import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_file_storage_repository.dart';
import '../local/local_store.dart';
import '../models/user_role.dart';
import 'user_signup_service.dart' show SignUpRequest;

part 'supabase_auth_service/auth_helpers.dart';
part 'supabase_auth_service/signup_helpers.dart';

/// Supabase-backed auth service.
///
/// Authenticates via Supabase Auth (email + password) and stores / reads
/// profile data from the `public.users` table. All methods return
/// [AppResult] so call sites can use `result.fold(...)` rather than
/// try/catch.
///
/// Sign-up plumbing, profile normalisation, and auth-error translation all
/// live in `supabase_auth_service/auth_helpers.dart` as a part-file extension.
class SupabaseAuthService {
  SupabaseAuthService({
    required LocalStore store,
    IFileStorageRepository? fileStorage,
  })  : _store = store,
        _fileStorage = fileStorage;

  final LocalStore _store;
  final IFileStorageRepository? _fileStorage;
  SupabaseClient get _client => Supabase.instance.client;

  // ── Sign-up ──────────────────────────────────────────────────────────────

  /// Creates a new account with profile row and optional media uploads.
  ///
  /// Thin delegator — full implementation lives in [performSignUp] so fakes
  /// in tests can cleanly override this method.
  Future<AppResult<Map<String, dynamic>>> signUp(
    SignUpRequest request, {
    File? profilePhoto,
    File? identityDocument,
  }) {
    return performSignUp(
      request,
      profilePhoto: profilePhoto,
      identityDocument: identityDocument,
    );
  }

  // ── Sign-in ──────────────────────────────────────────────────────────────

  Future<AppResult<Map<String, dynamic>>> signIn({
    required String identifier,
    required String password,
  }) async {
    final id = identifier.trim().toLowerCase();

    if (!kDebugMode) {
      if (id.isEmpty) {
        return const Failure(ValidationFailure(
          message: 'أدخل البريد الإلكتروني أو رقم الهاتف',
          fieldErrors: {'identifier': 'أدخل البريد الإلكتروني أو رقم الهاتف'},
        ));
      }
      if (password.isEmpty) {
        return const Failure(ValidationFailure(
          message: 'أدخل كلمة المرور',
          fieldErrors: {'password': 'أدخل كلمة المرور'},
        ));
      }
    }

    String emailToUse = id;
    if (!id.contains('@')) {
      try {
        final result = await _client.rpc(
          'get_email_by_phone',
          params: {'phone_number': id},
        );
        if (result == null || (result is String && result.isEmpty)) {
          return const Failure(
            AuthFailure(message: 'بيانات الدخول غير صحيحة'),
          );
        }
        emailToUse = result as String;
      } catch (_) {
        return const Failure(
          AuthFailure(message: 'بيانات الدخول غير صحيحة'),
        );
      }
    }

    try {
      await _client.auth.signInWithPassword(
        email: emailToUse,
        password: password,
      );
    } on AuthException catch (e) {
      return Failure(AuthFailure(message: mapAuthError(e)));
    }

    final profile = await fetchCurrentProfile();
    if (profile == null) {
      return const Failure(AuthFailure(message: 'بيانات الدخول غير صحيحة'));
    }

    await _store.setCurrentUserId(profile['id'] as String);
    return Success(profile);
  }

  // ── Session ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;
    return fetchCurrentProfile();
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    await _store.clearCurrentUserId();
  }
}
