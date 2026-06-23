import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../../data/models/driver_wallet.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../../../../data/services/location_publisher.dart';
import '../../../../../data/services/location_service.dart';
import '../../../../../data/services/proximity_service.dart';
import '../../../../../domain/repositories/i_wallet_repository.dart';
import '../../../../../domain/services/i_location_publisher.dart';

class DriverHomeViewModel extends ChangeNotifier {
  final AppOrderStore _store;
  final ILocationPublisher _publisher;
  final IWalletRepository _walletRepo;
  final LocationService _locationService;

  // Ghost timer: fires if driver doesn't reach pickup geofence within 15 min.
  Timer? _ghostTimer;
  // Arrival response timer: fires if supplier doesn't respond within 5 min.
  Timer? _arrivalResponseTimer;

  DriverHomeViewModel(
    this._store, {
    ILocationPublisher? publisher,
    LocationService? locationService,
    IWalletRepository? walletRepo,
  })  : _publisher = publisher ?? LocationPublisher.instance,
        _locationService = locationService ?? LocationService(),
        _walletRepo = walletRepo ?? const NoOpWalletRepository() {
    _store.addListener(_onStoreChanged);
    _refreshWallet();
  }

  @override
  void dispose() {
    _ghostTimer?.cancel();
    _arrivalResponseTimer?.cancel();
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => notifyListeners();

  // ── Local state ───────────────────────────────────────────────────────────

  int _currentTab = 0;
  bool _isAvailable = true;
  DriverWallet _wallet = DriverWallet.zero;

  DriverWallet get wallet => _wallet;

  Future<void> _refreshWallet() async {
    final result = await _walletRepo.getWallet();
    result.fold(
      onSuccess: (w) {
        _wallet = w;
        notifyListeners();
      },
      onFailure: (_) {},
    );
  }

  User _user = const User(
    id: 'DRV-19842',
    name: 'سائق دوّر',
    role: 'سائق',
    rating: 4.8,
    vehicleType: VehicleType.pickup,
  );

  // ── Getters (delegated to store) ──────────────────────────────────────────

  int get currentTab => _currentTab;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _store.isLoading;
  User get user => _user;

  List<Order> get available => _store.driverFeedFor(
        vehicleType: _user.vehicleType,
        hasChemicalPermit: _user.hasChemicalPermit,
      );
  Order? get active => _store.driverActiveOrder;
  bool get hasActiveTrip => active != null;
  OrderStatus? get activeTripStatus => active?.status;
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
      _currentTab = 2;
      notifyListeners();
      await _publisher.start(order.id);
      _startGhostTimer(order.id);
    }
    return error;
  }

  /// Called after PickupProofView collects weight + photo.
  /// Client GPS provides instant UX feedback; the Edge Function is the
  /// authoritative server-side gate (reads Supabase driver_locations).
  Future<String?> markArrivedAtPickup(Order order, {OrderProof? pickupProof}) async {
    final pos = await _locationService.getCurrentLocation();
    if (pos == null) return 'تعذّر تحديد موقعك. تحقق من صلاحية الموقع.';

    if (order.pickupLat == null || order.pickupLng == null) {
      _store.markArrivedAtPickup(order.id, pickupProof: pickupProof);
      _cancelGhostTimer();
      _startArrivalResponseTimer(order.id);
      return null;
    }

    // Fast client-side preflight — avoids an Edge Function round-trip when
    // the driver is clearly nowhere near the geofence.
    final clientDist = ProximityService.distanceMeters(
      pos.lat, pos.lng, order.pickupLat!, order.pickupLng!,
    );
    if (clientDist > ProximityService.pickupRadiusMeters * 3) {
      _store.recordFraudAttempt(order.id);
      return 'أنت بعيد جداً عن الموقع (${clientDist.round()} م). يجب أن تكون ضمن 200 م.';
    }

    // Server-side gate: reads the GPS row that LocationPublisher streamed.
    final serverResult = await _verifyArrivalServerSide(
      orderId: order.id,
      targetLat: order.pickupLat!,
      targetLng: order.pickupLng!,
    );
    if (serverResult != null) return serverResult;

    _store.markArrivedAtPickup(order.id, pickupProof: pickupProof);
    _cancelGhostTimer();
    _startArrivalResponseTimer(order.id);
    return null;
  }

  /// Supplier confirmed availability — clear timer, advance to inTransit.
  void handleSupplierAvailable(Order order) {
    _arrivalResponseTimer?.cancel();
    _arrivalResponseTimer = null;
    _store.handleSupplierAvailable(order.id);
  }

  /// Supplier pressed "Not Available" — clear timer, cancel with compensation.
  void handleSupplierUnavailable(Order order) {
    _arrivalResponseTimer?.cancel();
    _arrivalResponseTimer = null;
    _store.handleSupplierUnavailable(order.id);
    _publisher.stop();
  }

  /// Called when driver taps "I'm Here" at the dropoff location.
  Future<String?> markArrivedAtDropoff(Order order) async {
    final pos = await _locationService.getCurrentLocation();
    if (pos == null) return 'تعذّر تحديد موقعك. تحقق من صلاحية الموقع.';

    if (order.dropoffLat == null || order.dropoffLng == null) {
      _store.markArrivedAtDropoff(order.id);
      return null;
    }

    final clientDist = ProximityService.distanceMeters(
      pos.lat, pos.lng, order.dropoffLat!, order.dropoffLng!,
    );
    if (clientDist > ProximityService.dropoffRadiusMeters * 3) {
      _store.recordFraudAttempt(order.id);
      return 'أنت بعيد جداً عن موقع التسليم (${clientDist.round()} م). يجب أن تكون ضمن 200 م.';
    }

    final serverResult = await _verifyArrivalServerSide(
      orderId: order.id,
      targetLat: order.dropoffLat!,
      targetLng: order.dropoffLng!,
    );
    if (serverResult != null) return serverResult;

    _store.markArrivedAtDropoff(order.id);
    return null;
  }

  // ── Edge Function call ────────────────────────────────────────────────────

  /// Calls the verifyArrival method on store. Returns an error string if the
  /// server rejects the attempt, null if allowed. On network failure, returns
  /// null (graceful degradation — client-side preflight already passed).
  Future<String?> _verifyArrivalServerSide({
    required String orderId,
    required double targetLat,
    required double targetLng,
  }) async {
    final res = await _store.verifyArrival(orderId, targetLat, targetLng);
    return res.fold(
      onSuccess: (allowed) {
        if (!allowed) {
          _store.recordFraudAttempt(orderId);
          return 'التحقق من الموقع فشل على الخادم. يجب أن تكون ضمن 200 م.';
        }
        return null;
      },
      onFailure: (failure) {
        debugPrint('[verify_arrival] error: ${failure.message} — falling back to client check');
        return null;
      },
    );
  }

  Future<void> completeOrder(Order order) async {
    // Time-anomaly check: flag suspiciously fast completions.
    final accepted = order.acceptedAt;
    final dist = order.distanceKm;
    if (accepted != null && dist != null && dist > 0) {
      final elapsed = DateTime.now().difference(accepted).inSeconds;
      final minimum = ProximityService.minimumTravelSeconds(dist);
      if (elapsed < minimum) {
        _store.recordFraudAttempt(order.id);
      }
    }
    _store.completeOrder(order);
    await _publisher.stop();
    unawaited(_refreshWallet());
  }

  // ── Timer helpers ─────────────────────────────────────────────────────────

  void _startGhostTimer(String orderId) {
    _ghostTimer?.cancel();
    _ghostTimer = Timer(
      const Duration(minutes: 15),
      () {
        final active = _store.driverActiveOrder;
        if (active?.id == orderId &&
            active?.status == OrderStatus.accepted) {
          _store.cancelForNoShow(orderId);
          _publisher.stop();
        }
      },
    );
  }

  void _cancelGhostTimer() {
    _ghostTimer?.cancel();
    _ghostTimer = null;
  }

  void _startArrivalResponseTimer(String orderId) {
    _arrivalResponseTimer?.cancel();
    _arrivalResponseTimer = Timer(
      const Duration(minutes: 5),
      () => _store.handleArrivalTimeout(orderId),
    );
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
    final hasChemicals = wasteTypes.contains(WasteType.chemicals);
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
      expiresAt: DateTime.now().add(const Duration(days: 14)),
      adminApprovalStatus: hasChemicals
          ? AdminApprovalStatus.pendingApproval
          : AdminApprovalStatus.notRequired,
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
    VehicleType? vehicleType,
  }) {
    _user = _user.copyWith(
      vehicleModel: vehicleModel,
      vehicleColor: vehicleColor,
      licensePlate: licensePlate,
      vehiclePhotoPath: vehiclePhotoPath,
      vehicleType: vehicleType ?? _user.vehicleType,
    );
    notifyListeners();
  }
}
