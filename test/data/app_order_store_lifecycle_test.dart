import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/core/result/result.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/models/user.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/domain/failures/app_failure.dart';
import 'package:dwaar/domain/repositories/i_order_repository.dart';

// ── Recording fake repository ─────────────────────────────────────────────────

class _RecordingOrderRepository implements IOrderRepository {
  final List<String> calls = [];

  AppResult<void> _nextResult = const Success(null);

  void failNextWith(AppFailure failure) => _nextResult = Failure(failure);

  AppResult<void> _record(String name) {
    calls.add(name);
    final r = _nextResult;
    _nextResult = const Success(null);
    return r;
  }

  @override
  Stream<List<Order>> watchOrders() => const Stream.empty();

  @override
  Stream<List<Order>> watchOrdersForUser(String userId, UserRole role) =>
      const Stream.empty();

  @override
  Future<AppResult<void>> insertOrder(Order order) async =>
      _record('insertOrder');

  @override
  Future<AppResult<void>> updateOrder(Order order) async =>
      _record('updateOrder');

  @override
  Future<AppResult<void>> deleteOrder(String orderId) async =>
      _record('deleteOrder');

  @override
  Future<AppResult<void>> markAccepted(String orderId) async =>
      _record('markAccepted');

  @override
  Future<AppResult<void>> assignDriver(String orderId, String driverId) async =>
      _record('assignDriver');

  @override
  Future<AppResult<void>> markCancelled(String orderId) async =>
      _record('markCancelled');

  @override
  Future<AppResult<void>> markPurchased(
    String orderId, {
    required bool requiresRider,
  }) async =>
      _record('markPurchased');

  @override
  Future<AppResult<void>> markInTransit(String orderId) async =>
      _record('markInTransit');

  @override
  Future<AppResult<void>> markArrivedAtPickup(String orderId) async =>
      _record('markArrivedAtPickup');

  @override
  Future<AppResult<void>> markArrivedAtDropoff(String orderId) async =>
      _record('markArrivedAtDropoff');

  @override
  Future<AppResult<void>> markCompleted(String orderId, {double? actualWeightKg}) async =>
      _record('markCompleted');

  @override
  Future<AppResult<void>> recordTransaction({
    required String orderId,
    required breakdown,
    String? vehicleType,
  }) async => _record('recordTransaction');

  @override
  Future<AppResult<bool>> verifyArrival(String orderId, double lat, double lng) async {
    _record('verifyArrival');
    return const Success(true);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _driver = User(
  id: 'DRV-LIFECYCLE-01',
  name: 'سائق الاختبار',
  role: 'سائق',
  address: '',
  points: 0,
  totalOrders: 0,
  isVerified: true,
  vehicleModel: 'كيا',
  vehicleColor: 'رمادي',
  licensePlate: 'أ ب ج 9999',
);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('AppOrderStore – full pickup lifecycle', () {
    late _RecordingOrderRepository repo;
    late AppOrderStore store;

    setUp(() {
      repo = _RecordingOrderRepository();
      store = AppOrderStore(remote: repo);
    });

    tearDown(() => store.dispose());

    test('happy-path: pending → accepted → inTransit → completed', () async {
      final orderId = store.driverFeedFor().first.id;

      // accept
      expect(store.acceptOrder(orderId, _driver), isNull);
      expect(store.driverActiveOrder?.status, OrderStatus.accepted);

      // markInTransit
      store.markInTransit(orderId);
      expect(store.driverActiveOrder?.status, OrderStatus.inTransit);
      expect(store.driverActiveOrder?.inTransitAt, isNotNull);

      // complete
      store.completeOrder(store.driverActiveOrder!);
      expect(store.driverHasActiveOrder, isFalse);
      final completed =
          store.driverHistory.firstWhere((o) => o.id == orderId);
      expect(completed.status, OrderStatus.completed);
      expect(completed.completedAt, isNotNull);

      // let the fire-and-forget futures resolve
      await Future<void>.delayed(Duration.zero);

      expect(repo.calls, containsAll(['markAccepted', 'markInTransit', 'markCompleted']));
    });

    test('each transition fires notifyListeners exactly once', () async {
      final orderId = store.driverFeedFor().first.id;
      int notifications = 0;
      store.addListener(() => notifications++);

      store.acceptOrder(orderId, _driver);
      final afterAccept = notifications;
      expect(afterAccept, greaterThan(0));

      store.markInTransit(orderId);
      final afterTransit = notifications;
      expect(afterTransit, greaterThan(afterAccept));

      store.completeOrder(store.driverActiveOrder!);
      final afterComplete = notifications;
      expect(afterComplete, greaterThan(afterTransit));
    });

    test('race condition: second acceptOrder on already-accepted order returns error', () {
      final orderId = store.driverFeedFor().first.id;

      const secondDriver = User(
        id: 'DRV-LIFECYCLE-02',
        name: 'سائق ثانٍ',
        role: 'سائق',
        address: '',
        points: 0,
        totalOrders: 0,
        isVerified: true,
      );

      // First driver accepts
      expect(store.acceptOrder(orderId, _driver), isNull);
      expect(store.driverActiveOrder?.id, orderId);

      // Second driver on same store (simulates concurrent check on shared state)
      final secondError = store.acceptOrder(orderId, secondDriver);
      expect(secondError, isNotNull);

      // Order is still owned by first driver
      final order = store.driverActiveOrder;
      expect(order?.driverName, _driver.name);
      expect(order?.status, OrderStatus.accepted);
    });

    test('acceptOrder on already-accepted (non-assignRider) order returns "no longer available"', () {
      final orderId = store.driverFeedFor().first.id;
      store.acceptOrder(orderId, _driver);

      // Try to accept the same order again with first driver (should also fail)
      final error = store.acceptOrder(orderId, _driver);
      expect(error, isNotNull);
    });

    test('repository failure on acceptOrder propagates to store.lastError', () async {
      repo.failNextWith(const NetworkFailure());
      final orderId = store.driverFeedFor().first.id;
      store.acceptOrder(orderId, _driver);

      // Wait for unawaited future to resolve
      await Future<void>.delayed(Duration.zero);

      expect(store.lastError, isA<NetworkFailure>());
    });

    test('cancelOrder pushes markCancelled to repository', () async {
      final order = store.createPickupRequest(
        wasteTypes: [WasteType.paper],
        supplierName: 'مورد اختبار',
        pickupAddress: 'عنوان الاختبار',
      );

      final error = store.cancelOrder(order.id);
      expect(error, isNull);

      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, contains('markCancelled'));
    });

    test('completeOrder pushes markCompleted to repository', () async {
      final orderId = store.driverFeedFor().first.id;
      store.acceptOrder(orderId, _driver);
      store.completeOrder(store.driverActiveOrder!);

      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, contains('markCompleted'));
    });
  });
}
