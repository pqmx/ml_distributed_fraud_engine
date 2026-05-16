// =============================================================================
// src/scoring/grpc_ml_client.h
// =============================================================================
// gRPC client calling Python ML server for fraud probability score.
// =============================================================================

#pragma once

#include <grpcpp/grpcpp.h>
#include <chrono>
#include <optional>
#include <string>

#include "fraud.grpc.pb.h"
#include "enrichment/redis_feature_store.h"

class GrpcMlClient {
public:
    GrpcMlClient(const GrpcMlClient&) = delete;
    GrpcMlClient& operator=(const GrpcMlClient&) = delete;

    explicit GrpcMlClient(const std::string& server_address,
                          std::chrono::milliseconds timeout_ms = std::chrono::milliseconds(10));

    std::optional<float> score(const std::string& serialized_tx,
                               const UserFeatures& features);

private:
    std::string server_address_;
    std::chrono::milliseconds timeout_ms_;
    std::unique_ptr<fraud::FraudService::Stub> stub_;
};
