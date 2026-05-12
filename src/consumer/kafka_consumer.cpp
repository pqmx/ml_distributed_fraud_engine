// =============================================================================
// src/consumer/kafka_consumer.cpp  — IMPLEMENT THIS YOURSELF
// =============================================================================
// See kafka_consumer.h for full context, API references, and interview notes.
//
// SUGGESTED IMPLEMENTATION ORDER:
//   1. Constructor: rd_kafka_conf_t setup, set rebalance_cb, rd_kafka_new
//   2. start(): subscribe to topic, poll loop with rd_kafka_consumer_poll
//   3. Inside poll loop: deserialize protobuf, call on_message, commit offset
//   4. stop(): set running_ = false
//   5. rebalance_cb: handle RD_KAFKA_RESP_ERR__ASSIGN_PARTITIONS and REVOKE
//
// When you have an attempt, share it in chat for FAANG-level code review.

#include "kafka_consumer.h"
#include <spdlog/spdlog.h>

// TODO: implement KafkaConsumer constructor
// TODO: implement KafkaConsumer::start()
// TODO: implement KafkaConsumer::stop()
// TODO: implement KafkaConsumer::rebalance_cb()
// TODO: implement KafkaConsumer destructor
