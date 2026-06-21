// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
mixin _$Order {
  String get id => throw _privateConstructorUsedError;
  OrderType get type => throw _privateConstructorUsedError;
  List<WasteType> get wasteTypes => throw _privateConstructorUsedError;
  String get pickupAddress => throw _privateConstructorUsedError;
  String get dropoffAddress => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  double get reward => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get acceptedAt => throw _privateConstructorUsedError;
  DateTime? get inTransitAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  String? get driverName => throw _privateConstructorUsedError;
  String? get driverPhone => throw _privateConstructorUsedError;
  double? get driverRating => throw _privateConstructorUsedError;
  String? get driverVehicle => throw _privateConstructorUsedError;
  String? get driverVehicleModel => throw _privateConstructorUsedError;
  String? get driverVehicleColor => throw _privateConstructorUsedError;
  String? get driverLicensePlate => throw _privateConstructorUsedError;
  String? get driverVehiclePhotoPath => throw _privateConstructorUsedError;
  String? get supplierId => throw _privateConstructorUsedError;
  String? get supplierName => throw _privateConstructorUsedError;
  String? get supplierPhone => throw _privateConstructorUsedError;
  double? get weightKg => throw _privateConstructorUsedError;
  String? get eta => throw _privateConstructorUsedError;
  double? get distanceKm => throw _privateConstructorUsedError;
  String? get proofImagePath => throw _privateConstructorUsedError;
  double? get paidAmount => throw _privateConstructorUsedError;
  String? get supplierNotes => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  double? get estimatedWeightKg => throw _privateConstructorUsedError;
  WasteForm? get wasteForm => throw _privateConstructorUsedError;
  WeightCategory? get weightCategory => throw _privateConstructorUsedError;
  double? get deliveryFee => throw _privateConstructorUsedError;
  PickupTarget? get pickupTarget => throw _privateConstructorUsedError;
  double? get itemPrice => throw _privateConstructorUsedError;
  String? get jobDescription => throw _privateConstructorUsedError;
  double? get pricePerKg => throw _privateConstructorUsedError;
  PaymentModel? get paymentModel => throw _privateConstructorUsedError;
  double? get minQuantityKg => throw _privateConstructorUsedError;
  bool get isEdited => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;
  String? get editNote => throw _privateConstructorUsedError;
  String? get linkedJobId => throw _privateConstructorUsedError;
  CollectionDeliveryMethod? get collectionDeliveryMethod =>
      throw _privateConstructorUsedError;
  CollectionTransactionType? get collectionTransactionType =>
      throw _privateConstructorUsedError;
  double? get pickupLat => throw _privateConstructorUsedError;
  double? get pickupLng => throw _privateConstructorUsedError;
  double? get dropoffLat => throw _privateConstructorUsedError;
  double? get dropoffLng => throw _privateConstructorUsedError;
  int? get etaMinutes => throw _privateConstructorUsedError;
  bool get isMarketplaceShared => throw _privateConstructorUsedError;
  bool get requiresRider => throw _privateConstructorUsedError;
  RewardBreakdown? get rewardBreakdown => throw _privateConstructorUsedError;
  List<InvoiceItem>? get invoices => throw _privateConstructorUsedError;
  DateTime? get arrivedAtPickupAt => throw _privateConstructorUsedError;
  DateTime? get arrivedAtDropoffAt => throw _privateConstructorUsedError;
  ArrivalConfirmationStatus? get arrivalConfirmationStatus =>
      throw _privateConstructorUsedError;
  OrderProof? get proof => throw _privateConstructorUsedError;
  double? get supplierHoldAmount => throw _privateConstructorUsedError;
  double? get driverCompensationAmount => throw _privateConstructorUsedError;
  int get fraudAttemptCount => throw _privateConstructorUsedError;
  bool get weightVarianceFlag => throw _privateConstructorUsedError;
  VehicleType? get requiredVehicleType => throw _privateConstructorUsedError;
  bool get requiresChemicalPermit => throw _privateConstructorUsedError;
  AdminApprovalStatus get adminApprovalStatus =>
      throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  bool get isVatApplicable => throw _privateConstructorUsedError;
  double? get vatAmountJd => throw _privateConstructorUsedError;

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call({
    String id,
    OrderType type,
    List<WasteType> wasteTypes,
    String pickupAddress,
    String dropoffAddress,
    OrderStatus status,
    double reward,
    DateTime createdAt,
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
    List<String> images,
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
    bool isEdited,
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
    bool isMarketplaceShared,
    bool requiresRider,
    RewardBreakdown? rewardBreakdown,
    List<InvoiceItem>? invoices,
    DateTime? arrivedAtPickupAt,
    DateTime? arrivedAtDropoffAt,
    ArrivalConfirmationStatus? arrivalConfirmationStatus,
    OrderProof? proof,
    double? supplierHoldAmount,
    double? driverCompensationAmount,
    int fraudAttemptCount,
    bool weightVarianceFlag,
    VehicleType? requiredVehicleType,
    bool requiresChemicalPermit,
    AdminApprovalStatus adminApprovalStatus,
    DateTime? expiresAt,
    bool isVatApplicable,
    double? vatAmountJd,
  });

  $OrderProofCopyWith<$Res>? get proof;
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? wasteTypes = null,
    Object? pickupAddress = null,
    Object? dropoffAddress = null,
    Object? status = null,
    Object? reward = null,
    Object? createdAt = null,
    Object? acceptedAt = freezed,
    Object? inTransitAt = freezed,
    Object? completedAt = freezed,
    Object? scheduledAt = freezed,
    Object? driverName = freezed,
    Object? driverPhone = freezed,
    Object? driverRating = freezed,
    Object? driverVehicle = freezed,
    Object? driverVehicleModel = freezed,
    Object? driverVehicleColor = freezed,
    Object? driverLicensePlate = freezed,
    Object? driverVehiclePhotoPath = freezed,
    Object? supplierId = freezed,
    Object? supplierName = freezed,
    Object? supplierPhone = freezed,
    Object? weightKg = freezed,
    Object? eta = freezed,
    Object? distanceKm = freezed,
    Object? proofImagePath = freezed,
    Object? paidAmount = freezed,
    Object? supplierNotes = freezed,
    Object? images = null,
    Object? estimatedWeightKg = freezed,
    Object? wasteForm = freezed,
    Object? weightCategory = freezed,
    Object? deliveryFee = freezed,
    Object? pickupTarget = freezed,
    Object? itemPrice = freezed,
    Object? jobDescription = freezed,
    Object? pricePerKg = freezed,
    Object? paymentModel = freezed,
    Object? minQuantityKg = freezed,
    Object? isEdited = null,
    Object? editedAt = freezed,
    Object? editNote = freezed,
    Object? linkedJobId = freezed,
    Object? collectionDeliveryMethod = freezed,
    Object? collectionTransactionType = freezed,
    Object? pickupLat = freezed,
    Object? pickupLng = freezed,
    Object? dropoffLat = freezed,
    Object? dropoffLng = freezed,
    Object? etaMinutes = freezed,
    Object? isMarketplaceShared = null,
    Object? requiresRider = null,
    Object? rewardBreakdown = freezed,
    Object? invoices = freezed,
    Object? arrivedAtPickupAt = freezed,
    Object? arrivedAtDropoffAt = freezed,
    Object? arrivalConfirmationStatus = freezed,
    Object? proof = freezed,
    Object? supplierHoldAmount = freezed,
    Object? driverCompensationAmount = freezed,
    Object? fraudAttemptCount = null,
    Object? weightVarianceFlag = null,
    Object? requiredVehicleType = freezed,
    Object? requiresChemicalPermit = null,
    Object? adminApprovalStatus = null,
    Object? expiresAt = freezed,
    Object? isVatApplicable = null,
    Object? vatAmountJd = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as OrderType,
            wasteTypes: null == wasteTypes
                ? _value.wasteTypes
                : wasteTypes // ignore: cast_nullable_to_non_nullable
                      as List<WasteType>,
            pickupAddress: null == pickupAddress
                ? _value.pickupAddress
                : pickupAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            dropoffAddress: null == dropoffAddress
                ? _value.dropoffAddress
                : dropoffAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrderStatus,
            reward: null == reward
                ? _value.reward
                : reward // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            acceptedAt: freezed == acceptedAt
                ? _value.acceptedAt
                : acceptedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            inTransitAt: freezed == inTransitAt
                ? _value.inTransitAt
                : inTransitAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            scheduledAt: freezed == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            driverName: freezed == driverName
                ? _value.driverName
                : driverName // ignore: cast_nullable_to_non_nullable
                      as String?,
            driverPhone: freezed == driverPhone
                ? _value.driverPhone
                : driverPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            driverRating: freezed == driverRating
                ? _value.driverRating
                : driverRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            driverVehicle: freezed == driverVehicle
                ? _value.driverVehicle
                : driverVehicle // ignore: cast_nullable_to_non_nullable
                      as String?,
            driverVehicleModel: freezed == driverVehicleModel
                ? _value.driverVehicleModel
                : driverVehicleModel // ignore: cast_nullable_to_non_nullable
                      as String?,
            driverVehicleColor: freezed == driverVehicleColor
                ? _value.driverVehicleColor
                : driverVehicleColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            driverLicensePlate: freezed == driverLicensePlate
                ? _value.driverLicensePlate
                : driverLicensePlate // ignore: cast_nullable_to_non_nullable
                      as String?,
            driverVehiclePhotoPath: freezed == driverVehiclePhotoPath
                ? _value.driverVehiclePhotoPath
                : driverVehiclePhotoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            supplierId: freezed == supplierId
                ? _value.supplierId
                : supplierId // ignore: cast_nullable_to_non_nullable
                      as String?,
            supplierName: freezed == supplierName
                ? _value.supplierName
                : supplierName // ignore: cast_nullable_to_non_nullable
                      as String?,
            supplierPhone: freezed == supplierPhone
                ? _value.supplierPhone
                : supplierPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            weightKg: freezed == weightKg
                ? _value.weightKg
                : weightKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            eta: freezed == eta
                ? _value.eta
                : eta // ignore: cast_nullable_to_non_nullable
                      as String?,
            distanceKm: freezed == distanceKm
                ? _value.distanceKm
                : distanceKm // ignore: cast_nullable_to_non_nullable
                      as double?,
            proofImagePath: freezed == proofImagePath
                ? _value.proofImagePath
                : proofImagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            paidAmount: freezed == paidAmount
                ? _value.paidAmount
                : paidAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            supplierNotes: freezed == supplierNotes
                ? _value.supplierNotes
                : supplierNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            estimatedWeightKg: freezed == estimatedWeightKg
                ? _value.estimatedWeightKg
                : estimatedWeightKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            wasteForm: freezed == wasteForm
                ? _value.wasteForm
                : wasteForm // ignore: cast_nullable_to_non_nullable
                      as WasteForm?,
            weightCategory: freezed == weightCategory
                ? _value.weightCategory
                : weightCategory // ignore: cast_nullable_to_non_nullable
                      as WeightCategory?,
            deliveryFee: freezed == deliveryFee
                ? _value.deliveryFee
                : deliveryFee // ignore: cast_nullable_to_non_nullable
                      as double?,
            pickupTarget: freezed == pickupTarget
                ? _value.pickupTarget
                : pickupTarget // ignore: cast_nullable_to_non_nullable
                      as PickupTarget?,
            itemPrice: freezed == itemPrice
                ? _value.itemPrice
                : itemPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            jobDescription: freezed == jobDescription
                ? _value.jobDescription
                : jobDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            pricePerKg: freezed == pricePerKg
                ? _value.pricePerKg
                : pricePerKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            paymentModel: freezed == paymentModel
                ? _value.paymentModel
                : paymentModel // ignore: cast_nullable_to_non_nullable
                      as PaymentModel?,
            minQuantityKg: freezed == minQuantityKg
                ? _value.minQuantityKg
                : minQuantityKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            isEdited: null == isEdited
                ? _value.isEdited
                : isEdited // ignore: cast_nullable_to_non_nullable
                      as bool,
            editedAt: freezed == editedAt
                ? _value.editedAt
                : editedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            editNote: freezed == editNote
                ? _value.editNote
                : editNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            linkedJobId: freezed == linkedJobId
                ? _value.linkedJobId
                : linkedJobId // ignore: cast_nullable_to_non_nullable
                      as String?,
            collectionDeliveryMethod: freezed == collectionDeliveryMethod
                ? _value.collectionDeliveryMethod
                : collectionDeliveryMethod // ignore: cast_nullable_to_non_nullable
                      as CollectionDeliveryMethod?,
            collectionTransactionType: freezed == collectionTransactionType
                ? _value.collectionTransactionType
                : collectionTransactionType // ignore: cast_nullable_to_non_nullable
                      as CollectionTransactionType?,
            pickupLat: freezed == pickupLat
                ? _value.pickupLat
                : pickupLat // ignore: cast_nullable_to_non_nullable
                      as double?,
            pickupLng: freezed == pickupLng
                ? _value.pickupLng
                : pickupLng // ignore: cast_nullable_to_non_nullable
                      as double?,
            dropoffLat: freezed == dropoffLat
                ? _value.dropoffLat
                : dropoffLat // ignore: cast_nullable_to_non_nullable
                      as double?,
            dropoffLng: freezed == dropoffLng
                ? _value.dropoffLng
                : dropoffLng // ignore: cast_nullable_to_non_nullable
                      as double?,
            etaMinutes: freezed == etaMinutes
                ? _value.etaMinutes
                : etaMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            isMarketplaceShared: null == isMarketplaceShared
                ? _value.isMarketplaceShared
                : isMarketplaceShared // ignore: cast_nullable_to_non_nullable
                      as bool,
            requiresRider: null == requiresRider
                ? _value.requiresRider
                : requiresRider // ignore: cast_nullable_to_non_nullable
                      as bool,
            rewardBreakdown: freezed == rewardBreakdown
                ? _value.rewardBreakdown
                : rewardBreakdown // ignore: cast_nullable_to_non_nullable
                      as RewardBreakdown?,
            invoices: freezed == invoices
                ? _value.invoices
                : invoices // ignore: cast_nullable_to_non_nullable
                      as List<InvoiceItem>?,
            arrivedAtPickupAt: freezed == arrivedAtPickupAt
                ? _value.arrivedAtPickupAt
                : arrivedAtPickupAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            arrivedAtDropoffAt: freezed == arrivedAtDropoffAt
                ? _value.arrivedAtDropoffAt
                : arrivedAtDropoffAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            arrivalConfirmationStatus: freezed == arrivalConfirmationStatus
                ? _value.arrivalConfirmationStatus
                : arrivalConfirmationStatus // ignore: cast_nullable_to_non_nullable
                      as ArrivalConfirmationStatus?,
            proof: freezed == proof
                ? _value.proof
                : proof // ignore: cast_nullable_to_non_nullable
                      as OrderProof?,
            supplierHoldAmount: freezed == supplierHoldAmount
                ? _value.supplierHoldAmount
                : supplierHoldAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            driverCompensationAmount: freezed == driverCompensationAmount
                ? _value.driverCompensationAmount
                : driverCompensationAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            fraudAttemptCount: null == fraudAttemptCount
                ? _value.fraudAttemptCount
                : fraudAttemptCount // ignore: cast_nullable_to_non_nullable
                      as int,
            weightVarianceFlag: null == weightVarianceFlag
                ? _value.weightVarianceFlag
                : weightVarianceFlag // ignore: cast_nullable_to_non_nullable
                      as bool,
            requiredVehicleType: freezed == requiredVehicleType
                ? _value.requiredVehicleType
                : requiredVehicleType // ignore: cast_nullable_to_non_nullable
                      as VehicleType?,
            requiresChemicalPermit: null == requiresChemicalPermit
                ? _value.requiresChemicalPermit
                : requiresChemicalPermit // ignore: cast_nullable_to_non_nullable
                      as bool,
            adminApprovalStatus: null == adminApprovalStatus
                ? _value.adminApprovalStatus
                : adminApprovalStatus // ignore: cast_nullable_to_non_nullable
                      as AdminApprovalStatus,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isVatApplicable: null == isVatApplicable
                ? _value.isVatApplicable
                : isVatApplicable // ignore: cast_nullable_to_non_nullable
                      as bool,
            vatAmountJd: freezed == vatAmountJd
                ? _value.vatAmountJd
                : vatAmountJd // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderProofCopyWith<$Res>? get proof {
    if (_value.proof == null) {
      return null;
    }

    return $OrderProofCopyWith<$Res>(_value.proof!, (value) {
      return _then(_value.copyWith(proof: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
    _$OrderImpl value,
    $Res Function(_$OrderImpl) then,
  ) = __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    OrderType type,
    List<WasteType> wasteTypes,
    String pickupAddress,
    String dropoffAddress,
    OrderStatus status,
    double reward,
    DateTime createdAt,
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
    List<String> images,
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
    bool isEdited,
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
    bool isMarketplaceShared,
    bool requiresRider,
    RewardBreakdown? rewardBreakdown,
    List<InvoiceItem>? invoices,
    DateTime? arrivedAtPickupAt,
    DateTime? arrivedAtDropoffAt,
    ArrivalConfirmationStatus? arrivalConfirmationStatus,
    OrderProof? proof,
    double? supplierHoldAmount,
    double? driverCompensationAmount,
    int fraudAttemptCount,
    bool weightVarianceFlag,
    VehicleType? requiredVehicleType,
    bool requiresChemicalPermit,
    AdminApprovalStatus adminApprovalStatus,
    DateTime? expiresAt,
    bool isVatApplicable,
    double? vatAmountJd,
  });

  @override
  $OrderProofCopyWith<$Res>? get proof;
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
    _$OrderImpl _value,
    $Res Function(_$OrderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? wasteTypes = null,
    Object? pickupAddress = null,
    Object? dropoffAddress = null,
    Object? status = null,
    Object? reward = null,
    Object? createdAt = null,
    Object? acceptedAt = freezed,
    Object? inTransitAt = freezed,
    Object? completedAt = freezed,
    Object? scheduledAt = freezed,
    Object? driverName = freezed,
    Object? driverPhone = freezed,
    Object? driverRating = freezed,
    Object? driverVehicle = freezed,
    Object? driverVehicleModel = freezed,
    Object? driverVehicleColor = freezed,
    Object? driverLicensePlate = freezed,
    Object? driverVehiclePhotoPath = freezed,
    Object? supplierId = freezed,
    Object? supplierName = freezed,
    Object? supplierPhone = freezed,
    Object? weightKg = freezed,
    Object? eta = freezed,
    Object? distanceKm = freezed,
    Object? proofImagePath = freezed,
    Object? paidAmount = freezed,
    Object? supplierNotes = freezed,
    Object? images = null,
    Object? estimatedWeightKg = freezed,
    Object? wasteForm = freezed,
    Object? weightCategory = freezed,
    Object? deliveryFee = freezed,
    Object? pickupTarget = freezed,
    Object? itemPrice = freezed,
    Object? jobDescription = freezed,
    Object? pricePerKg = freezed,
    Object? paymentModel = freezed,
    Object? minQuantityKg = freezed,
    Object? isEdited = null,
    Object? editedAt = freezed,
    Object? editNote = freezed,
    Object? linkedJobId = freezed,
    Object? collectionDeliveryMethod = freezed,
    Object? collectionTransactionType = freezed,
    Object? pickupLat = freezed,
    Object? pickupLng = freezed,
    Object? dropoffLat = freezed,
    Object? dropoffLng = freezed,
    Object? etaMinutes = freezed,
    Object? isMarketplaceShared = null,
    Object? requiresRider = null,
    Object? rewardBreakdown = freezed,
    Object? invoices = freezed,
    Object? arrivedAtPickupAt = freezed,
    Object? arrivedAtDropoffAt = freezed,
    Object? arrivalConfirmationStatus = freezed,
    Object? proof = freezed,
    Object? supplierHoldAmount = freezed,
    Object? driverCompensationAmount = freezed,
    Object? fraudAttemptCount = null,
    Object? weightVarianceFlag = null,
    Object? requiredVehicleType = freezed,
    Object? requiresChemicalPermit = null,
    Object? adminApprovalStatus = null,
    Object? expiresAt = freezed,
    Object? isVatApplicable = null,
    Object? vatAmountJd = freezed,
  }) {
    return _then(
      _$OrderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as OrderType,
        wasteTypes: null == wasteTypes
            ? _value._wasteTypes
            : wasteTypes // ignore: cast_nullable_to_non_nullable
                  as List<WasteType>,
        pickupAddress: null == pickupAddress
            ? _value.pickupAddress
            : pickupAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        dropoffAddress: null == dropoffAddress
            ? _value.dropoffAddress
            : dropoffAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrderStatus,
        reward: null == reward
            ? _value.reward
            : reward // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        acceptedAt: freezed == acceptedAt
            ? _value.acceptedAt
            : acceptedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        inTransitAt: freezed == inTransitAt
            ? _value.inTransitAt
            : inTransitAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        scheduledAt: freezed == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        driverName: freezed == driverName
            ? _value.driverName
            : driverName // ignore: cast_nullable_to_non_nullable
                  as String?,
        driverPhone: freezed == driverPhone
            ? _value.driverPhone
            : driverPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        driverRating: freezed == driverRating
            ? _value.driverRating
            : driverRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        driverVehicle: freezed == driverVehicle
            ? _value.driverVehicle
            : driverVehicle // ignore: cast_nullable_to_non_nullable
                  as String?,
        driverVehicleModel: freezed == driverVehicleModel
            ? _value.driverVehicleModel
            : driverVehicleModel // ignore: cast_nullable_to_non_nullable
                  as String?,
        driverVehicleColor: freezed == driverVehicleColor
            ? _value.driverVehicleColor
            : driverVehicleColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        driverLicensePlate: freezed == driverLicensePlate
            ? _value.driverLicensePlate
            : driverLicensePlate // ignore: cast_nullable_to_non_nullable
                  as String?,
        driverVehiclePhotoPath: freezed == driverVehiclePhotoPath
            ? _value.driverVehiclePhotoPath
            : driverVehiclePhotoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        supplierId: freezed == supplierId
            ? _value.supplierId
            : supplierId // ignore: cast_nullable_to_non_nullable
                  as String?,
        supplierName: freezed == supplierName
            ? _value.supplierName
            : supplierName // ignore: cast_nullable_to_non_nullable
                  as String?,
        supplierPhone: freezed == supplierPhone
            ? _value.supplierPhone
            : supplierPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        weightKg: freezed == weightKg
            ? _value.weightKg
            : weightKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        eta: freezed == eta
            ? _value.eta
            : eta // ignore: cast_nullable_to_non_nullable
                  as String?,
        distanceKm: freezed == distanceKm
            ? _value.distanceKm
            : distanceKm // ignore: cast_nullable_to_non_nullable
                  as double?,
        proofImagePath: freezed == proofImagePath
            ? _value.proofImagePath
            : proofImagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        paidAmount: freezed == paidAmount
            ? _value.paidAmount
            : paidAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        supplierNotes: freezed == supplierNotes
            ? _value.supplierNotes
            : supplierNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        estimatedWeightKg: freezed == estimatedWeightKg
            ? _value.estimatedWeightKg
            : estimatedWeightKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        wasteForm: freezed == wasteForm
            ? _value.wasteForm
            : wasteForm // ignore: cast_nullable_to_non_nullable
                  as WasteForm?,
        weightCategory: freezed == weightCategory
            ? _value.weightCategory
            : weightCategory // ignore: cast_nullable_to_non_nullable
                  as WeightCategory?,
        deliveryFee: freezed == deliveryFee
            ? _value.deliveryFee
            : deliveryFee // ignore: cast_nullable_to_non_nullable
                  as double?,
        pickupTarget: freezed == pickupTarget
            ? _value.pickupTarget
            : pickupTarget // ignore: cast_nullable_to_non_nullable
                  as PickupTarget?,
        itemPrice: freezed == itemPrice
            ? _value.itemPrice
            : itemPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        jobDescription: freezed == jobDescription
            ? _value.jobDescription
            : jobDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        pricePerKg: freezed == pricePerKg
            ? _value.pricePerKg
            : pricePerKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        paymentModel: freezed == paymentModel
            ? _value.paymentModel
            : paymentModel // ignore: cast_nullable_to_non_nullable
                  as PaymentModel?,
        minQuantityKg: freezed == minQuantityKg
            ? _value.minQuantityKg
            : minQuantityKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        isEdited: null == isEdited
            ? _value.isEdited
            : isEdited // ignore: cast_nullable_to_non_nullable
                  as bool,
        editedAt: freezed == editedAt
            ? _value.editedAt
            : editedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        editNote: freezed == editNote
            ? _value.editNote
            : editNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        linkedJobId: freezed == linkedJobId
            ? _value.linkedJobId
            : linkedJobId // ignore: cast_nullable_to_non_nullable
                  as String?,
        collectionDeliveryMethod: freezed == collectionDeliveryMethod
            ? _value.collectionDeliveryMethod
            : collectionDeliveryMethod // ignore: cast_nullable_to_non_nullable
                  as CollectionDeliveryMethod?,
        collectionTransactionType: freezed == collectionTransactionType
            ? _value.collectionTransactionType
            : collectionTransactionType // ignore: cast_nullable_to_non_nullable
                  as CollectionTransactionType?,
        pickupLat: freezed == pickupLat
            ? _value.pickupLat
            : pickupLat // ignore: cast_nullable_to_non_nullable
                  as double?,
        pickupLng: freezed == pickupLng
            ? _value.pickupLng
            : pickupLng // ignore: cast_nullable_to_non_nullable
                  as double?,
        dropoffLat: freezed == dropoffLat
            ? _value.dropoffLat
            : dropoffLat // ignore: cast_nullable_to_non_nullable
                  as double?,
        dropoffLng: freezed == dropoffLng
            ? _value.dropoffLng
            : dropoffLng // ignore: cast_nullable_to_non_nullable
                  as double?,
        etaMinutes: freezed == etaMinutes
            ? _value.etaMinutes
            : etaMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        isMarketplaceShared: null == isMarketplaceShared
            ? _value.isMarketplaceShared
            : isMarketplaceShared // ignore: cast_nullable_to_non_nullable
                  as bool,
        requiresRider: null == requiresRider
            ? _value.requiresRider
            : requiresRider // ignore: cast_nullable_to_non_nullable
                  as bool,
        rewardBreakdown: freezed == rewardBreakdown
            ? _value.rewardBreakdown
            : rewardBreakdown // ignore: cast_nullable_to_non_nullable
                  as RewardBreakdown?,
        invoices: freezed == invoices
            ? _value._invoices
            : invoices // ignore: cast_nullable_to_non_nullable
                  as List<InvoiceItem>?,
        arrivedAtPickupAt: freezed == arrivedAtPickupAt
            ? _value.arrivedAtPickupAt
            : arrivedAtPickupAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        arrivedAtDropoffAt: freezed == arrivedAtDropoffAt
            ? _value.arrivedAtDropoffAt
            : arrivedAtDropoffAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        arrivalConfirmationStatus: freezed == arrivalConfirmationStatus
            ? _value.arrivalConfirmationStatus
            : arrivalConfirmationStatus // ignore: cast_nullable_to_non_nullable
                  as ArrivalConfirmationStatus?,
        proof: freezed == proof
            ? _value.proof
            : proof // ignore: cast_nullable_to_non_nullable
                  as OrderProof?,
        supplierHoldAmount: freezed == supplierHoldAmount
            ? _value.supplierHoldAmount
            : supplierHoldAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        driverCompensationAmount: freezed == driverCompensationAmount
            ? _value.driverCompensationAmount
            : driverCompensationAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        fraudAttemptCount: null == fraudAttemptCount
            ? _value.fraudAttemptCount
            : fraudAttemptCount // ignore: cast_nullable_to_non_nullable
                  as int,
        weightVarianceFlag: null == weightVarianceFlag
            ? _value.weightVarianceFlag
            : weightVarianceFlag // ignore: cast_nullable_to_non_nullable
                  as bool,
        requiredVehicleType: freezed == requiredVehicleType
            ? _value.requiredVehicleType
            : requiredVehicleType // ignore: cast_nullable_to_non_nullable
                  as VehicleType?,
        requiresChemicalPermit: null == requiresChemicalPermit
            ? _value.requiresChemicalPermit
            : requiresChemicalPermit // ignore: cast_nullable_to_non_nullable
                  as bool,
        adminApprovalStatus: null == adminApprovalStatus
            ? _value.adminApprovalStatus
            : adminApprovalStatus // ignore: cast_nullable_to_non_nullable
                  as AdminApprovalStatus,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isVatApplicable: null == isVatApplicable
            ? _value.isVatApplicable
            : isVatApplicable // ignore: cast_nullable_to_non_nullable
                  as bool,
        vatAmountJd: freezed == vatAmountJd
            ? _value.vatAmountJd
            : vatAmountJd // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl implements _Order {
  const _$OrderImpl({
    required this.id,
    required this.type,
    required final List<WasteType> wasteTypes,
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
    this.supplierId,
    this.supplierName,
    this.supplierPhone,
    this.weightKg,
    this.eta,
    this.distanceKm,
    this.proofImagePath,
    this.paidAmount,
    this.supplierNotes,
    final List<String> images = const [],
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
    final List<InvoiceItem>? invoices,
    this.arrivedAtPickupAt,
    this.arrivedAtDropoffAt,
    this.arrivalConfirmationStatus,
    this.proof,
    this.supplierHoldAmount,
    this.driverCompensationAmount,
    this.fraudAttemptCount = 0,
    this.weightVarianceFlag = false,
    this.requiredVehicleType,
    this.requiresChemicalPermit = false,
    this.adminApprovalStatus = AdminApprovalStatus.notRequired,
    this.expiresAt,
    this.isVatApplicable = false,
    this.vatAmountJd,
  }) : _wasteTypes = wasteTypes,
       _images = images,
       _invoices = invoices;

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final String id;
  @override
  final OrderType type;
  final List<WasteType> _wasteTypes;
  @override
  List<WasteType> get wasteTypes {
    if (_wasteTypes is EqualUnmodifiableListView) return _wasteTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wasteTypes);
  }

  @override
  final String pickupAddress;
  @override
  final String dropoffAddress;
  @override
  final OrderStatus status;
  @override
  final double reward;
  @override
  final DateTime createdAt;
  @override
  final DateTime? acceptedAt;
  @override
  final DateTime? inTransitAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? scheduledAt;
  @override
  final String? driverName;
  @override
  final String? driverPhone;
  @override
  final double? driverRating;
  @override
  final String? driverVehicle;
  @override
  final String? driverVehicleModel;
  @override
  final String? driverVehicleColor;
  @override
  final String? driverLicensePlate;
  @override
  final String? driverVehiclePhotoPath;
  @override
  final String? supplierId;
  @override
  final String? supplierName;
  @override
  final String? supplierPhone;
  @override
  final double? weightKg;
  @override
  final String? eta;
  @override
  final double? distanceKm;
  @override
  final String? proofImagePath;
  @override
  final double? paidAmount;
  @override
  final String? supplierNotes;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final double? estimatedWeightKg;
  @override
  final WasteForm? wasteForm;
  @override
  final WeightCategory? weightCategory;
  @override
  final double? deliveryFee;
  @override
  final PickupTarget? pickupTarget;
  @override
  final double? itemPrice;
  @override
  final String? jobDescription;
  @override
  final double? pricePerKg;
  @override
  final PaymentModel? paymentModel;
  @override
  final double? minQuantityKg;
  @override
  @JsonKey()
  final bool isEdited;
  @override
  final DateTime? editedAt;
  @override
  final String? editNote;
  @override
  final String? linkedJobId;
  @override
  final CollectionDeliveryMethod? collectionDeliveryMethod;
  @override
  final CollectionTransactionType? collectionTransactionType;
  @override
  final double? pickupLat;
  @override
  final double? pickupLng;
  @override
  final double? dropoffLat;
  @override
  final double? dropoffLng;
  @override
  final int? etaMinutes;
  @override
  @JsonKey()
  final bool isMarketplaceShared;
  @override
  @JsonKey()
  final bool requiresRider;
  @override
  final RewardBreakdown? rewardBreakdown;
  final List<InvoiceItem>? _invoices;
  @override
  List<InvoiceItem>? get invoices {
    final value = _invoices;
    if (value == null) return null;
    if (_invoices is EqualUnmodifiableListView) return _invoices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? arrivedAtPickupAt;
  @override
  final DateTime? arrivedAtDropoffAt;
  @override
  final ArrivalConfirmationStatus? arrivalConfirmationStatus;
  @override
  final OrderProof? proof;
  @override
  final double? supplierHoldAmount;
  @override
  final double? driverCompensationAmount;
  @override
  @JsonKey()
  final int fraudAttemptCount;
  @override
  @JsonKey()
  final bool weightVarianceFlag;
  @override
  final VehicleType? requiredVehicleType;
  @override
  @JsonKey()
  final bool requiresChemicalPermit;
  @override
  @JsonKey()
  final AdminApprovalStatus adminApprovalStatus;
  @override
  final DateTime? expiresAt;
  @override
  @JsonKey()
  final bool isVatApplicable;
  @override
  final double? vatAmountJd;

  @override
  String toString() {
    return 'Order(id: $id, type: $type, wasteTypes: $wasteTypes, pickupAddress: $pickupAddress, dropoffAddress: $dropoffAddress, status: $status, reward: $reward, createdAt: $createdAt, acceptedAt: $acceptedAt, inTransitAt: $inTransitAt, completedAt: $completedAt, scheduledAt: $scheduledAt, driverName: $driverName, driverPhone: $driverPhone, driverRating: $driverRating, driverVehicle: $driverVehicle, driverVehicleModel: $driverVehicleModel, driverVehicleColor: $driverVehicleColor, driverLicensePlate: $driverLicensePlate, driverVehiclePhotoPath: $driverVehiclePhotoPath, supplierId: $supplierId, supplierName: $supplierName, supplierPhone: $supplierPhone, weightKg: $weightKg, eta: $eta, distanceKm: $distanceKm, proofImagePath: $proofImagePath, paidAmount: $paidAmount, supplierNotes: $supplierNotes, images: $images, estimatedWeightKg: $estimatedWeightKg, wasteForm: $wasteForm, weightCategory: $weightCategory, deliveryFee: $deliveryFee, pickupTarget: $pickupTarget, itemPrice: $itemPrice, jobDescription: $jobDescription, pricePerKg: $pricePerKg, paymentModel: $paymentModel, minQuantityKg: $minQuantityKg, isEdited: $isEdited, editedAt: $editedAt, editNote: $editNote, linkedJobId: $linkedJobId, collectionDeliveryMethod: $collectionDeliveryMethod, collectionTransactionType: $collectionTransactionType, pickupLat: $pickupLat, pickupLng: $pickupLng, dropoffLat: $dropoffLat, dropoffLng: $dropoffLng, etaMinutes: $etaMinutes, isMarketplaceShared: $isMarketplaceShared, requiresRider: $requiresRider, rewardBreakdown: $rewardBreakdown, invoices: $invoices, arrivedAtPickupAt: $arrivedAtPickupAt, arrivedAtDropoffAt: $arrivedAtDropoffAt, arrivalConfirmationStatus: $arrivalConfirmationStatus, proof: $proof, supplierHoldAmount: $supplierHoldAmount, driverCompensationAmount: $driverCompensationAmount, fraudAttemptCount: $fraudAttemptCount, weightVarianceFlag: $weightVarianceFlag, requiredVehicleType: $requiredVehicleType, requiresChemicalPermit: $requiresChemicalPermit, adminApprovalStatus: $adminApprovalStatus, expiresAt: $expiresAt, isVatApplicable: $isVatApplicable, vatAmountJd: $vatAmountJd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(
              other._wasteTypes,
              _wasteTypes,
            ) &&
            (identical(other.pickupAddress, pickupAddress) ||
                other.pickupAddress == pickupAddress) &&
            (identical(other.dropoffAddress, dropoffAddress) ||
                other.dropoffAddress == dropoffAddress) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reward, reward) || other.reward == reward) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
            (identical(other.inTransitAt, inTransitAt) ||
                other.inTransitAt == inTransitAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.driverName, driverName) ||
                other.driverName == driverName) &&
            (identical(other.driverPhone, driverPhone) ||
                other.driverPhone == driverPhone) &&
            (identical(other.driverRating, driverRating) ||
                other.driverRating == driverRating) &&
            (identical(other.driverVehicle, driverVehicle) ||
                other.driverVehicle == driverVehicle) &&
            (identical(other.driverVehicleModel, driverVehicleModel) ||
                other.driverVehicleModel == driverVehicleModel) &&
            (identical(other.driverVehicleColor, driverVehicleColor) ||
                other.driverVehicleColor == driverVehicleColor) &&
            (identical(other.driverLicensePlate, driverLicensePlate) ||
                other.driverLicensePlate == driverLicensePlate) &&
            (identical(other.driverVehiclePhotoPath, driverVehiclePhotoPath) ||
                other.driverVehiclePhotoPath == driverVehiclePhotoPath) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.supplierName, supplierName) ||
                other.supplierName == supplierName) &&
            (identical(other.supplierPhone, supplierPhone) ||
                other.supplierPhone == supplierPhone) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.eta, eta) || other.eta == eta) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.proofImagePath, proofImagePath) ||
                other.proofImagePath == proofImagePath) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.supplierNotes, supplierNotes) ||
                other.supplierNotes == supplierNotes) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.estimatedWeightKg, estimatedWeightKg) ||
                other.estimatedWeightKg == estimatedWeightKg) &&
            (identical(other.wasteForm, wasteForm) ||
                other.wasteForm == wasteForm) &&
            (identical(other.weightCategory, weightCategory) ||
                other.weightCategory == weightCategory) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.pickupTarget, pickupTarget) ||
                other.pickupTarget == pickupTarget) &&
            (identical(other.itemPrice, itemPrice) ||
                other.itemPrice == itemPrice) &&
            (identical(other.jobDescription, jobDescription) ||
                other.jobDescription == jobDescription) &&
            (identical(other.pricePerKg, pricePerKg) ||
                other.pricePerKg == pricePerKg) &&
            (identical(other.paymentModel, paymentModel) ||
                other.paymentModel == paymentModel) &&
            (identical(other.minQuantityKg, minQuantityKg) ||
                other.minQuantityKg == minQuantityKg) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.editNote, editNote) ||
                other.editNote == editNote) &&
            (identical(other.linkedJobId, linkedJobId) ||
                other.linkedJobId == linkedJobId) &&
            (identical(
                  other.collectionDeliveryMethod,
                  collectionDeliveryMethod,
                ) ||
                other.collectionDeliveryMethod == collectionDeliveryMethod) &&
            (identical(
                  other.collectionTransactionType,
                  collectionTransactionType,
                ) ||
                other.collectionTransactionType == collectionTransactionType) &&
            (identical(other.pickupLat, pickupLat) ||
                other.pickupLat == pickupLat) &&
            (identical(other.pickupLng, pickupLng) ||
                other.pickupLng == pickupLng) &&
            (identical(other.dropoffLat, dropoffLat) ||
                other.dropoffLat == dropoffLat) &&
            (identical(other.dropoffLng, dropoffLng) ||
                other.dropoffLng == dropoffLng) &&
            (identical(other.etaMinutes, etaMinutes) ||
                other.etaMinutes == etaMinutes) &&
            (identical(other.isMarketplaceShared, isMarketplaceShared) ||
                other.isMarketplaceShared == isMarketplaceShared) &&
            (identical(other.requiresRider, requiresRider) ||
                other.requiresRider == requiresRider) &&
            (identical(other.rewardBreakdown, rewardBreakdown) ||
                other.rewardBreakdown == rewardBreakdown) &&
            const DeepCollectionEquality().equals(other._invoices, _invoices) &&
            (identical(other.arrivedAtPickupAt, arrivedAtPickupAt) ||
                other.arrivedAtPickupAt == arrivedAtPickupAt) &&
            (identical(other.arrivedAtDropoffAt, arrivedAtDropoffAt) ||
                other.arrivedAtDropoffAt == arrivedAtDropoffAt) &&
            (identical(
                  other.arrivalConfirmationStatus,
                  arrivalConfirmationStatus,
                ) ||
                other.arrivalConfirmationStatus == arrivalConfirmationStatus) &&
            (identical(other.proof, proof) || other.proof == proof) &&
            (identical(other.supplierHoldAmount, supplierHoldAmount) ||
                other.supplierHoldAmount == supplierHoldAmount) &&
            (identical(
                  other.driverCompensationAmount,
                  driverCompensationAmount,
                ) ||
                other.driverCompensationAmount == driverCompensationAmount) &&
            (identical(other.fraudAttemptCount, fraudAttemptCount) ||
                other.fraudAttemptCount == fraudAttemptCount) &&
            (identical(other.weightVarianceFlag, weightVarianceFlag) ||
                other.weightVarianceFlag == weightVarianceFlag) &&
            (identical(other.requiredVehicleType, requiredVehicleType) ||
                other.requiredVehicleType == requiredVehicleType) &&
            (identical(other.requiresChemicalPermit, requiresChemicalPermit) ||
                other.requiresChemicalPermit == requiresChemicalPermit) &&
            (identical(other.adminApprovalStatus, adminApprovalStatus) ||
                other.adminApprovalStatus == adminApprovalStatus) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isVatApplicable, isVatApplicable) ||
                other.isVatApplicable == isVatApplicable) &&
            (identical(other.vatAmountJd, vatAmountJd) ||
                other.vatAmountJd == vatAmountJd));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    type,
    const DeepCollectionEquality().hash(_wasteTypes),
    pickupAddress,
    dropoffAddress,
    status,
    reward,
    createdAt,
    acceptedAt,
    inTransitAt,
    completedAt,
    scheduledAt,
    driverName,
    driverPhone,
    driverRating,
    driverVehicle,
    driverVehicleModel,
    driverVehicleColor,
    driverLicensePlate,
    driverVehiclePhotoPath,
    supplierId,
    supplierName,
    supplierPhone,
    weightKg,
    eta,
    distanceKm,
    proofImagePath,
    paidAmount,
    supplierNotes,
    const DeepCollectionEquality().hash(_images),
    estimatedWeightKg,
    wasteForm,
    weightCategory,
    deliveryFee,
    pickupTarget,
    itemPrice,
    jobDescription,
    pricePerKg,
    paymentModel,
    minQuantityKg,
    isEdited,
    editedAt,
    editNote,
    linkedJobId,
    collectionDeliveryMethod,
    collectionTransactionType,
    pickupLat,
    pickupLng,
    dropoffLat,
    dropoffLng,
    etaMinutes,
    isMarketplaceShared,
    requiresRider,
    rewardBreakdown,
    const DeepCollectionEquality().hash(_invoices),
    arrivedAtPickupAt,
    arrivedAtDropoffAt,
    arrivalConfirmationStatus,
    proof,
    supplierHoldAmount,
    driverCompensationAmount,
    fraudAttemptCount,
    weightVarianceFlag,
    requiredVehicleType,
    requiresChemicalPermit,
    adminApprovalStatus,
    expiresAt,
    isVatApplicable,
    vatAmountJd,
  ]);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(this);
  }
}

abstract class _Order implements Order {
  const factory _Order({
    required final String id,
    required final OrderType type,
    required final List<WasteType> wasteTypes,
    required final String pickupAddress,
    required final String dropoffAddress,
    required final OrderStatus status,
    required final double reward,
    required final DateTime createdAt,
    final DateTime? acceptedAt,
    final DateTime? inTransitAt,
    final DateTime? completedAt,
    final DateTime? scheduledAt,
    final String? driverName,
    final String? driverPhone,
    final double? driverRating,
    final String? driverVehicle,
    final String? driverVehicleModel,
    final String? driverVehicleColor,
    final String? driverLicensePlate,
    final String? driverVehiclePhotoPath,
    final String? supplierId,
    final String? supplierName,
    final String? supplierPhone,
    final double? weightKg,
    final String? eta,
    final double? distanceKm,
    final String? proofImagePath,
    final double? paidAmount,
    final String? supplierNotes,
    final List<String> images,
    final double? estimatedWeightKg,
    final WasteForm? wasteForm,
    final WeightCategory? weightCategory,
    final double? deliveryFee,
    final PickupTarget? pickupTarget,
    final double? itemPrice,
    final String? jobDescription,
    final double? pricePerKg,
    final PaymentModel? paymentModel,
    final double? minQuantityKg,
    final bool isEdited,
    final DateTime? editedAt,
    final String? editNote,
    final String? linkedJobId,
    final CollectionDeliveryMethod? collectionDeliveryMethod,
    final CollectionTransactionType? collectionTransactionType,
    final double? pickupLat,
    final double? pickupLng,
    final double? dropoffLat,
    final double? dropoffLng,
    final int? etaMinutes,
    final bool isMarketplaceShared,
    final bool requiresRider,
    final RewardBreakdown? rewardBreakdown,
    final List<InvoiceItem>? invoices,
    final DateTime? arrivedAtPickupAt,
    final DateTime? arrivedAtDropoffAt,
    final ArrivalConfirmationStatus? arrivalConfirmationStatus,
    final OrderProof? proof,
    final double? supplierHoldAmount,
    final double? driverCompensationAmount,
    final int fraudAttemptCount,
    final bool weightVarianceFlag,
    final VehicleType? requiredVehicleType,
    final bool requiresChemicalPermit,
    final AdminApprovalStatus adminApprovalStatus,
    final DateTime? expiresAt,
    final bool isVatApplicable,
    final double? vatAmountJd,
  }) = _$OrderImpl;

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  String get id;
  @override
  OrderType get type;
  @override
  List<WasteType> get wasteTypes;
  @override
  String get pickupAddress;
  @override
  String get dropoffAddress;
  @override
  OrderStatus get status;
  @override
  double get reward;
  @override
  DateTime get createdAt;
  @override
  DateTime? get acceptedAt;
  @override
  DateTime? get inTransitAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get scheduledAt;
  @override
  String? get driverName;
  @override
  String? get driverPhone;
  @override
  double? get driverRating;
  @override
  String? get driverVehicle;
  @override
  String? get driverVehicleModel;
  @override
  String? get driverVehicleColor;
  @override
  String? get driverLicensePlate;
  @override
  String? get driverVehiclePhotoPath;
  @override
  String? get supplierId;
  @override
  String? get supplierName;
  @override
  String? get supplierPhone;
  @override
  double? get weightKg;
  @override
  String? get eta;
  @override
  double? get distanceKm;
  @override
  String? get proofImagePath;
  @override
  double? get paidAmount;
  @override
  String? get supplierNotes;
  @override
  List<String> get images;
  @override
  double? get estimatedWeightKg;
  @override
  WasteForm? get wasteForm;
  @override
  WeightCategory? get weightCategory;
  @override
  double? get deliveryFee;
  @override
  PickupTarget? get pickupTarget;
  @override
  double? get itemPrice;
  @override
  String? get jobDescription;
  @override
  double? get pricePerKg;
  @override
  PaymentModel? get paymentModel;
  @override
  double? get minQuantityKg;
  @override
  bool get isEdited;
  @override
  DateTime? get editedAt;
  @override
  String? get editNote;
  @override
  String? get linkedJobId;
  @override
  CollectionDeliveryMethod? get collectionDeliveryMethod;
  @override
  CollectionTransactionType? get collectionTransactionType;
  @override
  double? get pickupLat;
  @override
  double? get pickupLng;
  @override
  double? get dropoffLat;
  @override
  double? get dropoffLng;
  @override
  int? get etaMinutes;
  @override
  bool get isMarketplaceShared;
  @override
  bool get requiresRider;
  @override
  RewardBreakdown? get rewardBreakdown;
  @override
  List<InvoiceItem>? get invoices;
  @override
  DateTime? get arrivedAtPickupAt;
  @override
  DateTime? get arrivedAtDropoffAt;
  @override
  ArrivalConfirmationStatus? get arrivalConfirmationStatus;
  @override
  OrderProof? get proof;
  @override
  double? get supplierHoldAmount;
  @override
  double? get driverCompensationAmount;
  @override
  int get fraudAttemptCount;
  @override
  bool get weightVarianceFlag;
  @override
  VehicleType? get requiredVehicleType;
  @override
  bool get requiresChemicalPermit;
  @override
  AdminApprovalStatus get adminApprovalStatus;
  @override
  DateTime? get expiresAt;
  @override
  bool get isVatApplicable;
  @override
  double? get vatAmountJd;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
