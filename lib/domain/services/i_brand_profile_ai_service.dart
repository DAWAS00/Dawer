class BrandProfile {
  final List<String> suggestedCategories;
  final List<String> companyHighlights;
  const BrandProfile({required this.suggestedCategories, required this.companyHighlights});
}

abstract interface class IBrandProfileAiService {
  Future<BrandProfile> generateBrandProfile({
    required String companyName,
    required String tagline,
  });
}
