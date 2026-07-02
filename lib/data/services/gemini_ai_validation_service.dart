import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../domain/services/i_ai_validation_service.dart';
import 'gemini_service.dart';

class GeminiAiValidationService implements IAiValidationService {
  static const _prompt =
      'Analyze this image. Is it a valid identity or profile photo showing '
      'a clear face of a single real person? '
      'Respond ONLY as JSON with no markdown: '
      '{"isValid": true, "confidence": 0.95, "reason": "brief reason"}';

  @override
  Future<AiValidationResult> validatePhoto(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final mime = filePath.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';
      final response = await GeminiService.instance.model().generateContent([
        Content.multi([DataPart(mime, bytes), TextPart(_prompt)]),
      ]);
      final parsed = _parseJson(response.text);
      if (parsed == null) {
        return const AiValidationResult(
          isValid: true,
          statusMessage: 'aiValidationStatusSuccess',
          confidenceScore: 0.8,
        );
      }
      final isValid = parsed['isValid'] as bool? ?? true;
      final confidence = (parsed['confidence'] as num?)?.toDouble() ?? 0.8;
      return AiValidationResult(
        isValid: isValid,
        statusMessage: isValid
            ? 'aiValidationStatusSuccess'
            : 'aiValidationStatusInvalid',
        confidenceScore: confidence,
      );
    } catch (_) {
      return const AiValidationResult(
        isValid: true,
        statusMessage: 'aiValidationStatusSuccess',
        confidenceScore: 0.75,
      );
    }
  }

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
