import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../core/config/ai_config.dart';
import '../../../../data/services/gemini_vehicle_registration_service.dart';
import '../../../../data/services/mock_ai_vehicle_registration_service.dart';
import '../../../../domain/services/i_ai_vehicle_registration_service.dart';
import '../../auth/viewmodels/license_validation_viewmodel.dart'
    show LicenseValidationState;

export '../../auth/viewmodels/license_validation_viewmodel.dart'
    show LicenseValidationState;

class VehicleRegistrationViewModel extends ChangeNotifier {
  final IAiVehicleRegistrationService _service;

  VehicleRegistrationViewModel({IAiVehicleRegistrationService? service})
      : _service = service ??
            (AiConfig.hasGeminiKey
                ? GeminiVehicleRegistrationService()
                : MockAiVehicleRegistrationService());

  LicenseValidationState _state = LicenseValidationState.idle;
  LicenseValidationState get state => _state;

  File? _file;
  File? get registrationFile => _file;

  ExtractedVehicleData? _data;
  ExtractedVehicleData? get extractedData => _data;

  String? _failReason;
  String? get failReason => _failReason;

  Future<void> analyzeDocument(File file) async {
    _file = file;
    _data = null;
    _failReason = null;
    _state = LicenseValidationState.analyzing;
    notifyListeners();

    try {
      final result = await _service.extractVehicleData(file.path);
      if (result.isValid) {
        _data = result.data;
        _state = LicenseValidationState.valid;
      } else {
        _failReason = result.failReason;
        _state = LicenseValidationState.invalid;
      }
    } catch (_) {
      _failReason = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
      _state = LicenseValidationState.invalid;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _file = null;
    _data = null;
    _failReason = null;
    _state = LicenseValidationState.idle;
    notifyListeners();
  }
}
