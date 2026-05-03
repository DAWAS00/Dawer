import '../../data/models/user_role.dart';
import 'i_ai_validation_service.dart';

abstract class IAiLicenseValidationService {
  Future<AiValidationResult> validateLicense(String filePath, UserRole role);
}
