import 'package:flutter/material.dart';
import '../../../data/models/order/order.dart';
import '../../../data/utils/eco_impact_calculator.dart';
import 'models/analytics_period.dart';

/// One bucket of the trend series.
class TrendPoint {
  const TrendPoint({required this.day, required this.value});
  final DateTime day;
  final double value;
}

/// One slice of the waste-type breakdown.
class WasteShare {
  const WasteShare({required this.type, required this.kg, required this.share});
  final WasteType type;
  final double kg;
  final double share; // 0..1 of total weight
}

/// Which metric the hero card should lead with.
enum HeroMetric { earnings, weight }

/// Per-stage average time for the cycle-time breakdown. Any stage with no
/// valid samples is null; the widget hides that segment.
class CycleTimeBreakdown {
  const CycleTimeBreakdown({
    this.avgAcceptMinutes,
    this.avgPickupMinutes,
    this.avgTransitMinutes,
    this.avgDropoffMinutes,
    this.avgTotalMinutes,
  });
  final double? avgAcceptMinutes; // created -> accepted
  final double? avgPickupMinutes; // accepted -> arrivedAtPickup
  final double? avgTransitMinutes; // arrivedAtPickup -> arrivedAtDropoff
  final double? avgDropoffMinutes; // arrivedAtDropoff -> completed
  final double? avgTotalMinutes; // created -> completed

  bool get isEmpty => avgTotalMinutes == null;
}

/// Reward-per-kg for one waste type, used by the profitability chart.
class WasteProfitability {
  const WasteProfitability({
    required this.type,
    required this.rewardPerKg,
    required this.totalKg,
    required this.totalReward,
    required this.sampleCount,
  });
  final WasteType type;
  final double rewardPerKg;
  final double totalKg;
  final double totalReward;
  final int sampleCount;
}

/// One job in the earnings-efficiency top list.
class EfficientJob {
  const EfficientJob({required this.order, required this.jodPerKm});
  final Order order;
  final double jodPerKm;
}

class AnalyticsViewModel extends ChangeNotifier {
  AnalyticsViewModel({required List<Order> orders, DateTime? nowOverride})
    : _allOrders = orders,
      _nowOverride = nowOverride;

  final List<Order> _allOrders;
  final DateTime? _nowOverride;

  AnalyticsPeriod _period = AnalyticsPeriod.month;
  AnalyticsPeriod get period => _period;

  void setPeriod(AnalyticsPeriod p) {
    _period = p;
    notifyListeners();
  }

  DateTime get _now => _nowOverride ?? DateTime.now();

  DateRange get _range => _period.dateRange(now: _now);

  /// The immediately-prior window of the same length as the current period.
  DateRange get _previousRange {
    final span = _range.end.difference(_range.start);
    return DateRange(start: _range.start.subtract(span), end: _range.start);
  }

  bool _inRange(DateTime dt, DateRange r) =>
      (dt.isAfter(r.start) || dt.isAtSameMomentAs(r.start)) &&
      (dt.isBefore(r.end) || dt.isAtSameMomentAs(r.end));

  List<Order> get filteredOrders =>
      _allOrders
          .where(
            (o) =>
                o.status == OrderStatus.completed &&
                o.completedAt != null &&
                _inRange(o.completedAt!, _range),
          )
          .toList()
        ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  /// Orders completed in the previous period (for delta math).
  List<Order> get previousPeriodOrders => _allOrders
      .where(
        (o) =>
            o.status == OrderStatus.completed &&
            o.completedAt != null &&
            _inRange(o.completedAt!, _previousRange),
      )
      .toList();

  double get totalEarnings =>
      filteredOrders.fold(0.0, (sum, o) => sum + o.reward);

  double get totalWeightKg =>
      filteredOrders.fold(0.0, (sum, o) => sum + (o.weightKg ?? 0));

  /// Simple CO₂ estimate: 1.5 kg CO₂ saved per kg of recycled material.
  double get estimatedCo2Kg => totalWeightKg * 1.5;

  int get orderCount => filteredOrders.length;

  /// Average reward per completed order (0 if none).
  double get avgRewardPerOrder =>
      orderCount == 0 ? 0 : totalEarnings / orderCount;

  // ── Daily report (today's snapshot, independent of the period filter) ─────

  /// Orders completed today, regardless of the selected [period].
  List<Order> get todaysCompletedOrders {
    final today = DateTime(_now.year, _now.month, _now.day);
    return _allOrders
        .where(
          (o) =>
              o.status == OrderStatus.completed &&
              o.completedAt != null &&
              DateTime(
                    o.completedAt!.year,
                    o.completedAt!.month,
                    o.completedAt!.day,
                  ) ==
                  today,
        )
        .toList();
  }

  int get todaysOrderCount => todaysCompletedOrders.length;

  double get todaysWeightKg =>
      todaysCompletedOrders.fold(0.0, (sum, o) => sum + (o.weightKg ?? 0));

  double get todaysEarnings =>
      todaysCompletedOrders.fold(0.0, (sum, o) => sum + o.reward);

  /// Environmental impact of today's completed orders, computed per-order
  /// from actual weight (not the wizard's category estimate) so it reflects
  /// what was really processed.
  EcoImpactResult get todaysEcoImpact {
    var co2 = 0.0, water = 0.0, energy = 0.0;
    for (final o in todaysCompletedOrders) {
      final w = o.weightKg;
      if (w == null || w <= 0 || o.wasteTypes.isEmpty) continue;
      final impact = EcoImpactCalculator.calculateForWeight(o.wasteTypes, w);
      co2 += impact.co2SavedKg;
      water += impact.waterSavedLiters;
      energy += impact.energySavedKwh;
    }
    return EcoImpactResult(
      co2SavedKg: co2,
      waterSavedLiters: water,
      energySavedKwh: energy,
    );
  }

  // ── Deltas vs previous period ─────────────────────────────────────────────

  double? _pct(double current, double previous) {
    if (previous == 0) return null;
    return ((current - previous) / previous) * 100;
  }

  double? get deltaEarningsPct => _pct(
    totalEarnings,
    previousPeriodOrders.fold(0.0, (s, o) => s + o.reward),
  );

  double? get deltaWeightPct => _pct(
    totalWeightKg,
    previousPeriodOrders.fold(0.0, (s, o) => s + (o.weightKg ?? 0)),
  );

  double? get deltaOrdersPct =>
      _pct(orderCount.toDouble(), previousPeriodOrders.length.toDouble());

  // ── Trend series for the line chart ───────────────────────────────────────

  List<TrendPoint> dailySeries(HeroMetric metric) {
    final valueOf = metric == HeroMetric.earnings
        ? (Order o) => o.reward
        : (Order o) => o.weightKg ?? 0.0;

    if (_period == AnalyticsPeriod.allTime) {
      return _monthlySeries(valueOf);
    }

    final startDay = DateTime(
      _range.start.year,
      _range.start.month,
      _range.start.day,
    );
    final endDay = DateTime(_now.year, _now.month, _now.day);
    final buckets = <DateTime, double>{};
    for (
      var d = startDay;
      !d.isAfter(endDay);
      d = d.add(const Duration(days: 1))
    ) {
      buckets[d] = 0;
    }
    for (final o in filteredOrders) {
      final key = o.completedAt != null
          ? DateTime(
              o.completedAt!.year,
              o.completedAt!.month,
              o.completedAt!.day,
            )
          : null;
      if (key != null && buckets.containsKey(key)) {
        buckets[key] = buckets[key]! + valueOf(o);
      }
    }
    final pts =
        buckets.entries
            .map((e) => TrendPoint(day: e.key, value: e.value))
            .toList()
          ..sort((a, b) => a.day.compareTo(b.day));
    return pts;
  }

  List<TrendPoint> _monthlySeries(double Function(Order) valueOf) {
    final buckets = <String, _MonthBucket>{};
    for (final o in filteredOrders) {
      if (o.completedAt == null) continue;
      final key = '${o.completedAt!.year}-${o.completedAt!.month}';
      buckets.update(
        key,
        (b) => _MonthBucket(
          year: o.completedAt!.year,
          month: o.completedAt!.month,
          value: b.value + valueOf(o),
        ),
        ifAbsent: () => _MonthBucket(
          year: o.completedAt!.year,
          month: o.completedAt!.month,
          value: valueOf(o),
        ),
      );
    }
    final pts =
        buckets.values
            .map(
              (b) =>
                  TrendPoint(day: DateTime(b.year, b.month, 1), value: b.value),
            )
            .toList()
          ..sort((a, b) => a.day.compareTo(b.day));
    return pts;
  }

  // ── Waste-type breakdown ──────────────────────────────────────────────────

  List<WasteShare> get wasteBreakdown {
    final totals = <WasteType, double>{};
    for (final o in filteredOrders) {
      final w = o.weightKg ?? 0;
      if (w == 0) continue;
      for (final t in o.wasteTypes) {
        totals.update(t, (v) => v + w, ifAbsent: () => w);
      }
    }
    final grand = totals.values.fold(0.0, (s, v) => s + v);
    if (grand == 0) return const [];
    final list =
        totals.entries
            .map(
              (e) =>
                  WasteShare(type: e.key, kg: e.value, share: e.value / grand),
            )
            .toList()
          ..sort((a, b) => b.kg.compareTo(a.kg));
    return list;
  }

  // ── Gantt orders ──────────────────────────────────────────────────────────

  List<Order> get ganttOrders =>
      _allOrders
          .where(
            (o) => o.status == OrderStatus.completed && o.completedAt != null,
          )
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  // ── Streak ─────────────────────────────────────────────────────────────────
  //
  // A "day" is active if at least one order was completed on it. The streak
  // counts consecutive active days ending today (or the most recent active
  // day when today is silent — grace for "haven't worked yet today").

  Set<DateTime> get _activeDays => _allOrders
      .where((o) => o.status == OrderStatus.completed && o.completedAt != null)
      .map(
        (o) => DateTime(
          o.completedAt!.year,
          o.completedAt!.month,
          o.completedAt!.day,
        ),
      )
      .toSet();

  /// Current consecutive-day streak. 0 when no completed orders.
  int get currentStreak {
    final days = _activeDays;
    if (days.isEmpty) return 0;
    var cursor = DateTime(_now.year, _now.month, _now.day);
    // Grace: if today is silent, start from yesterday (driver hasn't worked yet today).
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Longest-ever consecutive-day streak. 0 when no completed orders.
  int get longestStreak {
    final sorted = _activeDays.toList()..sort();
    if (sorted.isEmpty) return 0;
    var best = 1;
    var run = 1;
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]) == const Duration(days: 1)) {
        run++;
        if (run > best) best = run;
      } else {
        run = 1;
      }
    }
    return best;
  }

  /// Completed-order counts per day for the last [days] days, keyed by
  /// day-granularity DateTime. Used by the heatmap. Oldest-first.
  Map<DateTime, int> activityByDay(int days) {
    final today = DateTime(_now.year, _now.month, _now.day);
    final start = today.subtract(Duration(days: days - 1));
    final counts = <DateTime, int>{};
    for (final o in _allOrders) {
      if (o.status != OrderStatus.completed || o.completedAt == null) continue;
      final d = DateTime(
        o.completedAt!.year,
        o.completedAt!.month,
        o.completedAt!.day,
      );
      if (d.isAfter(start) || d.isAtSameMomentAs(start)) {
        counts.update(d, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  // ── Cycle-time breakdown ──────────────────────────────────────────────────
  //
  // Averages each lifecycle stage over filteredOrders, skipping orders
  // missing a needed timestamp. Negative deltas (clock skew) clamped to 0.

  double? _avgMinutes(
    DateTime? Function(Order) start,
    DateTime? Function(Order) end,
  ) {
    final samples = <double>[];
    for (final o in filteredOrders) {
      final s = start(o);
      final e = end(o);
      if (s == null || e == null) continue;
      final mins = e.difference(s).inMinutes.toDouble();
      if (mins < 0) continue; // defensive: skip skew
      samples.add(mins);
    }
    if (samples.isEmpty) return null;
    return samples.fold(0.0, (a, b) => a + b) / samples.length;
  }

  CycleTimeBreakdown get cycleTime {
    final accept = _avgMinutes((o) => o.createdAt, (o) => o.acceptedAt);
    final pickup = _avgMinutes((o) => o.acceptedAt, (o) => o.arrivedAtPickupAt);
    final transit = _avgMinutes(
      (o) => o.arrivedAtPickupAt,
      (o) => o.arrivedAtDropoffAt,
    );
    final dropoff = _avgMinutes(
      (o) => o.arrivedAtDropoffAt,
      (o) => o.completedAt,
    );
    final total = _avgMinutes((o) => o.createdAt, (o) => o.completedAt);
    return CycleTimeBreakdown(
      avgAcceptMinutes: accept,
      avgPickupMinutes: pickup,
      avgTransitMinutes: transit,
      avgDropoffMinutes: dropoff,
      avgTotalMinutes: total,
    );
  }

  // ── Waste-type profitability (reward per kg) ──────────────────────────────
  //
  // Each order's reward is split evenly across its wasteTypes, then divided
  // by the order's weightKg. Accumulated per type. Approximate — see ADR.

  List<WasteProfitability> get wasteProfitability {
    final reward = <WasteType, double>{};
    final kg = <WasteType, double>{};
    final count = <WasteType, int>{};
    for (final o in filteredOrders) {
      final w = o.weightKg;
      if (w == null || w <= 0 || o.wasteTypes.isEmpty) continue;
      final share = o.reward / o.wasteTypes.length;
      for (final t in o.wasteTypes) {
        reward.update(t, (v) => v + share, ifAbsent: () => share);
        kg.update(t, (v) => v + w, ifAbsent: () => w);
        count.update(t, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    if (reward.isEmpty) return const [];
    final list = reward.entries.map((e) {
      final k = kg[e.key] ?? 0;
      return WasteProfitability(
        type: e.key,
        rewardPerKg: k == 0 ? 0 : e.value / k,
        totalKg: k,
        totalReward: e.value,
        sampleCount: count[e.key] ?? 0,
      );
    }).toList()..sort((a, b) => b.rewardPerKg.compareTo(a.rewardPerKg));
    return list;
  }

  // ── Earnings efficiency (reward per km) ───────────────────────────────────

  double? get earningsPerKm {
    final samples = <double>[];
    for (final o in filteredOrders) {
      final d = o.distanceKm;
      if (d == null || d <= 0) continue;
      samples.add(o.reward / d);
    }
    if (samples.isEmpty) return null;
    return samples.fold(0.0, (a, b) => a + b) / samples.length;
  }

  /// Top-3 jobs by reward-per-km (most efficient). Empty when none qualify.
  List<EfficientJob> get bestJobsByEfficiency {
    final jobs = <EfficientJob>[];
    for (final o in filteredOrders) {
      final d = o.distanceKm;
      if (d == null || d <= 0) continue;
      jobs.add(EfficientJob(order: o, jodPerKm: o.reward / d));
    }
    jobs.sort((a, b) => b.jodPerKm.compareTo(a.jodPerKm));
    return jobs.take(3).toList();
  }
}

class _MonthBucket {
  _MonthBucket({required this.year, required this.month, required this.value});
  final int year;
  final int month;
  double value;
}
