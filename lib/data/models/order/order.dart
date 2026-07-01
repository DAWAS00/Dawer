import 'package:freezed_annotation/freezed_annotation.dart';
import '../reward_breakdown.dart';
import 'order_enums.dart';
import 'order_proof.dart';
import 'invoice_item.dart';

export 'order_enums.dart';
export 'order_proof.dart';
export 'invoice_item.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required OrderType type,
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    required String dropoffAddress,
    required OrderStatus status,
    required double reward,
    required DateTime createdAt,
    DateTime? acceptedAt,
    DateTime? inTransitAt,
    DateTime? completedAt,
    DateTime? scheduledAt,
    String? driverName,
    String? driverPhone,
    double? driverRating,
    String? driverVehicle,
    String? driverVehicleModel,
    String? driverVehicleColor,
    String? driverLicensePlate,
    String? driverVehiclePhotoPath,
    String? supplierId,
    String? supplierName,
    String? supplierPhone,
    double? weightKg,
    String? eta,
    double? distanceKm,
    String? proofImagePath,
    double? paidAmount,
    String? supplierNotes,
    @Default([]) List<String> images,
    double? estimatedWeightKg,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    double? deliveryFee,
    PickupTarget? pickupTarget,
    double? itemPrice,
    String? jobDescription,
    double? pricePerKg,
    PaymentModel? paymentModel,
    double? minQuantityKg,
    @Default(false) bool isEdited,
    DateTime? editedAt,
    String? editNote,
    String? linkedJobId,
    CollectionDeliveryMethod? collectionDeliveryMethod,
    CollectionTransactionType? collectionTransactionType,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    int? etaMinutes,
    @Default(false) bool isMarketplaceShared,
    @Default(false) bool requiresRider,
    RewardBreakdown? rewardBreakdown,
    List<InvoiceItem>? invoices,
    DateTime? arrivedAtPickupAt,
    DateTime? arrivedAtDropoffAt,
    ArrivalConfirmationStatus? arrivalConfirmationStatus,
    OrderProof? proof,
    OrderProof? pickupProof,
    double? supplierHoldAmount,
    double? driverCompensationAmount,
    @Default(0) int fraudAttemptCount,
    @Default(false) bool weightVarianceFlag,
    VehicleType? requiredVehicleType,
    @Default(false) bool requiresChemicalPermit,
    @Default(AdminApprovalStatus.notRequired) AdminApprovalStatus adminApprovalStatus,
    DateTime? expiresAt,
    @Default(false) bool isVatApplicable,
    double? vatAmountJd,
    // ── Reservation (10 % escrow) ─────────────────────────────────────────
    ReservationStatus? reservationStatus,
    DateTime? reservationPickupDate,
    String? reservedByName,
    String? reservedById,
    double? buyerDepositAmount,
    double? sellerDepositAmount,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

extension VehicleTypeCapacity on VehicleType {
  double get maxWeightKg => switch (this) {
    VehicleType.motorcycle => 10,
    VehicleType.car        => 50,
    VehicleType.pickup     => 500,
    VehicleType.van        => 1000,
    VehicleType.truck      => 5000,
    VehicleType.heavyTruck => 20000,
  };

  /// Physical hard-ban for non-chemicals waste types.
  Set<WasteType> get _hardBanned => switch (this) {
    VehicleType.motorcycle => {
      WasteType.oil, WasteType.batteries, WasteType.electronics,
      WasteType.rubber, WasteType.tires, WasteType.construction,
      WasteType.furniture, WasteType.metal, WasteType.copperAluminium,
      WasteType.wood,
    },
    VehicleType.car => {
      WasteType.oil, WasteType.tires, WasteType.construction,
      WasteType.furniture,
    },
    _ => {},
  };

  /// Whether this vehicle type can carry [type].
  bool supportsWasteType(WasteType type, {bool hasChemicalPermit = false}) {
    if (type == WasteType.chemicals) {
      return switch (this) {
        VehicleType.motorcycle || VehicleType.car => false,
        _ => hasChemicalPermit,
      };
    }
    return !_hardBanned.contains(type);
  }

  bool canTakeOrder(Order order, {bool hasChemicalPermit = false}) {
    final weightOk = (order.estimatedWeightKg ?? 0) <= maxWeightKg;
    final typesOk = order.wasteTypes.every(
      (w) => supportsWasteType(w, hasChemicalPermit: hasChemicalPermit),
    );
    final permitOk = !order.requiresChemicalPermit || hasChemicalPermit;
    return weightOk && typesOk && permitOk;
  }
}
