import '../../core/result/result.dart';
import '../../data/models/user_role.dart';
import '../../data/services/user_signup_service.dart' show SignUpRequest;

class AuthSession {
  final String userId;
  final UserRole role;
  final SupplierType? supplierType;

  const AuthSession({
    required this.userId,
    required this.role,
    this.supplierType,
  });
}

abstract interface class IAuthRepository {
  Future<AppResult<AuthSession>> signInWithEmail(
      String email, String password);

  Future<AppResult<AuthSession>> signUp(SignUpRequest request);

  Future<AppResult<void>> requestOtp(String phone);

  Future<AppResult<AuthSession>> verifyOtp(String phone, String otp);

  Future<void> signOut();

  Stream<AuthSession?> watchAuthState();

  AuthSession? get currentSession;
}
