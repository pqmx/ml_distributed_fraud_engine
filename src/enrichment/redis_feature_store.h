// =============================================================================
// src/enrichment/redis_feature_store.h
// =============================================================================
// WHAT: Fetches user transaction history features from Redis to enrich
//       each transaction before scoring. Uses hiredis with pipelining
//       to minimize round-trip overhead.
//
// KEY SCHEMA (you decide the final design — this is a starting suggestion):
//   user:{user_id}:features  → Hash with fields:
//     tx_count_30d    (int)    — transactions in last 30 days
//     avg_amount_30d  (float)  — average transaction amount
//     countries_30d   (string) — comma-separated country codes seen
//     last_tx_ts      (int64)  — unix timestamp of last transaction
//     risk_score      (float)  — pre-computed rolling risk score
//
// FAANG INTERVIEW NOTE:
//   "Why HGETALL vs individual GETs?"
//   Answer: HGETALL fetches all fields in one round-trip. 5 individual
//   GETs = 5 round-trips = ~5x latency. Hash is the right data structure.
//
//   "How did you decide on the TTL?"
//   Answer: 30-day window matches the feature window. If a user hasn't
//   transacted in 30 days, their features are stale and we should
//   re-derive from the database rather than serve stale cache.
//
//   "What happens on a cache miss?"
//   Answer: return a default feature set (zero-history user) and
//   asynchronously schedule a cache warm from Postgres. Never block
//   the hot path on a DB query.
//
// APIs you will need:
//   redisContext*  redisConnect(host, port)
//   redisReply*    redisCommand(ctx, fmt, ...)
//   void           redisFree(ctx)
//   // For pipelining:
//   void           redisAppendCommand(ctx, fmt, ...)
//   int            redisGetReply(ctx, void** reply)
// =============================================================================

#pragma once
#include <hiredis/hiredis.h>
#include <string>
#include <optional>
#include <mutex>
#include <vector>
#include <variant>

struct UserFeatures {
    int tx_count_30d = 0;
    float avg_amount_30d = 0.0f;
    std::string countries_30d;
    int64_t last_tx_ts = 0;
    float risk_score = 0.0f;
    bool is_cache_miss = false; // true if user not found in Redis
};

class RedisFeatureStore {
public:
    // TODO: Constructor — create a pool of N hiredis connections
    // HINT: vector of redisContext*, protected by a mutex or connection pool pattern

    explicit RedisFeatureStore(const std::string& host, int port,
                                int pool_size = 8) : host_(host), port_(port) {

        pool_.reserve(pool_size);
        for (int i = 0; i < pool_size; i++) {
            redisContext* ctx = redisConnect(host.c_str(), port);
            if (ctx == nullptr || ctx->err) {
                for (auto* c : pool_) {
                    redisFree(c);
                }
                if (ctx) redisFree(ctx);
                throw std::runtime_error("Redis connection failed");
            }

            pool_.push_back(ctx);
        }
    }

    ~RedisFeatureStore() {
        for (auto* c : pool_) {
            redisFree(c);
        }
    }// TODO: redisFree all connections

    // TODO: Fetch features for a single user_id
    // Use HGETALL. Return default UserFeatures on miss (is_cache_miss=true).
    UserFeatures get_features(const std::string& user_id) {
        redisContext* ctx = acquire_connection();
        UserFeatures uf;
        if (ctx == nullptr) {
            uf.is_cache_miss = true;
            return uf;
        }

        redisReply* reply = (redisReply*)redisCommand(ctx, "HGETALL user:%s:features", user_id.c_str());
        if ( reply == nullptr) {
            throw std::runtime_error("Connection is broken");
        }
        if (reply->type == REDIS_REPLY_ARRAY && reply->elements == 0) {
            uf.is_cache_miss = true;
            return uf;
        }
        std::string field;
        std::string val;
        for (size_t i; i < reply->elements; i+=2) {
            field = reply->element[i]->str;
            val = reply->element[i + 1]->str;

            if (field == "tx_count_30d") {
                uf.tx_count_30d = std::stoi(val);
            }else if (field == "avg_amount_30d"){
                uf.avg_amount_30d = std::stof(val);
            }else if (field == "countries_30d") {
                uf.countries_30d = val;
            }else if (field == "last_tx_ts") {
                uf.last_tx_ts = std::stoll(val);
            }else if (field == "risk_score") {
                uf.risk_score = std::stof(val);
            }
        }
        freeReplyObject(reply);
        release_connection(ctx);
        return uf;
};

    // TODO: Fetch features for multiple user_ids in a single pipeline round-trip
    // HINT: redisAppendCommand N times, then redisGetReply N times
    // FAANG NOTE: this is the key optimization — batch lookups for a microbatch
    std::vector<UserFeatures> get_features_pipelined(
        const std::vector<std::string>& user_ids);

private:
    // TODO: Acquire a connection from the pool, use it, return it
    redisContext* acquire_connection() {
        std::lock_guard<std::mutex> lock(pool_mutex_);
        if (pool_.empty()) {
            return nullptr;
        }


        auto connection = pool_.back();
        pool_.pop_back();
        return connection;
    }
    void release_connection(redisContext* ctx) {
        std::lock_guard<std::mutex> lock(pool_mutex_);
        pool_.push_back(ctx);
    }

    std::vector<redisContext*> pool_;
    std::mutex pool_mutex_;
    std::string host_;
    int port_;
};
