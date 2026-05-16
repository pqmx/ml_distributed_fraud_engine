#include "redis_feature_store.h"

#include <charconv>
#include <cstring>
#include <stdexcept>

// =============================================================================
// ConnectionGuard
// =============================================================================

RedisFeatureStore::ConnectionGuard::ConnectionGuard(RedisFeatureStore& store)
    : store_(store), ctx_(store.acquire_connection()) {}

RedisFeatureStore::ConnectionGuard::~ConnectionGuard() {
    if (ctx_) store_.release_connection(ctx_);
}

redisContext* RedisFeatureStore::ConnectionGuard::get() const { return ctx_; }

void RedisFeatureStore::ConnectionGuard::discard() { ctx_ = nullptr; }

// =============================================================================
// Constructor / Destructor
// =============================================================================

RedisFeatureStore::RedisFeatureStore(const std::string& host, int port,
                                     int pool_size)
    : host_(host), port_(port) {
    pool_.reserve(pool_size);
    for (int i = 0; i < pool_size; i++) {
        redisContext* ctx = redisConnect(host.c_str(), port);
        if (ctx == nullptr || ctx->err) {
            for (auto* c : pool_) redisFree(c);
            if (ctx) redisFree(ctx);
            throw std::runtime_error("Redis connection failed");
        }
        pool_.push_back(ctx);
    }
}

RedisFeatureStore::~RedisFeatureStore() {
    for (auto* c : pool_) redisFree(c);
}

// =============================================================================
// Pool management
// =============================================================================

redisContext* RedisFeatureStore::acquire_connection() {
    std::lock_guard<std::mutex> lock(pool_mutex_);
    if (pool_.empty()) return nullptr;
    redisContext* ctx = pool_.back();
    pool_.pop_back();
    return ctx;
}

void RedisFeatureStore::release_connection(redisContext* ctx) {
    std::lock_guard<std::mutex> lock(pool_mutex_);
    pool_.push_back(ctx);
}

// =============================================================================
// Parsing
// =============================================================================

void RedisFeatureStore::parse_reply(redisReply* reply, UserFeatures& uf) {
    for (size_t i = 0; i < reply->elements; i += 2) {
        const char* field = reply->element[i]->str;
        const char* val = reply->element[i + 1]->str;
        size_t val_len = reply->element[i + 1]->len;

        if (std::strcmp(field, "tx_count_30d") == 0) {
            std::from_chars(val, val + val_len, uf.tx_count_30d);
        } else if (std::strcmp(field, "avg_amount_30d") == 0) {
            std::from_chars(val, val + val_len, uf.avg_amount_30d);
        } else if (std::strcmp(field, "countries_30d") == 0) {
            uf.countries_30d.assign(val, val_len);
        } else if (std::strcmp(field, "last_tx_ts") == 0) {
            std::from_chars(val, val + val_len, uf.last_tx_ts);
        } else if (std::strcmp(field, "risk_score") == 0) {
            std::from_chars(val, val + val_len, uf.risk_score);
        }
    }
}

// =============================================================================
// get_features — single user lookup via HGETALL
// =============================================================================

UserFeatures RedisFeatureStore::get_features(const std::string& user_id) {
    ConnectionGuard guard(*this);
    redisContext* ctx = guard.get();

    UserFeatures uf;
    if (ctx == nullptr) {
        uf.is_cache_miss = true;
        return uf;
    }

    redisReply* reply = (redisReply*)redisCommand(
        ctx, "HGETALL user:%s:features", user_id.c_str());

    if (reply == nullptr) {
        guard.discard();
        throw std::runtime_error("Redis connection broken");
    }

    if (reply->type != REDIS_REPLY_ARRAY || reply->elements == 0) {
        uf.is_cache_miss = true;
        freeReplyObject(reply);
        return uf;
    }

    parse_reply(reply, uf);
    freeReplyObject(reply);
    return uf;
}

// =============================================================================
// get_features_pipelined — batch lookup, one round-trip for N users
// =============================================================================

std::vector<UserFeatures> RedisFeatureStore::get_features_pipelined(
    const std::vector<std::string>& user_ids) {
    ConnectionGuard guard(*this);
    redisContext* ctx = guard.get();

    std::vector<UserFeatures> results(user_ids.size());
    if (ctx == nullptr) {
        for (auto& uf : results) uf.is_cache_miss = true;
        return results;
    }

    for (const auto& uid : user_ids) {
        redisAppendCommand(ctx, "HGETALL user:%s:features", uid.c_str());
    }

    for (size_t i = 0; i < user_ids.size(); i++) {
        redisReply* reply = nullptr;
        if (redisGetReply(ctx, (void**)&reply) != REDIS_OK || reply == nullptr) {
            for (size_t j = i; j < user_ids.size(); j++) {
                results[j].is_cache_miss = true;
            }
            guard.discard();
            return results;
        }

        if (reply->type != REDIS_REPLY_ARRAY || reply->elements == 0) {
            results[i].is_cache_miss = true;
            freeReplyObject(reply);
            continue;
        }

        parse_reply(reply, results[i]);
        freeReplyObject(reply);
    }

    return results;
}
