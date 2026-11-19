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
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// App name, shown as the wordmark
  ///
  /// In ar, this message translates to:
  /// **'سبرنت'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navFacilities.
  ///
  /// In ar, this message translates to:
  /// **'المنشآت'**
  String get navFacilities;

  /// No description provided for @navBookings.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتي'**
  String get navBookings;

  /// No description provided for @navProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navProfile;

  /// No description provided for @navMainLabel.
  ///
  /// In ar, this message translates to:
  /// **'التنقل الرئيسي'**
  String get navMainLabel;

  /// No description provided for @placeholderNote.
  ///
  /// In ar, this message translates to:
  /// **'الشاشة دي لسه تحت التجهيز.'**
  String get placeholderNote;

  /// No description provided for @homeIntro.
  ///
  /// In ar, this message translates to:
  /// **'هنا هتلاقي المنشآت والمواعيد القريبة.'**
  String get homeIntro;

  /// No description provided for @facilitiesIntro.
  ///
  /// In ar, this message translates to:
  /// **'كل منشآت الجامعة الرياضية في مكان واحد.'**
  String get facilitiesIntro;

  /// No description provided for @facilitiesSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن منشأة'**
  String get facilitiesSearchHint;

  /// No description provided for @signInPromptTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول مطلوب'**
  String get signInPromptTitle;

  /// No description provided for @signInPromptBody.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتك وبيانات حسابك هتظهر هنا بعد تسجيل الدخول.'**
  String get signInPromptBody;

  /// No description provided for @gateTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة دي محتاجة حساب'**
  String get gateTitle;

  /// No description provided for @gateBody.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول أو إنشاء حساب {reason}'**
  String gateBody(String reason);

  /// No description provided for @gateSignIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get gateSignIn;

  /// No description provided for @gateSignUp.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get gateSignUp;

  /// No description provided for @gateDismiss.
  ///
  /// In ar, this message translates to:
  /// **'مش دلوقتي'**
  String get gateDismiss;

  /// No description provided for @gateReasonBook.
  ///
  /// In ar, this message translates to:
  /// **'عشان تحجز'**
  String get gateReasonBook;

  /// No description provided for @gateReasonBookings.
  ///
  /// In ar, this message translates to:
  /// **'عشان تشوف حجوزاتك'**
  String get gateReasonBookings;

  /// No description provided for @gateReasonVerification.
  ///
  /// In ar, this message translates to:
  /// **'عشان تطلب التوثيق'**
  String get gateReasonVerification;

  /// No description provided for @gateReasonProfile.
  ///
  /// In ar, this message translates to:
  /// **'عشان تشوف بيانات حسابك'**
  String get gateReasonProfile;

  /// No description provided for @gateDemoBookSlot.
  ///
  /// In ar, this message translates to:
  /// **'حجز الميعاد ده'**
  String get gateDemoBookSlot;

  /// No description provided for @gateDemoTitle.
  ///
  /// In ar, this message translates to:
  /// **'تجربة طلب الحساب'**
  String get gateDemoTitle;

  /// No description provided for @gateDemoIntro.
  ///
  /// In ar, this message translates to:
  /// **'بعد اختيار ميعاد والضغط على الحجز، الزائر بتظهر له نافذة الحساب، وبعد الدخول بيرجع هنا والميعاد لسه مختار.'**
  String get gateDemoIntro;

  /// No description provided for @gateDemoReady.
  ///
  /// In ar, this message translates to:
  /// **'الحساب جاهز. الحجز ماتمش لوحده، ومحتاج ضغطة جديدة.'**
  String get gateDemoReady;

  /// No description provided for @gateDemoDismissed.
  ///
  /// In ar, this message translates to:
  /// **'اتقفلت من غير تسجيل دخول، ولسه الميعاد مختار.'**
  String get gateDemoDismissed;

  /// No description provided for @notFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة دي مش موجودة'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In ar, this message translates to:
  /// **'الرابط ممكن يكون اتغيّر أو مكتوب غلط.'**
  String get notFoundBody;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع للرئيسية'**
  String get backToHome;

  /// No description provided for @noAccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة دي مش متاحة لحسابك'**
  String get noAccessTitle;

  /// No description provided for @noAccessBody.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة دي مخصوصة لصلاحيات تانية. لو محتاج الوصول ليها ممكن تتواصل مع مسؤول الجامعة.'**
  String get noAccessBody;

  /// No description provided for @homeTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا في سبرنت'**
  String get homeTitle;

  /// No description provided for @facilitiesTitle.
  ///
  /// In ar, this message translates to:
  /// **'منشآت الجامعة'**
  String get facilitiesTitle;

  /// Price in Egyptian pounds; amount is already formatted with Western digits
  ///
  /// In ar, this message translates to:
  /// **'{amount} ج.م'**
  String priceEgp(String amount);

  /// No description provided for @appearanceTitle.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearanceTitle;

  /// No description provided for @appearanceSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب الجهاز'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In ar, this message translates to:
  /// **'غامق'**
  String get appearanceDark;

  /// No description provided for @languageTitle.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get languageTitle;

  /// No description provided for @languageAr.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageAr;

  /// No description provided for @languageEn.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @demoEntry.
  ///
  /// In ar, this message translates to:
  /// **'شاشة العرض للمراجعين'**
  String get demoEntry;

  /// No description provided for @optionSelected.
  ///
  /// In ar, this message translates to:
  /// **'مختار'**
  String get optionSelected;

  /// No description provided for @dayShortSaturday.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get dayShortSaturday;

  /// No description provided for @dayShortSunday.
  ///
  /// In ar, this message translates to:
  /// **'الحد'**
  String get dayShortSunday;

  /// No description provided for @dayShortMonday.
  ///
  /// In ar, this message translates to:
  /// **'الاتنين'**
  String get dayShortMonday;

  /// No description provided for @dayShortTuesday.
  ///
  /// In ar, this message translates to:
  /// **'التلات'**
  String get dayShortTuesday;

  /// No description provided for @dayShortWednesday.
  ///
  /// In ar, this message translates to:
  /// **'الأربع'**
  String get dayShortWednesday;

  /// No description provided for @dayShortThursday.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get dayShortThursday;

  /// No description provided for @dayShortFriday.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get dayShortFriday;

  /// No description provided for @dayFullSaturday.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get dayFullSaturday;

  /// No description provided for @dayFullSunday.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get dayFullSunday;

  /// No description provided for @dayFullMonday.
  ///
  /// In ar, this message translates to:
  /// **'الاثنين'**
  String get dayFullMonday;

  /// No description provided for @dayFullTuesday.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get dayFullTuesday;

  /// No description provided for @dayFullWednesday.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get dayFullWednesday;

  /// No description provided for @dayFullThursday.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get dayFullThursday;

  /// No description provided for @dayFullFriday.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get dayFullFriday;

  /// No description provided for @demoTitle.
  ///
  /// In ar, this message translates to:
  /// **'شاشة العرض'**
  String get demoTitle;

  /// No description provided for @demoColours.
  ///
  /// In ar, this message translates to:
  /// **'الألوان'**
  String get demoColours;

  /// No description provided for @demoTypography.
  ///
  /// In ar, this message translates to:
  /// **'الخطوط'**
  String get demoTypography;

  /// No description provided for @demoSpacing.
  ///
  /// In ar, this message translates to:
  /// **'المسافات'**
  String get demoSpacing;

  /// No description provided for @demoRadius.
  ///
  /// In ar, this message translates to:
  /// **'الزوايا'**
  String get demoRadius;

  /// No description provided for @demoControls.
  ///
  /// In ar, this message translates to:
  /// **'عناصر التحكم حسب النظام'**
  String get demoControls;

  /// No description provided for @demoTypeSample.
  ///
  /// In ar, this message translates to:
  /// **'سبرنت – حجزك اتأكد 120'**
  String get demoTypeSample;

  /// No description provided for @demoAppBarTrigger.
  ///
  /// In ar, this message translates to:
  /// **'عرض شريط العنوان الكبير'**
  String get demoAppBarTrigger;

  /// No description provided for @demoLargeTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان كبير'**
  String get demoLargeTitle;

  /// No description provided for @demoDialogTrigger.
  ///
  /// In ar, this message translates to:
  /// **'عرض نافذة التأكيد'**
  String get demoDialogTrigger;

  /// No description provided for @demoDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز؟'**
  String get demoDialogTitle;

  /// No description provided for @demoDialogMessage.
  ///
  /// In ar, this message translates to:
  /// **'المكان هيرجع متاح لغيرك.'**
  String get demoDialogMessage;

  /// No description provided for @demoDialogConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get demoDialogConfirm;

  /// No description provided for @demoDialogKeep.
  ///
  /// In ar, this message translates to:
  /// **'التراجع'**
  String get demoDialogKeep;

  /// No description provided for @demoSheetTrigger.
  ///
  /// In ar, this message translates to:
  /// **'عرض قايمة الإجراءات'**
  String get demoSheetTrigger;

  /// No description provided for @demoSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات الحجز'**
  String get demoSheetTitle;

  /// No description provided for @demoSheetShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get demoSheetShare;

  /// No description provided for @demoSheetCalendar.
  ///
  /// In ar, this message translates to:
  /// **'إضافة للتقويم'**
  String get demoSheetCalendar;

  /// No description provided for @demoSheetClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get demoSheetClose;

  /// No description provided for @demoSwitchLabel.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل التذكيرات'**
  String get demoSwitchLabel;

  /// No description provided for @demoLoaderLabel.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل'**
  String get demoLoaderLabel;

  /// No description provided for @demoResult.
  ///
  /// In ar, this message translates to:
  /// **'آخر اختيار: {value}'**
  String demoResult(String value);

  /// No description provided for @demoResultNone.
  ///
  /// In ar, this message translates to:
  /// **'لسه مفيش اختيار'**
  String get demoResultNone;

  /// No description provided for @demoAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر واللغة'**
  String get demoAppearance;

  /// No description provided for @roleBooker.
  ///
  /// In ar, this message translates to:
  /// **'حاجز'**
  String get roleBooker;

  /// No description provided for @roleTrainer.
  ///
  /// In ar, this message translates to:
  /// **'مدرب'**
  String get roleTrainer;

  /// No description provided for @roleFacilityManager.
  ///
  /// In ar, this message translates to:
  /// **'مدير منشأة'**
  String get roleFacilityManager;

  /// No description provided for @roleVerifier.
  ///
  /// In ar, this message translates to:
  /// **'مسؤول توثيق'**
  String get roleVerifier;

  /// No description provided for @roleUnitAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مسؤول جهة'**
  String get roleUnitAdmin;

  /// No description provided for @roleSuperAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مشرف عام'**
  String get roleSuperAdmin;

  /// No description provided for @roleViewer.
  ///
  /// In ar, this message translates to:
  /// **'مراقب'**
  String get roleViewer;

  /// No description provided for @tierInternal.
  ///
  /// In ar, this message translates to:
  /// **'سعر داخلي'**
  String get tierInternal;

  /// No description provided for @tierExternal.
  ///
  /// In ar, this message translates to:
  /// **'سعر كامل'**
  String get tierExternal;

  /// No description provided for @profileRoles.
  ///
  /// In ar, this message translates to:
  /// **'الأدوار: {roles}'**
  String profileRoles(String roles);

  /// No description provided for @profileTier.
  ///
  /// In ar, this message translates to:
  /// **'الشريحة: {tier}'**
  String profileTier(String tier);

  /// No description provided for @demoUserTitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض كمستخدم تاني'**
  String get demoUserTitle;

  /// No description provided for @demoUserNote.
  ///
  /// In ar, this message translates to:
  /// **'للمراجعين فقط. التبديل بين الحسابات من غير باسورد.'**
  String get demoUserNote;

  /// No description provided for @demoGuest.
  ///
  /// In ar, this message translates to:
  /// **'ضيف (من غير حساب)'**
  String get demoGuest;

  /// No description provided for @demoSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات والوراثة'**
  String get demoSettingsTitle;

  /// No description provided for @demoSettingsPick.
  ///
  /// In ar, this message translates to:
  /// **'اختيار وحدة'**
  String get demoSettingsPick;

  /// No description provided for @demoSettingsUnit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة: {unit}'**
  String demoSettingsUnit(String unit);

  /// No description provided for @levelUnit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get levelUnit;

  /// No description provided for @levelFacility.
  ///
  /// In ar, this message translates to:
  /// **'المنشأة'**
  String get levelFacility;

  /// No description provided for @levelUniversity.
  ///
  /// In ar, this message translates to:
  /// **'الجامعة'**
  String get levelUniversity;

  /// No description provided for @levelDefault.
  ///
  /// In ar, this message translates to:
  /// **'افتراضي'**
  String get levelDefault;

  /// No description provided for @demoNoLimit.
  ///
  /// In ar, this message translates to:
  /// **'بلا حد'**
  String get demoNoLimit;

  /// No description provided for @demoSettingsLevel.
  ///
  /// In ar, this message translates to:
  /// **'من: {level}'**
  String demoSettingsLevel(String level);

  /// No description provided for @demoSwatchLabel.
  ///
  /// In ar, this message translates to:
  /// **'{name}، فاتح وغامق'**
  String demoSwatchLabel(String name);

  /// No description provided for @buttonDisabledSuffix.
  ///
  /// In ar, this message translates to:
  /// **'، غير متاح'**
  String get buttonDisabledSuffix;

  /// No description provided for @buttonBusy.
  ///
  /// In ar, this message translates to:
  /// **'جاري التنفيذ…'**
  String get buttonBusy;

  /// No description provided for @fieldShowPassword.
  ///
  /// In ar, this message translates to:
  /// **'إظهار'**
  String get fieldShowPassword;

  /// No description provided for @fieldHidePassword.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get fieldHidePassword;

  /// No description provided for @codeEntryLabel.
  ///
  /// In ar, this message translates to:
  /// **'كود التأكيد'**
  String get codeEntryLabel;

  /// No description provided for @codeEntrySentTo.
  ///
  /// In ar, this message translates to:
  /// **'بعتنا كود على'**
  String get codeEntrySentTo;

  /// No description provided for @codeEntryResend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الكود تاني'**
  String get codeEntryResend;

  /// No description provided for @codeEntryResendIn.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الكود تاني بعد {seconds} ثانية'**
  String codeEntryResendIn(int seconds);

  /// No description provided for @fieldSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث'**
  String get fieldSearchHint;

  /// No description provided for @slotAvailablePlaces.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{مكان واحد} =2{مكانين} other{{count} أماكن}}'**
  String slotAvailablePlaces(int count);

  /// No description provided for @slotSelected.
  ///
  /// In ar, this message translates to:
  /// **'مختار'**
  String get slotSelected;

  /// No description provided for @slotFewLeft.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{فاضل 1} =2{فاضل مكانين} other{فاضل {count}}}'**
  String slotFewLeft(int count);

  /// No description provided for @slotFewLeftSpoken.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{فاضل مكان واحد} =2{فاضل مكانين} other{فاضل {count} أماكن}}'**
  String slotFewLeftSpoken(int count);

  /// No description provided for @slotFull.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get slotFull;

  /// No description provided for @slotPast.
  ///
  /// In ar, this message translates to:
  /// **'فات'**
  String get slotPast;

  /// No description provided for @slotSpoken.
  ///
  /// In ar, this message translates to:
  /// **'الساعة {time}، {state}'**
  String slotSpoken(String time, String state);

  /// No description provided for @slotSpokenWithPrice.
  ///
  /// In ar, this message translates to:
  /// **'الساعة {time}، {state}، {price}'**
  String slotSpokenWithPrice(String time, String state, String price);

  /// No description provided for @dayToday.
  ///
  /// In ar, this message translates to:
  /// **'النهارده'**
  String get dayToday;

  /// No description provided for @dayHasRoom.
  ///
  /// In ar, this message translates to:
  /// **'فيه أماكن'**
  String get dayHasRoom;

  /// No description provided for @dayClosed.
  ///
  /// In ar, this message translates to:
  /// **'مقفول'**
  String get dayClosed;

  /// No description provided for @daySpoken.
  ///
  /// In ar, this message translates to:
  /// **'يوم {day}، {state}'**
  String daySpoken(String day, String state);

  /// No description provided for @statusSpoken.
  ///
  /// In ar, this message translates to:
  /// **'الحالة: {status}'**
  String statusSpoken(String status);

  /// No description provided for @statusConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكد'**
  String get statusConfirmed;

  /// No description provided for @statusPendingPayment.
  ///
  /// In ar, this message translates to:
  /// **'في انتظار الدفع'**
  String get statusPendingPayment;

  /// No description provided for @statusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'اتلغى'**
  String get statusCancelled;

  /// No description provided for @statusAttended.
  ///
  /// In ar, this message translates to:
  /// **'حضر'**
  String get statusAttended;

  /// No description provided for @statusNoShow.
  ///
  /// In ar, this message translates to:
  /// **'غاب'**
  String get statusNoShow;

  /// No description provided for @statusExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت المهلة'**
  String get statusExpired;

  /// No description provided for @statusUnderReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get statusUnderReview;

  /// No description provided for @statusVerified.
  ///
  /// In ar, this message translates to:
  /// **'موثّق'**
  String get statusVerified;

  /// No description provided for @statusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get statusRejected;

  /// No description provided for @statusOpen.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get statusOpen;

  /// No description provided for @statusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In ar, this message translates to:
  /// **'اتحل'**
  String get statusResolved;

  /// No description provided for @facilityPhotoPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'صورة المنشأة'**
  String get facilityPhotoPlaceholder;

  /// No description provided for @facilityTrainerTag.
  ///
  /// In ar, this message translates to:
  /// **'بمدرب'**
  String get facilityTrainerTag;

  /// No description provided for @facilityFreeTag.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get facilityFreeTag;

  /// No description provided for @facilityUnitCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{وحدة واحدة} =2{وحدتين} other{{count} وحدات}}'**
  String facilityUnitCount(int count);

  /// No description provided for @facilityAvailabilityPlenty.
  ///
  /// In ar, this message translates to:
  /// **'متاح النهارده'**
  String get facilityAvailabilityPlenty;

  /// No description provided for @facilityAvailabilityFew.
  ///
  /// In ar, this message translates to:
  /// **'أماكن قليلة'**
  String get facilityAvailabilityFew;

  /// No description provided for @facilityAvailabilityNone.
  ///
  /// In ar, this message translates to:
  /// **'مفيش مواعيد النهارده'**
  String get facilityAvailabilityNone;

  /// No description provided for @facilityPriceInternalLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر الطلاب والعاملين'**
  String get facilityPriceInternalLabel;

  /// No description provided for @facilityPriceExternalLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر الكامل'**
  String get facilityPriceExternalLabel;

  /// No description provided for @facilityFree.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get facilityFree;

  /// No description provided for @facilitySpoken.
  ///
  /// In ar, this message translates to:
  /// **'منشأة {name}، {unit}، {availability}، {price}'**
  String facilitySpoken(
    String name,
    String unit,
    String availability,
    String price,
  );

  /// No description provided for @ticketShowTrainer.
  ///
  /// In ar, this message translates to:
  /// **'الكود بيتعرض للمدرب عند الدخول · السطوع العالي أوضح'**
  String get ticketShowTrainer;

  /// No description provided for @ticketCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'كود الحجز'**
  String get ticketCodeLabel;

  /// No description provided for @ticketCopied.
  ///
  /// In ar, this message translates to:
  /// **'اتنسخ'**
  String get ticketCopied;

  /// No description provided for @ticketPaid.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get ticketPaid;

  /// No description provided for @ticketCancelUntil.
  ///
  /// In ar, this message translates to:
  /// **'الإلغاء متاح لحد {date}'**
  String ticketCancelUntil(String date);

  /// No description provided for @ticketCancelUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الإلغاء مش متاح'**
  String get ticketCancelUnavailable;

  /// No description provided for @ticketQrUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'QR غير متاح'**
  String get ticketQrUnavailable;

  /// No description provided for @ticketSpoken.
  ///
  /// In ar, this message translates to:
  /// **'تذكرة {facility}، {dateTime}، {status}، {code}'**
  String ticketSpoken(
    String facility,
    String dateTime,
    String status,
    String code,
  );

  /// No description provided for @navMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get navMore;

  /// No description provided for @navBadgeSpoken.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{غير مقروء واحد} other{{count} غير مقروء}}'**
  String navBadgeSpoken(int count);

  /// No description provided for @statDeltaUp.
  ///
  /// In ar, this message translates to:
  /// **'زيادة {value}'**
  String statDeltaUp(String value);

  /// No description provided for @statDeltaDown.
  ///
  /// In ar, this message translates to:
  /// **'نقص {value}'**
  String statDeltaDown(String value);

  /// No description provided for @statDeltaFlat.
  ///
  /// In ar, this message translates to:
  /// **'مفيش تغيير'**
  String get statDeltaFlat;

  /// No description provided for @statNoComparison.
  ///
  /// In ar, this message translates to:
  /// **'مفيش مقارنة'**
  String get statNoComparison;

  /// No description provided for @logoLabel.
  ///
  /// In ar, this message translates to:
  /// **'سبرنت'**
  String get logoLabel;

  /// No description provided for @galleryTitle.
  ///
  /// In ar, this message translates to:
  /// **'معرض المكونات'**
  String get galleryTitle;

  /// No description provided for @gallerySampleNote.
  ///
  /// In ar, this message translates to:
  /// **'بيانات تجريبية'**
  String get gallerySampleNote;

  /// No description provided for @galleryTextSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم النص'**
  String get galleryTextSize;

  /// No description provided for @galleryReducedMotion.
  ///
  /// In ar, this message translates to:
  /// **'تقليل الحركة'**
  String get galleryReducedMotion;

  /// No description provided for @galleryPlatformLook.
  ///
  /// In ar, this message translates to:
  /// **'شكل المنصة'**
  String get galleryPlatformLook;

  /// No description provided for @galleryPlatformApple.
  ///
  /// In ar, this message translates to:
  /// **'آبل'**
  String get galleryPlatformApple;

  /// No description provided for @galleryPlatformAndroid.
  ///
  /// In ar, this message translates to:
  /// **'أندرويد'**
  String get galleryPlatformAndroid;

  /// No description provided for @galleryPlatformDesktop.
  ///
  /// In ar, this message translates to:
  /// **'ديسكتوب'**
  String get galleryPlatformDesktop;

  /// No description provided for @galleryOpenFromDemo.
  ///
  /// In ar, this message translates to:
  /// **'معرض المكونات'**
  String get galleryOpenFromDemo;

  /// No description provided for @galleryButtonSection.
  ///
  /// In ar, this message translates to:
  /// **'الأزرار'**
  String get galleryButtonSection;

  /// No description provided for @galleryTextFieldSection.
  ///
  /// In ar, this message translates to:
  /// **'حقول الإدخال'**
  String get galleryTextFieldSection;

  /// No description provided for @gallerySlotChipSection.
  ///
  /// In ar, this message translates to:
  /// **'مواعيد الحجز'**
  String get gallerySlotChipSection;

  /// No description provided for @galleryDayStripSection.
  ///
  /// In ar, this message translates to:
  /// **'شريط الأيام'**
  String get galleryDayStripSection;

  /// No description provided for @galleryStatusBadgeSection.
  ///
  /// In ar, this message translates to:
  /// **'شارات الحالة'**
  String get galleryStatusBadgeSection;

  /// No description provided for @galleryFacilityCardSection.
  ///
  /// In ar, this message translates to:
  /// **'كروت المنشآت'**
  String get galleryFacilityCardSection;

  /// No description provided for @galleryBookingTicketSection.
  ///
  /// In ar, this message translates to:
  /// **'تذاكر الحجز'**
  String get galleryBookingTicketSection;

  /// No description provided for @galleryNavigationSection.
  ///
  /// In ar, this message translates to:
  /// **'التنقل'**
  String get galleryNavigationSection;

  /// No description provided for @galleryStatTileSection.
  ///
  /// In ar, this message translates to:
  /// **'المؤشرات'**
  String get galleryStatTileSection;

  /// No description provided for @galleryLogoSection.
  ///
  /// In ar, this message translates to:
  /// **'اللوجو'**
  String get galleryLogoSection;

  /// No description provided for @timeAm.
  ///
  /// In ar, this message translates to:
  /// **'صباحًا'**
  String get timeAm;

  /// No description provided for @timePm.
  ///
  /// In ar, this message translates to:
  /// **'مساءً'**
  String get timePm;

  /// No description provided for @slotAvailableWord.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get slotAvailableWord;

  /// No description provided for @signInTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signInTitle;

  /// No description provided for @signInIdentifierLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإيميل أو رقم الموبايل'**
  String get signInIdentifierLabel;

  /// No description provided for @signInPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'الباسورد'**
  String get signInPasswordLabel;

  /// No description provided for @signInButton.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signInButton;

  /// No description provided for @signInBadCredentials.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الدخول مش صحيحة'**
  String get signInBadCredentials;

  /// No description provided for @signInLocked.
  ///
  /// In ar, this message translates to:
  /// **'المحاولات كترت. الدخول متوقف مؤقتًا، وتقدر تحاول تاني بعد {minutes} دقيقة.'**
  String signInLocked(int minutes);

  /// No description provided for @signInSuspended.
  ///
  /// In ar, this message translates to:
  /// **'الحساب ده موقوف حاليًا. ممكن التواصل مع إدارة الجامعة.'**
  String get signInSuspended;

  /// No description provided for @signInUnexpected.
  ///
  /// In ar, this message translates to:
  /// **'حصلت مشكلة غير متوقعة. ممكن المحاولة تاني بعد شوية.'**
  String get signInUnexpected;

  /// No description provided for @signInForgot.
  ///
  /// In ar, this message translates to:
  /// **'نسيت الباسورد؟'**
  String get signInForgot;

  /// No description provided for @signInCreateAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get signInCreateAccount;

  /// No description provided for @forgotTitle.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع الباسورد'**
  String get forgotTitle;

  /// No description provided for @forgotIntro.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الإيميل أو رقم الموبايل المسجّل، وهنبعت كود على إيميل الحساب.'**
  String get forgotIntro;

  /// No description provided for @forgotSendButton.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الكود'**
  String get forgotSendButton;

  /// No description provided for @resetTitle.
  ///
  /// In ar, this message translates to:
  /// **'باسورد جديد'**
  String get resetTitle;

  /// No description provided for @resetSentNeutral.
  ///
  /// In ar, this message translates to:
  /// **'لو الحساب موجود هيوصله كود على الإيميل المسجّل.'**
  String get resetSentNeutral;

  /// No description provided for @resetNewPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'الباسورد الجديد'**
  String get resetNewPasswordLabel;

  /// No description provided for @resetPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'8 حروف على الأقل، فيها حرف ورقم'**
  String get resetPasswordHint;

  /// No description provided for @resetSaveButton.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الباسورد'**
  String get resetSaveButton;

  /// No description provided for @resetCodeWrong.
  ///
  /// In ar, this message translates to:
  /// **'الكود غلط. المحاولات المتبقية: {tries}.'**
  String resetCodeWrong(int tries);

  /// No description provided for @resetCodeExpired.
  ///
  /// In ar, this message translates to:
  /// **'الكود انتهت صلاحيته. ممكن تطلب كود جديد.'**
  String get resetCodeExpired;

  /// No description provided for @resetCodeDead.
  ///
  /// In ar, this message translates to:
  /// **'محاولات الكود خلصت. ممكن تطلب كود جديد.'**
  String get resetCodeDead;

  /// No description provided for @resetResendTooSoon.
  ///
  /// In ar, this message translates to:
  /// **'ممكن تطلب كود جديد بعد {seconds} ثانية.'**
  String resetResendTooSoon(int seconds);

  /// No description provided for @resetPasswordEmpty.
  ///
  /// In ar, this message translates to:
  /// **'الباسورد الجديد مطلوب.'**
  String get resetPasswordEmpty;

  /// No description provided for @resetPasswordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'الباسورد لازم يكون 8 حروف على الأقل.'**
  String get resetPasswordTooShort;

  /// No description provided for @resetPasswordNeedsLetter.
  ///
  /// In ar, this message translates to:
  /// **'الباسورد لازم فيه حرف واحد على الأقل.'**
  String get resetPasswordNeedsLetter;

  /// No description provided for @resetPasswordNeedsDigit.
  ///
  /// In ar, this message translates to:
  /// **'الباسورد لازم فيه رقم واحد على الأقل.'**
  String get resetPasswordNeedsDigit;

  /// No description provided for @signOutTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تسجيل الخروج'**
  String get signOutTitle;

  /// No description provided for @signOutBody.
  ///
  /// In ar, this message translates to:
  /// **'هتفضل تقدر تتصفح التطبيق كزائر، وتسجّل دخول تاني في أي وقت.'**
  String get signOutBody;

  /// No description provided for @signOutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get signOutConfirm;

  /// No description provided for @signOutKeep.
  ///
  /// In ar, this message translates to:
  /// **'البقاء في الحساب'**
  String get signOutKeep;

  /// No description provided for @accountCardSpoken.
  ///
  /// In ar, this message translates to:
  /// **'حسابك: {name}، {tier}'**
  String accountCardSpoken(String name, String tier);

  /// No description provided for @signUpTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get signUpTitle;

  /// No description provided for @signUpButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get signUpButton;

  /// No description provided for @signUpNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالكامل'**
  String get signUpNameLabel;

  /// No description provided for @signUpNameHelper.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول واسم العيلة على الأقل'**
  String get signUpNameHelper;

  /// No description provided for @signUpPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get signUpPhoneLabel;

  /// No description provided for @signUpPhoneHelper.
  ///
  /// In ar, this message translates to:
  /// **'رقم مصري، مثال 01012345678'**
  String get signUpPhoneHelper;

  /// No description provided for @signUpEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإيميل'**
  String get signUpEmailLabel;

  /// No description provided for @signUpEmailHelper.
  ///
  /// In ar, this message translates to:
  /// **'هنبعت عليه كود تأكيد الحساب'**
  String get signUpEmailHelper;

  /// No description provided for @signUpPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'الباسورد'**
  String get signUpPasswordLabel;

  /// No description provided for @signUpPasswordHelper.
  ///
  /// In ar, this message translates to:
  /// **'8 حروف على الأقل، فيها حرف ورقم'**
  String get signUpPasswordHelper;

  /// No description provided for @signUpAlreadyHave.
  ///
  /// In ar, this message translates to:
  /// **'عندك حساب؟'**
  String get signUpAlreadyHave;

  /// No description provided for @validationNameEmpty.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب.'**
  String get validationNameEmpty;

  /// No description provided for @validationNameTooShort.
  ///
  /// In ar, this message translates to:
  /// **'الاسم قصير أوي.'**
  String get validationNameTooShort;

  /// No description provided for @validationNameTooLong.
  ///
  /// In ar, this message translates to:
  /// **'الاسم طويل، الحد الأقصى 60 حرف.'**
  String get validationNameTooLong;

  /// No description provided for @validationNameNeedsTwoWords.
  ///
  /// In ar, this message translates to:
  /// **'الاسم لازم يكون كلمتين على الأقل، الاسم الأول واسم العيلة.'**
  String get validationNameNeedsTwoWords;

  /// No description provided for @validationNameInvalidCharacters.
  ///
  /// In ar, this message translates to:
  /// **'الاسم يقبل حروف ومسافات بس.'**
  String get validationNameInvalidCharacters;

  /// No description provided for @validationPhoneEmpty.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل مطلوب.'**
  String get validationPhoneEmpty;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل لازم يكون 11 رقم ويبدأ بـ 010 أو 011 أو 012 أو 015.'**
  String get validationPhoneInvalid;

  /// No description provided for @validationEmailEmpty.
  ///
  /// In ar, this message translates to:
  /// **'الإيميل مطلوب.'**
  String get validationEmailEmpty;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الإيميل مش مكتوب صح، مثال name@example.com.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordEmpty.
  ///
  /// In ar, this message translates to:
  /// **'الباسورد مطلوب.'**
  String get validationPasswordEmpty;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'الباسورد لازم يكون 8 حروف على الأقل.'**
  String get validationPasswordTooShort;

  /// No description provided for @validationPasswordNeedsLetter.
  ///
  /// In ar, this message translates to:
  /// **'الباسورد لازم فيه حرف واحد على الأقل.'**
  String get validationPasswordNeedsLetter;

  /// No description provided for @validationPasswordNeedsDigit.
  ///
  /// In ar, this message translates to:
  /// **'الباسورد لازم فيه رقم واحد على الأقل.'**
  String get validationPasswordNeedsDigit;

  /// No description provided for @signUpEmailTaken.
  ///
  /// In ar, this message translates to:
  /// **'الإيميل ده مسجل قبل كده.'**
  String get signUpEmailTaken;

  /// No description provided for @signUpPhoneTaken.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل ده مسجل قبل كده.'**
  String get signUpPhoneTaken;

  /// No description provided for @signUpTakenActions.
  ///
  /// In ar, this message translates to:
  /// **'ممكن تسجيل الدخول أو استرجاع الباسورد.'**
  String get signUpTakenActions;

  /// No description provided for @confirmEmailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإيميل'**
  String get confirmEmailTitle;

  /// No description provided for @confirmEmailButton.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirmEmailButton;

  /// No description provided for @confirmCodeEmpty.
  ///
  /// In ar, this message translates to:
  /// **'الكود مكوّن من 6 أرقام.'**
  String get confirmCodeEmpty;

  /// No description provided for @confirmCodeWrong.
  ///
  /// In ar, this message translates to:
  /// **'الكود مش صحيح. {count, plural, =1{فاضلك محاولة واحدة} =2{فاضلك محاولتين} other{فاضلك {count} محاولات}}.'**
  String confirmCodeWrong(int count);

  /// No description provided for @confirmCodeExpired.
  ///
  /// In ar, this message translates to:
  /// **'الكود انتهت صلاحيته. ممكن إرسال كود جديد.'**
  String get confirmCodeExpired;

  /// No description provided for @confirmCodeDead.
  ///
  /// In ar, this message translates to:
  /// **'المحاولات خلصت على الكود ده. ممكن إرسال كود جديد.'**
  String get confirmCodeDead;

  /// No description provided for @confirmNoPending.
  ///
  /// In ar, this message translates to:
  /// **'مفيش تأكيد معلّق للإيميل ده. ممكن إنشاء حساب من جديد.'**
  String get confirmNoPending;

  /// No description provided for @confirmResendTooSoon.
  ///
  /// In ar, this message translates to:
  /// **'ممكن إرسال كود جديد بعد {seconds} ثانية.'**
  String confirmResendTooSoon(int seconds);

  /// No description provided for @confirmResent.
  ///
  /// In ar, this message translates to:
  /// **'بعتنا كود جديد.'**
  String get confirmResent;

  /// No description provided for @emailConfirmSubject.
  ///
  /// In ar, this message translates to:
  /// **'كود تأكيد حسابك في سبرنت'**
  String get emailConfirmSubject;

  /// No description provided for @emailConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'كود التأكيد: {code}\nالكود صالح لمدة {minutes} دقيقة. لو مش إنت اللي عملت الحساب، ممكن تتجاهل الرسالة دي.'**
  String emailConfirmBody(String code, int minutes);

  /// No description provided for @emailResetSubject.
  ///
  /// In ar, this message translates to:
  /// **'كود استرجاع الباسورد في سبرنت'**
  String get emailResetSubject;

  /// No description provided for @emailResetBody.
  ///
  /// In ar, this message translates to:
  /// **'كود الاسترجاع: {code}\nالكود صالح لمدة {minutes} دقيقة. لو مش إنت اللي طلبت الاسترجاع، ممكن تتجاهل الرسالة دي.'**
  String emailResetBody(String code, int minutes);

  /// No description provided for @demoNoticeTitle.
  ///
  /// In ar, this message translates to:
  /// **'للعرض بس'**
  String get demoNoticeTitle;

  /// No description provided for @demoNoticeCode.
  ///
  /// In ar, this message translates to:
  /// **'كود التجربة: {code}'**
  String demoNoticeCode(String code);

  /// No description provided for @demoNoticeDismiss.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get demoNoticeDismiss;

  /// No description provided for @mailboxTitle.
  ///
  /// In ar, this message translates to:
  /// **'صندوق البريد التجريبي'**
  String get mailboxTitle;

  /// No description provided for @demoResetButton.
  ///
  /// In ar, this message translates to:
  /// **'إرجاع الداتا التجريبية'**
  String get demoResetButton;

  /// No description provided for @demoResetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إرجاع الداتا التجريبية؟'**
  String get demoResetTitle;

  /// No description provided for @demoResetBody.
  ///
  /// In ar, this message translates to:
  /// **'كل الحجوزات والحسابات والطلبات اللي اتعملت هتتمسح، والداتا هترجع زي أول مرة. المظهر واللغة هيفضلوا زي ما هما.'**
  String get demoResetBody;

  /// No description provided for @demoResetConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إرجاع الداتا'**
  String get demoResetConfirm;

  /// No description provided for @demoResetKeep.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get demoResetKeep;

  /// No description provided for @mailboxNote.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل اللي التطبيق كان هيبعتها بالإيميل بتظهر هنا. للمراجعين فقط.'**
  String get mailboxNote;

  /// No description provided for @mailboxEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'مفيش رسائل لسه'**
  String get mailboxEmptyTitle;

  /// No description provided for @mailboxEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أي كود تأكيد أو استرجاع هيتبعت هيظهر هنا.'**
  String get mailboxEmptyBody;

  /// No description provided for @mailboxTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get mailboxTo;

  /// No description provided for @mailboxCopyCode.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الكود'**
  String get mailboxCopyCode;

  /// No description provided for @mailboxCopied.
  ///
  /// In ar, this message translates to:
  /// **'الكود اتنسخ.'**
  String get mailboxCopied;

  /// No description provided for @catalogueTypeSwimming.
  ///
  /// In ar, this message translates to:
  /// **'سباحة'**
  String get catalogueTypeSwimming;

  /// No description provided for @catalogueTypeFootball.
  ///
  /// In ar, this message translates to:
  /// **'كرة قدم'**
  String get catalogueTypeFootball;

  /// No description provided for @catalogueTypeGym.
  ///
  /// In ar, this message translates to:
  /// **'لياقة بدنية'**
  String get catalogueTypeGym;

  /// No description provided for @catalogueTypeTennis.
  ///
  /// In ar, this message translates to:
  /// **'تنس'**
  String get catalogueTypeTennis;

  /// No description provided for @catalogueTypeHall.
  ///
  /// In ar, this message translates to:
  /// **'صالة'**
  String get catalogueTypeHall;

  /// No description provided for @catalogueTypeTraining.
  ///
  /// In ar, this message translates to:
  /// **'تدريب'**
  String get catalogueTypeTraining;

  /// No description provided for @catalogueErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'حصلت مشكلة'**
  String get catalogueErrorTitle;

  /// No description provided for @catalogueErrorBody.
  ///
  /// In ar, this message translates to:
  /// **'المحتوى مش ظاهر دلوقتي. المحاولة تاني ممكن تحل المشكلة.'**
  String get catalogueErrorBody;

  /// No description provided for @catalogueRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get catalogueRetry;

  /// No description provided for @catalogueFacilityNotFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'المنشأة مش موجودة'**
  String get catalogueFacilityNotFoundTitle;

  /// No description provided for @catalogueFacilityNotFoundBody.
  ///
  /// In ar, this message translates to:
  /// **'الرابط ممكن يكون غلط أو المنشأة مش منشورة.'**
  String get catalogueFacilityNotFoundBody;

  /// No description provided for @catalogueBackToFacilities.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع للمنشآت'**
  String get catalogueBackToFacilities;

  /// No description provided for @cataloguePanePrompt.
  ///
  /// In ar, this message translates to:
  /// **'اختار منشأة تشوف تفاصيلها'**
  String get cataloguePanePrompt;

  /// No description provided for @cataloguePriceRange.
  ///
  /// In ar, this message translates to:
  /// **'{min}–{max} ج.م'**
  String cataloguePriceRange(String min, String max);

  /// No description provided for @catalogueTagFree.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get catalogueTagFree;

  /// No description provided for @catalogueTagTrainer.
  ///
  /// In ar, this message translates to:
  /// **'بمدرب'**
  String get catalogueTagTrainer;

  /// No description provided for @catalogueHomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتشف المنشآت'**
  String get catalogueHomeTitle;

  /// No description provided for @catalogueHomeTypesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنواع المنشآت'**
  String get catalogueHomeTypesTitle;

  /// No description provided for @catalogueHomeFeaturedTitle.
  ///
  /// In ar, this message translates to:
  /// **'منشآت مميزة'**
  String get catalogueHomeFeaturedTitle;

  /// No description provided for @catalogueHomeSeeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض كل المنشآت'**
  String get catalogueHomeSeeAll;

  /// No description provided for @catalogueHomeGuestHint.
  ///
  /// In ar, this message translates to:
  /// **'تقدر تشوف كل المنشآت من غير تسجيل.'**
  String get catalogueHomeGuestHint;

  /// No description provided for @catalogueFiltersTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفلاتر'**
  String get catalogueFiltersTitle;

  /// No description provided for @catalogueFilterAllTypes.
  ///
  /// In ar, this message translates to:
  /// **'كل الأنواع'**
  String get catalogueFilterAllTypes;

  /// No description provided for @catalogueFilterAllUnits.
  ///
  /// In ar, this message translates to:
  /// **'كل الجهات'**
  String get catalogueFilterAllUnits;

  /// No description provided for @catalogueFilterAny.
  ///
  /// In ar, this message translates to:
  /// **'مجاني أو مدفوع'**
  String get catalogueFilterAny;

  /// No description provided for @catalogueFilterFree.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get catalogueFilterFree;

  /// No description provided for @catalogueFilterPaid.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع'**
  String get catalogueFilterPaid;

  /// No description provided for @catalogueFilterClearAll.
  ///
  /// In ar, this message translates to:
  /// **'مسح الكل'**
  String get catalogueFilterClearAll;

  /// No description provided for @catalogueFilterRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة فلتر {name}'**
  String catalogueFilterRemove(String name);

  /// No description provided for @catalogueResultCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{مفيش منشآت} =1{منشأة واحدة} =2{منشأتين} few{{count} منشآت} other{{count} منشأة}}'**
  String catalogueResultCount(int count);

  /// No description provided for @catalogueEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'مفيش منشآت مطابقة'**
  String get catalogueEmptyTitle;

  /// No description provided for @catalogueEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'مفيش حاجة بتطابق الفلاتر دي: {filters}'**
  String catalogueEmptyBody(String filters);

  /// No description provided for @catalogueEmptyClear.
  ///
  /// In ar, this message translates to:
  /// **'مسح الفلاتر'**
  String get catalogueEmptyClear;

  /// No description provided for @catalogueSectionHours.
  ///
  /// In ar, this message translates to:
  /// **'مواعيد العمل'**
  String get catalogueSectionHours;

  /// No description provided for @catalogueSectionPrices.
  ///
  /// In ar, this message translates to:
  /// **'الأسعار'**
  String get catalogueSectionPrices;

  /// No description provided for @catalogueSectionTrainers.
  ///
  /// In ar, this message translates to:
  /// **'المدربين'**
  String get catalogueSectionTrainers;

  /// No description provided for @catalogueSectionUnits.
  ///
  /// In ar, this message translates to:
  /// **'الوحدات'**
  String get catalogueSectionUnits;

  /// No description provided for @catalogueSectionAvailability.
  ///
  /// In ar, this message translates to:
  /// **'المتاح النهارده'**
  String get catalogueSectionAvailability;

  /// No description provided for @catalogueSectionFacts.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الحجز'**
  String get catalogueSectionFacts;

  /// No description provided for @cataloguePhotoPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'صورة المنشأة'**
  String get cataloguePhotoPlaceholder;

  /// No description provided for @cataloguePhotoPosition.
  ///
  /// In ar, this message translates to:
  /// **'صورة {index} من {count}'**
  String cataloguePhotoPosition(int index, int count);

  /// No description provided for @catalogueDayName.
  ///
  /// In ar, this message translates to:
  /// **'{day, select, 1{الاثنين} 2{الثلاثاء} 3{الأربعاء} 4{الخميس} 5{الجمعة} 6{السبت} other{الأحد}}'**
  String catalogueDayName(String day);

  /// No description provided for @catalogueHoursClosedDay.
  ///
  /// In ar, this message translates to:
  /// **'مقفول'**
  String get catalogueHoursClosedDay;

  /// No description provided for @catalogueHoursToday.
  ///
  /// In ar, this message translates to:
  /// **'النهارده'**
  String get catalogueHoursToday;

  /// No description provided for @catalogueClosedNow.
  ///
  /// In ar, this message translates to:
  /// **'مقفول دلوقتي'**
  String get catalogueClosedNow;

  /// No description provided for @catalogueClosedToday.
  ///
  /// In ar, this message translates to:
  /// **'مقفول النهارده'**
  String get catalogueClosedToday;

  /// No description provided for @catalogueListSeparator.
  ///
  /// In ar, this message translates to:
  /// **'، '**
  String get catalogueListSeparator;

  /// No description provided for @catalogueClosureRange.
  ///
  /// In ar, this message translates to:
  /// **'من {from} إلى {to}'**
  String catalogueClosureRange(String from, String to);

  /// No description provided for @cataloguePriceInternalLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر الطلبة والعاملين'**
  String get cataloguePriceInternalLabel;

  /// No description provided for @cataloguePriceExternalLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر العادي'**
  String get cataloguePriceExternalLabel;

  /// No description provided for @cataloguePriceYours.
  ///
  /// In ar, this message translates to:
  /// **'سعرك'**
  String get cataloguePriceYours;

  /// No description provided for @cataloguePriceBasisShared.
  ///
  /// In ar, this message translates to:
  /// **'للمكان الواحد'**
  String get cataloguePriceBasisShared;

  /// No description provided for @cataloguePriceBasisExclusive.
  ///
  /// In ar, this message translates to:
  /// **'للحجز كله'**
  String get cataloguePriceBasisExclusive;

  /// No description provided for @cataloguePriceAllUnits.
  ///
  /// In ar, this message translates to:
  /// **'كل الوحدات'**
  String get cataloguePriceAllUnits;

  /// No description provided for @cataloguePriceNotSet.
  ///
  /// In ar, this message translates to:
  /// **'السعر لسه مش محدد'**
  String get cataloguePriceNotSet;

  /// No description provided for @catalogueFreeNoPayment.
  ///
  /// In ar, this message translates to:
  /// **'المنشأة دي مجانية ومفيش دفع.'**
  String get catalogueFreeNoPayment;

  /// No description provided for @catalogueTrainerCapacity.
  ///
  /// In ar, this message translates to:
  /// **'بياخد {count} في الحصة'**
  String catalogueTrainerCapacity(int count);

  /// No description provided for @catalogueTrainersNone.
  ///
  /// In ar, this message translates to:
  /// **'مفيش مدربين دلوقتي'**
  String get catalogueTrainersNone;

  /// No description provided for @catalogueTrainerFirst.
  ///
  /// In ar, this message translates to:
  /// **'لازم تختار المدرب الأول'**
  String get catalogueTrainerFirst;

  /// No description provided for @catalogueTrainerUnnamed.
  ///
  /// In ar, this message translates to:
  /// **'مدرب'**
  String get catalogueTrainerUnnamed;

  /// No description provided for @catalogueUnitOwnHours.
  ///
  /// In ar, this message translates to:
  /// **'مواعيد خاصة: {hours}'**
  String catalogueUnitOwnHours(String hours);

  /// No description provided for @catalogueFactWindow.
  ///
  /// In ar, this message translates to:
  /// **'الحجز لحد {days} أيام قدام'**
  String catalogueFactWindow(int days);

  /// No description provided for @catalogueFactMaxRange.
  ///
  /// In ar, this message translates to:
  /// **'أقصى مدة للحجز {hours} ساعات'**
  String catalogueFactMaxRange(int hours);

  /// No description provided for @catalogueFactSession.
  ///
  /// In ar, this message translates to:
  /// **'مدة الحصة {minutes} دقيقة'**
  String catalogueFactSession(int minutes);

  /// No description provided for @verifTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب التوثيق'**
  String get verifTitle;

  /// No description provided for @verifRenewTitle.
  ///
  /// In ar, this message translates to:
  /// **'تجديد التوثيق'**
  String get verifRenewTitle;

  /// No description provided for @verifIntro.
  ///
  /// In ar, this message translates to:
  /// **'بعد التوثيق بتحجز بالسعر الداخلي. بنراجع البيانات وصورة البطاقة.'**
  String get verifIntro;

  /// No description provided for @verifTypeTitle.
  ///
  /// In ar, this message translates to:
  /// **'نوع الحساب'**
  String get verifTypeTitle;

  /// No description provided for @verifTypeStudent.
  ///
  /// In ar, this message translates to:
  /// **'طالب'**
  String get verifTypeStudent;

  /// No description provided for @verifTypeStaff.
  ///
  /// In ar, this message translates to:
  /// **'موظف'**
  String get verifTypeStaff;

  /// No description provided for @verifTypeFaculty.
  ///
  /// In ar, this message translates to:
  /// **'عضو هيئة تدريس'**
  String get verifTypeFaculty;

  /// No description provided for @verifNationalIdLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرقم القومي'**
  String get verifNationalIdLabel;

  /// No description provided for @verifNationalIdHelper.
  ///
  /// In ar, this message translates to:
  /// **'14 رقم زي ما هو مكتوب في البطاقة.'**
  String get verifNationalIdHelper;

  /// No description provided for @verifCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكود الجامعي أو الوظيفي'**
  String get verifCodeLabel;

  /// No description provided for @verifCodeHelper.
  ///
  /// In ar, this message translates to:
  /// **'أرقام أو حروف إنجليزي، لحد 20 خانة.'**
  String get verifCodeHelper;

  /// No description provided for @verifUnitTitle.
  ///
  /// In ar, this message translates to:
  /// **'الكلية أو الإدارة'**
  String get verifUnitTitle;

  /// No description provided for @verifPhotoLabel.
  ///
  /// In ar, this message translates to:
  /// **'صورة البطاقة'**
  String get verifPhotoLabel;

  /// No description provided for @verifPhotoHelper.
  ///
  /// In ar, this message translates to:
  /// **'صورة واضحة للبطاقة كلها. بنصغّرها تلقائي قبل الإرسال.'**
  String get verifPhotoHelper;

  /// No description provided for @verifPhotoChoose.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الصورة'**
  String get verifPhotoChoose;

  /// No description provided for @verifPhotoReplace.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get verifPhotoReplace;

  /// No description provided for @verifPhotoSourceTitle.
  ///
  /// In ar, this message translates to:
  /// **'صورة البطاقة'**
  String get verifPhotoSourceTitle;

  /// No description provided for @verifPhotoCamera.
  ///
  /// In ar, this message translates to:
  /// **'تصوير بالكاميرا'**
  String get verifPhotoCamera;

  /// No description provided for @verifPhotoGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختيار من الصور أو الملفات'**
  String get verifPhotoGallery;

  /// No description provided for @verifPhotoCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get verifPhotoCancel;

  /// No description provided for @verifPhotoProcessing.
  ///
  /// In ar, this message translates to:
  /// **'جاري تجهيز الصورة'**
  String get verifPhotoProcessing;

  /// No description provided for @verifPhotoPreviewSpoken.
  ///
  /// In ar, this message translates to:
  /// **'معاينة صورة البطاقة'**
  String get verifPhotoPreviewSpoken;

  /// No description provided for @verifPhotoNotImage.
  ///
  /// In ar, this message translates to:
  /// **'الملف ده مش صورة. اختار صورة تانية.'**
  String get verifPhotoNotImage;

  /// No description provided for @verifErrNationalIdEmpty.
  ///
  /// In ar, this message translates to:
  /// **'الرقم القومي مطلوب.'**
  String get verifErrNationalIdEmpty;

  /// No description provided for @verifErrNationalIdLength.
  ///
  /// In ar, this message translates to:
  /// **'الرقم القومي لازم يكون 14 رقم.'**
  String get verifErrNationalIdLength;

  /// No description provided for @verifErrNationalIdCentury.
  ///
  /// In ar, this message translates to:
  /// **'أول رقم في الرقم القومي لازم يكون 2 أو 3.'**
  String get verifErrNationalIdCentury;

  /// No description provided for @verifErrNationalIdBirthDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الميلاد جوه الرقم القومي مش صحيح.'**
  String get verifErrNationalIdBirthDate;

  /// No description provided for @verifErrNationalIdFuture.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الميلاد جوه الرقم القومي لسه ماجاش.'**
  String get verifErrNationalIdFuture;

  /// No description provided for @verifErrNationalIdGovernorate.
  ///
  /// In ar, this message translates to:
  /// **'كود المحافظة جوه الرقم القومي مش صحيح.'**
  String get verifErrNationalIdGovernorate;

  /// No description provided for @verifErrCodeEmpty.
  ///
  /// In ar, this message translates to:
  /// **'الكود مطلوب.'**
  String get verifErrCodeEmpty;

  /// No description provided for @verifErrCodeInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الكود لازم يكون من 1 لـ 20 رقم أو حرف إنجليزي.'**
  String get verifErrCodeInvalid;

  /// No description provided for @verifErrUnitEmpty.
  ///
  /// In ar, this message translates to:
  /// **'اختار الكلية أو الإدارة.'**
  String get verifErrUnitEmpty;

  /// No description provided for @verifErrPhotoEmpty.
  ///
  /// In ar, this message translates to:
  /// **'صورة البطاقة مطلوبة.'**
  String get verifErrPhotoEmpty;

  /// No description provided for @verifSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get verifSubmit;

  /// No description provided for @verifSubmitting.
  ///
  /// In ar, this message translates to:
  /// **'جاري إرسال الطلب'**
  String get verifSubmitting;

  /// No description provided for @verifResultApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم التوثيق. سعرك داخلي لحد {date}.'**
  String verifResultApproved(String date);

  /// No description provided for @verifResultPending.
  ///
  /// In ar, this message translates to:
  /// **'الطلب اتبعت وبيتراجع. لحد ما يخلص هتفضل بالسعر الكامل.'**
  String get verifResultPending;

  /// No description provided for @verifResultRejected.
  ///
  /// In ar, this message translates to:
  /// **'الطلب اترفض. السبب: {reason}'**
  String verifResultRejected(String reason);

  /// No description provided for @verifResultDone.
  ///
  /// In ar, this message translates to:
  /// **'تمام'**
  String get verifResultDone;

  /// No description provided for @verifReasonDuplicate.
  ///
  /// In ar, this message translates to:
  /// **'الرقم القومي ده عليه طلب توثيق من حساب تاني.'**
  String get verifReasonDuplicate;

  /// No description provided for @verifStorageFull.
  ///
  /// In ar, this message translates to:
  /// **'الصورة متحفظتش، ممكن تبعتها تاني'**
  String get verifStorageFull;

  /// No description provided for @verifAlreadyPending.
  ///
  /// In ar, this message translates to:
  /// **'عندك طلب قيد المراجعة بالفعل.'**
  String get verifAlreadyPending;

  /// No description provided for @verifCardTitle.
  ///
  /// In ar, this message translates to:
  /// **'التوثيق'**
  String get verifCardTitle;

  /// No description provided for @verifCardSpoken.
  ///
  /// In ar, this message translates to:
  /// **'التوثيق: {status}'**
  String verifCardSpoken(String status);

  /// No description provided for @verifStatusNone.
  ///
  /// In ar, this message translates to:
  /// **'غير موثّق'**
  String get verifStatusNone;

  /// No description provided for @verifStatusExpired.
  ///
  /// In ar, this message translates to:
  /// **'التوثيق انتهى'**
  String get verifStatusExpired;

  /// No description provided for @verifNoneBody.
  ///
  /// In ar, this message translates to:
  /// **'حسابك بالسعر الكامل. بعد التوثيق بتحجز بالسعر الداخلي.'**
  String get verifNoneBody;

  /// No description provided for @verifPendingBody.
  ///
  /// In ar, this message translates to:
  /// **'طلبك قيد المراجعة. لحد ما يخلص هتفضل بالسعر الكامل.'**
  String get verifPendingBody;

  /// No description provided for @verifApprovedUntil.
  ///
  /// In ar, this message translates to:
  /// **'متوثق لحد {date}'**
  String verifApprovedUntil(String date);

  /// No description provided for @verifRejectedBody.
  ///
  /// In ar, this message translates to:
  /// **'الطلب اترفض.'**
  String get verifRejectedBody;

  /// No description provided for @verifReasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'السبب: {reason}'**
  String verifReasonLabel(String reason);

  /// No description provided for @verifExpiredBody.
  ///
  /// In ar, this message translates to:
  /// **'التوثيق انتهى يوم {date}. السعر دلوقتي كامل لحد التجديد.'**
  String verifExpiredBody(String date);

  /// No description provided for @verifActionRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب التوثيق'**
  String get verifActionRequest;

  /// No description provided for @verifActionRenew.
  ///
  /// In ar, this message translates to:
  /// **'تجديد التوثيق'**
  String get verifActionRenew;

  /// No description provided for @verifActionAgain.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب جديد'**
  String get verifActionAgain;

  /// No description provided for @verifActionWait.
  ///
  /// In ar, this message translates to:
  /// **'في انتظار المراجعة'**
  String get verifActionWait;

  /// No description provided for @verifNationalIdMasked.
  ///
  /// In ar, this message translates to:
  /// **'الرقم القومي: {id}'**
  String verifNationalIdMasked(String id);

  /// No description provided for @verifRevSection.
  ///
  /// In ar, this message translates to:
  /// **'التوثيق'**
  String get verifRevSection;

  /// No description provided for @verifRevQueueTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات التوثيق'**
  String get verifRevQueueTitle;

  /// No description provided for @verifRevQueueEmpty.
  ///
  /// In ar, this message translates to:
  /// **'مفيش طلبات مستنية المراجعة.'**
  String get verifRevQueueEmpty;

  /// No description provided for @verifRevWaitMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{مستني من أقل من دقيقة} =1{مستني من دقيقة} =2{مستني من دقيقتين} other{مستني من {count} دقايق}}'**
  String verifRevWaitMinutes(int count);

  /// No description provided for @verifRevWaitHours.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{مستني من ساعة} =2{مستني من ساعتين} other{مستني من {count} ساعات}}'**
  String verifRevWaitHours(int count);

  /// No description provided for @verifRevWaitDays.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{مستني من يوم} =2{مستني من يومين} other{مستني من {count} أيام}}'**
  String verifRevWaitDays(int count);

  /// No description provided for @verifRevPricing.
  ///
  /// In ar, this message translates to:
  /// **'بعد القبول هيتحاسب بالسعر الداخلي'**
  String get verifRevPricing;

  /// No description provided for @verifRevRowSpoken.
  ///
  /// In ar, this message translates to:
  /// **'طلب {name}، {type}، {unit}، {wait}'**
  String verifRevRowSpoken(String name, String type, String unit, String wait);

  /// No description provided for @verifRevDetailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get verifRevDetailTitle;

  /// No description provided for @verifRevPickPrompt.
  ///
  /// In ar, this message translates to:
  /// **'اختيار طلب من القائمة بيعرض تفاصيله هنا.'**
  String get verifRevPickPrompt;

  /// No description provided for @verifRevName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get verifRevName;

  /// No description provided for @verifRevType.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get verifRevType;

  /// No description provided for @verifRevCode.
  ///
  /// In ar, this message translates to:
  /// **'الكود'**
  String get verifRevCode;

  /// No description provided for @verifRevUnit.
  ///
  /// In ar, this message translates to:
  /// **'الكلية أو الإدارة'**
  String get verifRevUnit;

  /// No description provided for @verifRevSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'وقت الإرسال'**
  String get verifRevSubmitted;

  /// No description provided for @verifRevNationalId.
  ///
  /// In ar, this message translates to:
  /// **'الرقم القومي'**
  String get verifRevNationalId;

  /// No description provided for @verifRevPhoto.
  ///
  /// In ar, this message translates to:
  /// **'صورة البطاقة'**
  String get verifRevPhoto;

  /// No description provided for @verifRevPhotoSpoken.
  ///
  /// In ar, this message translates to:
  /// **'صورة بطاقة {name}'**
  String verifRevPhotoSpoken(String name);

  /// No description provided for @verifRevPhotoMissing.
  ///
  /// In ar, this message translates to:
  /// **'الصورة مش موجودة.'**
  String get verifRevPhotoMissing;

  /// No description provided for @verifRevApprove.
  ///
  /// In ar, this message translates to:
  /// **'قبول الطلب'**
  String get verifRevApprove;

  /// No description provided for @verifRevReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب'**
  String get verifRevReject;

  /// No description provided for @verifRevRejectTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب'**
  String get verifRevRejectTitle;

  /// No description provided for @verifRevReasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض'**
  String get verifRevReasonLabel;

  /// No description provided for @verifRevReasonHelper.
  ///
  /// In ar, this message translates to:
  /// **'10 حروف على الأقل، والسبب هيظهر لصاحب الطلب.'**
  String get verifRevReasonHelper;

  /// No description provided for @verifRevReasonConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرفض'**
  String get verifRevReasonConfirm;

  /// No description provided for @verifRevReasonCancel.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get verifRevReasonCancel;

  /// No description provided for @verifRevAlreadyDecided.
  ///
  /// In ar, this message translates to:
  /// **'الطلب ده اتقرر فيه قبل كده.'**
  String get verifRevAlreadyDecided;

  /// No description provided for @verifRevOwnRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلبك أنت مينفعش تراجعه بنفسك.'**
  String get verifRevOwnRequest;

  /// No description provided for @verifRevDecidedApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الطلب، وصاحبه بقى بالسعر الداخلي.'**
  String get verifRevDecidedApproved;

  /// No description provided for @verifRevDecidedRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الطلب، والسبب ظاهر لصاحبه.'**
  String get verifRevDecidedRejected;

  /// No description provided for @verifRevUpload.
  ///
  /// In ar, this message translates to:
  /// **'رفع الشيت'**
  String get verifRevUpload;

  /// No description provided for @sheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفع شيت التوثيق'**
  String get sheetTitle;

  /// No description provided for @sheetHelp.
  ///
  /// In ar, this message translates to:
  /// **'ملف CSV بترميز UTF-8 فيه 3 أعمدة بالترتيب: الرقم القومي، الكود، النوع (طالب أو موظف أو عضو هيئة تدريس). الصف الأول ممكن يبقى عناوين.'**
  String get sheetHelp;

  /// No description provided for @sheetPick.
  ///
  /// In ar, this message translates to:
  /// **'اختيار ملف CSV'**
  String get sheetPick;

  /// No description provided for @sheetSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الرفع'**
  String get sheetSummaryTitle;

  /// No description provided for @sheetSummaryRead.
  ///
  /// In ar, this message translates to:
  /// **'صفوف اتقرت'**
  String get sheetSummaryRead;

  /// No description provided for @sheetSummaryAdded.
  ///
  /// In ar, this message translates to:
  /// **'صفوف اتضافت'**
  String get sheetSummaryAdded;

  /// No description provided for @sheetSummaryDuplicates.
  ///
  /// In ar, this message translates to:
  /// **'صفوف مكررة اتجاهلت'**
  String get sheetSummaryDuplicates;

  /// No description provided for @sheetSummaryInvalid.
  ///
  /// In ar, this message translates to:
  /// **'صفوف غلط اتجاهلت'**
  String get sheetSummaryInvalid;

  /// No description provided for @sheetSummaryApproved.
  ///
  /// In ar, this message translates to:
  /// **'طلبات اتقبلت تلقائي'**
  String get sheetSummaryApproved;

  /// No description provided for @sheetProblemsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصفوف اللي اتجاهلت'**
  String get sheetProblemsTitle;

  /// No description provided for @sheetProblemRow.
  ///
  /// In ar, this message translates to:
  /// **'صف {row}: {reason}'**
  String sheetProblemRow(String row, String reason);

  /// No description provided for @sheetReasonColumns.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأعمدة غلط'**
  String get sheetReasonColumns;

  /// No description provided for @sheetReasonCode.
  ///
  /// In ar, this message translates to:
  /// **'الكود مش صالح'**
  String get sheetReasonCode;

  /// No description provided for @sheetReasonType.
  ///
  /// In ar, this message translates to:
  /// **'النوع مش معروف'**
  String get sheetReasonType;

  /// No description provided for @sheetReasonOther.
  ///
  /// In ar, this message translates to:
  /// **'الصف مش صالح'**
  String get sheetReasonOther;

  /// No description provided for @sheetErrBadColumns.
  ///
  /// In ar, this message translates to:
  /// **'الأعمدة مش زي المتوقع، ومفيش حاجة اتضافت.'**
  String get sheetErrBadColumns;

  /// No description provided for @sheetErrNoRows.
  ///
  /// In ar, this message translates to:
  /// **'مفيش صفوف صالحة في الملف، ومفيش حاجة اتضافت.'**
  String get sheetErrNoRows;

  /// No description provided for @sheetErrRead.
  ///
  /// In ar, this message translates to:
  /// **'الملف ماتقراش. ممكن تجرب ملف CSV تاني.'**
  String get sheetErrRead;

  /// No description provided for @sheetBatchesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرفعات اللي فاتت'**
  String get sheetBatchesTitle;

  /// No description provided for @sheetBatchesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لسه مفيش رفعات.'**
  String get sheetBatchesEmpty;

  /// No description provided for @sheetBatchLine.
  ///
  /// In ar, this message translates to:
  /// **'اتضاف {added}، اتقبل {approved}، اتجاهل {skipped}'**
  String sheetBatchLine(int added, int approved, int skipped);

  /// No description provided for @verifNoticeApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول طلب التوثيق. متوثق لحد {date}.'**
  String verifNoticeApproved(String date);

  /// No description provided for @verifNoticeRejected.
  ///
  /// In ar, this message translates to:
  /// **'طلب التوثيق اترفض. السبب: {reason}'**
  String verifNoticeRejected(String reason);

  /// No description provided for @catalogueAvailabilityToday.
  ///
  /// In ar, this message translates to:
  /// **'المتاح النهارده'**
  String get catalogueAvailabilityToday;

  /// No description provided for @catalogueScheduleAction.
  ///
  /// In ar, this message translates to:
  /// **'عرض المواعيد'**
  String get catalogueScheduleAction;

  /// No description provided for @catalogueUpcomingTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتك الجاية'**
  String get catalogueUpcomingTitle;

  /// No description provided for @catalogueUpcomingSeeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get catalogueUpcomingSeeAll;

  /// No description provided for @catalogueUpcomingNone.
  ///
  /// In ar, this message translates to:
  /// **'مفيش حجوزات جاية. اختار منشأة وابدأ.'**
  String get catalogueUpcomingNone;

  /// No description provided for @catalogueBookingSpoken.
  ///
  /// In ar, this message translates to:
  /// **'حجز في {facility}، {date}، الساعة {time}، {status}'**
  String catalogueBookingSpoken(
    String facility,
    String date,
    String time,
    String status,
  );

  /// No description provided for @catalogueSuggestionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مقترحة ليك'**
  String get catalogueSuggestionsTitle;

  /// No description provided for @catalogueSuggestionReasonBookedType.
  ///
  /// In ar, this message translates to:
  /// **'لأنك حجزت {type} قبل كده'**
  String catalogueSuggestionReasonBookedType(String type);

  /// No description provided for @catalogueSuggestionReasonOther.
  ///
  /// In ar, this message translates to:
  /// **'ممكن تعجبك'**
  String get catalogueSuggestionReasonOther;

  /// No description provided for @catalogueShareAction.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة المنشأة'**
  String get catalogueShareAction;

  /// No description provided for @catalogueShareCopyLink.
  ///
  /// In ar, this message translates to:
  /// **'نسخ اللينك'**
  String get catalogueShareCopyLink;

  /// No description provided for @catalogueShareCopied.
  ///
  /// In ar, this message translates to:
  /// **'اتنسخ اللينك'**
  String get catalogueShareCopied;

  /// No description provided for @catalogueShareText.
  ///
  /// In ar, this message translates to:
  /// **'شوف {name} على سبرنت'**
  String catalogueShareText(String name);

  /// No description provided for @bookingScheduleHeading.
  ///
  /// In ar, this message translates to:
  /// **'المواعيد'**
  String get bookingScheduleHeading;

  /// No description provided for @bookingRefreshAction.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المواعيد'**
  String get bookingRefreshAction;

  /// No description provided for @bookingContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get bookingContinue;

  /// No description provided for @bookingUnitLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get bookingUnitLabel;

  /// No description provided for @bookingUnitHasPlaces.
  ///
  /// In ar, this message translates to:
  /// **'{unit}، فيه أماكن'**
  String bookingUnitHasPlaces(String unit);

  /// No description provided for @bookingUnitNoPlaces.
  ///
  /// In ar, this message translates to:
  /// **'{unit}، مفيش أماكن في اليوم ده'**
  String bookingUnitNoPlaces(String unit);

  /// No description provided for @bookingNothingLeftDay.
  ///
  /// In ar, this message translates to:
  /// **'مفيش مواعيد فاضلة في اليوم ده، وفيه أيام تانية متاحة.'**
  String get bookingNothingLeftDay;

  /// No description provided for @bookingNothingLeftWindow.
  ///
  /// In ar, this message translates to:
  /// **'مفيش مواعيد فاضلة في الأيام الجاية.'**
  String get bookingNothingLeftWindow;

  /// No description provided for @bookingNoUnitsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مفيش مواعيد للحجز'**
  String get bookingNoUnitsTitle;

  /// No description provided for @bookingNoUnitsBody.
  ///
  /// In ar, this message translates to:
  /// **'المنشأة دي ملهاش مواعيد متاحة للحجز دلوقتي.'**
  String get bookingNoUnitsBody;

  /// No description provided for @bookingBackToFacility.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع للمنشأة'**
  String get bookingBackToFacility;

  /// No description provided for @bookingErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'المواعيد متحمّلتش'**
  String get bookingErrorTitle;

  /// No description provided for @bookingErrorBody.
  ///
  /// In ar, this message translates to:
  /// **'ممكن تكون مشكلة مؤقتة.'**
  String get bookingErrorBody;

  /// No description provided for @bookingRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get bookingRetry;

  /// No description provided for @bookingChoiceGone.
  ///
  /// In ar, this message translates to:
  /// **'الاختيار اللي فات مبقاش متاح، فدي أقرب مواعيد متاحة.'**
  String get bookingChoiceGone;

  /// No description provided for @bookingNoticeDismiss.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق الرسالة'**
  String get bookingNoticeDismiss;

  /// No description provided for @bookingRangeHint.
  ///
  /// In ar, this message translates to:
  /// **'{hours, plural, =1{الحجز هنا ساعة واحدة في المرة} =2{الحجز بأول ساعة وآخر ساعة، لحد ساعتين متتاليتين} other{الحجز بأول ساعة وآخر ساعة، لحد {hours} ساعات متتالية}}'**
  String bookingRangeHint(int hours);

  /// No description provided for @bookingLengthHours.
  ///
  /// In ar, this message translates to:
  /// **'{hours, plural, =1{ساعة واحدة} =2{ساعتين} other{{hours} ساعات}}'**
  String bookingLengthHours(int hours);

  /// No description provided for @bookingLengthMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة'**
  String bookingLengthMinutes(int minutes);

  /// No description provided for @bookingTimeWithLength.
  ///
  /// In ar, this message translates to:
  /// **'الوقت {time}، المدة {length}'**
  String bookingTimeWithLength(String time, String length);

  /// No description provided for @bookingFree.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get bookingFree;

  /// No description provided for @bookingPanelTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختيارك'**
  String get bookingPanelTitle;

  /// No description provided for @bookingSelectionPrompt.
  ///
  /// In ar, this message translates to:
  /// **'لسه مفيش ميعاد مختار'**
  String get bookingSelectionPrompt;

  /// No description provided for @bookingGateReason.
  ///
  /// In ar, this message translates to:
  /// **'عشان تحجز'**
  String get bookingGateReason;

  /// No description provided for @bookingFailSlotTaken.
  ///
  /// In ar, this message translates to:
  /// **'الميعاد ده اتحجز لسه. فيه مواعيد تانية متاحة.'**
  String get bookingFailSlotTaken;

  /// No description provided for @bookingFailSlotTakenAt.
  ///
  /// In ar, this message translates to:
  /// **'الساعة {time} اتحجزت لسه، فالنطاق ده مش متاح.'**
  String bookingFailSlotTakenAt(String time);

  /// No description provided for @bookingFailSlotFull.
  ///
  /// In ar, this message translates to:
  /// **'الميعاد ده اكتمل لسه. فيه مواعيد تانية متاحة.'**
  String get bookingFailSlotFull;

  /// No description provided for @bookingFailSlotFullAt.
  ///
  /// In ar, this message translates to:
  /// **'الساعة {time} مكتملة، فالنطاق ده مش متاح.'**
  String bookingFailSlotFullAt(String time);

  /// No description provided for @bookingFailSlotPast.
  ///
  /// In ar, this message translates to:
  /// **'وقت الميعاد ده فات.'**
  String get bookingFailSlotPast;

  /// No description provided for @bookingFailOutsideWindow.
  ///
  /// In ar, this message translates to:
  /// **'الحجز متاح للأيام القريبة بس.'**
  String get bookingFailOutsideWindow;

  /// No description provided for @bookingFailClosed.
  ///
  /// In ar, this message translates to:
  /// **'الميعاد ده مش متاح.'**
  String get bookingFailClosed;

  /// No description provided for @bookingFailClosedAt.
  ///
  /// In ar, this message translates to:
  /// **'الساعة {time} مش متاحة، فالنطاق ده مش متاح.'**
  String bookingFailClosedAt(String time);

  /// No description provided for @bookingFailRangeTooLong.
  ///
  /// In ar, this message translates to:
  /// **'{hours, plural, =1{أقصى مدة للحجز ساعة واحدة.} =2{أقصى مدة للحجز ساعتين.} other{أقصى مدة للحجز {hours} ساعات.}}'**
  String bookingFailRangeTooLong(int hours);

  /// No description provided for @bookingFailRangeTooLongGeneric.
  ///
  /// In ar, this message translates to:
  /// **'النطاق أطول من المسموح.'**
  String get bookingFailRangeTooLongGeneric;

  /// No description provided for @bookingFailOverlap.
  ///
  /// In ar, this message translates to:
  /// **'عندك حجز في نفس الوقت: {facility}، {when}.'**
  String bookingFailOverlap(String facility, String when);

  /// No description provided for @bookingFailOverlapGeneric.
  ///
  /// In ar, this message translates to:
  /// **'عندك حجز تاني في نفس الوقت.'**
  String get bookingFailOverlapGeneric;

  /// No description provided for @bookingFailTooMany.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{وصلت للحد الأقصى: حجز نشط واحد.} =2{وصلت للحد الأقصى: حجزين نشطين.} other{وصلت للحد الأقصى: {count} حجوزات نشطة.}}'**
  String bookingFailTooMany(int count);

  /// No description provided for @bookingFailTooManyGeneric.
  ///
  /// In ar, this message translates to:
  /// **'وصلت للحد الأقصى للحجوزات النشطة.'**
  String get bookingFailTooManyGeneric;

  /// No description provided for @bookingFailNotPermitted.
  ///
  /// In ar, this message translates to:
  /// **'الحساب ده مش مسموحله يحجز.'**
  String get bookingFailNotPermitted;

  /// No description provided for @bookingFailNotFound.
  ///
  /// In ar, this message translates to:
  /// **'المنشأة أو الميعاد مش متاحين دلوقتي.'**
  String get bookingFailNotFound;

  /// No description provided for @bookingFailGeneric.
  ///
  /// In ar, this message translates to:
  /// **'الحجز متمّش. المحاولة تاني ممكنة.'**
  String get bookingFailGeneric;

  /// No description provided for @bookingSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الحجز'**
  String get bookingSummaryTitle;

  /// No description provided for @bookingRowFacility.
  ///
  /// In ar, this message translates to:
  /// **'المنشأة'**
  String get bookingRowFacility;

  /// No description provided for @bookingRowUnit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get bookingRowUnit;

  /// No description provided for @bookingRowDate.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get bookingRowDate;

  /// No description provided for @bookingRowTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get bookingRowTime;

  /// No description provided for @bookingRowLength.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get bookingRowLength;

  /// No description provided for @bookingRowCoverage.
  ///
  /// In ar, this message translates to:
  /// **'الحجز يشمل'**
  String get bookingRowCoverage;

  /// No description provided for @bookingRowTrainer.
  ///
  /// In ar, this message translates to:
  /// **'المدرب'**
  String get bookingRowTrainer;

  /// No description provided for @bookingRowTier.
  ///
  /// In ar, this message translates to:
  /// **'الشريحة'**
  String get bookingRowTier;

  /// No description provided for @bookingRowPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get bookingRowPrice;

  /// No description provided for @bookingRowPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الإلغاء'**
  String get bookingRowPolicy;

  /// No description provided for @bookingCoverageWhole.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة كلها'**
  String get bookingCoverageWhole;

  /// No description provided for @bookingCoverageWholeMax.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{الوحدة كلها، لمشارك واحد} =2{الوحدة كلها، لحد مشاركين} other{الوحدة كلها، لحد {count} مشارك}}'**
  String bookingCoverageWholeMax(int count);

  /// No description provided for @bookingCoverageOnePlace.
  ///
  /// In ar, this message translates to:
  /// **'مكان واحد'**
  String get bookingCoverageOnePlace;

  /// No description provided for @bookingSessionLength.
  ///
  /// In ar, this message translates to:
  /// **'حصة {minutes} دقيقة'**
  String bookingSessionLength(int minutes);

  /// No description provided for @bookingPolicyCutoff.
  ///
  /// In ar, this message translates to:
  /// **'{hours, plural, =0{الإلغاء متاح لحد وقت الميعاد.} =1{الإلغاء متاح لحد ساعة قبل الميعاد.} =2{الإلغاء متاح لحد ساعتين قبل الميعاد.} other{الإلغاء متاح لحد {hours} ساعات قبل الميعاد.}}'**
  String bookingPolicyCutoff(int hours);

  /// No description provided for @bookingPolicyRefundFull.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ بيرجع كامل.'**
  String get bookingPolicyRefundFull;

  /// No description provided for @bookingPolicyRefundPartial.
  ///
  /// In ar, this message translates to:
  /// **'بيرجع {percent}% من المبلغ.'**
  String bookingPolicyRefundPartial(int percent);

  /// No description provided for @bookingPolicyRefundNone.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ مش بيرجع.'**
  String get bookingPolicyRefundNone;

  /// No description provided for @bookingVerifyHint.
  ///
  /// In ar, this message translates to:
  /// **'توثيق الحساب بيدّي سعر الطلاب والعاملين.'**
  String get bookingVerifyHint;

  /// No description provided for @bookingVerifyAction.
  ///
  /// In ar, this message translates to:
  /// **'طلب توثيق'**
  String get bookingVerifyAction;

  /// No description provided for @bookingVerifyPending.
  ///
  /// In ar, this message translates to:
  /// **'طلب التوثيق قيد المراجعة. السعر الداخلي بيسري على الحجوزات الجديدة بعد الموافقة.'**
  String get bookingVerifyPending;

  /// No description provided for @bookingPriceChanged.
  ///
  /// In ar, this message translates to:
  /// **'السعر اتغيّر عن اللي ظهر في المواعيد. ده السعر الحالي.'**
  String get bookingPriceChanged;

  /// No description provided for @bookingPayAction.
  ///
  /// In ar, this message translates to:
  /// **'متابعة للدفع'**
  String get bookingPayAction;

  /// No description provided for @bookingConfirmAction.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحجز'**
  String get bookingConfirmAction;

  /// No description provided for @bookingFreeNoPayment.
  ///
  /// In ar, this message translates to:
  /// **'الحجز مجاني ومفيش خطوة دفع.'**
  String get bookingFreeNoPayment;

  /// No description provided for @bookingCheckoutSoonTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع قريبًا'**
  String get bookingCheckoutSoonTitle;

  /// No description provided for @bookingCheckoutSoonBody.
  ///
  /// In ar, this message translates to:
  /// **'خطوة الدفع هتتضاف قريب. اختيارك محفوظ في الملخص.'**
  String get bookingCheckoutSoonBody;

  /// No description provided for @bookingBackToSummary.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع للملخص'**
  String get bookingBackToSummary;

  /// No description provided for @bookingDoneTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحجز اتأكد'**
  String get bookingDoneTitle;

  /// No description provided for @bookingDoneBody.
  ///
  /// In ar, this message translates to:
  /// **'الحجز متسجل على حسابك، وهيظهر في الرئيسية.'**
  String get bookingDoneBody;

  /// No description provided for @bookingDoneCode.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحجز'**
  String get bookingDoneCode;

  /// No description provided for @bookingDoneHome.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع للرئيسية'**
  String get bookingDoneHome;

  /// No description provided for @bookingDoneNotFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحجز مش موجود'**
  String get bookingDoneNotFoundTitle;

  /// No description provided for @bookingDoneNotFoundBody.
  ///
  /// In ar, this message translates to:
  /// **'ممكن يكون اللينك غلط أو الحجز تبع حساب تاني.'**
  String get bookingDoneNotFoundBody;

  /// No description provided for @bookingTrainerStepTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختيار المدرب'**
  String get bookingTrainerStepTitle;

  /// No description provided for @bookingTrainerStepBody.
  ///
  /// In ar, this message translates to:
  /// **'المواعيد بتظهر بعد اختيار المدرب.'**
  String get bookingTrainerStepBody;

  /// No description provided for @bookingTrainerHasSessions.
  ///
  /// In ar, this message translates to:
  /// **'عنده حصص في الأيام الجاية'**
  String get bookingTrainerHasSessions;

  /// No description provided for @bookingTrainerNoSessions.
  ///
  /// In ar, this message translates to:
  /// **'مفيش حصص في الأيام الجاية'**
  String get bookingTrainerNoSessions;

  /// No description provided for @bookingTrainerNoName.
  ///
  /// In ar, this message translates to:
  /// **'مدرب'**
  String get bookingTrainerNoName;

  /// No description provided for @bookingTrainerChange.
  ///
  /// In ar, this message translates to:
  /// **'تغيير المدرب'**
  String get bookingTrainerChange;

  /// No description provided for @bookingTrainerChosen.
  ///
  /// In ar, this message translates to:
  /// **'المدرب: {name}'**
  String bookingTrainerChosen(String name);

  /// No description provided for @bookingNoTrainersTitle.
  ///
  /// In ar, this message translates to:
  /// **'مفيش مدربين متاحين'**
  String get bookingNoTrainersTitle;

  /// No description provided for @bookingNoTrainersBody.
  ///
  /// In ar, this message translates to:
  /// **'المنشأة دي لسه ملهاش مدربين للحجز.'**
  String get bookingNoTrainersBody;

  /// No description provided for @bookingTrainerNoSessionsBody.
  ///
  /// In ar, this message translates to:
  /// **'المدرب ده ملوش حصص في الأيام الجاية.'**
  String get bookingTrainerNoSessionsBody;

  /// No description provided for @bookingTrainerRowSpoken.
  ///
  /// In ar, this message translates to:
  /// **'المدرب {name}، {bio}، {sessions}'**
  String bookingTrainerRowSpoken(String name, String bio, String sessions);

  /// No description provided for @checkoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get checkoutTitle;

  /// No description provided for @checkoutHoldTitle.
  ///
  /// In ar, this message translates to:
  /// **'المكان متحجز لك لحد ما الدفع يخلص'**
  String get checkoutHoldTitle;

  /// No description provided for @checkoutHoldRemaining.
  ///
  /// In ar, this message translates to:
  /// **'فاضل {time} دقيقة، وبعدها المكان يرجع متاح'**
  String checkoutHoldRemaining(String time);

  /// No description provided for @checkoutLastMinuteTitle.
  ///
  /// In ar, this message translates to:
  /// **'المهلة على وشك تخلص'**
  String get checkoutLastMinuteTitle;

  /// No description provided for @checkoutLastMinuteBody.
  ///
  /// In ar, this message translates to:
  /// **'{seconds, plural, =1{فاضل ثانية واحدة، وبعدها المكان يرجع متاح} =2{فاضل ثانيتين، وبعدها المكان يرجع متاح} other{فاضل {seconds} ثانية، وبعدها المكان يرجع متاح}}'**
  String checkoutLastMinuteBody(int seconds);

  /// No description provided for @checkoutTierInternal.
  ///
  /// In ar, this message translates to:
  /// **'داخلي · موثّق'**
  String get checkoutTierInternal;

  /// No description provided for @checkoutTierExternal.
  ///
  /// In ar, this message translates to:
  /// **'خارجي · السعر الكامل'**
  String get checkoutTierExternal;

  /// No description provided for @checkoutPolicyTitle.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الإلغاء'**
  String get checkoutPolicyTitle;

  /// No description provided for @checkoutPolicyBody.
  ///
  /// In ar, this message translates to:
  /// **'الإلغاء متاح لحد {until} ({hours} قبل الميعاد) والفلوس بترجع {percent}% على نفس وسيلة الدفع. بعد كده زرار الإلغاء بيختفي.'**
  String checkoutPolicyBody(String until, String hours, int percent);

  /// No description provided for @checkoutRowTime.
  ///
  /// In ar, this message translates to:
  /// **'الميعاد'**
  String get checkoutRowTime;

  /// No description provided for @checkoutRowTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get checkoutRowTotal;

  /// No description provided for @checkoutMethodTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع الإلكتروني'**
  String get checkoutMethodTitle;

  /// No description provided for @checkoutMethodSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة بنكية أو محفظة موبايل · صفحة المزوّد الآمنة'**
  String get checkoutMethodSubtitle;

  /// No description provided for @checkoutSandboxTag.
  ///
  /// In ar, this message translates to:
  /// **'وضع الاختبار · مفيش فلوس حقيقية بتتخصم'**
  String get checkoutSandboxTag;

  /// No description provided for @checkoutPay.
  ///
  /// In ar, this message translates to:
  /// **'الدفع · {amount}'**
  String checkoutPay(String amount);

  /// No description provided for @checkoutPaySpoken.
  ///
  /// In ar, this message translates to:
  /// **'الدفع، {amount} جنيه'**
  String checkoutPaySpoken(int amount);

  /// No description provided for @checkoutStartError.
  ///
  /// In ar, this message translates to:
  /// **'بدء الدفع ماتمّش. المكان لسه متحجز لك، وممكن تحاول تاني.'**
  String get checkoutStartError;

  /// No description provided for @checkoutFailedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع ماتمّش. ممكن تحاول تاني'**
  String get checkoutFailedTitle;

  /// No description provided for @checkoutFailedBody.
  ///
  /// In ar, this message translates to:
  /// **'المكان لسه متحجز لك لحد ما المهلة تخلص.'**
  String get checkoutFailedBody;

  /// No description provided for @checkoutRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة · {amount}'**
  String checkoutRetry(String amount);

  /// No description provided for @holdExpiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'المهلة خلصت'**
  String get holdExpiredTitle;

  /// No description provided for @holdExpiredBody.
  ///
  /// In ar, this message translates to:
  /// **'المكان رجع متاح للناس. ممكن تختار الميعاد من جديد.'**
  String get holdExpiredBody;

  /// No description provided for @holdExpiredPickAnother.
  ///
  /// In ar, this message translates to:
  /// **'اختيار ميعاد تاني'**
  String get holdExpiredPickAnother;

  /// No description provided for @checkoutLeaveTitle.
  ///
  /// In ar, this message translates to:
  /// **'ترك الدفع؟'**
  String get checkoutLeaveTitle;

  /// No description provided for @checkoutLeaveBody.
  ///
  /// In ar, this message translates to:
  /// **'لو سبت الصفحة دلوقتي، المكان بيرجع متاح للناس.'**
  String get checkoutLeaveBody;

  /// No description provided for @checkoutLeaveConfirm.
  ///
  /// In ar, this message translates to:
  /// **'ترك الدفع'**
  String get checkoutLeaveConfirm;

  /// No description provided for @checkoutLeaveStay.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الدفع'**
  String get checkoutLeaveStay;

  /// No description provided for @checkoutCancelledTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع اتلغى'**
  String get checkoutCancelledTitle;

  /// No description provided for @checkoutCancelledBody.
  ///
  /// In ar, this message translates to:
  /// **'المكان لسه متحجز لك، وممكن تحاول تاني'**
  String get checkoutCancelledBody;

  /// No description provided for @gatewayTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع الآمن'**
  String get gatewayTitle;

  /// No description provided for @gatewayHoldTitle.
  ///
  /// In ar, this message translates to:
  /// **'المكان متحجز لك'**
  String get gatewayHoldTitle;

  /// No description provided for @gatewayHoldBody.
  ///
  /// In ar, this message translates to:
  /// **'فاضل {time} دقيقة لإكمال الدفع'**
  String gatewayHoldBody(String time);

  /// No description provided for @gatewayAmountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المطلوب'**
  String get gatewayAmountLabel;

  /// No description provided for @gatewayMerchant.
  ///
  /// In ar, this message translates to:
  /// **'سبرنت · {facility}'**
  String gatewayMerchant(String facility);

  /// No description provided for @gatewayCardNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم البطاقة'**
  String get gatewayCardNumber;

  /// No description provided for @gatewayCardExpiry.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء'**
  String get gatewayCardExpiry;

  /// No description provided for @gatewayCardCvc.
  ///
  /// In ar, this message translates to:
  /// **'رمز الأمان'**
  String get gatewayCardCvc;

  /// No description provided for @gatewayCardName.
  ///
  /// In ar, this message translates to:
  /// **'اسم حامل البطاقة'**
  String get gatewayCardName;

  /// No description provided for @gatewayCardNameHint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم زي ما هو على البطاقة'**
  String get gatewayCardNameHint;

  /// No description provided for @gatewayNotice.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة دي بتاعة مزوّد الدفع. بعد التأكيد بنرجعلك للتطبيق'**
  String get gatewayNotice;

  /// No description provided for @gatewayConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الدفع · {amount}'**
  String gatewayConfirm(String amount);

  /// No description provided for @gatewayCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get gatewayCancel;

  /// No description provided for @gatewayErrCardNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم البطاقة مش صحيح'**
  String get gatewayErrCardNumber;

  /// No description provided for @gatewayErrExpiry.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء مش صحيح أو فات'**
  String get gatewayErrExpiry;

  /// No description provided for @gatewayErrCvc.
  ///
  /// In ar, this message translates to:
  /// **'رمز الأمان لازم يكون 3 أو 4 أرقام'**
  String get gatewayErrCvc;

  /// No description provided for @gatewayErrName.
  ///
  /// In ar, this message translates to:
  /// **'اسم حامل البطاقة مطلوب'**
  String get gatewayErrName;

  /// No description provided for @gatewayExpiryHint.
  ///
  /// In ar, this message translates to:
  /// **'MM / YY'**
  String get gatewayExpiryHint;

  /// No description provided for @gatewayCvcHint.
  ///
  /// In ar, this message translates to:
  /// **'000'**
  String get gatewayCvcHint;

  /// No description provided for @processingTitle.
  ///
  /// In ar, this message translates to:
  /// **'بنأكد الدفع'**
  String get processingTitle;

  /// No description provided for @processingBody.
  ///
  /// In ar, this message translates to:
  /// **'التأكيد بييجي من مزوّد الدفع وممكن ياخد لحظات، والأحسن إن الشاشة تفضل مفتوحة'**
  String get processingBody;

  /// No description provided for @processingHeld.
  ///
  /// In ar, this message translates to:
  /// **'المكان متحجز لك، فاضل {time} دقيقة'**
  String processingHeld(String time);

  /// No description provided for @awaitingTitle.
  ///
  /// In ar, this message translates to:
  /// **'لسه مستنيين تأكيد الدفع'**
  String get awaitingTitle;

  /// No description provided for @awaitingBody.
  ///
  /// In ar, this message translates to:
  /// **'لو الخصم حصل ومتأكدش الحجز، الفلوس بترجع لوحدها. المكان متحجز لك لحد ما التأكيد يوصل'**
  String get awaitingBody;

  /// No description provided for @awaitingRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الحالة'**
  String get awaitingRefresh;

  /// No description provided for @awaitingRefreshing.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحديث الحالة'**
  String get awaitingRefreshing;

  /// No description provided for @awaitingBackToBookings.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع للحجوزات'**
  String get awaitingBackToBookings;

  /// No description provided for @receiptTitle.
  ///
  /// In ar, this message translates to:
  /// **'إيصال دفع'**
  String get receiptTitle;

  /// No description provided for @receiptNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الإيصال'**
  String get receiptNumber;

  /// No description provided for @receiptBookingCode.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحجز'**
  String get receiptBookingCode;

  /// No description provided for @receiptDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get receiptDate;

  /// No description provided for @receiptUnit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get receiptUnit;

  /// No description provided for @receiptTier.
  ///
  /// In ar, this message translates to:
  /// **'الشريحة'**
  String get receiptTier;

  /// No description provided for @receiptMethod.
  ///
  /// In ar, this message translates to:
  /// **'وسيلة الدفع'**
  String get receiptMethod;

  /// No description provided for @receiptMethodCard.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة تنتهي بـ {last4} · اختبار'**
  String receiptMethodCard(String last4);

  /// No description provided for @receiptTotalPaid.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي المدفوع'**
  String get receiptTotalPaid;

  /// No description provided for @receiptRefund.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المسترد'**
  String get receiptRefund;

  /// No description provided for @receiptSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الإيصال PDF'**
  String get receiptSave;

  /// No description provided for @receiptShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الإيصال'**
  String get receiptShare;

  /// No description provided for @receiptNavTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإيصال'**
  String get receiptNavTitle;

  /// No description provided for @receiptPdfFailed.
  ///
  /// In ar, this message translates to:
  /// **'الـ PDF ماتعملش. اتشاركت نسخة نصية بدله'**
  String get receiptPdfFailed;

  /// No description provided for @receiptNotFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإيصال مش موجود'**
  String get receiptNotFoundTitle;

  /// No description provided for @receiptNotFoundBody.
  ///
  /// In ar, this message translates to:
  /// **'مفيش إيصال للحجز ده. الإيصال بيظهر بعد دفع ناجح.'**
  String get receiptNotFoundBody;

  /// No description provided for @confirmedTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجزك اتأكد'**
  String get confirmedTitle;

  /// No description provided for @confirmedSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'وصلك إشعار بالتفاصيل، وهنفكرك قبل الميعاد بـ{lead}.'**
  String confirmedSubtitle(String lead);

  /// No description provided for @confirmedReceiptRow.
  ///
  /// In ar, this message translates to:
  /// **'إيصال الدفع'**
  String get confirmedReceiptRow;

  /// No description provided for @leadHours.
  ///
  /// In ar, this message translates to:
  /// **'{hours, plural, =1{ساعة} =2{ساعتين} other{{hours} ساعات}}'**
  String leadHours(int hours);

  /// No description provided for @leadHoursHalf.
  ///
  /// In ar, this message translates to:
  /// **'{hours, plural, =0{نص ساعة} =1{ساعة ونص} =2{ساعتين ونص} other{{hours} ساعات ونص}}'**
  String leadHoursHalf(int hours);

  /// No description provided for @leadMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{minutes, plural, =1{دقيقة} =2{دقيقتين} other{{minutes} دقيقة}}'**
  String leadMinutes(int minutes);

  /// No description provided for @demoPaymentTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع التجريبي'**
  String get demoPaymentTitle;

  /// No description provided for @demoPaymentNote.
  ///
  /// In ar, this message translates to:
  /// **'بيحدد اللي هيحصل لما صفحة المزوّد تأكد الدفع. للعرض بس.'**
  String get demoPaymentNote;

  /// No description provided for @demoPaymentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'نجاح'**
  String get demoPaymentSuccess;

  /// No description provided for @demoPaymentFail.
  ///
  /// In ar, this message translates to:
  /// **'فشل'**
  String get demoPaymentFail;

  /// No description provided for @demoPaymentDelay.
  ///
  /// In ar, this message translates to:
  /// **'تأخير'**
  String get demoPaymentDelay;

  /// No description provided for @demoPaymentDelayPreset.
  ///
  /// In ar, this message translates to:
  /// **'{seconds} ثانية'**
  String demoPaymentDelayPreset(int seconds);

  /// No description provided for @demoPaymentDelayAfterMax.
  ///
  /// In ar, this message translates to:
  /// **'بعد الحد الأقصى'**
  String get demoPaymentDelayAfterMax;

  /// No description provided for @demoPaymentCurrent.
  ///
  /// In ar, this message translates to:
  /// **'الاختيار الحالي: {value}'**
  String demoPaymentCurrent(String value);

  /// No description provided for @demoPaymentDelayCurrent.
  ///
  /// In ar, this message translates to:
  /// **'تأخير {seconds} ثانية، وبعدها نجاح'**
  String demoPaymentDelayCurrent(int seconds);

  /// No description provided for @ticketQrLabel.
  ///
  /// In ar, this message translates to:
  /// **'رمز الحضور، بيتعرض للمدرب عند الدخول'**
  String get ticketQrLabel;

  /// Splash screen tagline under the wordmark (proposed copy, not yet in copy-review)
  ///
  /// In ar, this message translates to:
  /// **'احجز من غير زحمة'**
  String get splashTagline;

  /// Splash screen caption at the bottom (proposed copy, not yet in copy-review)
  ///
  /// In ar, this message translates to:
  /// **'جامعة طنطا'**
  String get splashCaption;

  /// No description provided for @notificationBellLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationBellLabel;

  /// No description provided for @notificationBellLabelUnread.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات، {count, plural, =1{إشعار جديد واحد} =2{إشعارين جدد} other{{count} إشعارات جديدة}}'**
  String notificationBellLabelUnread(int count);

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get commonBack;

  /// No description provided for @lockedFieldReadOnly.
  ///
  /// In ar, this message translates to:
  /// **'للقراءة فقط، {reason}'**
  String lockedFieldReadOnly(String reason);

  /// No description provided for @lockedFieldIcon.
  ///
  /// In ar, this message translates to:
  /// **'مقفول'**
  String get lockedFieldIcon;

  /// No description provided for @searchClear.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get searchClear;

  /// No description provided for @popoverClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق القائمة'**
  String get popoverClose;

  /// No description provided for @dialogConfirmDestructive.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get dialogConfirmDestructive;

  /// No description provided for @gallery007Section.
  ///
  /// In ar, this message translates to:
  /// **'جزء حجوزاتي والإشعارات والحساب'**
  String get gallery007Section;

  /// No description provided for @gallery007SampleTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد حجزك'**
  String get gallery007SampleTitle;

  /// No description provided for @gallery007SampleBody.
  ///
  /// In ar, this message translates to:
  /// **'حمام السباحة الأولمبي · حارة 2'**
  String get gallery007SampleBody;

  /// No description provided for @gallery007SampleTime.
  ///
  /// In ar, this message translates to:
  /// **'4:00 م'**
  String get gallery007SampleTime;

  /// No description provided for @gallery007SampleDate.
  ///
  /// In ar, this message translates to:
  /// **'الخميس 12 نوفمبر · 6:00 – 8:00 م'**
  String get gallery007SampleDate;

  /// No description provided for @gallery007SampleAction.
  ///
  /// In ar, this message translates to:
  /// **'عرض التذكرة'**
  String get gallery007SampleAction;

  /// No description provided for @gallery007SampleUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'الجاية (3)'**
  String get gallery007SampleUpcoming;

  /// No description provided for @gallery007SamplePast.
  ///
  /// In ar, this message translates to:
  /// **'اللي فاتت'**
  String get gallery007SamplePast;

  /// No description provided for @gallery007SampleLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get gallery007SampleLanguage;

  /// No description provided for @gallery007SampleLanguageValue.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get gallery007SampleLanguageValue;

  /// No description provided for @gallery007SampleSignOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get gallery007SampleSignOut;

  /// No description provided for @gallery007SampleName.
  ///
  /// In ar, this message translates to:
  /// **'منى سالم'**
  String get gallery007SampleName;

  /// No description provided for @gallery007SampleLockedHelper.
  ///
  /// In ar, this message translates to:
  /// **'مربوط بتسجيل الدخول ومش بيتعدل من هنا'**
  String get gallery007SampleLockedHelper;

  /// No description provided for @gallery007SampleBanner.
  ///
  /// In ar, this message translates to:
  /// **'الحجز اتلغى. الفلوس هترجع على نفس وسيلة الدفع.'**
  String get gallery007SampleBanner;

  /// No description provided for @gallery007OpenDialog.
  ///
  /// In ar, this message translates to:
  /// **'فتح نافذة التأكيد'**
  String get gallery007OpenDialog;

  /// No description provided for @gallery007DialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز؟'**
  String get gallery007DialogTitle;

  /// No description provided for @gallery007DialogBack.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع'**
  String get gallery007DialogBack;

  /// No description provided for @gallery007OpenPopover.
  ///
  /// In ar, this message translates to:
  /// **'فتح القائمة'**
  String get gallery007OpenPopover;

  /// No description provided for @gallery007SampleSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get gallery007SampleSearch;

  /// No description provided for @gallery007SampleSearchCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get gallery007SampleSearchCancel;

  /// No description provided for @gallery007SampleEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإيميل'**
  String get gallery007SampleEmailLabel;

  /// No description provided for @navNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get navNotifications;

  /// No description provided for @catalogueFacilitiesTitle.
  ///
  /// In ar, this message translates to:
  /// **'كل المنشآت'**
  String get catalogueFacilitiesTitle;

  /// No description provided for @bookingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتي'**
  String get bookingsTitle;

  /// No description provided for @bookingsSegmentUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'الجاية ({count})'**
  String bookingsSegmentUpcoming(int count);

  /// No description provided for @bookingsSegmentUpcomingPlain.
  ///
  /// In ar, this message translates to:
  /// **'الجاية'**
  String get bookingsSegmentUpcomingPlain;

  /// No description provided for @bookingsSegmentPast.
  ///
  /// In ar, this message translates to:
  /// **'اللي فاتت'**
  String get bookingsSegmentPast;

  /// No description provided for @bookingsSegmentUpcomingSpoken.
  ///
  /// In ar, this message translates to:
  /// **'الجاية، {count, plural, =1{حجز واحد} =2{حجزين} other{{count} حجوزات}}'**
  String bookingsSegmentUpcomingSpoken(int count);

  /// No description provided for @bookingsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لسه مفيش حجوزات.'**
  String get bookingsEmptyTitle;

  /// No description provided for @bookingsEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'المنشآت مستنياك'**
  String get bookingsEmptyBody;

  /// No description provided for @bookingsUpcomingEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'مفيش حجوزات جاية'**
  String get bookingsUpcomingEmptyTitle;

  /// No description provided for @bookingsUpcomingEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتك القديمة موجودة في \"اللي فاتت\".'**
  String get bookingsUpcomingEmptyBody;

  /// No description provided for @bookingsPastEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'مفيش حجوزات سابقة'**
  String get bookingsPastEmptyTitle;

  /// No description provided for @bookingsBrowse.
  ///
  /// In ar, this message translates to:
  /// **'استعراض المنشآت'**
  String get bookingsBrowse;

  /// No description provided for @bookingsNoneSelected.
  ///
  /// In ar, this message translates to:
  /// **'مفيش حجز محدد'**
  String get bookingsNoneSelected;

  /// No description provided for @bookingsActionTicket.
  ///
  /// In ar, this message translates to:
  /// **'عرض التذكرة'**
  String get bookingsActionTicket;

  /// No description provided for @bookingsActionPay.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الدفع'**
  String get bookingsActionPay;

  /// No description provided for @bookingsActionDetails.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get bookingsActionDetails;

  /// No description provided for @bookingsToday.
  ///
  /// In ar, this message translates to:
  /// **'النهارده'**
  String get bookingsToday;

  /// No description provided for @bookingsNoteFree.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get bookingsNoteFree;

  /// No description provided for @bookingsNoteTrainer.
  ///
  /// In ar, this message translates to:
  /// **'مع {name}'**
  String bookingsNoteTrainer(String name);

  /// No description provided for @bookingsNoteHold.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{فاضل دقيقة للدفع} =2{فاضل دقيقتين للدفع} other{فاضل {count} دقايق للدفع}}'**
  String bookingsNoteHold(int count);

  /// No description provided for @bookingsRowSpoken.
  ///
  /// In ar, this message translates to:
  /// **'{status}، {date}، {facility}، {notes}، رقم الحجز {code}، {action}'**
  String bookingsRowSpoken(
    String status,
    String date,
    String facility,
    String notes,
    String code,
    String action,
  );

  /// No description provided for @bookingsLoadError.
  ///
  /// In ar, this message translates to:
  /// **'مقدرناش نحمّل حجوزاتك.'**
  String get bookingsLoadError;

  /// No description provided for @bookingsRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get bookingsRetry;

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الحجز'**
  String get bookingDetailsTitle;

  /// No description provided for @bookingDetailsNotFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحجز مش موجود'**
  String get bookingDetailsNotFoundTitle;

  /// No description provided for @bookingDetailsNotFoundBody.
  ///
  /// In ar, this message translates to:
  /// **'مش لاقيين الحجز ده في حجوزاتك.'**
  String get bookingDetailsNotFoundBody;

  /// No description provided for @bookingDetailsBackToBookings.
  ///
  /// In ar, this message translates to:
  /// **'العودة للحجوزات'**
  String get bookingDetailsBackToBookings;

  /// No description provided for @bookingDetailsTier.
  ///
  /// In ar, this message translates to:
  /// **'الشريحة'**
  String get bookingDetailsTier;

  /// No description provided for @bookingDetailsTierInternal.
  ///
  /// In ar, this message translates to:
  /// **'داخلي'**
  String get bookingDetailsTierInternal;

  /// No description provided for @bookingDetailsTierExternal.
  ///
  /// In ar, this message translates to:
  /// **'خارجي'**
  String get bookingDetailsTierExternal;

  /// No description provided for @bookingDetailsPaid.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get bookingDetailsPaid;

  /// No description provided for @bookingDetailsAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get bookingDetailsAmount;

  /// No description provided for @bookingDetailsRequired.
  ///
  /// In ar, this message translates to:
  /// **'المطلوب'**
  String get bookingDetailsRequired;

  /// No description provided for @bookingDetailsNotPaid.
  ///
  /// In ar, this message translates to:
  /// **'ما اتدفعش'**
  String get bookingDetailsNotPaid;

  /// No description provided for @bookingDetailsPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get bookingDetailsPrice;

  /// No description provided for @bookingDetailsFree.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get bookingDetailsFree;

  /// No description provided for @bookingDetailsCode.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحجز'**
  String get bookingDetailsCode;

  /// No description provided for @bookingDetailsCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get bookingDetailsCancel;

  /// No description provided for @bookingDetailsPay.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الدفع · {amount}'**
  String bookingDetailsPay(String amount);

  /// No description provided for @bookingDetailsReceipt.
  ///
  /// In ar, this message translates to:
  /// **'إيصال الدفع'**
  String get bookingDetailsReceipt;

  /// No description provided for @bookingDetailsHoldTitle.
  ///
  /// In ar, this message translates to:
  /// **'المكان متحجز لك'**
  String get bookingDetailsHoldTitle;

  /// No description provided for @bookingDetailsHoldSub.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{فاضل دقيقة للدفع، وبعدها المكان يرجع متاح} =2{فاضل دقيقتين للدفع، وبعدها المكان يرجع متاح} other{فاضل {count} دقايق للدفع، وبعدها المكان يرجع متاح}}'**
  String bookingDetailsHoldSub(int count);

  /// No description provided for @bookingDetailsAfterCutoff.
  ///
  /// In ar, this message translates to:
  /// **'الإلغاء كان متاح لحد {when}، وبعده زرار الإلغاء بيختفي.'**
  String bookingDetailsAfterCutoff(String when);

  /// No description provided for @bookingDetailsAttended.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل حضورك. شكرًا لاستخدامك سبرنت'**
  String get bookingDetailsAttended;

  /// No description provided for @bookingDetailsNoShow.
  ///
  /// In ar, this message translates to:
  /// **'الحجز ده عدّى من غير حضور. مفيش أي رسوم أو عقوبة'**
  String get bookingDetailsNoShow;

  /// No description provided for @bookingDetailsExpired.
  ///
  /// In ar, this message translates to:
  /// **'المهلة خلصت من غير دفع، والمكان رجع متاح'**
  String get bookingDetailsExpired;

  /// No description provided for @bookingDetailsCancelledByYou.
  ///
  /// In ar, this message translates to:
  /// **'الحجز اتلغى.'**
  String get bookingDetailsCancelledByYou;

  /// No description provided for @bookingDetailsCancelledByFacility.
  ///
  /// In ar, this message translates to:
  /// **'لغته إدارة المنشأة.'**
  String get bookingDetailsCancelledByFacility;

  /// No description provided for @bookingDetailsCancelReason.
  ///
  /// In ar, this message translates to:
  /// **'السبب: {reason}'**
  String bookingDetailsCancelReason(String reason);

  /// No description provided for @bookingDetailsFacilityRefund.
  ///
  /// In ar, this message translates to:
  /// **'الـ {amount} رجعت كاملة، واتبلّغت فورًا.'**
  String bookingDetailsFacilityRefund(String amount);

  /// No description provided for @bookingDetailsRefundFull.
  ///
  /// In ar, this message translates to:
  /// **'الـ {amount} هترجع على نفس وسيلة الدفع.'**
  String bookingDetailsRefundFull(String amount);

  /// No description provided for @bookingDetailsRefundPartial.
  ///
  /// In ar, this message translates to:
  /// **'هيرجع {refund} من {paid} على نفس وسيلة الدفع.'**
  String bookingDetailsRefundPartial(String refund, String paid);

  /// No description provided for @bookingDetailsRefundNone.
  ///
  /// In ar, this message translates to:
  /// **'مفيش مبلغ هيرجع.'**
  String get bookingDetailsRefundNone;

  /// No description provided for @bookingDetailsFreeCancelled.
  ///
  /// In ar, this message translates to:
  /// **'الحجز كان مجاني، والمكان رجع متاح.'**
  String get bookingDetailsFreeCancelled;

  /// No description provided for @bookingDetailsPendingCancelled.
  ///
  /// In ar, this message translates to:
  /// **'الحجز اتلغى ومفيش فلوس اتسحبت.'**
  String get bookingDetailsPendingCancelled;

  /// No description provided for @bookingTicketSpoken.
  ///
  /// In ar, this message translates to:
  /// **'حجز {status}، {facility}، {date}'**
  String bookingTicketSpoken(String status, String facility, String date);

  /// No description provided for @cancelDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز؟'**
  String get cancelDialogTitle;

  /// No description provided for @cancelActionConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get cancelActionConfirm;

  /// No description provided for @cancelActionBack.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع'**
  String get cancelActionBack;

  /// No description provided for @cancelMessageFull.
  ///
  /// In ar, this message translates to:
  /// **'هترجع {amount} كاملة على نفس وسيلة الدفع.'**
  String cancelMessageFull(String amount);

  /// No description provided for @cancelMessagePartial.
  ///
  /// In ar, this message translates to:
  /// **'هيرجع {refund} من {paid} على نفس وسيلة الدفع.'**
  String cancelMessagePartial(String refund, String paid);

  /// No description provided for @cancelMessageNone.
  ///
  /// In ar, this message translates to:
  /// **'الإلغاء دلوقتي من غير استرداد، ومفيش مبلغ هيرجع.'**
  String get cancelMessageNone;

  /// No description provided for @cancelMessageFree.
  ///
  /// In ar, this message translates to:
  /// **'الحجز مجاني، فمفيش مبلغ يرجع. المكان هيرجع متاح لغيرك.'**
  String get cancelMessageFree;

  /// No description provided for @cancelMessagePending.
  ///
  /// In ar, this message translates to:
  /// **'هنلغي الحجز ومفيش فلوس اتسحبت.'**
  String get cancelMessagePending;

  /// No description provided for @cancelClosedTitle.
  ///
  /// In ar, this message translates to:
  /// **'فات وقت الإلغاء'**
  String get cancelClosedTitle;

  /// No description provided for @cancelClosedBody.
  ///
  /// In ar, this message translates to:
  /// **'الإلغاء كان متاح لحد {when}.'**
  String cancelClosedBody(String when);

  /// No description provided for @cancelAlreadyTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحجز ده اتلغى قبل كده'**
  String get cancelAlreadyTitle;

  /// No description provided for @cancelFailed.
  ///
  /// In ar, this message translates to:
  /// **'الإلغاء ماتمش والحجز زي ما هو.'**
  String get cancelFailed;

  /// No description provided for @cancelNotAllowedBody.
  ///
  /// In ar, this message translates to:
  /// **'الحجز ده مينفعش يتلغي دلوقتي.'**
  String get cancelNotAllowedBody;

  /// No description provided for @cancelResultTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحجز اتلغى'**
  String get cancelResultTitle;

  /// No description provided for @cancelResultBack.
  ///
  /// In ar, this message translates to:
  /// **'العودة للحجوزات'**
  String get cancelResultBack;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تعليم الكل كمقروء'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'مفيش إشعارات'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أي حاجة جديدة بخصوص حجوزاتك هتظهر هنا.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsUnreadSpoken.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get notificationsUnreadSpoken;

  /// No description provided for @notifBookingConfirmedTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجزك اتأكد'**
  String get notifBookingConfirmedTitle;

  /// No description provided for @notifBookingConfirmedBody.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحجز {code}'**
  String notifBookingConfirmedBody(String code);

  /// No description provided for @notifReminderTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجزك قرّب'**
  String get notifReminderTitle;

  /// No description provided for @notifReminderBody.
  ///
  /// In ar, this message translates to:
  /// **'الحجز {code} بيبدأ قريب.'**
  String notifReminderBody(String code);

  /// No description provided for @notifReminderCutoffClosed.
  ///
  /// In ar, this message translates to:
  /// **'الإلغاء اتقفل، والحجز زي ما هو.'**
  String get notifReminderCutoffClosed;

  /// No description provided for @notifAdminCancelTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المنشأة لغت حجزك'**
  String get notifAdminCancelTitle;

  /// No description provided for @notifAdminCancelBody.
  ///
  /// In ar, this message translates to:
  /// **'الحجز {code}. الفلوس رجعت كاملة.'**
  String notifAdminCancelBody(String code);

  /// No description provided for @notifOwnerCancelTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء حجزك'**
  String get notifOwnerCancelTitle;

  /// No description provided for @notifOwnerCancelBody.
  ///
  /// In ar, this message translates to:
  /// **'الحجز {code}.'**
  String notifOwnerCancelBody(String code);

  /// No description provided for @notifRefundTitle.
  ///
  /// In ar, this message translates to:
  /// **'رجعنا لك فلوسك'**
  String get notifRefundTitle;

  /// No description provided for @notifRefundBody.
  ///
  /// In ar, this message translates to:
  /// **'{amount} رجعت على نفس وسيلة الدفع.'**
  String notifRefundBody(String amount);

  /// No description provided for @notifVerificationPendingTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب التوثيق تحت المراجعة'**
  String get notifVerificationPendingTitle;

  /// No description provided for @notifVerificationPendingBody.
  ///
  /// In ar, this message translates to:
  /// **'هنبلغك أول ما نخلص.'**
  String get notifVerificationPendingBody;

  /// No description provided for @notifVerificationApprovedTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابك اتوثّق'**
  String get notifVerificationApprovedTitle;

  /// No description provided for @notifVerificationApprovedBody.
  ///
  /// In ar, this message translates to:
  /// **'دلوقتي بتحجز بالسعر الداخلي.'**
  String get notifVerificationApprovedBody;

  /// No description provided for @notifVerificationRejectedTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب التوثيق اترفض'**
  String get notifVerificationRejectedTitle;

  /// No description provided for @notifVerificationRejectedBody.
  ///
  /// In ar, this message translates to:
  /// **'السبب: {reason}'**
  String notifVerificationRejectedBody(String reason);

  /// No description provided for @notifUnknownTitle.
  ///
  /// In ar, this message translates to:
  /// **'إشعار جديد'**
  String get notifUnknownTitle;

  /// No description provided for @notifViewTicket.
  ///
  /// In ar, this message translates to:
  /// **'عرض التذكرة'**
  String get notifViewTicket;

  /// No description provided for @notifCancelBooking.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get notifCancelBooking;

  /// No description provided for @permissionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات؟'**
  String get permissionTitle;

  /// No description provided for @permissionMessage.
  ///
  /// In ar, this message translates to:
  /// **'هنبعتلك تذكير قبل الحجز وأي تحديث عليه.'**
  String get permissionMessage;

  /// No description provided for @permissionAllow.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get permissionAllow;

  /// No description provided for @permissionDeny.
  ///
  /// In ar, this message translates to:
  /// **'مش دلوقتي'**
  String get permissionDeny;

  /// No description provided for @demo007Section.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات وإلغاء من الإدارة'**
  String get demo007Section;

  /// No description provided for @demo007ShowReminder.
  ///
  /// In ar, this message translates to:
  /// **'إظهار تذكير حجزي الجاي'**
  String get demo007ShowReminder;

  /// No description provided for @demo007AdminCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء من الإدارة'**
  String get demo007AdminCancel;

  /// No description provided for @demo007Done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get demo007Done;

  /// No description provided for @demo007NoBooking.
  ///
  /// In ar, this message translates to:
  /// **'مفيش حجز مؤكد جاي'**
  String get demo007NoBooking;

  /// No description provided for @accountTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get accountTitle;

  /// No description provided for @accountPersonalData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات الشخصية'**
  String get accountPersonalData;

  /// No description provided for @accountNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get accountNotifications;

  /// No description provided for @accountNotificationsOn.
  ///
  /// In ar, this message translates to:
  /// **'مفعّلة'**
  String get accountNotificationsOn;

  /// No description provided for @accountNotificationsOff.
  ///
  /// In ar, this message translates to:
  /// **'متوقفة'**
  String get accountNotificationsOff;

  /// No description provided for @accountGuestTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك عشان تشوف حسابك'**
  String get accountGuestTitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل البيانات'**
  String get editProfileTitle;

  /// No description provided for @editProfileName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get editProfileName;

  /// No description provided for @editProfileNameError.
  ///
  /// In ar, this message translates to:
  /// **'الاسم لازم يكون حرفين على الأقل'**
  String get editProfileNameError;

  /// No description provided for @editProfileEmail.
  ///
  /// In ar, this message translates to:
  /// **'الإيميل'**
  String get editProfileEmail;

  /// No description provided for @editProfilePhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get editProfilePhone;

  /// No description provided for @editProfileLockedHelper.
  ///
  /// In ar, this message translates to:
  /// **'مربوط بتسجيل الدخول ومش بيتعدل من هنا'**
  String get editProfileLockedHelper;

  /// No description provided for @editProfileSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get editProfileSave;

  /// No description provided for @editProfileChangePhoto.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get editProfileChangePhoto;

  /// No description provided for @editProfileRemovePhoto.
  ///
  /// In ar, this message translates to:
  /// **'حذف الصورة'**
  String get editProfileRemovePhoto;

  /// No description provided for @editProfilePhotoError.
  ///
  /// In ar, this message translates to:
  /// **'الصورة مش مناسبة، وفضلت الصورة القديمة.'**
  String get editProfilePhotoError;

  /// No description provided for @editProfileSaveError.
  ///
  /// In ar, this message translates to:
  /// **'الحفظ ماتمش، وبياناتك زي ما هي.'**
  String get editProfileSaveError;

  /// No description provided for @editProfilePhotoSourceTitle.
  ///
  /// In ar, this message translates to:
  /// **'صورة الحساب'**
  String get editProfilePhotoSourceTitle;
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
