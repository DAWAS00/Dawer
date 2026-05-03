import 'package:flutter/foundation.dart';
import '../../../../domain/services/i_ai_validation_service.dart';

enum ValidationState { idle, analyzing, success, error }

class AiPhotoValidationViewModel extends ChangeNotifier {
  final IAiValidationService _aiService;
  
  ValidationState _state = ValidationState.idle;
  ValidationState get state => _state;

  String? _photoPath;
  String? get photoPath => _photoPath;

  String? _errorMessageKey;
  String? get errorMessageKey => _errorMessageKey;

  AiPhotoValidationViewModel({required IAiValidationService aiService}) : _aiService = aiService;

  Future<void> pickAndValidatePhoto(String path) async {
    _photoPath = path;
    _state = ValidationState.analyzing;
    _errorMessageKey = null;
    notifyListeners();

    try {
      final result = await _aiService.validatePhoto(path);
      if (result.isValid) {
        _state = ValidationState.success;
      } else {
        _state = ValidationState.error;
        _errorMessageKey = result.statusMessage;
      }
    } catch (e) {
      _state = ValidationState.error;
      _errorMessageKey = 'aiValidationStatusErrorUnknown';
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _photoPath = null;
    _state = ValidationState.idle;
    _errorMessageKey = null;
    notifyListeners();
  }
}
