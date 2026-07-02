import 'package:flutter_test/flutter_test.dart';

import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/models/signup_request.dart';

SignUpRequest _driver({
  String name = 'أحمد',
  String phone = '0791234567',
  String password = 'Passw0rd!',
  String? vehiclePlate = '12-34567',
  String? email,
}) => SignUpRequest(
  name: name,
  phone: phone,
  password: password,
  role: UserRole.driver,
  vehiclePlate: vehiclePlate,
  email: email,
);

SignUpRequest _supplier({
  SupplierType? supplierType = SupplierType.individual,
  String name = 'متجر دوّار',
  String phone = '0791111111',
  String password = 'Passw0rd!',
}) => SignUpRequest(
  name: name,
  phone: phone,
  password: password,
  role: UserRole.supplier,
  supplierType: supplierType,
);

void main() {
  group('SignUpRequest.validate — happy path', () {
    test('driver with vehicle plate is valid', () {
      expect(_driver().validate(), isEmpty);
    });

    test('supplier with supplier_type is valid', () {
      expect(_supplier().validate(), isEmpty);
    });

    test('recyclingCo is valid without supplier_type or vehicle', () {
      final req = SignUpRequest(
        name: 'شركة التدوير',
        phone: '0792222222',
        password: 'Passw0rd!',
        role: UserRole.recyclingCo,
      );
      expect(req.validate(), isEmpty);
    });
  });

  group('SignUpRequest.validate — required fields', () {
    test('empty name rejected', () {
      expect(_driver(name: '   ').validate().keys, contains('name'));
    });

    test('too-short name rejected', () {
      expect(_driver(name: 'أ').validate().keys, contains('name'));
    });

    test('too-long name rejected', () {
      expect(_driver(name: 'ا' * 121).validate().keys, contains('name'));
    });

    test('empty phone rejected', () {
      expect(_driver(phone: '').validate().keys, contains('phone'));
    });

    test('malformed phone rejected', () {
      expect(_driver(phone: 'not-a-phone').validate().keys, contains('phone'));
    });

    test('too-short password rejected', () {
      expect(_driver(password: 'Ab1!23').validate().keys, contains('password'));
    });

    test('too-long password rejected', () {
      expect(_driver(password: 'a' * 73).validate().keys, contains('password'));
    });
  });

  group('SignUpRequest.validate — email', () {
    test('valid email accepted', () {
      expect(_driver(email: 'x@y.co').validate(), isEmpty);
    });

    test('malformed email rejected', () {
      expect(_driver(email: 'not-an-email').validate().keys, contains('email'));
    });

    test('empty email string is ignored', () {
      expect(_driver(email: '   ').validate(), isEmpty);
    });
  });

  group('SignUpRequest.validate — role-specific rules', () {
    test('supplier without supplier_type is rejected', () {
      expect(
        _supplier(supplierType: null).validate().keys,
        contains('supplierType'),
      );
    });

    test('driver without vehicle_plate is rejected', () {
      expect(
        _driver(vehiclePlate: null).validate().keys,
        contains('vehiclePlate'),
      );
    });

    test('driver with blank vehicle_plate is rejected', () {
      expect(
        _driver(vehiclePlate: '   ').validate().keys,
        contains('vehiclePlate'),
      );
    });

    test('non-supplier role cannot carry supplier_type', () {
      final req = SignUpRequest(
        name: 'Driver',
        phone: '0791234567',
        password: 'Passw0rd!',
        role: UserRole.driver,
        vehiclePlate: '12-34567',
        supplierType: SupplierType.individual,
      );
      expect(req.validate().keys, contains('supplierType'));
    });
  });

  group('SignUpRequest.toInsertRow', () {
    test('includes typed role label matching SQL enum', () {
      final row = _supplier().toInsertRow(authId: 'auth-1');
      expect(row['role'], 'supplier');
      expect(row['supplier_type'], 'individual');
      expect(row['auth_id'], 'auth-1');
    });

    test('trims string fields', () {
      final row = _driver(name: '  محمد  ').toInsertRow(authId: 'a');
      expect(row['name'], 'محمد');
    });

    test('omits optional fields when null / empty', () {
      final row = _driver().toInsertRow(authId: 'a');
      expect(row.containsKey('email'), isFalse);
      expect(row.containsKey('vehicle_model'), isFalse);
      expect(row.containsKey('address'), isFalse);
    });

    test('omits supplier_type for non-supplier roles', () {
      final row = _driver().toInsertRow(authId: 'a');
      expect(row.containsKey('supplier_type'), isFalse);
    });
  });
}
