import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/user_role.dart';
import '../../../../data/services/gemini_brand_profile_ai_service.dart';
import '../../../../data/services/mock_ai_service.dart';
import '../../../../data/services/user_signup_service.dart';
import '../../../../domain/failures/app_failure.dart';
import 'license_validation_viewmodel.dart';

enum AiAnalysisStatus { none, analyzing, verified, failed }

class RecyclingCoOnboardingViewModel extends ChangeNotifier {
  RecyclingCoOnboardingViewModel({UserSignUpService? service})
      : _service = service ?? UserSignUpService();

  final UserSignUpService _service;
  final ImagePicker _picker = ImagePicker();
  final LicenseValidationViewModel licenseVm = LicenseValidationViewModel();

  // ── AI Status ─────────────────────────────────────────────────────────────
  AiAnalysisStatus _aiStatus = AiAnalysisStatus.none;
  AiAnalysisStatus get aiStatus => _aiStatus;

  void setAiStatus(AiAnalysisStatus status) {
    _aiStatus = status;
    notifyListeners();
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  File? profilePhoto;
  String companyName = '';
  String ownerName = '';
  String email = '';
  String phone = '';
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

  // ── License document ──────────────────────────────────────────────────────

  File? licenseDocument;

  Future<void> pickLicense(ImageSource source) async {
    final xf = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1200);
    if (xf != null) {
      licenseDocument = File(xf.path);
      notifyListeners();
      await licenseVm.analyzeDocument(licenseDocument!, UserRole.recyclingCo);
    }
  }

  void clearLicense() {
    licenseDocument = null;
    licenseVm.reset();
    notifyListeners();
  }

  void removeLicense() => clearLicense();

  List<String> get aiCategories => licenseVm.suggestedCategories;

  /// License-scan categories + user-selected brand-profile categories, deduplicated.
  List<String> get combinedCategories {
    final seen = <String>{};
    return [
      ...licenseVm.suggestedCategories,
      ..._selectedCategories,
    ].where(seen.add).toList();
  }

  // ── AI — category suggestions ─────────────────────────────────────────────

  String tagline = '';
  bool isAiLoading = false;
  BrandProfile? brandProfile;

  List<String> _allCategories = [];
  final Set<String> _selectedCategories = {};

  List<String> get allCategories => List.unmodifiable(_allCategories);
  Set<String> get selectedCategories => Set.unmodifiable(_selectedCategories);

  Future<void> triggerAiSuggestions() async {
    if (isAiLoading) return;
    isAiLoading = true;
    _aiStatus = AiAnalysisStatus.analyzing;
    notifyListeners();

    try {
      final result = await GeminiBrandProfileAiService().generateBrandProfile(
        companyName: companyName,
        tagline: tagline,
      );

      brandProfile = result;
      _allCategories = List.from(result.suggestedCategories);
      _selectedCategories
        ..clear()
        ..addAll(_allCategories.take(4));

      _aiStatus = AiAnalysisStatus.verified;
    } catch (e) {
      _aiStatus = AiAnalysisStatus.failed;
    }

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
      errors['companyName'] = 'اسم الشركة مطلوب (حرفين على الأقل)';
    }
    if (ownerName.trim().length < 2) {
      errors['ownerName'] = 'اسم المدير مطلوب';
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
      role: UserRole.recyclingCo,
      address: finalAddress,
      addressLat: _addressLat,
      addressLng: _addressLng,
      categories: combinedCategories,
    );
  }

  Future<void> submit() async {
    if (!validate()) return;
    if (isSubmitting) return;
    isSubmitting = true;
    submitError = null;
    notifyListeners();

    final result = await _service.signUp(
      _buildRequest(),
      profilePhoto: profilePhoto,
      identityDocument: licenseDocument,
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

  static final _emailRegex = RegExp(r"^[\w.\-]+@[\w\-]+(\.[\w\-]+)+$");
  static final _hasLetter = RegExp(r'[A-Za-z]');
  static final _hasDigit = RegExp(r'\d');

  @override
  void dispose() {
    licenseVm.dispose();
    super.dispose();
  }
}
