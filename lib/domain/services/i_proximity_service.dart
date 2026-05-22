// ── IProximityService ─────────────────────────────────────────────────────────
//
// Abstracts the GPS position stream so that:
//   • Real app  → [GeolocatorProximityService] using the `geolocator` package.
//   • Unit tests → [MockProximityService] with a controllable stream.
//
// This keeps [RiderProximityViewModel] 100% testable without device permissions.

/// A single lat/lng position snapshot.
typedef LatLng = ({double lat, double lng});

abstract interface class IProximityService {
  /// Continuous stream of device position updates.
  Stream<LatLng> get positions;

  /// Push an instant one-shot position — used by tests and manual simulation.
  void simulatePosition(double lat, double lng);

  void dispose();
}
