import '../../domain/services/i_ai_license_validation_service.dart';
import '../../domain/services/i_ai_validation_service.dart';
import '../models/user_role.dart';
import 'mock_ai_base.dart';

class MockAiLicenseValidationService extends MockAiBase implements IAiLicenseValidationService {
  static List<String> _categoriesForRole(UserRole role) => switch (role) {
        UserRole.driver => ['مواد بناء', 'أجهزة كهربائية', 'معادن'],
        UserRole.supplier => ['ورق وكرتون', 'زجاج', 'بلاستيك', 'مطاط'],
        UserRole.recyclingCo => ['معادن', 'إلكترونيات', 'مواد خام', 'بطاريات'],
      };

  @override
  Future<AiValidationResult> validateLicense(String filePath, UserRole role) =>
      simulate(
        () => isForcedFailure(filePath)
            ? const AiValidationResult(
                isValid: false,
                statusMessage: 'aiValidationStatusInvalid',
                confidenceScore: 0.1,
              )
            : AiValidationResult(
                isValid: true,
                statusMessage: 'aiValidationStatusSuccess',
                confidenceScore: 0.97,
                suggestedCategories: _categoriesForRole(role),
              ),
      );
}
