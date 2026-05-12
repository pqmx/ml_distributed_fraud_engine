// src/scoring/rule_engine.h — SKELETON — implement yourself
// WHAT: Fallback rule-based scorer used when circuit breaker is OPEN.
// Pure computation — NO I/O allowed. Must be callable in <1ms.
// Define at least 3 rules. Document why each threshold was chosen.
#pragma once
#include <string>
struct UserFeatures;

class RuleEngine {
public:
    // Returns 0.0-1.0 fraud probability
    float score(const std::string& serialized_tx, const UserFeatures& features);
};
