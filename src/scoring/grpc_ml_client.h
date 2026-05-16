// src/scoring/grpc_ml_client.h — SKELETON — implement yourself
// WHAT: gRPC client calling Python ML server for fraud probability score.
// FAANG NOTE: "Why gRPC over REST?" protobuf ~5x smaller than JSON, compile-time
// type safety, per-call deadline via context.set_deadline() for tight latency SLOs.
#pragma once
#include <grpcpp/grpcpp.h>
#include <chrono>
#include <optional>
#include "fraud.grpc.pb.h"

// NOTE: UserFeatures is defined in enrichment/redis_feature_store.h
// Include that header in your .cpp, not just a forward declaration
struct UserFeatures;

class GrpcMlClient {
public:
    explicit GrpcMlClient(const std::string& server_address,
                          std::chrono::milliseconds timeout_ms = std::chrono::milliseconds(10)) : server_address_(server_address), timeout_ms_(timeout_ms) {
        auto channel = grpc::CreateChannel(server_address_, grpc::InsecureChannelCredentials());
        stub_ = fraud::FraudService::NewStub(channel);
    };
    // Returns nullopt on timeout or error — caller triggers circuit breaker
    std::optional<float> score(const std::string& serialized_tx, const UserFeatures& features);
private:
    std::string server_address_;
    std::chrono::milliseconds timeout_ms_;
    std::unique_ptr<fraud::FraudService::Stub> stub_;
    // TODO: add stub_ after including generated .grpc.pb.h
};
