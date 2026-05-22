import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/domain/entities/earnings/earnings_summary.dart';

void main() {
  group('EarningsSummary', () {
    test('averageEarningsPerTrip calculates correctly', () {
      const summary = EarningsSummary(
        totalEarnings: 100.0,
        totalDistance: 50.0,
        totalTrips: 10,
        earningsTrend: [],
        distanceTrend: [],
        recentTrips: [],
      );

      expect(summary.averageEarningsPerTrip, 10.0);
    });

    test('averageEarningsPerTrip returns 0 if totalTrips is 0', () {
      const summary = EarningsSummary(
        totalEarnings: 100.0,
        totalDistance: 50.0,
        totalTrips: 0,
        earningsTrend: [],
        distanceTrend: [],
        recentTrips: [],
      );

      expect(summary.averageEarningsPerTrip, 0.0);
    });

    test('averageEarningsPerKm calculates correctly', () {
      const summary = EarningsSummary(
        totalEarnings: 100.0,
        totalDistance: 40.0,
        totalTrips: 10,
        earningsTrend: [],
        distanceTrend: [],
        recentTrips: [],
      );

      expect(summary.averageEarningsPerKm, 2.5);
    });
  });
}
