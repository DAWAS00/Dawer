import '../../domain/services/i_brand_profile_ai_service.dart';
import 'mock_ai_base.dart';

class MockBrandProfileAiService extends MockAiBase implements IBrandProfileAiService {
  static const List<String> _kMockCategories = [
    'ادارة النفايات', 'اعادة التدوير', 'المواد الخام',
    'البلاستيك والورق', 'المعادن والزجاج', 'النفايات الالكترونية',
    'النفايات العضوية', 'الاستدامة', 'الطاقة المتجددة', 'البيئة والتدوير',
  ];

  @override
  Future<BrandProfile> generateBrandProfile({
    required String companyName,
    required String tagline,
  }) =>
      simulate(
        () {
          final name = companyName.trim().isEmpty ? 'شركتنا' : companyName.trim();
          return BrandProfile(
            suggestedCategories: List.unmodifiable(_kMockCategories),
            companyHighlights: _mockHighlights(name),
          );
        },
        delay: const Duration(seconds: 3),
      );

  static List<String> _mockHighlights(String name) => [
    'ستظهر $name في نتائج بحث الموردين القريبين منك',
    'استقبال طلبات التجميع من الموردين مباشرة عبر التطبيق',
    'لوحة تحكم لتتبع كميات المواد وتطور حجم الأعمال',
    'الوصول لشبكة سائقين معتمدين لنقل المواد اليك',
    'تقييمات من الموردين تعزز ظهور شركتك في نتائج البحث',
  ];
}
