// Shared role labels for app state and serialized user payloads.
//
// Keep [UserRoleDbMapping.dbValue] / [SupplierTypeDbMapping.dbValue] stable so
// persisted data and backend-facing payloads remain compatible.

enum UserRole { driver, supplier, recyclingCo }

enum SupplierType { individual, storeBusiness }

extension UserRoleDbMapping on UserRole {
  /// Exact label used by the `user_role` Postgres enum.
  String get dbValue => switch (this) {
        UserRole.driver => 'driver',
        UserRole.supplier => 'supplier',
        UserRole.recyclingCo => 'recyclingCo',
      };

  /// Parse a value coming back from Postgres. Throws [ArgumentError] on an
  /// unknown label so a drifted schema fails loudly instead of silently.
  static UserRole fromDb(String value) {
    for (final r in UserRole.values) {
      if (r.dbValue == value) return r;
    }
    throw ArgumentError.value(value, 'value', 'unknown user_role');
  }

  /// All valid SQL labels, in declaration order. Useful for client-side
  /// allow-listing.
  static List<String> get allowedDbValues =>
      UserRole.values.map((r) => r.dbValue).toList(growable: false);
}

extension SupplierTypeDbMapping on SupplierType {
  String get dbValue => switch (this) {
        SupplierType.individual => 'individual',
        SupplierType.storeBusiness => 'storeBusiness',
      };

  static SupplierType fromDb(String value) {
    for (final t in SupplierType.values) {
      if (t.dbValue == value) return t;
    }
    throw ArgumentError.value(value, 'value', 'unknown supplier_type');
  }

  static List<String> get allowedDbValues =>
      SupplierType.values.map((t) => t.dbValue).toList(growable: false);
}
