import 'package:flutter_test/flutter_test.dart';

import 'package:dwaar/data/models/order.dart' show WasteType;
import 'package:dwaar/data/services/reward_service.dart';

void main() {
  group('RewardService.validate', () {
    test('accepts a well-formed request', () {
      expect(
        RewardService.validate(
          wasteTypes: const [WasteType.plastic],
          estimatedWeightKg: 1,
          distanceKm: 1,
        ),
        isNull,
      );
    });

    test('rejects empty wasteTypes', () {
      expect(
        RewardService.validate(
          wasteTypes: const [],
          estimatedWeightKg: 1,
          distanceKm: 1,
        ),
        contains('wasteTypes'),
      );
    });

    test('rejects negative estimatedWeightKg', () {
      expect(
        RewardService.validate(
          wasteTypes: const [WasteType.plastic],
          estimatedWeightKg: -1,
          distanceKm: 1,
        ),
        contains('estimatedWeightKg'),
      );
    });

    test('rejects negative distanceKm', () {
      expect(
        RewardService.validate(
          wasteTypes: const [WasteType.plastic],
          estimatedWeightKg: 1,
          distanceKm: -0.5,
        ),
        contains('distanceKm'),
      );
    });

    test('accepts zero weight and distance as non-negative', () {
      expect(
        RewardService.validate(
          wasteTypes: const [WasteType.plastic],
          estimatedWeightKg: 0,
          distanceKm: 0,
        ),
        isNull,
      );
    });
  });

  // Note: happy-path reward math is covered by dedicated breakdown/model tests.
}

