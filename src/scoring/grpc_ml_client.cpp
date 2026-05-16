#include "grpc_ml_client.h"

// =============================================================================
// Constructor — create channel + stub (both reused across all calls)
// =============================================================================

GrpcMlClient::GrpcMlClient(const std::string& server_address,
                             std::chrono::milliseconds timeout_ms)
    : server_address_(server_address), timeout_ms_(timeout_ms) {
    auto channel = grpc::CreateChannel(server_address_, grpc::InsecureChannelCredentials());
    stub_ = fraud::FraudService::NewStub(channel);
}

// =============================================================================
// score — single unary RPC with deadline, returns nullopt on failure
// =============================================================================

std::optional<float> GrpcMlClient::score(const std::string& serialized_tx,
                                          const UserFeatures& features) {
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
    grpc::Status status = stub_->Score(&context, request, &response);

    if (status.ok())
        return response.fraud_probability();

    return std::nullopt;
}
