import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../mock/order_mock_data.dart';

/// Singleton shared order store — the single source of truth for all orders
/// across Driver, Supplier, and Recycling Company roles.
///
/// Provided at app root via [ChangeNotifierProvider]. All three home-view VMs
/// accept this store in their constructor and addListener to it so their own
/// [notifyListeners] fires whenever the store changes.
class AppOrderStore extends ChangeNotifier {
  // ─────────────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────────────

  /// All regular orders — pickup requests (from suppliers) and collection jobs
  /// (posted by recycling companies). This is the canonical list.
  final List<Order> _orders = OrderMockData.seedOrders();

  /// Marketplace items — materials listed for purchase/claim.
  final List<Order> _market = OrderMockData.seedMarketItems();

  /// ID of the order currently active for our mock driver session.
  String? _activeOrderId;

  /// IDs of orders completed by our mock driver (their personal history).
  final List<String> _driverCompletedIds = ['ORD-H01', 'ORD-H02'];

  // ─────────────────────────────────────────────────────────────────────────
  // Driver views
  // ─────────────────────────────────────────────────────────────────────────

  /// Pending orders available for the driver to accept (no driver yet).
  List<Order> get driverFeed => _orders
      .where((o) =>
          o.status == OrderStatus.pending && o.id != _activeOrderId)
      .toList();

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

  /// All orders submitted by a specific supplier (by name, mock-only).
  List<Order> supplierOrdersFor(String supplierName) => _orders
      .where((o) =>
          o.supplierName == supplierName && o.type == OrderType.pickup)
      .toList();

  // ─────────────────────────────────────────────────────────────────────────
  // Recycling Company views
  // ─────────────────────────────────────────────────────────────────────────

  /// Pickup orders heading to the company (accepted or inTransit).
  List<Order> get companyIncoming => _orders
      .where((o) =>
          o.type == OrderType.pickup &&
          (o.status == OrderStatus.accepted ||
              o.status == OrderStatus.inTransit))
      .toList();

  /// Collection jobs posted by the company.
  List<Order> get companyJobs =>
      _orders.where((o) => o.type == OrderType.collection).toList();

  // ─────────────────────────────────────────────────────────────────────────
  // Marketplace views
  // ─────────────────────────────────────────────────────────────────────────

  List<Order> get marketItems => List.unmodifiable(_market);

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
    if (order.status != OrderStatus.pending) return 'هذا الطلب لم يعد متاحاً';

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
    return null;
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
    final orderId =
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final fee = _calculateFee(weightCategory);
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
    );
    _orders.insert(0, order);
    notifyListeners();
    return order;
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
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    double reward = 0,
    double? itemPrice,
    String? jobDescription,
    double? pricePerKg,
    PaymentModel? paymentModel,
    double? minQuantityKg,
  }) {
    final orderId =
        'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
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
      wasteForm: wasteForm,
      weightCategory: weightCategory,
      jobDescription: jobDescription,
      pricePerKg: pricePerKg,
      paymentModel: paymentModel,
      minQuantityKg: minQuantityKg,
    );
    _orders.insert(0, order);
    notifyListeners();
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
    final saleId =
        'SALE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final sale = Order(
      id: saleId,
      type: OrderType.collectionSale,
      linkedJobId: jobId,
      wasteTypes: wasteTypes,
      pickupAddress: 'موقعك الحالي',
      dropoffAddress: collectionArea,
      status: OrderStatus.pending,
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
    if (current.status != OrderStatus.pending) {
      return 'لا يمكن تغيير الحالة — الالتزام ليس في حالة انتظار';
    }
    _orders[idx] = current.copyWith(
      status: OrderStatus.inTransit,
      inTransitAt: DateTime.now(),
    );
    notifyListeners();
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
    return null;
  }

  /// Cancel a collection sale commitment. Only allowed when status == pending.
  /// Once inTransit or completed, cancellation is blocked — the user must
  /// contact the company directly.
  /// Returns an error string on failure, null on success.
  String? cancelCollectionSale(String saleId) {
    final idx = _orders.indexWhere(
      (o) => o.id == saleId && o.type == OrderType.collectionSale,
    );
    if (idx == -1) return 'الالتزام غير موجود';
    final status = _orders[idx].status;
    if (status == OrderStatus.inTransit) {
      return 'لا يمكن الإلغاء بعد بدء التجميع — تواصل مع الشركة مباشرة';
    }
    if (status == OrderStatus.completed) {
      return 'لا يمكن إلغاء التزام مكتمل';
    }
    if (status == OrderStatus.cancelled) {
      return 'هذا الالتزام ملغى مسبقاً';
    }
    _orders[idx] = _orders[idx].copyWith(status: OrderStatus.cancelled);
    notifyListeners();
    return null;
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
    _market.insert(0, order);
    notifyListeners();
  }

  void removeMarketListing(String orderId) {
    final idx = _market.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    if (_market[idx].status != OrderStatus.pending) return;
    _market[idx] = _market[idx].copyWith(status: OrderStatus.cancelled);
    notifyListeners();
  }

  List<Order> myMarketListings(String publisherName) => _market
      .where((o) =>
          o.supplierName == publisherName &&
          (o.status == OrderStatus.pending ||
              o.status == OrderStatus.accepted ||
              o.status == OrderStatus.inTransit))
      .toList();

  Order? claimMarketItem(String orderId, User driver) {
    final idx = _market.indexWhere((o) => o.id == orderId);
    if (idx == -1) return null;
    if (_market[idx].status != OrderStatus.pending) return null;
    final claimed = _market[idx].copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      driverName: driver.name,
      driverPhone: driver.phone,
      driverRating: driver.rating,
      driverVehicleModel: driver.vehicleModel,
      driverVehicleColor: driver.vehicleColor,
      driverLicensePlate: driver.licensePlate,
    );
    _market[idx] = claimed;
    notifyListeners();
    return claimed;
  }

  Order? purchaseMarketItem({
    required String orderId,
    required bool selfPickup,
    String? dropoffAddress,
    double deliveryFee = 0,
  }) {
    final idx = _market.indexWhere((o) => o.id == orderId);
    if (idx == -1) return null;
    if (_market[idx].status != OrderStatus.pending) return null;
    if (!selfPickup &&
        (dropoffAddress == null || dropoffAddress.trim().isEmpty)) {
      return null;
    }
    final purchased = _market[idx].copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      dropoffAddress: selfPickup ? 'استلام من السوق' : dropoffAddress!,
      deliveryFee: selfPickup ? 0 : deliveryFee,
    );
    _market[idx] = purchased;
    notifyListeners();
    return purchased;
  }

  Order? receiveAtFacility(String orderId, String facilityAddress) {
    final idx = _market.indexWhere((o) => o.id == orderId);
    if (idx == -1) return null;
    if (_market[idx].status != OrderStatus.pending) return null;
    final received = _market[idx].copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      dropoffAddress: facilityAddress,
    );
    _market[idx] = received;
    notifyListeners();
    return received;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

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

}
