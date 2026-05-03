import '../../../core/utils/arabic_text_utils.dart';

/// A single knowledge-base entry the Dawa chatbot can return.
class DawaEntry {
  final String id;
  final List<String> keywords;
  final String response;
  final List<String> followUpIds;

  /// Optional ML Kit metadata — if this entry was triggered by an image
  /// analysis result, this field carries the detected label (e.g. 'plastic').
  final String? mlLabel;

  const DawaEntry({
    required this.id,
    required this.keywords,
    required this.response,
    this.followUpIds = const [],
    this.mlLabel,
  });
}

/// Static keyword-based chatbot service for the Dawer (دوّر) platform.
///
/// Architecture mirrors the Faz3a chatbot:
///   - [match] scores user input against every entry's keyword list.
///   - [entryById] provides direct lookup for follow-up chip taps.
///   - [matchFromMlLabel] lets Google ML Kit vision results drive responses.
///
/// Knowledge domains covered:
///   General → Auth → Driver → Supplier → Recycling Company →
///   Order Lifecycle → Pricing → Marketplace → Points → ML Kit
class DawaChatbotService {
  DawaChatbotService._();

  // ──────────────────────────────────────────────
  //  Public API
  // ──────────────────────────────────────────────

  /// Returns the best-matching entry for typed [userInput].
  ///
  /// Enhanced algorithm:
  ///   1. Normalise (Arabic letter unification + tashkeel strip).
  ///   2. Filter stop-words and single-char tokens.
  ///   3. Phrase-level + token-level scoring.
  ///   4. If best score < [_minConfidence], build a contextual fallback
  ///      whose follow-up chips are the top-N closest marketplace entries.
  static DawaEntry match(String userInput) {
    final normalised = _normalise(userInput);
    final tokens = normalised
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2 && !_stopWords.contains(t))
        .toList();

    if (tokens.isEmpty) return _fallbackEntry;

    DawaEntry best = _fallbackEntry;
    int bestScore = 0;

    for (final entry in _entries) {
      final s = _score(tokens, entry);
      if (s > bestScore) {
        bestScore = s;
        best = entry;
      }
    }

    // Low-confidence → return contextual chips drawn from closest entries
    if (bestScore < _minConfidence) {
      final related = _topMatches(tokens, n: 5, minScore: 1);
      final chipIds = related.isNotEmpty
          ? related.map((e) => e.id).toList()
          : List<String>.from(_marketplaceFallbackIds);
      return DawaEntry(
        id: 'fallback_contextual',
        keywords: const [],
        response:
            'لم أجد إجابة مباشرة لسؤالك، لكن ربما تقصد أحد هذه المواضيع:\n'
            'اضغط على أي موضوع للحصول على الإجابة الكاملة.',
        followUpIds: chipIds,
      );
    }

    return best;
  }

  /// Look up an entry by its [id]. Returns the fallback entry if not found.
  static DawaEntry entryById(String id) {
    return _entries.firstWhere(
      (e) => e.id == id,
      orElse: () => _fallbackEntry,
    );
  }

  /// The greeting entry shown when the chat first opens.
  static DawaEntry get greeting => entryById('greeting');

  /// Called after Google ML Kit classifies a recycling image.
  ///
  /// Routes the two primary scan categories ('oil', 'wood') to the detailed
  /// recycling knowledge entries. All other labels fall back to keyword match.
  static DawaEntry matchFromMlLabel(String mlLabel) {
    final normalised = mlLabel.toLowerCase().trim();
    // Preferred: detailed recycling entries for the two supported materials
    if (normalised == 'oil')  return entryById('recycle_oil');
    if (normalised == 'wood') return entryById('recycle_wood');
    // Fall back to mlLabel-tagged entries (plastic, metal, glass…)
    final byLabel = _entries.where((e) => e.mlLabel == normalised).toList();
    if (byLabel.isNotEmpty) return byLabel.first;
    return match(mlLabel);
  }

  // ──────────────────────────────────────────────
  //  Scoring algorithm
  // ──────────────────────────────────────────────

  /// Minimum score required to accept an entry as a confident answer.
  static const int _minConfidence = 3;

  /// Score [tokens] (already normalised) against one [entry].
  ///
  /// Weights:
  ///   • Full multi-word phrase match in input  → 5 × phrase length
  ///   • Exact single token == keyword          → 4
  ///   • Keyword is substring of token (≥3 ch)  → 2
  ///   • Token is substring of keyword (≥3 ch)  → 2
  static int _score(List<String> tokens, DawaEntry entry) {
    if (tokens.isEmpty) return 0;
    int total = 0;
    final inputPhrase = tokens.join(' ');

    for (final kw in entry.keywords) {
      final kwNorm = _normalise(kw);
      if (kwNorm.isEmpty) continue;
      final kwTokens = kwNorm
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty)
          .toList();

      // Full phrase match (highest priority, catches multi-word keywords)
      if (kwTokens.length > 1 && inputPhrase.contains(kwNorm)) {
        total += kwTokens.length * 5;
        continue;
      }

      for (final tok in tokens) {
        if (tok.length < 2) continue;
        if (tok == kwNorm) {
          total += 4; // exact match
        } else if (kwNorm.contains(tok) && tok.length >= 3) {
          total += 2; // input token found inside keyword
        } else if (tok.contains(kwNorm) && kwNorm.length >= 3) {
          total += 2; // keyword found inside input token
        }
      }
    }
    return total;
  }

  /// Returns up to [n] entries with the highest scores, all >= [minScore].
  static List<DawaEntry> _topMatches(
    List<String> tokens, {
    int n = 5,
    int minScore = 1,
  }) {
    final scored = <MapEntry<DawaEntry, int>>[];
    for (final entry in _entries) {
      final s = _score(tokens, entry);
      if (s >= minScore) scored.add(MapEntry(entry, s));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(n).map((e) => e.key).toList();
  }

  /// Normalise Arabic text:
  ///   • Strip tashkeel (diacritics) and tatweel
  ///   • Unify alef forms  (أ إ آ → ا)
  ///   • Taa marbuta → ha  (ة → ه)
  ///   • Alef maqsoura → ya (ى → ي)
  ///   • Remove non-word, non-Arabic chars
  ///   • Lowercase + trim
  static String _normalise(String input) {
    return ArabicTextUtils.normalize(input)
        .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '') // keep Arabic + alnum
        .toLowerCase()
        .trim();
  }

  // ──────────────────────────────────────────────
  //  Stop-words (filtered before scoring)
  // ──────────────────────────────────────────────

  /// Common Arabic + English words that carry no domain meaning.
  static const _stopWords = {
    'في', 'من', 'على', 'عن', 'إلى', 'الى', 'ان', 'أن',
    'هل', 'كيف', 'ما', 'ماذا', 'لماذا', 'متى',
    'هذا', 'هذه', 'ذلك', 'تلك', 'هو', 'هي', 'هم',
    'و', 'أو', 'او', 'لكن', 'لا', 'لم', 'لن', 'قد',
    'يمكن', 'اريد', 'أريد', 'ابغى', 'ابي', 'أبي',
    'the', 'a', 'an', 'is', 'in', 'on', 'at', 'to',
    'of', 'for', 'and', 'or', 'how', 'what', 'where',
  };

  // ──────────────────────────────────────────────
  //  Marketplace fallback chips
  // ──────────────────────────────────────────────

  /// Default chips shown when the bot has no confident match.
  /// Deliberately marketplace-first so the chatbot steers users
  /// toward the core marketplace workflow.
  static const _marketplaceFallbackIds = [
    'marketplace',
    'market_listings',
    'market_collection_jobs',
    'market_roles',
    'market_search',
  ];

  // ──────────────────────────────────────────────
  //  Fallback
  // ──────────────────────────────────────────────

  static const _fallbackEntry = DawaEntry(
    id: 'fallback',
    keywords: [],
    response:
        'عذراً، لم أستطع فهم سؤالك.\n'
        'إليك أبرز مواضيع السوق — اضغط لتصفح أي منها:',
    followUpIds: [
      'marketplace',
      'market_listings',
      'market_collection_jobs',
      'market_accept_job',
      'market_search',
    ],
  );

  // ──────────────────────────────────────────────
  //  Knowledge base
  // ──────────────────────────────────────────────

  static final List<DawaEntry> _entries = [

    // ── General ───────────────────────────────────────────────────
    const DawaEntry(
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

    const DawaEntry(
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

    const DawaEntry(
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
    const DawaEntry(
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
      followUpIds: [
        'driver_signup',
        'supplier_signup',
        'company_signup',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'driver_earnings',
        'how_to_accept_order',
      ],
    ),

    const DawaEntry(
      id: 'supplier_signup',
      keywords: [
        'تسجيل مورد', 'اشتراك مورد', 'مورد فردي', 'مورد متجر',
        'supplier register', 'supplier signup',
      ],
      response:
          'للتسجيل كمورد:\n\n'
          '🏠 مورد فردي: الاسم، الجنسية، صورة شخصية، هوية وطنية\n\n'
          '🏪 مورد متجر/مطعم: اسم الجهة، اسم المالك/المدير، منطقة التغطية، شعار، سجل تجاري',
      followUpIds: [
        'how_to_post_request',
        'points_system',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'company_overview',
        'post_collection_job',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'how_to_register',
      ],
    ),

    // ── Supplier ──────────────────────────────────────────────────
    const DawaEntry(
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
      followUpIds: [
        'waste_types',
        'track_order',
        'cancel_order',
        'points_system',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'order_status_meanings',
        'cancel_order',
        'rate_driver',
      ],
    ),

    const DawaEntry(
      id: 'cancel_order',
      keywords: [
        'إلغاء طلب', 'الغاء', 'تراجع عن الطلب', 'cancel order', 'cancel request',
      ],
      response:
          'لإلغاء طلب:\n'
          '• يمكنك الإلغاء في أي وقت قبل أن يبدأ السائق بالتحرك ("في الطريق")\n'
          '• اذهب إلى "طلباتي" ← افتح الطلب ← اضغط "إلغاء"\n\n'
          '⚠️ بعد دخول الطلب مرحلة "في الطريق" لا يمكن الإلغاء إلا بالتواصل مع الدعم.',
      followUpIds: [
        'track_order',
        'how_to_post_request',
        'support',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'how_to_post_request',
        'waste_types',
      ],
    ),

    // ── Driver ────────────────────────────────────────────────────
    const DawaEntry(
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

    const DawaEntry(
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

    const DawaEntry(
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

    const DawaEntry(
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

    const DawaEntry(
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
      followUpIds: [
        'driver_complete_order',
        'how_to_accept_order',
      ],
    ),

    // ── Order Status ──────────────────────────────────────────────
    const DawaEntry(
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
      followUpIds: [
        'track_order',
        'cancel_order',
        'how_to_post_request',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'track_order',
        'cancel_order',
      ],
    ),

    // ── Pricing ───────────────────────────────────────────────────
    const DawaEntry(
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
      followUpIds: [
        'material_rates',
        'urgency_pricing',
        'driver_earnings',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'pricing_overview',
        'waste_types',
        'driver_earnings',
      ],
    ),

    const DawaEntry(
      id: 'urgency_pricing',
      keywords: [
        'عاجل', 'أولوية', 'طلب عاجل', 'urgent', 'priority',
      ],
      response:
          'الطلب العاجل (عاجل):\n\n'
          '• المورد يُحدده عند إرسال الطلب\n'
          '• يمنح الطلب أولوية في قائمة السائقين القريبين\n'
          '• يُضيف +0.50 د.أ للمكافأة تلقائياً\n'
          '• المورد لا يدفع إضافياً — المنصة تتحمل الفرق\n\n'
          'مفيد جداً للزيت المستعمل الذي قد يُسبب مشاكل إذا تُرك طويلاً.',
      followUpIds: [
        'how_to_post_request',
        'pricing_overview',
        'material_rates',
      ],
    ),

    // ── Waste Types ───────────────────────────────────────────────
    const DawaEntry(
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
      followUpIds: [
        'how_to_post_request',
        'material_rates',
        'ml_waste_scan',
      ],
    ),

    // ── Recycling Company ─────────────────────────────────────────
    const DawaEntry(
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
      followUpIds: [
        'post_collection_job',
        'company_stats',
        'company_signup',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'company_overview',
        'company_stats',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'company_overview',
        'post_collection_job',
      ],
    ),

    // ── Marketplace ───────────────────────────────────────────────
    const DawaEntry(
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
      followUpIds: [
        'market_listings',
        'market_collection_jobs',
        'market_roles',
      ],
    ),

    const DawaEntry(
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

    const DawaEntry(
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

    const DawaEntry(
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
      followUpIds: [
        'market_categories',
        'market_listings',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'market_search',
        'market_listings',
        'market_weight_category',
      ],
    ),

    const DawaEntry(
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

    const DawaEntry(
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
      followUpIds: [
        'market_delivery_fee',
        'market_item_price',
        'market_listings',
      ],
    ),

    const DawaEntry(
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

    const DawaEntry(
      id: 'market_collection_jobs',
      keywords: [
        'وظائف التجميع', 'collection jobs', 'وظيفة من شركة',
        'طلب شركة تدوير', 'وظائف السوق', 'jobs marketplace',
      ],
      response:
          'وظائف التجميع في السوق:\n\n'
          '• تنشرها شركات التدوير في القسم الثاني من السوق\n'
          '• تحدد: المادة المطلوبة، المنطقة، السعر، الحد الأدنى للكمية\n'
          '• تظهر للجميع لكن قبولها يختلف بالدور:\n'
          '  🚚 سائق: يضغط "قبول الوظيفة" مباشرة\n'
          '  🏠 مورد: يضغط "عرض التفاصيل" ثم يختار طريقة التسليم\n\n'
          '💡 وظيفة بعلامة "معدّل" تعني تعديل الشركة لشروطها.',
      followUpIds: [
        'market_accept_job',
        'market_payment_model',
        'market_post_job',
        'market_min_quantity',
      ],
    ),

    const DawaEntry(
      id: 'market_accept_job',
      keywords: [
        'قبول وظيفة تجميع', 'كيف أقبل وظيفة', 'قبول جوب',
        'accept collection job', 'commit to job', 'تأكيد وظيفة',
      ],
      response:
          'لقبول وظيفة تجميع:\n\n'
          '1. افتح تفاصيل الوظيفة\n'
          '2. اختر طريقة التوصيل:\n'
          '   • أوصّل بنفسي: تحضر المواد بنفسك للشركة\n'
          '   • أعيّن سائقاً: سائق دوّر ينقل المواد\n'
          '3. اختر نوع المعاملة:\n'
          '   • بيع للشركة: تحصل على المبلغ المتفق، ورسوم التوصيل عليك\n'
          '   • تبرع للشركة: رسوم التوصيل على الشركة، بدون مقابل\n'
          '4. اضغط تأكيد\n\n'
          '⚠️ لا يمكن قبول نفس الوظيفة مرتين.',
      followUpIds: [
        'market_delivery_method',
        'market_transaction_type',
        'market_payment_model',
        'market_linked_sale',
      ],
    ),

    const DawaEntry(
      id: 'market_payment_model',
      keywords: [
        'نموذج الدفع', 'دفع بالكيلو', 'أجر ثابت', 'per kg', 'flat fee',
        'سعر الكيلو', 'تسعير الوظيفة',
      ],
      response:
          'نماذج الدفع في وظائف التجميع:\n\n'
          '⚖️ لكل كيلوغرام (د.أ / كغ):\n'
          '  تحصل على مبلغ محدد عن كل كيلوغرام تسلّمه.\n'
          '  مثال: 0.08 د.أ/كغ × 50 كغ = 4 د.أ\n\n'
          '💵 أجر ثابت (د.أ):\n'
          '  مبلغ محدد مسبقاً بغض النظر عن الكمية.\n'
          '  مثال: 5 د.أ لكل رحلة تجميع\n\n'
          'نموذج الدفع يظهر واضحاً في تفاصيل الوظيفة.',
      followUpIds: [
        'market_transaction_type',
        'market_min_quantity',
        'market_collection_jobs',
      ],
    ),

    const DawaEntry(
      id: 'market_delivery_method',
      keywords: [
        'طريقة التوصيل', 'أوصل بنفسي', 'سائق للتوصيل', 'self delivery',
        'assign rider', 'كيف أوصل المواد',
      ],
      response:
          'طرق التوصيل عند قبول وظيفة تجميع:\n\n'
          '🚗 أوصّل بنفسي (selfDelivery):\n'
          '  تحضر المواد بمركبتك مباشرة لموقع الشركة.\n'
          '  ملاحظة: رسوم التوصيل على حسابك إذا اخترت البيع.\n\n'
          '🚚 أعيّن سائقاً (assignRider):\n'
          '  يتم تعيين سائق من دوّر لنقل المواد عنك.\n'
          '  مفيد إذا لم يكن لديك مركبة مناسبة.',
      followUpIds: [
        'market_transaction_type',
        'market_accept_job',
      ],
    ),

    const DawaEntry(
      id: 'market_transaction_type',
      keywords: [
        'بيع أو تبرع', 'نوع المعاملة', 'donate sell', 'transaction type',
        'تبرع بالمواد', 'بيع للشركة', 'مجاناً للشركة',
      ],
      response:
          'نوعا المعاملة في وظائف التجميع:\n\n'
          '💚 تبرع للشركة (donate):\n'
          '  • رسوم التوصيل تتحملها الشركة\n'
          '  • لا تحصل على مبلغ مالي مقابل المادة\n'
          '  • مثالي إذا أردت التخلص من المواد مجاناً\n\n'
          '💰 بيع للشركة (sell):\n'
          '  • رسوم التوصيل عليك\n'
          '  • تحصل على المبلغ المتفق عليه (حسب نموذج الدفع)\n'
          '  • مثالي إذا أردت تحقيق دخل من مواد النفايات',
      followUpIds: [
        'market_delivery_method',
        'market_payment_model',
        'market_accept_job',
      ],
    ),

    const DawaEntry(
      id: 'market_post_job',
      keywords: [
        'نشر وظيفة تجميع', 'كيف تنشر الشركة وظيفة', 'إنشاء وظيفة',
        'post collection job marketplace', 'add job market',
      ],
      response:
          'كشركة تدوير: كيف تنشر وظيفة تجميع\n\n'
          '1. اذهب إلى السوق ← وظائف التجميع\n'
          '2. اضغط "نشر وظيفة جديدة"\n'
          '3. حدد:\n'
          '   • أنواع النفايات المطلوبة (متعددة)\n'
          '   • منطقة التجميع (مطلوبة)\n'
          '   • وصف الوظيفة\n'
          '   • نموذج الدفع: لكل كغ أو أجر ثابت\n'
          '   • السعر\n'
          '   • الحد الأدنى للكمية (اختياري)\n'
          '4. اضغط "نشر"\n\n'
          'ستظهر الوظيفة فوراً للسائقين والموردين في السوق.',
      followUpIds: [
        'market_edit_delete_job',
        'market_payment_model',
        'market_min_quantity',
      ],
    ),

    const DawaEntry(
      id: 'market_edit_delete_job',
      keywords: [
        'تعديل وظيفة', 'حذف وظيفة', 'تغيير شروط وظيفة',
        'edit job', 'delete job', 'تحديث وظيفة', 'وظيفة معدّلة',
      ],
      response:
          'تعديل وحذف وظائف التجميع:\n\n'
          '✏️ تعديل الوظيفة:\n'
          '  • يمكنك تغيير: المادة، المنطقة، السعر، الوصف\n'
          '  • تظهر علامة "معدّل" على الوظيفة بعد التعديل\n'
          '  • يمكن إضافة ملاحظة التعديل\n\n'
          '🗑️ حذف الوظيفة:\n'
          '  • فقط إذا كانت الوظيفة بحالة "قيد الانتظار"\n'
          '  • الوظائف المقبولة لا يمكن حذفها\n\n'
          '⚠️ التعديل والحذف متاحان لصاحب الوظيفة فقط.',
      followUpIds: [
        'market_post_job',
        'market_collection_jobs',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'market_item_details',
        'market_waste_form',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'market_weight_category',
        'market_item_details',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'market_collection_jobs',
        'market_payment_model',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'market_accept_job',
        'order_status_meanings',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'market_buy_item',
        'market_transaction_type',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'market_payment_model',
        'market_item_details',
      ],
    ),

    // ── Bundled sample scan chips ────────────────────────────────

    const DawaEntry(
      id: 'scan_oil_sample',
      keywords: ['عينة الزيت', 'اختبار زيت', 'مسح زيت', 'sample oil'],
      response: '🛢️ تحليل عينة زيت مستعمل',
      followUpIds: ['recycle_oil'],
    ),

    const DawaEntry(
      id: 'scan_wood_sample',
      keywords: ['عينة الخشب', 'اختبار خشب', 'مسح خشب', 'sample wood'],
      response: '🪵 تحليل عينة خشب بناء',
      followUpIds: ['recycle_wood'],
    ),

    // ── Image-scan recycling knowledge ────────────────────────────

    const DawaEntry(
      id: 'recycle_oil',
      keywords: [
        'تدوير الزيت', 'ماذا يحدث بالزيت', 'فائدة تدوير الزيت',
        'زيت مستعمل تدوير', 'oil recycling', 'used oil recycle',
      ],
      response:
          '♻️ تدوير الزيت المستعمل 🛢️\n\n'
          '🔬 ماذا يحدث للزيت بعد التجميع؟\n'
          '1. الترشيح — إزالة الجسيمات الصلبة والماء\n'
          '2. إزالة الرواسب — فصل الشوائب المعدنية الثقيلة\n'
          '3. إعادة التكرير — تقطير تحت ضغط منخفض لاستخلاص زيت القاعدة\n'
          '4. المعالجة بالهيدروجين — تنقية وتحسين الجودة للوصول لمعايير API\n\n'
          '💰 الفائدة الاقتصادية\n'
          '• لتر واحد من الزيت المستعمل → 800 مل زيت محرك معاد تكريره\n'
          '• مقابل ذلك يحتاج نفس الإنتاج 33 لتراً من النفط الخام!\n'
          '• تكلفة إعادة التكرير أقل بـ50٪ من تكرير النفط الخام\n\n'
          '🏭 ماذا يُصنع منه؟\n'
          '• زيوت محرك وتشحيم جديدة (API SN Plus)\n'
          '• زيوت هيدروليكية لآلات البناء والمصانع\n'
          '• زيوت ناقل حركة وعلبة التروس\n'
          '• وقود صناعي ثقيل (HFO) للسفن والمصانع\n'
          '• الإسفلت ومواد رصف الطرق (Asphalt Flux)\n\n'
          '🌱 الأثر البيئي\n'
          '• يمنع تلوث مليون لتر ماء لكل لتر لا يصل للمجاري\n'
          '• يقلل انبعاثات CO₂ بـ85٪ مقارنة بتكرير النفط الخام\n'
          '• يحمي التربة من الرصاص والكادميوم والزرنيخ',
      followUpIds: [
        'how_to_post_request',
        'recycle_wood',
        'market_listings',
        'waste_types',
      ],
      mlLabel: 'oil',
    ),

    const DawaEntry(
      id: 'recycle_wood',
      keywords: [
        'تدوير الخشب', 'خشب بناء', 'ماذا يحدث بالخشب',
        'فائدة تدوير الخشب', 'wood recycling', 'construction wood recycle',
      ],
      response:
          '♻️ تدوير خشب البناء 🪵\n\n'
          '🔬 ماذا يحدث للخشب بعد التجميع؟\n'
          '1. الفرز — تصنيف حسب الحالة والنوع (صنوبر / بلوط / خشب رقائقي)\n'
          '2. التنظيف — إزالة المسامير والمواد اللاصقة والطلاء\n'
          '3. التشريح — تقطيع إلى قطع أصغر قابلة للمعالجة\n'
          '4. الطحن — تحويل إلى نشارة أو رقائق حسب الاستخدام النهائي\n\n'
          '💰 الفائدة الاقتصادية\n'
          '• طن واحد من الخشب المُعاد تدويره = 17 شجرة محمية من القطع\n'
          '• يوفر 60٪ من تكلفة إنتاج الألواح مقارنة بالخشب الطازج\n'
          '• ينتج 2–3 أضعاف كمية المنتجات من نفس الحجم\n\n'
          '🏭 ماذا يُصنع منه؟\n'
          '• ألواح الجسيمات (Particle Board) للأثاث والخزائن\n'
          '• ألواح الألياف MDF للديكور والأبواب الداخلية\n'
          '• نشارة الخشب: فراش حيوانات + تحسين تربة زراعية\n'
          '• حبيبات الوقود الحيوي (Biomass Pellets) للتدفئة\n'
          '• ألواح عازلة للصوت للقاعات والاستوديوهات\n'
          '• أرضيات خشبية معاد تصنيعها (Reclaimed Flooring)\n\n'
          '🌱 الأثر البيئي\n'
          '• كل طن مُعاد تدويره = توفير 1.49 طن CO₂\n'
          '• يقلل النفايات الصلبة في المكبّات بنسبة 30٪\n'
          '• يمنع انبعاث غاز الميثان الناتج عن تحلل الخشب (25× أقوى من CO₂)',
      followUpIds: [
        'how_to_post_request',
        'recycle_oil',
        'market_listings',
        'waste_types',
      ],
      mlLabel: 'wood',
    ),

    // ── Google ML Kit ─────────────────────────────────────────────
    const DawaEntry(
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
      followUpIds: [
        'how_to_post_request',
        'waste_types',
        'ml_proof_validation',
      ],
      mlLabel: 'general_waste',
    ),

    const DawaEntry(
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
      followUpIds: [
        'driver_complete_order',
        'ml_waste_scan',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'how_to_register',
        'driver_signup',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'driver_signup',
        'how_to_register',
      ],
    ),

    // ── Waste type ML entries ─────────────────────────────────────
    const DawaEntry(
      id: 'ml_plastic',
      keywords: ['بلاستيك', 'plastic', 'زجاجة بلاستيكية', 'كيس'],
      response:
          '🔍 تم التعرف على: بلاستيك\n\n'
          'سعر: 0.03 د.أ/كغ | نقاط: 2 نقطة/كغ\n\n'
          'هل تريد إضافة البلاستيك إلى طلبك؟',
      followUpIds: ['how_to_post_request', 'waste_types', 'material_rates'],
      mlLabel: 'plastic',
    ),

    const DawaEntry(
      id: 'ml_metal',
      keywords: ['معادن', 'حديد', 'ألمنيوم', 'metal', 'iron', 'aluminium'],
      response:
          '🔍 تم التعرف على: معادن\n\n'
          'سعر: 0.07 د.أ/كغ | نقاط: 3 نقطة/كغ\n\n'
          'هل تريد إضافة المعادن إلى طلبك؟',
      followUpIds: ['how_to_post_request', 'waste_types', 'material_rates'],
      mlLabel: 'metal',
    ),

    const DawaEntry(
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

    const DawaEntry(
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

    const DawaEntry(
      id: 'ml_glass',
      keywords: ['زجاج', 'قزاز', 'glass', 'bottle'],
      response:
          '🔍 تم التعرف على: زجاج\n\n'
          'سعر: 0.02 د.أ/كغ | نقاط: 1 نقطة/كغ\n\n'
          'هل تريد إضافة الزجاج إلى طلبك؟',
      followUpIds: ['how_to_post_request', 'waste_types'],
      mlLabel: 'glass',
    ),

    // ── Support & General ─────────────────────────────────────────
    const DawaEntry(
      id: 'rate_driver',
      keywords: [
        'تقييم السائق', 'نجوم', 'تقييم', 'rate driver', 'review', 'stars',
      ],
      response:
          'تقييم السائق:\n\n'
          'بعد إتمام الطلب يمكنك تقييم السائق من 1 إلى 5 نجوم.\n'
          'التقييمات تؤثر على ترتيب السائق في قائمة الطلبات المتاحة.\n'
          'سائقو التقييم العالي يُفضَّلون في الطلبات العاجلة.',
      followUpIds: [
        'track_order',
        'driver_complete_order',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'cancel_order',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'what_is_dawer',
        'how_to_register',
      ],
    ),

    const DawaEntry(
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
      followUpIds: [
        'what_is_dawer',
        'points_system',
        'waste_types',
      ],
    ),
  ];
}
