import 'dart:async';

import '../../domain/services/i_ai_marketplace_service.dart';
import 'mock_ai_base.dart';

class MockAiMarketplaceService extends MockAiBase implements IAiMarketplaceService {
  @override
  Future<AiMarketplaceSuggestion> getSuggestionsForRestaurant(
      String cuisine, String address) =>
      simulate(
        () => cuisine.trim().isEmpty
            ? const AiMarketplaceSuggestion(
                marketplaceLookupPrompt: '✨ AI suggests exploring our top trending marketplace categories today.',
                appDiscoverySuggestion: '✨ Check out our latest tools to help manage your business.',
              )
            : AiMarketplaceSuggestion(
                marketplaceLookupPrompt: '✨ We noticed you serve $cuisine. AI suggests looking up wholesale suppliers for fresh produce and spices in your local marketplace.',
                appDiscoverySuggestion: '✨ Explore our \'Bulk Order Automation\' tool and \'Supplier Verification\' badges to streamline your commercial supply chain securely.',
              ),
        delay: const Duration(seconds: 2),
      );

  @override
  Future<AiMarketplaceSuggestion> getSuggestionsForSupplier(String category) =>
      simulate(
        () => category.trim().isEmpty
            ? const AiMarketplaceSuggestion(
                marketplaceLookupPrompt: '✨ AI suggests exploring our top trending marketplace categories today.',
                appDiscoverySuggestion: '✨ Check out our latest tools to help manage your business.',
              )
            : AiMarketplaceSuggestion(
                marketplaceLookupPrompt: '✨ Based on your profile, we recommend looking up current demand for $category and pricing trends in your area.',
                appDiscoverySuggestion: '✨ Check out our \'Quick Listing\' tool to get your first products live in under 2 minutes, and set up \'Instant Notifications\' for nearby buyers.',
              ),
        delay: const Duration(seconds: 2),
      );
}
