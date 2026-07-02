import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/ui/features/home/supplier/viewmodels/individual_supplier_viewmodel.dart';
import 'package:dwaar/ui/features/home/shared/viewmodels/base_supplier_viewmodel.dart';

void main() {
  late AppOrderStore store;
  late BaseSupplierViewModel viewModel;

  setUp(() {
    store = AppOrderStore(skipMockSeed: true); // start with empty store
    viewModel = IndividualSupplierViewModel(store);
  });

  group('Marketplace Listing Persistence (Phase 0 Fix)', () {
    test(
      'addOrder successfully persists marketplace listing to AppOrderStore',
      () {
        final listing = viewModel.createListing(
          wasteTypes: [WasteType.plastic],
          pickupAddress: 'شارع الجامعة، عمان',
          itemPrice: 15.0,
        );

        // Verify listing is not yet in the store
        expect(store.marketItems.contains(listing), isFalse);

        // Call addOrder on the viewmodel (simulates wizard submission)
        viewModel.addOrder(listing);

        // Verify that after the fix, the listing is successfully added to the store
        expect(store.marketItems.any((item) => item.id == listing.id), isTrue);
        expect(
          store.marketItems
              .firstWhere((item) => item.id == listing.id)
              .itemPrice,
          15.0,
        );
      },
    );
  });
}
