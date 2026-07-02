import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/user.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/domain/services/i_location_publisher.dart';
import 'package:dwaar/l10n/generated/app_localizations_en.dart';
import 'package:dwaar/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart';

final _testL10n = AppLocalizationsEn();

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

      final order = store.driverFeedFor().first;
      final error = await vm.acceptOrder(order, _testL10n);

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

      vm.toggleAvailability(false, _testL10n);
      expect(vm.isAvailable, isFalse);

      final order = store.driverFeedFor().first;
      final error = await vm.acceptOrder(order, _testL10n);

      expect(error, isNotNull);
      expect(vm.currentTab, 0);
      expect(publisher.startCallCount, 0);
    });

    test('driver already has active order: store returns error, publisher not called', () async {
      final publisher = _FakeLocationPublisher();
      final store = AppOrderStore();
      final vm = DriverHomeViewModel(store, publisher: publisher);
      addTearDown(vm.dispose);

      final firstOrder = store.driverFeedFor().first;
      await vm.acceptOrder(firstOrder, _testL10n);
      expect(publisher.startCallCount, 1);

      final secondOrder = store.driverFeedFor().first;
      final error = await vm.acceptOrder(secondOrder, _testL10n);

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

      final order = store.driverFeedFor().first;
      await vm.acceptOrder(order, _testL10n);
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

      final order = store.driverFeedFor().first;
      await vm.acceptOrder(order, _testL10n);

      final error = vm.toggleAvailability(false, _testL10n);
      expect(error, isNotNull);
      expect(vm.isAvailable, isTrue);
    });

    test('allows going offline when no active order', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);

      expect(vm.toggleAvailability(false, _testL10n), isNull);
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
      store.acceptOrder(store.driverFeedFor().first.id, storeDriver);

      expect(vmNotifications, greaterThan(0));
    });
  });
}
