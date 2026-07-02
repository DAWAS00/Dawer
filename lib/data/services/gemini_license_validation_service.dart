import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/config/ai_config.dart';
import '../../data/models/user_role.dart';
import '../../domain/services/i_ai_license_validation_service.dart';

class GeminiLicenseValidationService implements IAiLicenseValidationService {
  final GenerativeModel _model;

  GeminiLicenseValidationService()
      : _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: AiConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 0.1,
          ),
        );

  GeminiLicenseValidationService.withModel(this._model);

  @override
  Future<AiLicenseValidationResult> validateLicense(
      String filePath, UserRole role) async {
    if (!AiConfig.hasGeminiKey) {
      throw Exception('Gemini API key not configured');
    }

    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final content = [
      Content.multi([
        TextPart(_prompt(role)),
        DataPart(_mimeType(file), bytes),
      ]),
    ];

    return _callWithRetry(content, role);
  }

  Future<AiLicenseValidationResult> _callWithRetry(
    List<Content> content,
    UserRole role, {
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
        return _parseResult(json, role);
      } on Exception catch (e) {
        debugPrint('[GeminiLicenseService] Attempt $attempt failed: $e');
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }
    return const AiLicenseValidationResult(
      isValid: false,
      statusMessage: 'aiValidationStatusErrorUnknown',
      confidenceScore: 0.0,
    );
  }


  AiLicenseValidationResult _parseResult(
      Map<String, dynamic> json, UserRole role) {
    if (json['isValidDocument'] == false) {
      return const AiLicenseValidationResult(
        isValid: false,
        statusMessage: 'aiValidationStatusInvalid',
        confidenceScore: 0.0,
      );
    }

    final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.0;
    if (confidence < 0.5) {
      return const AiLicenseValidationResult(
        isValid: false,
        statusMessage: 'aiValidationStatusLowConfidence',
        confidenceScore: 0.0,
      );
    }

    final expiryRaw = json['expiryDate']?.toString();
    final expiry = expiryRaw != null ? DateTime.tryParse(expiryRaw) : null;

    if (expiry != null && expiry.isBefore(DateTime.now())) {
      return const AiLicenseValidationResult(
        isValid: false,
        statusMessage: 'aiValidationStatusExpired',
        confidenceScore: 0.0,
      );
    }

    final categories = (json['suggestedCategories'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        _fallbackCategories(role);

    final docDetails = ExtractedDocData(
      docId: json['docNumber']?.toString() ?? '',
      organization: json['issuingOrganization']?.toString() ?? '',
      confidenceScore: confidence,
      expiryDate: expiry ?? DateTime.now().add(const Duration(days: 365 * 2)),
    );

    return AiLicenseValidationResult(
      isValid: true,
      statusMessage: 'aiValidationStatusSuccess',
      confidenceScore: confidence,
      suggestedCategories: categories,
      docDetails: docDetails,
    );
  }

  static List<String> _fallbackCategories(UserRole role) => switch (role) {
        UserRole.driver => ['مواد بناء', 'أجهزة كهربائية', 'معادن'],
        UserRole.supplier => ['ورق وكرتون', 'زجاج', 'بلاستيك', 'مطاط'],
        UserRole.recyclingCo => ['معادن', 'إلكترونيات', 'مواد خام', 'بطاريات'],
      };

  static String _mimeType(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }

  static String _prompt(UserRole role) {
    final roleAr = switch (role) {
      UserRole.driver => 'سائق (رخصة قيادة أو هوية شخصية)',
      UserRole.supplier => 'مورد (هوية شخصية أو سجل تجاري)',
      UserRole.recyclingCo => 'شركة تدوير (سجل تجاري أو ترخيص صناعي)',
    };

    final categoryPool = switch (role) {
      UserRole.driver =>
        'مواد بناء، أجهزة كهربائية، معادن، خردة، بلاستيك، إطارات',
      UserRole.supplier =>
        'ورق وكرتون، زجاج، بلاستيك، معادن، إلكترونيات، مطاط، أثاث، بطاريات',
      UserRole.recyclingCo =>
        'معادن، إلكترونيات، مواد خام، بطاريات، ورق، زجاج، مواد كيميائية، بلاستيك',
    };

    return '''
You are a document verifier for the Dawer recycling app in Jordan.
The user is registering as: $roleAr

Analyze this identity or business document image and return ONLY a strict JSON object — no markdown, no explanation:
{
  "isValidDocument": true,
  "docType": "national_id | driving_license | commercial_register | industrial_license | other",
  "docNumber": "document number as string or null",
  "issuingOrganization": "issuing authority in Arabic or null",
  "expiryDate": "YYYY-MM-DD or null if not present or not applicable",
  "confidence": 0.95,
  "suggestedCategories": ["Arabic category 1", "Arabic category 2"]
}

RULES:
- Set isValidDocument=false if the image is NOT a recognizable identity or business document.
- Set confidence below 0.5 if blurry, partial, or unreadable.
- suggestedCategories: pick 2–4 relevant waste categories from this list based on the document type and role: $categoryPool
- Use null for any field not clearly visible — never guess.
- expiryDate: only include if the document explicitly shows an expiry date.
''';
  }
}
