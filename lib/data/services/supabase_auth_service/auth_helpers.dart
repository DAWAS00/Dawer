part of '../supabase_auth_service.dart';

/// Core sign-up flow + profile normalisation + auth-error translation, all in
/// one part-file extension so they can freely access the main class's private
/// state (`_client`, `_store`). Further sign-up plumbing (validation,
/// profile-row building, media uploads) lives in `signup_helpers.dart`.
extension SupabaseAuthHelpers on SupabaseAuthService {
  /// Core sign-up flow. The class exposes a thin `signUp` delegator so test
  /// fakes can still override it as a regular instance method.
  Future<AppResult<Map<String, dynamic>>> performSignUp(
    SignUpRequest request, {
    File? profilePhoto,
    File? identityDocument,
  }) async {
    final pw = request.password ?? '';
    final email = request.email?.trim().toLowerCase() ?? '';

    final validation = validateSignUpInputs(email: email, password: pw);
    if (validation != null) return validation;

    final AuthResponse authResponse;
    try {
      authResponse = await _client.auth.signUp(email: email, password: pw);
    } on AuthException catch (e) {
      return Failure(AuthFailure(message: mapAuthError(e)));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }

    final authUser = authResponse.user;
    if (authUser == null) {
      return const Failure(
        AuthFailure(message: 'فشل إنشاء الحساب، حاول مجدداً'),
      );
    }

    // If email confirmation is enabled, signUp returns a user but no session.
    // A valid JWT is required so RLS permits the profile INSERT.
    if (authResponse.session == null) {
      try {
        await _client.auth.signInWithPassword(email: email, password: pw);
      } on AuthException catch (e) {
        return Failure(AuthFailure(message: mapAuthError(e)));
      }
    }

    try {
      final profileRow = buildProfileRow(
        authUserId: authUser.id,
        email: email,
        request: request,
      );
      final inserted = await _client
          .from('users')
          .insert(profileRow)
          .select()
          .single();

      final userId = inserted['id'] as String;
      await _store.setCurrentUserId(userId);

      final updates = await uploadSignUpMedia(
        userId: userId,
        profilePhoto: profilePhoto,
        identityDocument: identityDocument,
      );
      final finalRow = await applyProfileUpdates(
        userId: userId,
        insertedRow: inserted,
        updates: updates,
      );

      return Success(normalizeProfile(finalRow));
    } on PostgrestException catch (e) {
      await _client.auth.signOut();
      return Failure(UnknownFailure(
        message: 'خطأ بقاعدة البيانات: ${e.message}',
        code: e.code,
      ));
    } catch (_) {
      await _client.auth.signOut();
      return const Failure(UnknownFailure(
        message: 'فشل حفظ البيانات، حاول مجدداً',
      ));
    }
  }

  /// Fetches the current authenticated user's profile row, if any.
  Future<Map<String, dynamic>?> fetchCurrentProfile() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;
    try {
      final rows = await _client
          .from('users')
          .select()
          .eq('auth_id', authUser.id)
          .limit(1);
      if (rows.isEmpty) return null;
      return normalizeProfile(rows.first);
    } catch (_) {
      return null;
    }
  }

  /// Normalizes a Supabase row to the key shape ViewModels expect.
  Map<String, dynamic> normalizeProfile(Map<String, dynamic> row) {
    return <String, dynamic>{
      'id': row['id'],
      'auth_id': row['auth_id'],
      'name': row['name'],
      'phone': row['phone'],
      'email': row['email'],
      'role': row['role'],
      if (row['supplier_type'] != null) 'supplier_type': row['supplier_type'],
      if (row['vehicle_plate'] != null) 'vehicle_plate': row['vehicle_plate'],
      if (row['vehicle_model'] != null) 'vehicle_model': row['vehicle_model'],
      if (row['vehicle_color'] != null) 'vehicle_color': row['vehicle_color'],
      if (row['address'] != null) 'address': row['address'],
      'rating': row['rating'],
      'total_orders': row['total_orders'],
      'is_verified': row['is_verified'],
      'points': row['points'],
      if (row['profile_photo_url'] != null)
        'profile_photo_url': row['profile_photo_url'],
      if (row['identity_doc_path'] != null)
        'identity_doc_path': row['identity_doc_path'],
      'categories':
          (row['categories'] as List?)?.cast<String>() ?? const <String>[],
      'created_at': row['created_at'],
    };
  }

  /// Maps Supabase [AuthException] messages to user-facing Arabic strings.
  String mapAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('email') && msg.contains('already')) {
      return 'يوجد حساب بهذا البريد الإلكتروني بالفعل';
    }
    if (msg.contains('invalid') || msg.contains('credentials')) {
      return 'بيانات الدخول غير صحيحة';
    }
    if (msg.contains('rate') || msg.contains('limit')) {
      return 'تم إيقاف المحاولات مؤقتاً، حاول بعد دقيقة';
    }
    if (msg.contains('weak')) {
      return 'كلمة المرور ضعيفة جداً';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'تحقق من اتصالك بالإنترنت';
    }
    return 'تعذّر تسجيل الدخول، حاول مجدداً';
  }
}
