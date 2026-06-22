import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/result/result.dart';
import '../../../../data/models/order/order.dart' show VehicleType;
import '../../../../data/models/signup_request.dart';
import '../../../../data/models/user_role.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../domain/services/i_signup_orchestrator.dart';

/// Clean state machine for the redesigned phone-first signup flow.
///
/// Replaces the old `SignupWizardController`. Key differences:
/// - Actually calls [SignUpRequest.validate] (the old one rolled a 2-field subset).
/// - Delegates upload→insert→write-back to [ISignupOrchestrator] (fixes the
///   "photo/doc uploaded but URL never persisted" bug).
/// - Supports progressive profiling: [submitIdentity] creates the account;
///   [submitRoleDetails] / [submitDocuments] fill the rest later.
///
/// See `docs/signup-redesign-plan.md`.
class SignupController extends ChangeNotifier {
  SignupController({
    required ISignupOrchestrator orchestrator,
    required this.phone,
  }) : _orchestrator = orchestrator;

  final ISignupOrchestrator _orchestrator;

  /// Phone number, verified via OTP before this controller is constructed.
  final String phone;

  // ── Identity step (Screen 3) state ─────────────────────────────────────────
  String fullName = '';
  File? profilePhoto;
  UserRole role = UserRole.supplier;
  SupplierType supplierType = SupplierType.individual;

  // ── Role-details step (Screen 4) state ─────────────────────────────────────
  String vehiclePlate = '';
  String vehicleModel = '';
  String vehicleColor = '';
  VehicleType? vehicleType;
  bool hasChemicalPermit = false;
  String address = '';
  double? addressLat;
  double? addressLng;
  List<String> categories = const [];

  // ── Documents step (Screen 5) state ────────────────────────────────────────
  File? identityDocument;
  bool documentsUploaded = false;

  // ── UI state ───────────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  bool _submitted = false; // identity step succeeded → navigate to HomeRouter
  String? _error;
  Map<String, String> _fieldErrors = const {};
  AuthSession? _session;

  bool get isSubmitting => _isSubmitting;
  bool get submitted => _submitted;
  String? get error => _error;
  Map<String, String> get fieldErrors => _fieldErrors;
  AuthSession? get session => _session;

  // ── Mutators (called from the screens) ─────────────────────────────────────

  void updateRole(UserRole r, [SupplierType? st]) {
    role = r;
    if (r == UserRole.supplier) {
      supplierType = st ?? supplierType;
    }
    _fieldErrors = {};
    notifyListeners();
  }

  void setSupplierType(SupplierType st) {
    supplierType = st;
    notifyListeners();
  }

  void setVehicleData({
    String? model,
    String? color,
    VehicleType? type,
    bool? chemicalPermit,
    String? plate,
  }) {
    if (model != null) vehicleModel = model;
    if (color != null) vehicleColor = color;
    if (type != null) vehicleType = type;
    if (chemicalPermit != null) hasChemicalPermit = chemicalPermit;
    if (plate != null) vehiclePlate = plate;
    notifyListeners();
  }

  void setLocation(double lat, double lng, [String? addr]) {
    addressLat = lat;
    addressLng = lng;
    if (addr != null) address = addr;
    notifyListeners();
  }

  void setCategories(List<String> cats) {
    categories = cats;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _fieldErrors = const {};
    notifyListeners();
  }

  // ── Submission: identity step (creates the account) ───────────────────────

  /// Validates the identity subset (name, role, supplierType) using the real
  /// [SignUpRequest.validate]. Returns the errors map; empty == valid.
  Map<String, String> validateIdentity() {
    return _buildIdentityRequest().validate();
  }

  /// Submits the identity step: creates the profile row + uploads the photo.
  /// On success sets [submitted] = true (the screen navigates to HomeRouter).
  Future<void> submitIdentity() async {
    _error = null;
    final errors = validateIdentity();
    // Filter to only identity-relevant keys for display.
    _fieldErrors = Map.fromEntries(
      errors.entries.where(
        (e) => const ['name', 'supplierType'].contains(e.key),
      ),
    );
    if (_fieldErrors.isNotEmpty) {
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    final result = await _orchestrator.signUp(
      _buildIdentityRequest(),
      profilePhoto: profilePhoto,
    );

    result.fold(
      onSuccess: (session) {
        _session = session;
        _submitted = true;
      },
      onFailure: (f) => _error = f.message,
    );

    _isSubmitting = false;
    notifyListeners();
  }

  // ── Submission: role details step (progressive UPDATE) ────────────────────

  /// Validates the role-specific fields. Returns errors map; empty == valid.
  Map<String, String> validateRoleDetails() {
    return _buildFullRequest().validate();
  }

  /// Progressively updates the profile with role-specific data (vehicle info,
  /// address, categories). Called from Screen 4 after the user is already in
  /// the app. Returns true on success.
  Future<bool> submitRoleDetails() async {
    final errors = validateRoleDetails();
    _fieldErrors = Map.fromEntries(
      errors.entries.where(
        (e) => const ['vehiclePlate', 'vehicleModel'].contains(e.key),
      ),
    );
    if (_fieldErrors.isNotEmpty) {
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _orchestrator.updateProfile(_buildFullRequest());

    _isSubmitting = false;
    result.fold(
      onSuccess: (_) {},
      onFailure: (f) => _error = f.message,
    );
    notifyListeners();
    return result is Success;
  }

  // ── Submission: documents step ─────────────────────────────────────────────

  /// Uploads the identity document and marks the account as pending review.
  /// Returns the storage object path on success, null on failure.
  Future<String?> submitDocuments() async {
    if (identityDocument == null) {
      _error = 'يرجى اختيار صورة الوثيقة';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _orchestrator.uploadIdentityDocument(identityDocument!);

    String? path;
    result.fold(
      onSuccess: (p) {
        path = p;
        documentsUploaded = true;
      },
      onFailure: (f) => _error = f.message,
    );

    _isSubmitting = false;
    notifyListeners();
    return path;
  }

  // ── Request builders ───────────────────────────────────────────────────────

  /// Minimum-viable request for account creation (identity step).
  SignUpRequest _buildIdentityRequest() {
    return SignUpRequest(
      name: fullName.trim(),
      phone: phone,
      role: role,
      supplierType: role == UserRole.supplier ? supplierType : null,
    );
  }

  /// Full request with all collected data, for the progressive UPDATE.
  SignUpRequest _buildFullRequest() {
    return SignUpRequest(
      name: fullName.trim(),
      phone: phone,
      role: role,
      supplierType: role == UserRole.supplier ? supplierType : null,
      vehiclePlate: role == UserRole.driver ? vehiclePlate : null,
      vehicleModel: role == UserRole.driver && vehicleModel.isNotEmpty
          ? vehicleModel
          : null,
      vehicleColor: role == UserRole.driver && vehicleColor.isNotEmpty
          ? vehicleColor
          : null,
      vehicleType: role == UserRole.driver ? vehicleType : null,
      hasChemicalPermit: role == UserRole.driver ? hasChemicalPermit : false,
      address: address.isNotEmpty ? address : null,
      addressLat: addressLat,
      addressLng: addressLng,
      categories: categories,
    );
  }
}
