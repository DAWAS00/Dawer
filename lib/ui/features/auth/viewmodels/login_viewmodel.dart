import 'package:flutter/foundation.dart';

// Re-export data-layer enums so existing imports of this file keep working.
export '../../../../data/models/user_role.dart' show UserRole, SupplierType;

import '../../../../data/models/user_role.dart';
import '../../../../domain/repositories/i_auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  // --- State ---
  UserRole _selectedRole = UserRole.driver;
  SupplierType _supplierType = SupplierType.individual;
  String _email = '';
  String _password = '';
  String _phone = '';
  String? _error;
  bool _isLoading = false;
  bool _signedIn = false;
  bool _otpSent = false;
  bool _passwordResetRequested = false;
  AuthSession? _session;

  // --- Getters ---
  UserRole get selectedRole => _selectedRole;
  SupplierType get supplierType => _supplierType;
  String get email => _email;
  String get password => _password;
  String get phone => _phone;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get signedIn => _signedIn;
  bool get otpSent => _otpSent;
  bool get passwordResetRequested => _passwordResetRequested;
  AuthSession? get session => _session;

  String get profileName => _session?.userName ?? (_email.isNotEmpty ? _email : _phone);

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

  void setEmail(String email) {
    _email = email;
    _error = null;
  }

  void setPassword(String value) {
    _password = value;
    _error = null;
  }

  void setPhone(String value) {
    _phone = value;
    _error = null;
  }

  /// Requests an OTP for the provided phone number.
  Future<void> requestOtp(String phone) async {
    _phone = phone.trim();
    if (_phone.isEmpty) {
      _error = 'الرجاء إدخال رقم الهاتف';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authRepository.requestOtp(_phone);
    result.fold(
      onSuccess: (_) {
        _otpSent = true;
      },
      onFailure: (f) => _error = f.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  void resetOtpSent() {
    _otpSent = false;
  }

  void resetPasswordResetRequested() {
    _passwordResetRequested = false;
  }

  /// Sends a 6-digit recovery OTP to the current [_email].
  Future<void> requestPasswordReset() async {
    if (_email.trim().isEmpty) {
      _error = 'forgotPasswordErrorEmptyEmail';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authRepository.requestPasswordReset(_email.trim());
    result.fold(
      onSuccess: (_) => _passwordResetRequested = true,
      onFailure: (f) => _error = f.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Signs the user in with email + password.
  Future<void> signIn() async {
    if (_email.trim().isEmpty) {
      _error = 'الرجاء إدخال البريد الإلكتروني';
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

    final result = await _authRepository.signInWithEmail(
      _email.trim(),
      _password,
    );
    result.fold(
      onSuccess: (session) {
        _session = session;
        _selectedRole = session.role;
        if (session.supplierType != null) {
          _supplierType = session.supplierType!;
        }
        _signedIn = true;
      },
      onFailure: (f) => _error = f.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  void resetSignedIn() {
    _signedIn = false;
  }
}
