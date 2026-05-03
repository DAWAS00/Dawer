/// Plain data class representing a locally persisted user profile.
///
/// Field semantics mirror the backend payload shape so ViewModels can keep
/// consuming `Map<String, dynamic>` without changes.
class LocalUser {
  final String id;
  final String name;
  final String phone;
  final String? email;

  /// Matches `UserRole.dbValue`: `driver` | `supplier` | `recyclingCo`.
  final String role;

  /// Matches `SupplierType.dbValue` when [role] is `supplier`, else null.
  final String? supplierType;

  final String? vehiclePlate;
  final String? vehicleModel;
  final String? vehicleColor;

  /// base64(sha256(salt || password)) — see [PasswordHasher].
  final String passwordHash;

  /// base64(16 random bytes).
  final String passwordSalt;

  /// ISO 8601 timestamp string.
  final String createdAt;

  const LocalUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.passwordHash,
    required this.passwordSalt,
    this.email,
    this.supplierType,
    this.vehiclePlate,
    this.vehicleModel,
    this.vehicleColor,
  });

  /// Decodes a stored row. Tolerates missing password fields from older app
  /// versions by substituting empty strings — those rows are wiped by the auth
  /// migration runner before any login attempt reaches this decoder.
  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      supplierType: json['supplier_type'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      vehicleColor: json['vehicle_color'] as String?,
      passwordHash: json['password_hash'] as String? ?? '',
      passwordSalt: json['password_salt'] as String? ?? '',
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        'role': role,
        if (supplierType != null) 'supplier_type': supplierType,
        if (vehiclePlate != null) 'vehicle_plate': vehiclePlate,
        if (vehicleModel != null) 'vehicle_model': vehicleModel,
        if (vehicleColor != null) 'vehicle_color': vehicleColor,
        'password_hash': passwordHash,
        'password_salt': passwordSalt,
        'created_at': createdAt,
      };

  LocalUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? supplierType,
    String? vehiclePlate,
    String? vehicleModel,
    String? vehicleColor,
    String? passwordHash,
    String? passwordSalt,
    String? createdAt,
  }) {
    return LocalUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      supplierType: supplierType ?? this.supplierType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
