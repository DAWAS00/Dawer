import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_file_storage_repository.dart';

/// Supabase Storage implementation of [IFileStorageRepository].
///
/// Bucket layout and policies (see migration
/// `add_user_media_columns_and_profile_photos_bucket`):
///   • `profile-photos` (public)  → `{userId}/profile.<ext>`
///   • `user-documents` (private) → `{userId}/identity.<ext>`
class SupabaseFileStorageRepository implements IFileStorageRepository {
  SupabaseFileStorageRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _profileBucket = 'profile-photos';
  static const String _docsBucket = 'user-documents';

  static const Set<String> _imageExts = {'.jpg', '.jpeg', '.png', '.webp'};
  static const Set<String> _docExts = {'.jpg', '.jpeg', '.png', '.webp', '.pdf'};

  @override
  Future<AppResult<String>> uploadProfilePhoto({
    required String userId,
    required File file,
  }) {
    return _upload(
      bucket: _profileBucket,
      userId: userId,
      file: file,
      baseName: 'profile',
      allowedExts: _imageExts,
      returnPublicUrl: true,
    );
  }

  @override
  Future<AppResult<String>> uploadIdentityDocument({
    required String userId,
    required File file,
  }) {
    return _upload(
      bucket: _docsBucket,
      userId: userId,
      file: file,
      baseName: 'identity',
      allowedExts: _docExts,
      returnPublicUrl: false,
    );
  }

  @override
  Future<AppResult<String>> signedIdentityUrl({
    required String objectPath,
    Duration validity = const Duration(minutes: 5),
  }) async {
    try {
      final url = await _client.storage.from(_docsBucket).createSignedUrl(
            objectPath,
            validity.inSeconds,
          );
      return Success(url);
    } on StorageException catch (e) {
      return Failure(StorageFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  // ─── internals ────────────────────────────────────────────────────────────

  Future<AppResult<String>> _upload({
    required String bucket,
    required String userId,
    required File file,
    required String baseName,
    required Set<String> allowedExts,
    required bool returnPublicUrl,
  }) async {
    final ext = p.extension(file.path).toLowerCase();
    if (!allowedExts.contains(ext)) {
      return Failure(ValidationFailure(
        message: 'صيغة الملف غير مدعومة',
        fieldErrors: {'file': 'يجب أن يكون الملف بصيغة ${allowedExts.join("، ")}'},
      ));
    }

    if (!await file.exists()) {
      return const Failure(StorageFailure(message: 'الملف غير موجود'));
    }

    final objectPath = '$userId/$baseName$ext';
    try {
      await _client.storage.from(bucket).upload(
            objectPath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );
      if (returnPublicUrl) {
        return Success(_client.storage.from(bucket).getPublicUrl(objectPath));
      }
      return Success(objectPath);
    } on StorageException catch (e) {
      return Failure(StorageFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }
}
