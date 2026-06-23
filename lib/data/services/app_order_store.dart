import 'dart:async';
import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import '../../backend_integration_locally/local_store.dart';
import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../domain/repositories/i_wallet_repository.dart';
import '../../domain/requests/create_pickup_request.dart';
import '../mock/order_mock_data.dart';
import '../models/order/order.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import 'reward_service.dart';

/// Singleton shared order store — the single source of truth for all orders
/// across Driver, Supplier, and Recycling Company roles.
///
/// Provided at app root via [ChangeNotifierProvider]. All three home-view VMs
/// accept this store in their constructor and addListener to it so their own
/// [notifyListeners] fires whenever the store changes.
class AppOrderStore extends ChangeNotifier {
  AppOrderStore({
    LocalStore? store,
    IOrderRepository? remote,
    IWalletRepository? wallet,
    RewardService? rewardService,
    bool skipMockSeed = false,
  })  : _store = store,
        _remote = remote ?? const NoOpOrderRepository(),
        _wallet = wallet ?? const NoOpWalletRepository(),
        _rewardService = rewardService ?? RewardService(),
        _skipMockSeed = skipMockSeed {
    _bootstrap();
  }

  final LocalStore? _store;
  final IOrderRepository _remote;
  final IWalletRepository _wallet;
  final RewardService _rewardService;
  final bool _skipMockSeed;
  StreamSubscription<List<Order>>? _remoteSub;

  // ── Error state ───────────────────────────────────────────────────────────

  AppFailure? get lastError => _lastError;

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────────────

  /// All regular orders — pickup requests (from suppliers) and collection jobs
  /// (posted by recycling companies). This is the canonical list.
  late List<Order> _orders;
  List<Order> get orders => List.unmodifiable(_orders);


  /// ID of the order currently active for our mock driver session.
  String? _activeOrderId;

  /// IDs of orders completed by our mock driver (their personal history).
  final List<String> _driverCompletedIds = ['ORD-H01', 'ORD-H02'];

  /// True until the first bootstrap completes. Used by home tabs to show skeleton UI.
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// Last error captured by [_safeSupabaseInsert].
  AppFailure? _lastError;

  // ─────────────────────────────────────────────────────────────────────────
  // Bootstrap & persistence
  // ─────────────────────────────────────────────────────────────────────────

  void _bootstrap() {
    final store = _store;

    if (_skipMockSeed) {
      // Live Supabase: start empty; realtime subscription fills _orders.
      _orders = [];
    } else if (store == null || store.isFirstLaunch) {
      _orders = [...OrderMockData.seedOrders(), ...OrderMockData.seedMarketItems()];
      store?.writeOrders(_orders.map((o) => o.toJson()).toList());
      store?.markFirstLaunchDone();
    } else {
      _orders = store.readOrders().map((e) => Order.fromJson(e)).toList();
      final oldMarket = store.readMarket().map((e) => Order.fromJson(e)).toList();
      for (final m in oldMarket) {
        if (!_orders.any((o) => o.id == m.id)) {
          _orders.add(m.copyWith(isMarketplaceShared: true));
        }
      }
    }

    // Flip loading flag after one microtask so the UI renders one skeleton frame.
    Future.microtask(() {
      _isLoading = false;
      notifyListeners();
    });

    // Subscribe to remote order updates. The default NoOpOrderRepository
    // emits nothing, so seed-only / test paths are unaffected.
    _remoteSub = _remote.watchOrders().listen(
      (remoteOrders) {
        if (remoteOrders.isEmpty) return;
        for (final o in remoteOrders) {
          final idx = _orders.indexWhere((existing) => existing.id == o.id);
          if (idx >= 0) {
            _orders[idx] = o;
          } else {
            _orders.insert(0, o);
          }
        }
        notifyListeners();
      },
      onError: (Object e) =>
          debugPrint('Remote order stream error: $e'),
    );
  }

  @override
  void dispose() {
    _remoteSub?.cancel();
    super.dispose();
  }

  /// Re-subscribe the remote stream using a role-scoped filter.
  /// Call this once from [HomeRouter] after the user's session is established.
  void configureForUser(String userId, UserRole role) {
    _remoteSub?.cancel();
    _remoteSub = _remote.watchOrdersForUser(userId, role).listen(
      (remoteOrders) {
        if (remoteOrders.isEmpty) return;
        for (final o in remoteOrders) {
          final idx = _orders.indexWhere((existing) => existing.id == o.id);
          if (idx >= 0) {
            _orders[idx] = o;
          } else {
            _orders.insert(0, o);
          }
        }
        notifyListeners();
      },
      onError: (Object e) => debugPrint('Remote order stream error: $e'),
    );
  }

  Future<void> _persistOrders() async {
    final store = _store;
    if (store == null) return;
    await store.writeOrders(_orders.map((o) => o.toJson()).toList());
  }


  @override
  void notifyListeners() {
      // Auto-persist on every mutation. Fire-and-forget — a write failure does
    // not block UI updates.
    // ignore: discarded_futures
    _persistOrders();
    super.notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Driver views
  // ─────────────────────────────────────────────────────────────────────────

  /// Pending orders filtered to only those the driver's vehicle can handle.
  /// Pass [vehicleType] from the driver's profile; null returns all pending orders.
  List<Order> driverFeedFor({
    VehicleType? vehicleType,
    bool hasChemicalPermit = false,
  }) {
    return _orders.where((o) {
      final statusOk =
          o.status == OrderStatus.pending ||
          (o.status == OrderStatus.accepted &&
              o.requiresRider &&
              o.driverName == null);
      if (!statusOk || o.id == _activeOrderId) return false;
      if (o.adminApprovalStatus == AdminApprovalStatus.pendingApproval ||
          o.adminApprovalStatus == AdminApprovalStatus.rejected) {
        return false;
      }
      if (vehicleType == null) return true;
      return vehicleType.canTakeOrder(
        o,
        hasChemicalPermit: hasChemicalPermit,
      );
    }).toList();
  }

  /// The driver's currently active order (null when not on a trip).
  Order? get driverActiveOrder => _activeOrderId == null
      ? null
      : _orders.where((o) => o.id == _activeOrderId).firstOrNull;

  /// Orders the driver has completed in this session (+ seed history).
  List<Order> get driverHistory => _orders
      .where((o) => _driverCompletedIds.contains(o.id))
      .toList();

  bool get driverHasActiveOrder => _activeOrderId != null;

  // ─────────────────────────────────────────────────────────────────────────
  // Supplier views
  // ─────────────────────────────────────────────────────────────────────────

  /// All orders submitted by a specific supplier (by name, mock/offline only).
  List<Order> supplierOrdersFor(String supplierName) => _orders
      .where((o) =>
          o.supplierName == supplierName && o.type == OrderType.pickup)
      .toList();

  /// All orders submitted by a supplier identified by their auth ID (live mode).
  List<Order> supplierOrdersForId(String userId) => _orders
      .where((o) => o.type == OrderType.pickup && o.supplierId == userId)
      .toList();

  // ─────────────────────────────────────────────────────────────────────────
  // Recycling Company views
  // ─────────────────────────────────────────────────────────────────────────

  /// Pickup orders heading to the company (any active delivery state).
  List<Order> get companyIncoming => _orders
      .where((o) =>
          o.type == OrderType.pickup &&
          (o.status == OrderStatus.accepted ||
              o.status == OrderStatus.arrivedAtPickup ||
              o.status == OrderStatus.inTransit ||
              o.status == OrderStatus.arrivedAtDropoff))
      .toList();

  /// Collection jobs posted by the company.
  List<Order> get companyJobs =>
      _orders.where((o) => o.type == OrderType.collection).toList();

  // ─────────────────────────────────────────────────────────────────────────
  // Marketplace views
  // ─────────────────────────────────────────────────────────────────────────

  List<Order> get marketItems {
    final now = DateTime.now();
    return List.unmodifiable(_orders.where((o) =>
        o.isMarketplaceShared &&
        (o.expiresAt == null || o.expiresAt!.isAfter(now)) &&
        o.adminApprovalStatus != AdminApprovalStatus.pendingApproval &&
        o.adminApprovalStatus != AdminApprovalStatus.rejected));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Driver actions
  // ─────────────────────────────────────────────────────────────────────────

  /// Accept an available order. Returns an error string on failure.
  String? acceptOrder(String orderId, User driver) {
    if (_activeOrderId != null) {
      return 'لا يمكنك قبول طلب جديد. يرجى إتمام الطلب الحالي أولاً.';
    }
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return 'الطلب غير موجود';
    final order = _orders[idx];
    
    final canAccept = order.status == OrderStatus.pending ||
        (order.status == OrderStatus.accepted && order.requiresRider && order.driverName == null);
    if (!canAccept) return 'هذا الطلب لم يعد متاحاً';

    _orders[idx] = order.copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      eta: 'جاري الحساب...',
      driverName: driver.name,
      driverPhone: driver.phone,
      driverRating: driver.rating,
      driverVehicle: driver.vehicleModel,
      driverVehicleModel: driver.vehicleModel,
      driverVehicleColor: driver.vehicleColor,
      driverLicensePlate: driver.licensePlate,
      driverVehiclePhotoPath: driver.vehiclePhotoPath,
    );
    _activeOrderId = orderId;
    notifyListeners();

    unawaited(_pushRemote(_remote.markAccepted(orderId)));
    if (order.reward > 0) {
      unawaited(_wallet.holdForOrder(orderId, order.reward));
    }
    return null;
  }

  /// Assign a specific driver to an order (supplier action).
  void assignDriver(String orderId, User driver) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      driverName: driver.name,
      driverPhone: driver.phone,
      driverRating: driver.rating,
      driverVehicle: driver.vehicleModel,
      driverVehicleModel: driver.vehicleModel,
      driverVehicleColor: driver.vehicleColor,
      driverLicensePlate: driver.licensePlate,
      driverVehiclePhotoPath: driver.vehiclePhotoPath,
    );
    notifyListeners();

    unawaited(_pushRemote(_remote.assignDriver(orderId, driver.id)));
  }

  /// Mark the active order as in-transit (driver en-route to dropoff).
  void markInTransit(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(
      status: OrderStatus.inTransit,
      inTransitAt: DateTime.now(),
    );
    notifyListeners();

    unawaited(_pushRemote(_remote.markInTransit(orderId)));
  }

  /// Driver entered the 200m pickup geofence (server-verified). Sends customer
  /// notification and starts the 5-minute response window.
  void markArrivedAtPickup(String orderId, {OrderProof? pickupProof}) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(
      status: OrderStatus.arrivedAtPickup,
      arrivedAtPickupAt: DateTime.now(),
      arrivalConfirmationStatus: ArrivalConfirmationStatus.awaiting,
      pickupProof: pickupProof,
    );
    notifyListeners();
    unawaited(_pushRemote(_remote.markArrivedAtPickup(orderId, pickupProof: pickupProof)));
  }

  /// Supplier confirmed they are available. Advance order to inTransit.
  void handleSupplierAvailable(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(
      status: OrderStatus.inTransit,
      inTransitAt: DateTime.now(),
      arrivalConfirmationStatus: ArrivalConfirmationStatus.confirmed,
    );
    notifyListeners();
    unawaited(_pushRemote(_remote.markInTransit(orderId)));
  }

  /// Supplier pressed "Not Available". Cancel with base trip compensation.
  void handleSupplierUnavailable(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final order = _orders[idx];
    // Driver gets 25% of reward for making the trip; supplier is charged this.
    final compensation = (order.reward * 0.25).clamp(0.5, 5.0);
    _orders[idx] = order.copyWith(
      status: OrderStatus.cancelled,
      arrivalConfirmationStatus: ArrivalConfirmationStatus.unavailable,
      driverCompensationAmount: compensation,
    );
    if (_activeOrderId == orderId) _activeOrderId = null;
    notifyListeners();
    unawaited(_pushRemote(_remote.markCancelled(orderId)));
  }

  /// 5-minute response window expired with no customer action. Driver gets 50%
  /// as a penalty charge from the supplier's hold (not a refund).
  void handleArrivalTimeout(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final order = _orders[idx];
    if (order.status != OrderStatus.arrivedAtPickup) return;
    final compensation = (order.reward * 0.50).clamp(1.0, 10.0);
    _orders[idx] = order.copyWith(
      status: OrderStatus.cancelled,
      arrivalConfirmationStatus: ArrivalConfirmationStatus.timedOut,
      driverCompensationAmount: compensation,
    );
    if (_activeOrderId == orderId) _activeOrderId = null;
    notifyListeners();
    unawaited(_pushRemote(_remote.markCancelled(orderId)));
  }

  /// Driver entered the 200m dropoff geofence (server-verified).
  void markArrivedAtDropoff(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(
      status: OrderStatus.arrivedAtDropoff,
      arrivedAtDropoffAt: DateTime.now(),
    );
    notifyListeners();
    unawaited(_pushRemote(_remote.markArrivedAtDropoff(orderId)));
  }

  /// Record a blocked fraud attempt (driver tried to mark arrived while >200m away).
  void recordFraudAttempt(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(
      fraudAttemptCount: _orders[idx].fraudAttemptCount + 1,
    );
    notifyListeners();
  }

  /// Cancel the active order due to driver no-show (ghost timer fired).
  void cancelForNoShow(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(status: OrderStatus.cancelled);
    if (_activeOrderId == orderId) _activeOrderId = null;
    notifyListeners();
    unawaited(_pushRemote(_remote.markCancelled(orderId)));
  }

  /// Verify driver arrival at destination.
  Future<AppResult<bool>> verifyArrival(String orderId, double lat, double lng) async {
    return _remote.verifyArrival(orderId, lat, lng);
  }

  /// Complete the active order (driver marks delivered).
  void completeOrder(Order completedOrder) {
    final idx = _orders.indexWhere((o) => o.id == completedOrder.id);
    if (idx == -1) return;
    _orders[idx] = completedOrder.copyWith(
      status: OrderStatus.completed,
      completedAt: DateTime.now(),
    );
    if (_activeOrderId == completedOrder.id) {
      _driverCompletedIds.add(completedOrder.id);
      _activeOrderId = null;
    }
    notifyListeners();

    unawaited(_pushRemote(_remote.markCompleted(completedOrder.id, actualWeightKg: completedOrder.weightKg)));
    unawaited(_recordTransactionFor(completedOrder));
    if (completedOrder.reward > 0) {
      unawaited(_wallet.releaseForOrder(completedOrder.id, completedOrder.reward));
    }
  }

  Future<void> _recordTransactionFor(Order order) async {
    if (order.wasteTypes.isEmpty || order.distanceKm == null) return;

    final result = await _rewardService.calculate(
      wasteTypes: order.wasteTypes,
      estimatedWeightKg: order.estimatedWeightKg ?? 0,
      distanceKm: order.distanceKm!,
      actualWeightKg: order.weightKg,
      vehicleType: order.requiredVehicleType ?? VehicleType.pickup,
    );

    result.fold(
      onSuccess: (breakdown) => unawaited(_pushRemote(_remote.recordTransaction(
        orderId: order.id,
        breakdown: breakdown,
        vehicleType: order.requiredVehicleType?.name,
      ))),
      onFailure: (_) {},
    );
  }

  /// Record a driver rating after delivery (mock — updates driverRating on order).
  void submitDriverRating(String orderId, double rating) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(driverRating: rating);
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Supplier actions
  // ─────────────────────────────────────────────────────────────────────────

  /// Create a new pickup request (supplier posts waste for collection).
  Order createPickupRequest({
    required List<WasteType> wasteTypes,
    required String supplierName,
    String pickupAddress = 'عنواني الحالي',
    String dropoffAddress = 'أقرب مركز تدوير',
    String? notes,
    List<String> images = const [],
    double? estimatedWeightKg,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    PickupTarget? pickupTarget,
    double? itemPrice,
    DateTime? scheduledAt,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
  }) {
    final orderId = _uuid();
    final fee = _calculateFee(weightCategory);
    final hasChemicals = wasteTypes.contains(WasteType.chemicals);
    final order = Order(
      id: orderId,
      type: OrderType.pickup,
      wasteTypes: wasteTypes,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      status: OrderStatus.pending,
      reward: 0,
      createdAt: DateTime.now(),
      supplierName: supplierName,
      supplierNotes: notes,
      images: images,
      estimatedWeightKg: estimatedWeightKg,
      wasteForm: wasteForm,
      weightCategory: weightCategory,
      deliveryFee: fee,
      pickupTarget: pickupTarget,
      itemPrice: itemPrice,
      scheduledAt: scheduledAt,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      adminApprovalStatus: hasChemicals
          ? AdminApprovalStatus.pendingApproval
          : AdminApprovalStatus.notRequired,
    );
    _orders.insert(0, order);
    notifyListeners();

    unawaited(_pushRemote(_remote.insertOrder(order)));
    return order;
  }

  /// Domain-layer entry point for creating a pickup request.
  /// Wraps [createPickupRequest] and returns an [AppResult] so callers can
  /// fold success/failure without try-catch at the call site.
  AppResult<Order> submitPickupRequest(
    CreatePickupRequest request, {
    required String supplierName,
  }) {
    try {
      final order = createPickupRequest(
        wasteTypes: request.wasteTypes,
        supplierName: supplierName,
        pickupAddress: request.pickupAddress,
        notes: request.notes,
        images: request.images,
        estimatedWeightKg: request.estimatedWeightKg,
        wasteForm: request.wasteForm,
        weightCategory: request.weightCategory,
        pickupTarget: request.pickupTarget,
        itemPrice: request.itemPrice,
        scheduledAt: request.scheduledAt,
        pickupLat: request.pickupLat,
        pickupLng: request.pickupLng,
        dropoffLat: request.dropoffLat,
        dropoffLng: request.dropoffLng,
      );
      return Success(order);
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  /// Cancel a pending order.
  String? cancelOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return 'الطلب غير موجود';
    final order = _orders[idx];
    if (order.status != OrderStatus.pending) {
      return 'لا يمكن إلغاء هذا الطلب لأنه قيد التنفيذ بالفعل';
    }
    _orders[idx] = order.copyWith(status: OrderStatus.cancelled);
    notifyListeners();

    unawaited(_pushRemote(_remote.markCancelled(orderId)));
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Company actions
  // ─────────────────────────────────────────────────────────────────────────

  /// Post a new collection job (company requests material pickup).
  Order createCollectionJob({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    required String companyName,
    String dropoffAddress = 'منشأة التدوير',
    String? notes,
    List<String> images = const [],
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    double reward = 0,
    double? itemPrice,
    String? jobDescription,
    double? pricePerKg,
    PaymentModel? paymentModel,
    double? minQuantityKg,
    double? pickupLat,
    double? pickupLng,
    DateTime? expiresAt,
  }) {
    final orderId = _uuid();
    final order = Order(
      id: orderId,
      type: OrderType.collection,
      wasteTypes: wasteTypes,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      status: OrderStatus.pending,
      reward: reward,
      createdAt: DateTime.now(),
      supplierName: companyName,
      supplierNotes: notes,
      images: images,
      wasteForm: wasteForm,
      weightCategory: weightCategory,
      jobDescription: jobDescription,
      pricePerKg: pricePerKg,
      paymentModel: paymentModel,
      minQuantityKg: minQuantityKg,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      expiresAt: expiresAt,
    );
    _orders.insert(0, order);
    notifyListeners();

    unawaited(_pushRemote(_remote.insertOrder(order)));
    return order;
  }

  /// Pending collection jobs — for marketplace display (all roles).
  List<Order> get pendingCollectionJobs => _orders
      .where((o) =>
          o.type == OrderType.collection && o.status == OrderStatus.pending)
      .toList();

  /// Active collection jobs posted by a specific company.
  List<Order> myCollectionJobs(String companyName) => _orders
      .where((o) =>
          o.type == OrderType.collection &&
          o.supplierName == companyName &&
          (o.status == OrderStatus.pending || o.status == OrderStatus.accepted))
      .toList();

  /// Driver claims a collection job (does NOT set _activeOrderId — different flow).
  String? claimCollectionJob(String jobId, User driver) {
    final idx = _orders.indexWhere((o) => o.id == jobId);
    if (idx == -1) return 'الوظيفة غير موجودة';
    final job = _orders[idx];
    if (job.status != OrderStatus.pending) return 'هذه الوظيفة لم تعد متاحة';
    _orders[idx] = job.copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      driverName: driver.name,
      driverPhone: driver.phone,
    );
    notifyListeners();

    unawaited(_pushRemote(_remote.markAccepted(jobId)));
    return null;
  }

  /// Edit a collection job in place (company owner only). Sets isEdited flag.
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
  }) {
    final idx = _orders.indexWhere((o) => o.id == jobId);
    if (idx == -1) return null;
    final job = _orders[idx];
    if (job.supplierName != companyName || job.type != OrderType.collection) {
      return null;
    }
    _orders[idx] = job.copyWith(
      wasteTypes: wasteTypes,
      pickupAddress: collectionArea,
      jobDescription: jobDescription,
      paymentModel: paymentModel,
      pricePerKg: paymentModel == PaymentModel.perKg ? price : null,
      itemPrice: paymentModel == PaymentModel.flatFee ? price : null,
      minQuantityKg: minQuantityKg,
      isEdited: true,
      editedAt: DateTime.now(),
      editNote: editNote,
    );
    notifyListeners();

    unawaited(_pushRemote(_remote.updateOrder(_orders[idx])));
    return _orders[idx];
  }

  /// Delete a collection job (company owner only, pending status).
  bool deleteCollectionJob(String jobId, String companyName) {
    final idx = _orders.indexWhere((o) => o.id == jobId);
    if (idx == -1) return false;
    final job = _orders[idx];
    if (job.supplierName != companyName || job.type != OrderType.collection) {
      return false;
    }
    _orders.removeAt(idx);
    notifyListeners();

    unawaited(_pushRemote(_remote.deleteOrder(jobId)));
    return true;
  }

  /// Look up a single collection job by ID.
  Order? getCollectionJob(String jobId) => _orders
      .where((o) => o.id == jobId && o.type == OrderType.collection)
      .firstOrNull;

  /// True if [acceptorName] already committed to [jobId].
  bool hasAcceptedJob(String jobId, String acceptorName) => _orders.any(
        (o) =>
            o.type == OrderType.collectionSale &&
            o.linkedJobId == jobId &&
            o.supplierName == acceptorName,
      );

  /// All collection-sale commitments created by [acceptorName].
  List<Order> collectionSalesFor(String acceptorName) => _orders
      .where((o) =>
          o.type == OrderType.collectionSale &&
          o.supplierName == acceptorName)
      .toList();

  /// Driver or supplier commits to sell waste to the recycling company.
  /// Creates a [collectionSale] order. Returns an error string or null.
  String? createCollectionSale({
    required String jobId,
    required String acceptorName,
    required String collectionArea,
    required List<WasteType> wasteTypes,
    PaymentModel? paymentModel,
    double? pricePerKg,
    double? itemPrice,
    double? minQuantityKg,
    String? jobDescription,
    String? companyName,
    CollectionDeliveryMethod? deliveryMethod,
    CollectionTransactionType? transactionType,
  }) {
    if (hasAcceptedJob(jobId, acceptorName)) {
      return 'لقد قبلت هذه الوظيفة مسبقاً';
    }
    final saleId = _uuid();
    final sale = Order(
      id: saleId,
      type: OrderType.collectionSale,
      linkedJobId: jobId,
      wasteTypes: wasteTypes,
      pickupAddress: 'موقعك الحالي',
      dropoffAddress: collectionArea,
      status: OrderStatus.accepted,
      reward: pricePerKg ?? itemPrice ?? 0,
      createdAt: DateTime.now(),
      supplierName: acceptorName,
      supplierNotes: companyName,
      pricePerKg: pricePerKg,
      itemPrice: itemPrice,
      paymentModel: paymentModel,
      minQuantityKg: minQuantityKg,
      jobDescription: jobDescription,
      collectionDeliveryMethod: deliveryMethod,
      collectionTransactionType: transactionType,
    );
    _orders.insert(0, sale);
    notifyListeners();

    unawaited(_pushRemote(_remote.insertOrder(sale)));
    return null;
  }

  /// Driver/supplier signals they have collected the material and are heading to
  /// the recycling facility. Moves collectionSale from pending → inTransit.
  /// Returns an error string on failure, null on success.
  String? markCollectionSaleInTransit(String saleId) {
    final idx = _orders.indexWhere(
      (o) => o.id == saleId && o.type == OrderType.collectionSale,
    );
    if (idx == -1) return 'الالتزام غير موجود';
    final current = _orders[idx];
    if (current.status != OrderStatus.accepted) {
      return 'لا يمكن تغيير الحالة — الالتزام ليس في حالة مقبولة';
    }
    _orders[idx] = current.copyWith(
      status: OrderStatus.inTransit,
      inTransitAt: DateTime.now(),
    );
    notifyListeners();

    unawaited(_pushRemote(_remote.markInTransit(saleId)));
    return null;
  }

  /// Driver/supplier confirms delivery to the recycling facility.
  /// [actualWeightKg] is optional — used when paymentModel == perKg so the
  /// final earnings can be calculated later.
  /// Returns an error string on failure, null on success.
  String? completeCollectionSale(String saleId, {double? actualWeightKg}) {
    final idx = _orders.indexWhere(
      (o) => o.id == saleId && o.type == OrderType.collectionSale,
    );
    if (idx == -1) return 'الالتزام غير موجود';
    final current = _orders[idx];
    if (current.status != OrderStatus.inTransit) {
      return 'يجب بدء التجميع أولاً قبل تأكيد التسليم';
    }
    _orders[idx] = current.copyWith(
      status: OrderStatus.completed,
      completedAt: DateTime.now(),
      weightKg: actualWeightKg ?? current.weightKg,
    );
    notifyListeners();

    unawaited(_pushRemote(_remote.markCompleted(saleId, actualWeightKg: actualWeightKg)));
    return null;
  }

  /// Cancel a collection sale commitment. Only allowed when status == pending.
  /// Once inTransit or completed, cancellation is silently ignored — the user
  /// must contact the company directly.
  void cancelCollectionSale(String saleId) {
    final idx = _orders.indexWhere(
      (o) => o.id == saleId && o.type == OrderType.collectionSale,
    );
    if (idx == -1) return;
    final status = _orders[idx].status;
    if (status == OrderStatus.inTransit ||
        status == OrderStatus.completed ||
        status == OrderStatus.cancelled) {
      return;
    }
    _orders[idx] = _orders[idx].copyWith(status: OrderStatus.cancelled);
    notifyListeners();

    unawaited(_pushRemote(_remote.markCancelled(saleId)));
  }

  /// All collectionSale commitments linked to jobs owned by [companyName].
  /// Used by RecyclingHomeTab to show acceptor count + status per job.
  List<Order> salesForCompanyJobs(String companyName) {
    final companyJobIds = _orders
        .where(
          (o) => o.type == OrderType.collection && o.supplierName == companyName,
        )
        .map((o) => o.id)
        .toSet();

    return _orders
        .where(
          (o) =>
              o.type == OrderType.collectionSale &&
              o.linkedJobId != null &&
              companyJobIds.contains(o.linkedJobId),
        )
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Marketplace actions
  // ─────────────────────────────────────────────────────────────────────────

  void addMarketListing(Order order) {
    _orders.insert(0, order);
    notifyListeners();

    unawaited(_pushRemote(_remote.insertOrder(order)));
  }

  void removeMarketListing(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    if (_orders[idx].status != OrderStatus.pending) return;
    _orders[idx] = _orders[idx].copyWith(status: OrderStatus.cancelled);
    notifyListeners();

    unawaited(_pushRemote(_remote.markCancelled(orderId)));
  }

  List<Order> myMarketListings(String publisherName) => _orders
      .where((o) =>
          o.isMarketplaceShared &&
          o.supplierName == publisherName &&
          (o.status == OrderStatus.pending ||
              o.status == OrderStatus.accepted ||
              o.status == OrderStatus.inTransit))
      .toList();

  Order? claimMarketItem(String orderId, User driver) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1 || !_orders[idx].isMarketplaceShared) return null;
    if (_orders[idx].status != OrderStatus.pending) return null;
    final claimed = _orders[idx].copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      driverName: driver.name,
      driverPhone: driver.phone,
      driverRating: driver.rating,
      driverVehicleModel: driver.vehicleModel,
      driverVehicleColor: driver.vehicleColor,
      driverLicensePlate: driver.licensePlate,
    );
    _orders[idx] = claimed;
    notifyListeners();

    unawaited(_pushRemote(_remote.markAccepted(orderId)));
    return claimed;
  }

  Order? purchaseMarketItem({
    required String orderId,
    required bool selfPickup,
    String? dropoffAddress,
    double deliveryFee = 0,
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1 || !_orders[idx].isMarketplaceShared) return null;
    if (_orders[idx].status != OrderStatus.pending) return null;
    if (!selfPickup &&
        (dropoffAddress == null || dropoffAddress.trim().isEmpty)) {
      return null;
    }
    final purchased = _orders[idx].copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      dropoffAddress: selfPickup ? 'استلام من السوق' : (dropoffAddress ?? 'عنوان مجهول'),
      deliveryFee: selfPickup ? 0 : deliveryFee,
      requiresRider: !selfPickup,
    );
    _orders[idx] = purchased;
    notifyListeners();

    unawaited(_pushRemote(
      _remote.markPurchased(orderId, requiresRider: !selfPickup),
    ));
    return purchased;
  }

  Order? receiveAtFacility(String orderId, String facilityAddress) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1 || !_orders[idx].isMarketplaceShared) return null;
    if (_orders[idx].status != OrderStatus.pending) return null;
    final received = _orders[idx].copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      dropoffAddress: facilityAddress,
    );
    _orders[idx] = received;
    notifyListeners();

    // Marketplace receive-at-facility doesn't require a rider.
    unawaited(_pushRemote(
      _remote.markPurchased(orderId, requiresRider: false),
    ));
    return received;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  static String _uuid() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  static double _calculateFee(WeightCategory? cat) {
    const base = 2.0;
    return base +
        switch (cat) {
          WeightCategory.light => 0.0,
          WeightCategory.medium => 1.5,
          WeightCategory.heavy => 4.0,
          WeightCategory.veryHeavy => 8.0,
          null => 0.0,
        };
  }

  /// Awaits a remote write and lifts any failure into [_lastError] so widgets
  /// can react via [lastError]. Successes are silent.
  Future<void> _pushRemote(Future<AppResult<void>> op) async {
    final result = await op;
    result.fold(
      onSuccess: (_) {},
      onFailure: (failure) {
        _lastError = failure;
        notifyListeners();
      },
    );
  }
}
