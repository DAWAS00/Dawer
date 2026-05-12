import '../../models/dawa_entry.dart';

/// Knowledge-base entries: Marketplace overview, listings, search, item details,
/// buy and claim actions.
const List<DawaEntry> kMarketplaceOverviewEntries = [
  DawaEntry(
    id: 'marketplace',
    keywords: [
      'السوق', 'ماركت', 'عروض', 'شراء', 'بيع نفايات', 'قائمة السوق',
      'marketplace', 'market', 'buy', 'sell', 'listings',
    ],
    response:
        'السوق (Marketplace) في دوّر 🏪\n\n'
        'يضم قسمين رئيسيين:\n'
        '• العروض: مواد معروضة للبيع أو الاستلام\n'
        '• وظائف التجميع: إعلانات من شركات التدوير\n\n'
        'كل دور يرى إجراءات مختلفة:\n'
        '  🚚 سائق — "استلم وابيع": يطالب بمواد أو يقبل وظائف\n'
        '  🏠 مورد — "اشترِ وأوصل": يشتري المواد المعروضة\n'
        '  ♻️ شركة — "استلم في منشأتك": تستقبل المواد وتنشر وظائف',
    followUpIds: ['market_listings', 'market_collection_jobs', 'market_roles'],
  ),
  DawaEntry(
    id: 'market_roles',
    keywords: [
      'دور في السوق', 'صلاحيات السوق', 'ماذا يفعل السائق في السوق',
      'ماذا يفعل المورد في السوق', 'ماذا تفعل الشركة في السوق',
    ],
    response:
        'صلاحيات كل دور في السوق:\n\n'
        '🚚 السائق:\n'
        '  • يطالب بعروض المواد ليأخذها ويبيعها\n'
        '  • يقبل وظائف التجميع من شركات التدوير\n\n'
        '🏠 المورد:\n'
        '  • يشتري المواد المعروضة (بالاستلام الذاتي أو تعيين سائق)\n\n'
        '♻️ شركة التدوير:\n'
        '  • تستلم المواد مباشرة في منشأتها\n'
        '  • تنشر وظائف تجميع وتحدد السعر ونموذج الدفع',
    followUpIds: [
      'market_listings',
      'market_buy_item',
      'market_claim_item',
      'market_collection_jobs',
    ],
  ),
  DawaEntry(
    id: 'market_listings',
    keywords: [
      'عروض السوق', 'المواد المعروضة', 'قائمة المواد', 'ما المعروض',
      'تصفح السوق', 'market listings', 'browse market',
    ],
    response:
        'قسم العروض في السوق:\n\n'
        '• يعرض المواد المتاحة بحالة "قيد الانتظار" فقط\n'
        '• كل عرض يحتوي: نوع المادة، البائع، الموقع، السعر، فئة الوزن\n'
        '• يمكن البحث بالنص أو التصفية بفئة النفايات\n'
        '• اضغط أي عرض لرؤية تفاصيله الكاملة والصور\n\n'
        'تُحدَّث القائمة تلقائياً عند أي تغيير.',
    followUpIds: [
      'market_search',
      'market_categories',
      'market_item_details',
      'market_buy_item',
    ],
  ),
  DawaEntry(
    id: 'market_search',
    keywords: [
      'بحث في السوق', 'ابحث عن مادة', 'فلترة السوق', 'تصفية المواد',
      'search market', 'filter market', 'ابحث بالمنطقة',
    ],
    response:
        'البحث والتصفية في السوق:\n\n'
        '🔍 شريط البحث:\n'
        '  • اسم المادة (مثل: ورق، معادن)\n'
        '  • اسم البائع\n'
        '  • العنوان أو المنطقة\n'
        '  • الملاحظات في الإعلان\n\n'
        '🏷️ شريط الفئات:\n'
        '  • مرر أفقياً واختر فئة\n'
        '  • اضغط مرة ثانية لإلغاء التصفية\n\n'
        'النتائج تتحدث فورياً أثناء الكتابة.',
    followUpIds: ['market_categories', 'market_listings'],
  ),
  DawaEntry(
    id: 'market_categories',
    keywords: [
      'فئات السوق', 'أنواع مواد السوق', 'تصنيفات السوق',
      'ورق بلاستيك معادن زجاج إلكترونيات', 'waste categories market',
    ],
    response:
        'فئات المواد في السوق (15 فئة):\n\n'
        'ورق | بلاستيك | معادن | زجاج | إلكترونيات\n'
        'عضوي | أقمشة | خشب | مطاط | زيوت\n'
        'كيميائيات | بطاريات | أثاث | إطارات | مخلفات بناء\n\n'
        'كل فئة لها أيقونة مميزة في شريط الفلترة.\n'
        'يمكن اختيار فئة واحدة فقط في كل مرة.',
    followUpIds: ['market_search', 'market_listings', 'market_weight_category'],
  ),
  DawaEntry(
    id: 'market_item_details',
    keywords: [
      'تفاصيل العرض', 'صفحة العرض', 'معلومات المادة', 'عرض تفاصيل',
      'item details', 'listing details',
    ],
    response:
        'صفحة تفاصيل العرض تعرض:\n\n'
        '• أنواع النفايات المعروضة\n'
        '• اسم البائع والموقع\n'
        '• السعر (د.أ)\n'
        '• فئة الوزن (خفيف / متوسط / ثقيل / ثقيل جداً)\n'
        '• شكل النفايات (صلب / سائل / مختلط)\n'
        '• صور المادة (إذا أُضيفت)\n'
        '• ملاحظات البائع\n\n'
        'تجد أزرار الشراء أو الاستلام حسب دورك.',
    followUpIds: [
      'market_buy_item',
      'market_claim_item',
      'market_waste_form',
      'market_weight_category',
    ],
  ),
  DawaEntry(
    id: 'market_buy_item',
    keywords: [
      'شراء مادة', 'اشترِ من السوق', 'كيف أشتري', 'شراء عرض',
      'buy listing', 'purchase item', 'مورد يشتري',
    ],
    response:
        'كمورّد: كيف تشتري مادة من السوق\n\n'
        '1. افتح تفاصيل العرض\n'
        '2. اضغط "شراء"\n'
        '3. اختر طريقة الاستلام:\n'
        '   • استلام ذاتي: تجلب المادة بنفسك (بدون رسوم توصيل)\n'
        '   • تعيين سائق: سائق يوصلها إليك (+ رسوم توصيل)\n'
        '4. أدخل عنوان التوصيل (إذا اخترت سائقاً)\n'
        '5. اضغط تأكيد\n\n'
        'بعد التأكيد تنشأ طلبية جديدة وتُحوَّل لصفحة الطلبات.',
    followUpIds: ['market_delivery_fee', 'market_item_price', 'market_listings'],
  ),
  DawaEntry(
    id: 'market_claim_item',
    keywords: [
      'مطالبة بعرض', 'يستلم السائق', 'السائق يشتري', 'claim item',
      'driver claim', 'استلام مباشر من السوق',
    ],
    response:
        'كسائق: كيف تطالب بمادة من السوق\n\n'
        '1. افتح تفاصيل العرض\n'
        '2. اضغط "استلام"\n'
        '3. تُنشأ طلبية جديدة مرتبطة بالعرض\n'
        '4. توجّه لموقع البائع لاستلام المادة\n'
        '5. أوصلها للشركة المحددة وأتمّ الطلب\n\n'
        '⚠️ لا يمكن المطالبة بعرض إذا كان لديك طلب نشط آخر.',
    followUpIds: [
      'driver_single_order_rule',
      'market_listings',
      'market_collection_jobs',
    ],
  ),
];
