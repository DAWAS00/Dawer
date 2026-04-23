import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dwaar/backend_integration_locally/local_store.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/services/supabase_auth_service.dart';
import 'package:dwaar/data/services/user_signup_service.dart';
import 'package:dwaar/l10n/generated/app_localizations.dart';
import 'package:dwaar/l10n/generated/app_localizations_ar.dart';
import 'package:dwaar/ui/features/auth/viewmodels/signup_viewmodel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake auth service that returns canned data instead of hitting Supabase.
// ─────────────────────────────────────────────────────────────────────────────

class _FakeSupabaseAuthService extends SupabaseAuthService {
  _FakeSupabaseAuthService({required super.store});

  @override
  Future<Map<String, dynamic>> signUp(SignUpRequest request) async {
    // Simulate a successful sign-up returning a profile row.
    return <String, dynamic>{
      'id': 'fake-uuid',
      'auth_id': 'fake-auth-uuid',
      'name': request.name,
      'phone': request.phone,
      'email': request.email,
      'role': request.role.dbValue,
      if (request.supplierType != null)
        'supplier_type': request.supplierType!.dbValue,
      if (request.vehiclePlate != null) 'vehicle_plate': request.vehiclePlate,
      'rating': 0.0,
      'total_orders': 0,
      'is_verified': false,
      'points': 0,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Fake file that counts as "identity document uploaded" for the VM. We don't
/// actually read it — only null-vs-non-null matters for validation.
File _fakeDoc() => File('C:/tmp/nonexistent.jpg');

/// Arabic localizations used throughout the tests so `submit(l10n)` compiles.
final AppLocalizations _l10n = AppLocalizationsAr();

late UserSignUpService _fakeService;

SignUpViewModel _driverVm() => SignUpViewModel(
      role: UserRole.driver,
      supplierType: SupplierType.individual,
      service: _fakeService,
    );

SignUpViewModel _individualSupplierVm() => SignUpViewModel(
      role: UserRole.supplier,
      supplierType: SupplierType.individual,
      service: _fakeService,
    );

SignUpViewModel _businessVm() => SignUpViewModel(
      role: UserRole.supplier,
      supplierType: SupplierType.storeBusiness,
      service: _fakeService,
    );

SignUpViewModel _recyclingCoVm() => SignUpViewModel(
      role: UserRole.recyclingCo,
      supplierType: SupplierType.individual,
      service: _fakeService,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = await LocalStore.init();
    UserSignUpService.setGlobalStore(store);

    // Wire up the fake auth service so tests don't hit Supabase.
    final fakeAuth = _FakeSupabaseAuthService(store: store);
    _fakeService = UserSignUpService(authService: fakeAuth);
  });

  group('SignUpViewModel.submit — validation gates navigation', () {
    test('empty driver form produces name + phone + email errors', () async {
      final vm = _driverVm();
      await vm.submit(_l10n);

      expect(vm.submitted, isFalse);
      expect(
        vm.errors.keys,
        containsAll(['fullName', 'contactPhone', 'contactEmail']),
      );
      expect(vm.errors.keys, contains('identityDocument'));
    });

    test('driver with all required fields passes validation', () async {
      final vm = _driverVm()
        ..fullName = 'أحمد'
        ..contactPhone = '+962791234567'
        ..contactEmail = 'ahmad@example.com'
        ..password = 'Password123'
        ..passwordConfirm = 'Password123'
        ..vehiclePlate = 'أ 123456'
        ..identityDocument = _fakeDoc();

      await vm.submit(_l10n);

      expect(vm.errors, isEmpty);
      expect(vm.submitted, isTrue);
    });

    test('individual supplier with name + phone + email + doc passes',
        () async {
      final vm = _individualSupplierVm()
        ..fullName = 'مريم'
        ..contactPhone = '+962791234567'
        ..contactEmail = 'maryam@example.com'
        ..password = 'Password123'
        ..passwordConfirm = 'Password123'
        ..identityDocument = _fakeDoc();

      await vm.submit(_l10n);

      expect(vm.errors, isEmpty);
      expect(vm.submitted, isTrue);
    });

    test('business role uses businessName as the name', () async {
      final vm = _businessVm()
        ..businessName = 'متجر دوّار 2'
        ..ownerOrManagerName = 'أحمد'
        ..contactPhone = '+962791234568'
        ..contactEmail = 'store2@example.com'
        ..password = 'Password123'
        ..passwordConfirm = 'Password123'
        ..identityDocument = _fakeDoc();

      await vm.submit(_l10n);

      expect(vm.errors, isEmpty);
      expect(vm.buildRequest().name, 'متجر دوّار 2');
    });

    test('business role without owner name gets UI-level error', () async {
      final vm = _businessVm()
        ..businessName = 'متجر دوّار'
        ..ownerOrManagerName = ''
        ..contactPhone = '+962791234567'
        ..contactEmail = 'store@example.com'
        ..identityDocument = _fakeDoc();

      await vm.submit(_l10n);

      expect(vm.errors.keys, contains('ownerOrManagerName'));
      expect(vm.submitted, isFalse);
    });

    test('recyclingCo with business name + phone + email passes', () async {
      final vm = _recyclingCoVm()
        ..businessName = 'شركة التدوير'
        ..ownerOrManagerName = 'المدير'
        ..contactPhone = '+962792222222'
        ..contactEmail = 'ops@recycle.jo'
        ..password = 'Password123'
        ..passwordConfirm = 'Password123'
        ..identityDocument = _fakeDoc();

      await vm.submit(_l10n);

      expect(vm.errors, isEmpty);
    });
  });

  group('SignUpViewModel — phone/email rules', () {
    test('malformed phone produces contactPhone error', () async {
      final vm = _driverVm()
        ..fullName = 'أحمد'
        ..contactPhone = 'not-a-phone'
        ..contactEmail = 'x@y.co'
        ..identityDocument = _fakeDoc();

      await vm.submit(_l10n);

      expect(vm.errors['contactPhone'], isNotNull);
    });

    test('malformed email produces contactEmail error', () async {
      final vm = _driverVm()
        ..fullName = 'أحمد'
        ..contactPhone = '+962791234567'
        ..contactEmail = 'not-an-email'
        ..identityDocument = _fakeDoc();

      await vm.submit(_l10n);

      expect(vm.errors['contactEmail'], isNotNull);
    });

    test('missing email blocks submission (email is the OTP channel)',
        () async {
      final vm = _driverVm()
        ..fullName = 'أحمد'
        ..contactPhone = '+962791234567'
        ..identityDocument = _fakeDoc();

      await vm.submit(_l10n);

      expect(vm.errors['contactEmail'], isNotNull);
      expect(vm.submitted, isFalse);
    });

    test('missing phone still blocks submission (DB requires phone)',
        () async {
      final vm = _driverVm()
        ..fullName = 'أحمد'
        ..contactEmail = 'x@y.co'
        ..identityDocument = _fakeDoc();

      await vm.submit(_l10n);

      expect(vm.errors['contactPhone'], isNotNull);
      expect(vm.submitted, isFalse);
    });
  });

  group('SignUpViewModel.buildRequest — payload shape', () {
    test('driver request carries role + null supplier_type', () {
      final vm = _driverVm()
        ..fullName = 'أحمد'
        ..contactPhone = '+962791234567';

      final req = vm.buildRequest();
      expect(req.role, UserRole.driver);
      expect(req.supplierType, isNull);
    });

    test('supplier request carries matching supplier_type', () {
      final vm = _individualSupplierVm()
        ..fullName = 'مريم'
        ..contactPhone = '+962791234567';

      final req = vm.buildRequest();
      expect(req.role, UserRole.supplier);
      expect(req.supplierType, SupplierType.individual);
    });

    test('email is omitted when blank', () {
      final vm = _driverVm()
        ..fullName = 'أحمد'
        ..contactPhone = '+962791234567';

      expect(vm.buildRequest().email, isNull);
    });
  });

  group('SignUpViewModel.clearError', () {
    test('removes a specific error and notifies listeners', () async {
      final vm = _driverVm();
      await vm.submit(_l10n); // produces errors

      expect(vm.errors.containsKey('contactPhone'), isTrue);

      var notified = false;
      vm.addListener(() => notified = true);
      vm.clearError('contactPhone');

      expect(vm.errors.containsKey('contactPhone'), isFalse);
      expect(notified, isTrue);
    });
  });
}
