import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../local/local_store.dart';
import '../models/user_role.dart';
import '../services/user_signup_service.dart';

part 'supabase_auth_repository/helpers.dart';

/// Supabase-backed [IAuthRepository] implementation.
///
/// Profile → session mapping, local-store cache plumbing, and session
/// rehydration live in `supabase_auth_repository/helpers.dart` as a part-file
/// extension so this file stays focused on the interface contract.
final class SupabaseAuthRepository implements IAuthRepository {
  SupabaseAuthRepository(this._client, this._signUpService, this._localStore);

  final SupabaseClient _client;
  final UserSignUpService _signUpService;
  final LocalStore _localStore;

  // ── Sign-in / sign-up ───────────────────────────────────────────────────

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
        final session = mapProfileToSession(profile);
        cacheSession(session);
        return Success(session);
      },
      onFailure: Failure.new,
    );
  }

  @override
  Future<AppResult<AuthSession>> signUp(SignUpRequest request) async {
    final result = await _signUpService.signUp(request);
    return result.fold(
      onSuccess: (profile) {
        final session = mapProfileToSession(profile);
        cacheSession(session);
        return Success(session);
      },
      onFailure: Failure.new,
    );
  }

  // ── OTP ─────────────────────────────────────────────────────────────────

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
      final response = await _client.auth
          .verifyOTP(phone: phone, token: otp, type: OtpType.sms);

      if (response.session == null) {
        return const Failure(AuthFailure(message: 'رمز التحقق غير صحيح'));
      }

      final profile = await _signUpService.getCurrentProfile();
      if (profile == null) {
        return const Failure(
          AuthFailure(message: 'تعذر العثور على الملف الشخصي'),
        );
      }

      final authSession = mapProfileToSession(profile);
      cacheSession(authSession);
      return Success(authSession);
    } on AuthException catch (e) {
      return Failure(AuthFailure(message: e.message));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  // ── Session lifecycle ──────────────────────────────────────────────────

  @override
  Future<void> signOut() {
    clearCache();
    return _signUpService.logout();
  }

  @override
  Stream<AuthSession?> watchAuthState() {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      if (event.session == null) {
        clearCache();
        return null;
      }
      final profile = await _signUpService.getCurrentProfile();
      if (profile == null) {
        clearCache();
        return null;
      }
      final authSession = mapProfileToSession(profile);
      cacheSession(authSession);
      return authSession;
    });
  }

  @override
  AuthSession? get currentSession => rehydrateSessionFromCache();

  // ── Password reset ─────────────────────────────────────────────────────

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
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      await _client.auth.signOut();
      return const Success(null);
    } on AuthException catch (e) {
      return Failure(AuthFailure(message: e.message));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }
}
