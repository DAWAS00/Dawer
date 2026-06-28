import 'package:flutter/material.dart';
import '../../../data/models/order/order.dart';
import 'models/analytics_period.dart';

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

  List<Order> get filteredOrders => _allOrders
      .where((o) =>
          o.status == OrderStatus.completed &&
          o.completedAt != null &&
          _range.contains(o.completedAt!))
      .toList()
    ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  double get totalEarnings =>
      filteredOrders.fold(0.0, (sum, o) => sum + o.reward);

  double get totalWeightKg =>
      filteredOrders.fold(0.0, (sum, o) => sum + (o.weightKg ?? 0));

  /// Simple CO₂ estimate: 1.5 kg CO₂ saved per kg of recycled material.
  double get estimatedCo2Kg => totalWeightKg * 1.5;

  int get orderCount => filteredOrders.length;

  /// Orders with both createdAt and completedAt — used by the Gantt chart.
  List<Order> get ganttOrders => _allOrders
      .where((o) =>
          o.status == OrderStatus.completed &&
          o.completedAt != null)
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
}
