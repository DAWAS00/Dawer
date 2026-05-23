import '../../core/result/result.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_role.dart';
import '../services/user_signup_service.dart' show SignUpRequest;
import 'package:faker/faker.dart';

/// A fake auth implementation that allows bypassing real Supabase auth
/// for development and UI testing.
/// 
/// Magic Emails:
/// - driver@dawar.com -> Driver
/// - supplier@dawar.com -> Individual Supplier
/// - store@dawar.com -> Store Business Supplier
/// - recycling@dawar.com -> Recycling Company
final class MockAuthRepository implements IAuthRepository {
  UserRole _currentRole;
  SupplierType? _currentSupplierType;
  AuthSession? _activeSession;

  MockAuthRepository({
    UserRole initialRole = UserRole.driver,
    SupplierType? initialSupplierType,
  }) : _currentRole = initialRole,
       _currentSupplierType = initialSupplierType;

  @override
  Future<AppResult<AuthSession>> signInWithEmail(
    String email,
    String password,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final emailLower = email.toLowerCase().trim();
    
    // Magic email mapping
    AuthSession session;
    if (emailLower == 'driver@dawar.com') {
      session = const AuthSession(
        userId: 'm-driver-123',
        userName: 'أحمد السائق (تجريبي)',
        role: UserRole.driver,
      );
    } else if (emailLower == 'supplier@dawar.com') {
      session = const AuthSession(
        userId: 'm-supp-456',
        userName: 'خالد المورد (فردي)',
        role: UserRole.supplier,
        supplierType: SupplierType.individual,
      );
    } else if (emailLower == 'store@dawar.com') {
      session = const AuthSession(
        userId: 'm-store-789',
        userName: 'مطعم أبو علي (تجاري)',
        role: UserRole.supplier,
        supplierType: SupplierType.storeBusiness,
      );
    } else if (emailLower == 'recycling@dawar.com') {
      session = const AuthSession(
        userId: 'm-recy-000',
        userName: 'شركة تدويركم (تجريبي)',
        role: UserRole.recyclingCo,
      );
    } else {
      // Fallback: Use selected role from UI (if any) or default
      session = AuthSession(
        userId: 'm-user-${DateTime.now().millisecondsSinceEpoch}',
        userName: '${faker.person.firstName()} (تجريبي)',
        role: _currentRole,
        supplierType: _currentSupplierType,
      );
    }

    _activeSession = session;
    return Success(session);
  }

  /// Called by ViewModel to sync the UI selection before login
  void updateTargetRole(UserRole role, [SupplierType? type]) {
    _currentRole = role;
    _currentSupplierType = type;
  }

  @override
  Future<AppResult<AuthSession>> signUp(SignUpRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    final session = AuthSession(
      userId: 'm-new-${DateTime.now().millisecondsSinceEpoch}',
      userName: request.name,
      role: request.role,
      supplierType: request.supplierType,
    );
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
    final session = AuthSession(
      userId: 'm-otp-user',
      userName: 'مستخدم OTP',
      role: _currentRole,
      supplierType: _currentSupplierType,
    );
    _activeSession = session;
    return Success(session);
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
