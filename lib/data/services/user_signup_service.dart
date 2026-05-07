import 'dart:io';

export '../../domain/requests/sign_up_request.dart';
import '../../core/result/result.dart';
import '../../domain/requests/sign_up_request.dart';
import 'supabase_auth_service.dart';

/// Delegates auth operations to [SupabaseAuthService].
///
/// All methods return [AppResult] so call sites use `result.fold(...)` rather
/// than try/catch. Field-level validation errors are surfaced via
/// [ValidationFailure.fieldErrors].

class UserSignUpService {
  UserSignUpService({SupabaseAuthService? authService})
      : _injected = authService;

  final SupabaseAuthService? _injected;

  SupabaseAuthService get _auth {
    final injected = _injected;
    if (injected != null) return injected;
    throw StateError(
      'UserSignUpService requires a SupabaseAuthService injected via constructor.',
    );
  }

  Future<AppResult<Map<String, dynamic>>> signUp(
    SignUpRequest request, {
    File? profilePhoto,
    File? identityDocument,
  }) =>
      _auth.signUp(
        request,
        profilePhoto: profilePhoto,
        identityDocument: identityDocument,
      );

  Future<AppResult<Map<String, dynamic>>> signIn({
    required String identifier,
    required String password,
  }) =>
      _auth.signIn(identifier: identifier, password: password);

  Future<Map<String, dynamic>?> getCurrentProfile() => _auth.getCurrentUser();

  Future<void> logout() => _auth.logout();
}
