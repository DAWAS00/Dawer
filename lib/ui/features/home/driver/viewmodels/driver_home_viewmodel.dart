import 'package:flutter/material.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/services/app_order_store.dart';

class DriverHomeViewModel extends ChangeNotifier {
  final AppOrderStore _store;

  DriverHomeViewModel(this._store) {
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
    phone: '+962 79 XXX XXXX',
    rating: 4.8,
  );

  // ── Getters (delegated to store) ──────────────────────────────────────────

  int get currentTab => _currentTab;
  bool get isAvailable => _isAvailable;
  User get user => _user;

  List<Order> get available => _store.driverFeed;
  Order? get active => _store.driverActiveOrder;
  List<Order> get history => _store.driverHistory;

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

  String? acceptOrder(Order order) {
    if (!_isAvailable) {
      return 'أنت غير متاح حالياً. لا يمكنك قبول الطلب.';
    }
    final error = _store.acceptOrder(order.id, _user);
    if (error == null) {
      _currentTab = 2; // Switch to Orders tab
      notifyListeners();
    }
    return error;
  }

  void completeOrder(Order order) {
    _store.completeOrder(order);
  }

  Order createListing({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    List<String> images = const [],
    String? notes,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    double? itemPrice,
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
