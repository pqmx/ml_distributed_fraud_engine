// =============================================================================
// src/metrics/prometheus_metrics.cpp
// =============================================================================
// Implementation of the metrics facade. See prometheus_metrics.h for design.
// =============================================================================

#include "prometheus_metrics.h"

#include <prometheus/counter.h>
#include <prometheus/gauge.h>
#include <prometheus/histogram.h>
#include <prometheus/registry.h>
#include <prometheus/exposer.h>
#include <spdlog/spdlog.h>

#include <stdexcept>
#include <string>
#include <vector>

namespace fraud {

namespace {

// -----------------------------------------------------------------------------
// Histogram bucket boundaries (in seconds).
//
// Chosen to give us sub-ms resolution in the SLO-critical band:
//   - Redis enrichment SLO: < 2ms p99
//   - ML scoring SLO:       < 15ms p99
//   - End-to-end SLO:       < 20ms p99
//
// Buckets below 1ms catch wins; buckets up to 100ms catch tail blowups.
// -----------------------------------------------------------------------------
const std::vector<double> kLatencyBuckets = {
    0.0001,  // 100us
    0.0005,  // 500us
    0.001,   // 1ms
    0.002,   // 2ms   <- Redis SLO line
    0.005,   // 5ms
    0.010,   // 10ms
    0.015,   // 15ms  <- ML SLO line
    0.020,   // 20ms  <- E2E SLO line
    0.050,   // 50ms
    0.100,   // 100ms
    0.500,   // 500ms
    1.000,   // 1s
};

} // namespace

PrometheusMetrics::PrometheusMetrics(int port)
    : exposer_("0.0.0.0:" + std::to_string(port)),
      registry_(std::make_shared<prometheus::Registry>()) {

    // ---- Routing counter (labelled by route)
    tx_routed_family_ = &prometheus::BuildCounter()
        .Name("fraud_tx_routed_total")
        .Help("Number of transactions routed, labelled by destination")
        .Register(*registry_);

    // ---- Standalone counters
    circuit_open_total_ = &prometheus::BuildCounter()
        .Name("fraud_circuit_open_total")
        .Help("Number of circuit breaker OPEN transitions")
        .Register(*registry_)
        .Add({});

    dlq_poison_total_ = &prometheus::BuildCounter()
        .Name("fraud_dlq_poison_total")
        .Help("Messages routed to DLQ for poison-pill / parse errors")
        .Register(*registry_)
        .Add({});

    ml_fallback_total_ = &prometheus::BuildCounter()
        .Name("fraud_ml_fallback_total")
        .Help("Times we fell back from ML scoring to the rule engine")
        .Register(*registry_)
        .Add({});

    // ---- Histograms
    auto& e2e_family = prometheus::BuildHistogram()
        .Name("fraud_e2e_latency_seconds")
        .Help("End-to-end transaction processing latency")
        .Register(*registry_);
    e2e_latency_ = &e2e_family.Add({}, kLatencyBuckets);

    auto& redis_family = prometheus::BuildHistogram()
        .Name("fraud_redis_latency_seconds")
        .Help("Redis feature lookup latency")
        .Register(*registry_);
    redis_latency_ = &redis_family.Add({}, kLatencyBuckets);

    auto& ml_family = prometheus::BuildHistogram()
        .Name("fraud_ml_latency_seconds")
        .Help("Full gRPC scoring call latency (network + inference)")
        .Register(*registry_);
    ml_latency_ = &ml_family.Add({}, kLatencyBuckets);

    // ---- Gauge
    auto& queue_family = prometheus::BuildGauge()
        .Name("fraud_thread_pool_queue_depth")
        .Help("Current thread-pool queue depth (backpressure indicator)")
        .Register(*registry_);
    queue_depth_ = &queue_family.Add({});

    exposer_.RegisterCollectable(registry_);
    spdlog::info("PrometheusMetrics: exposer listening on :{}/metrics", port);
}

PrometheusMetrics::~PrometheusMetrics() {
    // Exposer destructor stops the HTTP server.
    spdlog::info("PrometheusMetrics: shutting down exposer");
}

void PrometheusMetrics::record_routed(const std::string& route) {
    // BuildCounter::Add will return the same counter for the same label set,
    // so this is effectively O(1) after the first call per label combination.
    tx_routed_family_->Add({{"route", route}}).Increment();
}

void PrometheusMetrics::observe_e2e_latency(double s)   { e2e_latency_->Observe(s); }
void PrometheusMetrics::observe_redis_latency(double s) { redis_latency_->Observe(s); }
void PrometheusMetrics::observe_ml_latency(double s)    { ml_latency_->Observe(s); }
void PrometheusMetrics::incr_circuit_open()             { circuit_open_total_->Increment(); }
void PrometheusMetrics::incr_dlq_poison()               { dlq_poison_total_->Increment(); }
void PrometheusMetrics::incr_ml_fallback()              { ml_fallback_total_->Increment(); }
void PrometheusMetrics::set_queue_depth(double n)       { queue_depth_->Set(n); }

} // namespace fraud
