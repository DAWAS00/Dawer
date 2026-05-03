import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/ui/features/home/shared/viewmodels/marketplace_viewmodel.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/data/models/order.dart';

void main() {
  late AppOrderStore store;
  late MarketplaceViewModel vm;

  setUp(() {
    store = AppOrderStore();
    vm = MarketplaceViewModel(store, initialSuggestions: ['Plastics', 'Paper']);
  });

  test('showAllOrders clears search, category and dismisses banner', () {
    // 1. Set some filters
    vm.setSearch('Bottle');
    vm.setCategory(WasteType.plastic);
    
    expect(vm.searchQuery, 'Bottle');
    expect(vm.selectedCategory, WasteType.plastic);
    expect(vm.showSuggestionBanner, isTrue);

    // 2. Call showAllOrders
    vm.showAllOrders();

    // 3. Verify everything is cleared
    expect(vm.searchQuery, '');
    expect(vm.selectedCategory, isNull);
    expect(vm.showSuggestionBanner, isFalse);
  });
}
