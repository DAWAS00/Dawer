import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dwaar/backend_integration_locally/local_store.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/services/app_order_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('first launch seeds orders + marks flag done', () async {
    final store = await LocalStore.init();
    expect(store.isFirstLaunch, isTrue);

    final sut = AppOrderStore(store: store);
    // Allow ctor fire-and-forget writes to drain.
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(sut.driverFeedFor().isNotEmpty || sut.companyIncoming.isNotEmpty, isTrue);
    expect(store.isFirstLaunch, isFalse);
    expect(store.readOrders().isNotEmpty, isTrue);
  });

  test('new supplier order survives restart via LocalStore', () async {
    final store1 = await LocalStore.init();
    final sut1 = AppOrderStore(store: store1);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    sut1.createPickupRequest(
      wasteTypes: const [WasteType.plastic],
      supplierName: 'متجر دوّار',
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // New store instance reads the same prefs (simulates a cold start).
    final store2 = await LocalStore.init();
    final sut2 = AppOrderStore(store: store2);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(
      sut2.supplierOrdersFor('متجر دوّار').any((o) =>
          o.type == OrderType.pickup &&
          o.wasteTypes.contains(WasteType.plastic)),
      isTrue,
    );
  });
}
