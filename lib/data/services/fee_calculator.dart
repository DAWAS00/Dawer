import '../models/order.dart';

class FeeCalculator {
  static const double base = 2.0;

  static double distanceFee(double km) => km * 0.2;

  static double weightSurcharge(WeightCategory? cat) => switch (cat) {
    WeightCategory.light => 0.0,
    WeightCategory.medium => 1.5,
    WeightCategory.heavy => 4.0,
    WeightCategory.veryHeavy => 8.0,
    null => 0.0,
  };

  static double calculateDeliveryFee({
    required double distanceKm,
    required WeightCategory? weightCategory,
  }) {
    return base + weightSurcharge(weightCategory) + distanceFee(distanceKm);
  }

  static double calculateTotal({
    required double deliveryFee,
    required double? itemPrice,
  }) {
    return deliveryFee + (itemPrice ?? 0.0);
  }
}
