import 'package:google_generative_ai/google_generative_ai.dart';

import '../../domain/services/i_ai_marketplace_service.dart';
import 'gemini_service.dart';

class GeminiAiMarketplaceService implements IAiMarketplaceService {
  @override
  Future<AiMarketplaceSuggestion> getSuggestionsForSupplier(
    String category,
  ) async {
    if (category.trim().isEmpty) {
      return const AiMarketplaceSuggestion(
        marketplaceLookupPrompt:
            'استكشف أحدث الفئات المطلوبة في سوق التدوير اليوم.',
        appDiscoverySuggestion:
            'جرّب أداة "الإدراج السريع" لنشر أول عرض لك في أقل من دقيقتين.',
      );
    }
    try {
      final response = await GeminiService.instance.model().generateContent([
        Content.text(
          'أنت مساعد لمنصة "دوّر" لتدوير النفايات في الأردن.\n'
          'المورد يعمل في فئة: $category\n'
          'اكتب جملتين قصيرتين باللغة العربية:\n'
          '1. اقتراح للبحث في السوق المحلي لهذه الفئة\n'
          '2. نصيحة لاستخدام ميزة في تطبيق دوّر\n'
          'أجب بالجملتين فقط، مفصولتين بسطر جديد، بدون ترقيم.',
        ),
      ]);
      final lines = (response.text ?? '')
          .trim()
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();
      return AiMarketplaceSuggestion(
        marketplaceLookupPrompt: lines.isNotEmpty
            ? lines[0]
            : 'تحقق من الطلب الحالي على $category في منطقتك.',
        appDiscoverySuggestion: lines.length > 1
            ? lines[1]
            : 'فعّل الإشعارات الفورية لتعرف عند وجود مشترين قريبين.',
      );
    } catch (_) {
      return AiMarketplaceSuggestion(
        marketplaceLookupPrompt:
            'تحقق من الطلب الحالي على $category وأسعاره في منطقتك.',
        appDiscoverySuggestion:
            'فعّل الإشعارات الفورية لتعرف عند وجود مشترين قريبين منك.',
      );
    }
  }

  @override
  Future<AiMarketplaceSuggestion> getSuggestionsForRestaurant(
    String cuisine,
    String address,
  ) async {
    if (cuisine.trim().isEmpty) {
      return const AiMarketplaceSuggestion(
        marketplaceLookupPrompt: 'استكشف خدمات تجميع النفايات المتاحة لمطعمك.',
        appDiscoverySuggestion:
            'جدوِّل عمليات تجميع النفايات أسبوعياً لتوفير الوقت والتكلفة.',
      );
    }
    try {
      final response = await GeminiService.instance.model().generateContent([
        Content.text(
          'أنت مساعد لمنصة "دوّر" لتدوير النفايات في الأردن.\n'
          'المطعم: نوع المطبخ "$cuisine"، الموقع: $address\n'
          'اكتب جملتين قصيرتين باللغة العربية:\n'
          '1. نوع النفايات الشائعة لهذا المطبخ وكيف يمكن تدويرها\n'
          '2. نصيحة لاستخدام ميزة في تطبيق دوّر\n'
          'أجب بالجملتين فقط، مفصولتين بسطر جديد، بدون ترقيم.',
        ),
      ]);
      final lines = (response.text ?? '')
          .trim()
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();
      return AiMarketplaceSuggestion(
        marketplaceLookupPrompt: lines.isNotEmpty
            ? lines[0]
            : 'مطعم $cuisine يُنتج نفايات عضوية وزيوت قابلة للتدوير.',
        appDiscoverySuggestion: lines.length > 1
            ? lines[1]
            : 'جدوِّل عمليات تجميع النفايات أسبوعياً عبر تطبيق دوّر.',
      );
    } catch (_) {
      return AiMarketplaceSuggestion(
        marketplaceLookupPrompt:
            'مطعم $cuisine يُنتج نفايات عضوية وزيوت قابلة للتدوير.',
        appDiscoverySuggestion:
            'جدوِّل عمليات تجميع النفايات أسبوعياً عبر تطبيق دوّر.',
      );
    }
  }
}
