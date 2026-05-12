// =============================================================================
// tests/test_circuit_breaker.cpp
// =============================================================================
// Tests for the circuit breaker. These are written against the public API
// declared in src/utils/circuit_breaker.h. They will FAIL TO LINK until you
// implement circuit_breaker.cpp — that's intentional. Use these as your
// implementation spec.
//
// FAANG INTERVIEW ANGLE: a senior engineer writes the test before the code.
// When you're stuck on the state machine, re-read these tests — they tell
// you exactly what each state transition should look like.
// =============================================================================

#include "utils/circuit_breaker.h"

#include <gtest/gtest.h>

#include <chrono>
#include <thread>

using namespace std::chrono_literals;

TEST(CircuitBreaker, StartsClosedAndAllowsRequests) {
    CircuitBreaker cb(/*failure_threshold=*/3, /*recovery=*/30s);
    EXPECT_EQ(cb.state(), CircuitState::CLOSED);
    EXPECT_TRUE(cb.allow_request());
}

TEST(CircuitBreaker, OpensAfterThresholdFailures) {
    CircuitBreaker cb(/*threshold=*/3, /*recovery=*/30s);

    cb.record_failure();
    cb.record_failure();
    EXPECT_EQ(cb.state(), CircuitState::CLOSED);  // still under threshold

    cb.record_failure();                          // hits threshold
    EXPECT_EQ(cb.state(), CircuitState::OPEN);
    EXPECT_FALSE(cb.allow_request());
}

TEST(CircuitBreaker, SuccessResetsFailureCount) {
    CircuitBreaker cb(/*threshold=*/3, /*recovery=*/30s);

    cb.record_failure();
    cb.record_failure();
    cb.record_success();        // reset
    cb.record_failure();        // count back to 1
    cb.record_failure();        // 2

    EXPECT_EQ(cb.state(), CircuitState::CLOSED)
        << "success() should have reset the failure counter";
}

TEST(CircuitBreaker, TransitionsToHalfOpenAfterTimeout) {
    // Short recovery so the test runs fast.
    CircuitBreaker cb(/*threshold=*/2, /*recovery=*/100ms);

    cb.record_failure();
    cb.record_failure();
    EXPECT_EQ(cb.state(), CircuitState::OPEN);
    EXPECT_FALSE(cb.allow_request());

    std::this_thread::sleep_for(150ms);

    // Timeout has elapsed — the next allow_request should let exactly one
    // trial call through (HALF_OPEN semantics).
    EXPECT_TRUE(cb.allow_request());
    EXPECT_EQ(cb.state(), CircuitState::HALF_OPEN);
}

TEST(CircuitBreaker, HalfOpenSuccessClosesCircuit) {
    CircuitBreaker cb(/*threshold=*/2, /*recovery=*/50ms);

    cb.record_failure();
    cb.record_failure();
    std::this_thread::sleep_for(80ms);

    (void)cb.allow_request();  // transition to HALF_OPEN
    cb.record_success();
    EXPECT_EQ(cb.state(), CircuitState::CLOSED);
    EXPECT_TRUE(cb.allow_request());
}

TEST(CircuitBreaker, HalfOpenFailureReopensCircuit) {
    CircuitBreaker cb(/*threshold=*/2, /*recovery=*/50ms);

    cb.record_failure();
    cb.record_failure();
    std::this_thread::sleep_for(80ms);

    (void)cb.allow_request();  // HALF_OPEN
    cb.record_failure();
    EXPECT_EQ(cb.state(), CircuitState::OPEN)
        << "trial failure in HALF_OPEN must reopen the circuit";
}
