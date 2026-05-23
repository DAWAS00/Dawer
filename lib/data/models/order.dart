import 'reward_breakdown.dart';

enum OrderType { pickup, collection, collectionSale }
enum OrderMode { pickup, marketplace }

enum OrderStatus {
 pending, accepted, arrivedAtPickup, inTransit, arrivedAtDropoff, completed, cancelled }

enum ArrivalConfirmationStatus { awaiting, confirmed, unavailable, timedOut }

enum PickupTarget { company, riderBuy }
enum WasteType {
  paper, plastic, metal, glass, electronics, organic,
  textile, wood, rubber, oil, chemicals, batteries, furniture, tires, construction,
  copperAluminium,
}

enum VehicleType { motorcycle, car, pickup, van, truck, heavyTruck }

enum AdminApprovalStatus { notRequired, pendingApproval, approved, rejected }

enum WasteForm { solid, liquid, gas, mixed }

enum PaymentModel { perKg, flatFee }

enum WeightCategory { light, medium, heavy, veryHeavy }

enum CollectionDeliveryMethod { selfDelivery, assignRider }
enum CollectionTransactionType { donate, sell }

extension CollectionDeliveryMethodLabel on CollectionDeliveryMethod {
  String get label => switch (this) {
    CollectionDeliveryMethod.selfDelivery => 'أوصّل بنفسي',
    CollectionDeliveryMethod.assignRider  => 'أعيّن سائقاً',
  };
  String get description => switch (this) {
    CollectionDeliveryMethod.selfDelivery => 'ستوصل المواد بنفسك',
    CollectionDeliveryMethod.assignRider  => 'سيتم تعيين سائق لك',
  };
}

extension CollectionTransactionTypeLabel on CollectionTransactionType {
  String get label => switch (this) {
    CollectionTransactionType.donate => 'تبرع للشركة',
    CollectionTransactionType.sell   => 'بيع للشركة',
  };
  String get description => switch (this) {
    CollectionTransactionType.donate => 'رسوم التوصيل على الشركة، بدون مقابل مالي',
    CollectionTransactionType.sell   => 'رسوم التوصيل عليك، وتحصل على المبلغ المتفق عليه',
  };
}

extension WasteTypeLabel on WasteType {
  String get label => switch (this) {
    WasteType.paper => 'ورق',
    WasteType.plastic => 'بلاستيك',
    WasteType.metal => 'معادن',
    WasteType.glass => 'زجاج',
    WasteType.electronics => 'إلكترونيات',
    WasteType.organic => 'عضوي',
    WasteType.textile => 'أقمشة',
    WasteType.wood => 'خشب',
    WasteType.rubber => 'مطاط',
    WasteType.oil => 'زيوت',
    WasteType.chemicals => 'كيميائيات',
    WasteType.batteries => 'بطاريات',
    WasteType.furniture => 'أثاث',
    WasteType.tires => 'إطارات',
    WasteType.construction => 'مخلفات بناء',
    WasteType.copperAluminium => 'نحاس وألومنيوم',
  };
}

extension VehicleTypeLabel on VehicleType {
  String get label => switch (this) {
    VehicleType.motorcycle => 'دراجة نارية',
    VehicleType.car       => 'سيارة خاصة',
    VehicleType.pickup    => 'بيك آب',
    VehicleType.van       => 'فان / ونيت',
    VehicleType.truck     => 'شاحنة',
    VehicleType.heavyTruck => 'شاحنة ثقيلة',
  };
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
  /// Motorcycle/car can never carry chemicals regardless of permit.
  /// All others require [hasChemicalPermit] to carry chemicals.
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

extension WasteFormLabel on WasteForm {
  String get label => switch (this) {
    WasteForm.solid => 'صلب',
    WasteForm.liquid => 'سائل',
    WasteForm.gas => 'غاز',
    WasteForm.mixed => 'مختلط',
  };
}

extension PickupTargetLabel on PickupTarget {
  String get label => switch (this) {
    PickupTarget.company => 'إرسال لشركة التدوير',
    PickupTarget.riderBuy => 'بيع للسائق في السوق',
  };

  String get shortLabel => switch (this) {
    PickupTarget.company => 'شركة التدوير',
    PickupTarget.riderBuy => 'بيع للسائق',
  };
}

extension PaymentModelLabel on PaymentModel {
  String get label => switch (this) {
    PaymentModel.perKg => 'لكل كيلوغرام',
    PaymentModel.flatFee => 'أجر ثابت',
  };

  String get unitLabel => switch (this) {
    PaymentModel.perKg => 'د.أ / كغ',
    PaymentModel.flatFee => 'د.أ',
  };
}

extension WeightCategoryLabel on WeightCategory {
  String get label => switch (this) {
    WeightCategory.light => 'خفيف (أقل من ٥ كغ)',
    WeightCategory.medium => 'متوسط (٥ - ٢٠ كغ)',
    WeightCategory.heavy => 'ثقيل (٢٠ - ١٠٠ كغ)',
    WeightCategory.veryHeavy => 'ثقيل جداً (أكثر من ١٠٠ كغ)',
  };

  String get shortLabel => switch (this) {
    WeightCategory.light => 'خفيف',
    WeightCategory.medium => 'متوسط',
    WeightCategory.heavy => 'ثقيل',
    WeightCategory.veryHeavy => 'ثقيل جداً',
  };
}

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pending => 'قيد الانتظار',
        OrderStatus.accepted => 'تم القبول',
        OrderStatus.arrivedAtPickup => 'وصل للاستلام',
        OrderStatus.inTransit => 'في الطريق',
        OrderStatus.arrivedAtDropoff => 'وصل للتسليم',
        OrderStatus.completed => 'مكتمل',
        OrderStatus.cancelled => 'ملغي',
      };
}

class OrderProof {
  final String imagePath;
  final DateTime capturedAt;
  final double lat;
  final double lng;
  final String checksum;

  const OrderProof({
    required this.imagePath,
    required this.capturedAt,
    required this.lat,
    required this.lng,
    required this.checksum,
  });

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'capturedAt': capturedAt.toIso8601String(),
        'lat': lat,
        'lng': lng,
        'checksum': checksum,
      };

  factory OrderProof.fromJson(Map<String, dynamic> json) => OrderProof(
        imagePath: json['imagePath'] as String,
        capturedAt: DateTime.parse(json['capturedAt'] as String),
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        checksum: json['checksum'] as String,
      );
}

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
  // ── Security & fraud-prevention fields ───────────────────────────────────
  final DateTime? arrivedAtPickupAt;
  final DateTime? arrivedAtDropoffAt;
  final ArrivalConfirmationStatus? arrivalConfirmationStatus;
  final OrderProof? proof;
  final double? supplierHoldAmount;
  final double? driverCompensationAmount;
  final int fraudAttemptCount;
  final bool weightVarianceFlag;
  // ── Vehicle matching & admin approval ────────────────────────────────────
  final VehicleType? requiredVehicleType;
  final bool requiresChemicalPermit;
  final AdminApprovalStatus adminApprovalStatus;
  // ── Marketplace TTL ──────────────────────────────────────────────────────
  final DateTime? expiresAt;

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
  });


  Order copyWith({
    String? id,
    OrderType? type,
    List<WasteType>? wasteTypes,
    String? pickupAddress,
    String? dropoffAddress,
    OrderStatus? status,
    String? driverName,
    String? driverPhone,
    double? driverRating,
    String? driverVehicle,
    String? driverVehicleModel,
    String? driverVehicleColor,
    String? driverLicensePlate,
    String? driverVehiclePhotoPath,
    String? supplierName,
    double? reward,
    double? weightKg,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? inTransitAt,
    DateTime? completedAt,
    DateTime? scheduledAt,
    String? eta,
    double? distanceKm,
    String? proofImagePath,
    double? paidAmount,
    String? supplierNotes,
    List<String>? images,
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
    bool? isEdited,
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
    bool? isMarketplaceShared,
    bool? requiresRider,
    RewardBreakdown? rewardBreakdown,
    List<InvoiceItem>? invoices,
    DateTime? arrivedAtPickupAt,
    DateTime? arrivedAtDropoffAt,
    ArrivalConfirmationStatus? arrivalConfirmationStatus,
    OrderProof? proof,
    double? supplierHoldAmount,
    double? driverCompensationAmount,
    int? fraudAttemptCount,
    bool? weightVarianceFlag,
    VehicleType? requiredVehicleType,
    bool? requiresChemicalPermit,
    AdminApprovalStatus? adminApprovalStatus,
    DateTime? expiresAt,
  }) {
    return Order(
      id: id ?? this.id,
      type: type ?? this.type,
      wasteTypes: wasteTypes ?? this.wasteTypes,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverRating: driverRating ?? this.driverRating,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      driverVehicleModel: driverVehicleModel ?? this.driverVehicleModel,
      driverVehicleColor: driverVehicleColor ?? this.driverVehicleColor,
      driverLicensePlate: driverLicensePlate ?? this.driverLicensePlate,
      driverVehiclePhotoPath: driverVehiclePhotoPath ?? this.driverVehiclePhotoPath,
      supplierName: supplierName ?? this.supplierName,
      reward: reward ?? this.reward,
      weightKg: weightKg ?? this.weightKg,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      inTransitAt: inTransitAt ?? this.inTransitAt,
      completedAt: completedAt ?? this.completedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      eta: eta ?? this.eta,
      distanceKm: distanceKm ?? this.distanceKm,
      proofImagePath: proofImagePath ?? this.proofImagePath,
      paidAmount: paidAmount ?? this.paidAmount,
      supplierNotes: supplierNotes ?? this.supplierNotes,
      images: images ?? this.images,
      estimatedWeightKg: estimatedWeightKg ?? this.estimatedWeightKg,
      wasteForm: wasteForm ?? this.wasteForm,
      weightCategory: weightCategory ?? this.weightCategory,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      pickupTarget: pickupTarget ?? this.pickupTarget,
      itemPrice: itemPrice ?? this.itemPrice,
      jobDescription: jobDescription ?? this.jobDescription,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      paymentModel: paymentModel ?? this.paymentModel,
      minQuantityKg: minQuantityKg ?? this.minQuantityKg,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      editNote: editNote ?? this.editNote,
      linkedJobId: linkedJobId ?? this.linkedJobId,
      collectionDeliveryMethod: collectionDeliveryMethod ?? this.collectionDeliveryMethod,
      collectionTransactionType: collectionTransactionType ?? this.collectionTransactionType,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      isMarketplaceShared: isMarketplaceShared ?? this.isMarketplaceShared,
      requiresRider: requiresRider ?? this.requiresRider,
      rewardBreakdown: rewardBreakdown ?? this.rewardBreakdown,
      invoices: invoices ?? this.invoices,
      arrivedAtPickupAt: arrivedAtPickupAt ?? this.arrivedAtPickupAt,
      arrivedAtDropoffAt: arrivedAtDropoffAt ?? this.arrivedAtDropoffAt,
      arrivalConfirmationStatus: arrivalConfirmationStatus ?? this.arrivalConfirmationStatus,
      proof: proof ?? this.proof,
      supplierHoldAmount: supplierHoldAmount ?? this.supplierHoldAmount,
      driverCompensationAmount: driverCompensationAmount ?? this.driverCompensationAmount,
      fraudAttemptCount: fraudAttemptCount ?? this.fraudAttemptCount,
      weightVarianceFlag: weightVarianceFlag ?? this.weightVarianceFlag,
      requiredVehicleType: requiredVehicleType ?? this.requiredVehicleType,
      requiresChemicalPermit: requiresChemicalPermit ?? this.requiresChemicalPermit,
      adminApprovalStatus: adminApprovalStatus ?? this.adminApprovalStatus,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class InvoiceItem {
  final String name;
  final int quantity;
  final double price;

  const InvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;
}
