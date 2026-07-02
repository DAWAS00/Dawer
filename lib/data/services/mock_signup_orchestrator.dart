import 'dart:io';
import '../../core/result/result.dart';
import '../../data/models/signup_request.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_file_storage_repository.dart';
import '../../domain/services/i_signup_orchestrator.dart';

/// Mock-mode [ISignupOrchestrator] for offline/test runs. Delegates account
/// creation to the (mock) auth repository and skips the Supabase write-back —
/// there's no live `profiles` row to update in mock mode.
class MockSignupOrchestrator implements ISignupOrchestrator {
  MockSignupOrchestrator({
    required this.authRepository,
    required this.fileStorage,
  });

  final IAuthRepository authRepository;
  final IFileStorageRepository fileStorage;

  @override
  Future<AppResult<AuthSession>> signUp(
    SignUpRequest request, {
    File? profilePhoto,
  }) async {
    if (profilePhoto != null) {
      await fileStorage.uploadProfilePhoto(
        userId: request.phone,
        file: profilePhoto,
      );
    }
    return authRepository.signUp(request);
  }

  @override
  Future<AppResult<void>> updateProfile(SignUpRequest request) async =>
      const Success(null);

  @override
  Future<AppResult<String>> uploadIdentityDocument(File document) async =>
      fileStorage.uploadIdentityDocument(userId: 'mock-user', file: document);
}
