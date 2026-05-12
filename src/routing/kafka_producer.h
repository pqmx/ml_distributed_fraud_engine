// src/routing/kafka_producer.h — SKELETON — implement yourself
// WHAT: Routes decisions to clean topic or fraud DLQ topic.
// FAANG NOTE: "How do you confirm delivery?" — delivery report callback (dr_msg_cb).
// Only after callback fires err=0 is the message durably committed to Kafka.
#pragma once
#include <librdkafka/rdkafka.h>
#include <string>

class KafkaProducer {
public:
    explicit KafkaProducer(const std::string& brokers,
                           const std::string& clean_topic,
                           const std::string& dlq_topic);
    ~KafkaProducer();
    void send_clean(const std::string& serialized_tx);
    void send_dlq(const std::string& serialized_tx, float score);
    void flush(int timeout_ms = 5000); // call before shutdown
private:
    rd_kafka_t* producer_ = nullptr;
    std::string clean_topic_, dlq_topic_;
    static void delivery_report_cb(rd_kafka_t*, const rd_kafka_message_t*, void*);
};
