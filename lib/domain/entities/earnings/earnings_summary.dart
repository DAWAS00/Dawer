import 'chart_data_point.dart';
import 'trip_earning.dart';

class EarningsSummary {
  final double totalEarnings;
  final double totalDistance;
  final int totalTrips;
  final List<ChartDataPoint> earningsTrend;
  final List<ChartDataPoint> distanceTrend;
  final List<TripEarning> recentTrips;

  const EarningsSummary({
    required this.totalEarnings,
    required this.totalDistance,
    required this.totalTrips,
    required this.earningsTrend,
    required this.distanceTrend,
    required this.recentTrips,
  });

  /// Example of OOP encapsulation for business logic
  double get averageEarningsPerTrip =>
      totalTrips > 0 ? totalEarnings / totalTrips : 0.0;

  double get averageEarningsPerKm =>
      totalDistance > 0 ? totalEarnings / totalDistance : 0.0;
}
