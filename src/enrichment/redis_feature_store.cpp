// src/enrichment/redis_feature_store.cpp  — IMPLEMENT THIS YOURSELF
// See redis_feature_store.h for full context, API references, and interview notes.
//
// SUGGESTED IMPLEMENTATION ORDER:
//   1. Constructor: create pool_size hiredis connections, store in pool_
//   2. acquire_connection() / release_connection() — simple mutex-based pool
//   3. get_features(): HGETALL user:{user_id}:features, parse reply, free reply
//   4. get_features_pipelined(): redisAppendCommand N times → redisGetReply N times
//   5. Destructor: redisFree all connections
//
// KEY INSIGHT: measure latency before and after adding pipelining.
// That delta is your resume bullet: "reduced enrichment latency from Xms to Yms"

#include "redis_feature_store.h"
#include <spdlog/spdlog.h>

// TODO: implement all methods
