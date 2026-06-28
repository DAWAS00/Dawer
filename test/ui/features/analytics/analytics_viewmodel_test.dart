import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/ui/features/analytics/models/analytics_period.dart';
import 'package:dwaar/ui/features/analytics/analytics_viewmodel.dart';
import 'package:dwaar/data/models/order/order.dart';

void main() {
  group('AnalyticsPeriod.dateRange', () {
    test('week range spans exactly 7 days', () {
      final range = AnalyticsPeriod.week.dateRange(now: DateTime(2026, 6, 28));
      expect(range.end.difference(range.start).inDays, 7);
    });

    test('month range starts on first of month', () {
      final range = AnalyticsPeriod.month.dateRange(now: DateTime(2026, 6, 28));
      expect(range.start, DateTime(2026, 6, 1));
    });

    test('allTime range starts from epoch', () {
      final range = AnalyticsPeriod.allTime.dateRange(now: DateTime(2026, 6, 28));
      expect(range.start.year, 2000);
    });

    test('order falls within week range', () {
      final range = AnalyticsPeriod.week.dateRange(now: DateTime(2026, 6, 28));
      final orderDate = DateTime(2026, 6, 25);
      expect(range.contains(orderDate), isTrue);
    });

    test('order outside week range is excluded', () {
      final range = AnalyticsPeriod.week.dateRange(now: DateTime(2026, 6, 28));
      final orderDate = DateTime(2026, 6, 1);
      expect(range.contains(orderDate), isFalse);
    });
  });

  group('AnalyticsViewModel', () {
    Order makeOrder({
      required double reward,
      required DateTime createdAt,
      DateTime? completedAt,
      WasteType wasteType = WasteType.plastic,
      double weightKg = 10.0,
      OrderStatus status = OrderStatus.completed,
    }) =>
        Order(
          id: 'ORD-${createdAt.millisecondsSinceEpoch}',
          type: OrderType.pickup,
          wasteTypes: [wasteType],
          pickupAddress: 'عمّان',
          dropoffAddress: 'المستودع',
          status: status,
          reward: reward,
          createdAt: createdAt,
          completedAt: completedAt ?? createdAt.add(const Duration(hours: 2)),
          weightKg: weightKg,
        );

    test('filteredOrders returns only orders within week range', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 25)),
        makeOrder(reward: 20, createdAt: DateTime(2026, 6, 1)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.filteredOrders.length, 1);
      expect(vm.filteredOrders.first.reward, 10.0);
    });

    test('totalEarnings sums reward of filtered orders', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 15, createdAt: DateTime(2026, 6, 25)),
        makeOrder(reward: 25, createdAt: DateTime(2026, 6, 26)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.totalEarnings, 40.0);
    });

    test('totalWeightKg sums weightKg of filtered orders', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 25), weightKg: 30),
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 26), weightKg: 50),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.totalWeightKg, 80.0);
    });

    test('estimatedCo2Kg defaults to 1.5 * totalWeightKg', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 25), weightKg: 100),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.estimatedCo2Kg, closeTo(150.0, 0.01));
    });

    test('orderCount returns filtered order count', () {
      final now = DateTime(2026, 6, 28);
      final orders = List.generate(
        5,
        (i) => makeOrder(reward: 10, createdAt: DateTime(2026, 6, 22 + i)),
      );
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.orderCount, 5);
    });
  });
}
