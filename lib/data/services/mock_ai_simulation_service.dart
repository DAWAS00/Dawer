import '../../domain/services/i_ai_simulation_service.dart';
import 'mock_ai_base.dart';

/// Mock implementation of [IAiSimulationService] used for frontend prototyping.
/// It simulates network latency and returns highly formatted mock responses
/// designed to look like authentic generative AI outputs.
class MockAiSimulationService extends MockAiBase implements IAiSimulationService {
  @override
  Future<AiGenerationResult> generateProfile(String tagline) =>
      simulate(
        () {
          final isItalian = tagline.toLowerCase().contains('italian') ||
              tagline.toLowerCase().contains('pizza') ||
              tagline.toLowerCase().contains('pasta');

          final generatedStory = isItalian
              ? "Welcome to our authentic Italian kitchen. Born from a passion for traditional recipes and fresh, locally sourced ingredients, our family-owned restaurant brings the heart of Italy to your table. Every dish is crafted from scratch daily, promising an unforgettable culinary experience."
              : "Experience culinary excellence with our carefully crafted menu. We take pride in using only the finest ingredients to create bold, unforgettable flavors. Whether you're here for a quick bite or a celebratory feast, our warm atmosphere and passionate chefs guarantee a remarkable dining experience.";

          final recommendedCategories = isItalian
              ? ["Italian", "Pasta", "Pizza", "Casual Dining", "Family Friendly"]
              : ["Contemporary", "Fine Dining", "Local Favorites", "Comfort Food"];

          return AiGenerationResult(
            story: generatedStory,
            categories: recommendedCategories,
          );
        },
        delay: const Duration(seconds: 3),
      );

  @override
  Future<VerificationResult> verifyDocumentAndAddress(String address, String documentPath) =>
      simulate(
        () {
          if (address.trim().isEmpty || documentPath.trim().isEmpty) {
            return const VerificationResult(
              isVerified: false,
              statusMessage: "restaurantSignupErrorVerificationRequired",
            );
          }
          if (isForcedFailure(documentPath)) {
            return const VerificationResult(
              isVerified: false,
              statusMessage: "restaurantSignupErrorVerificationFailed",
            );
          }
          final lower = documentPath.toLowerCase();
          if (lower.contains('empty') || lower.contains('blank')) {
            return const VerificationResult(
              isVerified: false,
              statusMessage: "restaurantSignupErrorVerificationFailed",
            );
          }
          return const VerificationResult(
            isVerified: true,
            statusMessage: "restaurantSignupStatusVerified",
          );
        },
        delay: const Duration(seconds: 2),
      );
}
