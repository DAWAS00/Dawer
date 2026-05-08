import '../../models/dawa_entry.dart';

/// Knowledge-base entries: General intro + Auth/registration.
const List<DawaEntry> kGeneralAuthEntries = [
  // ── General ───────────────────────────────────────────────────
  DawaEntry(
    id: 'greeting',
    keywords: ['مرحبا', 'أهلا', 'السلام', 'هلا', 'هاي', 'hello', 'hi', 'مرحبً'],
    response:
        'أهلاً بك في سوق دوّر! �\n'
        'أنا مساعدك الذكي للتنقل في السوق وإدارة العروض والوظائف.\n\n'
        'بماذا تحتاج مساعدة؟',
    followUpIds: [
      'marketplace',
      'market_listings',
      'scan_oil_sample',
      'scan_wood_sample',
      'market_roles',
    ],
  ),
  DawaEntry(
    id: 'what_is_dawer',
    keywords: [
      'ما هو دوّر', 'شو دوّر', 'دوّر', 'المنصة', 'عن التطبيق',
      'what is dawer', 'about', 'platform',
    ],
    response:
        'دوّر (Dawer) منصة أردنية للاقتصاد الدائري 🇯🇴\n\n'
        'تربط ثلاثة أطراف:\n'
        '• المورد — يتخلص من نفاياته مجاناً\n'
        '• السائق — يجمع النفايات ويكسب دخلاً\n'
        '• شركة إعادة التدوير — تستقبل شحنات منظمة\n\n'
        'الهدف: تحويل النفايات إلى قيمة اقتصادية وبيئية.',
    followUpIds: [
      'marketplace',
      'market_roles',
      'market_listings',
      'market_collection_jobs',
    ],
  ),
  DawaEntry(
    id: 'user_roles',
    keywords: [
      'أدوار', 'دور', 'نوع المستخدم', 'مورد', 'سائق', 'شركة',
      'roles', 'supplier', 'driver', 'company',
    ],
    response:
        'أنواع المستخدمين في دوّر:\n\n'
        '🏠 مورد فردي — يرسل طلب استلام نفايات من المنزل\n'
        '🏪 مورد متجر — مطعم أو محل يرسل كميات كبيرة\n'
        '🚚 سائق — يقبل الطلبات ويكسب أجراً بالدينار الأردني\n'
        '♻️ شركة إعادة تدوير — تستقبل الشحنات وتنشر وظائف تجميع',
    followUpIds: [
      'market_roles',
      'market_buy_item',
      'market_claim_item',
      'market_accept_job',
    ],
  ),

  // ── Auth ──────────────────────────────────────────────────────
  DawaEntry(
    id: 'how_to_register',
    keywords: [
      'تسجيل', 'حساب جديد', 'كيف أسجل', 'انضمام', 'اشتراك',
      'register', 'sign up', 'create account', 'new account',
    ],
    response:
        'للتسجيل في دوّر:\n'
        '1. افتح التطبيق → شاشة تسجيل الدخول\n'
        '2. اختر دورك (مورد / سائق / شركة)\n'
        '3. اضغط "سجّل الآن"\n'
        '4. أدخل بياناتك ورفع المستندات المطلوبة\n'
        '5. سيتم إنشاء حسابك وتحويلك للصفحة الرئيسية مباشرة',
    followUpIds: ['driver_signup', 'supplier_signup', 'company_signup'],
  ),
  DawaEntry(
    id: 'driver_signup',
    keywords: [
      'تسجيل سائق', 'اشتراك كسائق', 'ماذا يحتاج السائق', 'وثائق السائق',
      'driver register', 'driver signup',
    ],
    response:
        'للتسجيل كسائق تحتاج:\n'
        '• الاسم الكامل\n'
        '• الجنسية (أردني / غير ذلك)\n'
        '• صورة شخصية\n'
        '• صورة الهوية الوطنية\n'
        '• رقم هاتف أو بريد إلكتروني\n\n'
        'الوثائق تُستخدم للتحقق فقط ولا تُشارك مع أحد.',
    followUpIds: ['driver_earnings', 'how_to_accept_order'],
  ),
  DawaEntry(
    id: 'supplier_signup',
    keywords: [
      'تسجيل مورد', 'اشتراك مورد', 'مورد فردي', 'مورد متجر',
      'supplier register', 'supplier signup',
    ],
    response:
        'للتسجيل كمورد:\n\n'
        '🏠 مورد فردي: الاسم، الجنسية، صورة شخصية، هوية وطنية\n\n'
        '🏪 مورد متجر/مطعم: اسم الجهة، اسم المالك/المدير، منطقة التغطية، شعار، سجل تجاري',
    followUpIds: ['how_to_post_request', 'points_system'],
  ),
  DawaEntry(
    id: 'company_signup',
    keywords: [
      'تسجيل شركة', 'شركة إعادة تدوير', 'اشتراك شركة',
      'company register', 'recycling company signup',
    ],
    response:
        'للتسجيل كشركة إعادة تدوير تحتاج:\n'
        '• اسم الشركة\n'
        '• اسم المدير\n'
        '• منطقة التغطية\n'
        '• شعار الشركة\n'
        '• صورة الترخيص التجاري\n'
        '• هاتف أو بريد إلكتروني',
    followUpIds: ['company_overview', 'post_collection_job'],
  ),
  DawaEntry(
    id: 'login_help',
    keywords: [
      'تسجيل دخول', 'دخول', 'لوجن', 'لا أستطيع الدخول',
      'login', 'sign in', 'cant login',
    ],
    response:
        'لتسجيل الدخول:\n'
        '1. اختر دورك من الشاشة الرئيسية\n'
        '2. أدخل بريدك الإلكتروني\n'
        '3. أدخل كلمة المرور\n'
        '4. اضغط "تسجيل الدخول"\n\n'
        '⚠️ يجب اختيار الدور أولاً قبل تفعيل زر الدخول.',
    followUpIds: ['how_to_register'],
  ),
];
