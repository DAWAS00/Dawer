import 'dart:io';

abstract class IAiSimulationService {
  /// Simulates generating a rich profile story and suggested categories from a short tagline.
  /// [FUTURE IMPLEMENTATION: AI API Integration]
  /// Replace with real LLM prompt (e.g., OpenAI API) that takes the tagline and returns JSON.
  Future<AiGenerationResult> generateProfile(String tagline);

  /// Simulates verifying a document and an address using AI OCR and Location Intelligence.
  /// [FUTURE IMPLEMENTATION: AI API Integration]
  /// Replace with real Vision OCR and Address Validation API calls.
  Future<VerificationResult> verifyDocumentAndAddress(
    String address,
    String documentPath,
  );

  /// Verifies a Screen 5 signup document (national ID/driving license for
  /// individuals, or business license/commercial registration/municipal
  /// permit for store-business suppliers and recycling companies).
  ///
  /// Unlike [verifyDocumentAndAddress] (restaurant-specific, requires an
  /// address), this is scoped purely to document authenticity and doesn't
  /// require an address. Callers must treat any error/failure result as
  /// "pending" (not verified), never as an implicit approval — Screen 5's
  /// entire purpose is triage, so failing open would defeat it.
  Future<VerificationResult> verifyIdentityOrBusinessDocument(
    File document, {
    required bool isBusinessDocument,
  });
}

class AiGenerationResult {
  final String story;
  final List<String> categories;

  const AiGenerationResult({required this.story, required this.categories});
}

class VerificationResult {
  final bool isVerified;
  final String statusMessage;

  const VerificationResult({
    required this.isVerified,
    required this.statusMessage,
  });
}
