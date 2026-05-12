part of '../app_order_store.dart';

/// Company-facing collection-job CRUD and views for [AppOrderStore].
extension AppOrderStoreCollectionJobActions on AppOrderStore {
  // ── Company views ────────────────────────────────────────────────────────

  /// Collection jobs posted by the company.
  List<Order> get companyJobs =>
      _orders.where((o) => o.type == OrderType.collection).toList();

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
          (o.status == OrderStatus.pending ||
              o.status == OrderStatus.accepted))
      .toList();

  /// Look up a single collection job by ID.
  Order? getCollectionJob(String jobId) => _orders
      .where((o) => o.id == jobId && o.type == OrderType.collection)
      .firstOrNull;

  // ── Company actions ──────────────────────────────────────────────────────

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

    unawaited(_pushRemote(_remote.insertOrder(order)));
    return order;
  }

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
}
