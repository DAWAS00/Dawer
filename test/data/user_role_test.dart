import 'package:flutter_test/flutter_test.dart';

import 'package:dwaar/data/models/user_role.dart';

void main() {
  group('UserRole DB mapping', () {
    test('dbValue matches SQL enum labels exactly', () {
      expect(UserRole.driver.dbValue, 'driver');
      expect(UserRole.supplier.dbValue, 'supplier');
      expect(UserRole.recyclingCo.dbValue, 'recyclingCo');
    });

    test('fromDb round-trips every value', () {
      for (final r in UserRole.values) {
        expect(UserRoleDbMapping.fromDb(r.dbValue), r);
      }
    });

    test('fromDb throws on unknown label', () {
      expect(
        () => UserRoleDbMapping.fromDb('admin'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('allowedDbValues is exhaustive and ordered', () {
      expect(
        UserRoleDbMapping.allowedDbValues,
        const ['driver', 'supplier', 'recyclingCo'],
      );
    });
  });

  group('SupplierType DB mapping', () {
    test('dbValue matches SQL enum labels', () {
      expect(SupplierType.individual.dbValue, 'individual');
      expect(SupplierType.storeBusiness.dbValue, 'storeBusiness');
    });

    test('fromDb round-trips', () {
      for (final t in SupplierType.values) {
        expect(SupplierTypeDbMapping.fromDb(t.dbValue), t);
      }
    });

    test('fromDb throws on unknown label', () {
      expect(
        () => SupplierTypeDbMapping.fromDb('retail'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
