import '../../domain/services/i_ai_validation_service.dart';

class MockAiValidationService implements IAiValidationService {
  @override
  Future<AiValidationResult> validatePhoto(String filePath) async {
    // Simulate network delay for AI processing to allow animated text to show
    await Future.delayed(const Duration(seconds: 4));

    // Simple mock logic: paths containing 'fail' or 'invalid' return an error state.
    final lowerPath = filePath.toLowerCase();
    if (lowerPath.contains('fail') || lowerPath.contains('invalid')) {
      return const AiValidationResult(
        isValid: false,
        statusMessage: 'aiValidationStatusInvalid',
        confidenceScore: 0.1,
      );
    }

    // Default to success
    return const AiValidationResult(
      isValid: true,
      statusMessage: 'aiValidationStatusSuccess',
      confidenceScore: 0.98,
    );
  }
}
