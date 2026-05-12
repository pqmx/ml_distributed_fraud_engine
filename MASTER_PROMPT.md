# Master Prompt — Real-Time Fraud Detection Engine (C++)
## For: Claude Opus — paste this entire file as your first message

---

You are a senior FAANG systems engineer (Google/Meta/Amazon level) acting as the sole architect and code generator for a production-pattern real-time fraud detection engine. You will generate ALL boilerplate, config, and infrastructure code from scratch. The engineer using this prompt is a junior (0–2 years experience) targeting a FAANG backend SWE role. Their strongest languages are C++, Java, and TypeScript.

---

## What you are building

A high-throughput, low-latency fraud detection pipeline with the following architecture:

```
[Python tx producer] → [Kafka topic: transactions] → [C++ consumer service]
                                                              ↓
                                                    [Redis feature store]
                                                              ↓
                                                    [Python FastAPI gRPC ML server]
                                                              ↓
                                              [Decision engine: flag or pass]
                                                    ↙              ↘
                             [Kafka: clean-transactions]   [Kafka: fraud-dlq]
                                                              ↓
                                                    [Postgres: flagged log]
                                                              ↓
                                               [Prometheus + Grafana dashboard]
```

### Language breakdown
| Component | Language | Why |
|---|---|---|
| Kafka consumer + enrichment + decision engine | C++17 | Low-latency hot path |
| ML model server | Python + FastAPI + gRPC | ML ecosystem lives here |
| Transaction producer (synthetic data) | Python | Test scaffolding |
| Redis seeder | Python | Test scaffolding |
| All infra config | YAML/Dockerfile/CMake | Boilerplate |

---

## Tech stack (exact libraries)

**C++ service:**
- `librdkafka` — Kafka consumer + producer
- `hiredis` — Redis client
- `grpc` + `protobuf` — gRPC client to call Python ML server
- `prometheus-cpp` — metrics exposition
- `libpqxx` — Postgres client (for DLQ logging)
- `CMake` + `Conan` — build system + deps
- `spdlog` — structured logging
- `nlohmann/json` — JSON parsing

**Python ML server:**
- `FastAPI` — HTTP/gRPC server
- `grpcio` + `grpcio-tools` — gRPC server
- `xgboost` + `scikit-learn` — model training
- `pandas` — data processing
- `joblib` — model serialization

**Infrastructure:**
- Docker + Docker Compose — local orchestration
- Apache Kafka + Zookeeper
- Redis 7
- PostgreSQL 15
- Prometheus + Grafana

---

## Project directory structure to generate

```
fraud-detection-engine/
├── CMakeLists.txt
├── conanfile.txt
├── Dockerfile                          ← multi-stage C++ build
├── docker-compose.yml                  ← all 7 services
├── MASTER_PROMPT.md                    ← this file
├── OPUS_CONTEXT.md                     ← full context doc
├── README.md                           ← architecture + how to run
│
├── proto/
│   └── fraud.proto                     ← shared protobuf schema
│
├── src/
│   ├── main.cpp                        ← entry point + thread pool init
│   ├── consumer/
│   │   ├── kafka_consumer.cpp          ← librdkafka poll loop
│   │   └── kafka_consumer.h
│   ├── enrichment/
│   │   ├── redis_feature_store.cpp     ← hiredis connection pool + pipelining
│   │   └── redis_feature_store.h
│   ├── scoring/
│   │   ├── grpc_ml_client.cpp          ← gRPC client stub + circuit breaker
│   │   ├── grpc_ml_client.h
│   │   ├── rule_engine.cpp             ← fallback rule-based scoring
│   │   └── rule_engine.h
│   ├── routing/
│   │   ├── kafka_producer.cpp          ← route to clean or DLQ topic
│   │   └── kafka_producer.h
│   ├── metrics/
│   │   ├── prometheus_metrics.cpp      ← prometheus-cpp instrumentation
│   │   └── prometheus_metrics.h
│   └── utils/
│       ├── thread_pool.cpp             ← std::thread + std::atomic work queue
│       ├── thread_pool.h
│       ├── circuit_breaker.cpp         ← circuit breaker (closed/open/half-open)
│       └── circuit_breaker.h
│
├── include/
│   └── config.h                        ← env var config loading
│
├── tests/
│   ├── test_rule_engine.cpp
│   ├── test_circuit_breaker.cpp
│   └── test_thread_pool.cpp
│
├── scripts/
│   ├── producer.py                     ← synthetic Kafka transaction producer
│   ├── seed_redis.py                   ← populate Redis with user feature history
│   ├── train_model.py                  ← train XGBoost on Kaggle fraud dataset
│   └── load_test.py                    ← Locust load test
│
├── ml_server/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── server.py                       ← FastAPI gRPC server
│   └── model/                          ← saved model artifacts
│
└── infra/
    ├── docker/
    │   └── docker-compose.yml
    └── monitoring/
        ├── prometheus.yml
        └── grafana_dashboard.json
```

---

## What to GENERATE (vibe-coded — produce complete, production-quality code)

Generate ALL of the following. Each file should be complete, not stubbed. Add brief inline comments explaining what each block does so the junior engineer can own it in interviews.

1. `CMakeLists.txt` — full build config with all deps, C++17, sanitizer flags for debug
2. `conanfile.txt` — all C++ dependencies pinned to specific versions
3. `Dockerfile` — multi-stage: builder stage (compile C++) + runtime stage (minimal)
4. `docker-compose.yml` — all 7 services: c++-service, kafka, zookeeper, redis, postgres, ml-server, prometheus, grafana
5. `proto/fraud.proto` — Transaction message, FraudScore response, FraudService RPC definition
6. `src/metrics/prometheus_metrics.cpp/.h` — counters, histograms for throughput, latency, DLQ count
7. `src/utils/thread_pool.cpp/.h` — std::thread pool with mutex-protected work queue (Opus implements this fully — it is NOT a skeleton)
8. `scripts/producer.py` — Faker-based synthetic transaction producer to Kafka
9. `scripts/seed_redis.py` — populate Redis with 10K users of fake transaction history
10. `scripts/train_model.py` — load Kaggle creditcard.csv, train XGBoost, save with joblib
11. `ml_server/server.py` — FastAPI + gRPC server loading saved model, serving FraudScore
12. `ml_server/requirements.txt`
13. `ml_server/Dockerfile`
14. `infra/monitoring/prometheus.yml` — scrape config
15. `infra/monitoring/grafana_dashboard.json` — dashboard with throughput, p99 latency, DLQ count
16. `README.md` — architecture diagram (ASCII), setup instructions, how to run, benchmark targets
17. `include/config.h` — env var loading with defaults

---

## What NOT to generate (engineer writes these themselves — they are interview-critical)

Leave these as clearly marked skeleton files with TODO comments and the function signatures only. Do NOT implement them:

- `src/consumer/kafka_consumer.cpp` — librdkafka poll loop, partition callbacks, offset commits
- `src/enrichment/redis_feature_store.cpp` — hiredis connection pool, pipelining, TTL design
- `src/scoring/grpc_ml_client.cpp` — gRPC async client, timeout, retry with backoff
- `src/scoring/rule_engine.cpp` — rule-based fallback scoring logic
- `src/routing/kafka_producer.cpp` — produce to clean or DLQ topic based on score
- `src/utils/circuit_breaker.cpp` — closed/open/half-open state machine
- `src/main.cpp` — thread pool init, signal handling, graceful shutdown

For each skeleton file, include:
- A comment block at the top explaining WHAT this component does and WHY it matters
- The exact librdkafka / hiredis / gRPC API calls they will need (as commented references)
- A "FAANG interview note" comment explaining what an interviewer will ask about this component
- All header includes they will need
- The function signatures with parameter and return type documentation

---

## Code quality standards (apply to all generated code)

- C++17 minimum. Use `std::optional`, `std::variant`, structured bindings where appropriate
- RAII everywhere — no raw `new`/`delete`, use `std::unique_ptr` / `std::shared_ptr`
- Error handling: use `std::expected` pattern or explicit error enums, never silent failures
- All public APIs documented with what they do, parameters, and failure modes
- Structured logging via spdlog with log levels (INFO, WARN, ERROR)
- No magic numbers — named constants or config values only
- Thread safety: document which methods are thread-safe and which are not

---

## Benchmark targets (put these in README)

| Metric | Target |
|---|---|
| Throughput | 50K transactions/sec |
| Enrichment latency (Redis) | < 2ms p99 |
| ML scoring latency (gRPC) | < 15ms p99 |
| End-to-end decision latency | < 20ms p99 |
| DLQ rate (healthy) | < 0.1% |

---

## Output format

Generate each file one at a time in this order, using a clear header before each:

```
=== FILE: path/to/file.ext ===
[file contents]
=== END FILE ===
```

After all files, output a "Next steps" section telling the engineer which skeleton file to implement first and what to study before starting (with specific links to librdkafka and hiredis docs).

---

## Start

Acknowledge this prompt, confirm the full file list you will generate, then begin generating files one by one. Do not stop until all files are complete.
