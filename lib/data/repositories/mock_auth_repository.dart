import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_role.dart';
import 'package:dwaar/data/models/signup_request.dart';

/// A fake auth implementation that allows bypassing real Supabase auth
/// for development and UI testing.
/// 
/// Magic Numbers:
/// - +962790000001 -> Driver
/// - +962790000002 -> Individual Supplier
/// - +962790000003 -> Store Business Supplier
/// - +962790000004 -> Recycling Company
final class MockAuthRepository implements IAuthRepository {
  static const simulatedOtp = '123456';

  AuthSession? _activeSession;

  final Map<String, AuthSession> _users = {
    '+962790000001': const AuthSession(
      userId: 'm-driver-123',
      userName: 'أحمد السائق (تجريبي)',
      role: UserRole.driver,
    ),
    '+962790000002': const AuthSession(
      userId: 'm-supp-456',
      userName: 'خالد المورد (فردي)',
      role: UserRole.supplier,
      supplierType: SupplierType.individual,
    ),
    '+962790000003': const AuthSession(
      userId: 'm-store-789',
      userName: 'مطعم أبو علي (تجاري)',
      role: UserRole.supplier,
      supplierType: SupplierType.storeBusiness,
    ),
    '+962790000004': const AuthSession(
      userId: 'm-recy-000',
      userName: 'شركة تدويركم (تجريبي)',
      role: UserRole.recyclingCo,
    ),
  };

  UserRole _targetRole;
  SupplierType? _targetSupplierType;

  MockAuthRepository({
    UserRole initialRole = UserRole.driver,
    SupplierType? initialSupplierType,
  })  : _targetRole = initialRole,
        _targetSupplierType = initialSupplierType;

  /// Called by ViewModel to sync the UI selection before login
  void updateTargetRole(UserRole role, [SupplierType? type]) {
    _targetRole = role;
    _targetSupplierType = type;
  }

  String _normalizePhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (clean.length == 10 && clean.startsWith('0')) {
      return '+962${clean.substring(1)}';
    }
    return clean;
  }

  @override
  Future<AppResult<AuthSession>> signUp(SignUpRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    final normalizedPhone = _normalizePhone(request.phone);
    final session = AuthSession(
      userId: 'm-new-${DateTime.now().millisecondsSinceEpoch}',
      userName: request.name,
      role: request.role,
      supplierType: request.supplierType,
    );
    _users[normalizedPhone] = session;
    _activeSession = session;
    return Success(session);
  }

  @override
  Future<AppResult<void>> requestOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    return const Success(null);
  }

  @override
  Future<AppResult<AuthSession>> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // [DEV] Validation temporarily disabled
    // if (otp != simulatedOtp) {
    //   return const Failure(AuthFailure(code: AuthErrorCodes.invalidOtp, message: 'رمز التحقق غير صحيح'));
    // }

    final normalizedPhone = _normalizePhone(phone);
    final existingSession = _users[normalizedPhone];

    if (existingSession == null) {
      return const Failure(NotFoundFailure(
        code: AuthErrorCodes.phoneNotRegistered,
        message: 'رقم الهاتف غير مسجل. يرجى إنشاء حساب أولاً.',
      ));
    }

    // Always respect the role the user selected on the login screen
    // This prevents the issue where entering the same test phone number
    // ignores the selected role and forces the user into the rider screen.
    final session = AuthSession(
      userId: existingSession.userId,
      userName: existingSession.userName,
      role: _targetRole,
      supplierType: _targetSupplierType,
    );

    _users[normalizedPhone] = session;
    _activeSession = session;
    return Success(session);
  }

  void setActiveSession(AuthSession session) {
    _activeSession = session;
  }

  @override
  Future<void> signOut() async {
    _activeSession = null;
  }

  @override
  Stream<AuthSession?> watchAuthState() {
    return const Stream.empty();
  }

  @override
  AuthSession? get currentSession => _activeSession;
}
