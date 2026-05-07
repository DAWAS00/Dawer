import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../../core/result/result.dart';
import '../../domain/requests/create_pickup_request.dart';
import 'app_order_store.dart';

class SupplierOrderStore extends ChangeNotifier {
  final AppOrderStore _base;

  SupplierOrderStore(this._base) {
    _base.addListener(_onBaseChanged);
  }

  @override
  void dispose() {
    _base.removeListener(_onBaseChanged);
    super.dispose();
  }

  void _onBaseChanged() => notifyListeners();

  List<Order> ordersFor(String supplierName) =>
      _base.supplierOrdersFor(supplierName);
  List<Order> collectionSalesFor(String supplierName) =>
      _base.collectionSalesFor(supplierName);
  List<Order> myMarketListings(String publisherName) =>
      _base.myMarketListings(publisherName);
  List<Order> get pendingCollectionJobs => _base.pendingCollectionJobs;
  List<Order> get marketItems => _base.marketItems;

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
  }) => _base.createPickupRequest(
    wasteTypes: wasteTypes,
    supplierName: supplierName,
    pickupAddress: pickupAddress,
    dropoffAddress: dropoffAddress,
    notes: notes,
    images: images,
    estimatedWeightKg: estimatedWeightKg,
    wasteForm: wasteForm,
    weightCategory: weightCategory,
    pickupTarget: pickupTarget,
    itemPrice: itemPrice,
    scheduledAt: scheduledAt,
    pickupLat: pickupLat,
    pickupLng: pickupLng,
    dropoffLat: dropoffLat,
    dropoffLng: dropoffLng,
  );

  AppResult<Order> submitPickupRequest(CreatePickupRequest req, {required String supplierName}) =>
      _base.submitPickupRequest(req, supplierName: supplierName);

  String? cancelOrder(String orderId) => _base.cancelOrder(orderId);
  void assignDriver(String orderId, User driver) => _base.assignDriver(orderId, driver);
  String? markCollectionSaleInTransit(String saleId) => _base.markCollectionSaleInTransit(saleId);
  String? completeCollectionSale(String saleId, {double? actualWeightKg}) =>
      _base.completeCollectionSale(saleId, actualWeightKg: actualWeightKg);
  void cancelCollectionSale(String saleId) => _base.cancelCollectionSale(saleId);
  void addMarketListing(Order order) => _base.addMarketListing(order);
  void removeMarketListing(String orderId) => _base.removeMarketListing(orderId);
  Order? purchaseMarketItem({required String orderId, required bool selfPickup, String? dropoffAddress, double deliveryFee = 0}) =>
      _base.purchaseMarketItem(orderId: orderId, selfPickup: selfPickup, dropoffAddress: dropoffAddress, deliveryFee: deliveryFee);
  Order? receiveAtFacility(String orderId, String facilityAddress) => _base.receiveAtFacility(orderId, facilityAddress);
}
