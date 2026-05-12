#include "circuit_breaker.h"
#include <spdlog/spdlog.h>

CircuitBreaker::CircuitBreaker(int failure_threshold,
                               std::chrono::milliseconds recovery_timeout)
    : failure_threshold_(failure_threshold),
      recovery_timeout_(recovery_timeout) {}

bool CircuitBreaker::allow_request() {
    auto current = state_.load();

    switch (current) {
        case CircuitState::CLOSED:
            return true;

        case CircuitState::OPEN: {
            auto elapsed = std::chrono::steady_clock::now() - open_time_;
            if (elapsed >= recovery_timeout_) {
                // Try to transition to HALF_OPEN — only one thread wins
                auto expected = CircuitState::OPEN;
                if (state_.compare_exchange_strong(expected, CircuitState::HALF_OPEN)) {
                    spdlog::info("CircuitBreaker: OPEN -> HALF_OPEN (recovery timeout elapsed)");
                    return true;
                }
            }
            return false;
        }

        case CircuitState::HALF_OPEN:
            // Already in trial mode — block additional requests
            return false;
    }
    return false;
}

void CircuitBreaker::record_success() {
    failure_count_.store(0);
    auto expected = CircuitState::HALF_OPEN;
    if (state_.compare_exchange_strong(expected, CircuitState::CLOSED)) {
        spdlog::info("CircuitBreaker: HALF_OPEN -> CLOSED (trial succeeded)");
    }
}

void CircuitBreaker::record_failure() {
    auto current = state_.load();

    if (current == CircuitState::HALF_OPEN) {
        // Trial request failed — reopen immediately
        state_.store(CircuitState::OPEN);
        open_time_ = std::chrono::steady_clock::now();
        spdlog::warn("CircuitBreaker: HALF_OPEN -> OPEN (trial failed)");
        return;
    }

    int prev = failure_count_.fetch_add(1);
    if (prev + 1 >= failure_threshold_ && current == CircuitState::CLOSED) {
        auto expected = CircuitState::CLOSED;
        if (state_.compare_exchange_strong(expected, CircuitState::OPEN)) {
            open_time_ = std::chrono::steady_clock::now();
            spdlog::warn("CircuitBreaker: CLOSED -> OPEN (failures={} >= threshold={})",
                         prev + 1, failure_threshold_);
        }
    }
}

CircuitState CircuitBreaker::state() const {
    return state_.load();
}
