import '../../models/dawa_entry.dart';

/// Knowledge-base entries: Supplier-side actions + Driver workflow.
const List<DawaEntry> kSupplierDriverEntries = [
  // ── Supplier ──────────────────────────────────────────────────
  DawaEntry(
    id: 'how_to_post_request',
    keywords: [
      'كيف أرسل طلب', 'طلب استلام', 'تخلص من النفايات', 'إرسال طلب',
      'post request', 'pickup request', 'new order', 'طلب جديد',
    ],
    response:
        'لإرسال طلب استلام نفايات:\n'
        '1. من الصفحة الرئيسية اضغط "طلب استلام جديد"\n'
        '2. حدد أنواع النفايات (يجب اختيار نوع واحد على الأقل)\n'
        '3. أضف ملاحظات اختيارية\n'
        '4. يمكنك تحديد "عاجل" لتسريع الاستلام (+0.50 د.أ للسائق)\n'
        '5. اضغط "إرسال الطلب"\n\n'
        'ستجد طلبك في قسم "طلباتي" بحالة "قيد الانتظار".',
    followUpIds: ['waste_types', 'track_order', 'cancel_order', 'points_system'],
  ),
  DawaEntry(
    id: 'track_order',
    keywords: [
      'تتبع طلب', 'أين سائقي', 'متى يصل', 'حالة الطلب', 'وصل السائق',
      'track order', 'order status', 'where is driver', 'eta',
    ],
    response:
        'لتتبع طلبك:\n'
        '• بعد قبول سائق لطلبك، تظهر بطاقة التتبع في صفحتك الرئيسية\n'
        '• البطاقة تعرض: اسم السائق، المسافة، وقت الوصول المتوقع\n'
        '• حالات الطلب: قيد الانتظار ← تم القبول ← في الطريق ← مكتمل\n\n'
        'اذهب إلى "طلباتي" لعرض تفاصيل أي طلب.',
    followUpIds: ['order_status_meanings', 'cancel_order', 'rate_driver'],
  ),
  DawaEntry(
    id: 'cancel_order',
    keywords: [
      'إلغاء طلب', 'الغاء', 'تراجع عن الطلب', 'cancel order', 'cancel request',
    ],
    response:
        'لإلغاء طلب:\n'
        '• يمكنك الإلغاء في أي وقت قبل أن يبدأ السائق بالتحرك ("في الطريق")\n'
        '• اذهب إلى "طلباتي" ← افتح الطلب ← اضغط "إلغاء"\n\n'
        '⚠️ بعد دخول الطلب مرحلة "في الطريق" لا يمكن الإلغاء إلا بالتواصل مع الدعم.',
    followUpIds: ['track_order', 'how_to_post_request', 'support'],
  ),
  DawaEntry(
    id: 'points_system',
    keywords: [
      'نقاط', 'مكافآت', 'كيف أكسب نقاطاً', 'استبدال نقاط', 'نقطة',
      'points', 'rewards', 'earn points', 'redeem',
    ],
    response:
        'نظام نقاط إعادة التدوير 🌟\n\n'
        'تكسب نقاطاً بعد كل عملية تسليم مكتملة:\n'
        '• ورق: 1 نقطة/كغ\n'
        '• بلاستيك: 2 نقطة/كغ\n'
        '• معادن: 3 نقطة/كغ\n'
        '• إلكترونيات: 5 نقطة/كغ\n'
        '• زجاج: 1 نقطة/كغ\n\n'
        'استخدام النقاط:\n'
        '• خصومات عند متاجر الشركاء\n'
        '• تبرع لجمعيات خيرية\n'
        '• رصيد خدمات المنصة\n\n'
        'نقاطك تظهر في الشريط الأصفر بأعلى صفحتك الرئيسية.',
    followUpIds: ['how_to_post_request', 'waste_types'],
  ),

  // ── Driver ────────────────────────────────────────────────────
  DawaEntry(
    id: 'driver_earnings',
    keywords: [
      'أرباح', 'دخل', 'كيف أكسب', 'كم أربح', 'أجر', 'مكافأة',
      'earnings', 'income', 'how much earn', 'reward', 'salary',
    ],
    response:
        'كيف يكسب السائق:\n\n'
        'مكافأة كل طلب:\n'
        '1.50 د.أ (أساسية)\n'
        '+ (المسافة × 0.60 د.أ/كم)\n'
        '+ (الوزن × سعر المادة)\n'
        '+ 0.50 د.أ (إضافة عاجل إذا طلبها المورد)\n\n'
        'أمثلة أسعار المواد:\n'
        '• معادن: 0.07 د.أ/كغ\n'
        '• إلكترونيات: 0.10 د.أ/كغ\n'
        '• بلاستيك: 0.03 د.أ/كغ\n\n'
        'المكافأة الكاملة مرئية على بطاقة الطلب قبل القبول.',
    followUpIds: [
      'how_to_accept_order',
      'driver_availability',
      'driver_complete_order',
    ],
  ),
  DawaEntry(
    id: 'how_to_accept_order',
    keywords: [
      'كيف أقبل طلب', 'قبول طلب', 'اقبل الطلب', 'طلبات متاحة',
      'accept order', 'available jobs', 'how to accept',
    ],
    response:
        'لقبول طلب:\n'
        '1. تأكد أنك "متاح" (زر الحالة في أعلى الصفحة)\n'
        '2. شاهد قائمة الطلبات المتاحة بالقرب منك\n'
        '3. كل بطاقة تعرض: نوع النفايات، المنطقة، المسافة، المكافأة\n'
        '4. اضغط "اقبل الطلب" على الطلب المناسب\n\n'
        '⚠️ لا يمكن قبول أكثر من طلب واحد في نفس الوقت.',
    followUpIds: [
      'driver_availability',
      'driver_complete_order',
      'driver_earnings',
    ],
  ),
  DawaEntry(
    id: 'driver_availability',
    keywords: [
      'حالة السائق', 'متاح', 'غير متاح', 'تشغيل التوفر', 'أوفلاين',
      'availability', 'go online', 'go offline', 'toggle',
    ],
    response:
        'زر الحالة (متاح / غير متاح):\n'
        '• متاح ✅ — طلباتك مرئية للموردين، تظهر الطلبات في قائمتك\n'
        '• غير متاح ⛔ — لن تتلقى طلبات جديدة\n\n'
        '⚠️ لا يمكنك التحويل لـ "غير متاح" إذا كان لديك طلب نشط.\n'
        'أكمل طلبك الحالي أولاً.',
    followUpIds: [
      'how_to_accept_order',
      'driver_complete_order',
      'driver_earnings',
    ],
  ),
  DawaEntry(
    id: 'driver_complete_order',
    keywords: [
      'إتمام الطلب', 'اكتمال', 'تسليم', 'صورة إثبات', 'تأكيد التسليم',
      'complete order', 'proof photo', 'finish delivery',
    ],
    response:
        'لإتمام طلب:\n'
        '1. انتقل إلى موقع شركة إعادة التدوير وسلّم النفايات\n'
        '2. التقط صورة إثبات في موقع الشركة\n'
        '3. بعد رفع الصورة يظهر زر "إتمام الطلب"\n'
        '4. اضغطه لتغيير الحالة إلى "مكتمل"\n'
        '5. تُضاف مكافأتك تلقائياً إلى أرباحك\n\n'
        '📸 الصورة مطلوبة — لا يمكن الإتمام بدونها.',
    followUpIds: [
      'driver_earnings',
      'driver_availability',
      'how_to_accept_order',
    ],
  ),
  DawaEntry(
    id: 'driver_single_order_rule',
    keywords: [
      'طلبان', 'أكثر من طلب', 'طلب ثانٍ', 'لديك طلب نشط',
      'two orders', 'multiple orders', 'already have order',
    ],
    response:
        'السائق يستطيع العمل على طلب واحد في نفس الوقت فقط.\n\n'
        'إذا حاولت قبول طلب جديد وعندك طلب نشط:\n'
        'ستظهر رسالة: "لديك طلب نشط بالفعل. أكمل طلبك الحالي أولاً."\n\n'
        'هذا يضمن أن كل مورد يحصل على خدمة موثوقة.',
    followUpIds: ['driver_complete_order', 'how_to_accept_order'],
  ),
];
