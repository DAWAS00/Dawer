import '../../models/dawa_entry.dart';

/// Knowledge-base entries: Google ML Kit features + per-waste-type ML responses.
const List<DawaEntry> kMlKitEntries = [
  // ── Google ML Kit ─────────────────────────────────────────────
  DawaEntry(
    id: 'ml_waste_scan',
    keywords: [
      'مسح صورة', 'تحديد النوع', 'صورة النفايات', 'الذكاء الاصطناعي',
      'scan waste', 'image recognition', 'ml kit', 'photo classify',
    ],
    response:
        'ميزة مسح النفايات بالكاميرا 📸\n\n'
        'باستخدام Google ML Kit يمكنك:\n'
        '• التقاط صورة لنفاياتك\n'
        '• سيحدد التطبيق النوع تلقائياً (بلاستيك، معادن، زجاج...)\n'
        '• يُضاف النوع مسبقاً في نموذج الطلب\n\n'
        'هذا يسرّع إرسال الطلب ويقلل الأخطاء.',
    followUpIds: ['how_to_post_request', 'waste_types', 'ml_proof_validation'],
    mlLabel: 'general_waste',
  ),
  DawaEntry(
    id: 'ml_proof_validation',
    keywords: [
      'التحقق من الصورة', 'صورة إثبات', 'تحقق صورة', 'proof validation',
      'verify photo', 'image check',
    ],
    response:
        'التحقق من صورة الإثبات 🔍\n\n'
        'عند رفع صورة إتمام الطلب:\n'
        '• يتحقق النظام تلقائياً أن الصورة تحتوي على مواد نفايات\n'
        '• يمنع رفع صور لا علاقة لها بالتسليم\n'
        '• يحمي الموردين وشركات التدوير من إتمام وهمي\n\n'
        'إذا رُفضت الصورة: التقط صورة واضحة للنفايات في موقع الشركة.',
    followUpIds: ['driver_complete_order', 'ml_waste_scan'],
  ),
  DawaEntry(
    id: 'ml_kyc_scan',
    keywords: [
      'مسح الهوية', 'التحقق من الهوية', 'قراءة الوثائق', 'kyc',
      'id scan', 'document scan', 'identity verification',
    ],
    response:
        'مسح وثائق التسجيل (KYC) 🪪\n\n'
        'عند التسجيل:\n'
        '• صوّر هويتك الوطنية أو سجلك التجاري\n'
        '• يستخرج النظام البيانات تلقائياً (الاسم، الرقم، تاريخ الانتهاء)\n'
        '• يملأ حقول التسجيل لك تلقائياً\n\n'
        'الوثائق تُستخدم للتحقق فقط ولا تُشارك.',
    followUpIds: ['how_to_register', 'driver_signup'],
  ),
  DawaEntry(
    id: 'ml_face_verify',
    keywords: [
      'التعرف على الوجه', 'تحقق الوجه', 'صورة السائق', 'مطابقة هوية',
      'face recognition', 'face verify', 'selfie', 'identity match',
    ],
    response:
        'التحقق بالوجه للسائقين 🤳\n\n'
        'لضمان أن السائق هو نفسه المسجل:\n'
        '• يلتقط السائق سيلفي عند تسجيل الدخول\n'
        '• يقارن النظام الوجه بصورة الهوية المرفوعة\n'
        '• إذا تطابقا: يُفعّل الحساب\n'
        '• إذا لم يتطابقا: يُطلب إعادة التحقق\n\n'
        'هذا يحمي الموردين ويضمن موثوقية السائقين.',
    followUpIds: ['driver_signup', 'how_to_register'],
  ),

  // ── Waste type ML entries ─────────────────────────────────────
  DawaEntry(
    id: 'ml_plastic',
    keywords: ['بلاستيك', 'plastic', 'زجاجة بلاستيكية', 'كيس'],
    response:
        '🔍 تم التعرف على: بلاستيك\n\n'
        'سعر: 0.03 د.أ/كغ | نقاط: 2 نقطة/كغ\n\n'
        'هل تريد إضافة البلاستيك إلى طلبك؟',
    followUpIds: ['how_to_post_request', 'waste_types', 'material_rates'],
    mlLabel: 'plastic',
  ),
  DawaEntry(
    id: 'ml_metal',
    keywords: ['معادن', 'حديد', 'ألمنيوم', 'metal', 'iron', 'aluminium'],
    response:
        '🔍 تم التعرف على: معادن\n\n'
        'سعر: 0.07 د.أ/كغ | نقاط: 3 نقطة/كغ\n\n'
        'هل تريد إضافة المعادن إلى طلبك؟',
    followUpIds: ['how_to_post_request', 'waste_types', 'material_rates'],
    mlLabel: 'metal',
  ),
  DawaEntry(
    id: 'ml_electronics',
    keywords: ['إلكترونيات', 'جهاز', 'هاتف قديم', 'electronics', 'device'],
    response:
        '🔍 تم التعرف على: إلكترونيات\n\n'
        'سعر: 0.10 د.أ/كغ | نقاط: 5 نقطة/كغ\n\n'
        'الإلكترونيات تحمل أعلى قيمة تدوير!\n'
        'هل تريد إضافتها إلى طلبك؟',
    followUpIds: ['how_to_post_request', 'waste_types', 'material_rates'],
    mlLabel: 'electronics',
  ),
  DawaEntry(
    id: 'ml_oil',
    keywords: ['زيت', 'زيت مستعمل', 'دهون', 'oil', 'used oil', 'grease'],
    response:
        '🔍 تم التعرف على: زيت مستعمل\n\n'
        'سعر: 0.05 د.أ/لتر\n\n'
        'تنبيه: الزيت المستعمل من أكثر المواد الخطرة على البيئة.\n'
        'يُنصح بالإرسال كطلب عاجل.\n'
        'هل تريد إضافة الزيت إلى طلبك؟',
    followUpIds: ['how_to_post_request', 'urgency_pricing', 'material_rates'],
    mlLabel: 'oil',
  ),
  DawaEntry(
    id: 'ml_glass',
    keywords: ['زجاج', 'قزاز', 'glass', 'bottle'],
    response:
        '🔍 تم التعرف على: زجاج\n\n'
        'سعر: 0.02 د.أ/كغ | نقاط: 1 نقطة/كغ\n\n'
        'هل تريد إضافة الزجاج إلى طلبك؟',
    followUpIds: ['how_to_post_request', 'waste_types'],
    mlLabel: 'glass',
  ),
];
