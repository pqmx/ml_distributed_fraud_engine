// =============================================================================
// src/main.cpp  — SKELETON — implement this yourself
// =============================================================================
// WHAT: Entry point. Wires together all components and manages lifecycle.
//
// RESPONSIBILITIES:
//   1. Load config from environment variables
//   2. Initialize thread pool, Redis store, gRPC client, Kafka consumer/producer
//   3. Register SIGTERM/SIGINT handlers for graceful shutdown
//   4. Start Prometheus HTTP metrics endpoint
//   5. Start Kafka consumer (blocking call — runs until signal)
//   6. On shutdown: stop consumer, drain thread pool, flush producer
//
// FAANG INTERVIEW NOTE:
//   "Walk me through your graceful shutdown sequence."
//   Answer should cover: stop accepting new messages → drain in-flight work
//   → flush Kafka producer → commit final offsets → close connections.
//   Order matters — flushing producer before committing offsets prevents
//   message loss on restart.
//
// TODO: implement this file

#include "consumer/kafka_consumer.h"
#include "enrichment/redis_feature_store.h"
#include "scoring/grpc_ml_client.h"
#include "scoring/rule_engine.h"
#include "routing/kafka_producer.h"
#include "metrics/prometheus_metrics.h"
#include "utils/thread_pool.h"
#include "utils/circuit_breaker.h"
#include "config.h"
#include <csignal>
#include <spdlog/spdlog.h>

// TODO: Global atomic flag for shutdown signal
// std::atomic<bool> g_shutdown{false};

// TODO: Signal handler — set g_shutdown = true
// void signal_handler(int sig) { ... }

int main() {
    // TODO: Load config
    // TODO: Register signal handlers (SIGTERM, SIGINT)
    // TODO: Initialize all components
    // TODO: Start Prometheus endpoint on :9090
    // TODO: Define the per-message processing lambda:
    //   auto process = [&](Transaction tx) {
    //     auto features = redis_store.get_features(tx.user_id());
    //     float score = 0.0f;
    //     if (circuit_breaker.allow_request()) {
    //       auto result = grpc_client.score(tx.SerializeAsString(), features);
    //       if (result.has_value()) { circuit_breaker.record_success(); score = result.value(); }
    //       else { circuit_breaker.record_failure(); score = rule_engine.score(tx.SerializeAsString(), features); }
    //     } else {
    //       score = rule_engine.score(tx.SerializeAsString(), features);  // degraded mode
    //     }
    //     if (score > config.fraud_threshold) producer.send_dlq(tx.SerializeAsString(), score);
    //     else producer.send_clean(tx.SerializeAsString());
    //     metrics.record_transaction(score);
    //   };
    // TODO: Enqueue to thread_pool inside consumer callback
    // TODO: consumer.start(...)  ← blocks until shutdown
    // TODO: Graceful shutdown sequence

    return 0;
}
