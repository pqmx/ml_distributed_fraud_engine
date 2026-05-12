# Opus Context — Everything You Need to Know
## Full background for the fraud detection engine project

---

## Who this engineer is

- **Experience:** Junior (0–2 years)
- **Target role:** Backend SWE at a FAANG company (Google, Meta, Amazon, Apple, Netflix)
- **Strongest languages:** C++, Java, TypeScript/JS
- **Current projects:** Has a live full-stack dining app (Supabase) with 500 real college users
- **Strategy:** Building 3 portfolio projects specifically designed to hit FAANG backend interview topics

---

## The 3-project portfolio plan

| # | Project | Primary language | Status |
|---|---|---|---|
| 1 | Distributed URL shortener | Java + Spring Boot | Not started |
| 2 | Real-time fraud detection engine | **C++** (this project) | Starting now |
| 3 | Collaborative document editor backend | TypeScript + Java | Not started |

This project (fraud detection) was originally designed in Java but was swapped to C++ because the engineer has strong C++ skills and almost no junior FAANG candidate has a production-pattern C++ systems project — it's a genuine differentiator.

---

## Why this project was chosen

FAANG backend interviews test:
1. **Distributed systems thinking** — partitioning, caching, consistency
2. **Stream processing** — Kafka consumer patterns, offset management, backpressure
3. **Reliability engineering** — circuit breakers, dead-letter queues, graceful shutdown
4. **Low-latency design** — connection pooling, pipelining, lock-free data structures
5. **Observability** — metrics, tracing, SLOs

This project hits ALL of these in one codebase. The polyglot C++ ↔ Python gRPC boundary is especially impressive — it demonstrates a real architectural decision (C++ for the hot path, Python for the ML ecosystem) that engineers at Google, Meta, and Amazon make in production.

---

## The vibe coding philosophy

The engineer is using AI to generate boilerplate so they can focus their learning time on the parts that matter in interviews. The split:

**AI generates (vibe-coded):**
- CMake/Conan build config
- Dockerfiles and docker-compose
- Protobuf schemas and generated stubs
- Python ML training code
- Synthetic data generators
- Prometheus/Grafana config
- Redis seeder scripts

**Engineer writes themselves (interview-critical):**
- librdkafka poll loop + partition callbacks
- std::thread pool with std::atomic work queue
- hiredis connection pool + pipelining
- gRPC async client + circuit breaker
- Dead-letter queue routing logic
- Graceful shutdown + signal handling
- Rule-based fallback scoring engine

The rule: anything the engineer vibe-codes, they read line by line and must be able to explain every decision in an interview.

---

## FAANG interview questions this project prepares for

When an interviewer says "walk me through your fraud detection project," the engineer needs to answer:

**On the Kafka consumer:**
- "Why manual offset commits instead of auto-commit?"
- "How do you handle a rebalance mid-processing?"
- "What happens if your consumer falls behind — how do you detect and handle lag?"

**On the thread pool:**
- "Why std::atomic instead of a mutex here?"
- "How do you prevent the queue from growing unbounded?"
- "What's your graceful shutdown strategy?"

**On Redis feature store:**
- "Why did you choose this key schema?"
- "How did you decide on the TTL?"
- "Why hiredis pipelining — what problem does it solve?"

**On the circuit breaker:**
- "Walk me through the state machine — what triggers open, what triggers half-open?"
- "What happens to in-flight transactions when the circuit opens?"

**On the dead-letter queue:**
- "What's a poison pill message and how do you handle it?"
- "How do you ensure at-least-once delivery without duplicates?"

**On the gRPC boundary:**
- "Why gRPC instead of REST for the ML service call?"
- "How did you handle the case where the ML service is slow?"
- "What's your timeout and retry strategy?"

---

## Benchmark targets the engineer needs to hit

These go in the README and on the resume. They are achieved via Locust load testing and Prometheus measurement — not fabricated.

| Metric | Target | Resume bullet |
|---|---|---|
| Throughput | 50K tx/sec | "processed 50K transactions/sec" |
| Redis enrichment p99 | < 2ms | "reduced enrichment latency to 1.4ms p99 via hiredis pipelining" |
| ML scoring p99 | < 15ms | "ML inference latency under 15ms p99 with circuit breaker fallback" |
| End-to-end p99 | < 20ms | "end-to-end decision latency under 20ms p99" |
| DLQ rate | < 0.1% | "99.9%+ clean transaction routing with DLQ pattern" |

---

## Resume bullets (final form, after project is complete)

1. Built low-latency fraud detection engine in C++17 using librdkafka, processing 50K transactions/sec with p99 latency under 8ms
2. Implemented lock-free consumer thread pool using std::atomic and condition variables, achieving 4x throughput vs single-threaded baseline
3. Designed C++ ↔ Python gRPC boundary for ML model inference, with circuit breaker pattern falling back to rule-based scoring on timeout
4. Engineered Redis feature store client using hiredis pipelining, reducing per-transaction enrichment latency from 12ms to 1.4ms
5. Implemented dead-letter queue pattern with exponential backoff retry and poison pill handling; zero data loss under fault injection testing

---

## Project phases (CodeCrafters-style)

### Phase 0 — Environment & scaffolding (~5 hrs)
All vibe-coded. Get everything compiling and all 7 Docker services running.
- Milestone: `docker-compose up` brings up all services; C++ binary connects to Kafka

### Phase 1 — Kafka consumer core (~15 hrs, mostly learn)
The hot path. Engineer writes the poll loop themselves.
- Milestone: consuming 10K+ synthetic tx/sec, can explain every line cold

### Phase 2 — Redis feature store (~12 hrs, mostly learn)
Low-latency enrichment. Engineer designs key schema and writes hiredis pool.
- Milestone: enrichment under 2ms p99, can justify all design decisions

### Phase 3 — ML model server + gRPC boundary (~15 hrs, mixed)
Python server is vibe-coded. C++ gRPC client + circuit breaker is learned.
- Milestone: kill Python container mid-run, system falls back without crashing

### Phase 4 — Dead-letter queue + reliability (~12 hrs, all learn)
Fault tolerance. Engineer writes all of it.
- Milestone: 100 malformed messages → none crash service, all in DLQ

### Phase 5 — Observability + load testing (~11 hrs, mixed)
Where the resume numbers come from.
- Milestone: GitHub is public, README has real Grafana screenshots, benchmarks documented

**Total with vibe coding: ~70 hours**
**Schedule options:**
- 10 hrs/week → ~7 weeks
- 20 hrs/week → ~3.5 weeks
- Full-time summer → ~2 weeks

---

## Important notes for Opus

1. **The skeleton files are critical.** The engineer's ability to pass FAANG interviews depends on writing the core logic themselves. Do NOT implement the skeleton files — leave clear TODOs with API hints and FAANG interview notes.

2. **Code quality matters.** The generated boilerplate will be shown to FAANG interviewers during code reviews. It needs to look like it was written by a senior engineer: RAII, no raw pointers, proper error handling, spdlog structured logging.

3. **The README is a resume artifact.** Write it as if a Google L5 engineer is evaluating this project. Include: architecture diagram, design decisions and tradeoffs, how to run locally, benchmark results (as targets), and what problems were solved.

4. **Comment the why, not the what.** Inline comments should explain design decisions, not re-state the code. E.g., "// Pipeline 3 HGET calls in one round-trip to avoid 3x network overhead" not "// gets data from Redis"

5. **The Kafka dataset:** Use the Kaggle Credit Card Fraud Detection dataset (creditcard.csv) for model training. It has 284,807 transactions, 492 fraudulent (0.172%). The script should download it or provide instructions if Kaggle API isn't available.

---

## Contact / repo

- GitHub: [engineer adds their own]
- Dataset: https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud
- librdkafka docs: https://github.com/confluentinc/librdkafka/blob/master/INTRODUCTION.md
- hiredis docs: https://github.com/redis/hiredis
- gRPC C++ docs: https://grpc.io/docs/languages/cpp/
