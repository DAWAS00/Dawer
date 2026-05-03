import 'package:supabase_flutter/supabase_flutter.dart';

import '../../backend_integration_locally/local_store.dart';
import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_role.dart';
import '../services/user_signup_service.dart';

final class SupabaseAuthRepository implements IAuthRepository {
  SupabaseAuthRepository(this._client, this._signUpService, this._localStore);

  final SupabaseClient _client;
  final UserSignUpService _signUpService;
  final LocalStore _localStore;

  // ── IAuthRepository ────────────────────────────────────────────────────────

  @override
  Future<AppResult<AuthSession>> signInWithEmail(
    String email,
    String password,
  ) async {
    final result = await _signUpService.signIn(
      identifier: email,
      password: password,
    );

    return result.fold(
      onSuccess: (profile) {
        final session = _mapProfileToSession(profile);
        _cacheSession(session);
        return Success(session);
      },
      onFailure: (failure) => Failure(failure),
    );
  }

  @override
  Future<AppResult<AuthSession>> signUp(SignUpRequest request) async {
    final result = await _signUpService.signUp(request);

    return result.fold(
      onSuccess: (profile) {
        final session = _mapProfileToSession(profile);
        _cacheSession(session);
        return Success(session);
      },
      onFailure: (failure) => Failure(failure),
    );
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

      final profile = await _signUpService.getCurrentProfile();
      if (profile == null) {
        return const Failure(AuthFailure(message: 'تعذر العثور على الملف الشخصي'));
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
  Future<void> signOut() {
    _clearCache();
    return _signUpService.logout();
  }

  @override
  Stream<AuthSession?> watchAuthState() {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) {
        _clearCache();
        return null;
      }
      
      final profile = await _signUpService.getCurrentProfile();
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
    
    final userId = session.user.id;
    // Try to get cached role from local store
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

    final categories = _localStore.getCurrentUserCategories();

    return AuthSession(
      userId: userId,
      userName: userName,
      role: role,
      supplierType: supplierType,
      categories: categories,
    );
  }

  // ── Password reset ───────────────────────────────────────────────

  @override
  Future<AppResult<void>> requestPasswordReset(String email) async {
    try {
      await _client.auth.signInWithOtp(
        email: email.trim().toLowerCase(),
        shouldCreateUser: false,
      );
      return const Success(null);
    } on AuthException catch (e) {
      return Failure(AuthFailure(message: e.message));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<AppResult<void>> verifyResetCode(String email, String code) async {
    try {
      await _client.auth.verifyOTP(
        email: email.trim().toLowerCase(),
        token: code.trim(),
        type: OtpType.email,
      );
      return const Success(null);
    } on AuthException catch (e) {
      return Failure(AuthFailure(message: e.message));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<AppResult<void>> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      await _client.auth.signOut();
      return const Success(null);
    } on AuthException catch (e) {
      return Failure(AuthFailure(message: e.message));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _cacheSession(AuthSession session) {
    _localStore.setCurrentUserRole(session.role.dbValue);
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
    final categories = rawCats is List ? rawCats.cast<String>() : const <String>[];

    return AuthSession(
      userId: profile['auth_id'] as String,
      userName: profile['name'] as String? ?? 'مستخدم',
      role: role,
      supplierType: supplierType,
      categories: categories,
    );
  }
}

