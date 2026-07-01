import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'دوّر'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'حوّل النفايات إلى قيمة'**
  String get appTagline;

  /// No description provided for @appSystemTitle.
  ///
  /// In ar, this message translates to:
  /// **'نظام إدارة تدوير النفايات الذكي'**
  String get appSystemTitle;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get saveChanges;

  /// No description provided for @saveEdits.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveEdits;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @or.
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get or;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد تسجيل الخروج؟'**
  String get logoutConfirm;

  /// No description provided for @logoutExit.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get logoutExit;

  /// No description provided for @alert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get alert;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get unavailable;

  /// No description provided for @greeting.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، {name}'**
  String greeting(String name);

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navMarket.
  ///
  /// In ar, this message translates to:
  /// **'السوق'**
  String get navMarket;

  /// No description provided for @navMyOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get navMyOrders;

  /// No description provided for @navProfile.
  ///
  /// In ar, this message translates to:
  /// **'الملف'**
  String get navProfile;

  /// No description provided for @navOrders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get navOrders;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePickerTitle.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get languagePickerTitle;

  /// No description provided for @themeTitle.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get themeTitle;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// No description provided for @themeAutoFull.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (نظام الهاتف)'**
  String get themeAutoFull;

  /// No description provided for @themeAutoShort.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get themeAutoShort;

  /// No description provided for @loginMethodEmail.
  ///
  /// In ar, this message translates to:
  /// **'بريد إلكتروني'**
  String get loginMethodEmail;

  /// No description provided for @loginMethodPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get loginMethodPhone;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get loginPhoneLabel;

  /// No description provided for @loginEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In ar, this message translates to:
  /// **'example@domain.com'**
  String get loginEmailHint;

  /// No description provided for @loginButton.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get loginNoAccount;

  /// No description provided for @loginSignUpNow.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الآن'**
  String get loginSignUpNow;

  /// No description provided for @registerAsDriver.
  ///
  /// In ar, this message translates to:
  /// **'سجل كسائق'**
  String get registerAsDriver;

  /// No description provided for @registerAsIndividual.
  ///
  /// In ar, this message translates to:
  /// **'سجل كمورد فردي'**
  String get registerAsIndividual;

  /// No description provided for @registerAsStore.
  ///
  /// In ar, this message translates to:
  /// **'سجل كمتجر / شركة'**
  String get registerAsStore;

  /// No description provided for @registerAsRecyclingCo.
  ///
  /// In ar, this message translates to:
  /// **'سجل كشركة إعادة تدوير'**
  String get registerAsRecyclingCo;

  /// No description provided for @loginCountrySearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get loginCountrySearch;

  /// No description provided for @loginCountrySearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن الدولة'**
  String get loginCountrySearchHint;

  /// No description provided for @roleSelectTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الحساب'**
  String get roleSelectTitle;

  /// No description provided for @roleDriver.
  ///
  /// In ar, this message translates to:
  /// **'سائق'**
  String get roleDriver;

  /// No description provided for @roleSupplier.
  ///
  /// In ar, this message translates to:
  /// **'مورد'**
  String get roleSupplier;

  /// No description provided for @roleRecyclingCo.
  ///
  /// In ar, this message translates to:
  /// **'شركة إعادة تدوير'**
  String get roleRecyclingCo;

  /// No description provided for @supplierTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع المورد'**
  String get supplierTypeLabel;

  /// No description provided for @supplierTypeIndividual.
  ///
  /// In ar, this message translates to:
  /// **'فرد'**
  String get supplierTypeIndividual;

  /// No description provided for @supplierTypeStore.
  ///
  /// In ar, this message translates to:
  /// **'متجر / مطعم'**
  String get supplierTypeStore;

  /// No description provided for @footerTerms.
  ///
  /// In ar, this message translates to:
  /// **'شروط الخدمة'**
  String get footerTerms;

  /// No description provided for @footerPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get footerPrivacy;

  /// No description provided for @footerInfra.
  ///
  /// In ar, this message translates to:
  /// **'DIGITAL INFRASTRUCTURE BY GOVERNMENT'**
  String get footerInfra;

  /// No description provided for @footerIdea.
  ///
  /// In ar, this message translates to:
  /// **'فكرة من عقول الشباب الأردني'**
  String get footerIdea;

  /// No description provided for @footerPolicyOk.
  ///
  /// In ar, this message translates to:
  /// **'حسناً، فهمت'**
  String get footerPolicyOk;

  /// No description provided for @footerPolicyBody.
  ///
  /// In ar, this message translates to:
  /// **'هذا النص هو نص تجريبي يوضح الشروط والأحكام وسياسة الخصوصية الخاصة بالتطبيق. سيتم تحديث هذا النص لاحقاً ليعكس السياسات الحقيقية والقانونية المعتمدة.\n\n• يلتزم المستخدم بجميع القوانين والأنظمة المعمول بها.\n• يحق للتطبيق الاحتفاظ ببعض البيانات الأساسية لتحسين الخدمة المقدمة.\n• نحتفظ بالحق في تعديل هذه الشروط في أي وقت مع إشعار المستخدمين.\n• خصوصية بياناتك تهمنا، ولن نقوم بمشاركتها مع أطراف ثالثة دون موافقتك الصريحة.\n• باستخدامك لهذا التطبيق، فإنك توافق على جميع الشروط والأحكام المذكورة هنا.'**
  String get footerPolicyBody;

  /// No description provided for @signupTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get signupTitle;

  /// No description provided for @signupCreateButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get signupCreateButton;

  /// No description provided for @signupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أكمل بياناتك للانضمام إلى منصة دوّر'**
  String get signupSubtitle;

  /// No description provided for @signupSectionBusiness.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الجهة'**
  String get signupSectionBusiness;

  /// No description provided for @signupCompanyName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الشركة'**
  String get signupCompanyName;

  /// No description provided for @signupStoreName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المتجر / المطعم'**
  String get signupStoreName;

  /// No description provided for @signupCompanyNameHint.
  ///
  /// In ar, this message translates to:
  /// **'شركة البيئة الخضراء'**
  String get signupCompanyNameHint;

  /// No description provided for @signupStoreNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مطعم الأصيل'**
  String get signupStoreNameHint;

  /// No description provided for @signupManagerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المدير'**
  String get signupManagerName;

  /// No description provided for @signupStoreOwnerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم صاحب المتجر'**
  String get signupStoreOwnerName;

  /// No description provided for @signupExampleName.
  ///
  /// In ar, this message translates to:
  /// **'محمد أحمد العبدالله'**
  String get signupExampleName;

  /// No description provided for @signupCoverageArea.
  ///
  /// In ar, this message translates to:
  /// **'منطقة الخدمة'**
  String get signupCoverageArea;

  /// No description provided for @signupCoverageHint.
  ///
  /// In ar, this message translates to:
  /// **'عمّان، الزرقاء، إربد...'**
  String get signupCoverageHint;

  /// No description provided for @signupSectionPersonal.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get signupSectionPersonal;

  /// No description provided for @signupFullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get signupFullName;

  /// No description provided for @signupFullNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أحمد محمد العبدالله'**
  String get signupFullNameHint;

  /// No description provided for @signupNationality.
  ///
  /// In ar, this message translates to:
  /// **'الجنسية'**
  String get signupNationality;

  /// No description provided for @signupJordanian.
  ///
  /// In ar, this message translates to:
  /// **'أردني'**
  String get signupJordanian;

  /// No description provided for @signupOther.
  ///
  /// In ar, this message translates to:
  /// **'غير ذلك'**
  String get signupOther;

  /// No description provided for @signupSectionDocuments.
  ///
  /// In ar, this message translates to:
  /// **'المستندات الرسمية'**
  String get signupSectionDocuments;

  /// No description provided for @signupNationalIdDocument.
  ///
  /// In ar, this message translates to:
  /// **'صورة الهوية الوطنية'**
  String get signupNationalIdDocument;

  /// No description provided for @signupCommercialRegisterDocument.
  ///
  /// In ar, this message translates to:
  /// **'صورة السجل التجاري'**
  String get signupCommercialRegisterDocument;

  /// No description provided for @signupBusinessLicenseDocument.
  ///
  /// In ar, this message translates to:
  /// **'صورة الترخيص التجاري'**
  String get signupBusinessLicenseDocument;

  /// No description provided for @signupUploadDocumentPrompt.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لرفع صورة المستند'**
  String get signupUploadDocumentPrompt;

  /// No description provided for @signupUploadDocumentSources.
  ///
  /// In ar, this message translates to:
  /// **'كاميرا أو معرض الصور'**
  String get signupUploadDocumentSources;

  /// No description provided for @signupDocumentUploaded.
  ///
  /// In ar, this message translates to:
  /// **'تم الرفع'**
  String get signupDocumentUploaded;

  /// No description provided for @signupSectionContact.
  ///
  /// In ar, this message translates to:
  /// **'معلومات التواصل'**
  String get signupSectionContact;

  /// No description provided for @signupContactRequired.
  ///
  /// In ar, this message translates to:
  /// **'يجب إدخال واحد على الأقل'**
  String get signupContactRequired;

  /// No description provided for @signupPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get signupPhone;

  /// No description provided for @signupPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'7X XXX XXXX'**
  String get signupPhoneHint;

  /// No description provided for @signupEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get signupEmailLabel;

  /// No description provided for @signupEmailHint.
  ///
  /// In ar, this message translates to:
  /// **'example@domain.com'**
  String get signupEmailHint;

  /// No description provided for @signupPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get signupPasswordLabel;

  /// No description provided for @signupPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'٨ أحرف على الأقل، حرف ورقم'**
  String get signupPasswordHint;

  /// No description provided for @signupPasswordConfirmLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get signupPasswordConfirmLabel;

  /// No description provided for @signupPasswordConfirmHint.
  ///
  /// In ar, this message translates to:
  /// **'أعد إدخال كلمة المرور'**
  String get signupPasswordConfirmHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get loginPasswordHint;

  /// No description provided for @roleDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'سائق'**
  String get roleDriverTitle;

  /// No description provided for @roleDriverSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم بجمع ونقل النفايات لكسب المال'**
  String get roleDriverSubtitle;

  /// No description provided for @roleSupplierTitle.
  ///
  /// In ar, this message translates to:
  /// **'مورد'**
  String get roleSupplierTitle;

  /// No description provided for @roleSupplierSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم ببيع نفاياتك وساهم في حماية البيئة'**
  String get roleSupplierSubtitle;

  /// No description provided for @roleRecyclingCoTitle.
  ///
  /// In ar, this message translates to:
  /// **'شركة إعادة تدوير'**
  String get roleRecyclingCoTitle;

  /// No description provided for @roleRecyclingCoSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استقبل المواد مباشرة في منشأتك'**
  String get roleRecyclingCoSubtitle;

  /// No description provided for @loginPhoneHelp.
  ///
  /// In ar, this message translates to:
  /// **'سنرسل لك رمزاً قصيراً لهذا الرقم للتحقق من هويتك'**
  String get loginPhoneHelp;

  /// No description provided for @loginPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'7X XXX XXXX'**
  String get loginPhoneHint;

  /// No description provided for @loginContinueButton.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get loginContinueButton;

  /// No description provided for @loginPhoneEmptyError.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال رقم الهاتف'**
  String get loginPhoneEmptyError;

  /// No description provided for @loginNewNumberHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم جديد؟ سيتم إنشاء حسابك بعد التحقق'**
  String get loginNewNumberHint;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكون من 6 أرقام المرسل إلى {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpVerifyButton.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get otpVerifyButton;

  /// No description provided for @otpResendButton.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get otpResendButton;

  /// No description provided for @otpResentMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الرمز مرة أخرى'**
  String get otpResentMessage;

  /// No description provided for @otpErrorIncomplete.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال الرمز كاملاً'**
  String get otpErrorIncomplete;

  /// No description provided for @otpErrorInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الرمز غير صحيح، حاول مرة أخرى'**
  String get otpErrorInvalid;

  /// No description provided for @otpSimulatedHint.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إرسال رمز التحقق إلى رقمك عبر SMS'**
  String get otpSimulatedHint;

  /// No description provided for @signupRoleDriver.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل سائق'**
  String get signupRoleDriver;

  /// No description provided for @signupRoleStoreBusiness.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل متجر / مطعم'**
  String get signupRoleStoreBusiness;

  /// No description provided for @signupRoleIndividualSupplier.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل مورد فردي'**
  String get signupRoleIndividualSupplier;

  /// No description provided for @signupRoleRecyclingCo.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل شركة إعادة تدوير'**
  String get signupRoleRecyclingCo;

  /// No description provided for @signupPhotoPersonal.
  ///
  /// In ar, this message translates to:
  /// **'الصورة الشخصية'**
  String get signupPhotoPersonal;

  /// No description provided for @signupPhotoOrganization.
  ///
  /// In ar, this message translates to:
  /// **'شعار الجهة'**
  String get signupPhotoOrganization;

  /// No description provided for @signupErrorManagerName.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال اسم المسؤول'**
  String get signupErrorManagerName;

  /// No description provided for @signupErrorDocumentRequired.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء رفع صورة المستند المطلوب'**
  String get signupErrorDocumentRequired;

  /// No description provided for @signupErrorEmailRequired.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مطلوب'**
  String get signupErrorEmailRequired;

  /// No description provided for @signupErrorPasswordRequired.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور مطلوبة'**
  String get signupErrorPasswordRequired;

  /// No description provided for @signupErrorPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get signupErrorPasswordMismatch;

  /// No description provided for @signupErrorSubmitFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إنشاء الحساب، حاول مجدداً'**
  String get signupErrorSubmitFailed;

  /// No description provided for @signupLocationTitle.
  ///
  /// In ar, this message translates to:
  /// **'الموقع الجغرافي'**
  String get signupLocationTitle;

  /// No description provided for @signupLocationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختياري — يساعد على تحديد مناطق الخدمة'**
  String get signupLocationSubtitle;

  /// No description provided for @signupLocationChange.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get signupLocationChange;

  /// No description provided for @signupLocationSelect.
  ///
  /// In ar, this message translates to:
  /// **'تحديد'**
  String get signupLocationSelect;

  /// No description provided for @signupLocationSelectPrompt.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لتحديد موقعك'**
  String get signupLocationSelectPrompt;

  /// No description provided for @signupLocationOpenMap.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لفتح خريطة الموقع'**
  String get signupLocationOpenMap;

  /// No description provided for @signupLocationPreciseLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنوان الدقيق'**
  String get signupLocationPreciseLabel;

  /// No description provided for @signupLocationPreciseHint.
  ///
  /// In ar, this message translates to:
  /// **'الشارع، البناية، الشقة، إلخ.'**
  String get signupLocationPreciseHint;

  /// No description provided for @onboardingCategoriesSelected.
  ///
  /// In ar, this message translates to:
  /// **'{count} محددة'**
  String onboardingCategoriesSelected(int count);

  /// No description provided for @onboardingCategoriesSuggested.
  ///
  /// In ar, this message translates to:
  /// **'الفئات المقترحة — اختر ما ينطبق'**
  String get onboardingCategoriesSuggested;

  /// No description provided for @onboardingCategoriesNote.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تعديل اختياراتك في أي وقت من إعدادات الملف الشخصي'**
  String get onboardingCategoriesNote;

  /// No description provided for @onboardingHighlightsTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما يميزك في التطبيق'**
  String get onboardingHighlightsTitle;

  /// No description provided for @onboardingHighlightsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مزايا ستحصل عليها بمجرد إنشاء الحساب'**
  String get onboardingHighlightsSubtitle;

  /// No description provided for @onboardingAiPanelTitle.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات الذكاء الاصطناعي'**
  String get onboardingAiPanelTitle;

  /// No description provided for @onboardingAiPanelSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فئات موصى بها وما يميزك في التطبيق'**
  String get onboardingAiPanelSubtitle;

  /// No description provided for @onboardingAiPanelContext.
  ///
  /// In ar, this message translates to:
  /// **'سيحلل الذكاء الاصطناعي معلوماتك ويقترح الفئات الأنسب لك، ويوضح ما يميزك أمام عملائك في التطبيق.'**
  String get onboardingAiPanelContext;

  /// No description provided for @onboardingTaglineLabel.
  ///
  /// In ar, this message translates to:
  /// **'شعارك أو رؤيتك'**
  String get onboardingTaglineLabel;

  /// No description provided for @onboardingTaglineHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: أفضل خدمة بأقل تكلفة'**
  String get onboardingTaglineHint;

  /// No description provided for @onboardingAiGenerateButton.
  ///
  /// In ar, this message translates to:
  /// **'احصل على اقتراحات الذكاء الاصطناعي'**
  String get onboardingAiGenerateButton;

  /// No description provided for @onboardingAiGenerating.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التوليد...'**
  String get onboardingAiGenerating;

  /// No description provided for @individualSupplierSignupTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب مورد فردي'**
  String get individualSupplierSignupTitle;

  /// No description provided for @recyclingCoSignupTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب شركة تدوير'**
  String get recyclingCoSignupTitle;

  /// No description provided for @storeSignupTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب متجر / شركة'**
  String get storeSignupTitle;

  /// No description provided for @onboardingHeaderSubtitleAi.
  ///
  /// In ar, this message translates to:
  /// **'أكمل النموذج وسيساعدك الذكاء الاصطناعي في اختيار الفئات'**
  String get onboardingHeaderSubtitleAi;

  /// No description provided for @onboardingSectionProfile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get onboardingSectionProfile;

  /// No description provided for @onboardingSectionProfileCompany.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي للشركة'**
  String get onboardingSectionProfileCompany;

  /// No description provided for @onboardingSectionProfileStore.
  ///
  /// In ar, this message translates to:
  /// **'ملف الشركة / المتجر'**
  String get onboardingSectionProfileStore;

  /// No description provided for @onboardingLabelCompanyLogo.
  ///
  /// In ar, this message translates to:
  /// **'شعار الشركة'**
  String get onboardingLabelCompanyLogo;

  /// No description provided for @driverTitle.
  ///
  /// In ar, this message translates to:
  /// **'سائق دوّر'**
  String get driverTitle;

  /// No description provided for @driverActiveOrdersLabel.
  ///
  /// In ar, this message translates to:
  /// **'طلب نشط'**
  String get driverActiveOrdersLabel;

  /// No description provided for @driverCompletedOrdersLabel.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات المكتملة'**
  String get driverCompletedOrdersLabel;

  /// No description provided for @driverEarningsLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح (د.أ)'**
  String get driverEarningsLabel;

  /// No description provided for @driverUnavailableTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متاح حالياً'**
  String get driverUnavailableTitle;

  /// No description provided for @driverUnavailableSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم بتغيير حالتك إلى متاح بالأعلى لاستقبال طلبات جديدة'**
  String get driverUnavailableSubtitle;

  /// No description provided for @driverAvailableOrders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات المتاحة'**
  String get driverAvailableOrders;

  /// No description provided for @driverNoAvailableOrders.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات متاحة حالياً'**
  String get driverNoAvailableOrders;

  /// No description provided for @driverMyListings.
  ///
  /// In ar, this message translates to:
  /// **'منشوراتي في السوق'**
  String get driverMyListings;

  /// No description provided for @driverCurrentTrip.
  ///
  /// In ar, this message translates to:
  /// **'رحلتك الحالية'**
  String get driverCurrentTrip;

  /// No description provided for @driverViewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get driverViewDetails;

  /// No description provided for @driverPublishToMarket.
  ///
  /// In ar, this message translates to:
  /// **'نشر في السوق'**
  String get driverPublishToMarket;

  /// No description provided for @driverOrdersHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الطلبات'**
  String get driverOrdersHistory;

  /// No description provided for @driverNoOrders.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات'**
  String get driverNoOrders;

  /// No description provided for @driverNoOrdersYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تقم بقبول أي طلبات بعد'**
  String get driverNoOrdersYet;

  /// No description provided for @driverCollectionCommitments.
  ///
  /// In ar, this message translates to:
  /// **'التزامات التجميع'**
  String get driverCollectionCommitments;

  /// No description provided for @driverToggleOnline.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get driverToggleOnline;

  /// No description provided for @driverToggleOffline.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get driverToggleOffline;

  /// No description provided for @driverStatusOnline.
  ///
  /// In ar, this message translates to:
  /// **'متصل الآن'**
  String get driverStatusOnline;

  /// No description provided for @driverStatusOffline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get driverStatusOffline;

  /// No description provided for @driverActiveMission.
  ///
  /// In ar, this message translates to:
  /// **'مهمة نشطة'**
  String get driverActiveMission;

  /// No description provided for @driverHeadingToPickup.
  ///
  /// In ar, this message translates to:
  /// **'متجه للاستلام'**
  String get driverHeadingToPickup;

  /// No description provided for @driverHeadingToDelivery.
  ///
  /// In ar, this message translates to:
  /// **'متجه للتسليم'**
  String get driverHeadingToDelivery;

  /// No description provided for @driverOrderAccepted.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الطلب'**
  String get driverOrderAccepted;

  /// No description provided for @driverNewOrderBadge.
  ///
  /// In ar, this message translates to:
  /// **'طلب جديد'**
  String get driverNewOrderBadge;

  /// No description provided for @driverActivateNow.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الآن'**
  String get driverActivateNow;

  /// No description provided for @driverNoOrdersNotifySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ستصلك إشعارات عند توفر طلبات جديدة'**
  String get driverNoOrdersNotifySubtitle;

  /// No description provided for @driverOrdersTabAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get driverOrdersTabAll;

  /// No description provided for @driverOrdersTabActive.
  ///
  /// In ar, this message translates to:
  /// **'النشطة'**
  String get driverOrdersTabActive;

  /// No description provided for @driverOrdersTabCompleted.
  ///
  /// In ar, this message translates to:
  /// **'المكتملة'**
  String get driverOrdersTabCompleted;

  /// No description provided for @driverPickupLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاستلام'**
  String get driverPickupLabel;

  /// No description provided for @driverDeliveryLabel.
  ///
  /// In ar, this message translates to:
  /// **'التسليم'**
  String get driverDeliveryLabel;

  /// No description provided for @driverViewPickupDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل الاستلام'**
  String get driverViewPickupDetails;

  /// No description provided for @driverViewDeliveryDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل التسليم'**
  String get driverViewDeliveryDetails;

  /// No description provided for @driverRewardLabel.
  ///
  /// In ar, this message translates to:
  /// **'العائد'**
  String get driverRewardLabel;

  /// No description provided for @driverDistanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get driverDistanceLabel;

  /// No description provided for @driverTimeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get driverTimeLabel;

  /// No description provided for @driverWasteTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع المواد'**
  String get driverWasteTypeLabel;

  /// No description provided for @withdrawListing.
  ///
  /// In ar, this message translates to:
  /// **'سحب الإعلان'**
  String get withdrawListing;

  /// No description provided for @withdrawListingConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل يريد سحب هذا الإعلان من السوق؟'**
  String get withdrawListingConfirm;

  /// No description provided for @yesWithdraw.
  ///
  /// In ar, this message translates to:
  /// **'نعم، سحب'**
  String get yesWithdraw;

  /// No description provided for @profilePersonalAndVehicle.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية والمركبة'**
  String get profilePersonalAndVehicle;

  /// No description provided for @profilePhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get profilePhone;

  /// No description provided for @profileVehicle.
  ///
  /// In ar, this message translates to:
  /// **'المركبة'**
  String get profileVehicle;

  /// No description provided for @profileLicensePlate.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة'**
  String get profileLicensePlate;

  /// No description provided for @profileAddLicensePlate.
  ///
  /// In ar, this message translates to:
  /// **'أضف رقم اللوحة'**
  String get profileAddLicensePlate;

  /// No description provided for @profileAddVehicleInfo.
  ///
  /// In ar, this message translates to:
  /// **'أضف معلومات المركبة'**
  String get profileAddVehicleInfo;

  /// No description provided for @profileAppSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التطبيق'**
  String get profileAppSettings;

  /// No description provided for @profileLanguage.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get profileLanguage;

  /// No description provided for @profileTheme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get profileTheme;

  /// No description provided for @profileNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get profileNotifications;

  /// No description provided for @profileNotificationsEnabled.
  ///
  /// In ar, this message translates to:
  /// **'مفعلة'**
  String get profileNotificationsEnabled;

  /// No description provided for @profileHelpSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get profileHelpSupport;

  /// No description provided for @profileContactSupport.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم الفني'**
  String get profileContactSupport;

  /// No description provided for @profileEditProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get profileEditProfile;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get profileDeleteAccount;

  /// No description provided for @profileTotalTrips.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الرحلات'**
  String get profileTotalTrips;

  /// No description provided for @profileTotalEarnings.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأرباح'**
  String get profileTotalEarnings;

  /// No description provided for @profileTapToAddPhoto.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لإضافة صورة'**
  String get profileTapToAddPhoto;

  /// No description provided for @profileEditVehicle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل معلومات المركبة'**
  String get profileEditVehicle;

  /// No description provided for @profileVehicleTypeModel.
  ///
  /// In ar, this message translates to:
  /// **'نوع المركبة وموديلها'**
  String get profileVehicleTypeModel;

  /// No description provided for @profileVehicleTypeModelHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: تويوتا بريوس'**
  String get profileVehicleTypeModelHint;

  /// No description provided for @profileVehicleColor.
  ///
  /// In ar, this message translates to:
  /// **'لون المركبة'**
  String get profileVehicleColor;

  /// No description provided for @profileVehicleColorHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: أبيض'**
  String get profileVehicleColorHint;

  /// No description provided for @profileVehiclePhoto.
  ///
  /// In ar, this message translates to:
  /// **'صورة المركبة'**
  String get profileVehiclePhoto;

  /// No description provided for @supplierStoreType.
  ///
  /// In ar, this message translates to:
  /// **'مورد متجر'**
  String get supplierStoreType;

  /// No description provided for @supplierIndividualType.
  ///
  /// In ar, this message translates to:
  /// **'مورد فردي'**
  String get supplierIndividualType;

  /// No description provided for @supplierActiveOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي النشطة'**
  String get supplierActiveOrders;

  /// No description provided for @supplierMyListings.
  ///
  /// In ar, this message translates to:
  /// **'منشوراتي في السوق'**
  String get supplierMyListings;

  /// No description provided for @supplierNoOrdersYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات نشطة'**
  String get supplierNoOrdersYet;

  /// No description provided for @supplierCreateFromHome.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على زر + أسفل الشاشة لإنشاء طلب جديد'**
  String get supplierCreateFromHome;

  /// No description provided for @supplierGreeting.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، {name}'**
  String supplierGreeting(String name);

  /// No description provided for @supplierDriverOnWay.
  ///
  /// In ar, this message translates to:
  /// **'السائق في الطريق إليك'**
  String get supplierDriverOnWay;

  /// No description provided for @supplierPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقطة'**
  String get supplierPoints;

  /// No description provided for @supplierRecyclingPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاط التدوير'**
  String get supplierRecyclingPoints;

  /// No description provided for @supplierTotalOrders.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلبات'**
  String get supplierTotalOrders;

  /// No description provided for @supplierAddress.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get supplierAddress;

  /// No description provided for @supplierAddAddress.
  ///
  /// In ar, this message translates to:
  /// **'أضف العنوان'**
  String get supplierAddAddress;

  /// No description provided for @supplierIdentity.
  ///
  /// In ar, this message translates to:
  /// **'الهوية'**
  String get supplierIdentity;

  /// No description provided for @supplierVerified.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق'**
  String get supplierVerified;

  /// No description provided for @supplierNotVerified.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم التحقق'**
  String get supplierNotVerified;

  /// No description provided for @supplierPersonalInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get supplierPersonalInfo;

  /// No description provided for @supplierMyRewards.
  ///
  /// In ar, this message translates to:
  /// **'مكافآتي'**
  String get supplierMyRewards;

  /// No description provided for @supplierNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get supplierNameLabel;

  /// No description provided for @supplierNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك'**
  String get supplierNameHint;

  /// No description provided for @supplierPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'+962 7X XXX XXXX'**
  String get supplierPhoneHint;

  /// No description provided for @supplierAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get supplierAddressLabel;

  /// No description provided for @supplierAddressHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوانك'**
  String get supplierAddressHint;

  /// No description provided for @ordersTabTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get ordersTabTitle;

  /// No description provided for @ordersNoOrdersYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات بعد'**
  String get ordersNoOrdersYet;

  /// No description provided for @ordersCreateFromHome.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ طلب استلام جديد من الصفحة الرئيسية'**
  String get ordersCreateFromHome;

  /// No description provided for @ordersActiveSection.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات النشطة'**
  String get ordersActiveSection;

  /// No description provided for @ordersCompletedSection.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات المكتملة'**
  String get ordersCompletedSection;

  /// No description provided for @ordersCancelledSection.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات الملغاة'**
  String get ordersCancelledSection;

  /// No description provided for @ordersCollectionSection.
  ///
  /// In ar, this message translates to:
  /// **'التزامات التجميع'**
  String get ordersCollectionSection;

  /// No description provided for @orderDeliveryConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التسليم'**
  String get orderDeliveryConfirmTitle;

  /// No description provided for @orderDeliveryConfirmMsg.
  ///
  /// In ar, this message translates to:
  /// **'هل وصلت إلى المنشأة وسلّمت المواد؟'**
  String get orderDeliveryConfirmMsg;

  /// No description provided for @orderActualWeight.
  ///
  /// In ar, this message translates to:
  /// **'الوزن الفعلي (كغ) — اختياري'**
  String get orderActualWeight;

  /// No description provided for @orderScheduledAt.
  ///
  /// In ar, this message translates to:
  /// **'موعد مجدول'**
  String get orderScheduledAt;

  /// No description provided for @cancelOrderTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get cancelOrderTitle;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد إلغاء هذا الطلب؟'**
  String get cancelOrderConfirm;

  /// No description provided for @yesCancelOrder.
  ///
  /// In ar, this message translates to:
  /// **'نعم، إلغاء'**
  String get yesCancelOrder;

  /// No description provided for @recyclingCompanyLabel.
  ///
  /// In ar, this message translates to:
  /// **'شركة إعادة تدوير'**
  String get recyclingCompanyLabel;

  /// No description provided for @recyclingOpenForReceipt.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح للاستلام'**
  String get recyclingOpenForReceipt;

  /// No description provided for @recyclingClosedTemp.
  ///
  /// In ar, this message translates to:
  /// **'مغلق مؤقتاً'**
  String get recyclingClosedTemp;

  /// No description provided for @recyclingTodayShipments.
  ///
  /// In ar, this message translates to:
  /// **'شحنات اليوم'**
  String get recyclingTodayShipments;

  /// No description provided for @recyclingTotalWeight.
  ///
  /// In ar, this message translates to:
  /// **'الوزن الكلي'**
  String get recyclingTotalWeight;

  /// No description provided for @recyclingActiveJobsLabel.
  ///
  /// In ar, this message translates to:
  /// **'وظائف نشطة'**
  String get recyclingActiveJobsLabel;

  /// No description provided for @recyclingDriversInProgress.
  ///
  /// In ar, this message translates to:
  /// **'سائقون قيد التنفيذ'**
  String get recyclingDriversInProgress;

  /// No description provided for @recyclingPostJob.
  ///
  /// In ar, this message translates to:
  /// **'نشر وظيفة تجميع'**
  String get recyclingPostJob;

  /// No description provided for @recyclingPostJobSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أطلب من سائق جمع المخلفات من منطقة محددة'**
  String get recyclingPostJobSubtitle;

  /// No description provided for @recyclingIncomingShipments.
  ///
  /// In ar, this message translates to:
  /// **'الشحنات القادمة'**
  String get recyclingIncomingShipments;

  /// No description provided for @recyclingActiveCollectionJobs.
  ///
  /// In ar, this message translates to:
  /// **'وظائف التجميع النشطة'**
  String get recyclingActiveCollectionJobs;

  /// No description provided for @recyclingMyListings.
  ///
  /// In ar, this message translates to:
  /// **'منشوراتي في السوق'**
  String get recyclingMyListings;

  /// No description provided for @recyclingCommitted.
  ///
  /// In ar, this message translates to:
  /// **'الملتزمون:'**
  String get recyclingCommitted;

  /// No description provided for @recyclingCompanyInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الشركة'**
  String get recyclingCompanyInfo;

  /// No description provided for @recyclingCompanyPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم التواصل'**
  String get recyclingCompanyPhone;

  /// No description provided for @recyclingCompanyEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get recyclingCompanyEmail;

  /// No description provided for @recyclingServiceArea.
  ///
  /// In ar, this message translates to:
  /// **'منطقة الخدمة'**
  String get recyclingServiceArea;

  /// No description provided for @recyclingWorkingHours.
  ///
  /// In ar, this message translates to:
  /// **'ساعات العمل'**
  String get recyclingWorkingHours;

  /// No description provided for @recyclingLicense.
  ///
  /// In ar, this message translates to:
  /// **'الترخيص التجاري'**
  String get recyclingLicense;

  /// No description provided for @recyclingReceivedShipments.
  ///
  /// In ar, this message translates to:
  /// **'شحنات مستلمة'**
  String get recyclingReceivedShipments;

  /// No description provided for @recyclingProcessedWeight.
  ///
  /// In ar, this message translates to:
  /// **'وزن معالج (كغ)'**
  String get recyclingProcessedWeight;

  /// No description provided for @recyclingEditCompany.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات الشركة'**
  String get recyclingEditCompany;

  /// No description provided for @recyclingCompanyNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الشركة'**
  String get recyclingCompanyNameLabel;

  /// No description provided for @recyclingCompanyNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم الشركة'**
  String get recyclingCompanyNameHint;

  /// No description provided for @recyclingPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم التواصل'**
  String get recyclingPhoneLabel;

  /// No description provided for @recyclingPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'+962 6X XXX XXXX'**
  String get recyclingPhoneHint;

  /// No description provided for @recyclingEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get recyclingEmailLabel;

  /// No description provided for @recyclingEmailHint.
  ///
  /// In ar, this message translates to:
  /// **'info@company.jo'**
  String get recyclingEmailHint;

  /// No description provided for @recyclingAreaLabel.
  ///
  /// In ar, this message translates to:
  /// **'منطقة الخدمة'**
  String get recyclingAreaLabel;

  /// No description provided for @recyclingAreaHint.
  ///
  /// In ar, this message translates to:
  /// **'عمّان، الزرقاء...'**
  String get recyclingAreaHint;

  /// No description provided for @recyclingHoursLabel.
  ///
  /// In ar, this message translates to:
  /// **'ساعات العمل'**
  String get recyclingHoursLabel;

  /// No description provided for @recyclingHoursHint.
  ///
  /// In ar, this message translates to:
  /// **'٧:٠٠ ص - ٥:٠٠ م'**
  String get recyclingHoursHint;

  /// No description provided for @recyclingLicenseVerified.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق'**
  String get recyclingLicenseVerified;

  /// No description provided for @recyclingLicenseNotVerified.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم التحقق'**
  String get recyclingLicenseNotVerified;

  /// No description provided for @marketDriverRole.
  ///
  /// In ar, this message translates to:
  /// **'استلم وابيع'**
  String get marketDriverRole;

  /// No description provided for @marketSupplierRole.
  ///
  /// In ar, this message translates to:
  /// **'اشترِ وأوصل'**
  String get marketSupplierRole;

  /// No description provided for @marketRecyclingRole.
  ///
  /// In ar, this message translates to:
  /// **'استلم في منشأتك'**
  String get marketRecyclingRole;

  /// No description provided for @marketTitle.
  ///
  /// In ar, this message translates to:
  /// **'السوق'**
  String get marketTitle;

  /// No description provided for @marketBrowse.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح المواد المعروضة للبيع'**
  String get marketBrowse;

  /// No description provided for @marketCollectionJobsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'وظائف التجميع من شركات التدوير'**
  String get marketCollectionJobsSubtitle;

  /// No description provided for @marketSearch.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مواد، بائع، أو منطقة...'**
  String get marketSearch;

  /// No description provided for @marketAvailableOffers.
  ///
  /// In ar, this message translates to:
  /// **'العروض المتاحة'**
  String get marketAvailableOffers;

  /// No description provided for @marketNoOffers.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عروض حالياً'**
  String get marketNoOffers;

  /// No description provided for @collectionSaleNew.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get collectionSaleNew;

  /// No description provided for @collectionSaleJobNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الوظيفة: {id}'**
  String collectionSaleJobNumber(String id);

  /// No description provided for @collectionSaleDeliveryLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقع التسليم:'**
  String get collectionSaleDeliveryLocation;

  /// No description provided for @collectionSaleAgreedPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر المتفق عليه:'**
  String get collectionSaleAgreedPrice;

  /// No description provided for @collectionSaleCancelCommitment.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الالتزام'**
  String get collectionSaleCancelCommitment;

  /// No description provided for @collectionSaleStartCollection.
  ///
  /// In ar, this message translates to:
  /// **'بدء التجميع'**
  String get collectionSaleStartCollection;

  /// No description provided for @collectionSaleConfirmDelivery.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التسليم'**
  String get collectionSaleConfirmDelivery;

  /// No description provided for @collectionSaleCancelTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الالتزام'**
  String get collectionSaleCancelTitle;

  /// No description provided for @collectionSaleCancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد إلغاء التزامك بهذه الوظيفة؟'**
  String get collectionSaleCancelConfirm;

  /// No description provided for @postMarketTitle.
  ///
  /// In ar, this message translates to:
  /// **'نشر في السوق'**
  String get postMarketTitle;

  /// No description provided for @postMarketSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف تفاصيل المواد التي تريد بيعها'**
  String get postMarketSubtitle;

  /// No description provided for @postMarketWasteTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع المواد *'**
  String get postMarketWasteTypeLabel;

  /// No description provided for @postMarketWasteFormLabel.
  ///
  /// In ar, this message translates to:
  /// **'حالة المواد'**
  String get postMarketWasteFormLabel;

  /// No description provided for @postMarketPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر المطلوب (د.أ) — اختياري'**
  String get postMarketPriceLabel;

  /// No description provided for @postMarketImagesLabel.
  ///
  /// In ar, this message translates to:
  /// **'صور المواد — اختياري'**
  String get postMarketImagesLabel;

  /// No description provided for @postMarketSubmitButton.
  ///
  /// In ar, this message translates to:
  /// **'نشر الإعلان'**
  String get postMarketSubmitButton;

  /// No description provided for @postMarketAiAnalyzing.
  ///
  /// In ar, this message translates to:
  /// **'الذكاء الاصطناعي يحلل الصورة...'**
  String get postMarketAiAnalyzing;

  /// No description provided for @postMarketAiFilled.
  ///
  /// In ar, this message translates to:
  /// **'تم تعبئة الحقول تلقائياً بواسطة الذكاء الاصطناعي'**
  String get postMarketAiFilled;

  /// No description provided for @postMarketAiFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحليل الذكاء الاصطناعي، يرجى التعبئة يدوياً'**
  String get postMarketAiFailed;

  /// No description provided for @postMarketNeedImageFirst.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إضافة صورة أولاً لتحليلها'**
  String get postMarketNeedImageFirst;

  /// No description provided for @postMarketLocationPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الموقع، سيتم استخدام الموقع الافتراضي'**
  String get postMarketLocationPermissionDenied;

  /// No description provided for @postMarketUseCurrentLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام موقعي الحالي'**
  String get postMarketUseCurrentLocation;

  /// No description provided for @postMarketAdjustLocation.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الموقع على الخريطة'**
  String get postMarketAdjustLocation;

  /// No description provided for @postMarketMinPriceErrorIndividual.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، الحد الأدنى للنشر للأفراد هو ٥ دنانير'**
  String get postMarketMinPriceErrorIndividual;

  /// No description provided for @postMarketMinPriceErrorBusiness.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، الحد الأدنى للنشر للشركات هو ٢٠ ديناراً'**
  String get postMarketMinPriceErrorBusiness;

  /// No description provided for @collectionJobTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل وظيفة التجميع'**
  String get collectionJobTitle;

  /// No description provided for @collectionJobCollectionArea.
  ///
  /// In ar, this message translates to:
  /// **'منطقة التجميع: '**
  String get collectionJobCollectionArea;

  /// No description provided for @collectionJobDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الوظيفة'**
  String get collectionJobDeleteTitle;

  /// No description provided for @collectionJobDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get collectionJobDeleteConfirm;

  /// No description provided for @collectionJobAccepted.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الوظيفة — تحقق من طلباتك'**
  String get collectionJobAccepted;

  /// No description provided for @collectionJobAcceptButton.
  ///
  /// In ar, this message translates to:
  /// **'قبول الوظيفة'**
  String get collectionJobAcceptButton;

  /// No description provided for @collectionJobAcceptSellButton.
  ///
  /// In ar, this message translates to:
  /// **'قبول وبيع النفايات'**
  String get collectionJobAcceptSellButton;

  /// No description provided for @collectionJobRequiredMaterials.
  ///
  /// In ar, this message translates to:
  /// **'أنواع المواد المطلوبة'**
  String get collectionJobRequiredMaterials;

  /// No description provided for @collectionJobPricingTitle.
  ///
  /// In ar, this message translates to:
  /// **'التسعيرة والدفع'**
  String get collectionJobPricingTitle;

  /// No description provided for @collectionJobDescTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصف الوظيفة'**
  String get collectionJobDescTitle;

  /// No description provided for @collectionJobRecyclingCoLabel.
  ///
  /// In ar, this message translates to:
  /// **'شركة تدوير'**
  String get collectionJobRecyclingCoLabel;

  /// No description provided for @marketItemSellerLabel.
  ///
  /// In ar, this message translates to:
  /// **'البائع'**
  String get marketItemSellerLabel;

  /// No description provided for @marketItemPickupAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الاستلام'**
  String get marketItemPickupAddressLabel;

  /// No description provided for @marketItemDistanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'المسافة التقديرية'**
  String get marketItemDistanceLabel;

  /// No description provided for @marketItemDistanceValue.
  ///
  /// In ar, this message translates to:
  /// **'{distance} كم من موقعك'**
  String marketItemDistanceValue(String distance);

  /// No description provided for @marketItemConditionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get marketItemConditionLabel;

  /// No description provided for @marketItemWeightLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوزن'**
  String get marketItemWeightLabel;

  /// No description provided for @marketItemPublishDateLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ النشر'**
  String get marketItemPublishDateLabel;

  /// No description provided for @marketItemUnknown.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get marketItemUnknown;

  /// No description provided for @marketItemUnknownSeller.
  ///
  /// In ar, this message translates to:
  /// **'بائع مجهول'**
  String get marketItemUnknownSeller;

  /// No description provided for @marketItemDriverReceive.
  ///
  /// In ar, this message translates to:
  /// **'استلام العنصر'**
  String get marketItemDriverReceive;

  /// No description provided for @marketItemBuyNow.
  ///
  /// In ar, this message translates to:
  /// **'شراء الآن'**
  String get marketItemBuyNow;

  /// No description provided for @marketItemCompanyReceive.
  ///
  /// In ar, this message translates to:
  /// **'استلام في المنشأة'**
  String get marketItemCompanyReceive;

  /// No description provided for @marketItemPurchasedPickup.
  ///
  /// In ar, this message translates to:
  /// **'تم الشراء! يمكنك الاستلام من السوق.'**
  String get marketItemPurchasedPickup;

  /// No description provided for @marketItemReceived.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام العنصر بنجاح!'**
  String get marketItemReceived;

  /// No description provided for @marketItemPurchasedDriver.
  ///
  /// In ar, this message translates to:
  /// **'تم الشراء! سيتم إرسال سائق للاستلام.'**
  String get marketItemPurchasedDriver;

  /// No description provided for @marketItemFacilityReceived.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الاستلام في المنشأة!'**
  String get marketItemFacilityReceived;

  /// No description provided for @marketRiderChoiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر الإجراء'**
  String get marketRiderChoiceTitle;

  /// No description provided for @marketRiderChoiceSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد شراء هذا العنصر لنفسك أم توصيله؟'**
  String get marketRiderChoiceSubtitle;

  /// No description provided for @marketRiderOptionBuy.
  ///
  /// In ar, this message translates to:
  /// **'شراء لنفسي'**
  String get marketRiderOptionBuy;

  /// No description provided for @marketRiderOptionBuySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ادفع واستلم العنصر من موقعه'**
  String get marketRiderOptionBuySubtitle;

  /// No description provided for @marketRiderOptionDeliver.
  ///
  /// In ar, this message translates to:
  /// **'توصيل الطلب'**
  String get marketRiderOptionDeliver;

  /// No description provided for @marketRiderOptionDeliverSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نقل العنصر من مكان إلى آخر'**
  String get marketRiderOptionDeliverSubtitle;

  /// No description provided for @marketInvoiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة الطلب'**
  String get marketInvoiceTitle;

  /// No description provided for @marketInvoiceTotal.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الإجمالي'**
  String get marketInvoiceTotal;

  /// No description provided for @marketInvoiceConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد وشراء'**
  String get marketInvoiceConfirm;

  /// No description provided for @marketInvoicePickupLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقع الاستلام'**
  String get marketInvoicePickupLocation;

  /// No description provided for @marketInvoicePickupSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد الشراء! توجه إلى الموقع لاستلام عنصرك.'**
  String get marketInvoicePickupSuccess;

  /// No description provided for @rateDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقييم السائق'**
  String get rateDriverTitle;

  /// No description provided for @rateDriverSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get rateDriverSubmit;

  /// No description provided for @rateDriverSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطّ'**
  String get rateDriverSkip;

  /// No description provided for @rewardsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكافآتي'**
  String get rewardsTitle;

  /// No description provided for @rewardsHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل المكافآت'**
  String get rewardsHistoryTitle;

  /// No description provided for @rewardsNoHistory.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجل مكافآت بعد'**
  String get rewardsNoHistory;

  /// No description provided for @rewardsPointsLabel.
  ///
  /// In ar, this message translates to:
  /// **'نقطة'**
  String get rewardsPointsLabel;

  /// No description provided for @rewardsRedeem.
  ///
  /// In ar, this message translates to:
  /// **'استبدل نقاطك'**
  String get rewardsRedeem;

  /// No description provided for @rewardsComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'هذه الميزة قريباً!'**
  String get rewardsComingSoon;

  /// No description provided for @rewardsProgressText.
  ///
  /// In ar, this message translates to:
  /// **'{points} / {threshold} نقطة للمستوى التالي'**
  String rewardsProgressText(int points, int threshold);

  /// No description provided for @rewardsDiscountOrders.
  ///
  /// In ar, this message translates to:
  /// **'خصم على الطلبات'**
  String get rewardsDiscountOrders;

  /// No description provided for @rewardsGiftCard.
  ///
  /// In ar, this message translates to:
  /// **'كرت هدية'**
  String get rewardsGiftCard;

  /// No description provided for @rewardsFreeDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل مجاني'**
  String get rewardsFreeDelivery;

  /// No description provided for @rewards50Points.
  ///
  /// In ar, this message translates to:
  /// **'50 نقطة'**
  String get rewards50Points;

  /// No description provided for @rewards100Points.
  ///
  /// In ar, this message translates to:
  /// **'100 نقطة'**
  String get rewards100Points;

  /// No description provided for @rewards30Points.
  ///
  /// In ar, this message translates to:
  /// **'30 نقطة'**
  String get rewards30Points;

  /// No description provided for @tierBronze.
  ///
  /// In ar, this message translates to:
  /// **'برونزي'**
  String get tierBronze;

  /// No description provided for @tierSilver.
  ///
  /// In ar, this message translates to:
  /// **'فضي'**
  String get tierSilver;

  /// No description provided for @tierGold.
  ///
  /// In ar, this message translates to:
  /// **'ذهبي'**
  String get tierGold;

  /// No description provided for @tierPlatinum.
  ///
  /// In ar, this message translates to:
  /// **'بلاتيني'**
  String get tierPlatinum;

  /// No description provided for @mapsComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم ربط خرائط جوجل قريباً'**
  String get mapsComingSoon;

  /// No description provided for @marketSegmentJobs.
  ///
  /// In ar, this message translates to:
  /// **'وظائف التجميع'**
  String get marketSegmentJobs;

  /// No description provided for @marketJobsFromCompanies.
  ///
  /// In ar, this message translates to:
  /// **'من شركات التدوير'**
  String get marketJobsFromCompanies;

  /// No description provided for @marketNoJobs.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وظائف تجميع حالياً'**
  String get marketNoJobs;

  /// No description provided for @marketCategoryAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get marketCategoryAll;

  /// No description provided for @marketNoOffersBody.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر هنا ما يتم نشره من مواد للبيع'**
  String get marketNoOffersBody;

  /// No description provided for @marketNoJobsBody.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا وظائف التجميع المتاحة'**
  String get marketNoJobsBody;

  /// No description provided for @marketSuggestedByLicense.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات بناءً على رخصتك'**
  String get marketSuggestedByLicense;

  /// No description provided for @marketShowAllOrders.
  ///
  /// In ar, this message translates to:
  /// **'عرض كل الطلبات'**
  String get marketShowAllOrders;

  /// No description provided for @collectionJobBadge.
  ///
  /// In ar, this message translates to:
  /// **'وظيفة تجميع'**
  String get collectionJobBadge;

  /// No description provided for @collectionJobEdited.
  ///
  /// In ar, this message translates to:
  /// **'تم تعديله'**
  String get collectionJobEdited;

  /// No description provided for @collectionJobEditedAt.
  ///
  /// In ar, this message translates to:
  /// **'تم تعديل هذه الوظيفة {time}'**
  String collectionJobEditedAt(String time);

  /// No description provided for @collectionJobMinQtyChip.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى: {n} كغ'**
  String collectionJobMinQtyChip(String n);

  /// No description provided for @recyclingAndOthers.
  ///
  /// In ar, this message translates to:
  /// **'+{count} آخرون'**
  String recyclingAndOthers(int count);

  /// No description provided for @collectionJobMinQtyFrom.
  ///
  /// In ar, this message translates to:
  /// **'من {min} كغ'**
  String collectionJobMinQtyFrom(String min);

  /// No description provided for @timeAgoDays.
  ///
  /// In ar, this message translates to:
  /// **'منذ {n} يوم'**
  String timeAgoDays(int n);

  /// No description provided for @timeAgoHours.
  ///
  /// In ar, this message translates to:
  /// **'منذ {n} ساعة'**
  String timeAgoHours(int n);

  /// No description provided for @timeAgoMinutes.
  ///
  /// In ar, this message translates to:
  /// **'منذ {n} دقيقة'**
  String timeAgoMinutes(int n);

  /// No description provided for @marketListingStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار مشتري'**
  String get marketListingStatusPending;

  /// No description provided for @marketListingStatusAccepted.
  ///
  /// In ar, this message translates to:
  /// **'تم الشراء'**
  String get marketListingStatusAccepted;

  /// No description provided for @marketListingStatusInTransit.
  ///
  /// In ar, this message translates to:
  /// **'قيد التوصيل'**
  String get marketListingStatusInTransit;

  /// No description provided for @marketListingStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get marketListingStatusCompleted;

  /// No description provided for @marketListingStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get marketListingStatusCancelled;

  /// No description provided for @orderStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get orderStatusPending;

  /// No description provided for @orderStatusAccepted.
  ///
  /// In ar, this message translates to:
  /// **'تم القبول'**
  String get orderStatusAccepted;

  /// No description provided for @orderStatusArrivedAtPickup.
  ///
  /// In ar, this message translates to:
  /// **'وصل للاستلام'**
  String get orderStatusArrivedAtPickup;

  /// No description provided for @orderStatusArrivedAtDropoff.
  ///
  /// In ar, this message translates to:
  /// **'وصل للتسليم'**
  String get orderStatusArrivedAtDropoff;

  /// No description provided for @orderStatusInTransit.
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get orderStatusInTransit;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get orderStatusCompleted;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get orderStatusCancelled;

  /// No description provided for @orderWaitingTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الانتظار'**
  String get orderWaitingTime;

  /// No description provided for @orderArrivalTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الوصول'**
  String get orderArrivalTime;

  /// No description provided for @orderEarningsLabel.
  ///
  /// In ar, this message translates to:
  /// **'العائد'**
  String get orderEarningsLabel;

  /// No description provided for @orderCurrencyJD.
  ///
  /// In ar, this message translates to:
  /// **'دينار'**
  String get orderCurrencyJD;

  /// No description provided for @orderAcceptButton.
  ///
  /// In ar, this message translates to:
  /// **'اقبل الطلب'**
  String get orderAcceptButton;

  /// No description provided for @orderViewRoute.
  ///
  /// In ar, this message translates to:
  /// **'عرض المسار'**
  String get orderViewRoute;

  /// No description provided for @orderDriverOnWay.
  ///
  /// In ar, this message translates to:
  /// **'السائق في الطريق إليك'**
  String get orderDriverOnWay;

  /// No description provided for @orderChatButton.
  ///
  /// In ar, this message translates to:
  /// **'تواصل'**
  String get orderChatButton;

  /// No description provided for @orderWhatsAppButton.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get orderWhatsAppButton;

  /// No description provided for @orderChatComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'المحادثة مع السائق قريباً'**
  String get orderChatComingSoon;

  /// No description provided for @orderWhatsAppFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح واتساب'**
  String get orderWhatsAppFailed;

  /// No description provided for @orderStatusTitle.
  ///
  /// In ar, this message translates to:
  /// **'حالة الطلب'**
  String get orderStatusTitle;

  /// No description provided for @orderStatusStepPending.
  ///
  /// In ar, this message translates to:
  /// **'انتظار'**
  String get orderStatusStepPending;

  /// No description provided for @orderStatusStepAccepted.
  ///
  /// In ar, this message translates to:
  /// **'قُبل'**
  String get orderStatusStepAccepted;

  /// No description provided for @orderStatusStepArrivedAtPickup.
  ///
  /// In ar, this message translates to:
  /// **'وصل'**
  String get orderStatusStepArrivedAtPickup;

  /// No description provided for @orderStatusStepInTransit.
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get orderStatusStepInTransit;

  /// No description provided for @orderStatusStepArrivedAtDropoff.
  ///
  /// In ar, this message translates to:
  /// **'للتسليم'**
  String get orderStatusStepArrivedAtDropoff;

  /// No description provided for @orderStatusStepCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get orderStatusStepCompleted;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get orderDetailsTitle;

  /// No description provided for @orderFromLabel.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get orderFromLabel;

  /// No description provided for @orderToLabel.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get orderToLabel;

  /// No description provided for @orderDistKm.
  ///
  /// In ar, this message translates to:
  /// **'{d} كم'**
  String orderDistKm(String d);

  /// No description provided for @orderWeightKgLabel.
  ///
  /// In ar, this message translates to:
  /// **'{w} كغ'**
  String orderWeightKgLabel(String w);

  /// No description provided for @orderRewardJD.
  ///
  /// In ar, this message translates to:
  /// **'{r} د.أ'**
  String orderRewardJD(String r);

  /// No description provided for @orderDriverSection.
  ///
  /// In ar, this message translates to:
  /// **'السائق'**
  String get orderDriverSection;

  /// No description provided for @orderDriverArrives.
  ///
  /// In ar, this message translates to:
  /// **'يصل خلال {eta}'**
  String orderDriverArrives(String eta);

  /// No description provided for @orderCompletionTitle.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الرحلة'**
  String get orderCompletionTitle;

  /// No description provided for @orderPhotoCamera.
  ///
  /// In ar, this message translates to:
  /// **'التقاط صورة'**
  String get orderPhotoCamera;

  /// No description provided for @orderPhotoGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختيار من المعرض'**
  String get orderPhotoGallery;

  /// No description provided for @orderCompleteDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الطلب'**
  String get orderCompleteDialogTitle;

  /// No description provided for @orderCompleteDialogMsg.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسليم الطلب واستلام المبلغ؟\nعند إتمام الطلب، ستتمكن من استقبال طلبات جديدة.'**
  String get orderCompleteDialogMsg;

  /// No description provided for @orderConfirmComplete.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإتمام'**
  String get orderConfirmComplete;

  /// No description provided for @orderProofPhotoHint.
  ///
  /// In ar, this message translates to:
  /// **'التقط صورة إثبات الاستلام (اختياري)'**
  String get orderProofPhotoHint;

  /// No description provided for @orderAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المطلوب تحصيله:'**
  String get orderAmountLabel;

  /// No description provided for @orderFinishButton.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الطلب'**
  String get orderFinishButton;

  /// No description provided for @orderProofTitle.
  ///
  /// In ar, this message translates to:
  /// **'إثبات الاستلام والتسليم'**
  String get orderProofTitle;

  /// No description provided for @orderProofLinkBroken.
  ///
  /// In ar, this message translates to:
  /// **'الرابط يشير لملف غير متوفر مؤقتاً'**
  String get orderProofLinkBroken;

  /// No description provided for @orderRateDriver.
  ///
  /// In ar, this message translates to:
  /// **'قيّم السائق'**
  String get orderRateDriver;

  /// No description provided for @orderWhatsAppWaiting.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، أنا في انتظار استلامي.'**
  String get orderWhatsAppWaiting;

  /// No description provided for @marketItemPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر المواد'**
  String get marketItemPriceLabel;

  /// No description provided for @marketItemNegotiable.
  ///
  /// In ar, this message translates to:
  /// **'قابل للتفاوض'**
  String get marketItemNegotiable;

  /// No description provided for @marketItemDescriptionLabel.
  ///
  /// In ar, this message translates to:
  /// **'وصف المنتج'**
  String get marketItemDescriptionLabel;

  /// No description provided for @marketListingPrice.
  ///
  /// In ar, this message translates to:
  /// **'{price} د.أ'**
  String marketListingPrice(String price);

  /// No description provided for @collectionSaleDetailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الالتزام'**
  String get collectionSaleDetailTitle;

  /// No description provided for @collectionSaleDeliveryLocationNoColon.
  ///
  /// In ar, this message translates to:
  /// **'موقع التسليم'**
  String get collectionSaleDeliveryLocationNoColon;

  /// No description provided for @collectionSaleAgreedPriceNoColon.
  ///
  /// In ar, this message translates to:
  /// **'السعر المتفق عليه'**
  String get collectionSaleAgreedPriceNoColon;

  /// No description provided for @collectionSaleAgreementTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الاتفاق'**
  String get collectionSaleAgreementTitle;

  /// No description provided for @collectionSaleDeliveryMethodLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة التوصيل'**
  String get collectionSaleDeliveryMethodLabel;

  /// No description provided for @collectionSaleTransactionTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع المعاملة'**
  String get collectionSaleTransactionTypeLabel;

  /// No description provided for @collectionSaleWasteTypesLabel.
  ///
  /// In ar, this message translates to:
  /// **'أنواع النفايات'**
  String get collectionSaleWasteTypesLabel;

  /// No description provided for @collectionSaleCompanyNote.
  ///
  /// In ar, this message translates to:
  /// **'الشركة: {note}'**
  String collectionSaleCompanyNote(String note);

  /// No description provided for @collectionSaleCommitmentNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الالتزام'**
  String get collectionSaleCommitmentNumber;

  /// No description provided for @collectionSaleJobNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الوظيفة'**
  String get collectionSaleJobNumberLabel;

  /// No description provided for @collectionSaleAcceptedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ القبول'**
  String get collectionSaleAcceptedAt;

  /// No description provided for @orderTrackButton.
  ///
  /// In ar, this message translates to:
  /// **'تتبع'**
  String get orderTrackButton;

  /// No description provided for @rateDriverExperience.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت تجربتك مع السائق؟'**
  String get rateDriverExperience;

  /// No description provided for @rateDriverPickLabel.
  ///
  /// In ar, this message translates to:
  /// **'اختر تقييمك'**
  String get rateDriverPickLabel;

  /// No description provided for @rateDriverPoor.
  ///
  /// In ar, this message translates to:
  /// **'سيئ'**
  String get rateDriverPoor;

  /// No description provided for @rateDriverFair.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get rateDriverFair;

  /// No description provided for @rateDriverGood.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get rateDriverGood;

  /// No description provided for @rateDriverExcellent.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز'**
  String get rateDriverExcellent;

  /// No description provided for @imagePickerCamera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get imagePickerCamera;

  /// No description provided for @imagePickerGallery.
  ///
  /// In ar, this message translates to:
  /// **'المعرض'**
  String get imagePickerGallery;

  /// No description provided for @imagePickerSourceTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر مصدر الصورة'**
  String get imagePickerSourceTitle;

  /// No description provided for @imagePickerAddPhoto.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get imagePickerAddPhoto;

  /// No description provided for @imagePickerRemoveImage.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الصورة'**
  String get imagePickerRemoveImage;

  /// No description provided for @newOrderSelectButton.
  ///
  /// In ar, this message translates to:
  /// **'تحديد'**
  String get newOrderSelectButton;

  /// No description provided for @newOrderTapToSelectLocation.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لتحديد الموقع على الخريطة'**
  String get newOrderTapToSelectLocation;

  /// No description provided for @newOrderCurrentAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنواني الحالي'**
  String get newOrderCurrentAddress;

  /// No description provided for @newOrderTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب استلام جديد'**
  String get newOrderTitle;

  /// No description provided for @newOrderSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف تفاصيل المخلفات التي تريد التخلص منها'**
  String get newOrderSubtitle;

  /// No description provided for @newOrderWasteTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع المخلفات *'**
  String get newOrderWasteTypeLabel;

  /// No description provided for @newOrderWasteFormLabel.
  ///
  /// In ar, this message translates to:
  /// **'حالة المخلفات'**
  String get newOrderWasteFormLabel;

  /// No description provided for @newOrderWeightCategoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'حجم الكمية *'**
  String get newOrderWeightCategoryLabel;

  /// No description provided for @newOrderPickupAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الاستلام'**
  String get newOrderPickupAddressLabel;

  /// No description provided for @newOrderImagesLabel.
  ///
  /// In ar, this message translates to:
  /// **'صور المخلفات — اختياري'**
  String get newOrderImagesLabel;

  /// No description provided for @newOrderPickupTargetLabel.
  ///
  /// In ar, this message translates to:
  /// **'وجهة المخلفات *'**
  String get newOrderPickupTargetLabel;

  /// No description provided for @newOrderPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر المواد (د.أ) — اختياري'**
  String get newOrderPriceLabel;

  /// No description provided for @newOrderPriceHintDriver.
  ///
  /// In ar, this message translates to:
  /// **'السعر الذي تريده مقابل بيع المواد للسائق'**
  String get newOrderPriceHintDriver;

  /// No description provided for @newOrderPriceHintCompany.
  ///
  /// In ar, this message translates to:
  /// **'السعر الذي تريده مقابل بيع المواد للشركة'**
  String get newOrderPriceHintCompany;

  /// No description provided for @newOrderNotesLabel.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات — اختياري'**
  String get newOrderNotesLabel;

  /// No description provided for @newOrderNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: الكميّة تقريباً ٢٠ كيس بلاستيك...'**
  String get newOrderNotesHint;

  /// No description provided for @newOrderDeliveryFeeLabel.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل'**
  String get newOrderDeliveryFeeLabel;

  /// No description provided for @newOrderDeliveryFeeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تُحسب تلقائياً حسب المسافة والحجم'**
  String get newOrderDeliveryFeeSubtitle;

  /// No description provided for @newOrderSubmitButton.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get newOrderSubmitButton;

  /// No description provided for @chatTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحادثة'**
  String get chatTitle;

  /// No description provided for @chatDevBanner.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه: وضع التطوير — الرسائل محلية حالياً'**
  String get chatDevBanner;

  /// No description provided for @chatEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رسائل بعد'**
  String get chatEmpty;

  /// No description provided for @chatInputHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالة...'**
  String get chatInputHint;

  /// No description provided for @openInGoogleMaps.
  ///
  /// In ar, this message translates to:
  /// **'فتح في خرائط جوجل'**
  String get openInGoogleMaps;

  /// No description provided for @mapsNotInstalledTitle.
  ///
  /// In ar, this message translates to:
  /// **'خرائط جوجل غير مثبتة'**
  String get mapsNotInstalledTitle;

  /// No description provided for @mapsNotInstalledBody.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على تطبيق الخرائط. هل تريد فتح المتجر لتثبيته؟'**
  String get mapsNotInstalledBody;

  /// No description provided for @openStore.
  ///
  /// In ar, this message translates to:
  /// **'فتح المتجر'**
  String get openStore;

  /// No description provided for @mapLabelPickup.
  ///
  /// In ar, this message translates to:
  /// **'الاستلام'**
  String get mapLabelPickup;

  /// No description provided for @mapLabelDropoff.
  ///
  /// In ar, this message translates to:
  /// **'التسليم'**
  String get mapLabelDropoff;

  /// No description provided for @mapUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة غير متوفرة'**
  String get mapUnavailable;

  /// No description provided for @routeTitle.
  ///
  /// In ar, this message translates to:
  /// **'خط السير'**
  String get routeTitle;

  /// No description provided for @pickLocationTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع'**
  String get pickLocationTitle;

  /// No description provided for @confirmLocation.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الموقع'**
  String get confirmLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام موقعي الحالي'**
  String get useCurrentLocation;

  /// No description provided for @pickOnGoogleMaps.
  ///
  /// In ar, this message translates to:
  /// **'تحديد من خرائط جوجل'**
  String get pickOnGoogleMaps;

  /// No description provided for @locationNotSet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد الموقع بعد'**
  String get locationNotSet;

  /// No description provided for @pasteCoordinates.
  ///
  /// In ar, this message translates to:
  /// **'الصق الإحداثيات'**
  String get pasteCoordinates;

  /// No description provided for @pasteCoordinatesHint.
  ///
  /// In ar, this message translates to:
  /// **'الصق من خرائط جوجل، مثال: 31.9539, 35.9106'**
  String get pasteCoordinatesHint;

  /// No description provided for @latitude.
  ///
  /// In ar, this message translates to:
  /// **'خط العرض'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In ar, this message translates to:
  /// **'خط الطول'**
  String get longitude;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @gpsPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الموقع'**
  String get gpsPermissionDenied;

  /// No description provided for @gpsUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحصول على الموقع الحالي'**
  String get gpsUnavailable;

  /// No description provided for @invalidCoordinates.
  ///
  /// In ar, this message translates to:
  /// **'إحداثيات غير صالحة'**
  String get invalidCoordinates;

  /// No description provided for @orderTotalCost.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة الإجمالية'**
  String get orderTotalCost;

  /// No description provided for @orderPotentialEarnings.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح المتوقعة'**
  String get orderPotentialEarnings;

  /// No description provided for @orderEarningsBreakdown.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الأرباح'**
  String get orderEarningsBreakdown;

  /// No description provided for @orderBaseFee.
  ///
  /// In ar, this message translates to:
  /// **'الرسوم الأساسية'**
  String get orderBaseFee;

  /// No description provided for @orderDistanceFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم المسافة'**
  String get orderDistanceFee;

  /// No description provided for @orderMaterialFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم المواد'**
  String get orderMaterialFee;

  /// No description provided for @orderUrgencyFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم الاستعجال'**
  String get orderUrgencyFee;

  /// No description provided for @orderPayout.
  ///
  /// In ar, this message translates to:
  /// **'المستحق للسائق'**
  String get orderPayout;

  /// No description provided for @orderInvoices.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير'**
  String get orderInvoices;

  /// No description provided for @rateDriver.
  ///
  /// In ar, this message translates to:
  /// **'قيّم السائق'**
  String get rateDriver;

  /// No description provided for @pickupRequestCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الاستلام بنجاح'**
  String get pickupRequestCreated;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPasswordLink;

  /// No description provided for @forgotPasswordOtpTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get forgotPasswordOtpTitle;

  /// No description provided for @forgotPasswordOtpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز إلى {email}'**
  String forgotPasswordOtpSubtitle(String email);

  /// No description provided for @forgotPasswordOtpLabel.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكوّن من ٦ أرقام'**
  String get forgotPasswordOtpLabel;

  /// No description provided for @forgotPasswordVerifyButton.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من الرمز'**
  String get forgotPasswordVerifyButton;

  /// No description provided for @forgotPasswordResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get forgotPasswordResend;

  /// No description provided for @forgotPasswordResendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد {s} ثانية'**
  String forgotPasswordResendIn(int s);

  /// No description provided for @forgotPasswordCodeSentAgain.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز جديد'**
  String get forgotPasswordCodeSentAgain;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعيين كلمة مرور جديدة'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordNewLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get resetPasswordNewLabel;

  /// No description provided for @resetPasswordConfirmLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get resetPasswordConfirmLabel;

  /// No description provided for @resetPasswordButton.
  ///
  /// In ar, this message translates to:
  /// **'تعيين كلمة المرور'**
  String get resetPasswordButton;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح. يمكنك تسجيل الدخول الآن'**
  String get resetPasswordSuccess;

  /// No description provided for @forgotPasswordErrorEmptyEmail.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال بريدك الإلكتروني أولاً'**
  String get forgotPasswordErrorEmptyEmail;

  /// No description provided for @forgotPasswordErrorCodeLength.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال رمز مكوّن من ٦ أرقام'**
  String get forgotPasswordErrorCodeLength;

  /// No description provided for @resetPasswordErrorMinLength.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون ٨ أحرف على الأقل'**
  String get resetPasswordErrorMinLength;

  /// No description provided for @resetPasswordErrorMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get resetPasswordErrorMismatch;

  /// No description provided for @restaurantSignupStep1Title.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي الأساسي'**
  String get restaurantSignupStep1Title;

  /// No description provided for @restaurantSignupStep1Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'لنبدأ بتفاصيل شركتك. تساعدنا هذه المعلومات في التحقق من عملك وبناء الثقة مع العملاء.'**
  String get restaurantSignupStep1Subtitle;

  /// No description provided for @restaurantSignupCompanyNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المطعم / الشركة'**
  String get restaurantSignupCompanyNameLabel;

  /// No description provided for @restaurantSignupCompanyNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: الملعقة الذهبية'**
  String get restaurantSignupCompanyNameHint;

  /// No description provided for @restaurantSignupOwnerNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المالك'**
  String get restaurantSignupOwnerNameLabel;

  /// No description provided for @restaurantSignupOwnerNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: أحمد محمد'**
  String get restaurantSignupOwnerNameHint;

  /// No description provided for @restaurantSignupStep2Title.
  ///
  /// In ar, this message translates to:
  /// **'هوية العلامة التجارية والذكاء الاصطناعي'**
  String get restaurantSignupStep2Title;

  /// No description provided for @restaurantSignupStep2Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'صف مطعمك في سطر واحد. سيساعدك الذكاء الاصطناعي لدينا في صياغة قصة مقنعة والتوصية بفئات البحث.'**
  String get restaurantSignupStep2Subtitle;

  /// No description provided for @restaurantSignupTaglineLabel.
  ///
  /// In ar, this message translates to:
  /// **'صف مطعمك في سطر واحد'**
  String get restaurantSignupTaglineLabel;

  /// No description provided for @restaurantSignupTaglineHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: مكرونة إيطالية أصيلة مصنوعة يدوياً'**
  String get restaurantSignupTaglineHint;

  /// No description provided for @restaurantSignupGenerateButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الملف الشخصي والفئات'**
  String get restaurantSignupGenerateButton;

  /// No description provided for @restaurantSignupAiStoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'قصة من إنشاء الذكاء الاصطناعي (قابلة للتعديل)'**
  String get restaurantSignupAiStoryLabel;

  /// No description provided for @restaurantSignupCategoriesLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفئات الموصى بها'**
  String get restaurantSignupCategoriesLabel;

  /// No description provided for @restaurantSignupStep3Title.
  ///
  /// In ar, this message translates to:
  /// **'الموقع والتحقق'**
  String get restaurantSignupStep3Title;

  /// No description provided for @restaurantSignupStep3Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'قدم عنوانك الفعلي وحمل مستندات التحقق. سيقوم الذكاء الاصطناعي لدينا بالتحقق من تفاصيلك تلقائياً.'**
  String get restaurantSignupStep3Subtitle;

  /// No description provided for @restaurantSignupAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المطعم'**
  String get restaurantSignupAddressLabel;

  /// No description provided for @restaurantSignupAddressHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان الشارع الكامل'**
  String get restaurantSignupAddressHint;

  /// No description provided for @restaurantSignupUploadVerifyButton.
  ///
  /// In ar, this message translates to:
  /// **'تحميل الترخيص والتحقق'**
  String get restaurantSignupUploadVerifyButton;

  /// No description provided for @restaurantSignupAiVerificationNote.
  ///
  /// In ar, this message translates to:
  /// **'سيتم فحص هذه الصورة بواسطة الذكاء الاصطناعي للتحقق من مستندك.'**
  String get restaurantSignupAiVerificationNote;

  /// No description provided for @restaurantSignupStatusVerified.
  ///
  /// In ar, this message translates to:
  /// **'الحالة: تم التحقق'**
  String get restaurantSignupStatusVerified;

  /// No description provided for @restaurantSignupStatusInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الحالة: غير صالح'**
  String get restaurantSignupStatusInvalid;

  /// No description provided for @restaurantSignupVerificationSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق من مستنداتك وعنوانك تلقائياً.'**
  String get restaurantSignupVerificationSuccess;

  /// No description provided for @restaurantSignupStep4Title.
  ///
  /// In ar, this message translates to:
  /// **'المراجعة والإرسال'**
  String get restaurantSignupStep4Title;

  /// No description provided for @restaurantSignupStep4Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'يرجى مراجعة ملفك الشخصي وتفاصيلك قبل الإرسال النهائي.'**
  String get restaurantSignupStep4Subtitle;

  /// No description provided for @restaurantSignupSectionBasic.
  ///
  /// In ar, this message translates to:
  /// **'معلومات أساسية'**
  String get restaurantSignupSectionBasic;

  /// No description provided for @restaurantSignupSectionAi.
  ///
  /// In ar, this message translates to:
  /// **'الهوية المنشأة بالذكاء الاصطناعي'**
  String get restaurantSignupSectionAi;

  /// No description provided for @restaurantSignupSectionLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع والتحقق'**
  String get restaurantSignupSectionLocation;

  /// No description provided for @restaurantSignupGeneratedStoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'القصة المنشأة:'**
  String get restaurantSignupGeneratedStoryLabel;

  /// No description provided for @restaurantSignupNotVerified.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم التحقق'**
  String get restaurantSignupNotVerified;

  /// No description provided for @restaurantSignupAppBarTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل المطعم'**
  String get restaurantSignupAppBarTitle;

  /// No description provided for @restaurantSignupBackButton.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get restaurantSignupBackButton;

  /// No description provided for @restaurantSignupNextButton.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get restaurantSignupNextButton;

  /// No description provided for @restaurantSignupSubmitButton.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get restaurantSignupSubmitButton;

  /// No description provided for @restaurantSignupSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم التسجيل بنجاح!'**
  String get restaurantSignupSuccess;

  /// No description provided for @restaurantSignupErrorCompanyNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم الشركة مطلوب'**
  String get restaurantSignupErrorCompanyNameRequired;

  /// No description provided for @restaurantSignupErrorOwnerNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم المالك مطلوب'**
  String get restaurantSignupErrorOwnerNameRequired;

  /// No description provided for @restaurantSignupErrorTaglineRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تقديم وصف قصير لإنشاء ملفك الشخصي'**
  String get restaurantSignupErrorTaglineRequired;

  /// No description provided for @restaurantSignupErrorAiProfileRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إنشاء ومراجعة ملفك الشخصي بالذكاء الاصطناعي'**
  String get restaurantSignupErrorAiProfileRequired;

  /// No description provided for @restaurantSignupErrorCategoryRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار فئة واحدة على الأقل'**
  String get restaurantSignupErrorCategoryRequired;

  /// No description provided for @restaurantSignupErrorAddressRequired.
  ///
  /// In ar, this message translates to:
  /// **'العنوان مطلوب'**
  String get restaurantSignupErrorAddressRequired;

  /// No description provided for @restaurantSignupErrorVerificationRequired.
  ///
  /// In ar, this message translates to:
  /// **'يجب التحقق من مستنداتك وعنوانك'**
  String get restaurantSignupErrorVerificationRequired;

  /// No description provided for @restaurantSignupErrorAiGenerationFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل إنشاء الملف الشخصي. يرجى المحاولة مرة أخرى.'**
  String get restaurantSignupErrorAiGenerationFailed;

  /// No description provided for @restaurantSignupErrorVerificationFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل التحقق. يرجى المحاولة مرة أخرى.'**
  String get restaurantSignupErrorVerificationFailed;

  /// No description provided for @restaurantSignupErrorTaglineFirst.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تقديم وصف قصير أولاً'**
  String get restaurantSignupErrorTaglineFirst;

  /// No description provided for @restaurantSignupErrorAddressFirst.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تقديم عنوان أولاً'**
  String get restaurantSignupErrorAddressFirst;

  /// No description provided for @orderItemPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر العنصر'**
  String get orderItemPrice;

  /// No description provided for @aiValidationUploadPrompt.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لالتقاط أو رفع صورة'**
  String get aiValidationUploadPrompt;

  /// No description provided for @aiValidationAnalyzingStep1.
  ///
  /// In ar, this message translates to:
  /// **'الذكاء الاصطناعي يحلل صورتك...'**
  String get aiValidationAnalyzingStep1;

  /// No description provided for @aiValidationAnalyzingStep2.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحقق من وضوح المستند...'**
  String get aiValidationAnalyzingStep2;

  /// No description provided for @aiValidationAnalyzingStep3.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحقق من المصداقية...'**
  String get aiValidationAnalyzingStep3;

  /// No description provided for @aiValidationSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق من الصورة!'**
  String get aiValidationSuccessTitle;

  /// No description provided for @aiValidationSuccessSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تستوفي صورتك جميع المتطلبات.'**
  String get aiValidationSuccessSubtitle;

  /// No description provided for @aiValidationRetryButton.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get aiValidationRetryButton;

  /// No description provided for @aiValidationErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'فشل التحقق'**
  String get aiValidationErrorTitle;

  /// No description provided for @aiValidationErrorUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع.'**
  String get aiValidationErrorUnknown;

  /// No description provided for @aiValidationStatusSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق بنجاح'**
  String get aiValidationStatusSuccess;

  /// No description provided for @aiValidationStatusInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الصورة لا تفي بالمعايير.'**
  String get aiValidationStatusInvalid;

  /// No description provided for @aiValidationStatusErrorUnknown.
  ///
  /// In ar, this message translates to:
  /// **'خطأ تحقق غير معروف.'**
  String get aiValidationStatusErrorUnknown;

  /// No description provided for @aiValidationScanning.
  ///
  /// In ar, this message translates to:
  /// **'جاري مسح الوثيقة...'**
  String get aiValidationScanning;

  /// No description provided for @aiValidationVerifyingStamps.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من الأختام الرسمية...'**
  String get aiValidationVerifyingStamps;

  /// No description provided for @aiValidationMatchingData.
  ///
  /// In ar, this message translates to:
  /// **'مطابقة البيانات مع السجلات الحكومية...'**
  String get aiValidationMatchingData;

  /// No description provided for @aiValidationExtractedData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات مستخرجة بالذكاء الاصطناعي'**
  String get aiValidationExtractedData;

  /// No description provided for @aiValidationDocId.
  ///
  /// In ar, this message translates to:
  /// **'رقم الوثيقة'**
  String get aiValidationDocId;

  /// No description provided for @aiValidationOrg.
  ///
  /// In ar, this message translates to:
  /// **'الجهة / المؤسسة'**
  String get aiValidationOrg;

  /// No description provided for @aiValidationAuthenticity.
  ///
  /// In ar, this message translates to:
  /// **'نسبة المصداقية'**
  String get aiValidationAuthenticity;

  /// No description provided for @aiValidationFutureVision.
  ///
  /// In ar, this message translates to:
  /// **'رؤية مستقبلية: سيتم ربط النسخة النهائية مع الهوية الرقمية (سند) لضمان التحقق بنسبة 100%.'**
  String get aiValidationFutureVision;

  /// No description provided for @aiPulseStampOk.
  ///
  /// In ar, this message translates to:
  /// **'STAMP_DETECTED'**
  String get aiPulseStampOk;

  /// No description provided for @aiPulseIdMatch.
  ///
  /// In ar, this message translates to:
  /// **'ID_CONFIRMED'**
  String get aiPulseIdMatch;

  /// No description provided for @aiPulseExpiryValid.
  ///
  /// In ar, this message translates to:
  /// **'VALID_EXPIRY'**
  String get aiPulseExpiryValid;

  /// No description provided for @aiPulseSecurePaper.
  ///
  /// In ar, this message translates to:
  /// **'SECURITY_PAPER_OK'**
  String get aiPulseSecurePaper;

  /// No description provided for @aiLivenessCheck.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق من حيوية الصورة بالذكاء الاصطناعي'**
  String get aiLivenessCheck;

  /// تسمية لمدخل نوع أو مطبخ المطعم.
  ///
  /// In ar, this message translates to:
  /// **'المطبخ / نوع العمل'**
  String get signupCuisineType;

  /// نص تلميح لمدخل مطبخ المطعم.
  ///
  /// In ar, this message translates to:
  /// **'مثال: إيطالي، وجبات سريعة، مخبز'**
  String get signupCuisineTypeHint;

  /// تسمية لمدخل الفئة الأساسية للمورد الفردي.
  ///
  /// In ar, this message translates to:
  /// **'المنتج الأساسي / الفئة'**
  String get signupPrimaryCategory;

  /// نص تلميح لمدخل فئة المورد الفردي.
  ///
  /// In ar, this message translates to:
  /// **'مثال: منتجات طازجة، ألبان'**
  String get signupPrimaryCategoryHint;

  /// No description provided for @signupSectionVehicle.
  ///
  /// In ar, this message translates to:
  /// **'معلومات المركبة'**
  String get signupSectionVehicle;

  /// No description provided for @signupVehiclePlate.
  ///
  /// In ar, this message translates to:
  /// **'رقم لوحة المركبة'**
  String get signupVehiclePlate;

  /// No description provided for @signupVehiclePlateHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: أ 123456'**
  String get signupVehiclePlateHint;

  /// No description provided for @signupVehicleModel.
  ///
  /// In ar, this message translates to:
  /// **'نوع المركبة وموديلها'**
  String get signupVehicleModel;

  /// No description provided for @signupVehicleModelHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: تويوتا بريوس 2020'**
  String get signupVehicleModelHint;

  /// No description provided for @signupVehicleColor.
  ///
  /// In ar, this message translates to:
  /// **'لون المركبة'**
  String get signupVehicleColor;

  /// No description provided for @signupVehicleColorHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: أبيض'**
  String get signupVehicleColorHint;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات بعد'**
  String get notificationsEmpty;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get notificationsMarkAllRead;

  /// No description provided for @orderSearchingDriver.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ البحث عن أقرب سائق متاح...'**
  String get orderSearchingDriver;

  /// No description provided for @orderSearchingDriverRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة البحث عن سائق'**
  String get orderSearchingDriverRetry;

  /// No description provided for @vehicleScanTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسح استمارة المركبة'**
  String get vehicleScanTitle;

  /// No description provided for @vehicleScanOptional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get vehicleScanOptional;

  /// No description provided for @vehicleScanPrompt.
  ///
  /// In ar, this message translates to:
  /// **'امسح الاستمارة لملء البيانات تلقائياً'**
  String get vehicleScanPrompt;

  /// No description provided for @vehicleScanTypeHint.
  ///
  /// In ar, this message translates to:
  /// **'يُحدَّد نوع المركبة من الوثيقة'**
  String get vehicleScanTypeHint;

  /// No description provided for @vehicleScanStepType.
  ///
  /// In ar, this message translates to:
  /// **'فحص نوع المركبة...'**
  String get vehicleScanStepType;

  /// No description provided for @vehicleScanStepPlate.
  ///
  /// In ar, this message translates to:
  /// **'قراءة رقم اللوحة...'**
  String get vehicleScanStepPlate;

  /// No description provided for @vehicleScanStepModel.
  ///
  /// In ar, this message translates to:
  /// **'تحليل موديل السيارة...'**
  String get vehicleScanStepModel;

  /// No description provided for @vehicleScanStepExpiry.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من تاريخ الانتهاء...'**
  String get vehicleScanStepExpiry;

  /// No description provided for @vehicleScanPulseType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المركبة ✓'**
  String get vehicleScanPulseType;

  /// No description provided for @vehicleScanPulsePlate.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة...'**
  String get vehicleScanPulsePlate;

  /// No description provided for @vehicleScanPulseModel.
  ///
  /// In ar, this message translates to:
  /// **'الموديل ✓'**
  String get vehicleScanPulseModel;

  /// No description provided for @vehicleScanPulseExpiry.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء...'**
  String get vehicleScanPulseExpiry;

  /// No description provided for @vehicleScanPulseColor.
  ///
  /// In ar, this message translates to:
  /// **'اللون ✓'**
  String get vehicleScanPulseColor;

  /// No description provided for @vehicleScanPulseValid.
  ///
  /// In ar, this message translates to:
  /// **'الاستمارة سارية'**
  String get vehicleScanPulseValid;

  /// No description provided for @vehicleScanReadSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم قراءة الوثيقة بنجاح'**
  String get vehicleScanReadSuccess;

  /// No description provided for @vehicleScanReviewPrompt.
  ///
  /// In ar, this message translates to:
  /// **'راجع البيانات وأكّد'**
  String get vehicleScanReviewPrompt;

  /// No description provided for @vehicleScanRescanTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المسح'**
  String get vehicleScanRescanTooltip;

  /// No description provided for @vehicleScanConfirmAutoFill.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد وملء البيانات تلقائياً'**
  String get vehicleScanConfirmAutoFill;

  /// No description provided for @vehicleScanExtractedData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات المستخرجة'**
  String get vehicleScanExtractedData;

  /// No description provided for @vehicleScanRowModel.
  ///
  /// In ar, this message translates to:
  /// **'الموديل'**
  String get vehicleScanRowModel;

  /// No description provided for @vehicleScanRowColor.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get vehicleScanRowColor;

  /// No description provided for @vehicleScanRowPlate.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة'**
  String get vehicleScanRowPlate;

  /// No description provided for @vehicleScanRowExpiry.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ انتهاء الاستمارة'**
  String get vehicleScanRowExpiry;

  /// No description provided for @vehicleScanChemicalPermit.
  ///
  /// In ar, this message translates to:
  /// **'تصريح نقل مواد كيميائية'**
  String get vehicleScanChemicalPermit;

  /// No description provided for @vehicleScanChemicalPermitHint.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تصفية الطلبات تلقائياً بناءً على نوع مركبتك'**
  String get vehicleScanChemicalPermitHint;

  /// No description provided for @vehicleScanAccuracy.
  ///
  /// In ar, this message translates to:
  /// **'دقة'**
  String get vehicleScanAccuracy;

  /// No description provided for @vehicleScanReadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر قراءة الوثيقة'**
  String get vehicleScanReadFailed;

  /// No description provided for @licenseScanUploadPrompt.
  ///
  /// In ar, this message translates to:
  /// **'انقر لرفع الوثيقة'**
  String get licenseScanUploadPrompt;

  /// No description provided for @licenseScanSourcesHint.
  ///
  /// In ar, this message translates to:
  /// **'كاميرا أو معرض الصور'**
  String get licenseScanSourcesHint;

  /// No description provided for @licenseScanSuggestedCategories.
  ///
  /// In ar, this message translates to:
  /// **'فئات مقترحة في السوق'**
  String get licenseScanSuggestedCategories;

  /// No description provided for @signupLocationPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'يرجى السماح بالوصول للموقع من إعدادات الجهاز'**
  String get signupLocationPermissionDenied;

  /// No description provided for @signupLocationError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديد الموقع: {error}'**
  String signupLocationError(String error);

  /// No description provided for @signupLocating.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحديد موقعك...'**
  String get signupLocating;

  /// No description provided for @signupSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get signupSkip;

  /// No description provided for @signupIdentityLabel.
  ///
  /// In ar, this message translates to:
  /// **'هويتك'**
  String get signupIdentityLabel;

  /// No description provided for @signupRoleDetailsLabel.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الدور'**
  String get signupRoleDetailsLabel;

  /// No description provided for @signupVehicleInfoTitle.
  ///
  /// In ar, this message translates to:
  /// **'معلومات المركبة'**
  String get signupVehicleInfoTitle;

  /// No description provided for @signupYourWasteTypes.
  ///
  /// In ar, this message translates to:
  /// **'أنواع النفايات لديك'**
  String get signupYourWasteTypes;

  /// No description provided for @signupAcceptedWasteTypes.
  ///
  /// In ar, this message translates to:
  /// **'أنواع النفايات المقبولة'**
  String get signupAcceptedWasteTypes;

  /// No description provided for @signupSelectOneOrMore.
  ///
  /// In ar, this message translates to:
  /// **'اختر واحداً أو أكثر'**
  String get signupSelectOneOrMore;

  /// No description provided for @signupSaveAndComplete.
  ///
  /// In ar, this message translates to:
  /// **'حفظ وإكمال'**
  String get signupSaveAndComplete;

  /// No description provided for @signupSkipCompleteLater.
  ///
  /// In ar, this message translates to:
  /// **'تخطي الآن، سأكمل لاحقاً'**
  String get signupSkipCompleteLater;

  /// No description provided for @signupUpdateAnytime.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تحديث هذه البيانات في أي وقت من إعدادات حسابك.'**
  String get signupUpdateAnytime;

  /// No description provided for @signupRoleDriverHeading.
  ///
  /// In ar, this message translates to:
  /// **'معلومات مركبتك'**
  String get signupRoleDriverHeading;

  /// No description provided for @signupRoleSupplierHeading.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي تودّ تدويره؟'**
  String get signupRoleSupplierHeading;

  /// No description provided for @signupRoleRecyclingHeading.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي تقبله منشأتك؟'**
  String get signupRoleRecyclingHeading;

  /// No description provided for @signupRoleDriverBody.
  ///
  /// In ar, this message translates to:
  /// **'أضف لوحة مركبتك لبدء استلام الطلبات. يمكنك مسح الاستمارة تلقائياً.'**
  String get signupRoleDriverBody;

  /// No description provided for @signupRoleSupplierBody.
  ///
  /// In ar, this message translates to:
  /// **'حدد أنواع النفايات لديك لتلقي العروض المناسبة لك مباشرةً.'**
  String get signupRoleSupplierBody;

  /// No description provided for @signupRoleRecyclingBody.
  ///
  /// In ar, this message translates to:
  /// **'حدد ما تقبله منشأتك من مواد لمساعدة الموردين على إيجادك.'**
  String get signupRoleRecyclingBody;

  /// No description provided for @signupPlateNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم لوحة المركبة'**
  String get signupPlateNumberLabel;

  /// No description provided for @signupPlateNumberHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 12 أ ب ج'**
  String get signupPlateNumberHint;

  /// No description provided for @signupWelcomeTo.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك في دوّر!'**
  String get signupWelcomeTo;

  /// No description provided for @signupCreateIdentityHeading.
  ///
  /// In ar, this message translates to:
  /// **'لنبدأ بإنشاء هويتك الرقمية'**
  String get signupCreateIdentityHeading;

  /// No description provided for @signupProfilePhotoLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصورة الشخصية'**
  String get signupProfilePhotoLabel;

  /// No description provided for @signupAccountTypePrompt.
  ///
  /// In ar, this message translates to:
  /// **'ما نوع حسابك؟'**
  String get signupAccountTypePrompt;

  /// No description provided for @signupPrivacyNotice.
  ///
  /// In ar, this message translates to:
  /// **'سيتم استخدام بياناتك لإنشاء حسابك فقط، ولن تُشارك مع أي طرف ثالث.'**
  String get signupPrivacyNotice;

  /// No description provided for @signupSmsVerification.
  ///
  /// In ar, this message translates to:
  /// **'سنتحقق من رقمك عبر رسالة نصية'**
  String get signupSmsVerification;

  /// No description provided for @signupRoleIndividualLabel.
  ///
  /// In ar, this message translates to:
  /// **'فرد'**
  String get signupRoleIndividualLabel;

  /// No description provided for @signupRoleStoreLabel.
  ///
  /// In ar, this message translates to:
  /// **'متجر / مطعم'**
  String get signupRoleStoreLabel;

  /// No description provided for @recyclingIncomingShipmentsCount.
  ///
  /// In ar, this message translates to:
  /// **'الشحنات الواردة ({count})'**
  String recyclingIncomingShipmentsCount(int count);

  /// No description provided for @recyclingActiveJobsCount.
  ///
  /// In ar, this message translates to:
  /// **'الوظائف النشطة ({count})'**
  String recyclingActiveJobsCount(int count);

  /// No description provided for @recyclingTodayOperations.
  ///
  /// In ar, this message translates to:
  /// **'عمليات اليوم'**
  String get recyclingTodayOperations;

  /// No description provided for @recyclingNoActiveDrivers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سائقون نشطون الآن'**
  String get recyclingNoActiveDrivers;

  /// No description provided for @recyclingReconnecting.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الاتصال…'**
  String get recyclingReconnecting;

  /// No description provided for @recyclingFacility.
  ///
  /// In ar, this message translates to:
  /// **'منشأة تدوير'**
  String get recyclingFacility;

  /// No description provided for @recyclingReadyForReceipt.
  ///
  /// In ar, this message translates to:
  /// **'مستعد للاستلام'**
  String get recyclingReadyForReceipt;

  /// No description provided for @recyclingTotalWeightKg.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الوزن (كغ)'**
  String get recyclingTotalWeightKg;

  /// No description provided for @recyclingDriversEnRoute.
  ///
  /// In ar, this message translates to:
  /// **'سائقين بالطريق'**
  String get recyclingDriversEnRoute;

  /// No description provided for @recyclingResponses.
  ///
  /// In ar, this message translates to:
  /// **'استجابات'**
  String get recyclingResponses;

  /// No description provided for @recyclingShowDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get recyclingShowDetails;

  /// No description provided for @recyclingCommittedCount.
  ///
  /// In ar, this message translates to:
  /// **'الملتزمون ({count})'**
  String recyclingCommittedCount(int count);

  /// No description provided for @recyclingFilterHasAcceptors.
  ///
  /// In ar, this message translates to:
  /// **'لديه ملتزمون'**
  String get recyclingFilterHasAcceptors;

  /// No description provided for @recyclingFilterNoAcceptors.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد ملتزمون'**
  String get recyclingFilterNoAcceptors;

  /// No description provided for @recyclingFilterFlatFee.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ ثابت'**
  String get recyclingFilterFlatFee;

  /// No description provided for @recyclingFilterPerKg.
  ///
  /// In ar, this message translates to:
  /// **'بالكيلو'**
  String get recyclingFilterPerKg;

  /// No description provided for @recyclingWithdrawAdTitle.
  ///
  /// In ar, this message translates to:
  /// **'سحب الإعلان'**
  String get recyclingWithdrawAdTitle;

  /// No description provided for @recyclingWithdrawAdBody.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من سحب هذا الإعلان من السوق؟'**
  String get recyclingWithdrawAdBody;

  /// No description provided for @recyclingWithdrawAdConfirm.
  ///
  /// In ar, this message translates to:
  /// **'نعم، اسحب الإعلان'**
  String get recyclingWithdrawAdConfirm;

  /// No description provided for @recyclingMaxListingsReached.
  ///
  /// In ar, this message translates to:
  /// **'وصلت للحد الأقصى ({count} إعلانات نشطة)'**
  String recyclingMaxListingsReached(int count);

  /// No description provided for @collectionJobPaymentModelLabel.
  ///
  /// In ar, this message translates to:
  /// **'نموذج الدفع *'**
  String get collectionJobPaymentModelLabel;

  /// No description provided for @collectionJobPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر * ({unit})'**
  String collectionJobPriceLabel(String unit);

  /// No description provided for @collectionJobPricePerKgHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 2.5 د.أ لكل كغ'**
  String get collectionJobPricePerKgHint;

  /// No description provided for @collectionJobPriceFlatHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 25 د.أ للرحلة'**
  String get collectionJobPriceFlatHint;

  /// No description provided for @collectionJobMinQtyLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للكمية (كغ) — اختياري'**
  String get collectionJobMinQtyLabel;

  /// No description provided for @collectionJobMinQtyHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 10'**
  String get collectionJobMinQtyHint;

  /// No description provided for @collectionJobAreaHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: الرابية، عمّان'**
  String get collectionJobAreaHint;

  /// No description provided for @collectionJobDescHint.
  ///
  /// In ar, this message translates to:
  /// **'اشرح ما تحتاجه، المواصفات المطلوبة، وسبب الطلب...'**
  String get collectionJobDescHint;

  /// No description provided for @collectionJobFlatFeeLabel.
  ///
  /// In ar, this message translates to:
  /// **'أجر ثابت'**
  String get collectionJobFlatFeeLabel;

  /// No description provided for @collectionJobPerKgLabel.
  ///
  /// In ar, this message translates to:
  /// **'لكل كيلوغرام'**
  String get collectionJobPerKgLabel;

  /// No description provided for @supplierMyOrdersCurrent.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي الحالية'**
  String get supplierMyOrdersCurrent;

  /// No description provided for @supplierNoActiveOrders.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات نشطة'**
  String get supplierNoActiveOrders;

  /// No description provided for @supplierStartRecyclingCta.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإضافة أول طلب إعادة تدوير الآن!'**
  String get supplierStartRecyclingCta;

  /// No description provided for @supplierStartMarketCta.
  ///
  /// In ar, this message translates to:
  /// **'أضف أول عرض للسوق الآن!'**
  String get supplierStartMarketCta;

  /// No description provided for @supplierWelcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، {name}'**
  String supplierWelcome(String name);

  /// No description provided for @supplierAccountIndividual.
  ///
  /// In ar, this message translates to:
  /// **'حساب أفراد'**
  String get supplierAccountIndividual;

  /// No description provided for @supplierAccountBusiness.
  ///
  /// In ar, this message translates to:
  /// **'مورد تجاري'**
  String get supplierAccountBusiness;

  /// No description provided for @supplierMyPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاطي'**
  String get supplierMyPoints;

  /// No description provided for @supplierTotalWeight.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الوزن'**
  String get supplierTotalWeight;

  /// No description provided for @supplierWeightZero.
  ///
  /// In ar, this message translates to:
  /// **'0 كغ'**
  String get supplierWeightZero;

  /// No description provided for @supplierTreesSaved.
  ///
  /// In ar, this message translates to:
  /// **'أشجار أُنقذت'**
  String get supplierTreesSaved;

  /// No description provided for @supplierOrderPendingDriver.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار قبول سائق للطلب'**
  String get supplierOrderPendingDriver;

  /// No description provided for @supplierOrderAcceptedOnWay.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول طلبك، السائق في طريقه إليك'**
  String get supplierOrderAcceptedOnWay;

  /// No description provided for @supplierOrderDriverArrivedPickup.
  ///
  /// In ar, this message translates to:
  /// **'السائق وصل لموقع الاستلام'**
  String get supplierOrderDriverArrivedPickup;

  /// No description provided for @supplierOrderInTransitToDest.
  ///
  /// In ar, this message translates to:
  /// **'طلبك في الطريق إلى وجهته'**
  String get supplierOrderInTransitToDest;

  /// No description provided for @supplierOrderDriverArrivedDropoff.
  ///
  /// In ar, this message translates to:
  /// **'السائق وصل لموقع التسليم'**
  String get supplierOrderDriverArrivedDropoff;

  /// No description provided for @supplierOrderDeliveredSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسليم الطلب بنجاح'**
  String get supplierOrderDeliveredSuccess;

  /// No description provided for @supplierOrderCancelledDone.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الطلب'**
  String get supplierOrderCancelledDone;

  /// No description provided for @driverDeliveryHubs.
  ///
  /// In ar, this message translates to:
  /// **'مراكز التسليم المتاحة'**
  String get driverDeliveryHubs;

  /// No description provided for @driverActiveOrderTitle.
  ///
  /// In ar, this message translates to:
  /// **'الطلب النشط الحالي'**
  String get driverActiveOrderTitle;

  /// No description provided for @driverHubsUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'مراكز التسليم غير متاحة — تحقق من الاتصال'**
  String get driverHubsUnavailable;

  /// No description provided for @driverStatusReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز'**
  String get driverStatusReady;

  /// No description provided for @driverStatusCollecting.
  ///
  /// In ar, this message translates to:
  /// **'يجمع'**
  String get driverStatusCollecting;

  /// No description provided for @driverUnavailableBottomTitle.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح للعمل'**
  String get driverUnavailableBottomTitle;

  /// No description provided for @driverUnavailableBottomSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فعّل وضع التوفر لاستقبال الطلبات الجديدة'**
  String get driverUnavailableBottomSubtitle;

  /// No description provided for @driverEnableNow.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الآن'**
  String get driverEnableNow;

  /// No description provided for @driverNoOrdersAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات متاحة حالياً'**
  String get driverNoOrdersAvailable;

  /// No description provided for @driverNewOrderNotifications.
  ///
  /// In ar, this message translates to:
  /// **'ستصلك إشعارات عند توفر طلبات جديدة'**
  String get driverNewOrderNotifications;

  /// No description provided for @profileAvatarFallback.
  ///
  /// In ar, this message translates to:
  /// **'س'**
  String get profileAvatarFallback;

  /// No description provided for @profileEmailSupportSubject.
  ///
  /// In ar, this message translates to:
  /// **'مساعدة سائق'**
  String get profileEmailSupportSubject;

  /// No description provided for @profileEnterManually.
  ///
  /// In ar, this message translates to:
  /// **'أو أدخل يدوياً'**
  String get profileEnterManually;

  /// No description provided for @profilePlateLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة'**
  String get profilePlateLabel;

  /// No description provided for @profileVehicleTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع المركبة: {type}'**
  String profileVehicleTypeLabel(String type);

  /// No description provided for @driverOrderCardVehicleFallback.
  ///
  /// In ar, this message translates to:
  /// **'مركبة'**
  String get driverOrderCardVehicleFallback;

  /// No description provided for @currencyJodShort.
  ///
  /// In ar, this message translates to:
  /// **'د.أ'**
  String get currencyJodShort;

  /// No description provided for @monthJanuary.
  ///
  /// In ar, this message translates to:
  /// **'يناير'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In ar, this message translates to:
  /// **'فبراير'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In ar, this message translates to:
  /// **'مارس'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In ar, this message translates to:
  /// **'أبريل'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In ar, this message translates to:
  /// **'مايو'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In ar, this message translates to:
  /// **'يونيو'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In ar, this message translates to:
  /// **'يوليو'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In ar, this message translates to:
  /// **'أغسطس'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In ar, this message translates to:
  /// **'سبتمبر'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In ar, this message translates to:
  /// **'أكتوبر'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In ar, this message translates to:
  /// **'نوفمبر'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In ar, this message translates to:
  /// **'ديسمبر'**
  String get monthDecember;

  /// No description provided for @wizardStep1Title.
  ///
  /// In ar, this message translates to:
  /// **'ماذا تريد أن تبيع؟'**
  String get wizardStep1Title;

  /// No description provided for @wizardStep1Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف تفاصيل المواد التي تريد بيعها'**
  String get wizardStep1Subtitle;

  /// No description provided for @wizardMaterialPhotosOptional.
  ///
  /// In ar, this message translates to:
  /// **'صور المواد — اختياري'**
  String get wizardMaterialPhotosOptional;

  /// No description provided for @wizardMaterialTypeRequired.
  ///
  /// In ar, this message translates to:
  /// **'نوع المواد *'**
  String get wizardMaterialTypeRequired;

  /// No description provided for @wizardAiAnalyzing.
  ///
  /// In ar, this message translates to:
  /// **'يقوم الفريق الذكي بتحليل طلبك...'**
  String get wizardAiAnalyzing;

  /// No description provided for @wizardAiAnalysisFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل في تحليل الصورة: {error}'**
  String wizardAiAnalysisFailed(String error);

  /// No description provided for @wizardStep2Title.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المادة'**
  String get wizardStep2Title;

  /// No description provided for @wizardStep2Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'حدد الكمية والحالة والسعر المطلوب'**
  String get wizardStep2Subtitle;

  /// No description provided for @wizardMaterialCondition.
  ///
  /// In ar, this message translates to:
  /// **'حالة المواد *'**
  String get wizardMaterialCondition;

  /// No description provided for @wizardQuantitySize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الكمية *'**
  String get wizardQuantitySize;

  /// No description provided for @wizardRequestedPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر المطلوب (د.أ) — اختياري'**
  String get wizardRequestedPrice;

  /// No description provided for @wizardStep3Title.
  ///
  /// In ar, this message translates to:
  /// **'آخر خطوة!'**
  String get wizardStep3Title;

  /// No description provided for @wizardStep3Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'حدد موقع الاستلام وراجع الإعلان قبل النشر'**
  String get wizardStep3Subtitle;

  /// No description provided for @wizardPickupAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الاستلام *'**
  String get wizardPickupAddress;

  /// No description provided for @wizardTapToSetLocation.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لتحديد الموقع على الخريطة'**
  String get wizardTapToSetLocation;

  /// No description provided for @wizardNotesOptional.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات — اختياري'**
  String get wizardNotesOptional;

  /// No description provided for @wizardNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: المواد موجودة خلف المستودع...'**
  String get wizardNotesHint;

  /// No description provided for @wizardListingSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الإعلان والتأثير البيئي'**
  String get wizardListingSummary;

  /// No description provided for @wizardChangeLocation.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الموقع'**
  String get wizardChangeLocation;

  /// No description provided for @wizardUseCurrentLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام موقعي الحالي'**
  String get wizardUseCurrentLocation;

  /// No description provided for @wizardSummaryMaterialType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المواد'**
  String get wizardSummaryMaterialType;

  /// No description provided for @wizardSummaryCondition.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get wizardSummaryCondition;

  /// No description provided for @wizardSummaryQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get wizardSummaryQuantity;

  /// No description provided for @wizardSummaryPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get wizardSummaryPrice;

  /// No description provided for @wizardPriceUndefined.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get wizardPriceUndefined;

  /// No description provided for @wizardCo2Savings.
  ///
  /// In ar, this message translates to:
  /// **'توفير CO2'**
  String get wizardCo2Savings;

  /// No description provided for @wizardWaterSavings.
  ///
  /// In ar, this message translates to:
  /// **'توفير مياه'**
  String get wizardWaterSavings;

  /// No description provided for @wizardWaterLiters.
  ///
  /// In ar, this message translates to:
  /// **'{liters} لتر'**
  String wizardWaterLiters(String liters);

  /// No description provided for @wizardLocationDefined.
  ///
  /// In ar, this message translates to:
  /// **'موقع محدد'**
  String get wizardLocationDefined;

  /// No description provided for @wizardPublishedToMarket.
  ///
  /// In ar, this message translates to:
  /// **'تم النشر في السوق بنجاح! ✓'**
  String get wizardPublishedToMarket;

  /// No description provided for @wizardPickupRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الاستلام بنجاح! ✓'**
  String get wizardPickupRequestSent;

  /// No description provided for @wizardPickupRequestFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل في إرسال طلب الاستلام'**
  String get wizardPickupRequestFailed;

  /// No description provided for @wizardNewPickupTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب استلام جديد'**
  String get wizardNewPickupTitle;

  /// No description provided for @wizardPublishToMarket.
  ///
  /// In ar, this message translates to:
  /// **'نشر في السوق'**
  String get wizardPublishToMarket;

  /// No description provided for @driverActiveOrderViewPickupDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل الاستلام'**
  String get driverActiveOrderViewPickupDetails;

  /// No description provided for @driverActiveOrderViewDeliveryDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفاصيل التسليم'**
  String get driverActiveOrderViewDeliveryDetails;

  /// No description provided for @driverActiveOrderStepAccepted.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get driverActiveOrderStepAccepted;

  /// No description provided for @driverActiveOrderStepArrivedPickup.
  ///
  /// In ar, this message translates to:
  /// **'وصلت\nللاستلام'**
  String get driverActiveOrderStepArrivedPickup;

  /// No description provided for @driverActiveOrderStepInTransit.
  ///
  /// In ar, this message translates to:
  /// **'في\nالطريق'**
  String get driverActiveOrderStepInTransit;

  /// No description provided for @driverActiveOrderStepDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم\nالتسليم'**
  String get driverActiveOrderStepDelivered;

  /// No description provided for @driverActiveOrderEtaMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} د'**
  String driverActiveOrderEtaMinutes(String minutes);

  /// No description provided for @proofCancelTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء توثيق الاستلام؟'**
  String get proofCancelTitle;

  /// No description provided for @proofCancelBody.
  ///
  /// In ar, this message translates to:
  /// **'ستُفقد الصورة والوزن المُدخل.'**
  String get proofCancelBody;

  /// No description provided for @proofBack.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get proofBack;

  /// No description provided for @proofTitle.
  ///
  /// In ar, this message translates to:
  /// **'توثيق الاستلام'**
  String get proofTitle;

  /// No description provided for @proofShipmentWeight.
  ///
  /// In ar, this message translates to:
  /// **'وزن الشحنة (كغ)'**
  String get proofShipmentWeight;

  /// No description provided for @proofChangePhoto.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get proofChangePhoto;

  /// No description provided for @proofPhotoCaptured.
  ///
  /// In ar, this message translates to:
  /// **'صورة مُلتقطة ✓'**
  String get proofPhotoCaptured;

  /// No description provided for @proofCapturePhoto.
  ///
  /// In ar, this message translates to:
  /// **'التقط صورة الشحنة'**
  String get proofCapturePhoto;

  /// No description provided for @proofRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get proofRetry;

  /// No description provided for @proofConfirmPickup.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاستلام'**
  String get proofConfirmPickup;

  /// No description provided for @proofSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم توثيق الاستلام'**
  String get proofSuccessTitle;

  /// No description provided for @proofSuccessBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إشعار المورّد الآن'**
  String get proofSuccessBody;

  /// No description provided for @driverErrorToggleOfflineWithActive.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك تغيير حالتك إلى غير متاح أثناء وجود طلب نشط.'**
  String get driverErrorToggleOfflineWithActive;

  /// No description provided for @driverErrorAcceptWhileOffline.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متاح حالياً. لا يمكنك قبول الطلب.'**
  String get driverErrorAcceptWhileOffline;

  /// No description provided for @driverErrorLocationUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديد موقعك. تحقق من صلاحية الموقع.'**
  String get driverErrorLocationUnavailable;

  /// No description provided for @driverErrorTooFarPickup.
  ///
  /// In ar, this message translates to:
  /// **'أنت بعيد جداً عن موقع الاستلام ({meters} م). يجب أن تكون ضمن 200 م.'**
  String driverErrorTooFarPickup(int meters);

  /// No description provided for @driverErrorTooFarDelivery.
  ///
  /// In ar, this message translates to:
  /// **'أنت بعيد جداً عن موقع التسليم ({meters} م). يجب أن تكون ضمن 200 م.'**
  String driverErrorTooFarDelivery(int meters);

  /// No description provided for @driverErrorServerGeofence.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من الموقع فشل على الخادم. يجب أن تكون ضمن 200 م.'**
  String get driverErrorServerGeofence;

  /// No description provided for @earningsFilterMonth.
  ///
  /// In ar, this message translates to:
  /// **'شهر'**
  String get earningsFilterMonth;

  /// No description provided for @earningsFilterWeek.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع'**
  String get earningsFilterWeek;

  /// No description provided for @earningsFilterDay.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get earningsFilterDay;

  /// No description provided for @earningsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get earningsTitle;

  /// No description provided for @earningsNetTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأرباح الصافية'**
  String get earningsNetTotal;

  /// No description provided for @earningsIncreaseVsPrev.
  ///
  /// In ar, this message translates to:
  /// **'زيادة عن الفترة السابقة'**
  String get earningsIncreaseVsPrev;

  /// No description provided for @earningsFinancialDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل العوائد المالية'**
  String get earningsFinancialDetails;

  /// No description provided for @earningsDistanceFees.
  ///
  /// In ar, this message translates to:
  /// **'رسوم المسافات'**
  String get earningsDistanceFees;

  /// No description provided for @earningsNetTotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الصافي'**
  String get earningsNetTotalLabel;

  /// No description provided for @earningsBestDay.
  ///
  /// In ar, this message translates to:
  /// **'يومك الأفضل'**
  String get earningsBestDay;

  /// No description provided for @weekdayMonday.
  ///
  /// In ar, this message translates to:
  /// **'الإثنين'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get weekdaySunday;

  /// No description provided for @earningsMyEarnings.
  ///
  /// In ar, this message translates to:
  /// **'أرباحي'**
  String get earningsMyEarnings;

  /// No description provided for @earningsRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث البيانات'**
  String get earningsRefresh;

  /// No description provided for @earningsTrend.
  ///
  /// In ar, this message translates to:
  /// **'اتجاه الأرباح'**
  String get earningsTrend;

  /// No description provided for @earningsRecentActivity.
  ///
  /// In ar, this message translates to:
  /// **'النشاط الأخير'**
  String get earningsRecentActivity;

  /// No description provided for @earningsDownloadReport.
  ///
  /// In ar, this message translates to:
  /// **'تحميل تقرير الأداء'**
  String get earningsDownloadReport;

  /// No description provided for @earningsTotalEarnings.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأرباح'**
  String get earningsTotalEarnings;

  /// No description provided for @earningsTripsCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الرحلات'**
  String get earningsTripsCount;

  /// No description provided for @earningsAverage.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الأرباح'**
  String get earningsAverage;

  /// No description provided for @chatDateToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get chatDateToday;

  /// No description provided for @chatDateYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get chatDateYesterday;

  /// No description provided for @chatTyping.
  ///
  /// In ar, this message translates to:
  /// **'يكتب الآن'**
  String get chatTyping;

  /// Kilogram unit abbreviation
  ///
  /// In ar, this message translates to:
  /// **'كغ'**
  String get unitKg;

  /// No description provided for @unitKm.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get unitKm;

  /// No description provided for @orderArrivalAtPickup.
  ///
  /// In ar, this message translates to:
  /// **'وصلت إلى موقع الاستلام؟'**
  String get orderArrivalAtPickup;

  /// No description provided for @orderArrivalGeoNote.
  ///
  /// In ar, this message translates to:
  /// **'سيتم التحقق من موقعك (ضمن 200 م)'**
  String get orderArrivalGeoNote;

  /// No description provided for @orderArrivalHerePickup.
  ///
  /// In ar, this message translates to:
  /// **'أنا هنا — الاستلام'**
  String get orderArrivalHerePickup;

  /// No description provided for @orderArrivalAtDropoff.
  ///
  /// In ar, this message translates to:
  /// **'وصلت إلى موقع التسليم؟'**
  String get orderArrivalAtDropoff;

  /// No description provided for @orderArrivalHereDropoff.
  ///
  /// In ar, this message translates to:
  /// **'أنا هنا — التسليم'**
  String get orderArrivalHereDropoff;

  /// No description provided for @orderArrivalAwaitingSupplier.
  ///
  /// In ar, this message translates to:
  /// **'في انتظار تأكيد المورد'**
  String get orderArrivalAwaitingSupplier;

  /// No description provided for @orderArrivalAwaitingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'المورد لديه 5 دقائق للرد — سيُعوَّض السائق تلقائياً عند انتهاء المهلة'**
  String get orderArrivalAwaitingSubtitle;

  /// No description provided for @orderArrivalDriverArrived.
  ///
  /// In ar, this message translates to:
  /// **'السائق وصل!'**
  String get orderArrivalDriverArrived;

  /// No description provided for @orderArrivalDriverAtLocation.
  ///
  /// In ar, this message translates to:
  /// **'السائق في موقعك الآن. هل أنت متاح لتسليم المواد؟'**
  String get orderArrivalDriverAtLocation;

  /// No description provided for @orderArrivalIAmAvailable.
  ///
  /// In ar, this message translates to:
  /// **'أنا متاح'**
  String get orderArrivalIAmAvailable;

  /// No description provided for @acceptJobTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف تريد المتابعة؟'**
  String get acceptJobTitle;

  /// No description provided for @acceptJobSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر طريقة التوصيل ونوع المعاملة لقبول الوظيفة'**
  String get acceptJobSubtitle;

  /// No description provided for @acceptJobDeliveryFeeCompany.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل على الشركة'**
  String get acceptJobDeliveryFeeCompany;

  /// No description provided for @acceptJobDeliveryFeeYou.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل عليك'**
  String get acceptJobDeliveryFeeYou;

  /// No description provided for @acceptJobConfirmButton.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد القبول'**
  String get acceptJobConfirmButton;

  /// No description provided for @marketDeliveryConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الشراء والتوصيل'**
  String get marketDeliveryConfirmTitle;

  /// No description provided for @marketDeliveryFeeNote.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل محسوبة حسب المسافة والوزن'**
  String get marketDeliveryFeeNote;

  /// No description provided for @marketDeliverySellerLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقع البائع'**
  String get marketDeliverySellerLocation;

  /// No description provided for @marketDeliveryAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان التوصيل'**
  String get marketDeliveryAddressLabel;

  /// No description provided for @marketDeliveryDistanceFeeRow.
  ///
  /// In ar, this message translates to:
  /// **'رسوم المسافة ({distance} كم × 0.2)'**
  String marketDeliveryDistanceFeeRow(String distance);

  /// No description provided for @marketDeliveryWeightFeeRow.
  ///
  /// In ar, this message translates to:
  /// **'رسوم الوزن ({weight})'**
  String marketDeliveryWeightFeeRow(String weight);

  /// No description provided for @marketDeliveryBaseFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل الأساسية'**
  String get marketDeliveryBaseFee;

  /// No description provided for @marketDeliveryTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get marketDeliveryTotal;

  /// No description provided for @marketDeliveryConfirmButton.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الشراء — {total}'**
  String marketDeliveryConfirmButton(String total);

  /// No description provided for @marketPurchaseChoiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر طريقة الاستلام'**
  String get marketPurchaseChoiceTitle;

  /// No description provided for @marketPurchaseChoiceSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك الاستلام بنفسك أو تعيين سائق للتوصيل'**
  String get marketPurchaseChoiceSubtitle;

  /// No description provided for @marketPurchaseSelfPickup.
  ///
  /// In ar, this message translates to:
  /// **'استلام من السوق'**
  String get marketPurchaseSelfPickup;

  /// No description provided for @marketPurchaseNoFee.
  ///
  /// In ar, this message translates to:
  /// **'بدون رسوم توصيل'**
  String get marketPurchaseNoFee;

  /// No description provided for @marketPurchaseAssignRider.
  ///
  /// In ar, this message translates to:
  /// **'تعيين سائق للتوصيل'**
  String get marketPurchaseAssignRider;

  /// No description provided for @marketPurchaseRiderFeeNote.
  ///
  /// In ar, this message translates to:
  /// **'حساب رسوم التوصيل حسب المسافة والوزن'**
  String get marketPurchaseRiderFeeNote;

  /// No description provided for @walletTitle.
  ///
  /// In ar, this message translates to:
  /// **'محفظتي'**
  String get walletTitle;

  /// No description provided for @walletPointsAndRewards.
  ///
  /// In ar, this message translates to:
  /// **'نقاطي ومكافآتي'**
  String get walletPointsAndRewards;

  /// No description provided for @walletBillingPayments.
  ///
  /// In ar, this message translates to:
  /// **'الفوترة والمدفوعات'**
  String get walletBillingPayments;

  /// No description provided for @walletAvailableBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح'**
  String get walletAvailableBalance;

  /// No description provided for @walletHeldAmount.
  ///
  /// In ar, this message translates to:
  /// **'المحجوز'**
  String get walletHeldAmount;

  /// No description provided for @walletWithdrawButton.
  ///
  /// In ar, this message translates to:
  /// **'طلب صرف رصيد'**
  String get walletWithdrawButton;

  /// No description provided for @walletPointUnit.
  ///
  /// In ar, this message translates to:
  /// **'نقطة'**
  String get walletPointUnit;

  /// No description provided for @walletPointsToNextReward.
  ///
  /// In ar, this message translates to:
  /// **'تبقّى {n} نقطة للمكافأة القادمة'**
  String walletPointsToNextReward(String n);

  /// No description provided for @walletViewRewards.
  ///
  /// In ar, this message translates to:
  /// **'عرض المكافآت'**
  String get walletViewRewards;

  /// No description provided for @walletCurrentPeriod.
  ///
  /// In ar, this message translates to:
  /// **'الفترة الحالية:'**
  String get walletCurrentPeriod;

  /// No description provided for @walletShipments.
  ///
  /// In ar, this message translates to:
  /// **'الشحنات'**
  String get walletShipments;

  /// No description provided for @walletWeightKg.
  ///
  /// In ar, this message translates to:
  /// **'الوزن (كغ)'**
  String get walletWeightKg;

  /// No description provided for @walletViewInvoice.
  ///
  /// In ar, this message translates to:
  /// **'عرض الفاتورة'**
  String get walletViewInvoice;

  /// No description provided for @walletEfawateerTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع عبر فواتيركم'**
  String get walletEfawateerTitle;

  /// No description provided for @walletEfawateerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'منصة الدفع الإلكتروني الحكومية'**
  String get walletEfawateerSubtitle;

  /// No description provided for @analyticsStreakChip.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{🔥 يوم متتالٍ} =2{🔥 يومان متتاليان} few{🔥 # أيام متتالية} many{🔥 # يوماً متتالياً} other{🔥 # يوم متتالٍ}}'**
  String analyticsStreakChip(int count);

  /// No description provided for @analyticsStreakSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلسلة النشاط'**
  String get analyticsStreakSectionTitle;

  /// No description provided for @analyticsStreakBest.
  ///
  /// In ar, this message translates to:
  /// **'أطول سلسلة: {count, plural, =1{يوم} =2{يومان} few{# أيام} many{# يوماً} other{# يوم}}'**
  String analyticsStreakBest(int count);

  /// No description provided for @analyticsStreakEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد نشاط بعد — ابدأ أول طلب اليوم!'**
  String get analyticsStreakEmpty;

  /// No description provided for @analyticsCycleSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'زمن دورة الطلب'**
  String get analyticsCycleSectionTitle;

  /// No description provided for @analyticsCycleAvgCaption.
  ///
  /// In ar, this message translates to:
  /// **'متوسط زمن الطلب الكامل: {minutes} دقيقة'**
  String analyticsCycleAvgCaption(int minutes);

  /// No description provided for @analyticsCycleStageAccept.
  ///
  /// In ar, this message translates to:
  /// **'الانتظار حتى القبول'**
  String get analyticsCycleStageAccept;

  /// No description provided for @analyticsCycleStagePickup.
  ///
  /// In ar, this message translates to:
  /// **'الوصول للالتقاط'**
  String get analyticsCycleStagePickup;

  /// No description provided for @analyticsCycleStageTransit.
  ///
  /// In ar, this message translates to:
  /// **'النقل'**
  String get analyticsCycleStageTransit;

  /// No description provided for @analyticsCycleStageDropoff.
  ///
  /// In ar, this message translates to:
  /// **'التسليم'**
  String get analyticsCycleStageDropoff;

  /// No description provided for @analyticsCycleMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة'**
  String analyticsCycleMinutes(String minutes);

  /// No description provided for @analyticsCycleEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات كافية لتحليل زمن الطلب'**
  String get analyticsCycleEmpty;

  /// No description provided for @analyticsProfitabilitySectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'أربح المواد'**
  String get analyticsProfitabilitySectionTitle;

  /// No description provided for @analyticsProfitabilityPerKg.
  ///
  /// In ar, this message translates to:
  /// **'{value} د.أ/كغ'**
  String analyticsProfitabilityPerKg(String value);

  /// No description provided for @analyticsProfitabilityTopBadge.
  ///
  /// In ar, this message translates to:
  /// **'🏆 الأعلى ربحًا'**
  String get analyticsProfitabilityTopBadge;

  /// No description provided for @analyticsProfitabilityEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات كافية لتحليل ربحية المواد'**
  String get analyticsProfitabilityEmpty;

  /// No description provided for @analyticsEfficiencySectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'كفاءة الأرباح'**
  String get analyticsEfficiencySectionTitle;

  /// No description provided for @analyticsEfficiencyRatioCaption.
  ///
  /// In ar, this message translates to:
  /// **'متوسط ما تربحه لكل كيلومتر'**
  String get analyticsEfficiencyRatioCaption;

  /// No description provided for @analyticsEfficiencyRatioValue.
  ///
  /// In ar, this message translates to:
  /// **'{value} د.أ/كم'**
  String analyticsEfficiencyRatioValue(String value);

  /// No description provided for @analyticsEfficiencyTopJobs.
  ///
  /// In ar, this message translates to:
  /// **'أفضل الرحلات'**
  String get analyticsEfficiencyTopJobs;

  /// No description provided for @analyticsEfficiencyEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات مسافة لحساب الكفاءة'**
  String get analyticsEfficiencyEmpty;

  /// No description provided for @aboutDwaarButtonLabel.
  ///
  /// In ar, this message translates to:
  /// **'تعرّف على دوّر'**
  String get aboutDwaarButtonLabel;

  /// No description provided for @aboutDwaarSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'من نحن وماذا نقدّم'**
  String get aboutDwaarSheetTitle;

  /// No description provided for @aboutDwaarIntroBody.
  ///
  /// In ar, this message translates to:
  /// **'دوّر (Dwaar) منصة أردنية تربط بين ثلاثة أطراف: الموردين الذين لديهم نفايات قابلة لإعادة التدوير، السائقين الذين ينقلونها، وشركات إعادة التدوير التي تشتريها. هدفنا تحويل النفايات إلى مورد ذو قيمة، وتسهيل الاقتصاد الدائري في الأردن بخطوات بسيطة من هاتفك.'**
  String get aboutDwaarIntroBody;

  /// No description provided for @aboutDwaarServicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'خدماتنا لكل طرف'**
  String get aboutDwaarServicesTitle;

  /// No description provided for @aboutDwaarServiceSupplierTitle.
  ///
  /// In ar, this message translates to:
  /// **'للموردين (أفراد ومتاجر)'**
  String get aboutDwaarServiceSupplierTitle;

  /// No description provided for @aboutDwaarServiceSupplierBody.
  ///
  /// In ar, this message translates to:
  /// **'اطلب استلام نفاياتك القابلة لإعادة التدوير من موقعك، اختر بيعها لشركة تدوير أو عرضها في السوق لأقرب سائق، واربح نقاط ومكافآت مقابل كل عملية.'**
  String get aboutDwaarServiceSupplierBody;

  /// No description provided for @aboutDwaarServiceDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'للسائقين'**
  String get aboutDwaarServiceDriverTitle;

  /// No description provided for @aboutDwaarServiceDriverBody.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح طلبات الاستلام القريبة منك حسب نوع مركبتك، اقبل الطلب المناسب، وتتبّع أرباحك لحظة بلحظة مع كل رحلة تُنجزها.'**
  String get aboutDwaarServiceDriverBody;

  /// No description provided for @aboutDwaarServiceRecyclingTitle.
  ///
  /// In ar, this message translates to:
  /// **'لشركات إعادة التدوير'**
  String get aboutDwaarServiceRecyclingTitle;

  /// No description provided for @aboutDwaarServiceRecyclingBody.
  ///
  /// In ar, this message translates to:
  /// **'انشر طلبات تجميع بحسب نوع المادة والكمية والمنطقة، واستقبل تدفقًا منظّمًا وموثّقًا من المواد الخام مباشرة من الموردين والسائقين.'**
  String get aboutDwaarServiceRecyclingBody;

  /// No description provided for @aboutDwaarHowItWorksTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف تعمل دورة الطلب؟'**
  String get aboutDwaarHowItWorksTitle;

  /// No description provided for @aboutDwaarHowItWorksStep1.
  ///
  /// In ar, this message translates to:
  /// **'١. المورد يطلب استلام النفايات ويحدّد النوع والوزن التقريبي والموقع'**
  String get aboutDwaarHowItWorksStep1;

  /// No description provided for @aboutDwaarHowItWorksStep2.
  ///
  /// In ar, this message translates to:
  /// **'٢. سائق مناسب يقبل الطلب، ويظهر موقعه المباشر على الخريطة حتى الوصول'**
  String get aboutDwaarHowItWorksStep2;

  /// No description provided for @aboutDwaarHowItWorksStep3.
  ///
  /// In ar, this message translates to:
  /// **'٣. عند التسليم، يتم توثيق الوزن الفعلي وتأكيد الاستلام من الطرفين'**
  String get aboutDwaarHowItWorksStep3;

  /// No description provided for @aboutDwaarHowItWorksStep4.
  ///
  /// In ar, this message translates to:
  /// **'٤. تُصرف المكافآت والأرباح تلقائيًا، وتنتقل المواد إلى شركة إعادة التدوير أو المركز الأقرب'**
  String get aboutDwaarHowItWorksStep4;

  /// No description provided for @aboutDwaarRewardsTitle.
  ///
  /// In ar, this message translates to:
  /// **'نظام المكافآت (نقاط خُضَر)'**
  String get aboutDwaarRewardsTitle;

  /// No description provided for @aboutDwaarRewardsBody.
  ///
  /// In ar, this message translates to:
  /// **'كل عملية تدوير مكتملة تمنحك نقاط خُضَر بحسب نوع المادة ووزنها. اجمع النقاط لترتقي في مستويات البطاقة الخضراء، واستبدلها بخصومات على الطلبات القادمة أو قسائم شراء من شركائنا. السائقون أيضًا يحصلون على أجرة لكل رحلة تُحتسب من الأجرة الأساسية والمسافة ونوع المادة المنقولة.'**
  String get aboutDwaarRewardsBody;

  /// No description provided for @aboutDwaarHubsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مراكز التجميع (Hubs)'**
  String get aboutDwaarHubsTitle;

  /// No description provided for @aboutDwaarHubsBody.
  ///
  /// In ar, this message translates to:
  /// **'مراكز التجميع نقاط استلام فعلية تديرها فرق دوّر، يستخدمها السائقون كوجهة تسليم قريبة بدل التوجه مباشرة لكل شركة تدوير. إذا كانت لديك منشأة أو أرض مناسبة وتودّ استضافة مركز تجميع جديد في منطقتك، تواصل معنا عبر النموذج أدناه وسيقيّم فريقنا الطلب.'**
  String get aboutDwaarHubsBody;

  /// No description provided for @aboutDwaarImpactTitle.
  ///
  /// In ar, this message translates to:
  /// **'أثرنا حتى الآن'**
  String get aboutDwaarImpactTitle;

  /// No description provided for @aboutDwaarImpactSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لمحة حيّة عمّا حققه مجتمعنا معًا'**
  String get aboutDwaarImpactSubtitle;

  /// No description provided for @aboutDwaarImpactOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات مكتملة'**
  String get aboutDwaarImpactOrders;

  /// No description provided for @aboutDwaarImpactWeight.
  ///
  /// In ar, this message translates to:
  /// **'وزن معاد تدويره'**
  String get aboutDwaarImpactWeight;

  /// No description provided for @aboutDwaarImpactCo2.
  ///
  /// In ar, this message translates to:
  /// **'CO₂ وُفِّر'**
  String get aboutDwaarImpactCo2;

  /// No description provided for @aboutDwaarImpactWater.
  ///
  /// In ar, this message translates to:
  /// **'مياه وُفِّرت'**
  String get aboutDwaarImpactWater;

  /// No description provided for @aboutDwaarImpactEnergy.
  ///
  /// In ar, this message translates to:
  /// **'طاقة وُفِّرت'**
  String get aboutDwaarImpactEnergy;

  /// No description provided for @aboutDwaarImpactDownloadButton.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل شهادة CO₂ (PDF)'**
  String get aboutDwaarImpactDownloadButton;

  /// No description provided for @aboutDwaarImpactDownloadGenerating.
  ///
  /// In ar, this message translates to:
  /// **'جاري الإنشاء...'**
  String get aboutDwaarImpactDownloadGenerating;

  /// No description provided for @aboutDwaarImpactDownloadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إنشاء الشهادة. حاول مرة أخرى.'**
  String get aboutDwaarImpactDownloadError;

  /// No description provided for @aboutDwaarDataTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد شراء بياناتنا أو الشراكة معنا؟'**
  String get aboutDwaarDataTitle;

  /// No description provided for @aboutDwaarDataBody.
  ///
  /// In ar, this message translates to:
  /// **'نوفّر لبعض الجهات (بلديات، جهات بحثية، شركات استدامة) بيانات مجمّعة وغير شخصية حول أنماط التدوير. إن كنت مهتمًا بشراء بيانات أو ببناء شراكة، اترك بياناتك وسيتواصل معك فريقنا عبر البريد الإلكتروني.'**
  String get aboutDwaarDataBody;

  /// No description provided for @aboutDwaarDataFormCompanyLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الجهة / الشركة'**
  String get aboutDwaarDataFormCompanyLabel;

  /// No description provided for @aboutDwaarDataFormContactNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الشخص المسؤول'**
  String get aboutDwaarDataFormContactNameLabel;

  /// No description provided for @aboutDwaarDataFormEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني للتواصل'**
  String get aboutDwaarDataFormEmailLabel;

  /// No description provided for @aboutDwaarDataFormPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف (اختياري)'**
  String get aboutDwaarDataFormPhoneLabel;

  /// No description provided for @aboutDwaarDataFormMessageLabel.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل طلبك'**
  String get aboutDwaarDataFormMessageLabel;

  /// No description provided for @aboutDwaarDataFormMessageHint.
  ///
  /// In ar, this message translates to:
  /// **'ما نوع البيانات أو الشراكة التي تبحث عنها؟'**
  String get aboutDwaarDataFormMessageHint;

  /// No description provided for @aboutDwaarDataFormSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get aboutDwaarDataFormSubmit;

  /// No description provided for @aboutDwaarDataFormSubmitting.
  ///
  /// In ar, this message translates to:
  /// **'جاري الإرسال...'**
  String get aboutDwaarDataFormSubmitting;

  /// No description provided for @aboutDwaarDataFormRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get aboutDwaarDataFormRequired;

  /// No description provided for @aboutDwaarDataFormEmailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدًا إلكترونيًا صحيحًا'**
  String get aboutDwaarDataFormEmailInvalid;

  /// No description provided for @aboutDwaarDataFormSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام طلبك، سيتواصل معك فريقنا عبر بريدك الإلكتروني قريبًا.'**
  String get aboutDwaarDataFormSuccess;

  /// No description provided for @aboutDwaarDataFormError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إرسال الطلب، حاول مرة أخرى'**
  String get aboutDwaarDataFormError;

  /// No description provided for @aboutDwaarCloseButton.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get aboutDwaarCloseButton;

  /// No description provided for @reservationBookButton.
  ///
  /// In ar, this message translates to:
  /// **'حجز الآن'**
  String get reservationBookButton;

  /// No description provided for @reservationFormTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حجز جديد'**
  String get reservationFormTitle;

  /// No description provided for @reservationItemTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'وصف الطلب'**
  String get reservationItemTitleLabel;

  /// No description provided for @reservationItemTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: طاولة لأربعة أشخاص، ٧ مساءً'**
  String get reservationItemTitleHint;

  /// No description provided for @reservationBuyerPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف المشتري'**
  String get reservationBuyerPhoneLabel;

  /// No description provided for @reservationBuyerPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'7XXXXXXXX'**
  String get reservationBuyerPhoneHint;

  /// No description provided for @reservationBuyerNotFound.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير مسجل في التطبيق'**
  String get reservationBuyerNotFound;

  /// No description provided for @reservationInvoiceAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الفاتورة (د.أ)'**
  String get reservationInvoiceAmountLabel;

  /// No description provided for @reservationDurationLabel.
  ///
  /// In ar, this message translates to:
  /// **'مدة الحجز'**
  String get reservationDurationLabel;

  /// No description provided for @reservationDurationMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة'**
  String reservationDurationMinutes(int minutes);

  /// No description provided for @reservationPenaltyBanner.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه: سيتم خصم ١٠٪ من قيمة الفاتورة ({amount} د.أ) من الطرف المخالف لضمان حقوق التعامل'**
  String reservationPenaltyBanner(String amount);

  /// No description provided for @reservationSubmitButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحجز'**
  String get reservationSubmitButton;

  /// No description provided for @reservationCreateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحجز وإرساله للمشتري'**
  String get reservationCreateSuccess;

  /// No description provided for @reservationInboxTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الحجز'**
  String get reservationInboxTitle;

  /// No description provided for @reservationEmptyInbox.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات حجز حالياً'**
  String get reservationEmptyInbox;

  /// No description provided for @reservationInvoiceTotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الإجمالي'**
  String get reservationInvoiceTotalLabel;

  /// No description provided for @reservationTimeRemainingLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتبقي'**
  String get reservationTimeRemainingLabel;

  /// No description provided for @reservationApproveButton.
  ///
  /// In ar, this message translates to:
  /// **'قبول وتثبيت الحجز'**
  String get reservationApproveButton;

  /// No description provided for @reservationApproveSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تثبيت الحجز'**
  String get reservationApproveSuccess;

  /// No description provided for @reservationCompleteButton.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد إتمام الشراء'**
  String get reservationCompleteButton;

  /// No description provided for @reservationCancelButton.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get reservationCancelButton;

  /// No description provided for @reservationCancelReasonTitle.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإلغاء'**
  String get reservationCancelReasonTitle;

  /// No description provided for @reservationCancelReasonSoldElsewhere.
  ///
  /// In ar, this message translates to:
  /// **'تم بيع البضاعة لطرف آخر'**
  String get reservationCancelReasonSoldElsewhere;

  /// No description provided for @reservationCancelReasonOther.
  ///
  /// In ar, this message translates to:
  /// **'سبب آخر'**
  String get reservationCancelReasonOther;

  /// No description provided for @reservationCancelFraudWarning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير: اختيار هذا السبب سيؤدي لخصم ١٠٪ من حسابك فوراً كتعويض للمشتري'**
  String get reservationCancelFraudWarning;

  /// No description provided for @reservationSellerTag.
  ///
  /// In ar, this message translates to:
  /// **'أنت البائع'**
  String get reservationSellerTag;

  /// No description provided for @reservationBuyerTag.
  ///
  /// In ar, this message translates to:
  /// **'أنت المشتري'**
  String get reservationBuyerTag;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
