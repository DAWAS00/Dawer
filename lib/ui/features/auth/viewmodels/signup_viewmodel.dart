import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/user_role.dart';
import '../../../../data/services/mock_ai_marketplace_service.dart';
import '../../../../domain/services/i_ai_marketplace_service.dart';
import '../../../../data/services/user_signup_service.dart';
import 'package:dwaar/data/models/signup_request.dart';
import '../../../../domain/failures/app_failure.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../data/models/order/order.dart' show VehicleType;
import 'license_validation_viewmodel.dart';
import 'login_viewmodel.dart';
import 'vehicle_registration_viewmodel.dart';

class SignUpViewModel extends ChangeNotifier {
  final UserRole role;
  final SupplierType supplierType;

  final UserSignUpService _service;
  final LicenseValidationViewModel licenseVm = LicenseValidationViewModel();
  final VehicleRegistrationViewModel vehicleRegistrationVm = VehicleRegistrationViewModel();

  SignUpViewModel({
    required this.role,
    required this.supplierType,
    required UserSignUpService service,
  }) : _service = service;

  /// The created profile returned by [submit] (null until success).
  Map<String, dynamic>? _createdProfile;
  Map<String, dynamic>? get createdProfile => _createdProfile;

  // --- Images ---
  File? profilePhoto;
  File? identityDocument;

  // --- Common fields ---
  String fullName = '';
  String contactPhone = '';
  String contactEmail = '';
  String password = '';
  String passwordConfirm = '';

  // --- Driver / Individual Supplier ---
  String nationality = 'أردني';
  String _primaryCategory = '';

  String get primaryCategory => _primaryCategory;

  set primaryCategory(String val) {
    _primaryCategory = val;
    _fetchSuggestions(val);
    notifyListeners();
  }

  // --- Driver-only ---
  String vehiclePlate = '';
  String vehicleModel = '';
  String vehicleColor = '';
  VehicleType? vehicleType;

  // --- Business fields (Store Supplier / Recycling Co.) ---
  String businessName = '';
  String ownerOrManagerName = '';
  String coverageArea = '';

  // --- Address / Location ---
  double? _addressLat;
  double? _addressLng;
  String preciseAddress = '';

  double? get addressLat => _addressLat;
  double? get addressLng => _addressLng;
  bool get isAddressSet => _addressLat != null && _addressLng != null;

  void setAddress(double lat, double lng) {
    _addressLat = lat;
    _addressLng = lng;
    notifyListeners();
  }

  void updatePreciseAddress(String value) {
    preciseAddress = value;
    notifyListeners();
  }

  void clearAddress() {
    _addressLat = null;
    _addressLng = null;
    preciseAddress = '';
    notifyListeners();
  }

  // --- State ---
  bool _isLoading = false;
  bool _submitted = false;
  final Map<String, String> _errors = {};

  bool get isLoading => _isLoading;
  bool get submitted => _submitted;
  Map<String, String> get errors => Map.unmodifiable(_errors);

  // AI Suggestions
  final IAiMarketplaceService _aiMarketplaceService =
      MockAiMarketplaceService();
  AiMarketplaceSuggestion? _suggestion;
  AiMarketplaceSuggestion? get suggestion => _suggestion;
  bool _isLoadingSuggestion = false;
  bool get isLoadingSuggestion => _isLoadingSuggestion;
  Timer? _debounce;

  void _fetchSuggestions(String input) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _isLoadingSuggestion = true;
      notifyListeners();

      try {
        final result = await _aiMarketplaceService.getSuggestionsForSupplier(
          input,
        );
        _suggestion = result;
      } catch (_) {
        // Silently ignore AI errors
      } finally {
        _isLoadingSuggestion = false;
        notifyListeners();
      }
    });
  }

  bool get isBusinessRole =>
      role == UserRole.recyclingCo ||
      supplierType == SupplierType.storeBusiness;

  // --- Image picking ---
  final ImagePicker _picker = ImagePicker();

  Future<void> pickProfilePhoto(ImageSource source) async {
    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (xFile != null) {
      profilePhoto = File(xFile.path);
      notifyListeners();
    }
  }

  Future<void> pickIdentityDocument(ImageSource source) async {
    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (xFile != null) {
      identityDocument = File(xFile.path);
      _errors.remove('identityDocument');
      notifyListeners();
      // Trigger AI license validation in parallel with form completion
      await licenseVm.analyzeDocument(identityDocument!, role);
    }
  }

  void clearIdentityDocument() {
    identityDocument = null;
    licenseVm.reset();
    _errors.remove('identityDocument');
    notifyListeners();
  }

  Future<void> pickVehicleRegistration(ImageSource source) async {
    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (xFile != null) {
      await vehicleRegistrationVm.analyzeDocument(File(xFile.path));
    }
  }

  void clearVehicleRegistration() {
    vehicleRegistrationVm.reset();
    vehicleType = null;
    notifyListeners();
  }

  void applyExtractedVehicleData({
    required String? plate,
    required String? model,
    required String? color,
    required VehicleType? type,
  }) {
    if (plate != null && plate.isNotEmpty) vehiclePlate = plate;
    if (model != null && model.isNotEmpty) vehicleModel = model;
    if (color != null && color.isNotEmpty) vehicleColor = color;
    vehicleType = type;
    notifyListeners();
  }

  /// Categories extracted from the AI license scan, passed to the marketplace.
  List<String> get aiCategories => licenseVm.suggestedCategories;

  void removeProfilePhoto() {
    profilePhoto = null;
    notifyListeners();
  }

  void removeIdentityDocument() {
    identityDocument = null;
    notifyListeners();
  }

  void setNationality(String value) {
    nationality = value;
    notifyListeners();
  }

  void clearError(String key) {
    if (_errors.containsKey(key)) {
      _errors.remove(key);
      notifyListeners();
    }
  }

  /// The display name that maps to `public.users.name` — business name for
  /// business roles, full name otherwise.
  String get _effectiveName =>
      isBusinessRole ? businessName.trim() : fullName.trim();

  /// Build a [SignUpRequest] from the current form state for validation and
  /// local profile creation.
  SignUpRequest buildRequest() {
    String? finalAddress;
    if (isAddressSet) {
      final coords =
          '${_addressLat!.toStringAsFixed(5)}, ${_addressLng!.toStringAsFixed(5)}';
      finalAddress = preciseAddress.trim().isNotEmpty
          ? '$coords (${preciseAddress.trim()})'
          : coords;
    }

    return SignUpRequest(
      name: _effectiveName,
      phone: contactPhone.trim(),
      email: contactEmail.trim().isEmpty ? null : contactEmail.trim(),
      password: password,
      role: role,
      supplierType: role == UserRole.supplier ? supplierType : null,
      vehiclePlate: role == UserRole.driver && vehiclePlate.trim().isNotEmpty
          ? vehiclePlate.trim()
          : null,
      vehicleModel: vehicleModel.trim().isEmpty ? null : vehicleModel.trim(),
      vehicleColor: vehicleColor.trim().isEmpty ? null : vehicleColor.trim(),
      address: finalAddress,
      addressLat: _addressLat,
      addressLng: _addressLng,
      vehicleType: role == UserRole.driver ? vehicleType : null,
      hasChemicalPermit: role == UserRole.driver &&
          (vehicleRegistrationVm.extractedData?.hasChemicalPermit ?? false),
    );
  }

  bool _validate(AppLocalizations l10n) {
    _errors.clear();

    // 1) Delegate field-level rules to SignUpRequest so the UI matches the
    //    DB check constraints exactly.
    final dbErrors = buildRequest().validate();

    // Map SignUpRequest keys back to the UI's field keys so existing widgets
    // reading vm.errors['fullName'] / vm.errors['businessName'] keep working.
    if (dbErrors.containsKey('name')) {
      final key = isBusinessRole ? 'businessName' : 'fullName';
      _errors[key] = dbErrors['name']!;
    }
    if (dbErrors.containsKey('phone')) {
      _errors['contactPhone'] = dbErrors['phone']!;
    }
    if (dbErrors.containsKey('email')) {
      _errors['contactEmail'] = dbErrors['email']!;
    }
    if (dbErrors.containsKey('supplierType')) {
      _errors['supplierType'] = dbErrors['supplierType']!;
    }
    if (dbErrors.containsKey('password')) {
      _errors['password'] = dbErrors['password']!;
    }

    // 2) UI-only rules that are not enforced by the DB.
    if (isBusinessRole && ownerOrManagerName.trim().isEmpty) {
      _errors['ownerOrManagerName'] = l10n.signupErrorManagerName;
    }
    if (identityDocument == null) {
      _errors['identityDocument'] = l10n.signupErrorDocumentRequired;
    }

    // 3) Email is required so the user can sign back in later.
    if (contactEmail.trim().isEmpty) {
      _errors['contactEmail'] = l10n.signupErrorEmailRequired;
    }

    // 4) Password rules.
    if (password.isEmpty) {
      _errors['password'] = l10n.signupErrorPasswordRequired;
    }
    if (!_errors.containsKey('password') &&
        passwordConfirm.trim() != password) {
      _errors['passwordConfirm'] = l10n.signupErrorPasswordMismatch;
    }

    notifyListeners();
    return _errors.isEmpty;
  }

  Future<void> submit(AppLocalizations l10n) async {
    if (!_validate(l10n)) return;

    _isLoading = true;
    notifyListeners();

    final result = await _service.signUp(
      buildRequest(),
      profilePhoto: profilePhoto,
      identityDocument: identityDocument,
    );
    result.fold(
      onSuccess: (profile) {
        _createdProfile = profile;
        _submitted = true;
      },
      onFailure: (failure) {
        _errors['submit'] = failure.message;
        if (failure is ValidationFailure && failure.fieldErrors.isNotEmpty) {
          _errors.addAll(failure.fieldErrors);
        }
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void resetSubmitted() {
    _submitted = false;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    licenseVm.dispose();
    super.dispose();
  }

}
