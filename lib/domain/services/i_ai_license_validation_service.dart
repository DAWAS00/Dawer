import '../../data/models/user_role.dart';
import 'i_ai_validation_service.dart';

class ExtractedDocData {
  final String docId;
  final String organization;
  final double confidenceScore;
  final DateTime expiryDate;

  const ExtractedDocData({
    required this.docId,
    required this.organization,
    required this.confidenceScore,
    required this.expiryDate,
  });
}

class AiLicenseValidationResult extends AiValidationResult {
  final ExtractedDocData? docDetails;

  const AiLicenseValidationResult({
    required super.isValid,
    required super.statusMessage,
    super.extractedData,
    super.confidenceScore,
    super.suggestedCategories,
    this.docDetails,
  });
}

abstract class IAiLicenseValidationService {
  Future<AiLicenseValidationResult> validateLicense(
    String filePath,
    UserRole role,
  );
}
