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
//   rd_kafka_conf_set_rebalance_cb()  ← partition assignment/revocation callbacks
// =============================================================================

#pragma once
#include <librdkafka/rdkafka.h>
#include <functional>
#include <string>
#include <atomic>

struct Transaction; // forward declare from proto

class KafkaConsumer {
public:
    // TODO: Constructor — take broker list, group id, topic name, config map
    // Initialize rd_kafka_conf_t, set rebalance callback, create rd_kafka_t handle
    explicit KafkaConsumer(const std::string& brokers,
                           const std::string& group_id,
                           const std::string& topic) {
            rd_kafka_conf_t* conf = rd_kafka_conf_new();
            rd_kafka_conf_set_rebalance_cb(conf, rebalance_cb);
            char errstr[512];

            if (rd_kafka_conf_set(conf, "bootstrap.servers", brokers.c_str(), errstr, sizeof(errstr)) != RD_KAFKA_CONF_OK) {
                rd_kafka_conf_destroy(conf);   // YOU still own conf_ here
                throw std::runtime_error(std::string("Kafka config error: ") + errstr);
            };
            if (rd_kafka_conf_set(conf, "group.id", group_id.c_str(), errstr, sizeof(errstr)) != RD_KAFKA_CONF_OK){
                rd_kafka_conf_destroy(conf);   // YOU still own conf_ here
                throw std::runtime_error(std::string("Kafka config error: ") + errstr);
            }
            if (rd_kafka_conf_set(conf, "enable.auto.commit", "false", errstr, sizeof(errstr)) != RD_KAFKA_CONF_OK) {
                rd_kafka_conf_destroy(conf);   // YOU still own conf_ here
                throw std::runtime_error(std::string("Kafka config error: ") + errstr);
            }

            consumer_= rd_kafka_new(RD_KAFKA_CONSUMER, conf, errstr, sizeof(errstr));
            if (consumer_ == nullptr) {
                rd_kafka_conf_destroy(conf);
                throw std::runtime_error(std::string("Kafka consumer creation failed: ") + errstr);
            }
            rd_kafka_poll_set_consumer(consumer_);

        rd_kafka_topic_partition_list_t* topics = rd_kafka_topic_partition_list_new(1);
        rd_kafka_topic_partition_list_add(topics, topic.c_str(), RD_KAFKA_PARTITION_UA);
        rd_kafka_subscribe(consumer_, topics);
        rd_kafka_topic_partition_list_destroy(topics);

    }

    ~KafkaConsumer(); // TODO: rd_kafka_consumer_close, rd_kafka_destroy

    // TODO: Start the poll loop. Runs until stop() is called.
    // Each message: deserialize protobuf → call on_message callback → commit offset
    // HINT: rd_kafka_consumer_poll returns nullptr on timeout (not an error)
    void start(std::function<void(Transaction)> on_message);

    // TODO: Signal the poll loop to stop gracefully
    // HINT: set a std::atomic<bool> flag, the poll loop checks it
    void stop();

    // TODO: Rebalance callback (static) — called by librdkafka on partition assign/revoke
    // FAANG INTERVIEW NOTE: "What happens to in-flight messages during a rebalance?"
    static void rebalance_cb(rd_kafka_t*, rd_kafka_resp_err_t,
                             rd_kafka_topic_partition_list_t*, void*);

private:
    rd_kafka_t* consumer_ = nullptr;
    std::atomic<bool> running_{false};
    // TODO: add any private members you need
};
