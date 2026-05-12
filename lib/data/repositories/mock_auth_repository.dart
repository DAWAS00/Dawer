import '../../core/result/result.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_role.dart';
import '../services/user_signup_service.dart' show SignUpRequest;

/// Fake auth — bypasses Supabase for local UI testing.
///
/// Role is inferred from the email/phone you type at login:
///   • contains "recycl" or "company"  → recyclingCo
///   • contains "supplier"             → supplier / individual
///   • contains "biz" or "store"       → supplier / storeBusiness
///   • anything else                   → driver  (default)
///
/// Password can be anything non-empty.
final class MockAuthRepository implements IAuthRepository {
  MockAuthRepository();

  AuthSession? _session;

  static (UserRole, SupplierType?) _resolveRole(String identifier) {
    final id = identifier.trim().toLowerCase();
    if (id.contains('recycl') || id.contains('company')) {
      return (UserRole.recyclingCo, null);
    }
    if (id.contains('biz') || id.contains('store')) {
      return (UserRole.supplier, SupplierType.storeBusiness);
    }
    if (id.contains('supplier')) {
      return (UserRole.supplier, SupplierType.individual);
    }
    return (UserRole.driver, null);
  }

  static String _mockName(UserRole role) => switch (role) {
        UserRole.driver => 'أحمد (تجريبي)',
        UserRole.supplier => 'سارة (تجريبي)',
        UserRole.recyclingCo => 'شركة عمان (تجريبي)',
      };

  @override
  Future<AppResult<AuthSession>> signInWithEmail(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final (role, supplierType) = _resolveRole(email);
    _session = AuthSession(
      userId: 'mock-$role-uuid',
      userName: _mockName(role),
      role: role,
      supplierType: supplierType,
    );
    return Success(_session!);
  }

  @override
  Future<AppResult<AuthSession>> signUp(SignUpRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Success(AuthSession(
      userId: 'mock-signup-uuid',
      userName: request.name,
      role: request.role,
      supplierType: request.supplierType,
    ));
  }

  @override
  Future<AppResult<void>> requestOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    return const Success(null);
  }

  @override
  Future<AppResult<AuthSession>> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Success(AuthSession(
      userId: 'mock-otp-uuid',
      userName: 'Mock User',
      role: UserRole.driver,
      supplierType: null,
    ));
  }

  @override
  Future<void> signOut() async {
    _session = null;
  }

  @override
  Stream<AuthSession?> watchAuthState() {
    // Never changes in this simple mock
    return const Stream.empty();
  }

  @override
  AuthSession? get currentSession => _session;

  @override
  Future<AppResult<void>> requestPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const Success(null);
  }

  @override
  Future<AppResult<void>> verifyResetCode(String email, String code) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const Success(null);
  }

  @override
  Future<AppResult<void>> updatePassword(String newPassword) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const Success(null);
  }
}
