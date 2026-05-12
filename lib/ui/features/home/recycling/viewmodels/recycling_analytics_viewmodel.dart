import 'package:flutter/foundation.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../../../../domain/services/carbon_calculator.dart';

class MonthlyTotal {
  final int year;
  final int month;
  final double weightKg;
  final double spendJd;

  const MonthlyTotal({
    required this.year,
    required this.month,
    required this.weightKg,
    required this.spendJd,
  });

  String get label {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return months[month - 1];
  }
}

class AnalyticsSummary {
  final double totalKg;
  final double totalSpendJd;
  final double totalCo2Kg;
  final int totalShipments;
  final Map<WasteType, double> kgByType;
  final List<MonthlyTotal> monthly;
  final List<MapEntry<String, double>> topSuppliers;

  const AnalyticsSummary({
    required this.totalKg,
    required this.totalSpendJd,
    required this.totalCo2Kg,
    required this.totalShipments,
    required this.kgByType,
    required this.monthly,
    required this.topSuppliers,
  });
}

class RecyclingAnalyticsViewModel extends ChangeNotifier {
  final AppOrderStore _store;

  RecyclingAnalyticsViewModel(this._store) {
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => notifyListeners();

  List<Order> get _completed => _store.companyIncoming
      .where((o) => o.status == OrderStatus.completed)
      .toList();

  AnalyticsSummary get summary {
    double totalKg = 0;
    double totalSpend = 0;
    double totalCo2 = 0;
    final Map<WasteType, double> kgByType = {};
    final Map<String, double> supplierSpend = {};
    final Map<String, MonthlyTotal> byMonth = {};

    for (final o in _completed) {
      final w = o.weightKg ?? o.estimatedWeightKg ?? 0;
      totalKg += w;
      totalSpend += o.reward;

      if (w > 0 && o.wasteTypes.isNotEmpty) {
        totalCo2 += CarbonCalculator.savedKgCo2Multi(o.wasteTypes, w);
        final primary = o.wasteTypes.first;
        kgByType[primary] = (kgByType[primary] ?? 0) + w;
      }

      if (o.supplierName != null) {
        supplierSpend[o.supplierName!] =
            (supplierSpend[o.supplierName!] ?? 0) + o.reward;
      }

      final dt = o.completedAt ?? o.createdAt;
      final key = '${dt.year}-${dt.month}';
      final existing = byMonth[key];
      byMonth[key] = MonthlyTotal(
        year: dt.year,
        month: dt.month,
        weightKg: (existing?.weightKg ?? 0) + w,
        spendJd: (existing?.spendJd ?? 0) + o.reward,
      );
    }

    final now = DateTime.now();
    final monthly = <MonthlyTotal>[];
    for (var i = 5; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i, 1);
      final key = '${dt.year}-${dt.month}';
      monthly.add(byMonth[key] ??
          MonthlyTotal(year: dt.year, month: dt.month, weightKg: 0, spendJd: 0));
    }

    final topSuppliers = supplierSpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AnalyticsSummary(
      totalKg: totalKg,
      totalSpendJd: totalSpend,
      totalCo2Kg: totalCo2,
      totalShipments: _completed.length,
      kgByType: kgByType,
      monthly: monthly,
      topSuppliers: topSuppliers.take(5).toList(),
    );
  }
}
