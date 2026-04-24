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

  /// No description provided for @withdrawListing.
  ///
  /// In ar, this message translates to:
  /// **'سحب الإعلان'**
  String get withdrawListing;

  /// No description provided for @withdrawListingConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد سحب هذا الإعلان من السوق؟'**
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

  /// No description provided for @rateDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'قيّم السائق'**
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

  /// No description provided for @orderStatusStepInTransit.
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get orderStatusStepInTransit;

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
