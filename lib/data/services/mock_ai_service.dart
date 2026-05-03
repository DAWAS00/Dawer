// ════════════════════════════════════════════════════════════════════════════════
// MockAiService — isolated client-side AI simulation layer
// ════════════════════════════════════════════════════════════════════════════════
//
// FRONTEND-ONLY PHASE: Every response is 100% synthetic.
//
// HOW TO INTEGRATE REAL AI LATER:
//  1. Brand profile → replace [generateBrandProfile] body with your AI API call
//     (e.g. OpenAI Chat Completions, Gemini, or your own backend endpoint).
//  2. OCR / Verify  → replace [verifyDocument] body with your OCR + address
//     validation service (e.g. Google Cloud Vision, AWS Textract).
//  3. Delete the _mock* helpers and [_kMockCategories] constant below.
// ════════════════════════════════════════════════════════════════════════════════

/// Result returned by the brand-profile / category-suggestion step.
class BrandProfile {
  final List<String> suggestedCategories;

  /// What makes this company interesting / valuable inside the app.
  /// TODO: Populated by real AI from company name, tagline, and chosen categories.
  final List<String> companyHighlights;

  const BrandProfile({
    required this.suggestedCategories,
    required this.companyHighlights,
  });
}

/// Result returned by the document + address verification step.
class VerificationResult {
  final bool isVerified;
  final String summary;
  final Map<String, String> detectedFields;

  const VerificationResult({
    required this.isVerified,
    required this.summary,
    required this.detectedFields,
  });
}

abstract final class MockAiService {
  // ─── Public API ──────────────────────────────────────────────────────────────

  /// Generates a brand story and category suggestions.
  ///
  /// TODO: Replace body with a real AI API call, e.g.:
  /// ```dart
  /// final res = await openAiClient.chat(model:'gpt-4o', messages:[...]);
  /// return BrandProfile(story: res.content, suggestedCategories: ...);
  /// ```
  static Future<BrandProfile> generateBrandProfile({
    required String companyName,
    required String tagline,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 3));
    final name = companyName.trim().isEmpty ? 'شركتنا' : companyName.trim();
    return BrandProfile(
      suggestedCategories: List.unmodifiable(_kMockCategories),
      companyHighlights: _mockHighlights(name), // TODO: from real AI
    );
  }

  /// Simulates AI OCR + address validation.
  ///
  /// TODO: Replace body with real OCR + address validation, e.g.:
  /// ```dart
  /// final ocr = await cloudVisionClient.annotateImage(imagePath);
  /// final ok  = await addressApi.validate(address);
  /// return VerificationResult(isVerified: ok && ocr.hasLicense, ...);
  /// ```
  static Future<VerificationResult> verifyDocument({
    required String companyName,
    required String address,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 3));
    final name = companyName.trim().isEmpty ? 'شركة دوار' : companyName.trim();
    final addr = address.trim().isEmpty ? 'عمان، الاردن' : address.trim();
    return VerificationResult(
      isVerified: true,
      summary: 'تم التحقق من الوثائق والعنوان بنجاح',
      detectedFields: {
        'اسم الشركة': name,                 // TODO: from real OCR
        'رقم الترخيص': 'REC-2024-JO-0421', // TODO: from real OCR
        'تاريخ الانتهاء': '31/12/2026',     // TODO: from real OCR
        'منطقة الخدمة': addr,
        'حالة الترخيص': 'ساري المفعول',     // TODO: from real OCR
      },
    );
  }

  // ─── Mock data — DELETE when real AI is wired ─────────────────────────────

  // TODO: These categories will come from the AI API response.
  static const List<String> _kMockCategories = [
    'ادارة النفايات',
    'اعادة التدوير',
    'المواد الخام',
    'البلاستيك والورق',
    'المعادن والزجاج',
    'النفايات الالكترونية',
    'النفايات العضوية',
    'الاستدامة',
    'الطاقة المتجددة',
    'البيئة والتدوير',
  ];

  // TODO: Remove _mockHighlights when replacing with real AI.
  static List<String> _mockHighlights(String name) => [
    'ستظهر $name في نتائج بحث الموردين القريبين منك',
    'استقبال طلبات التجميع من الموردين مباشرة عبر التطبيق',
    'لوحة تحكم لتتبع كميات المواد وتطور حجم الأعمال',
    'الوصول لشبكة سائقين معتمدين لنقل المواد اليك',
    'تقييمات من الموردين تعزز ظهور شركتك في نتائج البحث',
  ];
}
