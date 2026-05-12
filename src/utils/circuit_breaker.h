// =============================================================================
// src/utils/circuit_breaker.h
// =============================================================================
// WHAT: Classic circuit breaker — protects the gRPC ML service call from
//       cascading failures when the Python server is slow or down.
//
// STATES:
//   CLOSED   → normal operation, all calls go through
//   OPEN     → fast-fail, return fallback immediately (no call made)
//   HALF_OPEN → trial mode, one call through to test if service recovered
//
// FAANG INTERVIEW NOTE:
//   "What triggers the transition from OPEN back to HALF_OPEN?"
//   Answer: a configurable timeout (e.g. 30 seconds). After timeout expires,
//   one trial request is allowed. Success → CLOSED. Failure → back to OPEN.
//
//   "What happens to the transactions when the circuit is OPEN?"
//   Answer: they fall through to the rule-based engine (see rule_engine.h).
//   This is the degraded-but-functional mode — we never drop transactions.
// =============================================================================

#pragma once
#include <atomic>
#include <chrono>
#include <cstdint>

enum class CircuitState { CLOSED, OPEN, HALF_OPEN };

class CircuitBreaker {
public:
    // TODO: Constructor — take failure_threshold (int), recovery_timeout (duration)
    explicit CircuitBreaker(int failure_threshold,
                            std::chrono::milliseconds recovery_timeout);

    // TODO: Returns true if the call should be allowed through
    // HINT: check current state; if OPEN, check if recovery_timeout has elapsed
    bool allow_request();

    // TODO: Record a successful call — reset failure count, transition to CLOSED
    void record_success();

    // TODO: Record a failed call — increment failure count
    // If count >= threshold AND state is CLOSED → transition to OPEN, record open_time
    void record_failure();

    CircuitState state() const;

private:
    std::atomic<int> failure_count_{0};
    // NOTE: std::atomic<CircuitState> works because enum class is trivially copyable.
    // Use atomic_compare_exchange_strong when transitioning states to avoid races.
    std::atomic<CircuitState> state_{CircuitState::CLOSED};
    std::chrono::steady_clock::time_point open_time_;
    int failure_threshold_;
    std::chrono::milliseconds recovery_timeout_;
};
