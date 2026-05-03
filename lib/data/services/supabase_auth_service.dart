import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../backend_integration_locally/local_store.dart';
import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_file_storage_repository.dart';
import '../models/user_role.dart';
import 'user_signup_service.dart' show SignUpRequest;

/// Supabase-backed auth service.
///
/// Authenticates via Supabase Auth (email + password) and stores / reads
/// profile data from the `public.users` table. All methods return
/// [AppResult] so call sites can use `result.fold(...)` rather than
/// try/catch.
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

  Future<AppResult<Map<String, dynamic>>> signUp(
    SignUpRequest request, {
    File? profilePhoto,
    File? identityDocument,
  }) async {
    // [CHANGE] Validation disabled for sign-up flow to allow bypassing checks
    /*
    // The ViewModel runs the full validation suite before calling this
    // method; we only re-check the absolute requirements for Supabase Auth.
    final pw = request.password;
    if (pw == null || pw.isEmpty) {
      return const Failure(ValidationFailure(
        message: 'كلمة المرور مطلوبة',
        fieldErrors: {'password': 'كلمة المرور مطلوبة'},
      ));
    }

    final email = request.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      return const Failure(ValidationFailure(
        message: 'البريد الإلكتروني مطلوب',
        fieldErrors: {'email': 'البريد الإلكتروني مطلوب للتسجيل'},
      ));
    }
    */
    final pw = request.password ?? '';
    final email = request.email?.trim().toLowerCase() ?? '';

    // 1. Create Supabase Auth user
    final AuthResponse authResponse;
    try {
      authResponse = await _client.auth.signUp(email: email, password: pw);
    } on AuthException catch (e) {
      return Failure(AuthFailure(message: _mapAuthError(e)));
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
    // We need a valid JWT so RLS allows the profile INSERT.
    if (authResponse.session == null) {
      try {
        await _client.auth.signInWithPassword(email: email, password: pw);
      } on AuthException catch (e) {
        return Failure(AuthFailure(message: _mapAuthError(e)));
      }
    }

    // 2. Insert profile row into public.users.
    try {
      final profileRow = <String, dynamic>{
        'auth_id': authUser.id,
        'name': request.name.trim(),
        'phone': request.phone.trim(),
        'email': email,
        'role': request.role.dbValue,
        // DB CHECK: supplier role requires supplier_type
        if (request.supplierType != null)
          'supplier_type': request.supplierType!.dbValue,
        // DB CHECK: driver role requires vehicle_plate (NOT NULL)
        if (request.vehiclePlate != null &&
            request.vehiclePlate!.trim().isNotEmpty)
          'vehicle_plate': request.vehiclePlate!.trim()
        else if (request.role == UserRole.driver)
          'vehicle_plate': '',
        if (request.vehicleModel != null &&
            request.vehicleModel!.trim().isNotEmpty)
          'vehicle_model': request.vehicleModel!.trim(),
        if (request.vehicleColor != null &&
            request.vehicleColor!.trim().isNotEmpty)
          'vehicle_color': request.vehicleColor!.trim(),
        if (request.address != null && request.address!.trim().isNotEmpty)
          'address': request.address!.trim(),
      };

      final inserted = await _client
          .from('users')
          .insert(profileRow)
          .select()
          .single();

      final userId = inserted['id'] as String;
      await _store.setCurrentUserId(userId);

      // 3. Upload media if provided. We swallow upload errors so a flaky
      //    network on signup day does not lose the freshly-created account;
      //    the user can re-upload from their profile screen.
      final updates = <String, dynamic>{};
      final fs = _fileStorage;
      if (fs != null) {
        if (profilePhoto != null) {
          final res = await fs.uploadProfilePhoto(
            userId: userId,
            file: profilePhoto,
          );
          res.fold(
            onSuccess: (url) => updates['profile_photo_url'] = url,
            onFailure: (_) {},
          );
        }
        if (identityDocument != null) {
          final res = await fs.uploadIdentityDocument(
            userId: userId,
            file: identityDocument,
          );
          res.fold(
            onSuccess: (path) => updates['identity_doc_path'] = path,
            onFailure: (_) {},
          );
        }
      }

      Map<String, dynamic> finalRow = inserted;
      if (updates.isNotEmpty) {
        try {
          finalRow = await _client
              .from('users')
              .update(updates)
              .eq('id', userId)
              .select()
              .single();
        } catch (_) {
          // Keep insert row on failure; URLs will be filled on next login.
        }
      }

      return Success(_normalizeProfile(finalRow));
    } on PostgrestException catch (e) {
      await _client.auth.signOut();
      return Failure(UnknownFailure(
        message: 'خطأ بقاعدة البيانات: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      await _client.auth.signOut();
      return Failure(UnknownFailure(
        message: 'فشل حفظ البيانات، حاول مجدداً',
      ));
    }
  }

  // ── Sign-in ──────────────────────────────────────────────────────────────

  Future<AppResult<Map<String, dynamic>>> signIn({
    required String identifier,
    required String password,
  }) async {
    // [CHANGE] Validation disabled to allow bypassing checks
    /*
    final id = identifier.trim().toLowerCase();
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
    */
    final id = identifier.trim().toLowerCase();

    // If the identifier looks like a phone number, look up the email first.
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
      return Failure(AuthFailure(message: _mapAuthError(e)));
    }

    final profile = await _fetchCurrentProfile();
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
    return _fetchCurrentProfile();
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    await _store.clearCurrentUserId();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _fetchCurrentProfile() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    try {
      final rows = await _client
          .from('users')
          .select()
          .eq('auth_id', authUser.id)
          .limit(1);

      if (rows.isEmpty) return null;
      return _normalizeProfile(rows.first);
    } catch (_) {
      return null;
    }
  }

  /// Normalizes a Supabase row to the same key shape ViewModels expect.
  Map<String, dynamic> _normalizeProfile(Map<String, dynamic> row) {
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
      'created_at': row['created_at'],
    };
  }

  /// Maps Supabase AuthException messages to user-facing Arabic strings.
  String _mapAuthError(AuthException e) {
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
    if (msg.contains('weak') || msg.contains('password')) {
      return 'كلمة المرور ضعيفة جداً';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'تحقق من اتصالك بالإنترنت';
    }
    return 'تعذّر تسجيل الدخول، حاول مجدداً';
  }
}
