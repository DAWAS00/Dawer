import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../domain/repositories/i_auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  // ── State ────────────────────────────────────────────────────────────────

  String? _error;
  bool _isLoading = false;
  bool _codeSent = false;
  bool _verified = false;
  bool _resetDone = false;

  int _resendCountdown = 0;
  Timer? _resendTimer;

  // ── Getters ──────────────────────────────────────────────────────────────

  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get codeSent => _codeSent;
  bool get verified => _verified;
  bool get resetDone => _resetDone;
  int get resendCountdown => _resendCountdown;
  bool get canResend => _resendCountdown == 0 && !_isLoading;

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Sends a recovery OTP to [email] and starts the 60-second resend cooldown.
  Future<void> sendCode(String email) async {
    if (email.trim().isEmpty) {
      _error = 'forgotPasswordErrorEmptyEmail';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authRepository.requestPasswordReset(email.trim());
    result.fold(
      onSuccess: (_) {
        _codeSent = true;
        _startResendCooldown();
      },
      onFailure: (f) => _error = f.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Re-sends the OTP after the cooldown expires.
  Future<void> resendCode(String email) => sendCode(email);

  /// Verifies the 6-digit [code] for [email].
  Future<void> verifyCode(String email, String code) async {
    if (code.trim().length != 6) {
      _error = 'forgotPasswordErrorCodeLength';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authRepository.verifyResetCode(
      email.trim(),
      code.trim(),
    );
    result.fold(
      onSuccess: (_) => _verified = true,
      onFailure: (f) => _error = f.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  void resetVerified() {
    _verified = false;
  }

  /// Updates the authenticated user's password and signs out the recovery session.
  Future<void> resetPassword(String newPassword, String confirmPassword) async {
    if (newPassword.length < 8) {
      _error = 'resetPasswordErrorMinLength';
      notifyListeners();
      return;
    }
    if (newPassword != confirmPassword) {
      _error = 'resetPasswordErrorMismatch';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authRepository.updatePassword(newPassword);
    result.fold(
      onSuccess: (_) => _resetDone = true,
      onFailure: (f) => _error = f.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  void resetResetDone() {
    _resetDone = false;
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  void _startResendCooldown() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown <= 0) {
        t.cancel();
        _resendTimer = null;
      } else {
        _resendCountdown--;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
