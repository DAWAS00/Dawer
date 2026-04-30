import 'package:flutter/foundation.dart';
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
  AuthSession? _session;

  String get otp => _otp;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get verified => _verified;
  AuthSession? get session => _session;

  void setOtp(String value) {
    _otp = value;
    _error = null;
    notifyListeners();
  }

  Future<void> verify() async {
    if (_otp.length < 6) {
      _error = 'الرجاء إدخال رمز التحقق كاملاً';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authRepository.verifyOtp(phoneNumber, _otp);
    result.fold(
      onSuccess: (session) {
        _session = session;
        _verified = true;
      },
      onFailure: (f) => _error = f.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> resendOtp() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authRepository.requestOtp(phoneNumber);
    result.fold(
      onSuccess: (_) {
        _error = 'تم إعادة إرسال الرمز';
      },
      onFailure: (f) => _error = f.message,
    );

    _isLoading = false;
    notifyListeners();
  }
}
