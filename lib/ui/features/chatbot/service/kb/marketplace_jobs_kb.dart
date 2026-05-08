import '../../models/dawa_entry.dart';

/// Knowledge-base entries: Collection jobs (accept, payment, delivery, post, edit).
const List<DawaEntry> kMarketplaceJobsEntries = [
  DawaEntry(
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
  DawaEntry(
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
  DawaEntry(
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
  DawaEntry(
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
    followUpIds: ['market_transaction_type', 'market_accept_job'],
  ),
  DawaEntry(
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
  DawaEntry(
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
  DawaEntry(
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
    followUpIds: ['market_post_job', 'market_collection_jobs'],
  ),
];
