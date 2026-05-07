import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/user.dart';
import 'app_order_store.dart';

class RecyclingOrderStore extends ChangeNotifier {
  final AppOrderStore _base;

  RecyclingOrderStore(this._base) {
    _base.addListener(_onBaseChanged);
  }

  @override
  void dispose() {
    _base.removeListener(_onBaseChanged);
    super.dispose();
  }

  void _onBaseChanged() => notifyListeners();

  List<Order> get incoming => _base.companyIncoming;
  List<Order> get jobs => _base.companyJobs;
  List<Order> get pendingCollectionJobs => _base.pendingCollectionJobs;
  List<Order> get marketItems => _base.marketItems;

  List<Order> salesForCompanyJobs(String companyName) =>
      _base.salesForCompanyJobs(companyName);
  List<Order> myCollectionJobs(String companyName) =>
      _base.myCollectionJobs(companyName);

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
  }) => _base.createCollectionJob(
    wasteTypes: wasteTypes,
    pickupAddress: pickupAddress,
    companyName: companyName,
    dropoffAddress: dropoffAddress,
    notes: notes,
    wasteForm: wasteForm,
    weightCategory: weightCategory,
    reward: reward,
    itemPrice: itemPrice,
    jobDescription: jobDescription,
    pricePerKg: pricePerKg,
    paymentModel: paymentModel,
    minQuantityKg: minQuantityKg,
  );

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
  }) => _base.updateCollectionJob(
    jobId: jobId,
    companyName: companyName,
    wasteTypes: wasteTypes,
    collectionArea: collectionArea,
    jobDescription: jobDescription,
    paymentModel: paymentModel,
    price: price,
    minQuantityKg: minQuantityKg,
    editNote: editNote,
  );

  bool deleteCollectionJob(String jobId, String companyName) =>
      _base.deleteCollectionJob(jobId, companyName);
  Order? getCollectionJob(String jobId) => _base.getCollectionJob(jobId);
  String? claimCollectionJob(String jobId, User driver) =>
      _base.claimCollectionJob(jobId, driver);
  bool hasAcceptedJob(String jobId, String acceptorName) =>
      _base.hasAcceptedJob(jobId, acceptorName);
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
  }) => _base.createCollectionSale(
    jobId: jobId,
    acceptorName: acceptorName,
    collectionArea: collectionArea,
    wasteTypes: wasteTypes,
    paymentModel: paymentModel,
    pricePerKg: pricePerKg,
    itemPrice: itemPrice,
    minQuantityKg: minQuantityKg,
    jobDescription: jobDescription,
    companyName: companyName,
    deliveryMethod: deliveryMethod,
    transactionType: transactionType,
  );

  Order? receiveAtFacility(String orderId, String facilityAddress) =>
      _base.receiveAtFacility(orderId, facilityAddress);
  void addMarketListing(Order order) => _base.addMarketListing(order);
}
