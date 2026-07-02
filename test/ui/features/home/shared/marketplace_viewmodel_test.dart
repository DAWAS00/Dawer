import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/ui/features/home/shared/viewmodels/marketplace_viewmodel.dart';

MarketplaceViewModel _buildVm({
  List<String> suggestions = const [],
  bool isBusiness = false,
}) {
  final store = AppOrderStore();
  return MarketplaceViewModel(
    store,
    isBusiness: isBusiness,
    initialSuggestions: suggestions,
  );
}

void main() {
  group('MarketplaceViewModel – initial state', () {
    test('filteredItems returns pending market items', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      expect(vm.filteredItems, isNotEmpty);
      expect(
        vm.filteredItems.every((o) => o.status == OrderStatus.pending),
        isTrue,
      );
    });

    test('selectedCategory is null by default', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      expect(vm.selectedCategory, isNull);
    });

    test('searchQuery is empty by default', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      expect(vm.searchQuery, '');
    });

    test('isLoading reflects store loading state', () async {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      // Store may start loading asynchronously; isLoading must be a bool
      expect(vm.isLoading, isA<bool>());
      // Eventually settles to false
      await Future.delayed(const Duration(milliseconds: 100));
      expect(vm.isLoading, isFalse);
    });
  });

  group('MarketplaceViewModel – search filter', () {
    test('setSearch filters items by supplier name', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      final all = vm.filteredItems;
      if (all.isEmpty) return;

      final first = all.first;
      final name = first.supplierName ?? '';
      if (name.isEmpty) return;

      vm.setSearch(name.substring(0, 2));
      expect(vm.filteredItems, isNotEmpty);
      expect(
        vm.filteredItems.any(
          (o) => (o.supplierName ?? '').contains(name.substring(0, 2)),
        ),
        isTrue,
      );
    });

    test('setSearch with no match returns empty list', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      vm.setSearch('xyzXYZnonexistent999');
      expect(vm.filteredItems, isEmpty);
    });

    test('setSearch notifies listeners', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      var notified = false;
      vm.addListener(() => notified = true);
      vm.setSearch('test');
      expect(notified, isTrue);
    });
  });

  group('MarketplaceViewModel – category filter', () {
    test('setCategory filters by waste type', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      final all = vm.filteredItems;
      if (all.isEmpty) return;

      // Find a waste type present in the data
      final targetType = all.first.wasteTypes.firstOrNull;
      if (targetType == null) return;

      vm.setCategory(targetType);
      expect(vm.selectedCategory, targetType);
      expect(
        vm.filteredItems.every((o) => o.wasteTypes.contains(targetType)),
        isTrue,
      );
    });

    test('setCategory toggling same category clears filter', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      final all = vm.filteredItems;
      if (all.isEmpty) return;

      final targetType = all.first.wasteTypes.firstOrNull;
      if (targetType == null) return;

      vm.setCategory(targetType);
      expect(vm.selectedCategory, targetType);

      // Toggle same → clears
      vm.setCategory(targetType);
      expect(vm.selectedCategory, isNull);
    });

    test('setCategory(null) shows all items', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      final all = vm.filteredItems;

      final targetType = all.firstOrNull?.wasteTypes.firstOrNull;
      if (targetType == null) return;

      vm.setCategory(targetType);
      final filtered = vm.filteredItems.length;

      vm.setCategory(null);
      expect(vm.filteredItems.length, greaterThanOrEqualTo(filtered));
    });

    test('setCategory notifies listeners', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      var notified = false;
      vm.addListener(() => notified = true);
      vm.setCategory(WasteType.paper);
      expect(notified, isTrue);
    });
  });

  group('MarketplaceViewModel – suggestion banner', () {
    test('hasUserCategories false when no suggestions', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      expect(vm.hasUserCategories, isFalse);
      expect(vm.showSuggestionBanner, isFalse);
    });

    test('hasUserCategories true when suggestions provided', () {
      final vm = _buildVm(suggestions: ['ورق', 'بلاستيك']);
      addTearDown(vm.dispose);
      expect(vm.hasUserCategories, isTrue);
      expect(vm.showSuggestionBanner, isTrue);
      expect(vm.aiSuggestedCategories, ['ورق', 'بلاستيك']);
    });

    test('dismissSuggestions clears categories', () {
      final vm = _buildVm(suggestions: ['ورق']);
      addTearDown(vm.dispose);
      vm.dismissSuggestions();
      expect(vm.hasUserCategories, isFalse);
      expect(vm.showSuggestionBanner, isFalse);
    });

    test('dismissSuggestions notifies listeners', () {
      final vm = _buildVm(suggestions: ['ورق']);
      addTearDown(vm.dispose);
      var notified = false;
      vm.addListener(() => notified = true);
      vm.dismissSuggestions();
      expect(notified, isTrue);
    });

    test('showAllOrders clears search, category, and suggestions', () {
      final vm = _buildVm(suggestions: ['ورق']);
      addTearDown(vm.dispose);
      vm.setSearch('test');
      vm.setCategory(WasteType.paper);
      vm.showAllOrders();
      expect(vm.searchQuery, '');
      expect(vm.selectedCategory, isNull);
      expect(vm.showSuggestionBanner, isFalse);
    });

    test('setAiSuggestions updates categories', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      vm.setAiSuggestions(['معادن', 'زجاج']);
      expect(vm.aiSuggestedCategories, ['معادن', 'زجاج']);
      expect(vm.showSuggestionBanner, isTrue);
    });
  });

  group('MarketplaceViewModel – listing limits', () {
    test('maxListings is 5 for individual', () {
      final vm = _buildVm(isBusiness: false);
      addTearDown(vm.dispose);
      expect(vm.maxListings, 5);
    });

    test('maxListings is 20 for business', () {
      final vm = _buildVm(isBusiness: true);
      addTearDown(vm.dispose);
      expect(vm.maxListings, 20);
    });

    test('canAddListing true when under limit', () {
      final vm = _buildVm(isBusiness: false);
      addTearDown(vm.dispose);
      expect(vm.canAddListing('test_user'), isTrue);
    });
  });

  group('MarketplaceViewModel – collection jobs', () {
    test('collectionJobs returns pending jobs from store', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      expect(vm.collectionJobs, isA<List<Order>>());
      expect(
        vm.collectionJobs.every((j) => j.type == OrderType.collection),
        isTrue,
      );
    });

    test('collectionJobsFor returns all when userName is null', () {
      final vm = _buildVm();
      addTearDown(vm.dispose);
      final all = vm.collectionJobs;
      final forNull = vm.collectionJobsFor(null);
      expect(forNull.length, all.length);
    });
  });
}
