import '../../core/result/result.dart';
import '../../data/models/user_role.dart';
import 'package:dwaar/data/models/signup_request.dart';

abstract final class AuthErrorCodes {
  static const phoneNotRegistered = 'phone_not_registered';
  static const invalidOtp = 'invalid_otp';
}

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
  Future<AppResult<AuthSession>> signUp(SignUpRequest request);

  Future<AppResult<void>> requestOtp(String phone);

  Future<AppResult<AuthSession>> verifyOtp(String phone, String otp);

  Future<void> signOut();

  Stream<AuthSession?> watchAuthState();

  AuthSession? get currentSession;
}
