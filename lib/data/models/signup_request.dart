import 'order/order.dart' show VehicleType;
import 'user_role.dart';

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
  final List<String> categories;
  final VehicleType? vehicleType;
  final bool hasChemicalPermit;

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
    this.categories = const [],
    this.vehicleType,
    this.hasChemicalPermit = false,
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
    } else if (normalizedPhone.length != 10 ||
        !_phoneRegex.hasMatch(normalizedPhone)) {
      errors['phone'] =
          'رقم الهاتف يجب أن يتكون من 10 أرقام ويبدأ بـ 07 (مثال: 07XXXXXXXX)';
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
    final cleanPhone = phone.trim();
    final normalizedPhone =
        (cleanPhone.length == 10 && cleanPhone.startsWith('0'))
        ? '+962${cleanPhone.substring(1)}'
        : cleanPhone;

    return <String, dynamic>{
      'auth_id': authId,
      'name': name.trim(),
      'phone': normalizedPhone,
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
      if (addressLat != null && addressLng != null) ...{
        // PostgREST cannot cast EWKT → geography. Write numeric lat/lng; a DB
        // trigger (00004_postgis_compat.sql) populates the `location` geography
        // column from these.
        'location_lat': addressLat,
        'location_lng': addressLng,
      },
      if (categories.isNotEmpty) 'categories': categories,
      // vehicle_type enum values match the Dart enum `.name` exactly
      // (motorcycle/car/pickup/van/truck/heavyTruck) — see 20260522_vehicle_type.sql.
      if (vehicleType != null) 'vehicle_type': vehicleType!.name,
      'has_chemical_permit': hasChemicalPermit,
    };
  }

  static final _phoneRegex = RegExp(r'^07\d{8}$');
  static final _emailRegex = RegExp(r"^[\w.\-]+@[\w\-]+(\.[\w\-]+)+$");
  static final _hasLetter = RegExp(r'[A-Za-z]');
  static final _hasDigit = RegExp(r'\d');
}
