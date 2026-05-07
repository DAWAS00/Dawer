import '../../domain/services/i_ai_validation_service.dart';
import 'mock_ai_base.dart';

class MockAiValidationService extends MockAiBase implements IAiValidationService {
  @override
  Future<AiValidationResult> validatePhoto(String filePath) =>
      simulate(
        () => isForcedFailure(filePath)
            ? const AiValidationResult(isValid: false, statusMessage: 'aiValidationStatusInvalid', confidenceScore: 0.1)
            : const AiValidationResult(isValid: true, statusMessage: 'aiValidationStatusSuccess', confidenceScore: 0.98),
        delay: const Duration(seconds: 4),
      );
}
