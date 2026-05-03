abstract class IAiSimulationService {
  /// Simulates generating a rich profile story and suggested categories from a short tagline.
  /// [FUTURE IMPLEMENTATION: AI API Integration]
  /// Replace with real LLM prompt (e.g., OpenAI API) that takes the tagline and returns JSON.
  Future<AiGenerationResult> generateProfile(String tagline);

  /// Simulates verifying a document and an address using AI OCR and Location Intelligence.
  /// [FUTURE IMPLEMENTATION: AI API Integration]
  /// Replace with real Vision OCR and Address Validation API calls.
  Future<VerificationResult> verifyDocumentAndAddress(String address, String documentPath);
}

class AiGenerationResult {
  final String story;
  final List<String> categories;

  const AiGenerationResult({
    required this.story,
    required this.categories,
  });
}

class VerificationResult {
  final bool isVerified;
  final String statusMessage;

  const VerificationResult({
    required this.isVerified,
    required this.statusMessage,
  });
}
