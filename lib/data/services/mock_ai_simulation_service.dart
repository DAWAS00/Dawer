import 'dart:io';

import '../../domain/services/i_ai_simulation_service.dart';

/// Mock [IAiSimulationService] used when `useSupabase == false` or no Gemini
/// API key is configured — keeps the dev/offline flow frictionless.
class MockAiSimulationService implements IAiSimulationService {
  const MockAiSimulationService();

  @override
  Future<AiGenerationResult> generateProfile(String tagline) async {
    return AiGenerationResult(
      story: tagline.trim().isEmpty
          ? 'مطعم متميز يقدم أشهى الأطباق بأعلى معايير الجودة.'
          : 'مطعم $tagline يقدم تجربة طعام لا تُنسى.',
      categories: const ['مطعم', 'أطباق متنوعة', 'خيارات عائلية'],
    );
  }

  @override
  Future<VerificationResult> verifyDocumentAndAddress(
    String address,
    String documentPath,
  ) async {
    return const VerificationResult(
      isVerified: true,
      statusMessage: 'restaurantSignupStatusVerified',
    );
  }

  @override
  Future<VerificationResult> verifyIdentityOrBusinessDocument(
    File document, {
    required bool isBusinessDocument,
  }) async {
    return const VerificationResult(
      isVerified: true,
      statusMessage: 'signupDocsStatusApproved',
    );
  }
}
