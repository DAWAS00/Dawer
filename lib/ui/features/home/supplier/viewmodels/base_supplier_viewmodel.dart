import 'package:flutter/material.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/services/app_order_store.dart';

/// Abstract base for [SupplierHomeViewModel] and [IndividualSupplierViewModel].
/// Contains all shared state, getters, and actions so concrete subclasses only
/// need to provide [defaultUser] and [listingIdPrefix].
abstract class BaseSupplierViewModel extends ChangeNotifier {
  final AppOrderStore _store;
  late User _user;

  BaseSupplierViewModel(this._store) {
    _user = defaultUser;
    _store.addListener(_onStoreChanged);
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

  // ── Exposed to subclasses ─────────────────────────────────────────────────

  @protected
  AppOrderStore get store => _store;

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

  List<Order> get orders => _store.supplierOrdersFor(_user.name);
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
        dropoffLat: 31.9992,
        dropoffLng: 36.0025,
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
    final orderId =
        '$listingIdPrefix${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
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

  void assignDriver(String orderId, User driver) =>
      _store.assignDriver(orderId, driver);

  void addOrder(Order order) {
    _currentTab = 2;
    notifyListeners();
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  void updateProfile({String? name, String? phone, String? address}) {
    _user = _user.copyWith(name: name, phone: phone, address: address);
    notifyListeners();
  }
}
