import '../../models/dawa_entry.dart';

/// Knowledge-base entries: Marketplace meta (weight category, waste form,
/// minimum quantity, linked sale, delivery fee, item price).
const List<DawaEntry> kMarketplaceMetaEntries = [
  DawaEntry(
    id: 'market_weight_category',
    keywords: [
      'فئة الوزن', 'خفيف ثقيل متوسط', 'وزن المادة',
      'weight category', 'light heavy medium',
    ],
    response:
        'فئات الوزن في عروض السوق:\n\n'
        '🪶 خفيف — أقل من 5 كغ\n'
        '⚖️ متوسط — 5 إلى 20 كغ\n'
        '🏋️ ثقيل — 20 إلى 100 كغ\n'
        '🪨 ثقيل جداً — أكثر من 100 كغ\n\n'
        'تُساعد هذه الفئات السائق في اختيار المركبة المناسبة.',
    followUpIds: ['market_item_details', 'market_waste_form'],
  ),
  DawaEntry(
    id: 'market_waste_form',
    keywords: [
      'شكل النفايات', 'صلب سائل مختلط', 'حالة المادة',
      'waste form', 'solid liquid mixed',
    ],
    response:
        'أشكال النفايات في عروض السوق:\n\n'
        '🧱 صلب — مواد صلبة (معادن، بلاستيك، خشب...)\n'
        '💧 سائل — مواد سائلة (زيوت، كيميائيات...)\n'
        '🔀 مختلط — مزيج من الأشكال\n\n'
        'الشكل يظهر في تفاصيل العرض ويساعد في تحديد طريقة النقل.',
    followUpIds: ['market_weight_category', 'market_item_details'],
  ),
  DawaEntry(
    id: 'market_min_quantity',
    keywords: [
      'الحد الأدنى للكمية', 'حد أدنى كيلو', 'minimum quantity',
      'min kg', 'أقل كمية', 'كمية مطلوبة',
    ],
    response:
        'الحد الأدنى للكمية في وظائف التجميع:\n\n'
        '• بعض الوظائف تشترط كمية دنيا بالكيلوغرام\n'
        '• مثال: "لا تقل عن 30 كغ لكل رحلة"\n'
        '• يظهر في تفاصيل الوظيفة كـ "الحد الأدنى"\n'
        '• إذا لم يُحدد فلا يوجد شرط للكمية\n\n'
        'تحقق من كميتك قبل قبول الوظيفة لتجنب الرفض.',
    followUpIds: ['market_collection_jobs', 'market_payment_model'],
  ),
  DawaEntry(
    id: 'market_linked_sale',
    keywords: [
      'التزام بوظيفة', 'collectionSale', 'ارتباط بوظيفة', 'وظيفة مقبولة',
      'accepted job', 'commit collection', 'collection commitment',
    ],
    response:
        'بعد قبول وظيفة تجميع:\n\n'
        '• يُنشأ "سجل التزام" (collectionSale) مرتبط بالوظيفة\n'
        '• يظهر في "طلباتي" كطلب من نوع تجميع\n'
        '• يمر بنفس مراحل الطلب العادي: قيد الانتظار ← في الطريق ← مكتمل\n'
        '• لا يمكن قبول نفس الوظيفة مرتين\n\n'
        'يمكن رؤية آخر التزام لك في قسم وظائف التجميع بصفحتك.',
    followUpIds: ['market_accept_job', 'order_status_meanings'],
  ),
  DawaEntry(
    id: 'market_delivery_fee',
    keywords: [
      'رسوم توصيل السوق', 'تكلفة التوصيل', 'delivery fee market',
      'سعر التوصيل', 'كم رسوم التوصيل',
    ],
    response:
        'رسوم التوصيل في السوق:\n\n'
        '🛒 عند شراء عرض:\n'
        '  • استلام ذاتي: بدون رسوم\n'
        '  • تعيين سائق: تُضاف رسوم التوصيل للسعر الإجمالي\n\n'
        '📦 عند قبول وظيفة تجميع:\n'
        '  • بيع للشركة: رسوم التوصيل على المورد/السائق\n'
        '  • تبرع للشركة: رسوم التوصيل على الشركة (مجاناً للمورد)',
    followUpIds: ['market_buy_item', 'market_transaction_type'],
  ),
  DawaEntry(
    id: 'market_item_price',
    keywords: [
      'سعر المادة في السوق', 'كم سعر العرض', 'itemPrice', 'price per kg',
      'تسعير السوق', 'سعر الكيلو في السوق',
    ],
    response:
        'تسعير عروض السوق:\n\n'
        '💵 سعر ثابت للعرض (itemPrice):\n'
        '  سعر محدد للمادة بالكامل (د.أ)\n\n'
        '⚖️ سعر لكل كيلوغرام (pricePerKg):\n'
        '  المبلغ = السعر × الوزن الفعلي بالكيلوغرام\n\n'
        'كلا النوعين يظهران في تفاصيل العرض أو الوظيفة.',
    followUpIds: ['market_payment_model', 'market_item_details'],
  ),
];
