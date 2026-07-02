import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'gemini_service.dart';
import 'mock_ai_service.dart';

class GeminiBrandProfileAiService {
  static const _categories =
      'ورق وكرتون، بلاستيك، معادن، زجاج، إلكترونيات، نفايات عضوية، نسيج، خشب، '
      'مطاط، زيوت، بطاريات، أثاث، إطارات، مواد بناء، مطاعم وفنادق';

  Future<BrandProfile> generateBrandProfile({
    required String companyName,
    required String tagline,
  }) async {
    final name = companyName.trim().isEmpty ? 'الشركة' : companyName.trim();
    final tag = tagline.trim().isEmpty ? 'خدمات التدوير' : tagline.trim();

    try {
      final response = await GeminiService.instance.model().generateContent([
        Content.text(
          'أنت مساعد لمنصة "دوّر" لتدوير النفايات في الأردن.\n'
          'اسم الشركة: $name\n'
          'الشعار: $tag\n\n'
          'اقترح 8 فئات نفايات مناسبة من هذه القائمة: $_categories\n'
          'واقترح 4 مميزات تسويقية قصيرة باللغة العربية تذكر اسم الشركة.\n'
          'أجب ONLY بـ JSON بدون markdown:\n'
          '{"categories": ["فئة1", ...], "highlights": ["ميزة1", ...]}',
        ),
      ]);
      final parsed = _parseJson(response.text);
      if (parsed == null) return _fallback(name);

      final rawCats = parsed['categories'];
      final rawHighlights = parsed['highlights'];
      return BrandProfile(
        suggestedCategories: rawCats is List
            ? rawCats.map((e) => e.toString()).toList()
            : _defaultCategories,
        companyHighlights: rawHighlights is List
            ? rawHighlights.map((e) => e.toString()).toList()
            : _defaultHighlights(name),
      );
    } catch (_) {
      return _fallback(name);
    }
  }

  static BrandProfile _fallback(String name) => BrandProfile(
    suggestedCategories: _defaultCategories,
    companyHighlights: _defaultHighlights(name),
  );

  static const _defaultCategories = [
    'ورق وكرتون',
    'بلاستيك',
    'معادن',
    'زجاج',
    'إلكترونيات',
    'نفايات عضوية',
    'مطاط',
    'زيوت',
  ];

  static List<String> _defaultHighlights(String name) => [
    'ستظهر $name في نتائج بحث الموردين القريبين',
    'استقبال طلبات التجميع مباشرة عبر التطبيق',
    'لوحة تحكم لتتبع الكميات وتطور حجم الأعمال',
    'الوصول لشبكة سائقين معتمدين لنقل المواد',
  ];

  Map<String, dynamic>? _parseJson(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      final cleaned = text.replaceAll(RegExp(r'```json?\s*|\s*```'), '').trim();
      return json.decode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
