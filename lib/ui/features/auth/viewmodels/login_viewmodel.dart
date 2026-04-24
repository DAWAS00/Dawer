import 'package:flutter/foundation.dart';

// Re-export data-layer enums so existing imports of this file keep working.
export '../../../../data/models/user_role.dart' show UserRole, SupplierType;

import '../../../../data/models/user_role.dart';
import '../../../../data/services/user_signup_service.dart';

enum LoginMethod { email, phone }

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({UserSignUpService? service})
      : _service = service ?? UserSignUpService();

  final UserSignUpService _service;

  // --- State ---
  UserRole _selectedRole = UserRole.driver;
  SupplierType _supplierType = SupplierType.individual;
  LoginMethod _loginMethod = LoginMethod.phone;
  String _currentInput = '';
  String _password = '';
  String? _error;
  bool _isLoading = false;
  bool _signedIn = false;
  Map<String, dynamic>? _profile;
  String _selectedCountryCode = 'JO';
  String _selectedDialCode = '+962';

  // --- Getters ---
  UserRole get selectedRole => _selectedRole;
  SupplierType get supplierType => _supplierType;
  LoginMethod get loginMethod => _loginMethod;
  String get currentInput => _currentInput;
  String get password => _password;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get signedIn => _signedIn;
  Map<String, dynamic>? get profile => _profile;
  bool get isEmailMethod => _loginMethod == LoginMethod.email;
  String get selectedCountryCode => _selectedCountryCode;
  String get selectedDialCode => _selectedDialCode;

  String get profileName =>
      (_profile?['name'] as String?) ?? _currentInput;

  // --- Mutators ---
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

  void setPassword(String value) {
    _password = value;
    _error = null;
  }

  void setCountry(String countryCode, String dialCode) {
    _selectedCountryCode = countryCode;
    _selectedDialCode = dialCode;
    notifyListeners();
  }

  /// Attempts password-based sign-in against [LocalAuthService]. Sets
  /// [signedIn] to true on success so the View can navigate to [HomeRouter].
  Future<void> signIn() async {
    if (_currentInput.trim().isEmpty) {
      _error = isEmailMethod
          ? 'الرجاء إدخال البريد الإلكتروني'
          : 'الرجاء إدخال رقم الهاتف';
      notifyListeners();
      return;
    }
    if (_password.isEmpty) {
      _error = 'الرجاء إدخال كلمة المرور';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final identifier = _currentInput.trim();
      _profile = await _service.signIn(
        identifier: identifier,
        password: _password,
      );
      // Reflect the actual role stored on the account so the home router
      // routes to the correct tab set (not the one picked in the UI).
      final storedRole = _profile?['role'] as String?;
      if (storedRole != null) {
        for (final r in UserRole.values) {
          if (r.dbValue == storedRole) {
            _selectedRole = r;
            break;
          }
        }
      }
      final storedSupplier = _profile?['supplier_type'] as String?;
      if (storedSupplier != null) {
        for (final s in SupplierType.values) {
          if (s.dbValue == storedSupplier) {
            _supplierType = s;
            break;
          }
        }
      }
      _signedIn = true;
    } on SignUpException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'تعذّر تسجيل الدخول، حاول مجدداً';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetSignedIn() {
    _signedIn = false;
  }
}
