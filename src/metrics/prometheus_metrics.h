// =============================================================================
// src/metrics/prometheus_metrics.h
// =============================================================================
// WHAT: Wraps prometheus-cpp Registry + an HTTP /metrics exposer. Centralizes
//       every counter / histogram / gauge so the rest of the codebase doesn't
//       have to know about the prometheus-cpp API surface.
//
// WHY: Resume bullet "p99 < 8ms" needs to be measured, not asserted. Histogram
// buckets here are tuned to detect SLO violations cleanly (sub-ms granularity
// in the latency-critical band).
//
// FAANG INTERVIEW NOTE:
//   "Why histograms over summaries?"
//     Summaries quantiles are computed per-process and CANNOT be aggregated
//     across replicas. Histograms ship buckets that aggregate cleanly via
//     histogram_quantile() in PromQL. In any horizontally-scaled service
//     you want histograms.
//
//   "How did you pick the bucket boundaries?"
//     Logarithmic in the SLO-relevant band (1ms..50ms) plus a couple of
//     coarse buckets above for pathological cases. Sub-ms buckets so we
//     can see Redis enrichment perf without losing fidelity.
// =============================================================================

#pragma once

#include <prometheus/counter.h>
#include <prometheus/exposer.h>
#include <prometheus/family.h>
#include <prometheus/gauge.h>
#include <prometheus/histogram.h>
#include <prometheus/registry.h>

#include <memory>
#include <string>

namespace fraud {

class PrometheusMetrics {
public:
    // Starts the HTTP exposer on 0.0.0.0:<port>/metrics. Throws on bind failure
    // — fail loud at startup rather than silently dropping observability.
    explicit PrometheusMetrics(int port);
    ~PrometheusMetrics();

    PrometheusMetrics(const PrometheusMetrics&)            = delete;
    PrometheusMetrics& operator=(const PrometheusMetrics&) = delete;

    // -------------------------------------------------------------------------
    // Recording helpers — keep call sites tidy. All thread-safe
    // (prometheus-cpp guarantees this for counters/histograms/gauges).
    // -------------------------------------------------------------------------

    // Increment the per-route counter ("clean" | "dlq").
    void record_routed(const std::string& route);

    // End-to-end latency from poll() to producer ack, in seconds.
    void observe_e2e_latency(double seconds);

    // Latency of a single Redis HGETALL (or pipelined batch / N).
    void observe_redis_latency(double seconds);

    // Latency of a single gRPC ML scoring call (full RPC, not just inference).
    void observe_ml_latency(double seconds);

    // Misc transitions worth alerting on.
    void incr_circuit_open();
    void incr_dlq_poison();
    void incr_ml_fallback();        // scoring fell back to rule engine

    // Periodically updated gauge of current thread-pool queue depth.
    void set_queue_depth(double n);

private:
    prometheus::Exposer                        exposer_;
    std::shared_ptr<prometheus::Registry>      registry_;

    // Counters
    prometheus::Family<prometheus::Counter>*   tx_routed_family_;
    prometheus::Counter*                       circuit_open_total_;
    prometheus::Counter*                       dlq_poison_total_;
    prometheus::Counter*                       ml_fallback_total_;

    // Histograms
    prometheus::Histogram*                     e2e_latency_;
    prometheus::Histogram*                     redis_latency_;
    prometheus::Histogram*                     ml_latency_;

    // Gauges
    prometheus::Gauge*                         queue_depth_;
};

} // namespace fraud
