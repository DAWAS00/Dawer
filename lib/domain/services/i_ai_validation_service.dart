class AiValidationResult {
  final bool isValid;
  final String statusMessage;
  final String? extractedData;
  final double confidenceScore;

  const AiValidationResult({
    required this.isValid,
    required this.statusMessage,
    this.extractedData,
    this.confidenceScore = 0.0,
  });
}

abstract class IAiValidationService {
  Future<AiValidationResult> validatePhoto(String filePath);
}
