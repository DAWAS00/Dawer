import '../../core/result/result.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_role.dart';
import '../services/user_signup_service.dart' show SignUpRequest;

/// A fake auth implementation that allows bypassing real Supabase auth
/// for development and UI testing.
final class MockAuthRepository implements IAuthRepository {
  final UserRole initialRole;
  final SupplierType? initialSupplierType;

  MockAuthRepository({
    this.initialRole = UserRole.driver,
    this.initialSupplierType,
  });

  @override
  Future<AppResult<AuthSession>> signInWithEmail(
    String email,
    String password,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In mock mode, any non-empty credentials succeed
    return Success(AuthSession(
      userId: 'mock-uuid-1234',
      role: initialRole,
      supplierType: initialSupplierType,
    ));
  }

  @override
  Future<AppResult<AuthSession>> signUp(SignUpRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    return Success(AuthSession(
      userId: 'mock-uuid-5678',
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
    await Future.delayed(const Duration(seconds: 1));
    return Success(AuthSession(
      userId: 'mock-uuid-otp',
      role: initialRole,
      supplierType: initialSupplierType,
    ));
  }

  @override
  Future<void> signOut() async {
    // No-op
  }

  @override
  Stream<AuthSession?> watchAuthState() {
    // Never changes in this simple mock
    return const Stream.empty();
  }

  @override
  AuthSession? get currentSession => null;
}
