// =============================================================================
// tests/test_rule_engine.cpp
// =============================================================================
// Tests for the fallback rule-based scorer. These will FAIL until you
// implement src/scoring/rule_engine.cpp — they're your spec.
//
// What the tests assume the rule engine does:
//   - Returns a score in [0.0, 1.0]
//   - Pure: no I/O, no global state, deterministic for same inputs
//   - Higher score = more suspicious
//   - At minimum 3 rules contributing to the score (your design — examples below)
//
// You can change the rules and adjust these tests, but the contract
// (range, purity, determinism) should hold.
// =============================================================================

#include "enrichment/redis_feature_store.h"  // UserFeatures struct
#include "scoring/rule_engine.h"

#include <fraud.pb.h>          // generated proto

#include <gtest/gtest.h>

#include <string>

namespace {

// Helper: build a "normal-looking" transaction + features baseline.
// Tests perturb fields off this baseline to exercise individual rules.
fraud::Transaction normal_tx() {
    fraud::Transaction tx;
    tx.set_tx_id("test-tx-001");
    tx.set_user_id("user-000001");
    tx.set_amount(50.0);
    tx.set_currency("USD");
    tx.set_country("US");
    tx.set_timestamp_ms(1'700'000'000'000);
    tx.set_method(fraud::Transaction::CARD);
    return tx;
}

UserFeatures normal_features() {
    UserFeatures f;
    f.tx_count_30d   = 50;
    f.avg_amount_30d = 60.0f;
    f.countries_30d  = "US";
    f.last_tx_ts     = 1'699'999'000'000;  // ~1000s before tx
    f.risk_score     = 0.10f;
    f.is_cache_miss  = false;
    return f;
}

std::string serialize(const fraud::Transaction& tx) {
    return tx.SerializeAsString();
}

} // namespace

TEST(RuleEngine, ReturnsScoreInValidRange) {
    RuleEngine engine;
    const auto tx       = normal_tx();
    const auto features = normal_features();

    float score = engine.score(serialize(tx), features);
    EXPECT_GE(score, 0.0f);
    EXPECT_LE(score, 1.0f);
}

TEST(RuleEngine, IsDeterministic) {
    RuleEngine engine;
    const auto tx       = normal_tx();
    const auto features = normal_features();

    float a = engine.score(serialize(tx), features);
    float b = engine.score(serialize(tx), features);
    EXPECT_FLOAT_EQ(a, b);
}

TEST(RuleEngine, NormalTransactionScoresLow) {
    RuleEngine engine;
    float score = engine.score(serialize(normal_tx()), normal_features());
    // Whatever your rules are, a vanilla US, $50, on-pattern tx should
    // score well under the default fraud threshold (0.85).
    EXPECT_LT(score, 0.5f) << "normal tx scored too high";
}

TEST(RuleEngine, LargeAmountIncreasesScore) {
    RuleEngine engine;
    auto features = normal_features();

    auto small = normal_tx();
    small.set_amount(50.0);

    auto large = normal_tx();
    large.set_amount(9'500.0);

    float small_score = engine.score(serialize(small), features);
    float large_score = engine.score(serialize(large), features);

    EXPECT_GT(large_score, small_score)
        << "large-amount rule should raise the score";
}

TEST(RuleEngine, NewCountryIncreasesScore) {
    RuleEngine engine;

    auto features = normal_features();
    features.countries_30d = "US";  // user only ever transacts in US

    auto local   = normal_tx();
    local.set_country("US");

    auto foreign = normal_tx();
    foreign.set_country("RU");      // never seen before

    float local_score   = engine.score(serialize(local),   features);
    float foreign_score = engine.score(serialize(foreign), features);

    EXPECT_GT(foreign_score, local_score)
        << "transaction from a country not in countries_30d should score higher";
}

TEST(RuleEngine, CacheMissAddsUncertaintyPenalty) {
    RuleEngine engine;
    const auto tx = normal_tx();

    auto known = normal_features();
    known.is_cache_miss = false;

    auto unknown = normal_features();
    unknown.is_cache_miss = true;
    unknown.tx_count_30d   = 0;
    unknown.avg_amount_30d = 0.0f;

    float known_score   = engine.score(serialize(tx), known);
    float unknown_score = engine.score(serialize(tx), unknown);

    EXPECT_GE(unknown_score, known_score)
        << "no-history users should not score lower than known-good users";
}
