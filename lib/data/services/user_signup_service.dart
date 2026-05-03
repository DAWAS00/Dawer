import 'dart:io';

import '../../backend_integration_locally/local_store.dart';
import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../models/user_role.dart';
import 'supabase_auth_service.dart';

/// Validation errors keyed by request field name. An empty map means the
/// request is valid. Keys mirror [SignUpRequest] field names so UI layers
/// can map them to their text inputs.
typedef ValidationErrors = Map<String, String>;

/// Client-side input for a new user sign-up.
class SignUpRequest {
  final String name;
  final String phone;
  final String? email;

  /// Required now that auth is password-based.
  final String? password;
  final UserRole role;

  /// Required when [role] == [UserRole.supplier].
  final SupplierType? supplierType;

  /// Required when [role] == [UserRole.driver].
  final String? vehiclePlate;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? vehiclePhotoUrl;

  final String? address;
  final double? addressLat;
  final double? addressLng;

  const SignUpRequest({
    required this.name,
    required this.phone,
    required this.role,
    this.password,
    this.email,
    this.supplierType,
    this.vehiclePlate,
    this.vehicleModel,
    this.vehicleColor,
    this.vehiclePhotoUrl,
    this.address,
    this.addressLat,
    this.addressLng,
  });

  /// Returns a map of `{field: humanReadableError}`. Empty map == valid.
  ValidationErrors validate() {
    final errors = <String, String>{};

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      errors['name'] = 'الاسم مطلوب';
    } else if (trimmedName.length < 2) {
      errors['name'] = 'الاسم قصير جداً';
    } else if (trimmedName.length > 120) {
      errors['name'] = 'الاسم طويل جداً';
    }

    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) {
      errors['phone'] = 'رقم الهاتف مطلوب';
    } else if (!_phoneRegex.hasMatch(normalizedPhone)) {
      errors['phone'] = 'صيغة رقم الهاتف غير صحيحة';
    }

    if (email != null && email!.trim().isNotEmpty) {
      if (!_emailRegex.hasMatch(email!.trim())) {
        errors['email'] = 'صيغة البريد الإلكتروني غير صحيحة';
      }
    }

    if (password != null) {
      final pw = password!;
      if (pw.length < 8) {
        errors['password'] = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
      } else if (pw.length > 72) {
        errors['password'] = 'كلمة المرور طويلة جداً';
      } else if (!_hasLetter.hasMatch(pw) || !_hasDigit.hasMatch(pw)) {
        errors['password'] = 'يجب أن تحتوي كلمة المرور على حرف ورقم';
      }
    }

    if (role == UserRole.supplier && supplierType == null) {
      errors['supplierType'] = 'اختر نوع المورد (فردي أو متجر)';
    }
    if (role == UserRole.driver) {
      if (vehiclePlate == null || vehiclePlate!.trim().isEmpty) {
        errors['vehiclePlate'] = 'رقم لوحة المركبة مطلوب للسائقين';
      }
    }
    if (role != UserRole.supplier && supplierType != null) {
      errors['supplierType'] = 'نوع المورد لا يُستخدم إلا مع دور المورد';
    }

    return errors;
  }

  Map<String, dynamic> toInsertRow({required String authId}) {
    return <String, dynamic>{
      'auth_id': authId,
      'name': name.trim(),
      'phone': phone.trim(),
      'role': role.dbValue,
      if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      if (supplierType != null) 'supplier_type': supplierType!.dbValue,
      if (vehiclePlate != null && vehiclePlate!.trim().isNotEmpty)
        'vehicle_plate': vehiclePlate!.trim(),
      if (vehicleModel != null && vehicleModel!.trim().isNotEmpty)
        'vehicle_model': vehicleModel!.trim(),
      if (vehicleColor != null && vehicleColor!.trim().isNotEmpty)
        'vehicle_color': vehicleColor!.trim(),
      if (vehiclePhotoUrl != null && vehiclePhotoUrl!.trim().isNotEmpty)
        'vehicle_photo_url': vehiclePhotoUrl!.trim(),
      if (address != null && address!.trim().isNotEmpty)
        'address': address!.trim(),
      if (addressLat != null && addressLng != null)
        'location': 'SRID=4326;POINT($addressLng $addressLat)',
    };
  }

  static final _phoneRegex = RegExp(r'^\+?\d{9,15}$');
  static final _emailRegex = RegExp(r"^[\w.\-]+@[\w\-]+(\.[\w\-]+)+$");
  static final _hasLetter = RegExp(r'[A-Za-z]');
  static final _hasDigit = RegExp(r'\d');
}

/// Delegates auth operations to [SupabaseAuthService].
///
/// All methods return [AppResult] so call sites use `result.fold(...)` rather
/// than try/catch. Field-level validation errors are surfaced via
/// [ValidationFailure.fieldErrors].

class UserSignUpService {
  UserSignUpService({SupabaseAuthService? authService})
      : _injected = authService;

  final SupabaseAuthService? _injected;

  static SupabaseAuthService? _globalAuth;
  static LocalStore? _globalStore;

  /// Wires the production [SupabaseAuthService] (with file storage and any
  /// other dependencies) once at app boot. Preferred over [setGlobalStore].
  static void setGlobalAuthService(SupabaseAuthService service) {
    _globalAuth = service;
  }

  /// Legacy boot hook used by tests that don't need file uploads. Builds a
  /// minimal [SupabaseAuthService] on demand.
  static void setGlobalStore(LocalStore store) => _globalStore = store;

  SupabaseAuthService get _auth {
    final injected = _injected;
    if (injected != null) return injected;
    final wired = _globalAuth;
    if (wired != null) return wired;
    final store = _globalStore;
    if (store == null) {
      throw StateError(
        'UserSignUpService.setGlobalAuthService (or setGlobalStore) must be '
        'called from main.dart before signUp/signIn.',
      );
    }
    return SupabaseAuthService(store: store);
  }

  Future<AppResult<Map<String, dynamic>>> signUp(
    SignUpRequest request, {
    File? profilePhoto,
    File? identityDocument,
  }) =>
      _auth.signUp(
        request,
        profilePhoto: profilePhoto,
        identityDocument: identityDocument,
      );

  Future<AppResult<Map<String, dynamic>>> signIn({
    required String identifier,
    required String password,
  }) =>
      _auth.signIn(identifier: identifier, password: password);

  Future<Map<String, dynamic>?> getCurrentProfile() => _auth.getCurrentUser();

  Future<void> logout() => _auth.logout();
}
