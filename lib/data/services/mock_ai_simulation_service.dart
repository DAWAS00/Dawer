import '../../domain/services/i_ai_simulation_service.dart';

/// Mock implementation of [IAiSimulationService] used for frontend prototyping.
/// It simulates network latency and returns highly formatted mock responses
/// designed to look like authentic generative AI outputs.
class MockAiSimulationService implements IAiSimulationService {
  @override
  Future<AiGenerationResult> generateProfile(String tagline) async {
    // Simulate network and processing delay
    await Future.delayed(const Duration(seconds: 3));

    // Mock AI logic to vary the response slightly based on the input
    final isItalian = tagline.toLowerCase().contains('italian') || tagline.toLowerCase().contains('pizza') || tagline.toLowerCase().contains('pasta');

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
  }

  @override
  Future<VerificationResult> verifyDocumentAndAddress(String address, String documentPath) async {
    // Simulate document OCR and Address verification API latency
    await Future.delayed(const Duration(seconds: 2));

    // Reject empty data
    if (address.trim().isEmpty || documentPath.trim().isEmpty) {
      return const VerificationResult(
        isVerified: false,
        statusMessage: "restaurantSignupErrorVerificationRequired",
      );
    }

    // Simulate invalid document detection for testing purposes:
    // Use paths containing 'invalid' or 'fail' to trigger failure state
    final lowerPath = documentPath.toLowerCase();
    if (lowerPath.contains('invalid') || lowerPath.contains('fail')) {
      return const VerificationResult(
        isVerified: false,
        statusMessage: "restaurantSignupErrorVerificationFailed",
      );
    }

    // Simulate missing or unreadable photo
    if (lowerPath.contains('empty') || lowerPath.contains('blank')) {
      return const VerificationResult(
        isVerified: false,
        statusMessage: "restaurantSignupErrorVerificationFailed",
      );
    }

    return const VerificationResult(
      isVerified: true,
      statusMessage: "restaurantSignupStatusVerified",
    );
  }
}
