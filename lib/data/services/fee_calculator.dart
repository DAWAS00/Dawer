import '../models/order.dart';

abstract final class FeeCalculator {
  static const double _base = 2.0;

  static double forWeightCategory(WeightCategory? cat) => _base +
      switch (cat) {
        WeightCategory.light => 0.0,
        WeightCategory.medium => 1.5,
        WeightCategory.heavy => 4.0,
        WeightCategory.veryHeavy => 8.0,
        null => 0.0,
      };
}
