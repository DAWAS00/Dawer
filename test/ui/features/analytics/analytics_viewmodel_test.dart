import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/ui/features/analytics/models/analytics_period.dart';
import 'package:dwaar/ui/features/analytics/analytics_viewmodel.dart';
import 'package:dwaar/data/models/order/order.dart';

void main() {
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

  group('AnalyticsViewModel deltas', () {
    test('deltaEarningsPct positive when current > previous', () {
      // Week ending 6/28. Previous week ends at range.start = 6/21.
      // Order A: this week (6/25), reward 30. Order B: prev week (6/15), reward 10.
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 30, createdAt: DateTime(2026, 6, 25)),
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 15)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.totalEarnings, 30.0);
      expect(vm.deltaEarningsPct, closeTo(200.0, 0.01));
    });

    test('deltaEarningsPct null when previous period is empty', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 30, createdAt: DateTime(2026, 6, 25)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.deltaEarningsPct, isNull);
    });

    test('deltaOrdersPct negative when current < previous', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 25)), // this week: 1
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 16)), // prev: 2
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 15)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.orderCount, 1);
      expect(vm.deltaOrdersPct, closeTo(-50.0, 0.01));
    });
  });

  group('AnalyticsViewModel.dailySeries', () {
    test('returns one point per day across the week range', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 25)),
        makeOrder(reward: 20, createdAt: DateTime(2026, 6, 26)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      final series = vm.dailySeries(HeroMetric.earnings);
      expect(series.length, greaterThanOrEqualTo(7));
      // Points sorted oldest-first
      for (var i = 1; i < series.length; i++) {
        expect(series[i].day.isAfter(series[i - 1].day) ||
            series[i].day.isAtSameMomentAs(series[i - 1].day), isTrue);
      }
    });

    test('buckets earnings by day', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 25)),
        makeOrder(reward: 5, createdAt: DateTime(2026, 6, 25)),
        makeOrder(reward: 20, createdAt: DateTime(2026, 6, 26)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      final series = vm.dailySeries(HeroMetric.earnings);
      final day25 = series.firstWhere(
          (p) => p.day.day == 25 && p.day.month == 6);
      final day26 = series.firstWhere(
          (p) => p.day.day == 26 && p.day.month == 6);
      expect(day25.value, 15.0);
      expect(day26.value, 20.0);
    });

    test('weight series sums weightKg', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 1, weightKg: 30, createdAt: DateTime(2026, 6, 25)),
        makeOrder(reward: 1, weightKg: 50, createdAt: DateTime(2026, 6, 25)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      final series = vm.dailySeries(HeroMetric.weight);
      final day25 = series.firstWhere(
          (p) => p.day.day == 25 && p.day.month == 6);
      expect(day25.value, 80.0);
    });
  });

  group('AnalyticsViewModel.wasteBreakdown', () {
    test('computes share per waste type sorted desc', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(
            reward: 1, wasteType: WasteType.plastic, weightKg: 60,
            createdAt: DateTime(2026, 6, 25)),
        makeOrder(
            reward: 1, wasteType: WasteType.paper, weightKg: 40,
            createdAt: DateTime(2026, 6, 25)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      final b = vm.wasteBreakdown;
      expect(b.length, 2);
      expect(b.first.type, WasteType.plastic);
      expect(b.first.share, closeTo(0.6, 0.001));
      expect(b.last.type, WasteType.paper);
      expect(b.last.share, closeTo(0.4, 0.001));
    });

    test('empty when no weighted orders', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(
            reward: 1, wasteType: WasteType.plastic, weightKg: 0,
            createdAt: DateTime(2026, 6, 25)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.wasteBreakdown, isEmpty);
    });

    test('avgRewardPerOrder is total/count', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 25)),
        makeOrder(reward: 30, createdAt: DateTime(2026, 6, 26)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.avgRewardPerOrder, 20.0);
    });

    test('avgRewardPerOrder is 0 when no orders', () {
      final now = DateTime(2026, 6, 28);
      final vm = AnalyticsViewModel(orders: const [], nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.avgRewardPerOrder, 0);
    });
  });
}
