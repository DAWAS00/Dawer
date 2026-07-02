import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_file_storage_repository.dart';
import '../../domain/services/i_signup_orchestrator.dart';
import '../models/signup_request.dart';

/// Supabase-backed [ISignupOrchestrator].
///
/// Coordinates: auth signUp → file uploads → write-back UPDATE to `profiles`.
/// The write-back is the fix for the historical bug where photo/doc URLs were
/// uploaded but never persisted to the profile row.
final class SupabaseSignupOrchestrator implements ISignupOrchestrator {
  SupabaseSignupOrchestrator({
    required IAuthRepository authRepository,
    required IFileStorageRepository fileStorage,
    required SupabaseClient client,
  })  : _auth = authRepository,
        _files = fileStorage,
        _client = client;

  final IAuthRepository _auth;
  final IFileStorageRepository _files;
  final SupabaseClient _client;

  @override
  Future<AppResult<AuthSession>> signUp(
    SignUpRequest request, {
    File? profilePhoto,
  }) async {
    // 1. Insert the profile row via the auth repository.
    final authResult = await _auth.signUp(request);
    return authResult.fold(
      onSuccess: (session) async {
        // 2. Upload the profile photo (if provided) and write the URL back.
        if (profilePhoto != null) {
          final upload = await _files.uploadProfilePhoto(
            userId: session.userId,
            file: profilePhoto,
          );
          // Upload failure is non-fatal: the account exists, just without a
          // photo. Log and continue rather than rolling back the signup.
          if (upload is Success<String, AppFailure>) {
            await _writeProfileFields(
              session.userId,
              {'profile_photo_url': upload.value},
            );
          } else {
            debugPrint(
              '[SignupOrchestrator] profile photo upload failed for '
              '${session.userId}; profile created without photo.',
            );
          }
        }
        return Success(session);
      },
      onFailure: (failure) => Failure(failure),
    );
  }

  @override
  Future<AppResult<void>> updateProfile(SignUpRequest request) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const Failure(AuthFailure(message: 'انتهت الجلسة. سجّل الدخول مجدداً.'));
    }

    // Build the subset of fields that are "progressive" (collected after the
    // initial account creation on Screen 4). Reuse toInsertRow but strip the
    // identity fields that must not change (auth_id, name, phone, role).
    final row = request.toInsertRow(authId: userId)
      ..remove('auth_id')
      ..remove('name')
      ..remove('phone')
      ..remove('role')
      ..remove('email');

    // Only UPDATE if there's something to write.
    if (row.isEmpty) return const Success(null);
    return _writeProfileFields(userId, row);
  }

  @override
  Future<AppResult<String>> uploadIdentityDocument(File document) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const Failure(AuthFailure(message: 'انتهت الجلسة. سجّل الدخول مجدداً.'));
    }

    final upload = await _files.uploadIdentityDocument(
      userId: userId,
      file: document,
    );
    return upload.fold(
      onSuccess: (objectPath) async {
        // Write the path back + mark as pending review.
        final writeBack = await _writeProfileFields(userId, {
          'identity_doc_path': objectPath,
          'is_verified': false,
        });
        return writeBack.fold(
          onSuccess: (_) => Success(objectPath),
          onFailure: (f) => Failure(f),
        );
      },
      onFailure: (f) => Failure(f),
    );
  }

  /// Low-level: runs `UPDATE profiles SET <fields> WHERE auth_id = <userId>`.
  /// Centralizes error mapping so callers don't repeat themselves.
  Future<AppResult<void>> _writeProfileFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      await _client
          .from('profiles')
          .update(fields)
          .eq('auth_id', userId);
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failure(UnknownFailure(message: e.message, code: e.code));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }
}
