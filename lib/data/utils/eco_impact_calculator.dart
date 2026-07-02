import '../../data/models/order/order.dart';

class EcoImpactResult {
  final double co2SavedKg;
  final double waterSavedLiters;
  final double energySavedKwh;

  const EcoImpactResult({
    required this.co2SavedKg,
    required this.waterSavedLiters,
    required this.energySavedKwh,
  });
}

class EcoImpactCalculator {
  /// Estimates environmental savings based on waste type and weight
  /// category (used before the actual weight is known, e.g. in the
  /// pickup-request wizard).
  static EcoImpactResult calculate(
    List<WasteType> types,
    WeightCategory? weight,
  ) {
    final approxWeight = switch (weight) {
      WeightCategory.light => 2.5,
      WeightCategory.medium => 12.5,
      WeightCategory.heavy => 60.0,
      WeightCategory.veryHeavy => 150.0,
      null => 0.0,
    };
    return calculateForWeight(types, approxWeight);
  }

  /// Estimates environmental savings from an actual measured weight (kg),
  /// distributed evenly across [types]. Data based on general recycling
  /// industry averages.
  static EcoImpactResult calculateForWeight(
    List<WasteType> types,
    double totalWeightKg,
  ) {
    if (types.isEmpty || totalWeightKg <= 0) {
      return const EcoImpactResult(
        co2SavedKg: 0,
        waterSavedLiters: 0,
        energySavedKwh: 0,
      );
    }

    double totalCo2 = 0;
    double totalWater = 0;
    double totalEnergy = 0;

    // Distribute weight across selected types
    final weightPerType = totalWeightKg / types.length;

    for (final type in types) {
      switch (type) {
        case WasteType.plastic:
          totalCo2 += weightPerType * 1.5;
          totalWater += weightPerType * 2.0;
          totalEnergy += weightPerType * 5.7;
        case WasteType.paper:
          totalCo2 += weightPerType * 0.9;
          totalWater += weightPerType * 26.0;
          totalEnergy += weightPerType * 4.0;
        case WasteType.metal:
          totalCo2 += weightPerType * 4.5;
          totalWater += weightPerType * 1.5;
          totalEnergy += weightPerType * 14.0;
        case WasteType.glass:
          totalCo2 += weightPerType * 0.3;
          totalWater += weightPerType * 0.5;
          totalEnergy += weightPerType * 0.7;
        case WasteType.electronics:
          totalCo2 += weightPerType * 2.5;
          totalWater += weightPerType * 10.0;
          totalEnergy += weightPerType * 20.0;
        default:
          totalCo2 += weightPerType * 0.5;
          totalWater += weightPerType * 1.0;
          totalEnergy += weightPerType * 1.0;
      }
    }

    return EcoImpactResult(
      co2SavedKg: totalCo2,
      waterSavedLiters: totalWater,
      energySavedKwh: totalEnergy,
    );
  }
}
