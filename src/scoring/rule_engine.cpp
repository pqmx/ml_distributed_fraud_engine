#include "rule_engine.h"
#include "enrichment/redis_feature_store.h"

#include <fraud.pb.h>

#include <algorithm>
#include <string>
#include <cmath>

float RuleEngine::score(const std::string& serialized_tx, const UserFeatures& features) {
    fraud::Transaction tx;
    if (!tx.ParseFromString(serialized_tx)) {
        // Unparseable transaction — treat as suspicious
        return 0.9f;
    }

    float total = 0.0f;

    // Rule 1: Large amount relative to user history
    // Threshold: amount > 5x average or absolute > $5000
    // Why: large deviation from spending pattern is a top fraud signal
    double amount = tx.amount();
    if (features.avg_amount_30d > 0.0f) {
        double ratio = amount / static_cast<double>(features.avg_amount_30d);
        if (ratio > 5.0) {
            total += 0.3f;
        } else if (ratio > 2.0) {
            total += 0.1f;
        }
    }
    if (amount > 5000.0) {
        total += 0.2f;
    }

    // Rule 2: New country not seen in 30-day history
    // Why: geo anomaly is a strong fraud indicator (card-not-present from new region)
    const std::string& country = tx.country();
    if (!country.empty() && !features.countries_30d.empty()) {
        if (features.countries_30d.find(country) == std::string::npos) {
            total += 0.25f;
        }
    }

    // Rule 3: Velocity — transaction too soon after last one
    // Why: rapid-fire transactions suggest automated/stolen-credential abuse
    if (features.last_tx_ts > 0 && tx.timestamp_ms() > 0) {
        int64_t gap_ms = tx.timestamp_ms() - features.last_tx_ts;
        if (gap_ms >= 0 && gap_ms < 60'000) {
            total += 0.15f;
        }
    }

    // Rule 4: Cache miss / no history — unknown user penalty
    // Why: no data means we can't confirm the user is legitimate
    if (features.is_cache_miss) {
        total += 0.15f;
    }

    return std::min(total, 1.0f);
}
