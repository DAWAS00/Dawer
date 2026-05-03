import '../../domain/services/i_ai_license_validation_service.dart';
import '../models/user_role.dart';

class MockAiLicenseValidationService implements IAiLicenseValidationService {
  static List<String> _categoriesForRole(UserRole role) => switch (role) {
        UserRole.driver => ['مواد بناء', 'أجهزة كهربائية', 'معادن'],
        UserRole.supplier => ['ورق وكرتون', 'زجاج', 'بلاستيك', 'مطاط'],
        UserRole.recyclingCo => ['معادن', 'إلكترونيات', 'مواد خام', 'بطاريات'],
      };

  @override
  Future<AiLicenseValidationResult> validateLicense(
      String filePath, UserRole role) async {
    // Simulate high-tech AI processing time
    await Future.delayed(const Duration(milliseconds: 4000));

    final lower = filePath.toLowerCase();
    if (lower.contains('fail') || lower.contains('invalid')) {
      return const AiLicenseValidationResult(
        isValid: false,
        statusMessage: 'aiValidationStatusInvalid',
        confidenceScore: 0.1,
      );
    }

    // Mock data for "impression"
    final mockData = ExtractedDocData(
      docId: 'JO-${DateTime.now().year}-88${DateTime.now().millisecond}',
      organization: role == UserRole.recyclingCo 
          ? 'شركة البيئة للتطوير' 
          : 'وزارة الداخلية - دائرة الأحوال المدنية',
      confidenceScore: 0.992,
      expiryDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    return AiLicenseValidationResult(
      isValid: true,
      statusMessage: 'aiValidationStatusSuccess',
      confidenceScore: 0.97,
      suggestedCategories: _categoriesForRole(role),
      docDetails: mockData,
    );
  }
}
