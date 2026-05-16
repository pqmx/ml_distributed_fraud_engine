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
#include "enrichment/redis_feature_store.h"

class GrpcMlClient {
public:
    explicit GrpcMlClient(const std::string& server_address,
                          std::chrono::milliseconds timeout_ms = std::chrono::milliseconds(10)) : server_address_(server_address), timeout_ms_(timeout_ms) {
        auto channel = grpc::CreateChannel(server_address_, grpc::InsecureChannelCredentials());
        stub_ = fraud::FraudService::NewStub(channel);
    };
    // Returns nullopt on timeout or error — caller triggers circuit breaker
    std::optional<float> score(const std::string& serialized_tx, const UserFeatures& features) {
        fraud::ScoreRequest request;
        request.mutable_transaction()->ParseFromString(serialized_tx);

        auto* f = request.mutable_features();
        f->set_tx_count_30d(features.tx_count_30d);
        f->set_avg_amount_30d(features.avg_amount_30d);
        f->set_countries_30d(features.countries_30d);
        f->set_last_tx_ts_ms(features.last_tx_ts);
        f->set_risk_score(features.risk_score);
        f->set_is_cache_miss(features.is_cache_miss);
        grpc::ClientContext context;
        context.set_deadline(std::chrono::system_clock::now() + timeout_ms_);

        fraud::ScoreResponse response;
        stub_->Score(&context, request, &response);
        grpc::Status status = stub_->Score(&context, request, &response);
        if (status.ok())
            return response.fraud_probability();
        return std::nullopt;
    };
private:
    std::string server_address_;
    std::chrono::milliseconds timeout_ms_;
    std::unique_ptr<fraud::FraudService::Stub> stub_;
    // TODO: add stub_ after including generated .grpc.pb.h
};
