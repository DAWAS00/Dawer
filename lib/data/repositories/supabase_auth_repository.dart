import 'package:supabase_flutter/supabase_flutter.dart';

import '../../backend_integration_locally/local_store.dart';
import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/signup_request.dart';
import '../models/user_role.dart';

final class SupabaseAuthRepository implements IAuthRepository {
  SupabaseAuthRepository(this._client, this._localStore);

  final SupabaseClient _client;
  final LocalStore _localStore;

  // ── IAuthRepository ────────────────────────────────────────────────────────

  @override
  Future<AppResult<AuthSession>> signUp(SignUpRequest request) async {
    try {
      // Auth user already exists — created by signInWithOtp + verifyOTP earlier
      // in the flow. Just insert the profile row with the current user's id.
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Failure(AuthFailure(message: 'انتهت الجلسة. أعد التحقق من رقم هاتفك.'));
      }

      await _client.from('profiles').insert(
        request.toInsertRow(authId: user.id),
      );

      final session = AuthSession(
        userId: user.id,
        userName: request.name,
        role: request.role,
        supplierType: request.supplierType,
        categories: request.categories,
      );
      _cacheSession(session);
      return Success(session);
    } on PostgrestException catch (e) {
      return Failure(UnknownFailure(message: e.message, code: e.code));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<AppResult<void>> requestOtp(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
      return const Success(null);
    } on AuthException catch (e) {
      return Failure(AuthFailure(message: e.message));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<AppResult<AuthSession>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.session == null) {
        return const Failure(AuthFailure(message: 'رمز التحقق غير صحيح'));
      }

      final profile = await _fetchProfile();
      if (profile == null) {
        // New user — OTP verified but no profile yet. Caller should redirect to signup wizard.
        return const Failure(NotFoundFailure(
          message: 'لم يتم العثور على حساب. سيتم توجيهك لإنشاء حساب.',
          code: AuthErrorCodes.phoneNotRegistered,
        ));
      }

      final authSession = _mapProfileToSession(profile);
      _cacheSession(authSession);
      return Success(authSession);
    } on AuthException catch (e) {
      return Failure(AuthFailure(message: e.message));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<void> signOut() async {
    _clearCache();
    await _client.auth.signOut();
  }

  @override
  Stream<AuthSession?> watchAuthState() {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) {
        _clearCache();
        return null;
      }

      final profile = await _fetchProfile();
      if (profile == null) {
        _clearCache();
        return null;
      }

      final authSession = _mapProfileToSession(profile);
      _cacheSession(authSession);
      return authSession;
    });
  }

  @override
  AuthSession? get currentSession {
    final session = _client.auth.currentSession;
    if (session == null) return null;

    final roleStr = _localStore.getCurrentUserRole();
    if (roleStr == null) return null;

    final userName = _localStore.getCurrentUserName() ?? 'مستخدم';
    final supplierStr = _localStore.getCurrentSupplierType();

    UserRole? role;
    for (final r in UserRole.values) {
      if (r.dbValue == roleStr) {
        role = r;
        break;
      }
    }
    if (role == null) return null;

    SupplierType? supplierType;
    if (supplierStr != null) {
      for (final s in SupplierType.values) {
        if (s.dbValue == supplierStr) {
          supplierType = s;
          break;
        }
      }
    }

    return AuthSession(
      userId: session.user.id,
      userName: userName,
      role: role,
      supplierType: supplierType,
      categories: _localStore.getCurrentUserCategories(),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _fetchProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      return await _client
          .from('profiles')
          .select()
          .eq('auth_id', uid)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  void _cacheSession(AuthSession session) {
    _localStore.setCurrentUserRole(session.role.dbValue);
    // ignore: discarded_futures
    _localStore.setCurrentUserName(session.userName);
    if (session.supplierType != null) {
      _localStore.setCurrentSupplierType(session.supplierType!.dbValue);
    } else {
      _localStore.clearCurrentSupplierType();
    }
    // ignore: discarded_futures
    _localStore.setCurrentUserCategories(session.categories);
  }

  void _clearCache() {
    _localStore.clearCurrentUserRole();
    // ignore: discarded_futures
    _localStore.clearCurrentUserName();
    _localStore.clearCurrentSupplierType();
    // ignore: discarded_futures
    _localStore.clearCurrentUserCategories();
  }

  AuthSession _mapProfileToSession(Map<String, dynamic> profile) {
    final roleStr = profile['role'] as String? ?? '';
    final supplierStr = profile['supplier_type'] as String?;

    UserRole role = UserRole.supplier;
    for (final r in UserRole.values) {
      if (r.dbValue == roleStr) {
        role = r;
        break;
      }
    }

    SupplierType? supplierType;
    if (supplierStr != null) {
      for (final s in SupplierType.values) {
        if (s.dbValue == supplierStr) {
          supplierType = s;
          break;
        }
      }
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
}
