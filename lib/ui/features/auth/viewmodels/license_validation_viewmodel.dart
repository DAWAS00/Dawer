import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../domain/services/i_ai_license_validation_service.dart';
import '../../../../data/models/user_role.dart';
import '../../../../data/services/gemini_ai_license_validation_service.dart';

enum LicenseValidationState { idle, analyzing, valid, invalid }

class LicenseValidationViewModel extends ChangeNotifier {
  final IAiLicenseValidationService _service;

  LicenseValidationViewModel({IAiLicenseValidationService? service})
      : _service = service ?? GeminiAiLicenseValidationService();

  LicenseValidationState _state = LicenseValidationState.idle;
  LicenseValidationState get state => _state;

  File? _licenseFile;
  File? get licenseFile => _licenseFile;

  List<String> _suggestedCategories = const [];
  List<String> get suggestedCategories => _suggestedCategories;

  ExtractedDocData? _extractedData;
  ExtractedDocData? get extractedData => _extractedData;

  String? _failReason;
  String? get failReason => _failReason;

  Future<void> analyzeDocument(File file, UserRole role) async {
    _licenseFile = file;
    _state = LicenseValidationState.analyzing;
    _failReason = null;
    _suggestedCategories = const [];
    _extractedData = null;
    notifyListeners();

    try {
      final result = await _service.validateLicense(file.path, role);
      if (result.isValid) {
        _suggestedCategories = result.suggestedCategories;
        _extractedData = result.docDetails;
        _state = LicenseValidationState.valid;
      } else {
        _failReason = result.statusMessage;
        _state = LicenseValidationState.invalid;
      }
    } catch (_) {
      _failReason = 'aiValidationStatusErrorUnknown';
      _state = LicenseValidationState.invalid;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _licenseFile = null;
    _state = LicenseValidationState.idle;
    _suggestedCategories = const [];
    _extractedData = null;
    _failReason = null;
    notifyListeners();
  }
}
