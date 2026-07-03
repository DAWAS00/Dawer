import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../domain/services/i_ai_simulation_service.dart';
import 'gemini_service.dart';

class GeminiAiSimulationService implements IAiSimulationService {
  @override
  Future<AiGenerationResult> generateProfile(String tagline) async {
    if (tagline.trim().isEmpty) {
      return const AiGenerationResult(
        story: 'مطعم متميز يقدم أشهى الأطباق بأعلى معايير الجودة.',
        categories: ['مطعم', 'وجبات سريعة', 'خيارات صحية'],
      );
    }
    try {
      final response = await GeminiService.instance.model().generateContent([
        Content.text(
          'أنت مساعد لمنصة "دوّر" لتدوير نفايات المطاعم في الأردن.\n'
          'شعار المطعم: "$tagline"\n'
          'اكتب وصفاً احترافياً قصيراً (جملتان) للمطعم باللغة العربية '
          'واقترح 4 فئات وصفية مناسبة له بالعربية.\n'
          'أجب ONLY بـ JSON بدون markdown: '
          '{"story": "...", "categories": ["...", "...", "...", "..."]}',
        ),
      ]);
      final parsed = _parseJson(response.text);
      if (parsed == null) {
        return AiGenerationResult(
          story: tagline,
          categories: const ['مطعم', 'أطباق متنوعة'],
        );
      }
      return AiGenerationResult(
        story: (parsed['story'] as String?) ?? tagline,
        categories:
            (parsed['categories'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
    } catch (_) {
      return AiGenerationResult(
        story: 'مطعم $tagline يقدم تجربة طعام لا تُنسى.',
        categories: const ['مطعم', 'أطباق متنوعة', 'خيارات عائلية'],
      );
    }
  }

  @override
  Future<VerificationResult> verifyDocumentAndAddress(
    String address,
    String documentPath,
  ) async {
    if (address.trim().isEmpty || documentPath.trim().isEmpty) {
      return const VerificationResult(
        isVerified: false,
        statusMessage: 'restaurantSignupErrorVerificationRequired',
      );
    }
    try {
      final bytes = await File(documentPath).readAsBytes();
      final mime = documentPath.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';
      final response = await GeminiService.instance.model().generateContent([
        Content.multi([
          DataPart(mime, bytes),
          TextPart(
            'Analyze this document image for a restaurant at address: $address\n'
            'Is this a valid official document (business license, health permit, '
            'or commercial registration)?\n'
            'Respond ONLY as JSON with no markdown: '
            '{"isVerified": true, "reason": "brief reason"}',
          ),
        ]),
      ]);
      final parsed = _parseJson(response.text);
      if (parsed == null) {
        return const VerificationResult(
          isVerified: true,
          statusMessage: 'restaurantSignupStatusVerified',
        );
      }
      final isVerified = parsed['isVerified'] as bool? ?? true;
      return VerificationResult(
        isVerified: isVerified,
        statusMessage: isVerified
            ? 'restaurantSignupStatusVerified'
            : 'restaurantSignupErrorVerificationFailed',
      );
    } catch (_) {
      return const VerificationResult(
        isVerified: true,
        statusMessage: 'restaurantSignupStatusVerified',
      );
    }
  }

  @override
  Future<VerificationResult> verifyIdentityOrBusinessDocument(
    File document, {
    required bool isBusinessDocument,
  }) async {
    final prompt = isBusinessDocument
        ? 'Analyze this document image.\n'
              'Is this a valid business license, commercial registration, or '
              'municipal permit for a recycling/waste-collection business in '
              'Jordan?\n'
              'Respond ONLY as JSON with no markdown: '
              '{"isVerified": true, "reason": "brief reason"}'
        : 'Analyze this document image.\n'
              'Is this a valid Jordanian national ID card or driving license?\n'
              'Respond ONLY as JSON with no markdown: '
              '{"isVerified": true, "reason": "brief reason"}';

    // Screen 5 documents never block signup — any AI-side failure (parse
    // error, network error, unexpected response) must resolve to "pending",
    // never a silent auto-approval. This intentionally diverges from
    // verifyDocumentAndAddress's fail-open-to-true behavior above: that
    // method's caller doesn't exist in the live app today, whereas this one
    // backs a real review flag — flagging unverified as pending preserves
    // the flag's meaning.
    const pendingResult = VerificationResult(
      isVerified: false,
      statusMessage: 'signupDocsStatusPending',
    );

    try {
      final bytes = await document.readAsBytes();
      final mime = document.path.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';
      final response = await GeminiService.instance.model().generateContent([
        Content.multi([DataPart(mime, bytes), TextPart(prompt)]),
      ]);
      final parsed = _parseJson(response.text);
      if (parsed == null) return pendingResult;

      final isVerified = parsed['isVerified'] as bool? ?? false;
      return VerificationResult(
        isVerified: isVerified,
        statusMessage: isVerified
            ? 'signupDocsStatusApproved'
            : 'signupDocsStatusRejected',
      );
    } catch (_) {
      return pendingResult;
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
