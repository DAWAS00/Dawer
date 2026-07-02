class AiMarketplaceSuggestion {
  final String marketplaceLookupPrompt;
  final String appDiscoverySuggestion;

  const AiMarketplaceSuggestion({
    required this.marketplaceLookupPrompt,
    required this.appDiscoverySuggestion,
  });
}

abstract class IAiMarketplaceService {
  Future<AiMarketplaceSuggestion> getSuggestionsForSupplier(String category);
  Future<AiMarketplaceSuggestion> getSuggestionsForRestaurant(
    String cuisine,
    String address,
  );
}
