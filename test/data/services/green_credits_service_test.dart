// test/data/services/green_credits_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/order/order.dart'
    show Order, OrderStatus, WasteType, OrderType;
import 'package:dwaar/data/services/green_credits_service.dart';

Order _makeOrder({
  List<WasteType> wasteTypes = const [WasteType.plastic],
  double? weightKg,
  double? estimatedWeightKg = 10.0,
  OrderStatus status = OrderStatus.completed,
  DateTime? completedAt,
}) => Order(
  id: 'test-${DateTime.now().microsecondsSinceEpoch}',
  status: status,
  type: OrderType.pickup,
  wasteTypes: wasteTypes,
  pickupAddress: 'شارع الجامعة، عمّان',
  dropoffAddress: 'شركة الخضراء للتدوير',
  reward: 0,
  weightKg: weightKg,
  estimatedWeightKg: estimatedWeightKg,
  createdAt:
      completedAt?.subtract(const Duration(hours: 2)) ??
      DateTime(2026, 1, 6, 10), // Monday
  completedAt: completedAt ?? DateTime(2026, 1, 6, 12),
  supplierName: 'مطعم الوطن',
);

void main() {
  const service = GreenCreditsService();

  group('GreenCreditsService.creditsForOrder', () {
    test(
      'base order with 10 kg plastic earns base + weight × 1.0 multiplier',
      () {
        final order = _makeOrder(
          wasteTypes: [WasteType.plastic],
          weightKg: 10.0,
        );
        // (10 base + 10 kg × 1.0 perKg) × 1.0 material × 1.0 streak = 20
        expect(service.creditsForOrder(order), equals(20));
      },
    );

    test(
      'uses highest material multiplier when multiple waste types present',
      () {
        final order = _makeOrder(
          wasteTypes: [WasteType.plastic, WasteType.electronics],
          weightKg: 10.0,
        );
        // electronics = 5×, plastic = 1× → highest is 5×
        // (10 + 10) × 5.0 = 100
        expect(service.creditsForOrder(order), equals(100));
      },
    );

    test('oil pickup earns 3× multiplier', () {
      final order = _makeOrder(wasteTypes: [WasteType.oil], weightKg: 0.0);
      // (10 + 0) × 3.0 × 1.0 = 30
      expect(service.creditsForOrder(order), equals(30));
    });

    test('electronics earns 5× multiplier', () {
      final order = _makeOrder(
        wasteTypes: [WasteType.electronics],
        weightKg: 0.0,
      );
      // (10 + 0) × 5.0 × 1.0 = 50
      expect(service.creditsForOrder(order), equals(50));
    });

    test('falls back to estimatedWeightKg when weightKg is null', () {
      final order = _makeOrder(
        wasteTypes: [WasteType.paper],
        weightKg: null,
        estimatedWeightKg: 20.0,
      );
      // (10 + 20) × 1.0 × 1.0 = 30
      expect(service.creditsForOrder(order), equals(30));
    });

    test('2-week streak applies 1.25× streak bonus', () {
      final order = _makeOrder(wasteTypes: [WasteType.plastic], weightKg: 10.0);
      // (10 + 10) × 1.0 material × 1.25 streak = 25
      expect(service.creditsForOrder(order, weekStreak: 2), equals(25));
    });

    test('4-week streak applies 1.5× streak bonus', () {
      final order = _makeOrder(wasteTypes: [WasteType.plastic], weightKg: 10.0);
      // (10 + 10) × 1.0 × 1.5 = 30
      expect(service.creditsForOrder(order, weekStreak: 4), equals(30));
    });

    test('8-week streak applies 2.0× streak bonus', () {
      final order = _makeOrder(wasteTypes: [WasteType.plastic], weightKg: 10.0);
      // (10 + 10) × 1.0 × 2.0 = 40
      expect(service.creditsForOrder(order, weekStreak: 8), equals(40));
    });

    test(
      'zero weight with empty wasteTypes returns base credits (clamped to 1 minimum)',
      () {
        final order = _makeOrder(
          wasteTypes: [],
          weightKg: 0.0,
          estimatedWeightKg: 0.0,
        );
        // (10 + 0) × 1.0 × 1.0 = 10
        expect(service.creditsForOrder(order), equals(10));
      },
    );

    test('result is always at least 1', () {
      final order = _makeOrder(
        wasteTypes: [WasteType.organic],
        weightKg: 0.0,
        estimatedWeightKg: 0.0,
      );
      expect(service.creditsForOrder(order), greaterThanOrEqualTo(1));
    });
  });

  group('GreenCreditsService.weekStreakFrom', () {
    // Reference date: we use completedAt to determine the week
    // Week 1 = 2026-01-05 (Mon) to 2026-01-11 (Sun)
    // Week 2 = 2026-01-12 (Mon) to 2026-01-18 (Sun)
    // Week 3 = 2026-01-19 (Mon) to 2026-01-25 (Sun)

    test('returns 0 for empty order list', () {
      expect(GreenCreditsService.weekStreakFrom([]), equals(0));
    });

    test('returns 0 when no completed orders', () {
      final orders = [
        _makeOrder(status: OrderStatus.pending, completedAt: null),
      ];
      expect(GreenCreditsService.weekStreakFrom(orders), equals(0));
    });

    test('returns 1 for a single completed order this week', () {
      // "now" is determined by the latest completedAt in the list.
      final orders = [
        _makeOrder(completedAt: DateTime(2026, 1, 6, 10)), // Week 1
      ];
      expect(GreenCreditsService.weekStreakFrom(orders), equals(1));
    });

    test('returns 2 for orders in two consecutive weeks', () {
      final orders = [
        _makeOrder(completedAt: DateTime(2026, 1, 6, 10)), // Week 1
        _makeOrder(completedAt: DateTime(2026, 1, 13, 10)), // Week 2
      ];
      expect(GreenCreditsService.weekStreakFrom(orders), equals(2));
    });

    test('returns 3 for three consecutive weeks', () {
      final orders = [
        _makeOrder(completedAt: DateTime(2026, 1, 6, 10)), // Week 1
        _makeOrder(completedAt: DateTime(2026, 1, 13, 10)), // Week 2
        _makeOrder(completedAt: DateTime(2026, 1, 20, 10)), // Week 3
      ];
      expect(GreenCreditsService.weekStreakFrom(orders), equals(3));
    });

    test('resets streak when a week is skipped', () {
      final orders = [
        _makeOrder(completedAt: DateTime(2026, 1, 6, 10)), // Week 1
        // Week 2 skipped
        _makeOrder(completedAt: DateTime(2026, 1, 20, 10)), // Week 3
      ];
      // Only week 3 is the "end" — week 2 is missing so streak = 1
      expect(GreenCreditsService.weekStreakFrom(orders), equals(1));
    });

    test('multiple orders in same week count as 1 week', () {
      final orders = [
        _makeOrder(completedAt: DateTime(2026, 1, 6, 10)), // Week 1, Monday
        _makeOrder(completedAt: DateTime(2026, 1, 8, 14)), // Week 1, Wednesday
        _makeOrder(completedAt: DateTime(2026, 1, 13, 10)), // Week 2
      ];
      expect(GreenCreditsService.weekStreakFrom(orders), equals(2));
    });
  });
}
