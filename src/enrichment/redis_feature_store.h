// =============================================================================
// src/enrichment/redis_feature_store.h
// =============================================================================
// Fetches user transaction history features from Redis to enrich each
// transaction before scoring. Uses hiredis with pipelining to minimize
// round-trip overhead.
//
// Key schema:
//   user:{user_id}:features → Hash with fields:
//     tx_count_30d, avg_amount_30d, countries_30d, last_tx_ts, risk_score
// =============================================================================

#pragma once

#include <hiredis/hiredis.h>

#include <cstdint>
#include <mutex>
#include <string>
#include <vector>

struct UserFeatures {
    int tx_count_30d = 0;
    float avg_amount_30d = 0.0f;
    std::string countries_30d;
    int64_t last_tx_ts = 0;
    float risk_score = 0.0f;
    bool is_cache_miss = false;
};

class RedisFeatureStore {
public:
    RedisFeatureStore(const RedisFeatureStore&) = delete;
    RedisFeatureStore& operator=(const RedisFeatureStore&) = delete;

    explicit RedisFeatureStore(const std::string& host, int port,
                               int pool_size = 8);
    ~RedisFeatureStore();

    UserFeatures get_features(const std::string& user_id);
    std::vector<UserFeatures> get_features_pipelined(
        const std::vector<std::string>& user_ids);

private:
    class ConnectionGuard {
    public:
        explicit ConnectionGuard(RedisFeatureStore& store);
        ~ConnectionGuard();
        redisContext* get() const;
        void discard();

    private:
        RedisFeatureStore& store_;
        redisContext* ctx_;
    };

    static void parse_reply(redisReply* reply, UserFeatures& uf);
    redisContext* acquire_connection();
    void release_connection(redisContext* ctx);

    std::vector<redisContext*> pool_;
    std::mutex pool_mutex_;
    std::string host_;
    int port_;
};
