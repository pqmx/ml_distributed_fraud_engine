#include "circuit_breaker.h"
#include <spdlog/spdlog.h>

// TODO: Implement constructor

// TODO: Implement allow_request()
//   - CLOSED → return true
//   - OPEN → check if recovery_timeout has elapsed since open_time_
//     - if elapsed, CAS state from OPEN → HALF_OPEN, return true
//     - otherwise return false
//   - HALF_OPEN → return false (only one trial request at a time)

// TODO: Implement record_success()
//   - Reset failure_count_ to 0
//   - If state is HALF_OPEN, CAS to CLOSED

// TODO: Implement record_failure()
//   - If HALF_OPEN → store OPEN, record open_time_
//   - If CLOSED → increment failure_count_, if >= threshold CAS to OPEN, record open_time_

// TODO: Implement state() — just return state_.load()
