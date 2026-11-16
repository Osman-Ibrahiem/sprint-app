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
  /// **'حجوزاتك وبيانات حسابك هتظهر هنا بعد تسجيل الدخول. التسجيل لسه مش متاح في النسخة دي.'**
  String get signInPromptBody;

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
  /// **'للمراجعين فقط. من غير تسجيل دخول حقيقي.'**
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
  /// **'إلغاء مجاني لحد {date}'**
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
