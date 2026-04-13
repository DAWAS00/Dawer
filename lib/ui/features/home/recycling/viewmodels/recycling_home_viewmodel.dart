import 'package:flutter/material.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/services/app_order_store.dart';

class RecyclingHomeViewModel extends ChangeNotifier {
  final AppOrderStore _store;

  RecyclingHomeViewModel(this._store) {
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
  bool _isOpen = true;

  User _company = const User(
    id: 'REC-4820',
    name: 'شركة دوّر للتدوير',
    role: 'recyclingCo',
    phone: '+962 6 XXX XXXX',
    address: 'عمّان، الزرقاء، إربد',
    isVerified: true,
    points: 0,
    totalOrders: 234,
    rating: 4.9,
  );

  String _serviceArea = 'عمّان، الزرقاء، إربد';
  String _email = 'info@dawwar-recycle.jo';
  String _workingHours = '٧:٠٠ ص - ٥:٠٠ م';
  final String _licenseNumber = 'RC-2024-00482';

  // ── Getters (delegated to store) ──────────────────────────────────────────

  int get currentTab => _currentTab;
  bool get isOpen => _isOpen;
  User get company => _company;
  String get companyName => _company.name;
  String get serviceArea => _serviceArea;
  String get email => _email;
  String get workingHours => _workingHours;
  String get licenseNumber => _licenseNumber;

  List<Order> get incoming => _store.companyIncoming;
  List<Order> get jobs => _store.companyJobs;

  // ── Computed stats ────────────────────────────────────────────────────────

  int get totalShipments => _company.totalOrders;

  double get totalWeightProcessed =>
      incoming.fold<double>(0, (sum, o) => sum + (o.weightKg ?? 0)) +
      12400;

  int get activeJobs => jobs
      .where((j) =>
          j.status == OrderStatus.pending ||
          j.status == OrderStatus.inTransit)
      .length;

  int get driversInProgress =>
      incoming.where((o) => o.status == OrderStatus.inTransit).length;

  // ── Tab navigation ────────────────────────────────────────────────────────

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  void toggleOpen(bool value) {
    _isOpen = value;
    notifyListeners();
  }

  // ── Order actions ─────────────────────────────────────────────────────────

  /// Post a new collection job — fixed: order is now added to the store.
  Order createListing({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    List<String> images = const [],
    String? notes,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    double reward = 0,
    double? itemPrice,
  }) =>
      _store.createCollectionJob(
        wasteTypes: wasteTypes,
        pickupAddress: pickupAddress,
        companyName: companyName,
        notes: notes,
        wasteForm: wasteForm,
        weightCategory: weightCategory,
        reward: reward,
        itemPrice: itemPrice,
      );

  // ── Profile ───────────────────────────────────────────────────────────────

  void updateProfile({
    String? name,
    String? phone,
    String? serviceArea,
    String? email,
    String? workingHours,
  }) {
    _company = _company.copyWith(name: name, phone: phone);
    if (serviceArea != null) _serviceArea = serviceArea;
    if (email != null) _email = email;
    if (workingHours != null) _workingHours = workingHours;
    notifyListeners();
  }
}
