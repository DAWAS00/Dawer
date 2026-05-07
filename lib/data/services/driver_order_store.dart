import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/user.dart';
import 'app_order_store.dart';

/// Driver-scoped view over AppOrderStore.
class DriverOrderStore extends ChangeNotifier {
  final AppOrderStore _base;

  DriverOrderStore(this._base) {
    _base.addListener(_onBaseChanged);
  }

  @override
  void dispose() {
    _base.removeListener(_onBaseChanged);
    super.dispose();
  }

  void _onBaseChanged() => notifyListeners();

  List<Order> get feed => _base.driverFeed;
  Order? get activeOrder => _base.driverActiveOrder;
  List<Order> get history => _base.driverHistory;
  bool get hasActiveOrder => _base.driverHasActiveOrder;

  List<Order> collectionSalesFor(String driverName) =>
      _base.collectionSalesFor(driverName);

  String? acceptOrder(String orderId, User driver) =>
      _base.acceptOrder(orderId, driver);

  void completeOrder(Order order) => _base.completeOrder(order);
  void markInTransit(String orderId) => _base.markInTransit(orderId);
  String? markCollectionSaleInTransit(String saleId) =>
      _base.markCollectionSaleInTransit(saleId);
  String? completeCollectionSale(String saleId, {double? actualWeightKg}) =>
      _base.completeCollectionSale(saleId, actualWeightKg: actualWeightKg);
  void cancelCollectionSale(String saleId) =>
      _base.cancelCollectionSale(saleId);
  void submitDriverRating(String orderId, double rating) =>
      _base.submitDriverRating(orderId, rating);
  void addMarketListing(Order order) => _base.addMarketListing(order);
}
