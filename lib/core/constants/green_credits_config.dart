// lib/core/constants/green_credits_config.dart

import '../../data/models/order/order.dart' show WasteType;

/// All tunable numbers for the خُضَر green-credits reward system.
///
/// Change values here only — never scatter magic numbers across the codebase.
class GreenCreditsConfig {
  GreenCreditsConfig._();

  // ── Earning ──────────────────────────────────────────────────────────────

  /// Flat credits earned for every completed order, regardless of material.
  static const int baseCreditsPerOrder = 10;

  /// Credits earned per kilogram of waste in the order.
  static const double creditsPerKg = 1.0;

  /// Per-material multiplier applied to (base + weightBonus).
  /// Higher = rarer / harder to recycle.
  static const Map<WasteType, double> materialMultiplier = {
    WasteType.electronics:     5.0,
    WasteType.batteries:       5.0,
    WasteType.chemicals:       4.0,
    WasteType.copperAluminium: 3.0,
    WasteType.oil:             3.0,
    WasteType.tires:           2.5,
    WasteType.rubber:          2.0,
    WasteType.metal:           2.0,
    WasteType.furniture:       1.5,
    WasteType.glass:           1.5,
    WasteType.construction:    1.5,
    WasteType.wood:            1.2,
    WasteType.textile:         1.2,
    WasteType.plastic:         1.0,
    WasteType.paper:           1.0,
    WasteType.organic:         1.0,
  };

  /// Bonus multiplier applied on top of earned credits based on consecutive
  /// week streak (weeks with at least one completed order).
  static double streakMultiplier(int weekStreak) {
    if (weekStreak >= 8) return 2.0;   // 8+ weeks → 2×
    if (weekStreak >= 4) return 1.5;   // 4–7 weeks → 1.5×
    if (weekStreak >= 2) return 1.25;  // 2–3 weeks → 1.25×
    return 1.0;                        // 0–1 weeks → no bonus
  }

  // ── Level thresholds (cumulative green points) ───────────────────────────

  static const int saplingThreshold        =  500;
  static const int treeThreshold           = 2000;
  static const int forestGuardianThreshold = 5000;

  // ── Redemption ───────────────────────────────────────────────────────────

  /// Every [redeemThreshold] خُضَر earned → [redeemJd] JD credit off next invoice.
  static const int    redeemThreshold = 500;
  static const double redeemJd        = 5.0;
}
