import 'order.dart';

/// Arabic-language labels and short-labels for [Order] enums.
///
/// English equivalents live in `order_labels.dart` as `*En` extensions.

extension CollectionDeliveryMethodLabel on CollectionDeliveryMethod {
  String get label => switch (this) {
    CollectionDeliveryMethod.selfDelivery => 'أوصّل بنفسي',
    CollectionDeliveryMethod.assignRider => 'أعيّن سائقاً',
  };
  String get description => switch (this) {
    CollectionDeliveryMethod.selfDelivery => 'ستوصل المواد بنفسك',
    CollectionDeliveryMethod.assignRider => 'سيتم تعيين سائق لك',
  };
}

extension CollectionTransactionTypeLabel on CollectionTransactionType {
  String get label => switch (this) {
    CollectionTransactionType.donate => 'تبرع للشركة',
    CollectionTransactionType.sell => 'بيع للشركة',
  };
  String get description => switch (this) {
    CollectionTransactionType.donate => 'رسوم التوصيل على الشركة، بدون مقابل مالي',
    CollectionTransactionType.sell => 'رسوم التوصيل عليك، وتحصل على المبلغ المتفق عليه',
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
    PickupTarget.company => 'Make Pickup Order',
    PickupTarget.riderBuy => 'Put it in the restaurant and the market',
  };

  String get shortLabel => switch (this) {
    PickupTarget.company => 'Make Pickup Order',
    PickupTarget.riderBuy => 'Put it in the restaurant and the market',
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

extension OrderEtaLabel on Order {
  /// Human-readable ETA string. Falls back to 'جاري الحساب...' only when
  /// etaMinutes is null (e.g. distance not yet known).
  String get etaLabel {
    final mins = etaMinutes;
    if (mins == null) return 'جاري الحساب...';
    if (mins < 60) return '$mins دقيقة';
    final hours = (mins / 60).floor();
    final remaining = mins % 60;
    if (remaining == 0) return '$hours ساعة';
    return '$hours س $remaining د';
  }
}
