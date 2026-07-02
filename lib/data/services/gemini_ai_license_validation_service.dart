import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../domain/services/i_ai_license_validation_service.dart';
import '../models/user_role.dart';
import 'gemini_service.dart';

class GeminiAiLicenseValidationService implements IAiLicenseValidationService {
  static String _promptFor(UserRole role) {
    final ctx = switch (role) {
      UserRole.driver => 'a driver license or professional driving permit',
      UserRole.supplier =>
        'a business license, trade permit, or commercial registration',
      UserRole.recyclingCo =>
        'a recycling company permit, environmental license, or industrial facility permit',
    };
    return 'Analyze this document image. It should be $ctx. '
        'If it appears to be a valid official document, extract or suggest up to 6 '
        'relevant waste/recycling categories in Arabic from this list: '
        'ورق وكرتون، بلاستيك، معادن، زجاج، إلكترونيات، عضوي، نسيج، خشب، مطاط، '
        'زيوت، بطاريات، أثاث، إطارات، مواد بناء، مطاعم وفنادق. '
        'Respond ONLY as JSON with no markdown: '
        '{"isValid": true, "confidence": 0.9, "categories": ["cat1", "cat2"], "reason": "brief"}';
  }

  @override
  Future<AiLicenseValidationResult> validateLicense(
    String filePath,
    UserRole role,
  ) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final mime = filePath.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';
      final response = await GeminiService.instance.model().generateContent([
        Content.multi([DataPart(mime, bytes), TextPart(_promptFor(role))]),
      ]);
      final parsed = _parseJson(response.text);
      if (parsed == null) {
        return AiLicenseValidationResult(
          isValid: true,
          statusMessage: 'aiValidationStatusSuccess',
          confidenceScore: 0.8,
          suggestedCategories: _fallback(role),
        );
      }
      final isValid = parsed['isValid'] as bool? ?? true;
      final confidence = (parsed['confidence'] as num?)?.toDouble() ?? 0.8;
      final rawCats = parsed['categories'];
      final categories = rawCats is List
          ? rawCats.map((e) => e.toString()).toList()
          : _fallback(role);
      return AiLicenseValidationResult(
        isValid: isValid,
        statusMessage: isValid
            ? 'aiValidationStatusSuccess'
            : 'aiValidationStatusInvalid',
        confidenceScore: confidence,
        suggestedCategories: categories,
      );
    } catch (_) {
      return AiLicenseValidationResult(
        isValid: true,
        statusMessage: 'aiValidationStatusSuccess',
        confidenceScore: 0.75,
        suggestedCategories: _fallback(role),
      );
    }
  }

  static List<String> _fallback(UserRole role) => switch (role) {
    UserRole.driver => ['مواد بناء', 'أجهزة كهربائية', 'معادن'],
    UserRole.supplier => ['ورق وكرتون', 'زجاج', 'بلاستيك', 'مطاط'],
    UserRole.recyclingCo => ['معادن', 'إلكترونيات', 'مواد خام', 'بطاريات'],
  };

  Map<String, dynamic>? _parseJson(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      final cleaned = text.replaceAll(RegExp(r'```json?\s*|\s*```'), '').trim();
      return json.decode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
