// =============================================================================
// src/consumer/kafka_consumer.cpp
// =============================================================================

#include "kafka_consumer.h"
#include <spdlog/spdlog.h>

KafkaConsumer::KafkaConsumer(const std::string& brokers,
                             const std::string& group_id,
                             const std::string& topic) {
    rd_kafka_conf_t* conf = rd_kafka_conf_new();
    rd_kafka_conf_set_rebalance_cb(conf, rebalance_cb);
    char errstr[512];

    if (rd_kafka_conf_set(conf, "bootstrap.servers", brokers.c_str(), errstr, sizeof(errstr)) != RD_KAFKA_CONF_OK) {
        rd_kafka_conf_destroy(conf);
        throw std::runtime_error(std::string("Kafka config error: ") + errstr);
    }
    if (rd_kafka_conf_set(conf, "group.id", group_id.c_str(), errstr, sizeof(errstr)) != RD_KAFKA_CONF_OK) {
        rd_kafka_conf_destroy(conf);
        throw std::runtime_error(std::string("Kafka config error: ") + errstr);
    }
    if (rd_kafka_conf_set(conf, "enable.auto.commit", "false", errstr, sizeof(errstr)) != RD_KAFKA_CONF_OK) {
        rd_kafka_conf_destroy(conf);
        throw std::runtime_error(std::string("Kafka config error: ") + errstr);
    }

    consumer_ = rd_kafka_new(RD_KAFKA_CONSUMER, conf, errstr, sizeof(errstr));
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

KafkaConsumer::~KafkaConsumer() {
    if (consumer_) {
        rd_kafka_consumer_close(consumer_);
        rd_kafka_destroy(consumer_);
    }
}

void KafkaConsumer::start(std::function<void(fraud::Transaction)> on_message) {
    running_ = true;
    while (running_) {
        rd_kafka_message_t* msg = rd_kafka_consumer_poll(consumer_, timeout_ms);
        if (msg == nullptr) {
            continue;
        }

        ScopeGuard destroy_guard{[msg] {
            rd_kafka_message_destroy(msg);
        }};

        fraud::Transaction tx;
        if (!tx.ParseFromArray(msg->payload, msg->len))
            continue;

        on_message(std::move(tx));

        rd_kafka_commit_message(consumer_, msg, 0);
    }
}

void KafkaConsumer::stop() {
    running_ = false;
}

void KafkaConsumer::rebalance_cb(rd_kafka_t *rk,
                                 rd_kafka_resp_err_t err,
                                 rd_kafka_topic_partition_list_t *partitions,
                                 void *opaque) {
    switch (err) {
        case RD_KAFKA_RESP_ERR__ASSIGN_PARTITIONS:
            logPartitions("assigned", partitions);
            rd_kafka_assign(rk, partitions);
            break;

        case RD_KAFKA_RESP_ERR__REVOKE_PARTITIONS:
            logPartitions("revoked", partitions);
            rd_kafka_commit(rk, partitions, 0);
            rd_kafka_assign(rk, NULL);
            break;

        default:
            spdlog::error("Rebalance error: {}", rd_kafka_err2str(err));
            rd_kafka_assign(rk, NULL);
            break;
    }
}

void KafkaConsumer::logPartitions(const char* action, rd_kafka_topic_partition_list_t *partitions) {
    for (int i = 0; i < partitions->cnt; i++) {
        spdlog::info("Rebalance {}: {} [{}]", action, partitions->elems[i].topic, partitions->elems[i].partition);
    }
}
