import 'dart:math' show Random;

import 'package:flutter/material.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/services/app_order_store.dart';

import '../../../../../domain/failures/app_failure.dart';
import '../../../../../domain/requests/create_pickup_request.dart';

/// Abstract base for [SupplierHomeViewModel] and [IndividualSupplierViewModel].
/// Contains all shared state, getters, and actions so concrete subclasses only
/// need to provide [defaultUser] and [listingIdPrefix].
abstract class BaseSupplierViewModel extends ChangeNotifier {
  final AppOrderStore _store;
  late User _user;
  String? _authUserId;

  bool _isSubmittingPickup = false;
  AppFailure? _pickupSubmitError;
  Order? _lastCreatedOrder;

  bool get isSubmittingPickup => _isSubmittingPickup;
  AppFailure? get pickupSubmitError => _pickupSubmitError;
  Order? get lastCreatedOrder => _lastCreatedOrder;

  BaseSupplierViewModel(this._store) {
    _user = defaultUser;
    _store.addListener(_onStoreChanged);
  }

  void setAuthUserId(String id) {
    _authUserId = id;
    notifyListeners();
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => notifyListeners();

  // ── Abstract ──────────────────────────────────────────────────────────────

  User get defaultUser;
  String get listingIdPrefix;
  int get listingTtlDays;
  bool get isBusiness;

  // ── Exposed to subclasses ─────────────────────────────────────────────────

  @protected
  AppOrderStore get store => _store;

  bool get isLoading => _store.isLoading;

  // ── Local state ───────────────────────────────────────────────────────────

  int _currentTab = 0;
  double? _pickupLat;
  double? _pickupLng;

  // ── Getters ───────────────────────────────────────────────────────────────

  int get currentTab => _currentTab;
  User get user => _user;
  double? get pickupLat => _pickupLat;
  double? get pickupLng => _pickupLng;
  bool get isPickupLocationSet => _pickupLat != null && _pickupLng != null;

  void setPickupLocation(double lat, double lng) {
    _pickupLat = lat;
    _pickupLng = lng;
    notifyListeners();
  }

  void clearPickupLocation() {
    _pickupLat = null;
    _pickupLng = null;
    notifyListeners();
  }

  List<Order> get orders => _authUserId != null
      ? _store.supplierOrdersForId(_authUserId!)
      : _store.supplierOrdersFor(_user.name);
  List<Order> get collectionSaleOrders => _store.collectionSalesFor(_user.name);

  List<Order> get activeOrders => orders
      .where((o) =>
          o.status == OrderStatus.pending ||
          o.status == OrderStatus.accepted ||
          o.status == OrderStatus.inTransit)
      .toList();

  List<Order> get completedOrders =>
      orders.where((o) => o.status == OrderStatus.completed).toList();

  List<Order> get cancelledOrders =>
      orders.where((o) => o.status == OrderStatus.cancelled).toList();

  Order? get trackedOrder => orders
      .where((o) => o.status == OrderStatus.inTransit && o.driverName != null)
      .firstOrNull;

  int get totalPoints => _user.points;
  int get totalOrders => completedOrders.length + _user.totalOrders;

  // ── Tab navigation ────────────────────────────────────────────────────────

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  // ── Order actions ─────────────────────────────────────────────────────────

  Order createOrder({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    List<String> images = const [],
    String? notes,
    double? estimatedWeightKg,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    PickupTarget? pickupTarget,
    double? itemPrice,
    DateTime? scheduledAt,
    double? dropoffLat,
    double? dropoffLng,
  }) =>
      _store.createPickupRequest(
        wasteTypes: wasteTypes,
        supplierName: _user.name,
        pickupAddress: pickupAddress,
        notes: notes,
        images: images,
        estimatedWeightKg: estimatedWeightKg,
        wasteForm: wasteForm,
        weightCategory: weightCategory,
        pickupTarget: pickupTarget,
        itemPrice: itemPrice,
        scheduledAt: scheduledAt,
        pickupLat: _pickupLat,
        pickupLng: _pickupLng,
        dropoffLat: dropoffLat,
        dropoffLng: dropoffLng,
      );

  /// Builds a marketplace listing Order and returns it.
  /// The caller is responsible for adding it to the marketplace via
  /// MarketplaceViewModel.addListing(order).
  Order createListing({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    List<String> images = const [],
    String? notes,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    double? itemPrice,
    double? pickupLat,
    double? pickupLng,
  }) {
    final orderId = _generateUuid();
    final hasChemicals = wasteTypes.contains(WasteType.chemicals);
    // Jordan VAT 16% applies to B2B marketplace transactions.
    const vatRate = 0.16;
    final effectivePrice = itemPrice ?? 0.0;
    final vatApplicable = isBusiness && effectivePrice > 0;
    return Order(
      id: orderId,
      type: OrderType.pickup,
      wasteTypes: wasteTypes,
      pickupAddress: pickupAddress,
      dropoffAddress: 'أقرب مركز تدوير',
      status: OrderStatus.pending,
      reward: 0,
      createdAt: DateTime.now(),
      supplierName: _user.name,
      supplierNotes: notes,
      images: images,
      wasteForm: wasteForm,
      weightCategory: weightCategory,
      pickupTarget: PickupTarget.riderBuy,
      itemPrice: itemPrice,
      isMarketplaceShared: true,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      expiresAt: DateTime.now().add(Duration(days: listingTtlDays)),
      adminApprovalStatus: hasChemicals
          ? AdminApprovalStatus.pendingApproval
          : AdminApprovalStatus.notRequired,
      isVatApplicable: vatApplicable,
      vatAmountJd: vatApplicable ? (effectivePrice * vatRate) : null,
    );
  }

  /// Move a collectionSale to inTransit. Returns error string or null.
  String? startCollectionSaleTransit(String saleId) =>
      _store.markCollectionSaleInTransit(saleId);

  /// Complete a collectionSale.
  String? completeCollectionSale(String saleId, {double? actualWeightKg}) =>
      _store.completeCollectionSale(saleId, actualWeightKg: actualWeightKg);

  /// Cancel a pending collectionSale. Silently ignored if inTransit/completed.
  void cancelCollectionSale(String saleId) =>
      _store.cancelCollectionSale(saleId);

  String? cancelOrder(String orderId) => _store.cancelOrder(orderId);

  static String _generateUuid() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  void assignDriver(String orderId, User driver) =>
      _store.assignDriver(orderId, driver);

  Future<bool> submitPickupRequest(CreatePickupRequest request) async {
    _isSubmittingPickup = true;
    _pickupSubmitError = null;
    notifyListeners();

    final result = _store.submitPickupRequest(
      request,
      supplierName: user.name,
    );

    result.fold(
      onSuccess: (order) {
        _lastCreatedOrder = order;
        _pickupSubmitError = null;
      },
      onFailure: (failure) {
        _pickupSubmitError = failure;
      },
    );

    _isSubmittingPickup = false;
    notifyListeners();
    return result.isSuccess;
  }

  void addOrder(Order order) {
    if (order.isMarketplaceShared) {
      _store.addMarketListing(order);
    }
    _currentTab = 2;
    notifyListeners();
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  void updateProfile({String? name, String? phone, String? address}) {
    _user = _user.copyWith(name: name, phone: phone, address: address);
    notifyListeners();
  }
}
