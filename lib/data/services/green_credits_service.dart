// lib/data/services/green_credits_service.dart

import '../../core/constants/green_credits_config.dart';
import '../models/order/order.dart' show Order, OrderStatus, WasteType;

/// Computes خُضَر green credits earned for a completed order.
///
/// Stateless and const-constructible — safe to store as a final field.
class GreenCreditsService {
  const GreenCreditsService();

  /// Returns the number of خُضَر credits earned for [order].
  ///
  /// [weekStreak] — consecutive weeks ending at the current week where the
  /// user had at least one completed order. Computed by [weekStreakFrom].
  int creditsForOrder(Order order, {int weekStreak = 0}) {
    final weight = order.weightKg ?? order.estimatedWeightKg ?? 0.0;

    // 1. Base flat credit per order
    final base = GreenCreditsConfig.baseCreditsPerOrder.toDouble();

    // 2. Weight bonus
    final weightBonus = weight * GreenCreditsConfig.creditsPerKg;

    // 3. Highest material multiplier across all waste types in the order
    final materialMult = _highestMaterialMultiplier(order.wasteTypes);

    // 4. Streak multiplier
    final streakMult = GreenCreditsConfig.streakMultiplier(weekStreak);

    // 5. Formula: (base + weightBonus) × materialMult × streakMult
    final raw = (base + weightBonus) * materialMult * streakMult;

    return raw.round().clamp(1, 9999);
  }

  /// Computes the consecutive-WEEK streak ending at the most recent
  /// completed order in [completedOrders].
  ///
  /// A "week" is defined as Mon–Sun (ISO week). A week "counts" if at least
  /// one order in [completedOrders] has a `completedAt` inside that week.
  /// Streak breaks at the first missing week when counting backwards.
  static int weekStreakFrom(List<Order> completedOrders) {
    final dones = completedOrders
        .where((o) =>
            o.status == OrderStatus.completed && o.completedAt != null)
        .toList();

    if (dones.isEmpty) return 0;

    // Collect the set of (year, isoWeek) tuples that have at least one order.
    final weeks = <(int, int)>{};
    for (final o in dones) {
      final dt = o.completedAt!;
      weeks.add((_isoYear(dt), _isoWeek(dt)));
    }

    // Find the most recent week
    final sorted = weeks.toList()
      ..sort((a, b) {
        final yearCmp = b.$1.compareTo(a.$1);
        return yearCmp != 0 ? yearCmp : b.$2.compareTo(a.$2);
      });

    // Count backwards from the latest week
    var streak = 1;
    var current = sorted.first;
    for (var i = 1; i < sorted.length; i++) {
      final prev = _previousIsoWeek(current);
      if (sorted[i] == prev) {
        streak++;
        current = prev;
      } else {
        break;
      }
    }
    return streak;
  }

  double _highestMaterialMultiplier(List<WasteType> types) {
    if (types.isEmpty) return 1.0;
    return types
        .map((t) => GreenCreditsConfig.materialMultiplier[t] ?? 1.0)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Returns the ISO week number (1–53) for [dt].
  static int _isoWeek(DateTime dt) {
    // ISO week: week containing the first Thursday of the year.
    final dayOfYear = dt.difference(DateTime(dt.year, 1, 1)).inDays + 1;
    // Day-of-week: Mon=1, Sun=7
    final dow = dt.weekday; // Dart: Mon=1, Sun=7
    final weekNumber = ((dayOfYear - dow + 10) / 7).floor();
    if (weekNumber < 1) return _isoWeek(DateTime(dt.year - 1, 12, 28));
    if (weekNumber > 52) {
      // Could be week 53 or week 1 of next year
      final jan1Next = DateTime(dt.year + 1, 1, 1).weekday;
      if (jan1Next <= 4) return 1; // week 1 of next year
    }
    return weekNumber;
  }

  /// Returns the ISO year for [dt] (may differ from calendar year in Jan/Dec).
  static int _isoYear(DateTime dt) {
    final week = _isoWeek(dt);
    if (week >= 52 && dt.month == 1) return dt.year - 1;
    if (week == 1 && dt.month == 12) return dt.year + 1;
    return dt.year;
  }

  /// Returns the (year, week) tuple of the week immediately before [yw].
  static (int, int) _previousIsoWeek((int, int) yw) {
    final (year, week) = yw;
    if (week > 1) return (year, week - 1);
    // Week 1 → last week of previous year (52 or 53)
    final dec28 = DateTime(year - 1, 12, 28);
    return (year - 1, _isoWeek(dec28));
  }
}
