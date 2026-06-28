import 'package:flutter/material.dart';
import '../../../data/models/order/order.dart';
import '../../../data/models/order/order_enums.dart';
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

class AnalyticsViewModel extends ChangeNotifier {
  AnalyticsViewModel({
    required List<Order> orders,
    DateTime? nowOverride,
  })  : _allOrders = orders,
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
    return DateRange(
      start: _range.start.subtract(span),
      end: _range.start,
    );
  }

  bool _inRange(DateTime dt, DateRange r) =>
      (dt.isAfter(r.start) || dt.isAtSameMomentAs(r.start)) &&
      (dt.isBefore(r.end) || dt.isAtSameMomentAs(r.end));

  List<Order> get filteredOrders => _allOrders
      .where((o) =>
          o.status == OrderStatus.completed &&
          o.completedAt != null &&
          _inRange(o.completedAt!, _range))
      .toList()
    ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  /// Orders completed in the previous period (for delta math).
  List<Order> get previousPeriodOrders => _allOrders
      .where((o) =>
          o.status == OrderStatus.completed &&
          o.completedAt != null &&
          _inRange(o.completedAt!, _previousRange))
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

  // ── Deltas vs previous period ─────────────────────────────────────────────

  /// (current - previous) / previous * 100. Returns null when previous is 0
  /// (can't compute a meaningful percentage).
  double? _pct(double current, double previous) {
    if (previous == 0) return null;
    return ((current - previous) / previous) * 100;
  }

  double? get deltaEarningsPct =>
      _pct(totalEarnings, previousPeriodOrders.fold(0.0, (s, o) => s + o.reward));

  double? get deltaWeightPct => _pct(
      totalWeightKg,
      previousPeriodOrders.fold(0.0, (s, o) => s + (o.weightKg ?? 0)));

  double? get deltaOrdersPct =>
      _pct(orderCount.toDouble(), previousPeriodOrders.length.toDouble());

  // ── Trend series for the line chart ───────────────────────────────────────

  /// Hero metric bucketed by day (week/month) or by month (allTime).
  /// Returns points oldest-first.
  List<TrendPoint> dailySeries(HeroMetric metric) {
    final valueOf = metric == HeroMetric.earnings
        ? (Order o) => o.reward
        : (Order o) => o.weightKg ?? 0.0;

    if (_period == AnalyticsPeriod.allTime) {
      return _monthlySeries(valueOf);
    }

    // Day-by-day from range.start (date-only) to _now.
    final startDay = DateTime(_range.start.year, _range.start.month, _range.start.day);
    final endDay = DateTime(_now.year, _now.month, _now.day);
    final buckets = <DateTime, double>{};
    for (var d = startDay;
        !d.isAfter(endDay);
        d = d.add(const Duration(days: 1))) {
      buckets[d] = 0;
    }
    for (final o in filteredOrders) {
      final key = o.completedAt != null
          ? DateTime(o.completedAt!.year, o.completedAt!.month, o.completedAt!.day)
          : null;
      if (key != null && buckets.containsKey(key)) {
        buckets[key] = buckets[key]! + valueOf(o);
      }
    }
    final pts = buckets.entries
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
    final pts = buckets.values
        .map((b) => TrendPoint(day: DateTime(b.year, b.month, 1), value: b.value))
        .toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    return pts;
  }

  // ── Waste-type breakdown ──────────────────────────────────────────────────

  /// Weight share per waste type over the filtered orders, sorted desc.
  /// Note: an order may carry multiple waste types; its weight is attributed
  /// to each of its types (so shares can sum > 1 when orders are mixed).
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
    final list = totals.entries
        .map((e) => WasteShare(
              type: e.key,
              kg: e.value,
              share: e.value / grand,
            ))
        .toList()
      ..sort((a, b) => b.kg.compareTo(a.kg));
    return list;
  }

  // ── Gantt orders (kept) ───────────────────────────────────────────────────

  /// Orders with both createdAt and completedAt — used by the Gantt chart.
  List<Order> get ganttOrders => _allOrders
      .where((o) =>
          o.status == OrderStatus.completed &&
          o.completedAt != null)
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
}

class _MonthBucket {
  _MonthBucket({required this.year, required this.month, required this.value});
  final int year;
  final int month;
  double value;
}
