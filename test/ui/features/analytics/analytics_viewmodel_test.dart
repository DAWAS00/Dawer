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
    List<WasteType>? wasteTypes,
    double weightKg = 10.0,
    double? distanceKm,
    DateTime? acceptedAt,
    DateTime? arrivedAtPickupAt,
    DateTime? arrivedAtDropoffAt,
    OrderStatus status = OrderStatus.completed,
  }) =>
      Order(
        id: 'ORD-${createdAt.millisecondsSinceEpoch}-${reward.hashCode}',
        type: OrderType.pickup,
        wasteTypes: wasteTypes ?? [wasteType],
        pickupAddress: 'عمّان',
        dropoffAddress: 'المستودع',
        status: status,
        reward: reward,
        createdAt: createdAt,
        acceptedAt: acceptedAt,
        arrivedAtPickupAt: arrivedAtPickupAt,
        arrivedAtDropoffAt: arrivedAtDropoffAt,
        completedAt: completedAt ?? createdAt.add(const Duration(hours: 2)),
        weightKg: weightKg,
        distanceKm: distanceKm,
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

  group('AnalyticsViewModel daily report (today snapshot)', () {
    test('todaysCompletedOrders only includes orders completed today, ignoring period', () {
      final now = DateTime(2026, 6, 28, 18);
      final orders = [
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 28, 8), weightKg: 20),
        makeOrder(reward: 20, createdAt: DateTime(2026, 6, 27, 8), weightKg: 30),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      // Even with allTime selected, "today" stats must stay pinned to today.
      vm.setPeriod(AnalyticsPeriod.allTime);
      expect(vm.todaysCompletedOrders.length, 1);
      expect(vm.todaysOrderCount, 1);
      expect(vm.todaysWeightKg, 20.0);
      expect(vm.todaysEarnings, 10.0);
    });

    test('todaysCompletedOrders excludes non-completed orders', () {
      final now = DateTime(2026, 6, 28, 18);
      final orders = [
        makeOrder(
          reward: 10,
          createdAt: DateTime(2026, 6, 28, 8),
          completedAt: null,
          status: OrderStatus.arrivedAtDropoff,
        ),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      expect(vm.todaysOrderCount, 0);
      expect(vm.todaysWeightKg, 0);
    });

    test('todaysEcoImpact sums per-order impact from actual weight', () {
      final now = DateTime(2026, 6, 28, 18);
      final orders = [
        makeOrder(
          reward: 10,
          createdAt: DateTime(2026, 6, 28, 8),
          wasteType: WasteType.metal,
          weightKg: 10,
        ),
        makeOrder(
          reward: 10,
          createdAt: DateTime(2026, 6, 28, 9),
          wasteType: WasteType.glass,
          weightKg: 10,
        ),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      // metal: 10*4.5=45, glass: 10*0.3=3 -> 48 total.
      expect(vm.todaysEcoImpact.co2SavedKg, closeTo(48.0, 0.001));
    });

    test('todaysEcoImpact ignores orders with no weight or no waste types', () {
      final now = DateTime(2026, 6, 28, 18);
      final orders = [
        makeOrder(
          reward: 10,
          createdAt: DateTime(2026, 6, 28, 8),
          weightKg: 0,
        ),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      expect(vm.todaysEcoImpact.co2SavedKg, 0);
    });

    test('todaysCompletedOrders is empty when no orders completed today', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 20)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      expect(vm.todaysOrderCount, 0);
      expect(vm.todaysEcoImpact.co2SavedKg, 0);
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

  group('AnalyticsViewModel.currentStreak', () {
    test('0 when no completed orders', () {
      final vm =
          AnalyticsViewModel(orders: const [], nowOverride: DateTime(2026, 6, 28));
      expect(vm.currentStreak, 0);
    });

    test('counts consecutive days ending today', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 26)),
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 27)),
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 28)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      expect(vm.currentStreak, 3);
    });

    test('grace: today silent counts from yesterday', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 26)),
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 27)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      expect(vm.currentStreak, 2);
    });

    test('gap breaks the streak', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 28)),
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 25)), // gap
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      expect(vm.currentStreak, 1);
    });

    test('longestStreak finds the best historical run', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        // 4-day run in the past
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 10)),
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 11)),
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 12)),
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 13)),
        // 2-day run now
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 27)),
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 28)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      expect(vm.longestStreak, 4);
    });

    test('activityByDay returns counts for recent days only', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 28)),
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 28)),
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 27)),
        makeOrder(reward: 1, createdAt: DateTime(2026, 3, 1)), // out of 35-day window
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      final counts = vm.activityByDay(35);
      final today = DateTime(2026, 6, 28);
      expect(counts[today], 2);
      expect(counts[DateTime(2026, 6, 27)], 1);
      expect(counts[DateTime(2026, 3, 1)], isNull);
    });
  });

  group('AnalyticsViewModel.cycleTime', () {
    test('all null when lifecycle timestamps missing', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 1, createdAt: DateTime(2026, 6, 25)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      final c = vm.cycleTime;
      expect(c.avgAcceptMinutes, isNull);
      expect(c.avgTotalMinutes, isNotNull); // createdAt + completedAt are set
    });

    test('computes per-stage averages from synthetic timestamps', () {
      final now = DateTime(2026, 6, 28);
      final base = DateTime(2026, 6, 25, 8, 0);
      final orders = [
        makeOrder(
          reward: 1,
          createdAt: base,
          acceptedAt: base.add(const Duration(minutes: 10)),
          arrivedAtPickupAt: base.add(const Duration(minutes: 40)),
          arrivedAtDropoffAt: base.add(const Duration(minutes: 100)),
          completedAt: base.add(const Duration(minutes: 120)),
        ),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      final c = vm.cycleTime;
      expect(c.avgAcceptMinutes, 10);
      expect(c.avgPickupMinutes, 30);
      expect(c.avgTransitMinutes, 60);
      expect(c.avgDropoffMinutes, 20);
      expect(c.avgTotalMinutes, 120);
    });

    test('skips orders missing a needed timestamp', () {
      final now = DateTime(2026, 6, 28);
      final base = DateTime(2026, 6, 25, 8, 0);
      final orders = [
        makeOrder(
          reward: 1,
          createdAt: base,
          acceptedAt: base.add(const Duration(minutes: 10)),
          arrivedAtPickupAt: null, // missing
          arrivedAtDropoffAt: null,
          completedAt: base.add(const Duration(minutes: 120)),
        ),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      final c = vm.cycleTime;
      expect(c.avgAcceptMinutes, 10);
      expect(c.avgTransitMinutes, isNull); // no samples
      expect(c.avgTotalMinutes, 120);
    });

    test('isNotEmpty flags null total', () {
      final vm =
          AnalyticsViewModel(orders: const [], nowOverride: DateTime(2026, 6, 28));
      expect(vm.cycleTime.isEmpty, isTrue);
    });
  });

  group('AnalyticsViewModel.wasteProfitability', () {
    test('reward per kg sorted desc', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(
            reward: 60, wasteType: WasteType.plastic, weightKg: 10,
            createdAt: DateTime(2026, 6, 25)), // 6.0 / kg
        makeOrder(
            reward: 20, wasteType: WasteType.paper, weightKg: 10,
            createdAt: DateTime(2026, 6, 25)), // 2.0 / kg
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      final p = vm.wasteProfitability;
      expect(p.first.type, WasteType.plastic);
      expect(p.first.rewardPerKg, closeTo(6.0, 0.001));
      expect(p.last.type, WasteType.paper);
      expect(p.last.rewardPerKg, closeTo(2.0, 0.001));
    });

    test('multi-type order splits reward evenly', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(
          reward: 40,
          weightKg: 10,
          wasteTypes: const [WasteType.plastic, WasteType.paper],
          createdAt: DateTime(2026, 6, 25),
        ),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      final p = vm.wasteProfitability;
      // 40 split into 20/20 across 2 types; each divides by 10kg => 2.0/kg.
      expect(p.length, 2);
      for (final item in p) {
        expect(item.rewardPerKg, closeTo(2.0, 0.001));
      }
    });

    test('empty when no weighted orders', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 10, weightKg: 0, createdAt: DateTime(2026, 6, 25)),
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.wasteProfitability, isEmpty);
    });
  });

  group('AnalyticsViewModel.earningsPerKm', () {
    test('null when no distance data', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(reward: 10, createdAt: DateTime(2026, 6, 25)), // no distance
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.earningsPerKm, isNull);
      expect(vm.bestJobsByEfficiency, isEmpty);
    });

    test('mean of reward/distance across orders', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(
            reward: 10, distanceKm: 5, createdAt: DateTime(2026, 6, 25)), // 2.0/km
        makeOrder(
            reward: 30, distanceKm: 10, createdAt: DateTime(2026, 6, 26)), // 3.0/km
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      expect(vm.earningsPerKm, closeTo(2.5, 0.001));
    });

    test('bestJobsByEfficiency returns top 3 sorted desc', () {
      final now = DateTime(2026, 6, 28);
      final orders = [
        makeOrder(
            reward: 10, distanceKm: 10, createdAt: DateTime(2026, 6, 25)), // 1.0
        makeOrder(
            reward: 30, distanceKm: 5, createdAt: DateTime(2026, 6, 26)), // 6.0
        makeOrder(
            reward: 20, distanceKm: 4, createdAt: DateTime(2026, 6, 24)), // 5.0
        makeOrder(
            reward: 5, distanceKm: 5, createdAt: DateTime(2026, 6, 23)), // 1.0
      ];
      final vm = AnalyticsViewModel(orders: orders, nowOverride: now);
      vm.setPeriod(AnalyticsPeriod.week);
      final best = vm.bestJobsByEfficiency;
      expect(best.length, 3);
      expect(best.first.jodPerKm, closeTo(6.0, 0.001));
      expect(best[1].jodPerKm, closeTo(5.0, 0.001));
      expect(best.last.jodPerKm, closeTo(1.0, 0.001));
    });
  });
}
