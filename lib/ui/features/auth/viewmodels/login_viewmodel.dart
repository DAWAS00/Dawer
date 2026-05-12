import 'package:flutter/foundation.dart';

// Re-export data-layer enums so existing imports of this file keep working.
export '../../../../data/models/user_role.dart' show UserRole, SupplierType;

import '../../../../core/state/view_state.dart';
import '../../../../data/models/user_role.dart';
import '../../../../domain/repositories/i_auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  // ── Action state ──────────────────────────────────────────────────────────
  ViewState<AuthSession> _state = const Idle();
  ViewState<AuthSession> get state => _state;

  // Backward-compatible helpers so existing views keep compiling unchanged.
  bool get isLoading => _state is Loading;
  String? get error => switch (_state) {
        Failed(:final failure) => failure.message,
        _ => null,
      };

  // ── Navigation signals ────────────────────────────────────────────────────
  bool _signedIn = false;
  bool _otpSent = false;
  bool _passwordResetRequested = false;
  AuthSession? _session;

  bool get signedIn => _signedIn;
  bool get otpSent => _otpSent;
  bool get passwordResetRequested => _passwordResetRequested;
  AuthSession? get session => _session;

  // ── Input state ───────────────────────────────────────────────────────────
  UserRole _selectedRole = UserRole.driver;
  SupplierType? _supplierType;
  String _email = '';
  String _password = '';
  String _phone = '';

  UserRole get selectedRole => _selectedRole;
  SupplierType? get supplierType => _supplierType;
  String get email => _email;
  String get password => _password;
  String get phone => _phone;

  String get profileName =>
      _session?.userName ?? (_email.isNotEmpty ? _email : _phone);

  // ── Mutators ──────────────────────────────────────────────────────────────

  void selectRole(UserRole role) {
    _selectedRole = role;
    _supplierType = null;
    _state = const Idle();
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

  void setEmail(String email) {
    _email = email;
    _state = const Idle();
  }

  void setPassword(String value) {
    _password = value;
    _state = const Idle();
  }

  void setPhone(String value) {
    _phone = value;
    _state = const Idle();
  }

  void resetSignedIn() {
    _signedIn = false;
  }

  void resetOtpSent() {
    _otpSent = false;
  }

  void resetPasswordResetRequested() {
    _passwordResetRequested = false;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Requests an email OTP for the provided phone number.
  Future<void> requestOtp(String phone) async {
    _phone = phone.trim();
    if (_phone.isEmpty) {
      _state = const Failed(ValidationFailure(message: 'الرجاء إدخال رقم الهاتف'));
      notifyListeners();
      return;
    }

    _state = const Loading();
    notifyListeners();

    final result = await _authRepository.requestOtp(_phone);
    _state = result.fold(
      onSuccess: (_) {
        _otpSent = true;
        return const Idle();
      },
      onFailure: Failed.new,
    );
    notifyListeners();
  }

  /// Sends a 6-digit recovery OTP to the current [_email].
  Future<void> requestPasswordReset() async {
    if (_email.trim().isEmpty) {
      _state = const Failed(
        ValidationFailure(message: 'الرجاء إدخال البريد الإلكتروني'),
      );
      notifyListeners();
      return;
    }

    _state = const Loading();
    notifyListeners();

    final result = await _authRepository.requestPasswordReset(_email.trim());
    _state = result.fold(
      onSuccess: (_) {
        _passwordResetRequested = true;
        return const Idle();
      },
      onFailure: Failed.new,
    );
    notifyListeners();
  }

  /// Signs the user in with email + password.
  Future<void> signIn() async {
    if (_email.trim().isEmpty) {
      _state = const Failed(
        ValidationFailure(message: 'الرجاء إدخال البريد الإلكتروني'),
      );
      notifyListeners();
      return;
    }
    if (_password.isEmpty) {
      _state = const Failed(
        ValidationFailure(message: 'الرجاء إدخال كلمة المرور'),
      );
      notifyListeners();
      return;
    }

    _state = const Loading();
    notifyListeners();

    final result = await _authRepository.signInWithEmail(
      _email.trim(),
      _password,
    );

    _state = result.fold(
      onSuccess: (authSession) {
        _session = authSession;
        _selectedRole = authSession.role;
        if (authSession.supplierType != null) {
          _supplierType = authSession.supplierType!;
        }
        _signedIn = true;
        return Loaded(authSession);
      },
      onFailure: Failed.new,
    );
    notifyListeners();
  }
}
