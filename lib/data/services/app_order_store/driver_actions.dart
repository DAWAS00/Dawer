part of '../app_order_store.dart';

/// Driver-facing views and actions for [AppOrderStore].
extension AppOrderStoreDriverActions on AppOrderStore {
  // ── Driver views ─────────────────────────────────────────────────────────

  /// Pending orders available for the driver to accept (no driver yet).
  List<Order> get driverFeed => _orders
      .where((o) =>
          ((o.status == OrderStatus.pending && !o.isMarketplaceShared) ||
              (o.status == OrderStatus.accepted &&
                  o.requiresRider &&
                  o.driverName == null)) &&
          o.id != _activeOrderId)
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

  // ── Driver actions ───────────────────────────────────────────────────────

  /// Accept an available order. Returns an error string on failure.
  String? acceptOrder(String orderId, User driver) {
    if (_activeOrderId != null) {
      return 'لا يمكنك قبول طلب جديد. يرجى إتمام الطلب الحالي أولاً.';
    }
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return 'الطلب غير موجود';
    final order = _orders[idx];

    final canAccept = order.status == OrderStatus.pending ||
        (order.status == OrderStatus.accepted &&
            order.requiresRider &&
            order.driverName == null);
    if (!canAccept) return 'هذا الطلب لم يعد متاحاً';

    // Rough urban ETA: 1 km ≈ 2 min. Null when distance unknown.
    final estimatedMins = order.distanceKm != null
        ? (order.distanceKm! * 2).round().clamp(1, 999)
        : null;
    _orders[idx] = order.copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      etaMinutes: estimatedMins,
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
      etaMinutes: null,
    );
    notifyListeners();

    unawaited(_pushRemote(_remote.markInTransit(orderId)));
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
      unawaited(_store?.writeDriverHistory(_driverCompletedIds));
    }
    notifyListeners();

    unawaited(_pushRemote(_remote.markCompleted(
      completedOrder.id,
      actualWeightKg: completedOrder.weightKg,
    )));
  }

  /// Record a driver rating after delivery (mock — updates driverRating on order).
  void submitDriverRating(String orderId, double rating) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(driverRating: rating);
      notifyListeners();
    }
  }
}
