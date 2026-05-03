import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/user.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/domain/services/i_location_publisher.dart';
import 'package:dwaar/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart';

// ── Fake location publisher ───────────────────────────────────────────────────

class _FakeLocationPublisher implements ILocationPublisher {
  String? lastStartedOrderId;
  int startCallCount = 0;
  int stopCallCount = 0;

  @override
  Future<void> start(String orderId) async {
    lastStartedOrderId = orderId;
    startCallCount++;
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

DriverHomeViewModel _buildVm({
  _FakeLocationPublisher? publisher,
}) {
  final store = AppOrderStore();
  return DriverHomeViewModel(store, publisher: publisher ?? _FakeLocationPublisher());
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('DriverHomeViewModel – acceptOrder', () {
    test('available driver: accepts order, switches to tab 2, starts publisher', () async {
      final publisher = _FakeLocationPublisher();
      final store = AppOrderStore();
      final vm = DriverHomeViewModel(store, publisher: publisher);
      addTearDown(vm.dispose);

      final order = store.driverFeed.first;
      final error = await vm.acceptOrder(order);

      expect(error, isNull);
      expect(vm.currentTab, 2);
      expect(publisher.startCallCount, 1);
      expect(publisher.lastStartedOrderId, order.id);
      expect(vm.active?.id, order.id);
    });

    test('unavailable driver: returns error, tab unchanged, publisher not called', () async {
      final publisher = _FakeLocationPublisher();
      final store = AppOrderStore();
      final vm = DriverHomeViewModel(store, publisher: publisher);
      addTearDown(vm.dispose);

      vm.toggleAvailability(false);
      expect(vm.isAvailable, isFalse);

      final order = store.driverFeed.first;
      final error = await vm.acceptOrder(order);

      expect(error, isNotNull);
      expect(vm.currentTab, 0);
      expect(publisher.startCallCount, 0);
    });

    test('driver already has active order: store returns error, publisher not called', () async {
      final publisher = _FakeLocationPublisher();
      final store = AppOrderStore();
      final vm = DriverHomeViewModel(store, publisher: publisher);
      addTearDown(vm.dispose);

      final firstOrder = store.driverFeed.first;
      await vm.acceptOrder(firstOrder);
      expect(publisher.startCallCount, 1);

      final secondOrder = store.driverFeed.first;
      final error = await vm.acceptOrder(secondOrder);

      expect(error, isNotNull);
      expect(publisher.startCallCount, 1); // no second start
    });
  });

  group('DriverHomeViewModel – completeOrder', () {
    test('completes order and stops publisher', () async {
      final publisher = _FakeLocationPublisher();
      final store = AppOrderStore();
      final vm = DriverHomeViewModel(store, publisher: publisher);
      addTearDown(vm.dispose);

      final order = store.driverFeed.first;
      await vm.acceptOrder(order);
      expect(vm.active, isNotNull);

      await vm.completeOrder(vm.active!);

      expect(publisher.stopCallCount, 1);
      expect(vm.active, isNull);
      expect(store.driverHasActiveOrder, isFalse);
    });
  });

  group('DriverHomeViewModel – toggleAvailability', () {
    test('returns error when trying to go offline with active order', () async {
      final store = AppOrderStore();
      final vm = DriverHomeViewModel(store, publisher: _FakeLocationPublisher());
      addTearDown(vm.dispose);

      final order = store.driverFeed.first;
      await vm.acceptOrder(order);

      final error = vm.toggleAvailability(false);
      expect(error, isNotNull);
      expect(vm.isAvailable, isTrue);
    });

    test('allows going offline when no active order', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);

      expect(vm.toggleAvailability(false), isNull);
      expect(vm.isAvailable, isFalse);
    });
  });

  group('DriverHomeViewModel – store listener propagation', () {
    test('store mutation triggers VM notifyListeners', () async {
      final store = AppOrderStore();
      final vm = DriverHomeViewModel(store);
      addTearDown(vm.dispose);

      int vmNotifications = 0;
      vm.addListener(() => vmNotifications++);

      const storeDriver = User(
        id: 'DRV-STUB-01',
        name: 'سائق الاستماع',
        role: 'سائق',
        address: '',
        points: 0,
        totalOrders: 0,
        isVerified: true,
      );
      store.acceptOrder(store.driverFeed.first.id, storeDriver);

      expect(vmNotifications, greaterThan(0));
    });
  });
}
