import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../../../../data/models/order.dart';
import '../../../../../domain/entities/rider_proximity_state.dart';
import '../../../../../domain/services/i_notification_service.dart';
import '../../../../../domain/services/i_proximity_service.dart';

// ── RiderProximityViewModel ───────────────────────────────────────────────────
//
// Tracks whether the rider is near the pickup or drop-off point for a single
// active [Order]. Drives the proximity banner, 10-minute wait timer, and the
// chat-unlock gate.
//
// Lifecycle:
//   1. Create with an [Order] and inject [IProximityService].
//   2. Subscribe: [proximityState] emits [NearPickup] / [NearDropoff].
//   3. Call [dispose] when the order is complete or the view is destroyed.
//
// Backend extension (future):
//   • Replace [MockProximityService] with [GeolocatorProximityService].
//   • Replace [MockNotificationService] with an FCM-based implementation.

const Duration _kTimerTick = Duration(seconds: 1);

class RiderProximityViewModel extends ChangeNotifier {
  final Order order;
  final IProximityService _proximityService;
  final INotificationService _notificationService;

  RiderProximityViewModel({
    required this.order,
    required IProximityService proximityService,
    required INotificationService notificationService,
  })  : _proximityService = proximityService,
        _notificationService = notificationService {
    _sub = _proximityService.positions.listen(_onPosition);
  }

  // ── State ──────────────────────────────────────────────────────────────────

  RiderProximityState _state = const ProximityIdle();
  RiderProximityState get proximityState => _state;

  /// True when the rider is near pickup OR near drop-off.
  /// Unlocks the in-order chat button.
  bool get isChatEnabled =>
      _state is NearPickup || _state is NearDropoff;

  /// Convenience cast — non-null when state is [NearPickup].
  NearPickup? get nearPickup =>
      _state is NearPickup ? _state as NearPickup : null;

  // ── Internals ──────────────────────────────────────────────────────────────

  StreamSubscription<LatLng>? _sub;
  Timer? _tickTimer;
  bool _pickupNotified = false;
  bool _dropoffNotified = false;
  bool _disposed = false;

  void _onPosition(LatLng pos) {
    if (_disposed) return;

    final distToPickup = _haversineMeters(
      pos.lat, pos.lng,
      order.pickupLat ?? 0, order.pickupLng ?? 0,
    );

    final distToDropoff = (order.dropoffLat != null && order.dropoffLng != null)
        ? _haversineMeters(
            pos.lat, pos.lng,
            order.dropoffLat!, order.dropoffLng!,
          )
        : double.infinity;

    final isInTransit = order.status == OrderStatus.inTransit;

    if (!isInTransit && distToPickup <= kNearThresholdMeters) {
      _handleNearPickup();
    } else if (isInTransit && distToDropoff <= kNearThresholdMeters) {
      _handleNearDropoff();
    } else {
      _resetToIdle();
    }
  }

  void _handleNearPickup() {
    if (_state is! NearPickup) {
      _state = NearPickup(
        arrivedAt: DateTime.now(),
        elapsed: Duration.zero,
      );
      _startTick();
      notifyListeners();
    }
    if (!_pickupNotified) {
      _pickupNotified = true;
      _notificationService.notifyProximity(
        orderId: order.id,
        kind: ProximityNotificationKind.riderNearPickup,
      );
    }
  }

  void _handleNearDropoff() {
    if (_state is! NearDropoff) {
      _state = NearDropoff(arrivedAt: DateTime.now());
      _stopTick();
      notifyListeners();
    }
    if (!_dropoffNotified) {
      _dropoffNotified = true;
      _notificationService.notifyProximity(
        orderId: order.id,
        kind: ProximityNotificationKind.riderNearDropoff,
      );
    }
  }

  void _resetToIdle() {
    if (_state is! ProximityIdle) {
      _state = const ProximityIdle();
      _stopTick();
      notifyListeners();
    }
  }

  // ── 10-minute tick timer ───────────────────────────────────────────────────

  void _startTick() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(_kTimerTick, (_) {
      if (_disposed) return;
      final current = _state;
      if (current is NearPickup) {
        _state = current.tick(_kTimerTick);
        notifyListeners();
      }
    });
  }

  void _stopTick() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  // ── Haversine distance (pure Dart, no package needed) ─────────────────────

  static double _haversineMeters(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    const r = 6371000.0; // Earth radius in metres
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * math.pi / 180;

  // ── Simulation helpers (dev / QA use) ─────────────────────────────────────

  /// Jump the simulated position to the order's pickup coordinates.
  /// Useful in debug builds and widget tests.
  void simulateAtPickup() {
    _proximityService.simulatePosition(
      order.pickupLat ?? 0,
      order.pickupLng ?? 0,
    );
  }

  /// Jump the simulated position to the order's drop-off coordinates.
  void simulateAtDropoff() {
    _proximityService.simulatePosition(
      order.dropoffLat ?? 0,
      order.dropoffLng ?? 0,
    );
  }

  /// Place rider far from all points — resets to idle.
  /// Uses (90.0, 0.0) — North Pole — guaranteed >10 000 km from Jordan.
  /// Avoids the (0, 0) / null-coord ambiguity where simulateAtPickup and
  /// simulateFarAway would push identical coordinates for orders with no GPS.
  void simulateFarAway() {
    _proximityService.simulatePosition(90.0, 0.0);
  }

  @override
  void dispose() {
    _disposed = true;
    _stopTick();
    _sub?.cancel();
    _proximityService.dispose();
    super.dispose();
  }
}
