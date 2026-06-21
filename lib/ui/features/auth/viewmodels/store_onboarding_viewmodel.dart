import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/user_role.dart';
import '../../../../data/services/mock_ai_service.dart';
import '../../../../data/services/user_signup_service.dart';
import 'package:dwaar/data/models/signup_request.dart';
import '../../../../domain/failures/app_failure.dart';
import 'license_validation_viewmodel.dart';

class StoreOnboardingViewModel extends ChangeNotifier {
  StoreOnboardingViewModel({required UserSignUpService service})
      : _service = service;

  final UserSignUpService _service;
  final ImagePicker _picker = ImagePicker();
  final LicenseValidationViewModel licenseVm = LicenseValidationViewModel();

  // ── Profile ───────────────────────────────────────────────────────────────

  File? profilePhoto;
  String companyName = '';
  String ownerName = '';
  String phone = '';
  String email = '';
  String password = '';
  String passwordConfirm = '';

  Future<void> pickProfilePhoto(ImageSource source) async {
    final xf = await _picker.pickImage(
        source: source, imageQuality: 80, maxWidth: 800);
    if (xf != null) {
      profilePhoto = File(xf.path);
      notifyListeners();
    }
  }

  void removeProfilePhoto() {
    profilePhoto = null;
    notifyListeners();
  }

  // ── Address / Location ────────────────────────────────────────────────────

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

  // ── Business license ──────────────────────────────────────────────────────

  File? identityDocument;

  Future<void> pickIdentityDocument(ImageSource source) async {
    final xf = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1200);
    if (xf != null) {
      identityDocument = File(xf.path);
      notifyListeners();
      await licenseVm.analyzeDocument(identityDocument!, UserRole.supplier);
    }
  }

  void clearIdentityDocument() {
    identityDocument = null;
    licenseVm.reset();
    notifyListeners();
  }

  void removeIdentityDocument() => clearIdentityDocument();

  List<String> get aiCategories => licenseVm.suggestedCategories;

  // ── AI — category suggestions ─────────────────────────────────────────────

  String tagline = '';
  bool isAiLoading = false;
  BrandProfile? brandProfile;

  List<String> _allCategories = [];
  final Set<String> _selectedCategories = {};

  List<String> get allCategories => List.unmodifiable(_allCategories);
  Set<String> get selectedCategories => Set.unmodifiable(_selectedCategories);

  /// TODO: Replace MockAiService with real AI API — see mock_ai_service.dart
  Future<void> triggerAiSuggestions() async {
    if (isAiLoading) return;
    isAiLoading = true;
    notifyListeners();

    final result = await MockAiService.generateBrandProfile(
      companyName: companyName,
      tagline: tagline,
    );

    brandProfile = result;
    _allCategories = List.from(result.suggestedCategories);
    _selectedCategories
      ..clear()
      ..addAll(_allCategories.take(4));

    isAiLoading = false;
    notifyListeners();
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  final Map<String, String> errors = {};

  bool validate() {
    errors.clear();
    if (companyName.trim().length < 2) {
      errors['companyName'] = 'اسم المتجر / الشركة مطلوب';
    }
    if (ownerName.trim().length < 2) {
      errors['ownerName'] = 'اسم المالك / المدير مطلوب';
    }
    if (!_emailRegex.hasMatch(email.trim())) {
      errors['email'] = 'البريد الإلكتروني غير صحيح';
    }
    if (password.length < 8) {
      errors['password'] = 'كلمة المرور 8 أحرف على الأقل';
    } else if (!_hasLetter.hasMatch(password) || !_hasDigit.hasMatch(password)) {
      errors['password'] = 'يجب أن تحتوي على حرف ورقم';
    }
    if (passwordConfirm != password) {
      errors['passwordConfirm'] = 'كلمتا المرور غير متطابقتين';
    }
    notifyListeners();
    return errors.isEmpty;
  }

  void clearError(String key) {
    errors.remove(key);
    notifyListeners();
  }

  // ── Submission ────────────────────────────────────────────────────────────

  bool isSubmitting = false;
  bool submitted = false;
  Map<String, dynamic>? createdProfile;
  String? submitError;

  SignUpRequest _buildRequest() {
    String? finalAddress;
    if (isAddressSet) {
      final coords = '${_addressLat!.toStringAsFixed(5)}, ${_addressLng!.toStringAsFixed(5)}';
      finalAddress = preciseAddress.trim().isNotEmpty
          ? '$coords (${preciseAddress.trim()})'
          : coords;
    }
    return SignUpRequest(
      name: companyName.trim(),
      phone: phone.trim(),
      email: email.trim().isEmpty ? null : email.trim(),
      password: password,
      role: UserRole.supplier,
      supplierType: SupplierType.storeBusiness,
      address: finalAddress,
      addressLat: _addressLat,
      addressLng: _addressLng,
    );
  }

  Future<void> submit() async {
    if (!validate()) return;
    if (isSubmitting) return;
    isSubmitting = true;
    submitError = null;
    notifyListeners();

    // TODO: persist selectedCategories + tagline to 'store_profiles' table
    final result = await _service.signUp(
      _buildRequest(),
      profilePhoto: profilePhoto,
      identityDocument: identityDocument,
    );

    result.fold(
      onSuccess: (profile) {
        createdProfile = profile;
        submitted = true;
      },
      onFailure: (failure) {
        submitError = failure.message;
        if (failure is ValidationFailure && failure.fieldErrors.isNotEmpty) {
          submitError = failure.fieldErrors.values.first;
        }
      },
    );

    isSubmitting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    licenseVm.dispose();
    super.dispose();
  }

  static final _emailRegex = RegExp(r"^[\w.\-]+@[\w\-]+(\.[\w\-]+)+$");
  static final _hasLetter = RegExp(r'[A-Za-z]');
  static final _hasDigit = RegExp(r'\d');
}
