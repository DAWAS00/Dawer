part of '../app_order_store.dart';

/// Supplier-facing views and pickup-request actions for [AppOrderStore].
extension AppOrderStoreSupplierActions on AppOrderStore {
  // ── Supplier views ───────────────────────────────────────────────────────

  /// All orders submitted by a specific supplier (by name, mock-only).
  List<Order> supplierOrdersFor(String supplierName) => _orders
      .where((o) =>
          o.supplierName == supplierName && o.type == OrderType.pickup)
      .toList();

  // ── Recycling Company views (pickup-side) ────────────────────────────────

  /// Pickup orders heading to the company (accepted or inTransit).
  List<Order> get companyIncoming => _orders
      .where((o) =>
          o.type == OrderType.pickup &&
          (o.status == OrderStatus.accepted ||
              o.status == OrderStatus.inTransit))
      .toList();

  // ── Supplier actions ─────────────────────────────────────────────────────

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
    final fee = FeeCalculator.forWeightCategory(weightCategory);
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
        wasteForm: request.wasteForm,
        weightCategory: request.weightCategory,
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
}
