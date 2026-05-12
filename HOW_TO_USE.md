# How to use this project package

## Step 1 — Generate all boilerplate with Opus

Open a new Claude conversation and use **claude-opus-4** (the most capable model).

Paste the entire contents of `MASTER_PROMPT.md` as your first message.

Opus will generate every vibe-coded file one by one. Copy each file into the
correct location in this directory structure as it outputs them.

Files Opus will generate (complete, production-quality):
  - CMakeLists.txt
  - conanfile.txt
  - Dockerfile
  - docker-compose.yml
  - proto/fraud.proto
  - src/metrics/prometheus_metrics.cpp + .h
  - src/utils/thread_pool.cpp + .h  (the implementation — Opus fills this in)
  - scripts/producer.py
  - scripts/seed_redis.py
  - scripts/train_model.py
  - ml_server/server.py + requirements.txt + Dockerfile
  - infra/monitoring/prometheus.yml
  - infra/monitoring/grafana_dashboard.json
  - README.md
  - include/config.h

## Step 2 — Keep the skeleton files AS-IS

The following files are already in this package as skeletons. Do NOT ask
Opus to implement them. You write these yourself — they are the parts
interviewers will ask you to explain in detail.

  - src/consumer/kafka_consumer.h / .cpp
  - src/enrichment/redis_feature_store.h / .cpp
  - src/scoring/grpc_ml_client.h / .cpp
  - src/scoring/rule_engine.h / .cpp
  - src/routing/kafka_producer.h / .cpp
  - src/utils/circuit_breaker.h / .cpp
  - src/main.cpp

  Note: src/utils/thread_pool.h/.cpp headers are included as reference only.
  Opus will overwrite them with a full implementation — that is intentional.

## Step 3 — Work through the phases

Use the progress tracker (open the project in Claude chat and reference
the CodeCrafters-style tracker) to work through each phase in order:

  Phase 0 → Environment & scaffolding   (~5 hrs, all vibe)
  Phase 1 → Kafka consumer core         (~15 hrs, mostly learn)
  Phase 2 → Redis feature store         (~12 hrs, mostly learn)
  Phase 3 → ML server + gRPC boundary   (~15 hrs, mixed)
  Phase 4 → Dead-letter queue           (~12 hrs, all learn)
  Phase 5 → Observability + load test   (~11 hrs, mixed)

## Step 4 — For each skeleton file, use this prompt pattern

When you're ready to implement a skeleton file, open a Claude conversation
and say:

  "I'm implementing [filename] for my C++ fraud detection engine. Here is
   the skeleton with the TODOs: [paste file]. Before I write code, explain
   the concept and the APIs I need. Then let me attempt an implementation
   and review it as a FAANG engineer would."

Do NOT ask Claude to implement it for you. Ask it to teach you, then write
it yourself, then get it reviewed.

## Step 5 — Get your resume numbers

After Phase 5:
1. Run `scripts/load_test.py` with Locust
2. Screenshot the Grafana dashboard at peak load
3. Record your real p99 latency, throughput, and DLQ rate
4. Put those real measured numbers in your resume bullets
5. Commit everything to a public GitHub repo

---

## Reference links

- librdkafka: https://github.com/confluentinc/librdkafka/blob/master/INTRODUCTION.md
- hiredis: https://github.com/redis/hiredis
- gRPC C++: https://grpc.io/docs/languages/cpp/
- Kaggle dataset: https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud
- prometheus-cpp: https://github.com/jupp0r/prometheus-cpp
- spdlog: https://github.com/gabime/spdlog
