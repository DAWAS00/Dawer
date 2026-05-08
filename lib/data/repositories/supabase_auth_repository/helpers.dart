part of '../supabase_auth_repository.dart';

/// Private helpers for [SupabaseAuthRepository] — session caching, local-store
/// rehydration, and profile → [AuthSession] mapping. Kept in a part-file
/// extension so the main repository stays focused on the [IAuthRepository]
/// contract.
extension SupabaseAuthRepositoryHelpers on SupabaseAuthRepository {
  void cacheSession(AuthSession session) {
    _localStore.setCurrentUserRole(session.role.dbValue);
    if (session.supplierType != null) {
      _localStore.setCurrentSupplierType(session.supplierType!.dbValue);
    } else {
      _localStore.clearCurrentSupplierType();
    }
    // ignore: discarded_futures
    _localStore.setCurrentUserCategories(session.categories);
  }

  void clearCache() {
    _localStore.clearCurrentUserRole();
    _localStore.clearCurrentSupplierType();
    // ignore: discarded_futures
    _localStore.clearCurrentUserCategories();
  }

  AuthSession mapProfileToSession(Map<String, dynamic> profile) {
    final roleStr = profile['role'] as String? ?? '';
    final supplierStr = profile['supplier_type'] as String?;

    UserRole role;
    try {
      role = UserRoleDbMapping.fromDb(roleStr);
    } catch (_) {
      role = UserRole.supplier;
    }

    SupplierType? supplierType;
    if (supplierStr != null) {
      try {
        supplierType = SupplierTypeDbMapping.fromDb(supplierStr);
      } catch (_) {}
    }

    final rawCats = profile['categories'];
    final categories =
        rawCats is List ? rawCats.cast<String>() : const <String>[];

    return AuthSession(
      userId: profile['auth_id'] as String,
      userName: profile['name'] as String? ?? 'مستخدم',
      role: role,
      supplierType: supplierType,
      categories: categories,
    );
  }

  /// Rebuilds the [AuthSession] for an already-authenticated user from
  /// locally-cached role/category data. Returns null when no Supabase session
  /// exists or the cache is missing / corrupt.
  AuthSession? rehydrateSessionFromCache() {
    final session = _client.auth.currentSession;
    if (session == null) return null;

    final roleStr = _localStore.getCurrentUserRole();
    if (roleStr == null) return null;

    final userName = _localStore.getCurrentUserName() ?? 'مستخدم';
    final supplierStr = _localStore.getCurrentSupplierType();

    UserRole role;
    try {
      role = UserRoleDbMapping.fromDb(roleStr);
    } catch (_) {
      return null;
    }

    SupplierType? supplierType;
    if (supplierStr != null) {
      try {
        supplierType = SupplierTypeDbMapping.fromDb(supplierStr);
      } catch (_) {}
    }

    return AuthSession(
      userId: session.user.id,
      userName: userName,
      role: role,
      supplierType: supplierType,
      categories: _localStore.getCurrentUserCategories(),
    );
  }
}
