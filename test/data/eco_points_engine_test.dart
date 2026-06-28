import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/eco_badge.dart';
import 'package:dwaar/data/models/order.dart' show WasteType;
import 'package:dwaar/data/services/eco_points_engine.dart';

void main() {
  // ── pointsForCollection ──────────────────────────────────────────────────

  group('EcoPointsEngine.pointsForCollection —', () {
    test('oil at 10 pts/kg: 5 kg → 50 pts', () {
      expect(
        EcoPointsEngine.pointsForCollection(
          weightKg: 5.0,
          wasteType: WasteType.oil,
        ),
        50.0,
      );
    });

    test('metal at 5 pts/kg: 10 kg → 50 pts', () {
      expect(
        EcoPointsEngine.pointsForCollection(
          weightKg: 10.0,
          wasteType: WasteType.metal,
        ),
        50.0,
      );
    });

    test('organic at 1 pt/kg: 20 kg → 20 pts', () {
      expect(
        EcoPointsEngine.pointsForCollection(
          weightKg: 20.0,
          wasteType: WasteType.organic,
        ),
        20.0,
      );
    });

    test('copperAluminium at 8 pts/kg: 2.5 kg → 20 pts', () {
      expect(
        EcoPointsEngine.pointsForCollection(
          weightKg: 2.5,
          wasteType: WasteType.copperAluminium,
        ),
        20.0,
      );
    });

    test('zero kg → 0 pts regardless of type', () {
      expect(
        EcoPointsEngine.pointsForCollection(
          weightKg: 0,
          wasteType: WasteType.oil,
        ),
        0.0,
      );
    });

    test('oil beats all other materials (highest rate)', () {
      final oilPts = EcoPointsEngine.rateFor(WasteType.oil);
      for (final type in WasteType.values) {
        if (type == WasteType.oil) continue;
        expect(
          oilPts >= EcoPointsEngine.rateFor(type),
          isTrue,
          reason: 'oil rate should be >= ${type.name}',
        );
      }
    });
  });

  // ── lifetimeKgFromPoints ──────────────────────────────────────────────────

  group('EcoPointsEngine.lifetimeKgFromPoints —', () {
    test('100 pts → 10 kg (oil rate: 10 pts/kg)', () {
      expect(EcoPointsEngine.lifetimeKgFromPoints(100), 10.0);
    });

    test('1000 pts → 100 kg', () {
      expect(EcoPointsEngine.lifetimeKgFromPoints(1000), 100.0);
    });

    test('0 pts → 0 kg', () {
      expect(EcoPointsEngine.lifetimeKgFromPoints(0), 0.0);
    });
  });

  // ── isEcoHero ─────────────────────────────────────────────────────────────

  group('EcoPointsEngine.isEcoHero —', () {
    test('99 kg → not Eco Hero', () {
      expect(EcoPointsEngine.isEcoHero(99), isFalse);
    });

    test('100 kg → is Eco Hero', () {
      expect(EcoPointsEngine.isEcoHero(100), isTrue);
    });

    test('500 kg → is Eco Hero', () {
      expect(EcoPointsEngine.isEcoHero(500), isTrue);
    });
  });

  // ── driverFuelCredit ──────────────────────────────────────────────────────

  group('EcoPointsEngine.driverFuelCredit —', () {
    test('0 deliveries → 0.00 JOD', () {
      expect(EcoPointsEngine.driverFuelCredit(0), 0.0);
    });

    test('20 deliveries → 1.00 JOD (20 × 0.05)', () {
      expect(EcoPointsEngine.driverFuelCredit(20), closeTo(1.0, 0.001));
    });

    test('100 deliveries → 5.00 JOD', () {
      expect(EcoPointsEngine.driverFuelCredit(100), closeTo(5.0, 0.001));
    });

    test('rate constant matches test expectations', () {
      expect(EcoPointsEngine.fuelCreditPerDelivery, 0.05);
    });
  });

  // ── earnedBadges ─────────────────────────────────────────────────────────

  group('EcoPointsEngine.earnedBadges —', () {
    test('0 kg, 0 orders → no badges', () {
      final badges = EcoPointsEngine.earnedBadges(
        lifetimeKg: 0,
        completedOrders: 0,
      );
      expect(badges, isEmpty);
    });

    test('0 kg, 1 order → firstStep badge only', () {
      final badges = EcoPointsEngine.earnedBadges(
        lifetimeKg: 0,
        completedOrders: 1,
      );
      expect(badges.length, 1);
      expect(badges.first.type, EcoBadgeType.firstStep);
    });

    test('10 kg, 1 order → firstStep + recycleChampion', () {
      final badges = EcoPointsEngine.earnedBadges(
        lifetimeKg: 10,
        completedOrders: 1,
      );
      final types = badges.map((b) => b.type).toSet();
      expect(types, contains(EcoBadgeType.firstStep));
      expect(types, contains(EcoBadgeType.recycleChampion));
    });

    test('100 kg, 5 orders → includes ecoHero', () {
      final badges = EcoPointsEngine.earnedBadges(
        lifetimeKg: 100,
        completedOrders: 5,
      );
      expect(
        badges.any((b) => b.type == EcoBadgeType.ecoHero),
        isTrue,
      );
    });

    test('500 kg → all 5 badges earned', () {
      final badges = EcoPointsEngine.earnedBadges(
        lifetimeKg: 500,
        completedOrders: 10,
      );
      expect(badges.length, EcoBadge.all.length);
    });

    test('recycleLegend not earned at 499 kg', () {
      final badges = EcoPointsEngine.earnedBadges(
        lifetimeKg: 499,
        completedOrders: 10,
      );
      expect(
        badges.any((b) => b.type == EcoBadgeType.recycleLegend),
        isFalse,
      );
    });
  });

  // ── neighborhoodLeaderboard ───────────────────────────────────────────────

  group('EcoPointsEngine.neighborhoodLeaderboard —', () {
    final leaderboard = EcoPointsEngine.neighborhoodLeaderboard();

    test('has 10 entries', () {
      expect(leaderboard.length, 10);
    });

    test('sorted descending by kgCollected', () {
      for (int i = 0; i < leaderboard.length - 1; i++) {
        expect(
          leaderboard[i].kgCollected >= leaderboard[i + 1].kgCollected,
          isTrue,
          reason:
              'entry $i (${leaderboard[i].kgCollected}) should be >= entry ${i + 1} (${leaderboard[i + 1].kgCollected})',
        );
      }
    });

    test('top entry has highest kg', () {
      final maxKg = leaderboard.map((e) => e.kgCollected).reduce((a, b) => a > b ? a : b);
      expect(leaderboard.first.kgCollected, maxKg);
    });

    test('all entries have non-empty district name', () {
      for (final e in leaderboard) {
        expect(e.district.isNotEmpty, isTrue);
      }
    });

    test('all entries have positive kgCollected', () {
      for (final e in leaderboard) {
        expect(e.kgCollected, greaterThan(0));
      }
    });
  });

  // ── coupons ───────────────────────────────────────────────────────────────

  group('EcoPointsEngine.coupons —', () {
    test('has 4 coupons', () {
      expect(EcoPointsEngine.coupons.length, 4);
    });

    test('coupons are sorted ascending by pointsRequired', () {
      final pts = EcoPointsEngine.coupons.map((c) => c.pointsRequired).toList();
      for (int i = 0; i < pts.length - 1; i++) {
        expect(pts[i] <= pts[i + 1], isTrue,
            reason: 'coupons should be sorted by points ascending');
      }
    });

    test('all coupons have non-empty code and title', () {
      for (final c in EcoPointsEngine.coupons) {
        expect(c.code.isNotEmpty, isTrue);
        expect(c.title.isNotEmpty, isTrue);
      }
    });

    test('FUEL5JD coupon requires 500 points', () {
      final fuelCoupon =
          EcoPointsEngine.coupons.firstWhere((c) => c.code == 'FUEL5JD');
      expect(fuelCoupon.pointsRequired, 500);
    });

    test('first coupon is the lowest threshold', () {
      final minRequired = EcoPointsEngine.coupons
          .map((c) => c.pointsRequired)
          .reduce((a, b) => a < b ? a : b);
      expect(EcoPointsEngine.coupons.first.pointsRequired, minRequired);
    });
  });

  // ── EcoBadge helpers ──────────────────────────────────────────────────────

  group('EcoBadge —', () {
    test('ecoHero badge has 100 kg threshold', () {
      final badge = EcoBadge.all.firstWhere(
          (b) => b.type == EcoBadgeType.ecoHero);
      expect(badge.kgThreshold, 100.0);
    });

    test('firstStep badge has 1 order threshold', () {
      final badge = EcoBadge.all.firstWhere(
          (b) => b.type == EcoBadgeType.firstStep);
      expect(badge.ordersThreshold, 1);
      expect(badge.kgThreshold, 0.0);
    });

    test('requirementLabel uses kg for kg-based badges', () {
      final badge = EcoBadge.all.firstWhere(
          (b) => b.type == EcoBadgeType.ecoHero);
      expect(badge.requirementLabel, contains('كغ'));
    });

    test('requirementLabel uses orders for order-based badges', () {
      final badge = EcoBadge.all.firstWhere(
          (b) => b.type == EcoBadgeType.firstStep);
      expect(badge.requirementLabel, contains('طلبات'));
    });

    test('all badges in EcoBadge.all have non-empty label', () {
      for (final b in EcoBadge.all) {
        expect(b.label.isNotEmpty, isTrue);
        expect(b.emoji.isNotEmpty, isTrue);
      }
    });
  });
}
