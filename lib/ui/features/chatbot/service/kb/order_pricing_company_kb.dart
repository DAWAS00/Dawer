import '../../models/dawa_entry.dart';

/// Knowledge-base entries: Order status, Pricing, Waste types, Recycling company.
const List<DawaEntry> kOrderPricingCompanyEntries = [
  // ── Order Status ──────────────────────────────────────────────
  DawaEntry(
    id: 'order_status',
    keywords: [
      'حالة الطلب', 'ماذا تعني', 'معنى الحالة', 'status',
      'order state', 'what does status mean',
    ],
    response:
        'حالات الطلب في دوّر:\n\n'
        '🟡 قيد الانتظار — لم يُقبل من سائق بعد\n'
        '🟢 تم القبول — سائق قبل الطلب\n'
        '🔵 في الطريق — السائق متحرك\n'
        '✅ مكتمل — تم التسليم بنجاح\n'
        '❌ ملغي — تم الإلغاء',
    followUpIds: ['track_order', 'cancel_order', 'how_to_post_request'],
  ),
  DawaEntry(
    id: 'order_status_meanings',
    keywords: [
      'قيد الانتظار', 'في الطريق', 'تم القبول', 'مكتمل', 'ملغي',
      'pending', 'in transit', 'accepted', 'completed', 'cancelled',
    ],
    response:
        'معنى كل حالة:\n'
        '• قيد الانتظار: طلبك منشور وينتظر سائقاً\n'
        '• تم القبول: سائق التزم بطلبك — ستجد بياناته\n'
        '• في الطريق: السائق في طريقه إليك\n'
        '• مكتمل: تم تسليم النفايات لشركة التدوير\n'
        '• ملغي: تم إلغاء الطلب (يظهر في السجل)',
    followUpIds: ['track_order', 'cancel_order'],
  ),

  // ── Pricing ───────────────────────────────────────────────────
  DawaEntry(
    id: 'pricing_overview',
    keywords: [
      'التسعير', 'الأسعار', 'كم يكلف', 'كيف يُحسب', 'تسعير',
      'pricing', 'how much cost', 'price formula', 'cost',
    ],
    response:
        'نموذج التسعير في دوّر:\n\n'
        '✅ المورد: مجاناً — لا تدفع شيئاً\n'
        '💰 السائق يكسب:\n'
        '  1.50 د.أ (أساسية)\n'
        '  + مسافة × 0.60 د.أ/كم\n'
        '  + وزن × سعر المادة\n'
        '  + 0.50 د.أ (إذا كان الطلب عاجلاً)\n\n'
        'شركة التدوير تدفع للسائق ومصاريف المنصة.',
    followUpIds: ['material_rates', 'urgency_pricing', 'driver_earnings'],
  ),
  DawaEntry(
    id: 'material_rates',
    keywords: [
      'سعر المادة', 'أسعار المواد', 'كم يساوي', 'تسعير النفايات',
      'material rate', 'waste price', 'oil price', 'metal rate',
    ],
    response:
        'أسعار المواد (للسائق):\n\n'
        '• زيت مستعمل: 0.05 د.أ/لتر\n'
        '• بلاستيك: 0.03 د.أ/كغ\n'
        '• معادن: 0.07 د.أ/كغ\n'
        '• زجاج: 0.02 د.أ/كغ\n'
        '• إلكترونيات: 0.10 د.أ/كغ\n'
        '• عضوي: 0.01 د.أ/كغ\n'
        '• أثاث: يُحدد يدوياً\n'
        '• أخرى: مخصص',
    followUpIds: ['pricing_overview', 'waste_types', 'driver_earnings'],
  ),
  DawaEntry(
    id: 'urgency_pricing',
    keywords: ['عاجل', 'أولوية', 'طلب عاجل', 'urgent', 'priority'],
    response:
        'الطلب العاجل (عاجل):\n\n'
        '• المورد يُحدده عند إرسال الطلب\n'
        '• يمنح الطلب أولوية في قائمة السائقين القريبين\n'
        '• يُضيف +0.50 د.أ للمكافأة تلقائياً\n'
        '• المورد لا يدفع إضافياً — المنصة تتحمل الفرق\n\n'
        'مفيد جداً للزيت المستعمل الذي قد يُسبب مشاكل إذا تُرك طويلاً.',
    followUpIds: ['how_to_post_request', 'pricing_overview', 'material_rates'],
  ),

  // ── Waste Types ───────────────────────────────────────────────
  DawaEntry(
    id: 'waste_types',
    keywords: [
      'أنواع النفايات', 'ماذا تقبل', 'أي نوع', 'فئات',
      'waste types', 'what types', 'categories', 'recyclables',
    ],
    response:
        'أنواع النفايات المقبولة في دوّر (15 فئة):\n\n'
        'ورق | بلاستيك | معادن | زجاج | إلكترونيات\n'
        'عضوي | أقمشة | خشب | مطاط | زيوت\n'
        'كيميائيات | بطاريات | أثاث | إطارات | مخلفات بناء\n\n'
        'يمكنك اختيار أكثر من فئة في نفس الطلب.',
    followUpIds: ['how_to_post_request', 'material_rates', 'ml_waste_scan'],
  ),

  // ── Recycling Company ─────────────────────────────────────────
  DawaEntry(
    id: 'company_overview',
    keywords: [
      'شركة إعادة تدوير', 'مهام الشركة', 'ماذا تفعل الشركة',
      'recycling company', 'company features',
    ],
    response:
        'ميزات شركة إعادة التدوير:\n\n'
        '• عرض الشحنات القادمة (inTransit)\n'
        '• نشر وظائف تجميع للسائقين\n'
        '• إحصاءات: الشحنات الواردة، الوزن الكلي، الوظائف النشطة\n'
        '• تتبع السائقين المتحركين\n'
        '• فتح/إغلاق الشركة (toggle)',
    followUpIds: ['post_collection_job', 'company_stats', 'company_signup'],
  ),
  DawaEntry(
    id: 'post_collection_job',
    keywords: [
      'نشر وظيفة', 'وظيفة تجميع', 'نشر عمل للسائقين',
      'post job', 'collection job', 'post collection',
    ],
    response:
        'لنشر وظيفة تجميع:\n'
        '1. اضغط بطاقة "نشر وظيفة تجميع جديدة" في صفحتك الرئيسية\n'
        '2. حدد أنواع النفايات المطلوبة\n'
        '3. أدخل المنطقة المستهدفة (مطلوبة)\n'
        '4. أضف ملاحظات اختيارية\n'
        '5. اضغط "نشر الوظيفة"\n\n'
        'ستظهر الوظيفة للسائقين المتاحين في منطقتك.',
    followUpIds: ['company_overview', 'company_stats'],
  ),
  DawaEntry(
    id: 'company_stats',
    keywords: [
      'إحصاءات الشركة', 'الوزن المعالج', 'عدد الشحنات', 'نشاط الشركة',
      'company stats', 'total weight', 'shipments',
    ],
    response:
        'إحصاءات شركة التدوير:\n\n'
        '📦 الشحنات الواردة — عدد الشحنات القادمة\n'
        '⚖️ الوزن الكلي — إجمالي الكيلوغرامات المعالجة\n'
        '💼 الوظائف النشطة — وظائف التجميع المنشورة\n'
        '🚚 سائقون في التنفيذ — عدد السائقين في الطريق حالياً',
    followUpIds: ['company_overview', 'post_collection_job'],
  ),
];
