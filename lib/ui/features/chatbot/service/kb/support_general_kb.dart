import '../../models/dawa_entry.dart';

/// Knowledge-base entries: Support, coverage area, environmental impact.
const List<DawaEntry> kSupportGeneralEntries = [
  DawaEntry(
    id: 'rate_driver',
    keywords: [
      'تقييم السائق', 'نجوم', 'تقييم', 'rate driver', 'review', 'stars',
    ],
    response:
        'تقييم السائق:\n\n'
        'بعد إتمام الطلب يمكنك تقييم السائق من 1 إلى 5 نجوم.\n'
        'التقييمات تؤثر على ترتيب السائق في قائمة الطلبات المتاحة.\n'
        'سائقو التقييم العالي يُفضَّلون في الطلبات العاجلة.',
    followUpIds: ['track_order', 'driver_complete_order'],
  ),
  DawaEntry(
    id: 'support',
    keywords: [
      'دعم', 'مساعدة', 'مشكلة', 'تواصل', 'شكوى',
      'support', 'help', 'problem', 'contact', 'complaint',
    ],
    response:
        'للتواصل مع الدعم:\n\n'
        '• داخل التطبيق: الملف الشخصي ← "التواصل مع الدعم"\n'
        '• البريد: support@dawer.jo\n'
        '• ساعات العمل: 8ص – 8م (بتوقيت عمّان)\n\n'
        'يرجى ذكر رقم الطلب عند التواصل.',
    followUpIds: ['cancel_order'],
  ),
  DawaEntry(
    id: 'coverage_area',
    keywords: [
      'المناطق', 'خدمة', 'المدن', 'أين يعمل', 'التغطية',
      'coverage', 'cities', 'where available', 'areas',
    ],
    response:
        'مناطق تغطية دوّر حالياً:\n\n'
        '📍 عمّان\n'
        '📍 الزرقاء\n'
        '📍 إربد\n'
        '📍 العقبة\n\n'
        'يتم التوسع لمناطق جديدة تدريجياً.',
    followUpIds: ['what_is_dawer', 'how_to_register'],
  ),
  DawaEntry(
    id: 'environmental_impact',
    keywords: [
      'البيئة', 'كربون', 'CO2', 'أثر بيئي', 'نفايات مُعادة',
      'environment', 'carbon', 'impact', 'co2 saved',
    ],
    response:
        'الأثر البيئي لدوّر 🌍\n\n'
        'المنصة تتتبع:\n'
        '• الوزن الكلي للنفايات المُحوّلة عن المكبات\n'
        '• كمية CO₂ الموفرة لكل مادة\n\n'
        'الأهداف المتوقعة (السنة الأولى):\n'
        '• 300+ طن/شهر تُحوّل عن المكبات\n'
        '• ~120 طن CO₂ موفرة شهرياً\n\n'
        'كل طلب مكتمل يُسجَّل ضمن الأثر البيئي الكلي للمنصة.',
    followUpIds: ['what_is_dawer', 'points_system', 'waste_types'],
  ),
];
