// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get chatbotTitle => 'مساعد دوّر الذكي';

  @override
  String get chatbotInputHint => 'اكتب سؤالك أو أرسل صورة...';

  @override
  String get chatbotThinking => 'داوة تفكر...';

  @override
  String get chatbotScanningImage => 'جاري تحليل الصورة...';

  @override
  String get chatbotAnalyzingOil =>
      'جاري تحليل جودة الزيت بالذكاء الاصطناعي...';

  @override
  String get chatbotTakePhoto => 'التقاط صورة بالكاميرا';

  @override
  String get chatbotPickFromGallery => 'اختيار من المعرض';

  @override
  String get chatbotImageScanResult => 'نتيجة تحليل الصورة';

  @override
  String get chatbotOpenAssistant => 'افتح مساعد دوّر';

  @override
  String get chatbotOnlineNow => 'متصل الآن • يرد فوراً';

  @override
  String get chatbotSendImageTooltip => 'إرسال صورة للتحليل';

  @override
  String get appTitle => 'دوّر';

  @override
  String get appTagline => 'حوّل النفايات إلى قيمة';

  @override
  String get appSystemTitle => 'نظام إدارة تدوير النفايات الذكي';

  @override
  String get ok => 'حسناً';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get saveEdits => 'حفظ التعديلات';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get or => 'أو';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get logoutExit => 'خروج';

  @override
  String get alert => 'تنبيه';

  @override
  String get available => 'متاح';

  @override
  String get unavailable => 'غير متاح';

  @override
  String greeting(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMarket => 'السوق';

  @override
  String get navMyOrders => 'طلباتي';

  @override
  String get navProfile => 'الملف';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navAccount => 'حسابي';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePickerTitle => 'اللغة';

  @override
  String get themeTitle => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeAutoFull => 'تلقائي (نظام الهاتف)';

  @override
  String get themeAutoShort => 'تلقائي';

  @override
  String get loginMethodEmail => 'بريد إلكتروني';

  @override
  String get loginMethodPhone => 'رقم الهاتف';

  @override
  String get loginPhoneLabel => 'رقم الهاتف';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginEmailHint => 'example@domain.com';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loginNoAccount => 'ليس لديك حساب؟';

  @override
  String get loginSignUpNow => 'سجّل الآن';

  @override
  String get registerAsDriver => 'سجل كسائق';

  @override
  String get registerAsIndividual => 'سجل كمورد فردي';

  @override
  String get registerAsStore => 'سجل كمتجر / شركة';

  @override
  String get registerAsRecyclingCo => 'سجل كشركة إعادة تدوير';

  @override
  String get loginCountrySearch => 'بحث';

  @override
  String get loginCountrySearchHint => 'ابحث عن الدولة';

  @override
  String get roleSelectTitle => 'اختر نوع الحساب';

  @override
  String get roleDriver => 'سائق';

  @override
  String get roleSupplier => 'مورد';

  @override
  String get roleRecyclingCo => 'شركة إعادة تدوير';

  @override
  String get supplierTypeLabel => 'نوع المورد';

  @override
  String get supplierTypeIndividual => 'فرد';

  @override
  String get supplierTypeStore => 'متجر / مطعم';

  @override
  String get footerTerms => 'شروط الخدمة';

  @override
  String get footerPrivacy => 'سياسة الخصوصية';

  @override
  String get footerInfra => 'DIGITAL INFRASTRUCTURE BY GOVERNMENT';

  @override
  String get footerIdea => 'فكرة من عقول الشباب الأردني';

  @override
  String get footerPolicyOk => 'حسناً، فهمت';

  @override
  String get footerPolicyBody =>
      'هذا النص هو نص تجريبي يوضح الشروط والأحكام وسياسة الخصوصية الخاصة بالتطبيق. سيتم تحديث هذا النص لاحقاً ليعكس السياسات الحقيقية والقانونية المعتمدة.\n\n• يلتزم المستخدم بجميع القوانين والأنظمة المعمول بها.\n• يحق للتطبيق الاحتفاظ ببعض البيانات الأساسية لتحسين الخدمة المقدمة.\n• نحتفظ بالحق في تعديل هذه الشروط في أي وقت مع إشعار المستخدمين.\n• خصوصية بياناتك تهمنا، ولن نقوم بمشاركتها مع أطراف ثالثة دون موافقتك الصريحة.\n• باستخدامك لهذا التطبيق، فإنك توافق على جميع الشروط والأحكام المذكورة هنا.';

  @override
  String get signupTitle => 'إنشاء حساب';

  @override
  String get signupCreateButton => 'إنشاء الحساب';

  @override
  String get signupSubtitle => 'أكمل بياناتك للانضمام إلى منصة دوّر';

  @override
  String get signupSectionBusiness => 'معلومات الجهة';

  @override
  String get signupCompanyName => 'اسم الشركة';

  @override
  String get signupStoreName => 'اسم المتجر / المطعم';

  @override
  String get signupCompanyNameHint => 'شركة البيئة الخضراء';

  @override
  String get signupStoreNameHint => 'مطعم الأصيل';

  @override
  String get signupManagerName => 'اسم المدير';

  @override
  String get signupStoreOwnerName => 'اسم صاحب المتجر';

  @override
  String get signupExampleName => 'محمد أحمد العبدالله';

  @override
  String get signupCoverageArea => 'منطقة الخدمة';

  @override
  String get signupCoverageHint => 'عمّان، الزرقاء، إربد...';

  @override
  String get signupSectionPersonal => 'المعلومات الشخصية';

  @override
  String get signupFullName => 'الاسم الكامل';

  @override
  String get signupFullNameHint => 'أحمد محمد العبدالله';

  @override
  String get signupNationality => 'الجنسية';

  @override
  String get signupJordanian => 'أردني';

  @override
  String get signupOther => 'غير ذلك';

  @override
  String get signupSectionDocuments => 'المستندات الرسمية';

  @override
  String get signupNationalIdDocument => 'صورة الهوية الوطنية';

  @override
  String get signupCommercialRegisterDocument => 'صورة السجل التجاري';

  @override
  String get signupBusinessLicenseDocument => 'صورة الترخيص التجاري';

  @override
  String get signupUploadDocumentPrompt => 'اضغط لرفع صورة المستند';

  @override
  String get signupUploadDocumentSources => 'كاميرا أو معرض الصور';

  @override
  String get signupDocumentUploaded => 'تم الرفع';

  @override
  String get signupSectionContact => 'معلومات التواصل';

  @override
  String get signupContactRequired => 'يجب إدخال واحد على الأقل';

  @override
  String get signupPhone => 'رقم الهاتف';

  @override
  String get signupPhoneHint => '7X XXX XXXX';

  @override
  String get signupEmailLabel => 'البريد الإلكتروني';

  @override
  String get signupEmailHint => 'example@domain.com';

  @override
  String get signupPasswordLabel => 'كلمة المرور';

  @override
  String get signupPasswordHint => '٨ أحرف على الأقل، حرف ورقم';

  @override
  String get signupPasswordConfirmLabel => 'تأكيد كلمة المرور';

  @override
  String get signupPasswordConfirmHint => 'أعد إدخال كلمة المرور';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginPasswordHint => 'أدخل كلمة المرور';

  @override
  String get roleDriverTitle => 'سائق';

  @override
  String get roleDriverSubtitle => 'قم بجمع ونقل النفايات لكسب المال';

  @override
  String get roleSupplierTitle => 'مورد';

  @override
  String get roleSupplierSubtitle => 'قم ببيع نفاياتك وساهم في حماية البيئة';

  @override
  String get roleRecyclingCoTitle => 'شركة إعادة تدوير';

  @override
  String get roleRecyclingCoSubtitle => 'استقبل المواد مباشرة في منشأتك';

  @override
  String get loginPhoneHelp =>
      'سنرسل لك رمزاً قصيراً لهذا الرقم للتحقق من هويتك';

  @override
  String get loginPhoneHint => '7X XXX XXXX';

  @override
  String get loginContinueButton => 'متابعة';

  @override
  String get loginPhoneEmptyError => 'الرجاء إدخال رقم الهاتف';

  @override
  String get loginNewNumberHint => 'رقم جديد؟ سيتم إنشاء حسابك بعد التحقق';

  @override
  String get otpTitle => 'رمز التحقق';

  @override
  String otpSubtitle(String phone) {
    return 'أدخل الرمز المكون من 6 أرقام المرسل إلى $phone';
  }

  @override
  String get otpVerifyButton => 'تحقق';

  @override
  String get otpResendButton => 'إعادة إرسال الرمز';

  @override
  String get otpResentMessage => 'تم إرسال الرمز مرة أخرى';

  @override
  String get otpErrorIncomplete => 'الرجاء إدخال الرمز كاملاً';

  @override
  String get otpErrorInvalid => 'الرمز غير صحيح، حاول مرة أخرى';

  @override
  String get otpSimulatedHint => 'سيتم إرسال رمز التحقق إلى رقمك عبر SMS';

  @override
  String get signupRoleDriver => 'تسجيل سائق';

  @override
  String get signupRoleStoreBusiness => 'تسجيل متجر / مطعم';

  @override
  String get signupRoleIndividualSupplier => 'تسجيل مورد فردي';

  @override
  String get signupRoleRecyclingCo => 'تسجيل شركة إعادة تدوير';

  @override
  String get signupPhotoPersonal => 'الصورة الشخصية';

  @override
  String get signupPhotoOrganization => 'شعار الجهة';

  @override
  String get signupErrorManagerName => 'الرجاء إدخال اسم المسؤول';

  @override
  String get signupErrorDocumentRequired => 'الرجاء رفع صورة المستند المطلوب';

  @override
  String get signupErrorEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get signupErrorPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get signupErrorPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get signupErrorSubmitFailed => 'تعذّر إنشاء الحساب، حاول مجدداً';

  @override
  String get signupLocationTitle => 'الموقع الجغرافي';

  @override
  String get signupLocationSubtitle => 'اختياري — يساعد على تحديد مناطق الخدمة';

  @override
  String get signupLocationChange => 'تغيير';

  @override
  String get signupLocationSelect => 'تحديد';

  @override
  String get signupLocationSelectPrompt => 'اضغط لتحديد موقعك';

  @override
  String get signupLocationOpenMap => 'اضغط لفتح خريطة الموقع';

  @override
  String get signupLocationPreciseLabel => 'العنوان الدقيق';

  @override
  String get signupLocationPreciseHint => 'الشارع، البناية، الشقة، إلخ.';

  @override
  String onboardingCategoriesSelected(int count) {
    return '$count محددة';
  }

  @override
  String get onboardingCategoriesSuggested => 'الفئات المقترحة — اختر ما ينطبق';

  @override
  String get onboardingCategoriesNote =>
      'يمكنك تعديل اختياراتك في أي وقت من إعدادات الملف الشخصي';

  @override
  String get onboardingHighlightsTitle => 'ما يميزك في التطبيق';

  @override
  String get onboardingHighlightsSubtitle =>
      'مزايا ستحصل عليها بمجرد إنشاء الحساب';

  @override
  String get onboardingAiPanelTitle => 'اقتراحات الذكاء الاصطناعي';

  @override
  String get onboardingAiPanelSubtitle => 'فئات موصى بها وما يميزك في التطبيق';

  @override
  String get onboardingAiPanelContext =>
      'سيحلل الذكاء الاصطناعي معلوماتك ويقترح الفئات الأنسب لك، ويوضح ما يميزك أمام عملائك في التطبيق.';

  @override
  String get onboardingTaglineLabel => 'شعارك أو رؤيتك';

  @override
  String get onboardingTaglineHint => 'مثال: أفضل خدمة بأقل تكلفة';

  @override
  String get onboardingAiGenerateButton => 'احصل على اقتراحات الذكاء الاصطناعي';

  @override
  String get onboardingAiGenerating => 'جارٍ التوليد...';

  @override
  String get individualSupplierSignupTitle => 'إنشاء حساب مورد فردي';

  @override
  String get recyclingCoSignupTitle => 'إنشاء حساب شركة تدوير';

  @override
  String get storeSignupTitle => 'إنشاء حساب متجر / شركة';

  @override
  String get onboardingHeaderSubtitleAi =>
      'أكمل النموذج وسيساعدك الذكاء الاصطناعي في اختيار الفئات';

  @override
  String get onboardingSectionProfile => 'الملف الشخصي';

  @override
  String get onboardingSectionProfileCompany => 'الملف الشخصي للشركة';

  @override
  String get onboardingSectionProfileStore => 'ملف الشركة / المتجر';

  @override
  String get onboardingLabelCompanyLogo => 'شعار الشركة';

  @override
  String get driverTitle => 'سائق دوّر';

  @override
  String get driverActiveOrdersLabel => 'طلب نشط';

  @override
  String get driverCompletedOrdersLabel => 'الطلبات المكتملة';

  @override
  String get driverEarningsLabel => 'الأرباح (د.أ)';

  @override
  String get driverUnavailableTitle => 'أنت غير متاح حالياً';

  @override
  String get driverUnavailableSubtitle =>
      'قم بتغيير حالتك إلى متاح بالأعلى لاستقبال طلبات جديدة';

  @override
  String get driverAvailableOrders => 'الطلبات المتاحة';

  @override
  String get driverNoAvailableOrders => 'لا توجد طلبات متاحة حالياً';

  @override
  String get driverMyListings => 'منشوراتي في السوق';

  @override
  String get driverCurrentTrip => 'رحلتك الحالية';

  @override
  String get driverViewDetails => 'عرض التفاصيل';

  @override
  String get driverPublishToMarket => 'نشر في السوق';

  @override
  String get driverOrdersHistory => 'سجل الطلبات';

  @override
  String get driverNoOrders => 'لا توجد طلبات';

  @override
  String get driverNoOrdersYet => 'لم تقم بقبول أي طلبات بعد';

  @override
  String get driverCollectionCommitments => 'التزامات التجميع';

  @override
  String get driverToggleOnline => 'متاح';

  @override
  String get driverToggleOffline => 'غير متاح';

  @override
  String get driverStatusOnline => 'متصل الآن';

  @override
  String get driverStatusOffline => 'غير متصل';

  @override
  String get driverActiveMission => 'مهمة نشطة';

  @override
  String get driverHeadingToPickup => 'متجه للاستلام';

  @override
  String get driverHeadingToDelivery => 'متجه للتسليم';

  @override
  String get driverOrderAccepted => 'تم قبول الطلب';

  @override
  String get driverNewOrderBadge => 'طلب جديد';

  @override
  String get driverActivateNow => 'تفعيل الآن';

  @override
  String get driverNoOrdersNotifySubtitle =>
      'ستصلك إشعارات عند توفر طلبات جديدة';

  @override
  String get driverOrdersTabAll => 'الكل';

  @override
  String get driverOrdersTabActive => 'النشطة';

  @override
  String get driverOrdersTabCompleted => 'المكتملة';

  @override
  String get driverPickupLabel => 'الاستلام';

  @override
  String get driverDeliveryLabel => 'التسليم';

  @override
  String get driverViewPickupDetails => 'عرض تفاصيل الاستلام';

  @override
  String get driverViewDeliveryDetails => 'عرض تفاصيل التسليم';

  @override
  String get driverRewardLabel => 'العائد';

  @override
  String get driverDistanceLabel => 'المسافة';

  @override
  String get driverTimeLabel => 'الوقت';

  @override
  String get driverWasteTypeLabel => 'نوع المواد';

  @override
  String get withdrawListing => 'سحب الإعلان';

  @override
  String get withdrawListingConfirm => 'هل يريد سحب هذا الإعلان من السوق؟';

  @override
  String get yesWithdraw => 'نعم، سحب';

  @override
  String get profilePersonalAndVehicle => 'المعلومات الشخصية والمركبة';

  @override
  String get profilePhone => 'رقم الهاتف';

  @override
  String get profileVehicle => 'المركبة';

  @override
  String get profileLicensePlate => 'رقم اللوحة';

  @override
  String get profileAddLicensePlate => 'أضف رقم اللوحة';

  @override
  String get profileAddVehicleInfo => 'أضف معلومات المركبة';

  @override
  String get profileAppSettings => 'إعدادات التطبيق';

  @override
  String get profileLanguage => 'لغة التطبيق';

  @override
  String get profileTheme => 'المظهر';

  @override
  String get profileNotifications => 'الإشعارات';

  @override
  String get profileNotificationsEnabled => 'مفعلة';

  @override
  String get profileHelpSupport => 'المساعدة والدعم';

  @override
  String get profileContactSupport => 'تواصل مع الدعم الفني';

  @override
  String get profileEditProfile => 'تعديل الملف الشخصي';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileTotalTrips => 'إجمالي الرحلات';

  @override
  String get profileTotalEarnings => 'إجمالي الأرباح';

  @override
  String get profileTapToAddPhoto => 'اضغط لإضافة صورة';

  @override
  String get profileEditVehicle => 'تعديل معلومات المركبة';

  @override
  String get profileVehicleTypeModel => 'نوع المركبة وموديلها';

  @override
  String get profileVehicleTypeModelHint => 'مثال: تويوتا بريوس';

  @override
  String get profileVehicleColor => 'لون المركبة';

  @override
  String get profileVehicleColorHint => 'مثال: أبيض';

  @override
  String get profileVehiclePhoto => 'صورة المركبة';

  @override
  String get supplierStoreType => 'مورد متجر';

  @override
  String get supplierIndividualType => 'مورد فردي';

  @override
  String get supplierActiveOrders => 'طلباتي النشطة';

  @override
  String get supplierMyListings => 'منشوراتي في السوق';

  @override
  String get supplierNoOrdersYet => 'لا توجد طلبات نشطة';

  @override
  String get supplierCreateFromHome =>
      'اضغط على زر + أسفل الشاشة لإنشاء طلب جديد';

  @override
  String supplierGreeting(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get supplierDriverOnWay => 'السائق في الطريق إليك';

  @override
  String get supplierPoints => 'نقطة';

  @override
  String get supplierRecyclingPoints => 'نقاط التدوير';

  @override
  String get supplierTotalOrders => 'إجمالي الطلبات';

  @override
  String get supplierAddress => 'العنوان';

  @override
  String get supplierAddAddress => 'أضف العنوان';

  @override
  String get supplierIdentity => 'الهوية';

  @override
  String get supplierVerified => 'تم التحقق';

  @override
  String get supplierNotVerified => 'لم يتم التحقق';

  @override
  String get supplierPersonalInfo => 'المعلومات الشخصية';

  @override
  String get supplierMyRewards => 'مكافآتي';

  @override
  String get supplierNameLabel => 'الاسم';

  @override
  String get supplierNameHint => 'أدخل اسمك';

  @override
  String get supplierPhoneHint => '+962 7X XXX XXXX';

  @override
  String get supplierAddressLabel => 'العنوان';

  @override
  String get supplierAddressHint => 'أدخل عنوانك';

  @override
  String get ordersTabTitle => 'طلباتي';

  @override
  String get ordersNoOrdersYet => 'لا توجد طلبات بعد';

  @override
  String get ordersCreateFromHome => 'أنشئ طلب استلام جديد من الصفحة الرئيسية';

  @override
  String get ordersActiveSection => 'الطلبات النشطة';

  @override
  String get ordersCompletedSection => 'الطلبات المكتملة';

  @override
  String get ordersCancelledSection => 'الطلبات الملغاة';

  @override
  String get ordersCollectionSection => 'التزامات التجميع';

  @override
  String get orderDeliveryConfirmTitle => 'تأكيد التسليم';

  @override
  String get orderDeliveryConfirmMsg => 'هل وصلت إلى المنشأة وسلّمت المواد؟';

  @override
  String get orderActualWeight => 'الوزن الفعلي (كغ) — اختياري';

  @override
  String get orderScheduledAt => 'موعد مجدول';

  @override
  String get cancelOrderTitle => 'إلغاء الطلب';

  @override
  String get cancelOrderConfirm => 'هل أنت متأكد أنك تريد إلغاء هذا الطلب؟';

  @override
  String get yesCancelOrder => 'نعم، إلغاء';

  @override
  String get recyclingCompanyLabel => 'شركة إعادة تدوير';

  @override
  String get recyclingOpenForReceipt => 'مفتوح للاستلام';

  @override
  String get recyclingClosedTemp => 'مغلق مؤقتاً';

  @override
  String get recyclingTodayShipments => 'شحنات اليوم';

  @override
  String get recyclingTotalWeight => 'الوزن الكلي';

  @override
  String get recyclingActiveJobsLabel => 'وظائف نشطة';

  @override
  String get recyclingDriversInProgress => 'سائقون قيد التنفيذ';

  @override
  String get recyclingPostJob => 'نشر وظيفة تجميع';

  @override
  String get recyclingPostJobSubtitle =>
      'أطلب من سائق جمع المخلفات من منطقة محددة';

  @override
  String get recyclingIncomingShipments => 'الشحنات القادمة';

  @override
  String get recyclingActiveCollectionJobs => 'وظائف التجميع النشطة';

  @override
  String get recyclingMyListings => 'منشوراتي في السوق';

  @override
  String get recyclingCommitted => 'الملتزمون:';

  @override
  String get recyclingCompanyInfo => 'معلومات الشركة';

  @override
  String get recyclingCompanyPhone => 'رقم التواصل';

  @override
  String get recyclingCompanyEmail => 'البريد الإلكتروني';

  @override
  String get recyclingServiceArea => 'منطقة الخدمة';

  @override
  String get recyclingWorkingHours => 'ساعات العمل';

  @override
  String get recyclingLicense => 'الترخيص التجاري';

  @override
  String get recyclingReceivedShipments => 'شحنات مستلمة';

  @override
  String get recyclingProcessedWeight => 'وزن معالج (كغ)';

  @override
  String get recyclingEditCompany => 'تعديل بيانات الشركة';

  @override
  String get recyclingCompanyNameLabel => 'اسم الشركة';

  @override
  String get recyclingCompanyNameHint => 'أدخل اسم الشركة';

  @override
  String get recyclingPhoneLabel => 'رقم التواصل';

  @override
  String get recyclingPhoneHint => '+962 6X XXX XXXX';

  @override
  String get recyclingEmailLabel => 'البريد الإلكتروني';

  @override
  String get recyclingEmailHint => 'info@company.jo';

  @override
  String get recyclingAreaLabel => 'منطقة الخدمة';

  @override
  String get recyclingAreaHint => 'عمّان، الزرقاء...';

  @override
  String get recyclingHoursLabel => 'ساعات العمل';

  @override
  String get recyclingHoursHint => '٧:٠٠ ص - ٥:٠٠ م';

  @override
  String get recyclingLicenseVerified => 'تم التحقق';

  @override
  String get recyclingLicenseNotVerified => 'لم يتم التحقق';

  @override
  String get marketDriverRole => 'استلم وابيع';

  @override
  String get marketSupplierRole => 'اشترِ وأوصل';

  @override
  String get marketRecyclingRole => 'استلم في منشأتك';

  @override
  String get marketTitle => 'السوق';

  @override
  String get marketBrowse => 'تصفّح المواد المعروضة للبيع';

  @override
  String get marketCollectionJobsSubtitle => 'وظائف التجميع من شركات التدوير';

  @override
  String get marketSearch => 'ابحث عن مواد، بائع، أو منطقة...';

  @override
  String get marketAvailableOffers => 'العروض المتاحة';

  @override
  String get marketNoOffers => 'لا توجد عروض حالياً';

  @override
  String get collectionSaleNew => 'جديد';

  @override
  String collectionSaleJobNumber(String id) {
    return 'رقم الوظيفة: $id';
  }

  @override
  String get collectionSaleDeliveryLocation => 'موقع التسليم:';

  @override
  String get collectionSaleAgreedPrice => 'السعر المتفق عليه:';

  @override
  String get collectionSaleCancelCommitment => 'إلغاء الالتزام';

  @override
  String get collectionSaleStartCollection => 'بدء التجميع';

  @override
  String get collectionSaleConfirmDelivery => 'تأكيد التسليم';

  @override
  String get collectionSaleCancelTitle => 'إلغاء الالتزام';

  @override
  String get collectionSaleCancelConfirm =>
      'هل أنت متأكد أنك تريد إلغاء التزامك بهذه الوظيفة؟';

  @override
  String get postMarketTitle => 'نشر في السوق';

  @override
  String get postMarketSubtitle => 'أضف تفاصيل المواد التي تريد بيعها';

  @override
  String get postMarketWasteTypeLabel => 'نوع المواد *';

  @override
  String get postMarketWasteFormLabel => 'حالة المواد';

  @override
  String get postMarketPriceLabel => 'السعر المطلوب (د.أ) — اختياري';

  @override
  String get postMarketImagesLabel => 'صور المواد — اختياري';

  @override
  String get postMarketSubmitButton => 'نشر الإعلان';

  @override
  String get postMarketAiAnalyzing => 'الذكاء الاصطناعي يحلل الصورة...';

  @override
  String get postMarketAiFilled =>
      'تم تعبئة الحقول تلقائياً بواسطة الذكاء الاصطناعي';

  @override
  String get postMarketAiFailed =>
      'فشل تحليل الذكاء الاصطناعي، يرجى التعبئة يدوياً';

  @override
  String get postMarketNeedImageFirst => 'يرجى إضافة صورة أولاً لتحليلها';

  @override
  String get postMarketLocationPermissionDenied =>
      'تم رفض إذن الموقع، سيتم استخدام الموقع الافتراضي';

  @override
  String get postMarketUseCurrentLocation => 'استخدام موقعي الحالي';

  @override
  String get postMarketAdjustLocation => 'تعديل الموقع على الخريطة';

  @override
  String get postMarketMinPriceErrorIndividual =>
      'عذراً، الحد الأدنى للنشر للأفراد هو ٥ دنانير';

  @override
  String get postMarketMinPriceErrorBusiness =>
      'عذراً، الحد الأدنى للنشر للشركات هو ٢٠ ديناراً';

  @override
  String get collectionJobTitle => 'تفاصيل وظيفة التجميع';

  @override
  String get collectionJobCollectionArea => 'منطقة التجميع: ';

  @override
  String get collectionJobDeleteTitle => 'حذف الوظيفة';

  @override
  String get collectionJobDeleteConfirm =>
      'هل أنت متأكد؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get collectionJobAccepted => 'تم قبول الوظيفة — تحقق من طلباتك';

  @override
  String get collectionJobAcceptButton => 'قبول الوظيفة';

  @override
  String get collectionJobAcceptSellButton => 'قبول وبيع النفايات';

  @override
  String get collectionJobRequiredMaterials => 'أنواع المواد المطلوبة';

  @override
  String get collectionJobPricingTitle => 'التسعيرة والدفع';

  @override
  String get collectionJobDescTitle => 'وصف الوظيفة';

  @override
  String get collectionJobRecyclingCoLabel => 'شركة تدوير';

  @override
  String get marketItemSellerLabel => 'البائع';

  @override
  String get marketItemPickupAddressLabel => 'عنوان الاستلام';

  @override
  String get marketItemDistanceLabel => 'المسافة التقديرية';

  @override
  String marketItemDistanceValue(String distance) {
    return '$distance كم من موقعك';
  }

  @override
  String get marketItemConditionLabel => 'الحالة';

  @override
  String get marketItemWeightLabel => 'الوزن';

  @override
  String get marketItemPublishDateLabel => 'تاريخ النشر';

  @override
  String get marketItemUnknown => 'غير محدد';

  @override
  String get marketItemUnknownSeller => 'بائع مجهول';

  @override
  String get marketItemDriverReceive => 'استلام العنصر';

  @override
  String get marketItemBuyNow => 'شراء الآن';

  @override
  String get marketItemCompanyReceive => 'استلام في المنشأة';

  @override
  String get marketItemPurchasedPickup => 'تم الشراء! يمكنك الاستلام من السوق.';

  @override
  String get marketItemReceived => 'تم استلام العنصر بنجاح!';

  @override
  String get marketItemPurchasedDriver =>
      'تم الشراء! سيتم إرسال سائق للاستلام.';

  @override
  String get marketItemFacilityReceived => 'تم تسجيل الاستلام في المنشأة!';

  @override
  String get marketRiderChoiceTitle => 'اختر الإجراء';

  @override
  String get marketRiderChoiceSubtitle =>
      'هل تريد شراء هذا العنصر لنفسك أم توصيله؟';

  @override
  String get marketRiderOptionBuy => 'شراء لنفسي';

  @override
  String get marketRiderOptionBuySubtitle => 'ادفع واستلم العنصر من موقعه';

  @override
  String get marketRiderOptionDeliver => 'توصيل الطلب';

  @override
  String get marketRiderOptionDeliverSubtitle => 'نقل العنصر من مكان إلى آخر';

  @override
  String get marketInvoiceTitle => 'فاتورة الطلب';

  @override
  String get marketInvoiceTotal => 'المبلغ الإجمالي';

  @override
  String get marketInvoiceConfirm => 'تأكيد وشراء';

  @override
  String get marketInvoicePickupLocation => 'موقع الاستلام';

  @override
  String get marketInvoicePickupSuccess =>
      'تم تأكيد الشراء! توجه إلى الموقع لاستلام عنصرك.';

  @override
  String get rateDriverTitle => 'تقييم السائق';

  @override
  String get rateDriverSubmit => 'إرسال التقييم';

  @override
  String get rateDriverSkip => 'تخطّ';

  @override
  String get rewardsTitle => 'مكافآتي';

  @override
  String get rewardsHistoryTitle => 'سجل المكافآت';

  @override
  String get rewardsNoHistory => 'لا يوجد سجل مكافآت بعد';

  @override
  String get rewardsPointsLabel => 'نقطة';

  @override
  String get rewardsRedeem => 'استبدل نقاطك';

  @override
  String get rewardsComingSoon => 'هذه الميزة قريباً!';

  @override
  String rewardsProgressText(int points, int threshold) {
    return '$points / $threshold نقطة للمستوى التالي';
  }

  @override
  String get rewardsDiscountOrders => 'خصم على الطلبات';

  @override
  String get rewardsGiftCard => 'كرت هدية';

  @override
  String get rewardsFreeDelivery => 'توصيل مجاني';

  @override
  String get rewards50Points => '50 نقطة';

  @override
  String get rewards100Points => '100 نقطة';

  @override
  String get rewards30Points => '30 نقطة';

  @override
  String get tierBronze => 'برونزي';

  @override
  String get tierSilver => 'فضي';

  @override
  String get tierGold => 'ذهبي';

  @override
  String get tierPlatinum => 'بلاتيني';

  @override
  String get mapsComingSoon => 'سيتم ربط خرائط جوجل قريباً';

  @override
  String get marketSegmentJobs => 'وظائف التجميع';

  @override
  String get marketJobsFromCompanies => 'من شركات التدوير';

  @override
  String get marketNoJobs => 'لا توجد وظائف تجميع حالياً';

  @override
  String get marketCategoryAll => 'الكل';

  @override
  String get marketNoOffersBody => 'سيظهر هنا ما يتم نشره من مواد للبيع';

  @override
  String get marketNoJobsBody => 'ستظهر هنا وظائف التجميع المتاحة';

  @override
  String get marketSuggestedByLicense => 'اقتراحات بناءً على رخصتك';

  @override
  String get marketShowAllOrders => 'عرض كل الطلبات';

  @override
  String get collectionJobBadge => 'وظيفة تجميع';

  @override
  String get collectionJobEdited => 'تم تعديله';

  @override
  String collectionJobEditedAt(String time) {
    return 'تم تعديل هذه الوظيفة $time';
  }

  @override
  String collectionJobMinQtyChip(String n) {
    return 'الحد الأدنى: $n كغ';
  }

  @override
  String recyclingAndOthers(int count) {
    return '+$count آخرون';
  }

  @override
  String collectionJobMinQtyFrom(String min) {
    return 'من $min كغ';
  }

  @override
  String timeAgoDays(int n) {
    return 'منذ $n يوم';
  }

  @override
  String timeAgoHours(int n) {
    return 'منذ $n ساعة';
  }

  @override
  String timeAgoMinutes(int n) {
    return 'منذ $n دقيقة';
  }

  @override
  String get marketListingStatusPending => 'بانتظار مشتري';

  @override
  String get marketListingStatusAccepted => 'تم الشراء';

  @override
  String get marketListingStatusInTransit => 'قيد التوصيل';

  @override
  String get marketListingStatusCompleted => 'مكتمل';

  @override
  String get marketListingStatusCancelled => 'ملغي';

  @override
  String get orderStatusPending => 'قيد الانتظار';

  @override
  String get orderStatusAccepted => 'تم القبول';

  @override
  String get orderStatusArrivedAtPickup => 'وصل للاستلام';

  @override
  String get orderStatusArrivedAtDropoff => 'وصل للتسليم';

  @override
  String get orderStatusInTransit => 'في الطريق';

  @override
  String get orderStatusCompleted => 'مكتمل';

  @override
  String get orderStatusCancelled => 'ملغي';

  @override
  String get orderWaitingTime => 'وقت الانتظار';

  @override
  String get orderArrivalTime => 'وقت الوصول';

  @override
  String get orderEarningsLabel => 'العائد';

  @override
  String get orderCurrencyJD => 'دينار';

  @override
  String get orderAcceptButton => 'اقبل الطلب';

  @override
  String get orderViewRoute => 'عرض المسار';

  @override
  String get orderDriverOnWay => 'السائق في الطريق إليك';

  @override
  String get orderChatButton => 'تواصل';

  @override
  String get orderWhatsAppButton => 'واتساب';

  @override
  String get orderChatComingSoon => 'المحادثة مع السائق قريباً';

  @override
  String get orderWhatsAppFailed => 'تعذّر فتح واتساب';

  @override
  String get orderStatusTitle => 'حالة الطلب';

  @override
  String get orderStatusStepPending => 'انتظار';

  @override
  String get orderStatusStepAccepted => 'قُبل';

  @override
  String get orderStatusStepArrivedAtPickup => 'وصل';

  @override
  String get orderStatusStepInTransit => 'في الطريق';

  @override
  String get orderStatusStepArrivedAtDropoff => 'للتسليم';

  @override
  String get orderStatusStepCompleted => 'مكتمل';

  @override
  String get orderDetailsTitle => 'تفاصيل الطلب';

  @override
  String get orderFromLabel => 'من';

  @override
  String get orderToLabel => 'إلى';

  @override
  String orderDistKm(String d) {
    return '$d كم';
  }

  @override
  String orderWeightKgLabel(String w) {
    return '$w كغ';
  }

  @override
  String orderRewardJD(String r) {
    return '$r د.أ';
  }

  @override
  String get orderDriverSection => 'السائق';

  @override
  String orderDriverArrives(String eta) {
    return 'يصل خلال $eta';
  }

  @override
  String get orderEtaEnRouteToDropoff => 'أنت في الطريق إلى موقع التسليم';

  @override
  String get orderEtaMinutesUnit => 'دقيقة';

  @override
  String get orderCompletionTitle => 'إتمام الرحلة';

  @override
  String get orderPhotoCamera => 'التقاط صورة';

  @override
  String get orderPhotoGallery => 'اختيار من المعرض';

  @override
  String get orderCompleteDialogTitle => 'إتمام الطلب';

  @override
  String get orderCompleteDialogMsg =>
      'هل أنت متأكد من تسليم الطلب واستلام المبلغ؟\nعند إتمام الطلب، ستتمكن من استقبال طلبات جديدة.';

  @override
  String get orderConfirmComplete => 'تأكيد الإتمام';

  @override
  String get orderProofPhotoHint => 'التقط صورة إثبات الاستلام (اختياري)';

  @override
  String get orderAmountLabel => 'المبلغ المطلوب تحصيله:';

  @override
  String get orderFinishButton => 'إنهاء الطلب';

  @override
  String get orderProofTitle => 'إثبات الاستلام والتسليم';

  @override
  String get orderProofLinkBroken => 'الرابط يشير لملف غير متوفر مؤقتاً';

  @override
  String get orderRateDriver => 'قيّم السائق';

  @override
  String get orderWhatsAppWaiting => 'مرحباً، أنا في انتظار استلامي.';

  @override
  String get marketItemPriceLabel => 'سعر المواد';

  @override
  String get marketItemNegotiable => 'قابل للتفاوض';

  @override
  String get marketItemDescriptionLabel => 'وصف المنتج';

  @override
  String get marketItemReserveNowButton => 'احجز الآن بـ ١٠٪';

  @override
  String get marketItemReservationSent =>
      'تم إرسال طلب الحجز — بانتظار موافقة البائع';

  @override
  String marketListingPrice(String price) {
    return '$price د.أ';
  }

  @override
  String get collectionSaleDetailTitle => 'تفاصيل الالتزام';

  @override
  String get collectionSaleDeliveryLocationNoColon => 'موقع التسليم';

  @override
  String get collectionSaleAgreedPriceNoColon => 'السعر المتفق عليه';

  @override
  String get collectionSaleAgreementTitle => 'تفاصيل الاتفاق';

  @override
  String get collectionSaleDeliveryMethodLabel => 'طريقة التوصيل';

  @override
  String get collectionSaleTransactionTypeLabel => 'نوع المعاملة';

  @override
  String get collectionSaleWasteTypesLabel => 'أنواع النفايات';

  @override
  String collectionSaleCompanyNote(String note) {
    return 'الشركة: $note';
  }

  @override
  String get collectionSaleCommitmentNumber => 'رقم الالتزام';

  @override
  String get collectionSaleJobNumberLabel => 'رقم الوظيفة';

  @override
  String get collectionSaleAcceptedAt => 'تاريخ القبول';

  @override
  String get orderTrackButton => 'تتبع';

  @override
  String get rateDriverExperience => 'كيف كانت تجربتك مع السائق؟';

  @override
  String get rateDriverPickLabel => 'اختر تقييمك';

  @override
  String get rateDriverPoor => 'سيئ';

  @override
  String get rateDriverFair => 'متوسط';

  @override
  String get rateDriverGood => 'جيد';

  @override
  String get rateDriverExcellent => 'ممتاز';

  @override
  String get imagePickerCamera => 'الكاميرا';

  @override
  String get imagePickerGallery => 'المعرض';

  @override
  String get imagePickerSourceTitle => 'اختر مصدر الصورة';

  @override
  String get imagePickerAddPhoto => 'إضافة صورة';

  @override
  String get imagePickerRemoveImage => 'إزالة الصورة';

  @override
  String get newOrderSelectButton => 'تحديد';

  @override
  String get newOrderTapToSelectLocation => 'اضغط لتحديد الموقع على الخريطة';

  @override
  String get newOrderCurrentAddress => 'عنواني الحالي';

  @override
  String get newOrderTitle => 'طلب استلام جديد';

  @override
  String get newOrderSubtitle => 'أضف تفاصيل المخلفات التي تريد التخلص منها';

  @override
  String get newOrderWasteTypeLabel => 'نوع المخلفات *';

  @override
  String get newOrderWasteFormLabel => 'حالة المخلفات';

  @override
  String get newOrderWeightCategoryLabel => 'حجم الكمية *';

  @override
  String get newOrderPickupAddressLabel => 'عنوان الاستلام';

  @override
  String get newOrderImagesLabel => 'صور المخلفات — اختياري';

  @override
  String get newOrderPickupTargetLabel => 'وجهة المخلفات *';

  @override
  String get newOrderPriceLabel => 'سعر المواد (د.أ) — اختياري';

  @override
  String get newOrderPriceHintDriver =>
      'السعر الذي تريده مقابل بيع المواد للسائق';

  @override
  String get newOrderPriceHintCompany =>
      'السعر الذي تريده مقابل بيع المواد للشركة';

  @override
  String get newOrderNotesLabel => 'ملاحظات — اختياري';

  @override
  String get newOrderNotesHint => 'مثال: الكميّة تقريباً ٢٠ كيس بلاستيك...';

  @override
  String get newOrderDeliveryFeeLabel => 'رسوم التوصيل';

  @override
  String get newOrderDeliveryFeeSubtitle => 'تُحسب تلقائياً حسب المسافة والحجم';

  @override
  String get newOrderSubmitButton => 'إرسال الطلب';

  @override
  String get chatTitle => 'المحادثة';

  @override
  String get chatDevBanner => 'تنبيه: وضع التطوير — الرسائل محلية حالياً';

  @override
  String get chatEmpty => 'لا توجد رسائل بعد';

  @override
  String get chatInputHint => 'اكتب رسالة...';

  @override
  String get openInGoogleMaps => 'الذهاب للمركز عبر خرائط جوجل';

  @override
  String get mapsNotInstalledTitle => 'خرائط جوجل غير مثبتة';

  @override
  String get mapsNotInstalledBody =>
      'لم يتم العثور على تطبيق الخرائط. هل تريد فتح المتجر لتثبيته؟';

  @override
  String get openStore => 'فتح المتجر';

  @override
  String get mapLabelPickup => 'الاستلام';

  @override
  String get mapLabelDropoff => 'التسليم';

  @override
  String get mapUnavailable => 'الخريطة غير متوفرة';

  @override
  String get routeTitle => 'خط السير';

  @override
  String get pickLocationTitle => 'تحديد الموقع';

  @override
  String get confirmLocation => 'تأكيد الموقع';

  @override
  String get useCurrentLocation => 'استخدام موقعي الحالي';

  @override
  String get pickOnGoogleMaps => 'تحديد من خرائط جوجل';

  @override
  String get locationNotSet => 'لم يتم تحديد الموقع بعد';

  @override
  String get pasteCoordinates => 'الصق الإحداثيات';

  @override
  String get pasteCoordinatesHint =>
      'الصق من خرائط جوجل، مثال: 31.9539, 35.9106';

  @override
  String get latitude => 'خط العرض';

  @override
  String get longitude => 'خط الطول';

  @override
  String get save => 'حفظ';

  @override
  String get gpsPermissionDenied => 'تم رفض إذن الموقع';

  @override
  String get gpsUnavailable => 'تعذّر الحصول على الموقع الحالي';

  @override
  String get invalidCoordinates => 'إحداثيات غير صالحة';

  @override
  String get orderTotalCost => 'التكلفة الإجمالية';

  @override
  String get orderPotentialEarnings => 'الأرباح المتوقعة';

  @override
  String get orderEarningsBreakdown => 'تفاصيل الأرباح';

  @override
  String get orderBaseFee => 'الرسوم الأساسية';

  @override
  String get orderDistanceFee => 'رسوم المسافة';

  @override
  String get orderMaterialFee => 'رسوم المواد';

  @override
  String get orderUrgencyFee => 'رسوم الاستعجال';

  @override
  String get orderPayout => 'المستحق للسائق';

  @override
  String get orderInvoices => 'الفواتير';

  @override
  String get rateDriver => 'قيّم السائق';

  @override
  String get pickupRequestCreated => 'تم إرسال طلب الاستلام بنجاح';

  @override
  String get forgotPasswordLink => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordOtpTitle => 'رمز التحقق';

  @override
  String forgotPasswordOtpSubtitle(String email) {
    return 'تم إرسال رمز إلى $email';
  }

  @override
  String get forgotPasswordOtpLabel => 'أدخل الرمز المكوّن من ٦ أرقام';

  @override
  String get forgotPasswordVerifyButton => 'التحقق من الرمز';

  @override
  String get forgotPasswordResend => 'إعادة الإرسال';

  @override
  String forgotPasswordResendIn(int s) {
    return 'إعادة الإرسال بعد $s ثانية';
  }

  @override
  String get forgotPasswordCodeSentAgain => 'تم إرسال رمز جديد';

  @override
  String get resetPasswordTitle => 'تعيين كلمة مرور جديدة';

  @override
  String get resetPasswordNewLabel => 'كلمة المرور الجديدة';

  @override
  String get resetPasswordConfirmLabel => 'تأكيد كلمة المرور';

  @override
  String get resetPasswordButton => 'تعيين كلمة المرور';

  @override
  String get resetPasswordSuccess =>
      'تم تغيير كلمة المرور بنجاح. يمكنك تسجيل الدخول الآن';

  @override
  String get forgotPasswordErrorEmptyEmail =>
      'الرجاء إدخال بريدك الإلكتروني أولاً';

  @override
  String get forgotPasswordErrorCodeLength =>
      'الرجاء إدخال رمز مكوّن من ٦ أرقام';

  @override
  String get resetPasswordErrorMinLength =>
      'كلمة المرور يجب أن تكون ٨ أحرف على الأقل';

  @override
  String get resetPasswordErrorMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get restaurantSignupStep1Title => 'الملف الشخصي الأساسي';

  @override
  String get restaurantSignupStep1Subtitle =>
      'لنبدأ بتفاصيل شركتك. تساعدنا هذه المعلومات في التحقق من عملك وبناء الثقة مع العملاء.';

  @override
  String get restaurantSignupCompanyNameLabel => 'اسم المطعم / الشركة';

  @override
  String get restaurantSignupCompanyNameHint => 'مثال: الملعقة الذهبية';

  @override
  String get restaurantSignupOwnerNameLabel => 'اسم المالك';

  @override
  String get restaurantSignupOwnerNameHint => 'مثال: أحمد محمد';

  @override
  String get restaurantSignupStep2Title =>
      'هوية العلامة التجارية والذكاء الاصطناعي';

  @override
  String get restaurantSignupStep2Subtitle =>
      'صف مطعمك في سطر واحد. سيساعدك الذكاء الاصطناعي لدينا في صياغة قصة مقنعة والتوصية بفئات البحث.';

  @override
  String get restaurantSignupTaglineLabel => 'صف مطعمك في سطر واحد';

  @override
  String get restaurantSignupTaglineHint =>
      'مثال: مكرونة إيطالية أصيلة مصنوعة يدوياً';

  @override
  String get restaurantSignupGenerateButton => 'إنشاء الملف الشخصي والفئات';

  @override
  String get restaurantSignupAiStoryLabel =>
      'قصة من إنشاء الذكاء الاصطناعي (قابلة للتعديل)';

  @override
  String get restaurantSignupCategoriesLabel => 'الفئات الموصى بها';

  @override
  String get restaurantSignupStep3Title => 'الموقع والتحقق';

  @override
  String get restaurantSignupStep3Subtitle =>
      'قدم عنوانك الفعلي وحمل مستندات التحقق. سيقوم الذكاء الاصطناعي لدينا بالتحقق من تفاصيلك تلقائياً.';

  @override
  String get restaurantSignupAddressLabel => 'عنوان المطعم';

  @override
  String get restaurantSignupAddressHint => 'أدخل عنوان الشارع الكامل';

  @override
  String get restaurantSignupUploadVerifyButton => 'تحميل الترخيص والتحقق';

  @override
  String get restaurantSignupAiVerificationNote =>
      'سيتم فحص هذه الصورة بواسطة الذكاء الاصطناعي للتحقق من مستندك.';

  @override
  String get restaurantSignupStatusVerified => 'الحالة: تم التحقق';

  @override
  String get restaurantSignupStatusInvalid => 'الحالة: غير صالح';

  @override
  String get restaurantSignupVerificationSuccess =>
      'تم التحقق من مستنداتك وعنوانك تلقائياً.';

  @override
  String get restaurantSignupStep4Title => 'المراجعة والإرسال';

  @override
  String get restaurantSignupStep4Subtitle =>
      'يرجى مراجعة ملفك الشخصي وتفاصيلك قبل الإرسال النهائي.';

  @override
  String get restaurantSignupSectionBasic => 'معلومات أساسية';

  @override
  String get restaurantSignupSectionAi => 'الهوية المنشأة بالذكاء الاصطناعي';

  @override
  String get restaurantSignupSectionLocation => 'الموقع والتحقق';

  @override
  String get restaurantSignupGeneratedStoryLabel => 'القصة المنشأة:';

  @override
  String get restaurantSignupNotVerified => 'لم يتم التحقق';

  @override
  String get restaurantSignupAppBarTitle => 'تسجيل المطعم';

  @override
  String get restaurantSignupBackButton => 'رجوع';

  @override
  String get restaurantSignupNextButton => 'التالي';

  @override
  String get restaurantSignupSubmitButton => 'إرسال';

  @override
  String get restaurantSignupSuccess => 'تم التسجيل بنجاح!';

  @override
  String get restaurantSignupErrorCompanyNameRequired => 'اسم الشركة مطلوب';

  @override
  String get restaurantSignupErrorOwnerNameRequired => 'اسم المالك مطلوب';

  @override
  String get restaurantSignupErrorTaglineRequired =>
      'يرجى تقديم وصف قصير لإنشاء ملفك الشخصي';

  @override
  String get restaurantSignupErrorAiProfileRequired =>
      'يرجى إنشاء ومراجعة ملفك الشخصي بالذكاء الاصطناعي';

  @override
  String get restaurantSignupErrorCategoryRequired =>
      'يرجى اختيار فئة واحدة على الأقل';

  @override
  String get restaurantSignupErrorAddressRequired => 'العنوان مطلوب';

  @override
  String get restaurantSignupErrorVerificationRequired =>
      'يجب التحقق من مستنداتك وعنوانك';

  @override
  String get restaurantSignupErrorAiGenerationFailed =>
      'فشل إنشاء الملف الشخصي. يرجى المحاولة مرة أخرى.';

  @override
  String get restaurantSignupErrorVerificationFailed =>
      'فشل التحقق. يرجى المحاولة مرة أخرى.';

  @override
  String get restaurantSignupErrorTaglineFirst => 'يرجى تقديم وصف قصير أولاً';

  @override
  String get restaurantSignupErrorAddressFirst => 'يرجى تقديم عنوان أولاً';

  @override
  String get orderItemPrice => 'سعر العنصر';

  @override
  String get aiValidationUploadPrompt => 'اضغط لالتقاط أو رفع صورة';

  @override
  String get aiValidationAnalyzingStep1 => 'الذكاء الاصطناعي يحلل صورتك...';

  @override
  String get aiValidationAnalyzingStep2 => 'جاري التحقق من وضوح المستند...';

  @override
  String get aiValidationAnalyzingStep3 => 'جاري التحقق من المصداقية...';

  @override
  String get aiValidationSuccessTitle => 'تم التحقق من الصورة!';

  @override
  String get aiValidationSuccessSubtitle => 'تستوفي صورتك جميع المتطلبات.';

  @override
  String get aiValidationRetryButton => 'حاول مرة أخرى';

  @override
  String get aiValidationErrorTitle => 'فشل التحقق';

  @override
  String get aiValidationErrorUnknown => 'حدث خطأ غير متوقع.';

  @override
  String get aiValidationStatusSuccess => 'تم التحقق بنجاح';

  @override
  String get aiValidationStatusInvalid => 'الصورة لا تفي بالمعايير.';

  @override
  String get aiValidationStatusErrorUnknown => 'خطأ تحقق غير معروف.';

  @override
  String get aiValidationScanning => 'جاري مسح الوثيقة...';

  @override
  String get aiValidationVerifyingStamps => 'التحقق من الأختام الرسمية...';

  @override
  String get aiValidationMatchingData =>
      'مطابقة البيانات مع السجلات الحكومية...';

  @override
  String get aiValidationExtractedData => 'بيانات مستخرجة بالذكاء الاصطناعي';

  @override
  String get aiValidationDocId => 'رقم الوثيقة';

  @override
  String get aiValidationOrg => 'الجهة / المؤسسة';

  @override
  String get aiValidationAuthenticity => 'نسبة المصداقية';

  @override
  String get aiValidationFutureVision =>
      'رؤية مستقبلية: سيتم ربط النسخة النهائية مع الهوية الرقمية (سند) لضمان التحقق بنسبة 100%.';

  @override
  String get aiPulseStampOk => 'STAMP_DETECTED';

  @override
  String get aiPulseIdMatch => 'ID_CONFIRMED';

  @override
  String get aiPulseExpiryValid => 'VALID_EXPIRY';

  @override
  String get aiPulseSecurePaper => 'SECURITY_PAPER_OK';

  @override
  String get aiLivenessCheck => 'تم التحقق من حيوية الصورة بالذكاء الاصطناعي';

  @override
  String get signupCuisineType => 'المطبخ / نوع العمل';

  @override
  String get signupCuisineTypeHint => 'مثال: إيطالي، وجبات سريعة، مخبز';

  @override
  String get signupPrimaryCategory => 'المنتج الأساسي / الفئة';

  @override
  String get signupPrimaryCategoryHint => 'مثال: منتجات طازجة، ألبان';

  @override
  String get signupSectionVehicle => 'معلومات المركبة';

  @override
  String get signupVehiclePlate => 'رقم لوحة المركبة';

  @override
  String get signupVehiclePlateHint => 'مثال: أ 123456';

  @override
  String get signupVehicleModel => 'نوع المركبة وموديلها';

  @override
  String get signupVehicleModelHint => 'مثال: تويوتا بريوس 2020';

  @override
  String get signupVehicleColor => 'لون المركبة';

  @override
  String get signupVehicleColorHint => 'مثال: أبيض';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات بعد';

  @override
  String get notificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get orderSearchingDriver => 'جارٍ البحث عن أقرب سائق متاح...';

  @override
  String get orderSearchingDriverRetry => 'إعادة البحث عن سائق';

  @override
  String get vehicleScanTitle => 'مسح استمارة المركبة';

  @override
  String get vehicleScanOptional => 'اختياري';

  @override
  String get vehicleScanPrompt => 'امسح الاستمارة لملء البيانات تلقائياً';

  @override
  String get vehicleScanTypeHint => 'يُحدَّد نوع المركبة من الوثيقة';

  @override
  String get vehicleScanStepType => 'فحص نوع المركبة...';

  @override
  String get vehicleScanStepPlate => 'قراءة رقم اللوحة...';

  @override
  String get vehicleScanStepModel => 'تحليل موديل السيارة...';

  @override
  String get vehicleScanStepExpiry => 'التحقق من تاريخ الانتهاء...';

  @override
  String get vehicleScanPulseType => 'نوع المركبة ✓';

  @override
  String get vehicleScanPulsePlate => 'رقم اللوحة...';

  @override
  String get vehicleScanPulseModel => 'الموديل ✓';

  @override
  String get vehicleScanPulseExpiry => 'تاريخ الانتهاء...';

  @override
  String get vehicleScanPulseColor => 'اللون ✓';

  @override
  String get vehicleScanPulseValid => 'الاستمارة سارية';

  @override
  String get vehicleScanReadSuccess => 'تم قراءة الوثيقة بنجاح';

  @override
  String get vehicleScanReviewPrompt => 'راجع البيانات وأكّد';

  @override
  String get vehicleScanRescanTooltip => 'إعادة المسح';

  @override
  String get vehicleScanConfirmAutoFill => 'تأكيد وملء البيانات تلقائياً';

  @override
  String get vehicleScanExtractedData => 'البيانات المستخرجة';

  @override
  String get vehicleScanRowModel => 'الموديل';

  @override
  String get vehicleScanRowColor => 'اللون';

  @override
  String get vehicleScanRowPlate => 'رقم اللوحة';

  @override
  String get vehicleScanRowExpiry => 'تاريخ انتهاء الاستمارة';

  @override
  String get vehicleScanChemicalPermit => 'تصريح نقل مواد كيميائية';

  @override
  String get vehicleScanChemicalPermitHint =>
      'سيتم تصفية الطلبات تلقائياً بناءً على نوع مركبتك';

  @override
  String get vehicleScanAccuracy => 'دقة';

  @override
  String get vehicleScanReadFailed => 'تعذّر قراءة الوثيقة';

  @override
  String get licenseScanUploadPrompt => 'انقر لرفع الوثيقة';

  @override
  String get licenseScanSourcesHint => 'كاميرا أو معرض الصور';

  @override
  String get licenseScanSuggestedCategories => 'فئات مقترحة في السوق';

  @override
  String get signupLocationPermissionDenied =>
      'يرجى السماح بالوصول للموقع من إعدادات الجهاز';

  @override
  String signupLocationError(String error) {
    return 'تعذّر تحديد الموقع: $error';
  }

  @override
  String get signupLocating => 'جاري تحديد موقعك...';

  @override
  String get signupSkip => 'تخطي';

  @override
  String get signupIdentityLabel => 'هويتك';

  @override
  String get signupRoleDetailsLabel => 'تفاصيل الدور';

  @override
  String get signupVehicleInfoTitle => 'معلومات المركبة';

  @override
  String get signupYourWasteTypes => 'أنواع النفايات لديك';

  @override
  String get signupAcceptedWasteTypes => 'أنواع النفايات المقبولة';

  @override
  String get signupSelectOneOrMore => 'اختر واحداً أو أكثر';

  @override
  String get signupSaveAndComplete => 'حفظ وإكمال';

  @override
  String get signupSkipCompleteLater => 'تخطي الآن، سأكمل لاحقاً';

  @override
  String get signupUpdateAnytime =>
      'يمكنك تحديث هذه البيانات في أي وقت من إعدادات حسابك.';

  @override
  String get signupRoleDriverHeading => 'معلومات مركبتك';

  @override
  String get signupRoleSupplierHeading => 'ما الذي تودّ تدويره؟';

  @override
  String get signupRoleRecyclingHeading => 'ما الذي تقبله منشأتك؟';

  @override
  String get signupRoleDriverBody =>
      'أضف لوحة مركبتك لبدء استلام الطلبات. يمكنك مسح الاستمارة تلقائياً.';

  @override
  String get signupRoleSupplierBody =>
      'حدد أنواع النفايات لديك لتلقي العروض المناسبة لك مباشرةً.';

  @override
  String get signupRoleRecyclingBody =>
      'حدد ما تقبله منشأتك من مواد لمساعدة الموردين على إيجادك.';

  @override
  String get signupPlateNumberLabel => 'رقم لوحة المركبة';

  @override
  String get signupPlateNumberHint => 'مثال: 12 أ ب ج';

  @override
  String get signupWelcomeTo => 'أهلاً بك في دوّر!';

  @override
  String get signupCreateIdentityHeading => 'لنبدأ بإنشاء هويتك الرقمية';

  @override
  String get signupProfilePhotoLabel => 'الصورة الشخصية';

  @override
  String get signupAccountTypePrompt => 'ما نوع حسابك؟';

  @override
  String get signupPrivacyNotice =>
      'سيتم استخدام بياناتك لإنشاء حسابك فقط، ولن تُشارك مع أي طرف ثالث.';

  @override
  String get signupSmsVerification => 'سنتحقق من رقمك عبر رسالة نصية';

  @override
  String get signupRoleIndividualLabel => 'فرد';

  @override
  String get signupRoleStoreLabel => 'متجر / مطعم';

  @override
  String recyclingIncomingShipmentsCount(int count) {
    return 'الشحنات الواردة ($count)';
  }

  @override
  String recyclingActiveJobsCount(int count) {
    return 'الوظائف النشطة ($count)';
  }

  @override
  String get recyclingTodayOperations => 'عمليات اليوم';

  @override
  String get recyclingNoActiveDrivers => 'لا يوجد سائقون نشطون الآن';

  @override
  String get recyclingReconnecting => 'إعادة الاتصال…';

  @override
  String get recyclingFacility => 'منشأة تدوير';

  @override
  String get recyclingReadyForReceipt => 'مستعد للاستلام';

  @override
  String get recyclingTotalWeightKg => 'إجمالي الوزن (كغ)';

  @override
  String get recyclingDriversEnRoute => 'سائقين بالطريق';

  @override
  String get recyclingResponses => 'استجابات';

  @override
  String get recyclingShowDetails => 'عرض التفاصيل';

  @override
  String recyclingCommittedCount(int count) {
    return 'الملتزمون ($count)';
  }

  @override
  String get recyclingFilterHasAcceptors => 'لديه ملتزمون';

  @override
  String get recyclingFilterNoAcceptors => 'لا يوجد ملتزمون';

  @override
  String get recyclingFilterFlatFee => 'مبلغ ثابت';

  @override
  String get recyclingFilterPerKg => 'بالكيلو';

  @override
  String get recyclingWithdrawAdTitle => 'سحب الإعلان';

  @override
  String get recyclingWithdrawAdBody =>
      'هل أنت متأكد من سحب هذا الإعلان من السوق؟';

  @override
  String get recyclingWithdrawAdConfirm => 'نعم، اسحب الإعلان';

  @override
  String recyclingMaxListingsReached(int count) {
    return 'وصلت للحد الأقصى ($count إعلانات نشطة)';
  }

  @override
  String get collectionJobPaymentModelLabel => 'نموذج الدفع *';

  @override
  String collectionJobPriceLabel(String unit) {
    return 'السعر * ($unit)';
  }

  @override
  String get collectionJobPricePerKgHint => 'مثال: 2.5 د.أ لكل كغ';

  @override
  String get collectionJobPriceFlatHint => 'مثال: 25 د.أ للرحلة';

  @override
  String get collectionJobMinQtyLabel => 'الحد الأدنى للكمية (كغ) — اختياري';

  @override
  String get collectionJobMinQtyHint => 'مثال: 10';

  @override
  String get collectionJobAreaHint => 'مثال: الرابية، عمّان';

  @override
  String get collectionJobDescHint =>
      'اشرح ما تحتاجه، المواصفات المطلوبة، وسبب الطلب...';

  @override
  String get collectionJobFlatFeeLabel => 'أجر ثابت';

  @override
  String get collectionJobPerKgLabel => 'لكل كيلوغرام';

  @override
  String get supplierMyOrdersCurrent => 'طلباتي الحالية';

  @override
  String get supplierNoActiveOrders => 'لا توجد طلبات نشطة';

  @override
  String get supplierStartRecyclingCta =>
      'ابدأ بإضافة أول طلب إعادة تدوير الآن!';

  @override
  String get supplierStartMarketCta => 'أضف أول عرض للسوق الآن!';

  @override
  String supplierWelcome(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get supplierAccountIndividual => 'حساب أفراد';

  @override
  String get supplierAccountBusiness => 'مورد تجاري';

  @override
  String get supplierMyPoints => 'نقاطي';

  @override
  String get supplierTotalWeight => 'إجمالي الوزن';

  @override
  String get supplierWeightZero => '0 كغ';

  @override
  String get supplierTreesSaved => 'أشجار أُنقذت';

  @override
  String get supplierOrderPendingDriver => 'بانتظار قبول سائق للطلب';

  @override
  String get supplierOrderAcceptedOnWay => 'تم قبول طلبك، السائق في طريقه إليك';

  @override
  String get supplierOrderDriverArrivedPickup => 'السائق وصل لموقع الاستلام';

  @override
  String get supplierOrderInTransitToDest => 'طلبك في الطريق إلى وجهته';

  @override
  String get supplierOrderDriverArrivedDropoff => 'السائق وصل لموقع التسليم';

  @override
  String get supplierOrderDeliveredSuccess => 'تم تسليم الطلب بنجاح';

  @override
  String get supplierOrderCancelledDone => 'تم إلغاء الطلب';

  @override
  String get driverDeliveryHubs => 'مراكز التسليم المتاحة';

  @override
  String get driverActiveOrderTitle => 'الطلب النشط الحالي';

  @override
  String get driverHubsUnavailable =>
      'مراكز التسليم غير متاحة — تحقق من الاتصال';

  @override
  String get driverStatusReady => 'جاهز';

  @override
  String get driverStatusCollecting => 'قيد الجمع';

  @override
  String get hubCapacity => 'سعة مركز التجميع';

  @override
  String get hubBreakdown => 'تفاصيل المواد';

  @override
  String get cookingOilLabel => 'زيت طهي';

  @override
  String get plasticLabel => 'بلاستيك';

  @override
  String get paperLabel => 'ورق';

  @override
  String get electronicsLabel => 'إلكترونيات';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get nextShipment => 'الشحنة القادمة';

  @override
  String get lastShipment => 'آخر شحنة';

  @override
  String get driverUnavailableBottomTitle => 'غير متاح للعمل';

  @override
  String get driverUnavailableBottomSubtitle =>
      'فعّل وضع التوفر لاستقبال الطلبات الجديدة';

  @override
  String get driverEnableNow => 'تفعيل الآن';

  @override
  String get driverNoOrdersAvailable => 'لا توجد طلبات متاحة حالياً';

  @override
  String get driverNewOrderNotifications =>
      'ستصلك إشعارات عند توفر طلبات جديدة';

  @override
  String get profileAvatarFallback => 'س';

  @override
  String get profileEmailSupportSubject => 'مساعدة سائق';

  @override
  String get profileEnterManually => 'أو أدخل يدوياً';

  @override
  String get profilePlateLabel => 'رقم اللوحة';

  @override
  String profileVehicleTypeLabel(String type) {
    return 'نوع المركبة: $type';
  }

  @override
  String get driverOrderCardVehicleFallback => 'مركبة';

  @override
  String get currencyJodShort => 'د.أ';

  @override
  String get monthJanuary => 'يناير';

  @override
  String get monthFebruary => 'فبراير';

  @override
  String get monthMarch => 'مارس';

  @override
  String get monthApril => 'أبريل';

  @override
  String get monthMay => 'مايو';

  @override
  String get monthJune => 'يونيو';

  @override
  String get monthJuly => 'يوليو';

  @override
  String get monthAugust => 'أغسطس';

  @override
  String get monthSeptember => 'سبتمبر';

  @override
  String get monthOctober => 'أكتوبر';

  @override
  String get monthNovember => 'نوفمبر';

  @override
  String get monthDecember => 'ديسمبر';

  @override
  String get wizardStep1Title => 'ماذا تريد أن تبيع؟';

  @override
  String get wizardStep1Subtitle => 'أضف تفاصيل المواد التي تريد بيعها';

  @override
  String get wizardMaterialPhotosOptional => 'صور المواد — اختياري';

  @override
  String get wizardMaterialTypeRequired => 'نوع المواد *';

  @override
  String get wizardAiAnalyzing => 'يقوم الفريق الذكي بتحليل طلبك...';

  @override
  String wizardAiAnalysisFailed(String error) {
    return 'فشل في تحليل الصورة: $error';
  }

  @override
  String get wizardStep2Title => 'تفاصيل المادة';

  @override
  String get wizardStep2Subtitle => 'حدد الكمية والحالة والسعر المطلوب';

  @override
  String get wizardMaterialCondition => 'حالة المواد *';

  @override
  String get wizardQuantitySize => 'حجم الكمية *';

  @override
  String get wizardRequestedPrice => 'السعر المطلوب (د.أ) — اختياري';

  @override
  String get wizardStep3Title => 'آخر خطوة!';

  @override
  String get wizardStep3Subtitle => 'حدد موقع الاستلام وراجع الإعلان قبل النشر';

  @override
  String get wizardPickupAddress => 'عنوان الاستلام *';

  @override
  String get wizardTapToSetLocation => 'اضغط لتحديد الموقع على الخريطة';

  @override
  String get wizardNotesOptional => 'ملاحظات — اختياري';

  @override
  String get wizardNotesHint => 'مثال: المواد موجودة خلف المستودع...';

  @override
  String get wizardListingSummary => 'ملخص الإعلان والتأثير البيئي';

  @override
  String get wizardChangeLocation => 'تغيير الموقع';

  @override
  String get wizardUseCurrentLocation => 'استخدام موقعي الحالي';

  @override
  String get wizardSummaryMaterialType => 'نوع المواد';

  @override
  String get wizardSummaryCondition => 'الحالة';

  @override
  String get wizardSummaryQuantity => 'الكمية';

  @override
  String get wizardSummaryPrice => 'السعر';

  @override
  String get wizardPriceUndefined => 'غير محدد';

  @override
  String get wizardCo2Savings => 'توفير CO2';

  @override
  String get wizardWaterSavings => 'توفير مياه';

  @override
  String wizardWaterLiters(String liters) {
    return '$liters لتر';
  }

  @override
  String get wizardLocationDefined => 'موقع محدد';

  @override
  String get wizardPublishedToMarket => 'تم النشر في السوق بنجاح! ✓';

  @override
  String get wizardPickupRequestSent => 'تم إرسال طلب الاستلام بنجاح! ✓';

  @override
  String get wizardPickupRequestFailed => 'فشل في إرسال طلب الاستلام';

  @override
  String get wizardNewPickupTitle => 'طلب استلام جديد';

  @override
  String get wizardPublishToMarket => 'نشر في السوق';

  @override
  String get driverActiveOrderViewPickupDetails => 'عرض تفاصيل الاستلام';

  @override
  String get driverActiveOrderViewDeliveryDetails => 'عرض تفاصيل التسليم';

  @override
  String get driverActiveOrderStepAccepted => 'مقبول';

  @override
  String get driverActiveOrderStepArrivedPickup => 'وصلت\nللاستلام';

  @override
  String get driverActiveOrderStepInTransit => 'في\nالطريق';

  @override
  String get driverActiveOrderStepDelivered => 'تم\nالتسليم';

  @override
  String driverActiveOrderEtaMinutes(String minutes) {
    return '$minutes د';
  }

  @override
  String get proofCancelTitle => 'إلغاء توثيق الاستلام؟';

  @override
  String get proofCancelBody => 'ستُفقد الصورة والوزن المُدخل.';

  @override
  String get proofBack => 'تراجع';

  @override
  String get proofTitle => 'توثيق الاستلام';

  @override
  String get proofShipmentWeight => 'وزن الشحنة (كغ)';

  @override
  String get proofChangePhoto => 'تغيير الصورة';

  @override
  String get proofPhotoCaptured => 'صورة مُلتقطة ✓';

  @override
  String get proofCapturePhoto => 'التقط صورة الشحنة';

  @override
  String get proofRetry => 'إعادة المحاولة';

  @override
  String get proofConfirmPickup => 'تأكيد الاستلام';

  @override
  String get proofSuccessTitle => 'تم توثيق الاستلام';

  @override
  String get proofSuccessBody => 'سيتم إشعار المورّد الآن';

  @override
  String get driverErrorToggleOfflineWithActive =>
      'لا يمكنك تغيير حالتك إلى غير متاح أثناء وجود طلب نشط.';

  @override
  String get driverErrorAcceptWhileOffline =>
      'أنت غير متاح حالياً. لا يمكنك قبول الطلب.';

  @override
  String get driverErrorLocationUnavailable =>
      'تعذّر تحديد موقعك. تحقق من صلاحية الموقع.';

  @override
  String driverErrorTooFarPickup(int meters) {
    return 'أنت بعيد جداً عن موقع الاستلام ($meters م). يجب أن تكون ضمن 200 م.';
  }

  @override
  String driverErrorTooFarDelivery(int meters) {
    return 'أنت بعيد جداً عن موقع التسليم ($meters م). يجب أن تكون ضمن 200 م.';
  }

  @override
  String get driverErrorServerGeofence =>
      'التحقق من الموقع فشل على الخادم. يجب أن تكون ضمن 200 م.';

  @override
  String get earningsFilterMonth => 'شهر';

  @override
  String get earningsFilterWeek => 'أسبوع';

  @override
  String get earningsFilterDay => 'يوم';

  @override
  String get earningsTitle => 'الأرباح';

  @override
  String get earningsNetTotal => 'إجمالي الأرباح الصافية';

  @override
  String get earningsIncreaseVsPrev => 'زيادة عن الفترة السابقة';

  @override
  String get earningsFinancialDetails => 'تفاصيل العوائد المالية';

  @override
  String get earningsDistanceFees => 'رسوم المسافات';

  @override
  String get earningsNetTotalLabel => 'المجموع الصافي';

  @override
  String get earningsBestDay => 'يومك الأفضل';

  @override
  String get weekdayMonday => 'الإثنين';

  @override
  String get weekdayTuesday => 'الثلاثاء';

  @override
  String get weekdayWednesday => 'الأربعاء';

  @override
  String get weekdayThursday => 'الخميس';

  @override
  String get weekdayFriday => 'الجمعة';

  @override
  String get weekdaySaturday => 'السبت';

  @override
  String get weekdaySunday => 'الأحد';

  @override
  String get earningsMyEarnings => 'أرباحي';

  @override
  String get earningsRefresh => 'تحديث البيانات';

  @override
  String get earningsTrend => 'اتجاه الأرباح';

  @override
  String get earningsRecentActivity => 'النشاط الأخير';

  @override
  String get earningsDownloadReport => 'تحميل تقرير الأداء';

  @override
  String get earningsTotalEarnings => 'إجمالي الأرباح';

  @override
  String get earningsTripsCount => 'عدد الرحلات';

  @override
  String get earningsAverage => 'متوسط الأرباح';

  @override
  String get chatDateToday => 'اليوم';

  @override
  String get chatDateYesterday => 'أمس';

  @override
  String get chatTyping => 'يكتب الآن';

  @override
  String get unitKg => 'كغ';

  @override
  String get unitKm => 'كم';

  @override
  String get orderArrivalAtPickup => 'وصلت إلى موقع الاستلام؟';

  @override
  String get orderArrivalGeoNote => 'سيتم التحقق من موقعك (ضمن 200 م)';

  @override
  String get orderArrivalHerePickup => 'أنا هنا — الاستلام';

  @override
  String get orderArrivalAtDropoff => 'وصلت إلى موقع التسليم؟';

  @override
  String get orderArrivalHereDropoff => 'أنا هنا — التسليم';

  @override
  String get orderArrivalAwaitingSupplier => 'في انتظار تأكيد المورد';

  @override
  String get orderArrivalAwaitingSubtitle =>
      'المورد لديه 5 دقائق للرد — سيُعوَّض السائق تلقائياً عند انتهاء المهلة';

  @override
  String get orderArrivalDriverArrived => 'السائق وصل!';

  @override
  String get orderArrivalDriverAtLocation =>
      'السائق في موقعك الآن. هل أنت متاح لتسليم المواد؟';

  @override
  String get orderArrivalIAmAvailable => 'أنا متاح';

  @override
  String get acceptJobTitle => 'كيف تريد المتابعة؟';

  @override
  String get acceptJobSubtitle =>
      'اختر طريقة التوصيل ونوع المعاملة لقبول الوظيفة';

  @override
  String get acceptJobDeliveryFeeCompany => 'رسوم التوصيل على الشركة';

  @override
  String get acceptJobDeliveryFeeYou => 'رسوم التوصيل عليك';

  @override
  String get acceptJobConfirmButton => 'تأكيد القبول';

  @override
  String get marketDeliveryConfirmTitle => 'تأكيد الشراء والتوصيل';

  @override
  String get marketDeliveryFeeNote => 'رسوم التوصيل محسوبة حسب المسافة والوزن';

  @override
  String get marketDeliverySellerLocation => 'موقع البائع';

  @override
  String get marketDeliveryAddressLabel => 'عنوان التوصيل';

  @override
  String marketDeliveryDistanceFeeRow(String distance) {
    return 'رسوم المسافة ($distance كم × 0.2)';
  }

  @override
  String marketDeliveryWeightFeeRow(String weight) {
    return 'رسوم الوزن ($weight)';
  }

  @override
  String get marketDeliveryBaseFee => 'رسوم التوصيل الأساسية';

  @override
  String get marketDeliveryTotal => 'الإجمالي';

  @override
  String marketDeliveryConfirmButton(String total) {
    return 'تأكيد الشراء — $total';
  }

  @override
  String get marketPurchaseChoiceTitle => 'اختر طريقة الاستلام';

  @override
  String get marketPurchaseChoiceSubtitle =>
      'يمكنك الاستلام بنفسك أو تعيين سائق للتوصيل';

  @override
  String get marketPurchaseSelfPickup => 'استلام من السوق';

  @override
  String get marketPurchaseNoFee => 'بدون رسوم توصيل';

  @override
  String get marketPurchaseAssignRider => 'تعيين سائق للتوصيل';

  @override
  String get marketPurchaseRiderFeeNote =>
      'حساب رسوم التوصيل حسب المسافة والوزن';

  @override
  String get walletTitle => 'محفظتي';

  @override
  String get walletPointsAndRewards => 'نقاطي ومكافآتي';

  @override
  String get walletBillingPayments => 'الفوترة والمدفوعات';

  @override
  String get walletAvailableBalance => 'الرصيد المتاح';

  @override
  String get walletHeldAmount => 'المحجوز';

  @override
  String get walletWithdrawButton => 'طلب صرف رصيد';

  @override
  String get walletPointUnit => 'نقطة';

  @override
  String walletPointsToNextReward(String n) {
    return 'تبقّى $n نقطة للمكافأة القادمة';
  }

  @override
  String get walletViewRewards => 'عرض المكافآت';

  @override
  String get walletCurrentPeriod => 'الفترة الحالية:';

  @override
  String get walletShipments => 'الشحنات';

  @override
  String get walletWeightKg => 'الوزن (كغ)';

  @override
  String get walletViewInvoice => 'عرض الفاتورة';

  @override
  String get walletEfawateerTitle => 'الدفع عبر فواتيركم';

  @override
  String get walletEfawateerSubtitle => 'منصة الدفع الإلكتروني الحكومية';

  @override
  String analyticsStreakChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🔥 # يوم متتالٍ',
      many: '🔥 # يوماً متتالياً',
      few: '🔥 # أيام متتالية',
      two: '🔥 يومان متتاليان',
      one: '🔥 يوم متتالٍ',
    );
    return '$_temp0';
  }

  @override
  String get analyticsStreakSectionTitle => 'سلسلة النشاط';

  @override
  String analyticsStreakBest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# يوم',
      many: '# يوماً',
      few: '# أيام',
      two: 'يومان',
      one: 'يوم',
    );
    return 'أطول سلسلة: $_temp0';
  }

  @override
  String get analyticsStreakEmpty => 'لا يوجد نشاط بعد — ابدأ أول طلب اليوم!';

  @override
  String get analyticsCycleSectionTitle => 'زمن دورة الطلب';

  @override
  String analyticsCycleAvgCaption(int minutes) {
    return 'متوسط زمن الطلب الكامل: $minutes دقيقة';
  }

  @override
  String get analyticsCycleStageAccept => 'الانتظار حتى القبول';

  @override
  String get analyticsCycleStagePickup => 'الوصول للالتقاط';

  @override
  String get analyticsCycleStageTransit => 'النقل';

  @override
  String get analyticsCycleStageDropoff => 'التسليم';

  @override
  String analyticsCycleMinutes(String minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get analyticsCycleEmpty => 'لا توجد بيانات كافية لتحليل زمن الطلب';

  @override
  String get analyticsProfitabilitySectionTitle => 'أربح المواد';

  @override
  String analyticsProfitabilityPerKg(String value) {
    return '$value د.أ/كغ';
  }

  @override
  String get analyticsProfitabilityTopBadge => '🏆 الأعلى ربحًا';

  @override
  String get analyticsProfitabilityEmpty =>
      'لا توجد بيانات كافية لتحليل ربحية المواد';

  @override
  String get analyticsEfficiencySectionTitle => 'كفاءة الأرباح';

  @override
  String get analyticsEfficiencyRatioCaption => 'متوسط ما تربحه لكل كيلومتر';

  @override
  String analyticsEfficiencyRatioValue(String value) {
    return '$value د.أ/كم';
  }

  @override
  String get analyticsEfficiencyTopJobs => 'أفضل الرحلات';

  @override
  String get analyticsEfficiencyEmpty => 'لا توجد بيانات مسافة لحساب الكفاءة';

  @override
  String get aboutDwaarButtonLabel => 'تعرّف على دوّر';

  @override
  String get aboutDwaarSheetTitle => 'من نحن وماذا نقدّم';

  @override
  String get aboutDwaarIntroBody =>
      'دوّر (Dwaar) منصة أردنية تربط بين ثلاثة أطراف: الموردين الذين لديهم نفايات قابلة لإعادة التدوير، السائقين الذين ينقلونها، وشركات إعادة التدوير التي تشتريها. هدفنا تحويل النفايات إلى مورد ذو قيمة، وتسهيل الاقتصاد الدائري في الأردن بخطوات بسيطة من هاتفك.';

  @override
  String get aboutDwaarServicesTitle => 'خدماتنا لكل طرف';

  @override
  String get aboutDwaarServiceSupplierTitle => 'للموردين (أفراد ومتاجر)';

  @override
  String get aboutDwaarServiceSupplierBody =>
      'اطلب استلام نفاياتك القابلة لإعادة التدوير من موقعك، اختر بيعها لشركة تدوير أو عرضها في السوق لأقرب سائق، واربح نقاط ومكافآت مقابل كل عملية.';

  @override
  String get aboutDwaarServiceDriverTitle => 'للسائقين';

  @override
  String get aboutDwaarServiceDriverBody =>
      'تصفّح طلبات الاستلام القريبة منك حسب نوع مركبتك، اقبل الطلب المناسب، وتتبّع أرباحك لحظة بلحظة مع كل رحلة تُنجزها.';

  @override
  String get aboutDwaarServiceRecyclingTitle => 'لشركات إعادة التدوير';

  @override
  String get aboutDwaarServiceRecyclingBody =>
      'انشر طلبات تجميع بحسب نوع المادة والكمية والمنطقة، واستقبل تدفقًا منظّمًا وموثّقًا من المواد الخام مباشرة من الموردين والسائقين.';

  @override
  String get aboutDwaarHowItWorksTitle => 'كيف تعمل دورة الطلب؟';

  @override
  String get aboutDwaarHowItWorksStep1 =>
      '١. المورد يطلب استلام النفايات ويحدّد النوع والوزن التقريبي والموقع';

  @override
  String get aboutDwaarHowItWorksStep2 =>
      '٢. سائق مناسب يقبل الطلب، ويظهر موقعه المباشر على الخريطة حتى الوصول';

  @override
  String get aboutDwaarHowItWorksStep3 =>
      '٣. عند التسليم، يتم توثيق الوزن الفعلي وتأكيد الاستلام من الطرفين';

  @override
  String get aboutDwaarHowItWorksStep4 =>
      '٤. تُصرف المكافآت والأرباح تلقائيًا، وتنتقل المواد إلى شركة إعادة التدوير أو المركز الأقرب';

  @override
  String get aboutDwaarRewardsTitle => 'نظام المكافآت (نقاط خُضَر)';

  @override
  String get aboutDwaarRewardsBody =>
      'كل عملية تدوير مكتملة تمنحك نقاط خُضَر بحسب نوع المادة ووزنها. اجمع النقاط لترتقي في مستويات البطاقة الخضراء، واستبدلها بخصومات على الطلبات القادمة أو قسائم شراء من شركائنا. السائقون أيضًا يحصلون على أجرة لكل رحلة تُحتسب من الأجرة الأساسية والمسافة ونوع المادة المنقولة.';

  @override
  String get aboutDwaarHubsTitle => 'مراكز التجميع (Hubs)';

  @override
  String get aboutDwaarHubsBody =>
      'مراكز التجميع نقاط استلام فعلية تديرها فرق دوّر، يستخدمها السائقون كوجهة تسليم قريبة بدل التوجه مباشرة لكل شركة تدوير. إذا كانت لديك منشأة أو أرض مناسبة وتودّ استضافة مركز تجميع جديد في منطقتك، تواصل معنا عبر النموذج أدناه وسيقيّم فريقنا الطلب.';

  @override
  String get aboutDwaarImpactTitle => 'أثرنا حتى الآن';

  @override
  String get aboutDwaarImpactSubtitle => 'لمحة حيّة عمّا حققه مجتمعنا معًا';

  @override
  String get aboutDwaarImpactOrders => 'طلبات مكتملة';

  @override
  String get aboutDwaarImpactWeight => 'وزن معاد تدويره';

  @override
  String get aboutDwaarImpactCo2 => 'CO₂ وُفِّر';

  @override
  String get aboutDwaarImpactWater => 'مياه وُفِّرت';

  @override
  String get aboutDwaarImpactEnergy => 'طاقة وُفِّرت';

  @override
  String get aboutDwaarImpactDownloadButton => 'تنزيل شهادة CO₂ (PDF)';

  @override
  String get aboutDwaarImpactDownloadGenerating => 'جاري الإنشاء...';

  @override
  String get aboutDwaarImpactDownloadError =>
      'تعذّر إنشاء الشهادة. حاول مرة أخرى.';

  @override
  String get aboutDwaarDataTitle => 'هل تريد شراء بياناتنا أو الشراكة معنا؟';

  @override
  String get aboutDwaarDataBody =>
      'نوفّر لبعض الجهات (بلديات، جهات بحثية، شركات استدامة) بيانات مجمّعة وغير شخصية حول أنماط التدوير. إن كنت مهتمًا بشراء بيانات أو ببناء شراكة، اترك بياناتك وسيتواصل معك فريقنا عبر البريد الإلكتروني.';

  @override
  String get aboutDwaarDataFormCompanyLabel => 'اسم الجهة / الشركة';

  @override
  String get aboutDwaarDataFormContactNameLabel => 'اسم الشخص المسؤول';

  @override
  String get aboutDwaarDataFormEmailLabel => 'البريد الإلكتروني للتواصل';

  @override
  String get aboutDwaarDataFormPhoneLabel => 'رقم الهاتف (اختياري)';

  @override
  String get aboutDwaarDataFormMessageLabel => 'تفاصيل طلبك';

  @override
  String get aboutDwaarDataFormMessageHint =>
      'ما نوع البيانات أو الشراكة التي تبحث عنها؟';

  @override
  String get aboutDwaarDataFormSubmit => 'إرسال الطلب';

  @override
  String get aboutDwaarDataFormSubmitting => 'جاري الإرسال...';

  @override
  String get aboutDwaarDataFormRequired => 'هذا الحقل مطلوب';

  @override
  String get aboutDwaarDataFormEmailInvalid => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get aboutDwaarDataFormSuccess =>
      'تم استلام طلبك، سيتواصل معك فريقنا عبر بريدك الإلكتروني قريبًا.';

  @override
  String get aboutDwaarDataFormError => 'تعذّر إرسال الطلب، حاول مرة أخرى';

  @override
  String get aboutDwaarCloseButton => 'إغلاق';

  @override
  String get reservationBookButton => 'حجز الآن';

  @override
  String get reservationFormTitle => 'إنشاء حجز جديد';

  @override
  String get reservationItemTitleLabel => 'وصف الطلب';

  @override
  String get reservationItemTitleHint => 'مثال: طاولة لأربعة أشخاص، ٧ مساءً';

  @override
  String get reservationBuyerPhoneLabel => 'رقم هاتف المشتري';

  @override
  String get reservationBuyerPhoneHint => '7XXXXXXXX';

  @override
  String get reservationBuyerNotFound => 'رقم الهاتف غير مسجل في التطبيق';

  @override
  String get reservationInvoiceAmountLabel => 'قيمة الفاتورة (د.أ)';

  @override
  String get reservationDurationLabel => 'مدة الحجز';

  @override
  String reservationDurationMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String reservationPenaltyBanner(String amount) {
    return 'تنبيه: سيتم خصم ١٠٪ من قيمة الفاتورة ($amount د.أ) من الطرف المخالف لضمان حقوق التعامل';
  }

  @override
  String get reservationSubmitButton => 'إنشاء الحجز';

  @override
  String get reservationCreateSuccess => 'تم إنشاء الحجز وإرساله للمشتري';

  @override
  String get reservationInboxTitle => 'طلبات الحجز';

  @override
  String get reservationEmptyInbox => 'لا توجد طلبات حجز حالياً';

  @override
  String get reservationInvoiceTotalLabel => 'المبلغ الإجمالي';

  @override
  String get reservationTimeRemainingLabel => 'الوقت المتبقي';

  @override
  String get reservationApproveButton => 'قبول وتثبيت الحجز';

  @override
  String get reservationApproveSuccess => 'تم تثبيت الحجز';

  @override
  String get reservationCompleteButton => 'تأكيد إتمام الشراء';

  @override
  String get reservationCancelButton => 'إلغاء الحجز';

  @override
  String get reservationCancelReasonTitle => 'سبب الإلغاء';

  @override
  String get reservationCancelReasonSoldElsewhere => 'تم بيع البضاعة لطرف آخر';

  @override
  String get reservationCancelReasonOther => 'سبب آخر';

  @override
  String get reservationCancelFraudWarning =>
      'تحذير: اختيار هذا السبب سيؤدي لخصم ١٠٪ من حسابك فوراً كتعويض للمشتري';

  @override
  String get reservationSellerTag => 'أنت البائع';

  @override
  String get reservationBuyerTag => 'أنت المشتري';

  @override
  String get errorConnectionFailed =>
      'فشل الاتصال بالشبكة. يرجى التحقق من اتصالك بالإنترنت وإعادة المحاولة.';

  @override
  String get errorPermissionDenied =>
      'عذراً، ليس لديك الصلاحية الكافية لإتمام هذه العملية.';

  @override
  String get errorUniqueViolation =>
      'البيانات التي تحاول إدخالها مسجلة مسبقاً في النظام.';

  @override
  String get errorForeignKeyViolation =>
      'البيانات المرتبطة غير صحيحة أو لم تعد موجودة.';

  @override
  String get errorTimeout =>
      'انتهت مهلة الاتصال بالخادم. يرجى المحاولة لاحقاً.';

  @override
  String get errorPhoneNotRegistered =>
      'رقم الهاتف غير مسجل. يرجى إنشاء حساب جديد.';

  @override
  String get errorInvalidOtp =>
      'رمز التحقق المدخل غير صحيح. يرجى إعادة المحاولة.';

  @override
  String get errorOtpLimitExceeded =>
      'لقد تجاوزت الحد الأقصى لطلب الرموز. يرجى المحاولة بعد قليل.';

  @override
  String get errorUnknown =>
      'حدث خطأ غير متوقع في النظام. يرجى المحاولة لاحقاً.';
}
