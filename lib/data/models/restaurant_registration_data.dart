class RestaurantRegistrationData {
  final String? ownerName;
  final String? companyName;
  final String? photoPath;
  final String? tagline;
  final String? aiGeneratedContent;
  final List<String> selectedCategories;
  final String? address;
  final bool isCertificationVerified;

  const RestaurantRegistrationData({
    this.ownerName,
    this.companyName,
    this.photoPath,
    this.tagline,
    this.aiGeneratedContent,
    this.selectedCategories = const [],
    this.address,
    this.isCertificationVerified = false,
  });

  RestaurantRegistrationData copyWith({
    String? ownerName,
    String? companyName,
    String? photoPath,
    String? tagline,
    String? aiGeneratedContent,
    List<String>? selectedCategories,
    String? address,
    bool? isCertificationVerified,
  }) {
    return RestaurantRegistrationData(
      ownerName: ownerName ?? this.ownerName,
      companyName: companyName ?? this.companyName,
      photoPath: photoPath ?? this.photoPath,
      tagline: tagline ?? this.tagline,
      aiGeneratedContent: aiGeneratedContent ?? this.aiGeneratedContent,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      address: address ?? this.address,
      isCertificationVerified: isCertificationVerified ?? this.isCertificationVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerName': ownerName,
      'companyName': companyName,
      'photoPath': photoPath,
      'tagline': tagline,
      'aiGeneratedContent': aiGeneratedContent,
      'selectedCategories': selectedCategories,
      'address': address,
      'isCertificationVerified': isCertificationVerified,
      'metadata': {
        // [FUTURE IMPLEMENTATION: AI API Integration]
        // Provide the real API key or references here later.
        'aiApiKeyUsed': '[PLACEHOLDER_FOR_FUTURE_API_KEY]'
      }
    };
  }
}
