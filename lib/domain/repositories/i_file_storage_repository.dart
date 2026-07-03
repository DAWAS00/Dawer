import 'dart:io';

import '../../core/result/result.dart';

/// Repository for uploading user media (avatars, identity docs) to remote
/// storage. Implementations must enforce the bucket-naming and folder layout
/// rules expected by the storage RLS policies.
abstract class IFileStorageRepository {
  /// Uploads [file] to the public `profile-photos` bucket under
  /// `{userId}/profile.<ext>` and returns the public URL.
  Future<AppResult<String>> uploadProfilePhoto({
    required String userId,
    required File file,
  });

  /// Uploads [file] to the private `user-documents` bucket under
  /// `{userId}/identity.<ext>` and returns the storage object path
  /// (NOT a URL — UI layers must mint signed URLs on demand).
  Future<AppResult<String>> uploadIdentityDocument({
    required String userId,
    required File file,
  });

  /// Creates a short-lived signed URL for a private object stored under
  /// the `user-documents` bucket. Used to display identity docs in
  /// admin/profile screens without exposing them publicly.
  Future<AppResult<String>> signedIdentityUrl({
    required String objectPath,
    Duration validity = const Duration(minutes: 5),
  });

  /// Uploads [file] to the private `user-documents` bucket under
  /// `{userId}/business_license.<ext>` and returns the storage object path
  /// (NOT a URL). Used by Screen 5 for store-business suppliers and
  /// recycling companies uploading a business license / commercial
  /// registration document.
  Future<AppResult<String>> uploadBusinessLicense({
    required String userId,
    required File file,
  });

  /// Creates a short-lived signed URL for a private business-license object
  /// stored under the `user-documents` bucket. Mirrors [signedIdentityUrl].
  Future<AppResult<String>> signedBusinessLicenseUrl({
    required String objectPath,
    Duration validity = const Duration(minutes: 5),
  });
}

/// No-op stub for tests / mock mode.
class NoOpFileStorageRepository implements IFileStorageRepository {
  const NoOpFileStorageRepository();

  @override
  Future<AppResult<String>> uploadProfilePhoto({
    required String userId,
    required File file,
  }) async => Success('mock://profile/$userId.jpg');

  @override
  Future<AppResult<String>> uploadIdentityDocument({
    required String userId,
    required File file,
  }) async => Success('$userId/identity.jpg');

  @override
  Future<AppResult<String>> signedIdentityUrl({
    required String objectPath,
    Duration validity = const Duration(minutes: 5),
  }) async => Success('mock://signed/$objectPath');

  @override
  Future<AppResult<String>> uploadBusinessLicense({
    required String userId,
    required File file,
  }) async => Success('$userId/business_license.jpg');

  @override
  Future<AppResult<String>> signedBusinessLicenseUrl({
    required String objectPath,
    Duration validity = const Duration(minutes: 5),
  }) async => Success('mock://signed/$objectPath');
}
