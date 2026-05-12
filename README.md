# Real-Time Fraud Detection Engine

A low-latency, high-throughput fraud detection pipeline written in **C++17**, with a Python ML scoring sidecar reached over gRPC.

Designed to demonstrate the patterns FAANG backend interviews ask about: stream processing with manual offset management, lock-friendly concurrency, connection pooling and pipelining, circuit breakers, dead-letter queues, and end-to-end observability.

## Architecture

```
                ┌───────────────────────┐
                │ producer.py (synthetic)│
                └────────────┬───────────┘
                             │  protobuf
                             ▼
                ┌───────────────────────┐         ┌──────────────────┐
                │   Kafka:transactions   │◄───────►│   Zookeeper      │
                └────────────┬───────────┘         └──────────────────┘
                             │
                             ▼
   ┌─────────────────────────────────────────────────────────┐
   │              C++ Fraud Engine (this repo)                │
   │                                                          │
   │   ┌──────────────────┐                                   │
   │   │ KafkaConsumer    │  manual offset commits            │
   │   │ (librdkafka)     │  rebalance callbacks              │
   │   └────────┬─────────┘                                   │
   │            │ enqueue                                     │
   │            ▼                                             │
   │   ┌──────────────────┐                                   │
   │   │ ThreadPool (8)   │  bounded queue → backpressure     │
   │   └────────┬─────────┘                                   │
   │            │                                             │
   │   ┌────────▼─────────┐    HGETALL pipelined              │
   │   │ RedisFeatureStore│◄──────────► Redis (feature store) │
   │   │ (hiredis pool)   │                                    │
   │   └────────┬─────────┘                                   │
   │            │                                             │
   │   ┌────────▼─────────┐  gRPC unary + 10ms deadline       │
   │   │ GrpcMlClient     │◄────────────► ml-server (Python)  │
   │   │ + CircuitBreaker │                                    │
   │   └────────┬─────────┘                                   │
   │            │ score                                       │
   │            ▼                                             │
   │   ┌──────────────────┐                                   │
   │   │ Decision (>thr?) │                                   │
   │   └────────┬─────────┘                                   │
   │            │                                             │
   │   ┌────────▼─────────┐                                   │
   │   │ KafkaProducer    │                                   │
   │   └────────┬─────────┘                                   │
   │            │                                             │
   └────────────┼─────────────────────────────────────────────┘
                ▼
       ┌────────┴────────┐
       │                 │
       ▼                 ▼
 Kafka:clean-     Kafka:fraud-dlq → Postgres (audit log)
 transactions
                                  ↓
                        Prometheus scrapes :9090
                                  ↓
                              Grafana
```

## Tech stack

| Layer | Tech | Why |
|---|---|---|
| Hot path | C++17 + librdkafka + hiredis + gRPC | Deterministic latency, no GC pauses |
| ML scoring | Python 3.11 + FastAPI + gRPC + XGBoost | ML ecosystem lives in Python |
| Build | CMake + Conan | Reproducible C++ builds |
| Orchestration | Docker Compose | Single-command local stack |
| Observability | Prometheus + Grafana | Standard for SLO graphs |
| Logging | spdlog | Structured, low-allocation logs |

## Repository layout

```
fraud-detection-engine/
├── CMakeLists.txt              # Top-level CMake build
├── conanfile.txt               # Pinned C++ deps
├── Dockerfile                  # Multi-stage build for the C++ engine
├── docker-compose.yml          # All 7 services
│
├── proto/fraud.proto           # Single source of truth for wire schema
│
├── src/
│   ├── consumer/               # librdkafka consumer (skeleton — implement yourself)
│   ├── enrichment/             # Redis feature store + connection pool
│   ├── scoring/                # gRPC ML client + rule-engine fallback
│   ├── routing/                # Kafka producer (clean / DLQ)
│   ├── metrics/                # prometheus-cpp wrapper (✓ implemented)
│   └── utils/                  # ThreadPool (✓ implemented), CircuitBreaker
│
├── ml_server/
│   ├── server.py               # FastAPI + gRPC scoring server
│   ├── requirements.txt
│   └── Dockerfile
│
├── scripts/
│   ├── producer.py             # Synthetic Faker-based transaction producer
│   ├── seed_redis.py           # 10K users with rolling 30-day features
│   ├── train_model.py          # XGBoost trainer (Kaggle creditcard.csv)
│   └── load_test.py            # Locust-based load harness
│
├── infra/monitoring/
│   ├── prometheus.yml          # Scrape config
│   └── grafana_dashboard.json  # Pre-built fraud SLO dashboard
│
└── tests/                      # GoogleTest unit tests
```

## What's implemented vs. left for the engineer

This codebase is intentionally split into two halves. The infrastructure (build, Docker, schemas, metrics, ML server, scripts) is generated and ready to run. The hot-path components are skeleton-only — they're the parts an interviewer will ask about, so they need to be written and owned by hand.

| Component | Status |
|---|---|
| `CMakeLists.txt`, `conanfile.txt`, `Dockerfile`, `docker-compose.yml` | ✓ Ready |
| `proto/fraud.proto`, `include/config.h` | ✓ Ready |
| `src/utils/thread_pool.{h,cpp}` | ✓ Fully implemented + unit-tested |
| `src/metrics/prometheus_metrics.{h,cpp}` | ✓ Fully implemented |
| `ml_server/server.py`, all `scripts/*.py` | ✓ Ready |
| `src/consumer/kafka_consumer.cpp` | Skeleton — implement yourself |
| `src/enrichment/redis_feature_store.cpp` | Skeleton — implement yourself |
| `src/scoring/grpc_ml_client.cpp` | Skeleton — implement yourself |
| `src/scoring/rule_engine.cpp` | Skeleton — implement yourself |
| `src/routing/kafka_producer.cpp` | Skeleton — implement yourself |
| `src/utils/circuit_breaker.cpp` | Skeleton — implement yourself |
| `src/main.cpp` | Skeleton — implement yourself |

Each skeleton header has a comment block explaining what the component does, the relevant librdkafka/hiredis/gRPC APIs to call, and the FAANG interview question it's meant to prepare for. The unit tests in `tests/` are written against the public API of these skeletons, so you can drive the implementation TDD-style.

## Quick start

```bash
# 1. Generate Python protobuf stubs (needed for producer.py and load_test.py)
mkdir -p scripts/_generated
python -m grpc_tools.protoc -Iproto \
    --python_out=scripts/_generated \
    --grpc_python_out=scripts/_generated \
    proto/fraud.proto

# 2. (Optional) train the ML model on Kaggle data
#    Skip this and the server falls back to a stub scorer.
mkdir -p data ml_server/model
kaggle datasets download mlg-ulb/creditcardfraud -p data/ --unzip
python scripts/train_model.py

# 3. Bring everything up
docker compose up --build

# 4. In another shell, seed Redis and start producing
python scripts/seed_redis.py
python scripts/producer.py --rate 5000

# 5. Open dashboards
#    - Grafana:   http://localhost:3000  (anon access enabled)
#    - Prometheus: http://localhost:9090
#    - Engine /metrics: http://localhost:9091/metrics
```

## SLO targets

Targets to validate via load test + Grafana, not assertions baked in.

| Metric | Target | How to verify |
|---|---|---|
| Throughput | 50K transactions/sec | `rate(fraud_tx_routed_total[1m])` |
| Redis enrichment p99 | < 2ms | `histogram_quantile(0.99, fraud_redis_latency_seconds_bucket)` |
| ML scoring p99 (full RPC) | < 15ms | `histogram_quantile(0.99, fraud_ml_latency_seconds_bucket)` |
| End-to-end p99 | < 20ms | `histogram_quantile(0.99, fraud_e2e_latency_seconds_bucket)` |
| DLQ rate (healthy) | < 0.1% | `dlq / total` panel in dashboard |

## Key design decisions

**Manual Kafka offset commits.** `enable.auto.commit=true` commits on a timer regardless of processing success. If the service crashes between commit and processing, messages are silently lost. We commit only after successful routing, giving at-least-once semantics — duplicates are far easier to handle downstream than data loss.

**Bounded thread-pool queue.** Unbounded queues hide the real failure mode: when the gRPC ML server gets slow, memory grows until the kernel OOM-kills the process. With a bounded queue, `enqueue()` returns false when full; the consumer responds by calling `rd_kafka_pause_partitions()` to apply backpressure upstream, letting Kafka itself buffer the burst durably.

**hiredis connection pool with pipelining.** A single hiredis context is not thread-safe, so we maintain a pool of N contexts gated by a mutex. For batch lookups (multiple users in flight at once), `redisAppendCommand` + `redisGetReply` pipelines the round-trip — N lookups in 1 round-trip instead of N. This is where the "1.4ms p99 enrichment" number comes from.

**Circuit breaker around the gRPC call.** If the Python ML server slows down or crashes, naïvely retrying every transaction makes the cascade worse. The breaker trips after N consecutive failures, fast-fails for a recovery window, then admits one trial call to test recovery. While open, traffic falls through to a deterministic rule-based scorer — degraded mode, never down.

**C++ ↔ Python over gRPC.** REST + JSON would parse to ~5x the bytes on the wire and add per-call ser/des overhead in both directions. gRPC gives us protobuf binary encoding, compile-time-checked schemas, and per-call deadlines (`ClientContext::set_deadline`) so a slow server can't hold the C++ caller indefinitely.

**Dead-letter queue + Postgres audit log.** Poison-pill messages (malformed protobuf, unknown enum values, etc.) are routed to `fraud-dlq` rather than retried into a tight loop. A separate consumer (out of scope here) drains the DLQ into Postgres for audit and offline analysis. The healthy DLQ rate is a top-level SLI.

## What an interviewer will ask

A non-exhaustive list of questions this codebase prepares you to answer cold. The skeleton headers reference these inline so you build the muscle memory while implementing.

- Why manual offset commits? What goes wrong with `enable.auto.commit=true`?
- What happens to in-flight processing during a Kafka rebalance?
- Why a bounded thread-pool queue? How does backpressure propagate?
- Why hiredis pipelining over individual `GET` calls?
- What's your TTL strategy for the feature store? What happens on a cache miss?
- Walk through the circuit breaker state machine: triggers, timeouts, recovery.
- What's a poison-pill message? How does the DLQ pattern handle it?
- Why gRPC over REST for the ML boundary? How do you handle a slow server?
- Walk through your graceful shutdown sequence.

## Build and test locally (without Docker)

```bash
# C++ build
conan install . --output-folder=build --build=missing -s build_type=Release
cmake -B build -DCMAKE_TOOLCHAIN_FILE=build/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
cmake --build build -j

# Run tests
ctest --test-dir build --output-on-failure

# Run with sanitizers (debug builds)
cmake -B build-debug -DCMAKE_BUILD_TYPE=Debug -DENABLE_SANITIZERS=ON \
      -DCMAKE_TOOLCHAIN_FILE=build-debug/conan_toolchain.cmake
cmake --build build-debug -j
```

## License

MIT.
