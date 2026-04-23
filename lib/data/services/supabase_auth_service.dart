import 'package:supabase_flutter/supabase_flutter.dart';

import '../../backend_integration_locally/local_store.dart';
import '../models/user_role.dart';
import 'user_signup_service.dart' show SignUpRequest, SignUpException;

/// Supabase-backed auth service that replaces [LocalAuthService].
///
/// Authenticates via Supabase Auth (email + password) and stores / reads
/// profile data from the `public.users` table. Returns the same
/// `Map<String, dynamic>` shape so ViewModels work unchanged.
class SupabaseAuthService {
  SupabaseAuthService({required LocalStore store}) : _store = store;

  final LocalStore _store;
  SupabaseClient get _client => Supabase.instance.client;

  // ── Sign-up ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> signUp(SignUpRequest request) async {
    // Note: ViewModel validates before calling this method.
    // We only guard the absolute requirements for Supabase Auth here.

    final pw = request.password;
    if (pw == null || pw.isEmpty) {
      throw const SignUpException(
        'كلمة المرور مطلوبة',
        fieldErrors: {'password': 'كلمة المرور مطلوبة'},
      );
    }

    final email = request.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      throw const SignUpException(
        'البريد الإلكتروني مطلوب',
        fieldErrors: {'email': 'البريد الإلكتروني مطلوب للتسجيل'},
      );
    }

    // 2. Create Supabase Auth user
    final AuthResponse authResponse;
    try {
      authResponse = await _client.auth.signUp(
        email: email,
        password: pw,
      );
    } on AuthException catch (e) {
      throw SignUpException(
        _mapAuthError(e),
        cause: e,
      );
    }

    final authUser = authResponse.user;
    if (authUser == null) {
      throw const SignUpException(
        'فشل إنشاء الحساب، حاول مجدداً',
      );
    }

    // If email confirmation is enabled, signUp returns a user but NO session.
    // We need a valid session (JWT) so RLS policies allow the profile INSERT.
    if (authResponse.session == null) {
      try {
        await _client.auth.signInWithPassword(
          email: email,
          password: pw,
        );
      } on AuthException catch (e) {
        throw SignUpException(
          _mapAuthError(e),
          cause: e,
        );
      }
    }

    // 3. Insert profile row into public.users
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

      // Cache locally
      await _store.setCurrentUserId(inserted['id'] as String);

      return _normalizeProfile(inserted);
    } catch (e) {
      // If profile insert fails, clean up the auth user by signing out
      await _client.auth.signOut();
      if (e is SignUpException) rethrow;

      String errorMessage = 'فشل حفظ البيانات، حاول مجدداً';
      if (e is PostgrestException) {
        errorMessage = 'خطأ بقاعدة البيانات: ${e.message}';
      } else {
        errorMessage = 'فشل الحفظ: $e';
      }

      throw SignUpException(
        errorMessage,
        cause: e,
      );
    }
  }

  // ── Sign-in ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> signIn({
    required String identifier,
    required String password,
  }) async {
    final id = identifier.trim().toLowerCase();
    if (id.isEmpty) {
      throw const SignUpException('أدخل البريد الإلكتروني أو رقم الهاتف');
    }
    if (password.isEmpty) {
      throw const SignUpException('أدخل كلمة المرور');
    }

    // If the identifier looks like a phone number, look up the email first
    String emailToUse = id;
    if (!id.contains('@')) {
      // Phone-based login: use RPC function that bypasses RLS
      try {
        final result = await _client.rpc(
          'get_email_by_phone',
          params: {'phone_number': id},
        );
        if (result == null || (result is String && result.isEmpty)) {
          throw const SignUpException('بيانات الدخول غير صحيحة');
        }
        emailToUse = result as String;
      } catch (e) {
        if (e is SignUpException) rethrow;
        throw const SignUpException('بيانات الدخول غير صحيحة');
      }
    }

    // Authenticate with Supabase Auth
    try {
      await _client.auth.signInWithPassword(
        email: emailToUse,
        password: password,
      );
    } on AuthException catch (e) {
      throw SignUpException(_mapAuthError(e), cause: e);
    }

    // Fetch profile
    final profile = await _fetchCurrentProfile();
    if (profile == null) {
      throw const SignUpException('بيانات الدخول غير صحيحة');
    }

    await _store.setCurrentUserId(profile['id'] as String);
    return profile;
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

  /// Normalizes the Supabase row to the same key shape the ViewModels expect
  /// (matching the old LocalAuthService output).
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
