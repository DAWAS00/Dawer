import 'dart:math';

class ProximityService {
  static const double pickupRadiusMeters = 200.0;
  static const double dropoffRadiusMeters = 200.0;
  static const double ghostTimeoutMinutes = 15.0;
  static const double arrivalResponseMinutes = 5.0;

  static double distanceMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371000.0;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final dPhi = (lat2 - lat1) * pi / 180;
    final dLambda = (lng2 - lng1) * pi / 180;
    final a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static bool isWithinPickupGeofence(
    double driverLat,
    double driverLng,
    double targetLat,
    double targetLng,
  ) =>
      distanceMeters(driverLat, driverLng, targetLat, targetLng) <=
      pickupRadiusMeters;

  static bool isWithinDropoffGeofence(
    double driverLat,
    double driverLng,
    double targetLat,
    double targetLng,
  ) =>
      distanceMeters(driverLat, driverLng, targetLat, targetLng) <=
      dropoffRadiusMeters;

  /// Minimum plausible travel seconds at 30 km/h. Used to detect impossibly
  /// fast completions (time-anomaly fraud signal).
  static int minimumTravelSeconds(double distanceKm) =>
      (distanceKm / 30.0 * 3600).round();
}
