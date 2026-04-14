import 'package:flutter/foundation.dart';

enum UserRole { driver, supplier, recyclingCo }

enum SupplierType { individual, storeBusiness }

enum LoginMethod { email, phone }

class LoginViewModel extends ChangeNotifier {
  LoginViewModel();

  // --- State ---
  UserRole _selectedRole = UserRole.driver;
  SupplierType _supplierType = SupplierType.individual;
  LoginMethod _loginMethod = LoginMethod.phone;
  String _currentInput = '';
  String? _error;
  bool _isLoading = false;
  bool _verificationSent = false;
  String _selectedCountryCode = 'JO';
  String _selectedDialCode = '+962';

  // --- Getters ---
  UserRole get selectedRole => _selectedRole;
  SupplierType get supplierType => _supplierType;
  LoginMethod get loginMethod => _loginMethod;
  String get currentInput => _currentInput;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get verificationSent => _verificationSent;
  bool get isEmailMethod => _loginMethod == LoginMethod.email;
  String get selectedCountryCode => _selectedCountryCode;
  String get selectedDialCode => _selectedDialCode;

  // --- Methods ---
  void selectRole(UserRole role) {
    _selectedRole = role;
    _error = null;
    notifyListeners();
  }

  void setSupplierType(SupplierType type) {
    _supplierType = type;
    notifyListeners();
  }

  void setLoginMethod(LoginMethod method) {
    _loginMethod = method;
    _currentInput = '';
    _error = null;
    notifyListeners();
  }

  void setEmail(String email) {
    _currentInput = email;
    _error = null;
  }

  void setPhoneNumber(String phone) {
    _currentInput = phone;
    _error = null;
  }

  void setCountry(String countryCode, String dialCode) {
    _selectedCountryCode = countryCode;
    _selectedDialCode = dialCode;
    notifyListeners();
  }

  Future<void> sendVerificationCode() async {
    if (_currentInput.trim().isEmpty) {
      _error = isEmailMethod
          ? 'الرجاء إدخال البريد الإلكتروني'
          : 'الرجاء إدخال رقم الهاتف';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    _isLoading = false;
    _verificationSent = true;
    notifyListeners();
  }

  void resetVerificationSent() {
    _verificationSent = false;
  }
}
