// =============================================================================
// src/consumer/kafka_consumer.h
// =============================================================================
// WHAT: librdkafka-based Kafka consumer for the transaction hot path.
// WHY: C++ gives us deterministic latency and control over the poll loop
//      that higher-level clients abstract away. We need that control for
//      manual offset commits, rebalance handling, and backpressure.
//
// FAANG INTERVIEW NOTE:
//   "Why manual offset commits instead of enable.auto.commit=true?"
//   Answer: auto-commit commits on a timer, not on processing success.
//   If the service crashes between commit and processing, we lose messages.
//   Manual commit after processing gives us at-least-once semantics.
//
// APIs you will need:
//   rd_kafka_t*         rd_kafka_new(rd_kafka_type_t, rd_kafka_conf_t*, ...)
//   rd_kafka_message_t* rd_kafka_consumer_poll(rd_kafka_t*, int timeout_ms)
//   rd_kafka_error_t*   rd_kafka_commit(rd_kafka_t*, const rd_kafka_topic_partition_list_t*, int async)
//   rd_kafka_conf_set_rebalance_cb()  <- partition assignment/revocation callbacks
// =============================================================================

#pragma once
#include <librdkafka/rdkafka.h>
#include <functional>
#include <string>
#include <atomic>
#include "fraud.pb.h"

class KafkaConsumer {
public:
    explicit KafkaConsumer(const std::string& brokers,
                           const std::string& group_id,
                           const std::string& topic);
    ~KafkaConsumer();

    void start(std::function<void(fraud::Transaction)> on_message);
    void stop();

    static void rebalance_cb(rd_kafka_t *rk,
                             rd_kafka_resp_err_t err,
                             rd_kafka_topic_partition_list_t *partitions,
                             void *opaque);

private:
    static void logPartitions(const char* action, rd_kafka_topic_partition_list_t *partitions);

    struct ScopeGuard {
        std::function<void()> f;
        ~ScopeGuard() { if (f) f(); }
    };

    rd_kafka_t* consumer_ = nullptr;
    std::atomic<bool> running_{false};
    int timeout_ms = 100;
};
