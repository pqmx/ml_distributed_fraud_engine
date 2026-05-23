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
    // If elapsed → try CAS to HALF_OPEN, allow one trial request
    bool allow_request() {
        auto current = state_.load();

        switch (current) {
            case CircuitState::CLOSED:
                return true;

            case CircuitState::OPEN:
               if ( std::chrono::steady_clock::now() - open_time_ >= recovery_timeout_) {
                   auto expected = CircuitState::OPEN;
                   if (state_.compare_exchange_strong(expected, CircuitState::HALF_OPEN))
                       return true;
               }
        }
        return false;
    };

    // TODO: Record a successful call — reset failure count, transition to CLOSED
    // HINT: if state is HALF_OPEN, CAS to CLOSED
    void record_success() {
            auto expected = CircuitState::HALF_OPEN;
            state_.compare_exchange_strong(expected, CircuitState::CLOSED);
    }

    // TODO: Record a failed call — increment failure count
    // If count >= threshold AND state is CLOSED → transition to OPEN, record open_time
    // If state is HALF_OPEN → reopen immediately
    void record_failure() {
        int prev = failure_count_.fetch_add(1);
        if(prev + 1 >= failure_threshold_ && state_ == CircuitState::CLOSED) {
            auto expected = CircuitState::CLOSED;
            state_.compare_exchange_strong(expected, CircuitState::OPEN);
            open_time_ = std::chrono::steady_clock::now();
        }else if (state_ == CircuitState::HALF_OPEN) {
            auto expected = CircuitState::HALF_OPEN;
            state_.compare_exchange_strong(expected, CircuitState::OPEN);
        }
        failure_count_++;
    }

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
