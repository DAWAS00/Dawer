import 'dart:async';
import '../../domain/services/i_proximity_service.dart';

// ── MockProximityService ──────────────────────────────────────────────────────
//
// Controllable fake GPS for unit tests and UI development.
// Use [simulatePosition] to push arbitrary coordinates without device GPS.
//
// Example:
//   final svc = MockProximityService();
//   svc.simulatePosition(24.6877, 46.7219); // near Riyadh pickup

class MockProximityService implements IProximityService {
  final _controller = StreamController<LatLng>.broadcast();

  @override
  Stream<LatLng> get positions => _controller.stream;

  @override
  void simulatePosition(double lat, double lng) {
    if (!_controller.isClosed) {
      _controller.add((lat: lat, lng: lng));
    }
  }

  @override
  void dispose() => _controller.close();
}
