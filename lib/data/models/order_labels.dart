import 'dart:ui' show Locale;
import 'order.dart';

extension WasteTypeLabelEn on WasteType {
  String get englishLabel => switch (this) {
    WasteType.paper => 'Paper',
    WasteType.plastic => 'Plastic',
    WasteType.metal => 'Metal',
    WasteType.glass => 'Glass',
    WasteType.electronics => 'Electronics',
    WasteType.organic => 'Organic',
    WasteType.textile => 'Textile',
    WasteType.wood => 'Wood',
    WasteType.rubber => 'Rubber',
    WasteType.oil => 'Oil',
    WasteType.chemicals => 'Chemicals',
    WasteType.batteries => 'Batteries',
    WasteType.furniture => 'Furniture',
    WasteType.tires => 'Tires',
    WasteType.construction => 'Construction Waste',
    WasteType.copperAluminium => 'Copper & Aluminium',
  };
  String labelFor(Locale locale) =>
      locale.languageCode == 'ar' ? label : englishLabel;
}

extension WasteFormLabelEn on WasteForm {
  String get englishLabel => switch (this) {
    WasteForm.solid => 'Solid',
    WasteForm.liquid => 'Liquid',
    WasteForm.gas => 'Gas',
    WasteForm.mixed => 'Mixed',
  };
  String labelFor(Locale locale) =>
      locale.languageCode == 'ar' ? label : englishLabel;
}

extension WeightCategoryLabelEn on WeightCategory {
  String get englishShortLabel => switch (this) {
    WeightCategory.light => 'Light',
    WeightCategory.medium => 'Medium',
    WeightCategory.heavy => 'Heavy',
    WeightCategory.veryHeavy => 'Very Heavy',
  };
  String shortLabelFor(Locale locale) =>
      locale.languageCode == 'ar' ? shortLabel : englishShortLabel;
}

extension PaymentModelLabelEn on PaymentModel {
  String get englishLabel => switch (this) {
    PaymentModel.perKg => 'Per Kilogram',
    PaymentModel.flatFee => 'Flat Fee',
  };
  String get englishUnitLabel => switch (this) {
    PaymentModel.perKg => 'JD / kg',
    PaymentModel.flatFee => 'JD',
  };
  String labelFor(Locale locale) =>
      locale.languageCode == 'ar' ? label : englishLabel;
  String unitLabelFor(Locale locale) =>
      locale.languageCode == 'ar' ? unitLabel : englishUnitLabel;
}

extension OrderStatusLabelEn on OrderStatus {
  String get englishLabel => switch (this) {
    OrderStatus.pending => 'Pending',
    OrderStatus.accepted => 'Accepted',
    OrderStatus.arrivedAtPickup => 'Arrived at Pickup',
    OrderStatus.inTransit => 'In Transit',
    OrderStatus.arrivedAtDropoff => 'Arrived at Dropoff',
    OrderStatus.completed => 'Completed',
    OrderStatus.cancelled => 'Cancelled',
  };
  String labelFor(Locale locale) =>
      locale.languageCode == 'ar' ? label : englishLabel;
}

extension CollectionDeliveryMethodLabelEn on CollectionDeliveryMethod {
  String get englishLabel => switch (this) {
    CollectionDeliveryMethod.selfDelivery => 'Self Delivery',
    CollectionDeliveryMethod.assignRider => 'Assign a Driver',
  };
  String get englishDescription => switch (this) {
    CollectionDeliveryMethod.selfDelivery =>
      'You will deliver the materials yourself',
    CollectionDeliveryMethod.assignRider => 'A driver will be assigned for you',
  };
  String labelFor(Locale locale) =>
      locale.languageCode == 'ar' ? label : englishLabel;
  String descriptionFor(Locale locale) =>
      locale.languageCode == 'ar' ? description : englishDescription;
}

extension CollectionTransactionTypeLabelEn on CollectionTransactionType {
  String get englishLabel => switch (this) {
    CollectionTransactionType.donate => 'Donate to Company',
    CollectionTransactionType.sell => 'Sell to Company',
  };
  String get englishDescription => switch (this) {
    CollectionTransactionType.donate =>
      'Delivery fees paid by company, no payment received',
    CollectionTransactionType.sell =>
      'Delivery fees are yours, you receive the agreed amount',
  };
  String labelFor(Locale locale) =>
      locale.languageCode == 'ar' ? label : englishLabel;
  String descriptionFor(Locale locale) =>
      locale.languageCode == 'ar' ? description : englishDescription;
}

extension PickupTargetLabelEn on PickupTarget {
  String get englishLabel => switch (this) {
    PickupTarget.company => 'Send to Recycling Company',
    PickupTarget.riderBuy => 'Driver Buys Directly',
  };
  String get englishShortLabel => switch (this) {
    PickupTarget.company => 'Company',
    PickupTarget.riderBuy => 'Direct Purchase',
  };
  String labelFor(Locale locale) =>
      locale.languageCode == 'ar' ? label : englishLabel;
  String shortLabelFor(Locale locale) =>
      locale.languageCode == 'ar' ? shortLabel : englishShortLabel;
}
