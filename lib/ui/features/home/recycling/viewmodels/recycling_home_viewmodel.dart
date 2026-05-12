import 'package:flutter/material.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/models/user_role.dart';
import '../../../../../data/services/app_order_store.dart';

class RecyclingHomeViewModel extends ChangeNotifier {
  final AppOrderStore _store;
  late User _company;

  RecyclingHomeViewModel(this._store, {String? userName}) {
    _company = User(
      id: 'REC-${DateTime.now().millisecondsSinceEpoch}',
      name: userName ?? 'شركة دوّر للتدوير',
      role: UserRole.recyclingCo,
      address: 'عمّان، الزرقاء، إربد',
      isVerified: true,
      points: 0,
      totalOrders: 234,
      rating: 4.9,
    );
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
  List<Order> get completedOrders =>
      incoming.where((o) => o.status == OrderStatus.completed).toList();

  /// All collectionSale orders linked to this company's jobs.
  /// Used to show who accepted which job and their status.
  List<Order> get jobSales => _store.salesForCompanyJobs(_company.name);

  /// Sales for one specific job by job ID.
  List<Order> salesForJob(String jobId) =>
      jobSales.where((s) => s.linkedJobId == jobId).toList();

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
    double? pickupLat,
    double? pickupLng,
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

  /// Post a paid collection job to the marketplace.
  Order postCollectionJob({
    required List<WasteType> wasteTypes,
    required String collectionArea,
    required String jobDescription,
    required PaymentModel paymentModel,
    required double price,
    double? minQuantityKg,
  }) =>
      _store.createCollectionJob(
        wasteTypes: wasteTypes,
        pickupAddress: collectionArea,
        companyName: companyName,
        jobDescription: jobDescription,
        paymentModel: paymentModel,
        pricePerKg: paymentModel == PaymentModel.perKg ? price : null,
        itemPrice: paymentModel == PaymentModel.flatFee ? price : null,
        minQuantityKg: minQuantityKg,
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
