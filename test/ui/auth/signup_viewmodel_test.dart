import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dwaar/backend_integration_locally/local_store.dart';
import 'package:dwaar/core/result/result.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/models/signup_request.dart';
import 'package:dwaar/domain/repositories/i_auth_repository.dart';
import 'package:dwaar/domain/repositories/i_file_storage_repository.dart';
import 'package:dwaar/data/services/user_signup_service.dart';
import 'package:dwaar/l10n/generated/app_localizations.dart';
import 'package:dwaar/l10n/generated/app_localizations_ar.dart';
import 'package:dwaar/ui/features/auth/viewmodels/signup_viewmodel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake auth and storage repositories for testing.
// ─────────────────────────────────────────────────────────────────────────────

class _FakeAuthRepository implements IAuthRepository {
  final LocalStore store;
  _FakeAuthRepository({required this.store});

  @override
  Future<AppResult<AuthSession>> signUp(SignUpRequest request) async {
    return Success(AuthSession(
      userId: 'fake-uuid',
      userName: request.name,
      role: request.role,
      supplierType: request.supplierType,
    ));
  }

  @override
  Future<AppResult<void>> requestOtp(String phone) async => const Success(null);

  @override
  Future<AppResult<AuthSession>> verifyOtp(String phone, String otp) async {
    return Success(AuthSession(
      userId: 'fake-uuid',
      userName: 'fake-user',
      role: UserRole.driver,
    ));
  }

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthSession?> watchAuthState() => const Stream<AuthSession?>.empty();

  @override
  AuthSession? get currentSession => null;
}

class _FakeFileStorageRepository implements IFileStorageRepository {
  File? lastProfilePhoto;
  File? lastIdentityDocument;

  @override
  Future<AppResult<String>> uploadProfilePhoto({
    required String userId,
    required File file,
  }) async {
    lastProfilePhoto = file;
    return Success('mock://profile/$userId.jpg');
  }

  @override
  Future<AppResult<String>> uploadIdentityDocument({
    required String userId,
    required File file,
  }) async {
    lastIdentityDocument = file;
    return Success('$userId/identity.jpg');
  }

  @override
  Future<AppResult<String>> signedIdentityUrl({
    required String objectPath,
    Duration validity = const Duration(minutes: 5),
  }) async => Success('mock://signed/$objectPath');
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

File _fakeDoc() => File('C:/tmp/nonexistent.jpg');

final AppLocalizations _l10n = AppLocalizationsAr();

late UserSignUpService _fakeService;
late _FakeFileStorageRepository _fakeStorage;

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

    final fakeAuth = _FakeAuthRepository(store: store);
    _fakeStorage = _FakeFileStorageRepository();

    _fakeService = UserSignUpService(
      authRepository: fakeAuth,
      fileStorage: _fakeStorage,
    );
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
        ..contactPhone = '0791234567'
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
        ..contactPhone = '0791234567'
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
        ..contactPhone = '0791234568'
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
        ..contactPhone = '0791234567'
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
        ..contactPhone = '0792222222'
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
        ..contactPhone = '0791234567'
        ..contactEmail = 'not-an-email'
        ..identityDocument = _fakeDoc();

      await vm.submit(_l10n);

      expect(vm.errors['contactEmail'], isNotNull);
    });

    test('missing email blocks submission', () async {
      final vm = _driverVm()
        ..fullName = 'أحمد'
        ..contactPhone = '0791234567'
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
        ..contactPhone = '0791234567';

      final req = vm.buildRequest();
      expect(req.role, UserRole.driver);
      expect(req.supplierType, isNull);
    });

    test('supplier request carries matching supplier_type', () {
      final vm = _individualSupplierVm()
        ..fullName = 'مريم'
        ..contactPhone = '0791234567';

      final req = vm.buildRequest();
      expect(req.role, UserRole.supplier);
      expect(req.supplierType, SupplierType.individual);
    });

    test('email is omitted when blank', () {
      final vm = _driverVm()
        ..fullName = 'أحمد'
        ..contactPhone = '0791234567';

      expect(vm.buildRequest().email, isNull);
    });
  });

  group('SignUpViewModel.submit — media forwarding', () {
    test('forwards picked profilePhoto + identityDocument to the service',
        () async {
      final store = await LocalStore.init();
      final fakeAuth = _FakeAuthRepository(store: store);
      final fakeStorage = _FakeFileStorageRepository();

      final service = UserSignUpService(
        authRepository: fakeAuth,
        fileStorage: fakeStorage,
      );

      final profilePhoto = File('C:/tmp/avatar.jpg');
      final idDoc = File('C:/tmp/national-id.jpg');

      final vm = SignUpViewModel(
        role: UserRole.driver,
        supplierType: SupplierType.individual,
        service: service,
      )
        ..fullName = 'أحمد'
        ..contactPhone = '0791234567'
        ..contactEmail = 'ahmad@example.com'
        ..password = 'Password123'
        ..passwordConfirm = 'Password123'
        ..vehiclePlate = 'أ 123456'
        ..profilePhoto = profilePhoto
        ..identityDocument = idDoc;

      await vm.submit(_l10n);

      expect(vm.errors, isEmpty);
      expect(vm.submitted, isTrue);
      expect(fakeStorage.lastProfilePhoto?.path, profilePhoto.path);
      expect(fakeStorage.lastIdentityDocument?.path, idDoc.path);
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
