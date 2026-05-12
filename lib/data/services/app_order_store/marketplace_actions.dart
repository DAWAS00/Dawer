part of '../app_order_store.dart';

/// Marketplace views and buy/claim/receive actions for [AppOrderStore].
extension AppOrderStoreMarketplaceActions on AppOrderStore {
  // ── Views ────────────────────────────────────────────────────────────────

  List<Order> get marketItems =>
      List.unmodifiable(_orders.where((o) => o.isMarketplaceShared));

  List<Order> myMarketListings(String publisherName) => _orders
      .where((o) =>
          o.isMarketplaceShared &&
          o.supplierName == publisherName &&
          (o.status == OrderStatus.pending ||
              o.status == OrderStatus.accepted ||
              o.status == OrderStatus.inTransit))
      .toList();

  // ── Actions ──────────────────────────────────────────────────────────────

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
      dropoffAddress:
          selfPickup ? 'استلام من السوق' : (dropoffAddress ?? 'عنوان مجهول'),
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
}
