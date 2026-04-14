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

  // ── Collection jobs (recycling company postings) ───────────────────────────

  /// All pending collection jobs — shown in marketplace for all roles.
  List<Order> get collectionJobs => _store.pendingCollectionJobs;

  /// Pending jobs filtered so already-accepted ones are hidden for [userName].
  List<Order> collectionJobsFor(String? userName) {
    if (userName == null) return collectionJobs;
    return collectionJobs
        .where((j) => !_store.hasAcceptedJob(j.id, userName))
        .toList();
  }

  /// The most recently created collection-sale commitment for [acceptorName].
  Order? latestCollectionSaleFor(String acceptorName) =>
      _store.collectionSalesFor(acceptorName).firstOrNull;

  /// Jobs posted by a specific company (pending + accepted).
  List<Order> myCollectionJobs(String companyName) =>
      _store.myCollectionJobs(companyName);

  /// Driver claims a collection job.
  String? claimCollectionJob(String jobId, User driver) =>
      _store.claimCollectionJob(jobId, driver);

  /// Edit a collection job (owner only). Returns updated order or null.
  Order? updateCollectionJob({
    required String jobId,
    required String companyName,
    required List<WasteType> wasteTypes,
    required String collectionArea,
    required String jobDescription,
    required PaymentModel paymentModel,
    required double price,
    double? minQuantityKg,
    String? editNote,
  }) =>
      _store.updateCollectionJob(
        jobId: jobId,
        companyName: companyName,
        wasteTypes: wasteTypes,
        collectionArea: collectionArea,
        jobDescription: jobDescription,
        paymentModel: paymentModel,
        price: price,
        minQuantityKg: minQuantityKg,
        editNote: editNote,
      );

  /// Delete a collection job (owner only). Returns true on success.
  bool deleteCollectionJob(String jobId, String companyName) =>
      _store.deleteCollectionJob(jobId, companyName);

  /// Whether [acceptorName] has already committed to [jobId].
  bool hasAcceptedJob(String jobId, String acceptorName) =>
      _store.hasAcceptedJob(jobId, acceptorName);

  /// Driver or supplier accepts a collection job → creates a collectionSale.
  /// Returns an error string on failure, null on success.
  String? acceptCollectionJob(
    String jobId,
    String acceptorName, {
    CollectionDeliveryMethod? deliveryMethod,
    CollectionTransactionType? transactionType,
  }) {
    final job = _store.getCollectionJob(jobId);
    if (job == null) return 'الوظيفة غير موجودة';
    if (job.status != OrderStatus.pending) return 'هذه الوظيفة لم تعد متاحة';
    return _store.createCollectionSale(
      jobId: jobId,
      acceptorName: acceptorName,
      collectionArea: job.pickupAddress,
      wasteTypes: job.wasteTypes,
      paymentModel: job.paymentModel,
      pricePerKg: job.pricePerKg,
      itemPrice: job.itemPrice,
      minQuantityKg: job.minQuantityKg,
      jobDescription: job.jobDescription,
      companyName: job.supplierName,
      deliveryMethod: deliveryMethod,
      transactionType: transactionType,
    );
  }
}
