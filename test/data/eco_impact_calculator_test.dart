import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/utils/eco_impact_calculator.dart';

void main() {
  group('EcoImpactCalculator.calculateForWeight', () {
    test('empty types returns zero impact', () {
      final result = EcoImpactCalculator.calculateForWeight([], 50);
      expect(result.co2SavedKg, 0);
      expect(result.waterSavedLiters, 0);
      expect(result.energySavedKwh, 0);
    });

    test('zero or negative weight returns zero impact', () {
      expect(EcoImpactCalculator.calculateForWeight([WasteType.plastic], 0).co2SavedKg, 0);
      expect(EcoImpactCalculator.calculateForWeight([WasteType.plastic], -5).co2SavedKg, 0);
    });

    test('single type uses full weight against that factor', () {
      final result = EcoImpactCalculator.calculateForWeight([WasteType.metal], 10);
      // metal: co2 4.5/kg, water 1.5/kg, energy 14.0/kg
      expect(result.co2SavedKg, closeTo(45.0, 0.001));
      expect(result.waterSavedLiters, closeTo(15.0, 0.001));
      expect(result.energySavedKwh, closeTo(140.0, 0.001));
    });

    test('multiple types split weight evenly across each', () {
      final result = EcoImpactCalculator.calculateForWeight(
        [WasteType.plastic, WasteType.glass],
        10,
      );
      // 5kg each: plastic co2 5*1.5=7.5, glass co2 5*0.3=1.5 -> 9.0
      expect(result.co2SavedKg, closeTo(9.0, 0.001));
    });

    test('calculate (category-based) matches calculateForWeight with the category midpoint', () {
      final byCategory = EcoImpactCalculator.calculate([WasteType.paper], WeightCategory.medium);
      final byWeight = EcoImpactCalculator.calculateForWeight([WasteType.paper], 12.5);
      expect(byCategory.co2SavedKg, byWeight.co2SavedKg);
    });

    test('null category weighs zero', () {
      final result = EcoImpactCalculator.calculate([WasteType.plastic], null);
      expect(result.co2SavedKg, 0);
    });
  });
}
