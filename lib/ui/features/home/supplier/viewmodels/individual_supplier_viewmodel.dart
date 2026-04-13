import 'package:flutter/material.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/services/app_order_store.dart';

class IndividualSupplierViewModel extends ChangeNotifier {
  final AppOrderStore _store;

  IndividualSupplierViewModel(this._store) {
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

  User _user = const User(
    id: 'SUP-IND-001',
    name: 'مورد دوّر',
    role: 'مورد فردي',
    phone: '+962 79 XXX XXXX',
    address: 'شارع الجامعة، عمّان',
    points: 120,
    totalOrders: 18,
    isVerified: true,
  );

  // ── Getters ───────────────────────────────────────────────────────────────

  int get currentTab => _currentTab;
  User get user => _user;

  List<Order> get orders => _store.supplierOrdersFor(_user.name);

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
      .where(
          (o) => o.status == OrderStatus.inTransit && o.driverName != null)
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
      );

  Order createListing({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    List<String> images = const [],
    String? notes,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    double? itemPrice,
  }) {
    final orderId = 'IND-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final order = Order(
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
    );
    notifyListeners();
    return order;
  }

  String? cancelOrder(String orderId) => _store.cancelOrder(orderId);

  // Called when supplier purchases a marketplace item
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
