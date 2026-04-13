import 'package:flutter/material.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/services/app_order_store.dart';

enum SupplierPurchaseMode { selfPickup, assignRider }

class MarketplaceViewModel extends ChangeNotifier {
  final AppOrderStore _store;

  MarketplaceViewModel(this._store) {
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => notifyListeners();

  // ── Local filter state ────────────────────────────────────────────────────

  String _searchQuery = '';
  WasteType? _selectedCategory;

  String get searchQuery => _searchQuery;
  WasteType? get selectedCategory => _selectedCategory;

  // ── Filtered items (reads from shared store) ──────────────────────────────

  List<Order> get filteredItems {
    var items = _store.marketItems
        .where((o) => o.status == OrderStatus.pending)
        .toList();

    if (_selectedCategory != null) {
      items = items
          .where((o) => o.wasteTypes.contains(_selectedCategory))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((o) {
        final matchTypes = o.wasteTypes.any((t) => t.label.contains(q));
        final matchName =
            (o.supplierName ?? '').toLowerCase().contains(q);
        final matchAddress = o.pickupAddress.toLowerCase().contains(q);
        final matchNotes =
            (o.supplierNotes ?? '').toLowerCase().contains(q);
        return matchTypes || matchName || matchAddress || matchNotes;
      }).toList();
    }

    return items;
  }

  // ── Search & filter ───────────────────────────────────────────────────────

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(WasteType? category) {
    _selectedCategory = (_selectedCategory == category) ? null : category;
    notifyListeners();
  }

  // ── Publisher actions ─────────────────────────────────────────────────────

  void addListing(Order order) => _store.addMarketListing(order);

  void removeListing(String orderId) => _store.removeMarketListing(orderId);

  List<Order> myListings(String publisherName) =>
      _store.myMarketListings(publisherName);

  // ── Driver: claim item ────────────────────────────────────────────────────

  Order? claimItem(String orderId, User driver) =>
      _store.claimMarketItem(orderId, driver);

  // ── Supplier: purchase item ───────────────────────────────────────────────

  Order? purchaseItem({
    required String orderId,
    required SupplierPurchaseMode mode,
    String? dropoffAddress,
    double deliveryFee = 0,
  }) =>
      _store.purchaseMarketItem(
        orderId: orderId,
        selfPickup: mode == SupplierPurchaseMode.selfPickup,
        dropoffAddress: dropoffAddress,
        deliveryFee: deliveryFee,
      );

  // ── Company: receive at facility ──────────────────────────────────────────

  Order? receiveAtFacility(String orderId, String facilityAddress) =>
      _store.receiveAtFacility(orderId, facilityAddress);
}
