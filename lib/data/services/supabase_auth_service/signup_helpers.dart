part of '../supabase_auth_service.dart';

/// Private sign-up plumbing — input validation, profile-row construction,
/// media uploads, and profile-row updates. Part-file extension so helpers
/// have direct access to `_client`, `_store`, `_fileStorage`.
extension _SupabaseAuthSignUpHelpers on SupabaseAuthService {
  AppResult<Map<String, dynamic>>? validateSignUpInputs({
    required String email,
    required String password,
  }) {
    if (kDebugMode) return null;
    if (password.isEmpty) {
      return const Failure<Map<String, dynamic>, AppFailure>(
        ValidationFailure(
          message: 'كلمة المرور مطلوبة',
          fieldErrors: {'password': 'كلمة المرور مطلوبة'},
        ),
      );
    }
    if (email.isEmpty) {
      return const Failure<Map<String, dynamic>, AppFailure>(
        ValidationFailure(
          message: 'البريد الإلكتروني مطلوب',
          fieldErrors: {'email': 'البريد الإلكتروني مطلوب للتسجيل'},
        ),
      );
    }
    return null;
  }

  Map<String, dynamic> buildProfileRow({
    required String authUserId,
    required String email,
    required SignUpRequest request,
  }) {
    return <String, dynamic>{
      'auth_id': authUserId,
      'name': request.name.trim(),
      'phone': request.phone.trim(),
      'email': email,
      'role': request.role.dbValue,
      if (request.supplierType != null)
        'supplier_type': request.supplierType!.dbValue,
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
      if (request.categories.isNotEmpty) 'categories': request.categories,
    };
  }

  Future<Map<String, dynamic>> uploadSignUpMedia({
    required String userId,
    File? profilePhoto,
    File? identityDocument,
  }) async {
    final updates = <String, dynamic>{};
    final fs = _fileStorage;
    if (fs == null) return updates;

    if (profilePhoto != null) {
      final res =
          await fs.uploadProfilePhoto(userId: userId, file: profilePhoto);
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
    return updates;
  }

  Future<Map<String, dynamic>> applyProfileUpdates({
    required String userId,
    required Map<String, dynamic> insertedRow,
    required Map<String, dynamic> updates,
  }) async {
    if (updates.isEmpty) return insertedRow;
    try {
      return await _client
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
    } catch (_) {
      return insertedRow;
    }
  }
}
