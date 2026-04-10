import 'dart:async';
import 'package:flutter/material.dart';

class VerificationViewModel extends ChangeNotifier {
  final String destination;
  final bool isEmail;

  final List<String> _digits = List.filled(6, '');
  Timer? _timer;
  int _secondsRemaining = 120;
  bool _canResend = false;
  bool _isLoading = false;
  String? _error;
  bool _verified = false;

  VerificationViewModel({required this.destination, required this.isEmail}) {
    _startTimer();
  }

  List<String> get digits => List.unmodifiable(_digits);
  bool get canResend => _canResend;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get verified => _verified;
  bool get isComplete => _digits.every((d) => d.isNotEmpty);

  String get timerDisplay {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void setDigit(int index, String value) {
    if (index < 0 || index >= 6) return;
    _digits[index] = value;
    if (_error != null) _error = null;
    notifyListeners();
  }

  void _startTimer() {
    _secondsRemaining = 120;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _canResend = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void resendCode() {
    if (!_canResend) return;
    _digits.fillRange(0, 6, '');
    _startTimer();
    notifyListeners();
  }

  Future<void> verify() async {
    if (!isComplete) {
      _error = 'أكمل رمز التحقق من 6 أرقام';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    _isLoading = false;
    _verified = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
