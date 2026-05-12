"""
scripts/load_test.py — Locust-based load generator.

This is a Kafka load test, not an HTTP one. Locust gives us its UI, web
dashboard, and rate-shaping for free; we just hijack `task` to publish
to Kafka instead of HTTP.

Usage (interactive web UI on :8089):
  pip install locust confluent-kafka faker
  locust -f scripts/load_test.py --host=kafka

Headless run (for CI / benchmarking):
  locust -f scripts/load_test.py --host=kafka \
         --users 200 --spawn-rate 50 \
         --run-time 5m --headless --csv=bench_results

Numbers we want to validate:
  - 50K tx/sec sustained
  - C++ engine end-to-end p99 < 20ms (read from Prometheus, not Locust)
  - DLQ rate < 0.1% under healthy conditions

Locust's request_success/request_failure are the wrong granularity for
this — we measure latency on the C++ side via Prometheus histograms.
This script's job is just to push enough load.
"""

from __future__ import annotations

import os
import random
import sys
import time
import uuid
from datetime import datetime, timezone

# generated stubs — see scripts/producer.py for setup notes
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "_generated"))
import fraud_pb2  # noqa: E402

from confluent_kafka import Producer
from locust import User, between, events, task

KAFKA_BROKERS = os.environ.get("KAFKA_BROKERS", "localhost:9092")
TOPIC         = os.environ.get("KAFKA_INPUT_TOPIC", "transactions")

USER_POOL    = [f"user-{i:06d}" for i in range(10_000)]
COUNTRIES    = ["US", "GB", "DE", "FR", "JP", "CA", "AU", "BR", "IN"]


def make_tx() -> bytes:
    tx = fraud_pb2.Transaction()
    tx.tx_id        = str(uuid.uuid4())
    tx.user_id      = random.choice(USER_POOL)
    tx.merchant_id  = f"merchant-{random.randint(0, 999):04d}"
    tx.amount       = round(random.uniform(5, 800), 2)
    tx.currency     = "USD"
    tx.country      = random.choice(COUNTRIES)
    tx.timestamp_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    tx.card_bin     = f"{random.randint(400000, 499999)}"
    tx.method       = fraud_pb2.Transaction.PaymentMethod.CARD
    return tx.SerializeToString()


class KafkaProducerClient:
    """Thin wrapper so each Locust user gets its own producer handle."""

    def __init__(self) -> None:
        self.producer = Producer({
            "bootstrap.servers": KAFKA_BROKERS,
            "linger.ms":         5,
            "batch.size":        64 * 1024,
            "acks":              1,
            "compression.type":  "lz4",
        })

    def send(self) -> None:
        t0 = time.perf_counter()
        self.producer.produce(TOPIC, value=make_tx())
        # Drive delivery callbacks. Don't flush per message — kills throughput.
        self.producer.poll(0)
        elapsed_ms = (time.perf_counter() - t0) * 1000

        # Report to Locust as a "request" so the UI graphs throughput.
        events.request.fire(
            request_type="KAFKA",
            name="produce_tx",
            response_time=elapsed_ms,
            response_length=0,
            exception=None,
        )

    def close(self) -> None:
        self.producer.flush(timeout=10)


class KafkaUser(User):
    # 1ms..3ms between calls per user. With 200 users → ~67-200K tx/sec ceiling
    # before the broker becomes the bottleneck.
    wait_time = between(0.001, 0.003)

    def on_start(self) -> None:
        self.client = KafkaProducerClient()

    def on_stop(self) -> None:
        self.client.close()

    @task
    def produce(self) -> None:
        self.client.send()
