part of '../app_order_store.dart';

/// Collection-sale commitments: a driver/supplier fulfilling a company job.
/// Includes views, lifecycle transitions, and cancellation for [AppOrderStore].
extension AppOrderStoreCollectionSaleActions on AppOrderStore {
  // ── Views ────────────────────────────────────────────────────────────────

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

  /// All collectionSale commitments linked to jobs owned by [companyName].
  /// Used by RecyclingHomeTab to show acceptor count + status per job.
  List<Order> salesForCompanyJobs(String companyName) {
    final companyJobIds = _orders
        .where(
          (o) => o.type == OrderType.collection &&
              o.supplierName == companyName,
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

  // ── Lifecycle ────────────────────────────────────────────────────────────

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

    unawaited(_pushRemote(
      _remote.markCompleted(saleId, actualWeightKg: actualWeightKg),
    ));
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
}
