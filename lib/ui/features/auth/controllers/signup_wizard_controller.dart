import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/services/user_signup_service.dart';
import 'package:dwaar/data/models/signup_request.dart';
import 'package:dwaar/domain/repositories/i_auth_repository.dart';
import 'package:dwaar/domain/services/i_ai_license_validation_service.dart';
import 'package:dwaar/ui/features/auth/viewmodels/license_validation_viewmodel.dart';

class SignupWizardController extends ChangeNotifier {
  final UserSignUpService _signupService;
  final LicenseValidationViewModel licenseVm;
  final IAuthRepository? authRepository;

  SignupWizardController({
    required UserSignUpService signupService,
    LicenseValidationViewModel? licenseViewModel,
    this.authRepository,
    String initialPhone = '',
  })  : _signupService = signupService,
        licenseVm = licenseViewModel ?? LicenseValidationViewModel(),
        phone = initialPhone;

  // ─── Wizard State ──────────────────────────────────────────────────────────
  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _submitted = false;
  bool get submitted => _submitted;

  String? _error;
  String? get error => _error;

  // ─── Step 1: Identity & Role ──────────────────────────────────────────────
  String fullName = '';
  UserRole role = UserRole.supplier;
  SupplierType supplierType = SupplierType.individual;
  File? profilePhoto;
  bool isPhotoVerified = false;

  // ─── Step 2: AI Verification ──────────────────────────────────────────────
  bool isScanning = false;
  double scanningProgress = 0.0;
  ExtractedDocData? extractedData;

  // ─── Step 3: Role-specific Details ────────────────────────────────────────
  String vehiclePlate = '';
  String businessName = '';
  String ownerManagerName = '';
  String coverageArea = '';
  String primaryCategory = '';

  // ─── Step 4: Credentials ──────────────────────────────────────────────────
  String phone;
  String email = '';

  // ─── Navigation ────────────────────────────────────────────────────────────

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void updateRole(UserRole newRole, [SupplierType? newType]) {
    role = newRole;
    if (newType != null) supplierType = newType;
    notifyListeners();
  }

  Future<void> pickProfilePhoto(File file) async {
    profilePhoto = file;
    isPhotoVerified = false;
    notifyListeners();
    
    // Simulate instant AI "Liveness" check
    await Future.delayed(const Duration(seconds: 1));
    isPhotoVerified = true;
    notifyListeners();
  }

  Future<void> startScan(File file) async {
    isScanning = true;
    scanningProgress = 0.0;
    notifyListeners();

    await licenseVm.analyzeDocument(file, role);
    
    if (licenseVm.state == LicenseValidationState.valid) {
      extractedData = licenseVm.extractedData;
    }
    
    isScanning = false;
    notifyListeners();
  }

  // ─── Submission ────────────────────────────────────────────────────────────

  SignUpRequest buildRequest() {
    return SignUpRequest(
      name: (role == UserRole.recyclingCo || supplierType == SupplierType.storeBusiness)
          ? businessName
          : fullName,
      phone: phone,
      email: email.isEmpty ? null : email,
      password: null,
      role: role,
      supplierType: role == UserRole.supplier ? supplierType : null,
      vehiclePlate: role == UserRole.driver ? vehiclePlate : null,
      categories: licenseVm.suggestedCategories,
    );
  }

  Future<void> submit() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (authRepository != null) {
      final result = await authRepository!.signUp(buildRequest());
      result.fold(
        onSuccess: (_) => _submitted = true,
        onFailure: (f) => _error = f.message,
      );
    } else {
      final result = await _signupService.signUp(
        buildRequest(),
        profilePhoto: profilePhoto,
        identityDocument: licenseVm.licenseFile,
      );

      result.fold(
        onSuccess: (_) => _submitted = true,
        onFailure: (f) => _error = f.message,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    licenseVm.dispose();
    super.dispose();
  }
}
