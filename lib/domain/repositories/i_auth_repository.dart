import '../../core/result/result.dart';
import '../requests/sign_up_request.dart';
export '../entities/auth_session.dart';
import '../entities/auth_session.dart';

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
