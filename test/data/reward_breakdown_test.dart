import 'package:flutter_test/flutter_test.dart';

import 'package:dwaar/data/models/reward_breakdown.dart';

void main() {
  group('RewardBreakdown.fromJson', () {
    test('parses a normal response', () {
      final b = RewardBreakdown.fromJson(const {
        'base_fee': 1.5,
        'distance_fee': 2.1,
        'material_fee': 0.3,
        'urgency_bonus': 0.0,
        'total_jd': 3.9,
      });

      expect(b.baseFee, 1.5);
      expect(b.distanceFee, 2.1);
      expect(b.materialFee, 0.3);
      expect(b.urgencyBonus, 0);
      expect(b.totalJd, 3.9);
      expect(b.needsManualReview, isFalse);
    });

    test('honors needs_manual_review flag', () {
      final b = RewardBreakdown.fromJson(const {
        'base_fee': 1.5,
        'distance_fee': 0,
        'material_fee': 0,
        'urgency_bonus': 0,
        'total_jd': 1.5,
        'needs_manual_review': true,
      });
      expect(b.needsManualReview, isTrue);
    });

    test('coerces int values to double', () {
      final b = RewardBreakdown.fromJson(const {
        'base_fee': 1,
        'distance_fee': 2,
        'material_fee': 0,
        'urgency_bonus': 0,
        'total_jd': 3,
      });
      expect(b.baseFee, 1.0);
      expect(b.totalJd, 3.0);
    });

    test('falls back to 0 for missing / non-numeric fields', () {
      final b = RewardBreakdown.fromJson(const {
        'base_fee': 'oops',
        'total_jd': null,
      });
      expect(b.baseFee, 0);
      expect(b.totalJd, 0);
      expect(b.distanceFee, 0);
    });
  });

  test('zero constant has all-zero fields', () {
    const z = RewardBreakdown.zero;
    expect(z.baseFee, 0);
    expect(z.distanceFee, 0);
    expect(z.materialFee, 0);
    expect(z.urgencyBonus, 0);
    expect(z.totalJd, 0);
    expect(z.needsManualReview, isFalse);
  });

  test('toJson omits needs_manual_review when false', () {
    const b = RewardBreakdown(
      baseFee: 1.5,
      distanceFee: 0,
      materialFee: 0,
      urgencyBonus: 0,
      totalJd: 1.5,
    );
    expect(b.toJson().containsKey('needs_manual_review'), isFalse);
  });
}
