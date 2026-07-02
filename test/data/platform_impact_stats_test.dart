import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/utils/platform_impact_stats.dart';

void main() {
  Order makeOrder({
    required String id,
    OrderStatus status = OrderStatus.completed,
    double? weightKg = 10.0,
    List<WasteType> wasteTypes = const [WasteType.plastic],
  }) =>
      Order(
        id: id,
        type: OrderType.pickup,
        wasteTypes: wasteTypes,
        pickupAddress: 'عمّان',
        dropoffAddress: 'المستودع',
        status: status,
        reward: 5,
        createdAt: DateTime(2026, 6, 1),
        completedAt: status == OrderStatus.completed ? DateTime(2026, 6, 2) : null,
        weightKg: weightKg,
      );

  group('PlatformImpactStats.fromOrders', () {
    test('empty order list yields all-zero stats', () {
      final stats = PlatformImpactStats.fromOrders([]);
      expect(stats.totalOrders, 0);
      expect(stats.totalWeightKg, 0);
      expect(stats.co2SavedKg, 0);
    });

    test('counts only completed orders', () {
      final orders = [
        makeOrder(id: 'A', status: OrderStatus.completed),
        makeOrder(id: 'B', status: OrderStatus.inTransit, weightKg: null),
        makeOrder(id: 'C', status: OrderStatus.cancelled),
      ];
      final stats = PlatformImpactStats.fromOrders(orders);
      expect(stats.totalOrders, 1);
    });

    test('sums weight across all completed orders', () {
      final orders = [
        makeOrder(id: 'A', weightKg: 20),
        makeOrder(id: 'B', weightKg: 30),
      ];
      final stats = PlatformImpactStats.fromOrders(orders);
      expect(stats.totalWeightKg, 50.0);
      expect(stats.totalOrders, 2);
    });

    test('sums CO2/water/energy impact per-order using actual weight', () {
      final orders = [
        makeOrder(id: 'A', wasteTypes: const [WasteType.metal], weightKg: 10),
        makeOrder(id: 'B', wasteTypes: const [WasteType.glass], weightKg: 10),
      ];
      final stats = PlatformImpactStats.fromOrders(orders);
      // metal: 10*4.5=45, glass: 10*0.3=3 -> 48 total.
      expect(stats.co2SavedKg, closeTo(48.0, 0.001));
    });

    test('completed order with no weight counts toward totalOrders but contributes no impact', () {
      final orders = [makeOrder(id: 'A', weightKg: null)];
      final stats = PlatformImpactStats.fromOrders(orders);
      expect(stats.totalOrders, 1);
      expect(stats.totalWeightKg, 0);
      expect(stats.co2SavedKg, 0);
    });

    test('completed order with empty waste types contributes no impact', () {
      final orders = [makeOrder(id: 'A', wasteTypes: const [], weightKg: 15)];
      final stats = PlatformImpactStats.fromOrders(orders);
      expect(stats.totalOrders, 1);
      expect(stats.co2SavedKg, 0);
    });
  });
}
