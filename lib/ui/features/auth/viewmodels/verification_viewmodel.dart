import 'package:flutter/foundation.dart';
import '../../../../domain/failures/app_failure.dart';
import '../../../../domain/repositories/i_auth_repository.dart';

class VerificationViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final String phoneNumber;

  VerificationViewModel({
    required IAuthRepository authRepository,
    required this.phoneNumber,
  }) : _authRepository = authRepository;

  String _otp = '';
  String? _error;
  bool _isLoading = false;
  bool _verified = false;
  bool _needsSignup = false;
  AuthSession? _session;

  String get otp => _otp;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get verified => _verified;
  bool get needsSignup => _needsSignup;
  AuthSession? get session => _session;

  void setOtp(String value) {
    _otp = value;
    _error = null;
    notifyListeners();
  }

  Future<void> verify() async {
    if (_otp.length < 6) {
      _error = 'أدخل رمز التحقق المكوّن من 6 أرقام';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final normalizedPhone = phoneNumber.startsWith('0') && phoneNumber.length == 10
        ? '+962${phoneNumber.substring(1)}'
        : phoneNumber;

    final result = await _authRepository.verifyOtp(normalizedPhone, _otp);
    result.fold(
      onSuccess: (session) {
        _session = session;
        _verified = true;
      },
      onFailure: (f) {
        if (f is NotFoundFailure && f.code == AuthErrorCodes.phoneNotRegistered) {
          _needsSignup = true;
        } else {
          _error = f.message;
        }
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> resendOtp() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final normalizedPhone = phoneNumber.startsWith('0') && phoneNumber.length == 10
        ? '+962${phoneNumber.substring(1)}'
        : phoneNumber;

    final result = await _authRepository.requestOtp(normalizedPhone);
    result.fold(
      onSuccess: (_) {
        _error = 'otpResentMessage';
      },
      onFailure: (f) => _error = f.message,
    );

    _isLoading = false;
    notifyListeners();
  }
}
