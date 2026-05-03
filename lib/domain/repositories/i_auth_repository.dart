import '../../core/result/result.dart';
import '../../data/models/user_role.dart';
import '../../data/services/user_signup_service.dart' show SignUpRequest;

class AuthSession {
  final String userId;
  final String userName;
  final UserRole role;
  final SupplierType? supplierType;
  final List<String> categories;

  const AuthSession({
    required this.userId,
    required this.userName,
    required this.role,
    this.supplierType,
    this.categories = const [],
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

  /// Sends a 6-digit recovery OTP to [email] via Supabase.
  Future<AppResult<void>> requestPasswordReset(String email);

  /// Verifies the 6-digit recovery [code] for [email].
  /// On success the caller holds a short-lived recovery session.
  Future<AppResult<void>> verifyResetCode(String email, String code);

  /// Updates the authenticated user's password to [newPassword].
  /// Should be called immediately after [verifyResetCode] succeeds.
  /// Signs the user out of the recovery session after the update.
  Future<AppResult<void>> updatePassword(String newPassword);
}
