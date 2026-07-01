import '../models/order/order.dart';
import 'eco_impact_calculator.dart';

/// Aggregate environmental impact across every completed order on the
/// platform (not scoped to a single user) — used for the public "our
/// impact so far" section shown before login.
class PlatformImpactStats {
  const PlatformImpactStats({
    required this.totalOrders,
    required this.totalWeightKg,
    required this.co2SavedKg,
    required this.waterSavedLiters,
    required this.energySavedKwh,
  });

  final int totalOrders;
  final double totalWeightKg;
  final double co2SavedKg;
  final double waterSavedLiters;
  final double energySavedKwh;

  /// Computes totals from every completed order with a recorded weight.
  /// Orders missing weight or waste-type data are counted toward
  /// [totalOrders] but contribute no weight/impact.
  factory PlatformImpactStats.fromOrders(List<Order> orders) {
    final completed = orders.where((o) => o.status == OrderStatus.completed);

    var weight = 0.0;
    var co2 = 0.0;
    var water = 0.0;
    var energy = 0.0;
    var count = 0;

    for (final o in completed) {
      count++;
      final w = o.weightKg;
      if (w == null || w <= 0 || o.wasteTypes.isEmpty) continue;
      weight += w;
      final impact = EcoImpactCalculator.calculateForWeight(o.wasteTypes, w);
      co2 += impact.co2SavedKg;
      water += impact.waterSavedLiters;
      energy += impact.energySavedKwh;
    }

    return PlatformImpactStats(
      totalOrders: count,
      totalWeightKg: weight,
      co2SavedKg: co2,
      waterSavedLiters: water,
      energySavedKwh: energy,
    );
  }
}
