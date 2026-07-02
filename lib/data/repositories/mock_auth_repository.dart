import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_role.dart';
import 'package:dwaar/data/models/signup_request.dart';

/// A fake auth implementation that allows bypassing real Supabase auth
/// for development and UI testing.
///
/// Test accounts (OTP for all: 123456):
///   0791234567  →  محمد عمر خليل       (Driver)
///   0792345678  →  ليلى ناصر أبو حمد   (Supplier – Individual)
///   0793456789  →  مطعم الزيتونة        (Supplier – Store)
///   0794567890  →  شركة الخضراء للتدوير (Recycling Company)
final class MockAuthRepository implements IAuthRepository {
  static const simulatedOtp = '123456';

  AuthSession? _activeSession;

  final Map<String, AuthSession> _users = {
    '+962791234567': const AuthSession(
      userId: '11111111-1111-1111-1111-111111111111',
      userName: 'محمد عمر خليل',
      role: UserRole.driver,
    ),
    '+962792345678': const AuthSession(
      userId: '22222222-2222-2222-2222-222222222222',
      userName: 'ليلى ناصر أبو حمد',
      role: UserRole.supplier,
      supplierType: SupplierType.individual,
    ),
    '+962793456789': const AuthSession(
      userId: '33333333-3333-3333-3333-333333333333',
      userName: 'مطعم الزيتونة',
      role: UserRole.supplier,
      supplierType: SupplierType.storeBusiness,
    ),
    '+962794567890': const AuthSession(
      userId: '44444444-4444-4444-4444-444444444444',
      userName: 'شركة الخضراء للتدوير',
      role: UserRole.recyclingCo,
    ),
  };

  MockAuthRepository();

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

    if (otp != simulatedOtp) {
      return const Failure(
        AuthFailure(
          code: AuthErrorCodes.invalidOtp,
          message: 'رمز التحقق غير صحيح. استخدم: $simulatedOtp',
        ),
      );
    }

    final normalizedPhone = _normalizePhone(phone);
    final existingSession = _users[normalizedPhone];

    if (existingSession == null) {
      return const Failure(
        NotFoundFailure(
          code: AuthErrorCodes.phoneNotRegistered,
          message: 'رقم الهاتف غير مسجل. يرجى إنشاء حساب أولاً.',
        ),
      );
    }

    _activeSession = existingSession;
    return Success(existingSession);
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
