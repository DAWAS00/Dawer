import '../../core/result/result.dart';
import '../../domain/entities/earnings/chart_data_point.dart';
import '../../domain/entities/earnings/earnings_summary.dart';
import '../../domain/entities/earnings/trip_earning.dart';
import '../../domain/repositories/i_earnings_repository.dart';

class MockEarningsRepository implements IEarningsRepository {
  @override
  Future<AppResult<EarningsSummary>> getEarningsSummary({
    required String riderId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();

    final earningsTrend = List.generate(7, (i) {
      return ChartDataPoint(
        date: now.subtract(Duration(days: 6 - i)),
        value: 20.0 + (i * 5.0) + (i % 2 == 0 ? 5.0 : -3.0),
      );
    });

    final distanceTrend = List.generate(7, (i) {
      return ChartDataPoint(
        date: now.subtract(Duration(days: 6 - i)),
        value: 10.0 + (i * 2.0) + (i % 3 == 0 ? 2.0 : -1.0),
      );
    });

    final recentTrips = [
      TripEarning(
        orderId: 'ORD-001',
        date: now.subtract(const Duration(hours: 2)),
        amount: 8.5,
        distanceKm: 12.4,
        pickupAddress: 'جبل عمان، عمان',
        dropoffAddress: 'الصويفية، عمان',
      ),
      TripEarning(
        orderId: 'ORD-002',
        date: now.subtract(const Duration(hours: 5)),
        amount: 6.0,
        distanceKm: 8.2,
        pickupAddress: 'الدوار السابع، عمان',
        dropoffAddress: 'الجبيهة، عمان',
      ),
      TripEarning(
        orderId: 'ORD-003',
        date: now.subtract(const Duration(days: 1, hours: 1)),
        amount: 11.0,
        distanceKm: 15.6,
        pickupAddress: 'الزرقاء الجديدة، الزرقاء',
        dropoffAddress: 'ماركا الشمالية، عمان',
      ),
    ];

    return Success(
      EarningsSummary(
        totalEarnings: 148.75,
        totalDistance: 215.3,
        totalTrips: 18,
        earningsTrend: earningsTrend,
        distanceTrend: distanceTrend,
        recentTrips: recentTrips,
      ),
    );
  }
}
