import 'package:flutter/foundation.dart';

// Re-export data-layer enums so existing imports of this file keep working.
export '../../../../data/models/user_role.dart' show UserRole, SupplierType;

import '../../../../data/models/user_role.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../data/repositories/mock_auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  // --- State ---
  UserRole _selectedRole = UserRole.driver;
  SupplierType? _supplierType;
  String _phone = '';
  String? _error;
  bool _isLoading = false;
  bool _otpSent = false;
  AuthSession? _session;
  AuthSession? _quickSession;

  // --- Getters ---
  UserRole get selectedRole => _selectedRole;
  SupplierType? get supplierType => _supplierType;
  String get phone => _phone;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get otpSent => _otpSent;
  AuthSession? get session => _session;
  AuthSession? get quickSession => _quickSession;

  // --- Mutators ---
  void selectRole(UserRole role) {
    _selectedRole = role;
    _supplierType = null; // reset so portal cards return to un-chosen state
    _error = null;
    notifyListeners();
  }

  void setSupplierType(SupplierType type) {
    _supplierType = type;
    notifyListeners();
  }

  void clearSupplierType() {
    _supplierType = null;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    _error = null;
  }

  /// Requests an OTP for the provided phone number.
  Future<void> requestOtp(String phone) async {
    _phone = phone.trim();
    if (_phone.isEmpty) {
      _error = 'رقم الهاتف مطلوب';
      notifyListeners();
      return;
    }
    if (_phone.length != 10 || !RegExp(r'^07\d{8}$').hasMatch(_phone)) {
      _error = 'رقم الهاتف يجب أن يتكون من 10 أرقام ويبدأ بـ 07 (مثال: 07XXXXXXXX)';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    // Normalize for backend/firebase
    final normalizedPhone = '+962${_phone.substring(1)}';

    // If using mock repo, sync the UI selection so it knows what to generate
    if (_authRepository case final MockAuthRepository repo) {
      repo.updateTargetRole(
        _selectedRole,
        _supplierType,
      );
    }

    final result = await _authRepository.requestOtp(normalizedPhone);
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

  void quickLogin(AuthSession session) {
    if (_authRepository case final MockAuthRepository repo) {
      repo.setActiveSession(session);
    }
    _quickSession = session;
    notifyListeners();
  }

  void resetQuickSession() {
    _quickSession = null;
  }
}
