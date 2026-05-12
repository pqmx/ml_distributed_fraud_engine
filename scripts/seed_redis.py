"""
scripts/seed_redis.py — populate Redis with synthetic user feature history.

Generates 10K users (matching the producer pool) with realistic-ish rolling
30-day stats so cache hits return useful enrichment data.

Schema (must match what RedisFeatureStore expects in C++):

  Key:  user:{user_id}:features
  Type: Hash
  Fields:
    tx_count_30d    int   transactions in last 30 days
    avg_amount_30d  float average transaction amount (USD)
    countries_30d   str   CSV of ISO-3166 alpha-2 codes
    last_tx_ts      int64 unix epoch ms of last transaction
    risk_score      float pre-computed rolling baseline 0.0-1.0

  TTL: 30 days. After that the user is treated as a cache miss
       and the C++ engine schedules a Postgres backfill.

Usage:
  python scripts/seed_redis.py
  python scripts/seed_redis.py --count 50000   # bigger pool
  python scripts/seed_redis.py --flush         # wipe before seeding
"""

from __future__ import annotations

import argparse
import logging
import os
import random
import time
from datetime import datetime, timedelta, timezone

import redis

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] seed_redis: %(message)s",
)
log = logging.getLogger(__name__)

COUNTRIES = ["US", "GB", "DE", "FR", "JP", "CA", "AU", "BR", "IN"]
TTL_SECONDS = 30 * 24 * 60 * 60  # 30 days


def gen_user_features() -> dict:
    """Synthesize a plausible feature set for one user."""
    tx_count = max(0, int(random.gauss(45, 20)))
    avg_amt  = round(random.uniform(15, 250), 2)

    # Most users transact in 1-2 countries; a small fraction travel a lot.
    n_countries = 1 if random.random() < 0.85 else random.randint(2, 4)
    countries = ",".join(random.sample(COUNTRIES, k=n_countries))

    # Last tx within the last 30 days, biased toward "recent".
    days_ago = random.expovariate(1 / 5)  # mean ~5 days
    last_tx  = datetime.now(timezone.utc) - timedelta(days=min(days_ago, 30))
    last_tx_ts = int(last_tx.timestamp() * 1000)

    # Risk score ~ Beta(2, 8): most users low risk, long tail.
    risk = round(random.betavariate(2, 8), 4)

    return {
        "tx_count_30d":   tx_count,
        "avg_amount_30d": avg_amt,
        "countries_30d":  countries,
        "last_tx_ts":     last_tx_ts,
        "risk_score":     risk,
    }


def main() -> int:
    p = argparse.ArgumentParser(description="Seed Redis with user feature data")
    p.add_argument("--host",  default=os.environ.get("REDIS_HOST", "localhost"))
    p.add_argument("--port",  type=int, default=int(os.environ.get("REDIS_PORT", "6379")))
    p.add_argument("--count", type=int, default=10_000, help="Number of users to seed")
    p.add_argument("--flush", action="store_true", help="FLUSHDB before seeding")
    p.add_argument("--ttl",   type=int, default=TTL_SECONDS, help="Per-key TTL in seconds")
    args = p.parse_args()

    r = redis.Redis(host=args.host, port=args.port, decode_responses=True)
    r.ping()  # fail loud if Redis is unreachable
    log.info("connected to redis://%s:%d", args.host, args.port)

    if args.flush:
        log.warning("FLUSHDB requested — wiping current Redis state")
        r.flushdb()

    # Pipeline writes for throughput. ~50K HSETs/sec on a local Redis.
    start = time.time()
    pipe = r.pipeline(transaction=False)

    for i in range(args.count):
        user_id = f"user-{i:06d}"
        key     = f"user:{user_id}:features"
        feat    = gen_user_features()
        pipe.hset(key, mapping=feat)
        pipe.expire(key, args.ttl)

        # Flush every 1000 commands so we don't OOM the pipeline buffer.
        if (i + 1) % 1000 == 0:
            pipe.execute()
            pipe = r.pipeline(transaction=False)

    pipe.execute()
    elapsed = time.time() - start
    log.info("seeded %d users in %.2fs (%.0f/sec)",
             args.count, elapsed, args.count / max(elapsed, 1e-9))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
