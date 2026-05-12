// =============================================================================
// include/config.h
// =============================================================================
// Centralized config loaded from environment variables.
//
// Why env vars (not a YAML file)?  Twelve-factor app principle: config that
// varies per-environment (dev / staging / prod) lives in the env, not in the
// image. The same Docker image we run in dev runs in prod with different env.
//
// Usage:
//   const auto cfg = Config::from_env();
//   spdlog::info("kafka brokers: {}", cfg.kafka_brokers);
//
// FAANG NOTE: header-only intentionally — config is read once at startup,
// the cost of a translation unit isn't worth the indirection.
// =============================================================================

#pragma once

#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <stdexcept>
#include <string>
#include <string_view>

namespace fraud {

// -----------------------------------------------------------------------------
// Tiny env helpers — throw on missing required vars with a descriptive message.
// Silent fallbacks to defaults bite us in prod when an env var gets typo'd.
// -----------------------------------------------------------------------------
inline std::string env_or(std::string_view key, std::string_view default_val) {
    const char* v = std::getenv(std::string{key}.c_str());
    return v ? std::string{v} : std::string{default_val};
}

inline std::string env_required(std::string_view key) {
    const char* v = std::getenv(std::string{key}.c_str());
    if (!v || *v == '\0') {
        throw std::runtime_error(
            "Required environment variable missing: " + std::string{key});
    }
    return std::string{v};
}

inline int env_int(std::string_view key, int default_val) {
    const char* v = std::getenv(std::string{key}.c_str());
    if (!v || *v == '\0') return default_val;
    try { return std::stoi(v); }
    catch (...) {
        throw std::runtime_error(
            "Env var " + std::string{key} + " is not a valid int: " + v);
    }
}

inline float env_float(std::string_view key, float default_val) {
    const char* v = std::getenv(std::string{key}.c_str());
    if (!v || *v == '\0') return default_val;
    try { return std::stof(v); }
    catch (...) {
        throw std::runtime_error(
            "Env var " + std::string{key} + " is not a valid float: " + v);
    }
}

// -----------------------------------------------------------------------------
// Config — every knob, with sane defaults that work against docker-compose.
// -----------------------------------------------------------------------------
struct Config {
    // Kafka
    std::string kafka_brokers;
    std::string kafka_input_topic;
    std::string kafka_clean_topic;
    std::string kafka_dlq_topic;
    std::string kafka_group_id;

    // Redis
    std::string redis_host;
    int         redis_port;
    int         redis_pool_size;

    // ML server
    std::string ml_grpc_address;
    std::chrono::milliseconds ml_timeout_ms;

    // Postgres (audit log)
    std::string postgres_dsn;

    // Thread pool / queue
    int  thread_pool_size;
    int  max_queue_size;

    // Decision policy
    float fraud_threshold;

    // Circuit breaker
    int circuit_failure_threshold;
    std::chrono::seconds circuit_recovery;

    // Observability
    int         prometheus_port;
    std::string log_level;

    // -------------------------------------------------------------------------
    // Factory: read all values from the environment with documented defaults.
    // Defaults are tuned for `docker compose up` to Just Work.
    // -------------------------------------------------------------------------
    static Config from_env() {
        Config c;
        c.kafka_brokers      = env_or("KAFKA_BROKERS",      "localhost:9092");
        c.kafka_input_topic  = env_or("KAFKA_INPUT_TOPIC",  "transactions");
        c.kafka_clean_topic  = env_or("KAFKA_CLEAN_TOPIC",  "clean-transactions");
        c.kafka_dlq_topic    = env_or("KAFKA_DLQ_TOPIC",    "fraud-dlq");
        c.kafka_group_id     = env_or("KAFKA_GROUP_ID",     "fraud-engine");

        c.redis_host         = env_or("REDIS_HOST",         "localhost");
        c.redis_port         = env_int("REDIS_PORT",        6379);
        c.redis_pool_size    = env_int("REDIS_POOL_SIZE",   8);

        c.ml_grpc_address    = env_or("ML_GRPC_ADDRESS",    "localhost:50051");
        c.ml_timeout_ms      = std::chrono::milliseconds(env_int("ML_TIMEOUT_MS", 10));

        c.postgres_dsn       = env_or("POSTGRES_DSN",
                                      "postgresql://fraud:fraud@localhost:5432/fraud");

        c.thread_pool_size   = env_int("THREAD_POOL_SIZE",  8);
        c.max_queue_size     = env_int("MAX_QUEUE_SIZE",    10000);

        c.fraud_threshold    = env_float("FRAUD_THRESHOLD", 0.85f);

        c.circuit_failure_threshold = env_int("CIRCUIT_FAILURE_THRESHOLD", 5);
        c.circuit_recovery = std::chrono::seconds(env_int("CIRCUIT_RECOVERY_SEC", 30));

        c.prometheus_port    = env_int("PROMETHEUS_PORT",   9090);
        c.log_level          = env_or("LOG_LEVEL",          "info");
        return c;
    }
};

} // namespace fraud
