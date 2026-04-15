enum OrderType { pickup, collection, collectionSale }
enum OrderStatus { pending, accepted, inTransit, completed, cancelled }
enum PickupTarget { company, riderBuy }
enum WasteType {
  paper, plastic, metal, glass, electronics, organic,
  textile, wood, rubber, oil, chemicals, batteries, furniture, tires, construction,
}

enum WasteForm { solid, liquid, mixed }

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
  };
}

extension WasteFormLabel on WasteForm {
  String get label => switch (this) {
    WasteForm.solid => 'صلب',
    WasteForm.liquid => 'سائل',
    WasteForm.mixed => 'مختلط',
  };
}

extension PickupTargetLabel on PickupTarget {
  String get label => switch (this) {
    PickupTarget.company => 'إرسال لشركة تدوير',
    PickupTarget.riderBuy => 'السائق يشتريها مباشرة',
  };

  String get shortLabel => switch (this) {
    PickupTarget.company => 'شركة',
    PickupTarget.riderBuy => 'شراء مباشر',
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
        OrderStatus.inTransit => 'في الطريق',
        OrderStatus.completed => 'مكتمل',
        OrderStatus.cancelled => 'ملغي',
      };
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
    );
  }

}
