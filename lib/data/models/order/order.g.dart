// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
  id: json['id'] as String,
  type: $enumDecode(_$OrderTypeEnumMap, json['type']),
  wasteTypes: (json['wasteTypes'] as List<dynamic>)
      .map((e) => $enumDecode(_$WasteTypeEnumMap, e))
      .toList(),
  pickupAddress: json['pickupAddress'] as String,
  dropoffAddress: json['dropoffAddress'] as String,
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  reward: (json['reward'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  acceptedAt: json['acceptedAt'] == null
      ? null
      : DateTime.parse(json['acceptedAt'] as String),
  inTransitAt: json['inTransitAt'] == null
      ? null
      : DateTime.parse(json['inTransitAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  driverName: json['driverName'] as String?,
  driverPhone: json['driverPhone'] as String?,
  driverRating: (json['driverRating'] as num?)?.toDouble(),
  driverVehicle: json['driverVehicle'] as String?,
  driverVehicleModel: json['driverVehicleModel'] as String?,
  driverVehicleColor: json['driverVehicleColor'] as String?,
  driverLicensePlate: json['driverLicensePlate'] as String?,
  driverVehiclePhotoPath: json['driverVehiclePhotoPath'] as String?,
  supplierId: json['supplierId'] as String?,
  supplierName: json['supplierName'] as String?,
  supplierPhone: json['supplierPhone'] as String?,
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  eta: json['eta'] as String?,
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  proofImagePath: json['proofImagePath'] as String?,
  paidAmount: (json['paidAmount'] as num?)?.toDouble(),
  supplierNotes: json['supplierNotes'] as String?,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  estimatedWeightKg: (json['estimatedWeightKg'] as num?)?.toDouble(),
  wasteForm: $enumDecodeNullable(_$WasteFormEnumMap, json['wasteForm']),
  weightCategory: $enumDecodeNullable(
    _$WeightCategoryEnumMap,
    json['weightCategory'],
  ),
  deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
  pickupTarget: $enumDecodeNullable(
    _$PickupTargetEnumMap,
    json['pickupTarget'],
  ),
  itemPrice: (json['itemPrice'] as num?)?.toDouble(),
  jobDescription: json['jobDescription'] as String?,
  pricePerKg: (json['pricePerKg'] as num?)?.toDouble(),
  paymentModel: $enumDecodeNullable(
    _$PaymentModelEnumMap,
    json['paymentModel'],
  ),
  minQuantityKg: (json['minQuantityKg'] as num?)?.toDouble(),
  isEdited: json['isEdited'] as bool? ?? false,
  editedAt: json['editedAt'] == null
      ? null
      : DateTime.parse(json['editedAt'] as String),
  editNote: json['editNote'] as String?,
  linkedJobId: json['linkedJobId'] as String?,
  collectionDeliveryMethod: $enumDecodeNullable(
    _$CollectionDeliveryMethodEnumMap,
    json['collectionDeliveryMethod'],
  ),
  collectionTransactionType: $enumDecodeNullable(
    _$CollectionTransactionTypeEnumMap,
    json['collectionTransactionType'],
  ),
  pickupLat: (json['pickupLat'] as num?)?.toDouble(),
  pickupLng: (json['pickupLng'] as num?)?.toDouble(),
  dropoffLat: (json['dropoffLat'] as num?)?.toDouble(),
  dropoffLng: (json['dropoffLng'] as num?)?.toDouble(),
  etaMinutes: (json['etaMinutes'] as num?)?.toInt(),
  isMarketplaceShared: json['isMarketplaceShared'] as bool? ?? false,
  requiresRider: json['requiresRider'] as bool? ?? false,
  rewardBreakdown: json['rewardBreakdown'] == null
      ? null
      : RewardBreakdown.fromJson(
          json['rewardBreakdown'] as Map<String, dynamic>,
        ),
  invoices: (json['invoices'] as List<dynamic>?)
      ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  arrivedAtPickupAt: json['arrivedAtPickupAt'] == null
      ? null
      : DateTime.parse(json['arrivedAtPickupAt'] as String),
  arrivedAtDropoffAt: json['arrivedAtDropoffAt'] == null
      ? null
      : DateTime.parse(json['arrivedAtDropoffAt'] as String),
  arrivalConfirmationStatus: $enumDecodeNullable(
    _$ArrivalConfirmationStatusEnumMap,
    json['arrivalConfirmationStatus'],
  ),
  proof: json['proof'] == null
      ? null
      : OrderProof.fromJson(json['proof'] as Map<String, dynamic>),
  pickupProof: json['pickupProof'] == null
      ? null
      : OrderProof.fromJson(json['pickupProof'] as Map<String, dynamic>),
  supplierHoldAmount: (json['supplierHoldAmount'] as num?)?.toDouble(),
  driverCompensationAmount: (json['driverCompensationAmount'] as num?)
      ?.toDouble(),
  fraudAttemptCount: (json['fraudAttemptCount'] as num?)?.toInt() ?? 0,
  weightVarianceFlag: json['weightVarianceFlag'] as bool? ?? false,
  requiredVehicleType: $enumDecodeNullable(
    _$VehicleTypeEnumMap,
    json['requiredVehicleType'],
  ),
  requiresChemicalPermit: json['requiresChemicalPermit'] as bool? ?? false,
  adminApprovalStatus:
      $enumDecodeNullable(
        _$AdminApprovalStatusEnumMap,
        json['adminApprovalStatus'],
      ) ??
      AdminApprovalStatus.notRequired,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  isVatApplicable: json['isVatApplicable'] as bool? ?? false,
  vatAmountJd: (json['vatAmountJd'] as num?)?.toDouble(),
  reservationStatus: $enumDecodeNullable(
    _$ReservationStatusEnumMap,
    json['reservationStatus'],
  ),
  reservationPickupDate: json['reservationPickupDate'] == null
      ? null
      : DateTime.parse(json['reservationPickupDate'] as String),
  reservedByName: json['reservedByName'] as String?,
  reservedById: json['reservedById'] as String?,
  buyerDepositAmount: (json['buyerDepositAmount'] as num?)?.toDouble(),
  sellerDepositAmount: (json['sellerDepositAmount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$OrderImplToJson(
  _$OrderImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$OrderTypeEnumMap[instance.type]!,
  'wasteTypes': instance.wasteTypes.map((e) => _$WasteTypeEnumMap[e]!).toList(),
  'pickupAddress': instance.pickupAddress,
  'dropoffAddress': instance.dropoffAddress,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'reward': instance.reward,
  'createdAt': instance.createdAt.toIso8601String(),
  'acceptedAt': instance.acceptedAt?.toIso8601String(),
  'inTransitAt': instance.inTransitAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'scheduledAt': instance.scheduledAt?.toIso8601String(),
  'driverName': instance.driverName,
  'driverPhone': instance.driverPhone,
  'driverRating': instance.driverRating,
  'driverVehicle': instance.driverVehicle,
  'driverVehicleModel': instance.driverVehicleModel,
  'driverVehicleColor': instance.driverVehicleColor,
  'driverLicensePlate': instance.driverLicensePlate,
  'driverVehiclePhotoPath': instance.driverVehiclePhotoPath,
  'supplierId': instance.supplierId,
  'supplierName': instance.supplierName,
  'supplierPhone': instance.supplierPhone,
  'weightKg': instance.weightKg,
  'eta': instance.eta,
  'distanceKm': instance.distanceKm,
  'proofImagePath': instance.proofImagePath,
  'paidAmount': instance.paidAmount,
  'supplierNotes': instance.supplierNotes,
  'images': instance.images,
  'estimatedWeightKg': instance.estimatedWeightKg,
  'wasteForm': _$WasteFormEnumMap[instance.wasteForm],
  'weightCategory': _$WeightCategoryEnumMap[instance.weightCategory],
  'deliveryFee': instance.deliveryFee,
  'pickupTarget': _$PickupTargetEnumMap[instance.pickupTarget],
  'itemPrice': instance.itemPrice,
  'jobDescription': instance.jobDescription,
  'pricePerKg': instance.pricePerKg,
  'paymentModel': _$PaymentModelEnumMap[instance.paymentModel],
  'minQuantityKg': instance.minQuantityKg,
  'isEdited': instance.isEdited,
  'editedAt': instance.editedAt?.toIso8601String(),
  'editNote': instance.editNote,
  'linkedJobId': instance.linkedJobId,
  'collectionDeliveryMethod':
      _$CollectionDeliveryMethodEnumMap[instance.collectionDeliveryMethod],
  'collectionTransactionType':
      _$CollectionTransactionTypeEnumMap[instance.collectionTransactionType],
  'pickupLat': instance.pickupLat,
  'pickupLng': instance.pickupLng,
  'dropoffLat': instance.dropoffLat,
  'dropoffLng': instance.dropoffLng,
  'etaMinutes': instance.etaMinutes,
  'isMarketplaceShared': instance.isMarketplaceShared,
  'requiresRider': instance.requiresRider,
  'rewardBreakdown': instance.rewardBreakdown,
  'invoices': instance.invoices,
  'arrivedAtPickupAt': instance.arrivedAtPickupAt?.toIso8601String(),
  'arrivedAtDropoffAt': instance.arrivedAtDropoffAt?.toIso8601String(),
  'arrivalConfirmationStatus':
      _$ArrivalConfirmationStatusEnumMap[instance.arrivalConfirmationStatus],
  'proof': instance.proof,
  'pickupProof': instance.pickupProof,
  'supplierHoldAmount': instance.supplierHoldAmount,
  'driverCompensationAmount': instance.driverCompensationAmount,
  'fraudAttemptCount': instance.fraudAttemptCount,
  'weightVarianceFlag': instance.weightVarianceFlag,
  'requiredVehicleType': _$VehicleTypeEnumMap[instance.requiredVehicleType],
  'requiresChemicalPermit': instance.requiresChemicalPermit,
  'adminApprovalStatus':
      _$AdminApprovalStatusEnumMap[instance.adminApprovalStatus]!,
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'isVatApplicable': instance.isVatApplicable,
  'vatAmountJd': instance.vatAmountJd,
  'reservationStatus': _$ReservationStatusEnumMap[instance.reservationStatus],
  'reservationPickupDate': instance.reservationPickupDate?.toIso8601String(),
  'reservedByName': instance.reservedByName,
  'reservedById': instance.reservedById,
  'buyerDepositAmount': instance.buyerDepositAmount,
  'sellerDepositAmount': instance.sellerDepositAmount,
};

const _$OrderTypeEnumMap = {
  OrderType.pickup: 'pickup',
  OrderType.collection: 'collection',
  OrderType.collectionSale: 'collectionSale',
};

const _$WasteTypeEnumMap = {
  WasteType.paper: 'paper',
  WasteType.plastic: 'plastic',
  WasteType.metal: 'metal',
  WasteType.glass: 'glass',
  WasteType.electronics: 'electronics',
  WasteType.organic: 'organic',
  WasteType.textile: 'textile',
  WasteType.wood: 'wood',
  WasteType.rubber: 'rubber',
  WasteType.oil: 'oil',
  WasteType.chemicals: 'chemicals',
  WasteType.batteries: 'batteries',
  WasteType.furniture: 'furniture',
  WasteType.tires: 'tires',
  WasteType.construction: 'construction',
  WasteType.copperAluminium: 'copperAluminium',
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.accepted: 'accepted',
  OrderStatus.arrivedAtPickup: 'arrivedAtPickup',
  OrderStatus.inTransit: 'inTransit',
  OrderStatus.arrivedAtDropoff: 'arrivedAtDropoff',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};

const _$WasteFormEnumMap = {
  WasteForm.solid: 'solid',
  WasteForm.liquid: 'liquid',
  WasteForm.gas: 'gas',
  WasteForm.mixed: 'mixed',
};

const _$WeightCategoryEnumMap = {
  WeightCategory.light: 'light',
  WeightCategory.medium: 'medium',
  WeightCategory.heavy: 'heavy',
  WeightCategory.veryHeavy: 'veryHeavy',
};

const _$PickupTargetEnumMap = {
  PickupTarget.company: 'company',
  PickupTarget.riderBuy: 'riderBuy',
};

const _$PaymentModelEnumMap = {
  PaymentModel.perKg: 'perKg',
  PaymentModel.flatFee: 'flatFee',
};

const _$CollectionDeliveryMethodEnumMap = {
  CollectionDeliveryMethod.selfDelivery: 'selfDelivery',
  CollectionDeliveryMethod.assignRider: 'assignRider',
};

const _$CollectionTransactionTypeEnumMap = {
  CollectionTransactionType.donate: 'donate',
  CollectionTransactionType.sell: 'sell',
};

const _$ArrivalConfirmationStatusEnumMap = {
  ArrivalConfirmationStatus.awaiting: 'awaiting',
  ArrivalConfirmationStatus.confirmed: 'confirmed',
  ArrivalConfirmationStatus.unavailable: 'unavailable',
  ArrivalConfirmationStatus.timedOut: 'timedOut',
};

const _$VehicleTypeEnumMap = {
  VehicleType.motorcycle: 'motorcycle',
  VehicleType.car: 'car',
  VehicleType.pickup: 'pickup',
  VehicleType.van: 'van',
  VehicleType.truck: 'truck',
  VehicleType.heavyTruck: 'heavyTruck',
};

const _$AdminApprovalStatusEnumMap = {
  AdminApprovalStatus.notRequired: 'notRequired',
  AdminApprovalStatus.pendingApproval: 'pendingApproval',
  AdminApprovalStatus.approved: 'approved',
  AdminApprovalStatus.rejected: 'rejected',
};

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 'pending',
  ReservationStatus.accepted: 'accepted',
  ReservationStatus.rejected: 'rejected',
  ReservationStatus.cancelledByBuyer: 'cancelledByBuyer',
  ReservationStatus.cancelledBySeller: 'cancelledBySeller',
  ReservationStatus.completedByReservation: 'completedByReservation',
};
