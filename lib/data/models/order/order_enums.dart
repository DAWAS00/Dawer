enum OrderType { pickup, collection, collectionSale }
enum OrderMode { pickup, marketplace }

enum OrderStatus {
  pending, accepted, arrivedAtPickup, inTransit, arrivedAtDropoff, completed, cancelled
}

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
