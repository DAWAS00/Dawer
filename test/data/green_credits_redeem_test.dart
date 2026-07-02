import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/services/app_order_store.dart';

void main() {
  const driverId = '11111111-1111-1111-1111-111111111111';

  group('AppOrderStore green credits redemption', () {
    test('configureForUser seeds the demo balance for a known mock user', () {
      final store = AppOrderStore();
      store.configureForUser(driverId, UserRole.driver);
      // Seed value for the driver in GreenCreditsMockData is 2340.
      expect(store.greenPointsFor(driverId), 2340);
      expect(store.greenTransactionsFor(driverId), isNotEmpty);
    });

    test('redeemGreenCredits deducts balance and records a transaction', () {
      final store = AppOrderStore();
      store.configureForUser(driverId, UserRole.driver);
      final before = store.greenPointsFor(driverId);

      final ok = store.redeemGreenCredits(
        driverId,
        cost: 500,
        description: 'استبدال: خصم على الطلبات',
      );

      expect(ok, isTrue);
      expect(store.greenPointsFor(driverId), before - 500);
      // Most recent transaction is the redemption.
      expect(store.greenTransactionsFor(driverId).first.points, 500);
    });

    test('redeemGreenCredits fails when balance is insufficient', () {
      final store = AppOrderStore();
      store.configureForUser(driverId, UserRole.driver);

      final ok = store.redeemGreenCredits(
        driverId,
        cost: 999999,
        description: 'too expensive',
      );

      expect(ok, isFalse);
      expect(store.greenPointsFor(driverId), 2340); // unchanged
    });
  });
}
