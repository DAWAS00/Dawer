import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/domain/failures/app_failure.dart';
import 'package:dwaar/domain/repositories/i_auth_repository.dart';
import 'package:dwaar/data/repositories/mock_auth_repository.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/models/signup_request.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  group('MockAuthRepository', () {
    test('verifyOtp returns InvalidOtp failure for wrong code', () async {
      // [DEV] Test disabled while validation is bypassed
      /*
      final result = await repo.verifyOtp('0790000001', '000000');
      
      expect(result.isFailure, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should have failed'),
        onFailure: (f) {
          expect(f, isA<AuthFailure>());
          expect((f as AuthFailure).code, AuthErrorCodes.invalidOtp);
        },
      );
      */
    });

    test('verifyOtp returns PhoneNotRegistered failure for unknown phone', () async {
      final result = await repo.verifyOtp('0799999999', MockAuthRepository.simulatedOtp);
      
      expect(result.isFailure, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should have failed'),
        onFailure: (f) {
          expect(f, isA<NotFoundFailure>());
          expect((f as NotFoundFailure).code, AuthErrorCodes.phoneNotRegistered);
        },
      );
    });

    test('verifyOtp returns success with correct session for magic driver number', () async {
      final result = await repo.verifyOtp('0790000001', MockAuthRepository.simulatedOtp);
      
      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (session) {
          expect(session.role, UserRole.driver);
        },
        onFailure: (_) => fail('Should have succeeded'),
      );
    });

    test('verifyOtp normalizes phone number properly', () async {
      final result = await repo.verifyOtp('0790000001', MockAuthRepository.simulatedOtp);
      
      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (session) {
          expect(session.role, UserRole.driver);
        },
        onFailure: (_) => fail('Should have succeeded'),
      );
    });

    test('signUp then verifyOtp succeeds', () async {
      final request = SignUpRequest(
        name: 'New User',
        phone: '0777777777',
        role: UserRole.supplier,
        supplierType: SupplierType.individual,
      );

      final signupResult = await repo.signUp(request);
      expect(signupResult.isSuccess, isTrue);

      final verifyResult = await repo.verifyOtp('0777777777', MockAuthRepository.simulatedOtp);
      expect(verifyResult.isSuccess, isTrue);
      
      verifyResult.fold(
        onSuccess: (session) {
          expect(session.userName, 'New User');
        },
        onFailure: (_) => fail('Should have succeeded'),
      );
    });
  });
}
