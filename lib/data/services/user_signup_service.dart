import 'dart:io';

import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_file_storage_repository.dart';
import '../models/signup_request.dart';
import '../models/user_role.dart';

class UserSignUpService {
  final IAuthRepository _authRepository;
  final IFileStorageRepository _fileStorage;

  UserSignUpService({
    required IAuthRepository authRepository,
    required IFileStorageRepository fileStorage,
  }) : _authRepository = authRepository,
       _fileStorage = fileStorage;

  /// Global store reference for backward compatibility in tests
  static dynamic _globalStore;
  static void setGlobalStore(dynamic store) {
    _globalStore = store;
  }

  static get globalStore => _globalStore;

  Future<AppResult<Map<String, dynamic>>> signUp(
    SignUpRequest request, {
    File? profilePhoto,
    File? identityDocument,
  }) async {
    final authResult = await _authRepository.signUp(request);

    return authResult.fold(
      onSuccess: (session) async {
        final userId = session.userId;
        String? profilePhotoUrl;
        String? identityDocPath;

        if (profilePhoto != null) {
          final uploadResult = await _fileStorage.uploadProfilePhoto(
            userId: userId,
            file: profilePhoto,
          );
          uploadResult.fold(
            onSuccess: (url) => profilePhotoUrl = url,
            onFailure: (failure) {},
          );
          if (profilePhotoUrl == null) {
            return const Failure(
              StorageFailure(message: 'فشل رفع صورة الملف الشخصي'),
            );
          }
        }

        if (identityDocument != null) {
          final uploadResult = await _fileStorage.uploadIdentityDocument(
            userId: userId,
            file: identityDocument,
          );
          uploadResult.fold(
            onSuccess: (path) => identityDocPath = path,
            onFailure: (failure) {},
          );
          if (identityDocPath == null) {
            return const Failure(
              StorageFailure(message: 'فشل رفع وثيقة الهوية'),
            );
          }
        }

        return Success({
          'id': session.userId,
          'name': session.userName,
          'role': session.role.dbValue,
          if (session.supplierType != null)
            'supplier_type': session.supplierType!.dbValue,
          if (profilePhotoUrl != null) 'profile_photo_url': profilePhotoUrl,
          if (identityDocPath != null) 'identity_doc_path': identityDocPath,
          'categories': session.categories,
        });
      },
      onFailure: (failure) => Failure(failure),
    );
  }

  Future<void> logout() async {
    await _authRepository.signOut();
  }
}
