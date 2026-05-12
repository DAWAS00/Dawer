import 'package:flutter/foundation.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/reward_transaction.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../../../../domain/services/carbon_calculator.dart';

class EarningsSummary {
  final double totalJd;
  final int totalPoints;
  final double totalCo2Kg;
  final int completedTrips;
  final Map<WasteType, double> jdByType;

  const EarningsSummary({
    required this.totalJd,
    required this.totalPoints,
    required this.totalCo2Kg,
    required this.completedTrips,
    required this.jdByType,
  });
}

class DriverEarningsViewModel extends ChangeNotifier {
  final AppOrderStore _store;

  DriverEarningsViewModel(this._store) {
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => notifyListeners();

  List<Order> get _history => _store.driverHistory;

  EarningsSummary get summary {
    double totalJd = 0;
    int totalPoints = 0;
    double totalCo2 = 0;
    int trips = 0;
    final Map<WasteType, double> byType = {};

    for (final o in _history) {
      if (o.status != OrderStatus.completed) continue;
      trips++;
      totalJd += o.reward;

      // Points: 1 JD ≈ 10 points (same ratio RewardService uses for base)
      totalPoints += (o.reward * 10).round();

      // CO₂
      final w = o.weightKg ?? o.estimatedWeightKg;
      if (w != null && w > 0 && o.wasteTypes.isNotEmpty) {
        final co2 = CarbonCalculator.savedKgCo2Multi(o.wasteTypes, w);
        totalCo2 += co2;
        final primary = o.wasteTypes.first;
        byType[primary] = (byType[primary] ?? 0) + o.reward;
      }
    }

    return EarningsSummary(
      totalJd: totalJd,
      totalPoints: totalPoints,
      totalCo2Kg: totalCo2,
      completedTrips: trips,
      jdByType: byType,
    );
  }

  /// Returns up to [count] recent completed orders as reward transactions.
  List<RewardTransaction> recentTransactions({int count = 20}) {
    final completed = _history
        .where((o) => o.status == OrderStatus.completed)
        .toList()
      ..sort((a, b) =>
          (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));

    return completed.take(count).map((o) {
      final typeLabel = o.wasteTypes.isNotEmpty
          ? o.wasteTypes.first.label
          : 'طلب';
      return RewardTransaction(
        id: o.id,
        type: RewardTransactionType.earned,
        points: (o.reward * 10).round(),
        description: 'توصيل $typeLabel',
        createdAt: o.completedAt ?? o.createdAt,
        linkedOrderId: o.id,
      );
    }).toList();
  }
}
