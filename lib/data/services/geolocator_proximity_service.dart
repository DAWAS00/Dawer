import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../domain/services/i_proximity_service.dart';

// ── GeolocatorProximityService ────────────────────────────────────────────────
//
// Production GPS stream using the `geolocator` package.
// Swap in via DI when permissions are granted and backend is live.
//
// Backend extension: call `_publisher.start(orderId)` in
// [RiderProximityViewModel] once near-pickup is confirmed.

class GeolocatorProximityService implements IProximityService {
  StreamSubscription<Position>? _sub;
  final _controller = StreamController<LatLng>.broadcast();

  GeolocatorProximityService() {
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((p) {
      if (!_controller.isClosed) {
        _controller.add((lat: p.latitude, lng: p.longitude));
      }
    });
  }

  @override
  Stream<LatLng> get positions => _controller.stream;

  @override
  void simulatePosition(double lat, double lng) {
    if (!_controller.isClosed) {
      _controller.add((lat: lat, lng: lng));
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
