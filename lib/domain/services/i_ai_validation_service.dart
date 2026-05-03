class AiValidationResult {
  final bool isValid;
  final String statusMessage;
  final String? extractedData;
  final double confidenceScore;
  final List<String> suggestedCategories;

  const AiValidationResult({
    required this.isValid,
    required this.statusMessage,
    this.extractedData,
    this.confidenceScore = 0.0,
    this.suggestedCategories = const [],
  });
}

abstract class IAiValidationService {
  Future<AiValidationResult> validatePhoto(String filePath);
}
