import 'package:flutter/material.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../../../../data/services/location_publisher.dart';
import '../../../../../domain/services/i_location_publisher.dart';

class DriverHomeViewModel extends ChangeNotifier {
  final AppOrderStore _store;
  final ILocationPublisher _publisher;

  DriverHomeViewModel(
    this._store, {
    ILocationPublisher? publisher,
  }) : _publisher = publisher ?? LocationPublisher.instance {
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => notifyListeners();

  // ── Local state ───────────────────────────────────────────────────────────

  int _currentTab = 0;
  bool _isAvailable = true;

  User _user = const User(
    id: 'DRV-19842',
    name: 'سائق دوّر',
    role: 'سائق',
    rating: 4.8,
  );

  // ── Getters (delegated to store) ──────────────────────────────────────────

  int get currentTab => _currentTab;
  bool get isAvailable => _isAvailable;
  User get user => _user;

  List<Order> get available => _store.driverFeed;
  Order? get active => _store.driverActiveOrder;
  List<Order> get history => _store.driverHistory;
  List<Order> get collectionSaleOrders => _store.collectionSalesFor(_user.name);

  double get totalEarnings => _store.driverHistory
      .fold(0.0, (sum, o) => sum + o.reward);

  int get totalCompletedRides => _store.driverHistory
      .where((o) => o.status == OrderStatus.completed)
      .length;

  // ── Tab navigation ────────────────────────────────────────────────────────

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  // ── Availability ──────────────────────────────────────────────────────────

  String? toggleAvailability(bool value) {
    if (!value && _store.driverHasActiveOrder) {
      return 'لا يمكنك تغيير حالتك إلى غير متاح أثناء وجود طلب نشط.';
    }
    _isAvailable = value;
    notifyListeners();
    return null;
  }

  // ── Order actions ─────────────────────────────────────────────────────────

  Future<String?> acceptOrder(Order order) async {
    if (!_isAvailable) {
      return 'أنت غير متاح حالياً. لا يمكنك قبول الطلب.';
    }
    final error = _store.acceptOrder(order.id, _user);
    if (error == null) {
      _currentTab = 2; // Switch to Orders tab
      notifyListeners();
      // Start publishing GPS to Supabase driver_locations.
      await _publisher.start(order.id);
    }
    return error;
  }

  Future<void> completeOrder(Order order) async {
    _store.completeOrder(order);
    await _publisher.stop();
  }

  /// Move a collectionSale to inTransit. Returns error string or null.
  String? startCollectionSaleTransit(String saleId) =>
      _store.markCollectionSaleInTransit(saleId);

  /// Complete a collectionSale. [actualWeightKg] used for per-kg payment calculation.
  String? completeCollectionSale(String saleId, {double? actualWeightKg}) =>
      _store.completeCollectionSale(saleId, actualWeightKg: actualWeightKg);

  /// Cancel a pending collectionSale. Silently ignored if inTransit/completed.
  void cancelCollectionSale(String saleId) =>
      _store.cancelCollectionSale(saleId);

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
    final orderId = 'DRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final order = Order(
      id: orderId,
      type: OrderType.pickup,
      wasteTypes: wasteTypes,
      pickupAddress: pickupAddress,
      dropoffAddress: 'منشأة التدوير',
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
    );
    notifyListeners();
    return order;
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  void updateVehicleInfo({
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
    String? vehiclePhotoPath,
  }) {
    _user = _user.copyWith(
      vehicleModel: vehicleModel,
      vehicleColor: vehicleColor,
      licensePlate: licensePlate,
      vehiclePhotoPath: vehiclePhotoPath,
    );
    notifyListeners();
  }
}
