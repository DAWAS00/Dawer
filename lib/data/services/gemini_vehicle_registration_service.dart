import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/config/ai_config.dart';
import '../../data/models/order/order.dart' show VehicleType, VehicleTypeLabel;
import '../../domain/services/i_ai_vehicle_registration_service.dart';

class GeminiVehicleRegistrationService implements IAiVehicleRegistrationService {
  final GenerativeModel _model;

  GeminiVehicleRegistrationService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: AiConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 0.1,
          ),
        );

  GeminiVehicleRegistrationService.withModel(this._model);

  @override
  Future<VehicleRegistrationResult> extractVehicleData(String filePath) async {
    if (!AiConfig.hasGeminiKey) {
      throw Exception('Gemini API key not configured');
    }

    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final content = [
      Content.multi([
        TextPart(_prompt),
        DataPart(_mimeType(file), bytes),
      ]),
    ];

    return _callWithRetry(content);
  }

  Future<VehicleRegistrationResult> _callWithRetry(
    List<Content> content, {
    int maxAttempts = 2,
  }) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _model.generateContent(content);
        var text = response.text;
        if (text == null || text.isEmpty) {
          throw const FormatException('Empty response from Gemini');
        }

        // Handle potential markdown wrapper
        if (text.contains('```')) {
          final lines = text.split('\n');
          text = lines
              .where((l) => !l.trim().startsWith('```'))
              .join('\n')
              .trim();
        }

        final json = jsonDecode(text);
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Gemini response was not a JSON object');
        }
        return _parseResult(json);
      } on Exception catch (e) {
        debugPrint('[GeminiVehicleService] Attempt $attempt failed: $e');
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }
    return VehicleRegistrationResult.failure(
      'حدث خطأ أثناء التحليل. يرجى المحاولة مرة أخرى.',
    );
  }


  VehicleRegistrationResult _parseResult(Map<String, dynamic> json) {
    if (json['isVehicleRegistration'] == false) {
      return const VehicleRegistrationResult.failure(
        'هذه الصورة لا تبدو وثيقة تسجيل مركبة. يرجى رفع صورة واضحة للاستمارة.',
      );
    }

    final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.0;
    if (confidence < 0.5) {
      return const VehicleRegistrationResult.failure(
        'تعذّر قراءة الوثيقة بوضوح. يرجى التأكد من الإضاءة ووضوح الصورة.',
      );
    }

    final vehicleClass = json['vehicleClass']?.toString() ?? '';
    final vehicleType = _mapVehicleType(vehicleClass);

    DateTime? expiry;
    final expiryRaw = json['registrationExpiry']?.toString();
    if (expiryRaw != null) expiry = DateTime.tryParse(expiryRaw);

    return VehicleRegistrationResult.success(ExtractedVehicleData(
      vehicleType: vehicleType,
      vehicleClass: vehicleClass.isNotEmpty ? vehicleClass : vehicleType.label,
      make: _nonEmpty(json['make']?.toString()),
      model: _nonEmpty(json['model']?.toString()),
      color: _nonEmpty(json['color']?.toString()),
      plateNumber: _nonEmpty(json['plateNumber']?.toString()),
      registrationExpiry: expiry,
      confidenceScore: confidence,
      hasChemicalPermit: json['hasChemicalPermit'] == true,
    ));
  }

  static VehicleType _mapVehicleType(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('دراجة') || s.contains('motorcycle') || s.contains('motorbike')) {
      return VehicleType.motorcycle;
    }
    if (s.contains('شاحنة ثقيلة') || s.contains('heavy') ||
        s.contains('مقطورة') || s.contains('semi')) {
      return VehicleType.heavyTruck;
    }
    if (s.contains('شاحنة') || s.contains('truck') || s.contains('lorry')) {
      return VehicleType.truck;
    }
    if (s.contains('فان') || s.contains('ونيت') || s.contains('van') ||
        s.contains('minibus') || s.contains('ميكروباص')) {
      return VehicleType.van;
    }
    if (s.contains('بيك') || s.contains('pickup') || s.contains('pick-up') ||
        s.contains('pick up')) {
      return VehicleType.pickup;
    }
    return VehicleType.car;
  }

  static String? _nonEmpty(String? s) =>
      (s == null || s.trim().isEmpty || s == 'null') ? null : s.trim();

  static String _mimeType(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }

  static const _prompt = r'''
You are a vehicle registration document analyzer for the Dawer recycling app in Jordan.
Analyze this image and extract data from a Jordanian vehicle registration document
(استمارة المركبة / رخصة السير).

Return ONLY a strict JSON object — no markdown, no explanation:
{
  "isVehicleRegistration": true,
  "vehicleClass": "exact Arabic text for vehicle type from document (e.g. بيك آب, سيارة خاصة, شاحنة, فان / ونيت, دراجة نارية, شاحنة ثقيلة)",
  "make": "manufacturer in Arabic or English (e.g. تويوتا) or null",
  "model": "model name (e.g. هايلوكس) or null",
  "color": "color in Arabic (e.g. أبيض) or null",
  "plateNumber": "plate number as string (e.g. 11 - 12345) or null",
  "registrationExpiry": "YYYY-MM-DD or null if not visible",
  "hasChemicalPermit": false,
  "confidence": 0.95
}

RULES:
- Set isVehicleRegistration=false if the image is NOT a vehicle registration document.
- Set confidence below 0.5 if blurry, partial, or unreadable.
- vehicleClass must be the raw Arabic text from the document — do not translate.
- Set hasChemicalPermit=true only if you see explicit hazmat/chemical transport endorsement.
- Use null for any field not clearly visible — never guess.
''';
}
