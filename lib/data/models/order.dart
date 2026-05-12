import 'invoice_item.dart';
import 'order_enums.dart';
import 'reward_breakdown.dart';

// Re-export enums, Arabic labels, invoice item, and copyWith so consumers that
// `import '.../data/models/order.dart'` keep working without new imports.
export 'invoice_item.dart';
export 'order_arabic_labels.dart';
export 'order_copy_with.dart';
export 'order_enums.dart';

/// Immutable domain model representing a single order on the Dawer platform.
///
/// `copyWith` lives as an extension in `order_copy_with.dart`.
/// JSON and Supabase mapping helpers live in `order_json.dart` and
/// `order_supabase_ext.dart`.
class Order {
  final String id;
  final OrderType type;
  final List<WasteType> wasteTypes;
  final String pickupAddress;
  final String dropoffAddress;
  final OrderStatus status;
  final String? driverName;
  final String? driverPhone;
  final double? driverRating;
  final String? driverVehicle;
  final String? driverVehicleModel;
  final String? driverVehicleColor;
  final String? driverLicensePlate;
  final String? driverVehiclePhotoPath;
  final String? supplierName;
  final double reward;
  final double? weightKg;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? inTransitAt;
  final DateTime? completedAt;
  final DateTime? scheduledAt;
  final String? eta;
  final double? distanceKm;
  final String? proofImagePath;
  final double? paidAmount;
  final String? supplierNotes;
  final List<String> images;
  final double? estimatedWeightKg;
  final WasteForm? wasteForm;
  final WeightCategory? weightCategory;
  final double? deliveryFee;
  final PickupTarget? pickupTarget;
  final double? itemPrice;
  final String? jobDescription;
  final double? pricePerKg;
  final PaymentModel? paymentModel;
  final double? minQuantityKg;
  final bool isEdited;
  final DateTime? editedAt;
  final String? editNote;
  final String? linkedJobId;
  final CollectionDeliveryMethod? collectionDeliveryMethod;
  final CollectionTransactionType? collectionTransactionType;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final int? etaMinutes;
  final bool isMarketplaceShared;
  final bool requiresRider;
  final RewardBreakdown? rewardBreakdown;
  final List<InvoiceItem>? invoices;

  const Order({
    required this.id,
    required this.type,
    required this.wasteTypes,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    required this.reward,
    required this.createdAt,
    this.acceptedAt,
    this.inTransitAt,
    this.completedAt,
    this.scheduledAt,
    this.driverName,
    this.driverPhone,
    this.driverRating,
    this.driverVehicle,
    this.driverVehicleModel,
    this.driverVehicleColor,
    this.driverLicensePlate,
    this.driverVehiclePhotoPath,
    this.supplierName,
    this.weightKg,
    this.eta,
    this.distanceKm,
    this.proofImagePath,
    this.paidAmount,
    this.supplierNotes,
    this.images = const [],
    this.estimatedWeightKg,
    this.wasteForm,
    this.weightCategory,
    this.deliveryFee,
    this.pickupTarget,
    this.itemPrice,
    this.jobDescription,
    this.pricePerKg,
    this.paymentModel,
    this.minQuantityKg,
    this.isEdited = false,
    this.editedAt,
    this.editNote,
    this.linkedJobId,
    this.collectionDeliveryMethod,
    this.collectionTransactionType,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.etaMinutes,
    this.isMarketplaceShared = false,
    this.requiresRider = false,
    this.rewardBreakdown,
    this.invoices,
  });
}
