import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_viewmodel.dart';

class SignUpViewModel extends ChangeNotifier {
  final UserRole role;
  final SupplierType supplierType;

  SignUpViewModel({required this.role, required this.supplierType});

  // --- Images ---
  File? profilePhoto;
  File? identityDocument;

  // --- Common fields ---
  String fullName = '';
  String contactPhone = '';
  String contactEmail = '';

  // --- Driver / Individual Supplier ---
  String nationality = 'أردني';

  // --- Business fields (Store Supplier / Recycling Co.) ---
  String businessName = '';
  String ownerOrManagerName = '';
  String coverageArea = '';

  // --- State ---
  bool _isLoading = false;
  bool _submitted = false;
  final Map<String, String> _errors = {};

  bool get isLoading => _isLoading;
  bool get submitted => _submitted;
  Map<String, String> get errors => Map.unmodifiable(_errors);

  bool get isBusinessRole =>
      role == UserRole.recyclingCo ||
      supplierType == SupplierType.storeBusiness;

  String get roleTitle {
    switch (role) {
      case UserRole.driver:
        return 'تسجيل سائق';
      case UserRole.supplier:
        return supplierType == SupplierType.storeBusiness
            ? 'تسجيل متجر / مطعم'
            : 'تسجيل مورد فردي';
      case UserRole.recyclingCo:
        return 'تسجيل شركة إعادة تدوير';
    }
  }

  String get photoLabel {
    if (role == UserRole.recyclingCo ||
        supplierType == SupplierType.storeBusiness) {
      return 'شعار الجهة';
    }
    return 'الصورة الشخصية';
  }

  String get idDocLabel {
    switch (role) {
      case UserRole.driver:
        return 'صورة الهوية الوطنية';
      case UserRole.supplier:
        return supplierType == SupplierType.storeBusiness
            ? 'صورة السجل التجاري'
            : 'صورة الهوية الوطنية';
      case UserRole.recyclingCo:
        return 'صورة الترخيص التجاري';
    }
  }

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
    }
  }

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

  bool _validate() {
    _errors.clear();

    if (isBusinessRole) {
      if (businessName.trim().isEmpty) {
        _errors['businessName'] = 'الرجاء إدخال اسم الجهة';
      }
      if (ownerOrManagerName.trim().isEmpty) {
        _errors['ownerOrManagerName'] = 'الرجاء إدخال اسم المسؤول';
      }
    } else {
      if (fullName.trim().isEmpty) {
        _errors['fullName'] = 'الرجاء إدخال الاسم الكامل';
      }
    }

    if (identityDocument == null) {
      _errors['identityDocument'] = 'الرجاء رفع صورة المستند المطلوب';
    }

    if (contactPhone.trim().isEmpty && contactEmail.trim().isEmpty) {
      _errors['contact'] = 'يجب إدخال رقم الهاتف أو البريد الإلكتروني';
    }

    notifyListeners();
    return _errors.isEmpty;
  }

  Future<void> submit() async {
    if (!_validate()) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    _isLoading = false;
    _submitted = true;
    notifyListeners();
  }

  void resetSubmitted() {
    _submitted = false;
  }
}
