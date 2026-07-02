import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/domain/entities/rider_proximity_state.dart';
import 'package:dwaar/domain/services/i_notification_service.dart';
import 'package:dwaar/domain/services/i_proximity_service.dart';
import 'package:dwaar/ui/features/home/driver/viewmodels/rider_proximity_viewmodel.dart';

// ── Inline mocks ──────────────────────────────────────────────────────────────

class MockProximityService implements IProximityService {
  final _controller = StreamController<LatLng>.broadcast();

  @override
  Stream<LatLng> get positions => _controller.stream;

  @override
  void simulatePosition(double lat, double lng) {
    if (!_controller.isClosed) _controller.add((lat: lat, lng: lng));
  }

  @override
  void dispose() => _controller.close();
}

class NotificationEntry {
  final String orderId;
  final ProximityNotificationKind kind;
  NotificationEntry({required this.orderId, required this.kind});
}

class MockNotificationService implements INotificationService {
  final List<NotificationEntry> log = [];

  @override
  Future<void> notifyProximity({
    required String orderId,
    required ProximityNotificationKind kind,
  }) async {
    log.add(NotificationEntry(orderId: orderId, kind: kind));
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Riyadh city centre (24.6877, 46.7219).
/// Pickup is set to this coordinate; drop-off is 1 km east.
const double _pickupLat = 24.6877;
const double _pickupLng = 46.7219;
const double _dropoffLat = 24.6877;
const double _dropoffLng = 46.7310; // ~700m east

/// A nearby coordinate — within kNearThresholdMeters of pickup.
const double _nearPickupLat = 24.6880;
const double _nearPickupLng = 46.7221;

/// A nearby coordinate — within kNearThresholdMeters of drop-off.
const double _nearDropoffLat = 24.6879;
const double _nearDropoffLng = 46.7312;

/// Coordinate far from both points.
const double _farLat = 24.0;
const double _farLng = 46.0;

Order _makeOrder({OrderStatus status = OrderStatus.accepted}) => Order(
      id: 'ORD-TEST-01',
      type: OrderType.pickup,
      wasteTypes: [WasteType.plastic],
      pickupAddress: 'نقطة الاستلام',
      dropoffAddress: 'نقطة التسليم',
      status: status,
      reward: 20,
      createdAt: DateTime(2025, 1, 1),
      pickupLat: _pickupLat,
      pickupLng: _pickupLng,
      dropoffLat: _dropoffLat,
      dropoffLng: _dropoffLng,
    );

/// Pumps the event loop to let stream listeners fire.
Future<void> _settle() => Future.delayed(Duration.zero);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockProximityService proxSvc;
  late MockNotificationService notifSvc;
  late RiderProximityViewModel vm;

  setUp(() {
    proxSvc = MockProximityService();
    notifSvc = MockNotificationService();
    vm = RiderProximityViewModel(
      order: _makeOrder(),
      proximityService: proxSvc,
      notificationService: notifSvc,
    );
  });

  tearDown(() => vm.dispose());

  // ── Initial state ──────────────────────────────────────────────────────────

  group('initial state', () {
    test('starts as ProximityIdle', () {
      expect(vm.proximityState, isA<ProximityIdle>());
    });

    test('chat is disabled when idle', () {
      expect(vm.isChatEnabled.value, isFalse);
    });

    test('nearPickup convenience getter is null when idle', () {
      expect(vm.nearPickup.value, isNull);
    });
  });

  // ── Near Pickup ────────────────────────────────────────────────────────────

  group('near pickup (accepted order)', () {
    test('transitions to NearPickup when within threshold', () async {
      var notified = 0;
      final disposeEffect = effect(() => { vm.proximityState, notified++ });

      proxSvc.simulatePosition(_nearPickupLat, _nearPickupLng);
      await _settle();

      expect(vm.proximityState, isA<NearPickup>());
      expect(notified, greaterThanOrEqualTo(1));
      disposeEffect();
    });

    test('chat is enabled when NearPickup', () async {
      proxSvc.simulatePosition(_nearPickupLat, _nearPickupLng);
      await _settle();
      expect(vm.isChatEnabled.value, isTrue);
    });

    test('nearPickup getter is non-null when NearPickup', () async {
      proxSvc.simulatePosition(_nearPickupLat, _nearPickupLng);
      await _settle();
      expect(vm.nearPickup.value, isNotNull);
    });

    test('NearPickup.elapsed starts at zero', () async {
      proxSvc.simulatePosition(_nearPickupLat, _nearPickupLng);
      await _settle();
      expect(vm.nearPickup.value!.elapsed, Duration.zero);
    });

    test('NearPickup.waitExpired is false at start', () async {
      proxSvc.simulatePosition(_nearPickupLat, _nearPickupLng);
      await _settle();
      expect(vm.nearPickup.value!.waitExpired, isFalse);
    });

    test('sends riderNearPickup notification exactly once', () async {
      proxSvc.simulatePosition(_nearPickupLat, _nearPickupLng);
      await _settle();
      // Send again — should still be just one notification.
      proxSvc.simulatePosition(_nearPickupLat, _nearPickupLng);
      await _settle();

      expect(notifSvc.log.length, 1);
      expect(
        notifSvc.log.first.kind,
        ProximityNotificationKind.riderNearPickup,
      );
    });
  });

  // ── Returns to idle ────────────────────────────────────────────────────────

  group('returns to idle', () {
    test('transitions back to ProximityIdle when rider moves away', () async {
      proxSvc.simulatePosition(_nearPickupLat, _nearPickupLng);
      await _settle();
      expect(vm.proximityState, isA<NearPickup>());

      proxSvc.simulatePosition(_farLat, _farLng);
      await _settle();
      expect(vm.proximityState, isA<ProximityIdle>());
    });

    test('chat is disabled once back to idle', () async {
      proxSvc.simulatePosition(_nearPickupLat, _nearPickupLng);
      await _settle();

      proxSvc.simulatePosition(_farLat, _farLng);
      await _settle();
      expect(vm.isChatEnabled.value, isFalse);
    });
  });

  // ── Near drop-off (inTransit) ──────────────────────────────────────────────

  group('near dropoff (inTransit order)', () {
    late RiderProximityViewModel transitVm;

    setUp(() {
      transitVm = RiderProximityViewModel(
        order: _makeOrder(status: OrderStatus.inTransit),
        proximityService: proxSvc,
        notificationService: notifSvc,
      );
    });

    tearDown(() => transitVm.dispose());

    test('transitions to NearDropoff when inTransit and near dropoff', () async {
      proxSvc.simulatePosition(_nearDropoffLat, _nearDropoffLng);
      await _settle();
      expect(transitVm.proximityState, isA<NearDropoff>());
    });

    test('chat is enabled when NearDropoff', () async {
      proxSvc.simulatePosition(_nearDropoffLat, _nearDropoffLng);
      await _settle();
      expect(transitVm.isChatEnabled.value, isTrue);
    });

    test('sends riderNearDropoff notification exactly once', () async {
      proxSvc.simulatePosition(_nearDropoffLat, _nearDropoffLng);
      await _settle();
      proxSvc.simulatePosition(_nearDropoffLat, _nearDropoffLng);
      await _settle();

      expect(notifSvc.log.length, 1);
      expect(
        notifSvc.log.first.kind,
        ProximityNotificationKind.riderNearDropoff,
      );
    });

    test('accepted order does NOT trigger NearDropoff even when near dropoff', () async {
      // vm uses accepted status; near dropoff position should stay idle
      proxSvc.simulatePosition(_nearDropoffLat, _nearDropoffLng);
      await _settle();
      expect(vm.proximityState, isA<ProximityIdle>());
    });
  });

  // ── Simulation helpers ─────────────────────────────────────────────────────

  group('simulation helpers', () {
    test('simulateAtPickup triggers NearPickup', () async {
      vm.simulateAtPickup();
      await _settle();
      expect(vm.proximityState, isA<NearPickup>());
    });

    test('simulateAtDropoff on inTransit order triggers NearDropoff', () async {
      final transitVm = RiderProximityViewModel(
        order: _makeOrder(status: OrderStatus.inTransit),
        proximityService: proxSvc,
        notificationService: notifSvc,
      );
      transitVm.simulateAtDropoff();
      await _settle();
      expect(transitVm.proximityState, isA<NearDropoff>());
      transitVm.dispose();
    });

    test('simulateFarAway resets to idle', () async {
      vm.simulateAtPickup();
      await _settle();

      vm.simulateFarAway();
      await _settle();
      expect(vm.proximityState, isA<ProximityIdle>());
    });
  });

  // ── Dispose ────────────────────────────────────────────────────────────────

  group('dispose', () {
    test('does not throw', () {
      final localVm = RiderProximityViewModel(
        order: _makeOrder(),
        proximityService: MockProximityService(),
        notificationService: MockNotificationService(),
      );
      expect(() => localVm.dispose(), returnsNormally);
    });

    test('position events after dispose do not crash', () async {
      final localProxSvc = MockProximityService();
      final localVm = RiderProximityViewModel(
        order: _makeOrder(),
        proximityService: localProxSvc,
        notificationService: MockNotificationService(),
      );
      localVm.dispose();
      // Should be silently ignored (not crash).
      localProxSvc.simulatePosition(_nearPickupLat, _nearPickupLng);
      await _settle();
    });
  });
}
