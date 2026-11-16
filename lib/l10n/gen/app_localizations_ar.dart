// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سبرنت';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navFacilities => 'المنشآت';

  @override
  String get navBookings => 'حجوزاتي';

  @override
  String get navProfile => 'حسابي';

  @override
  String get navMainLabel => 'التنقل الرئيسي';

  @override
  String get placeholderNote => 'الشاشة دي لسه تحت التجهيز.';

  @override
  String get homeIntro => 'هنا هتلاقي المنشآت والمواعيد القريبة.';

  @override
  String get facilitiesIntro => 'كل منشآت الجامعة الرياضية في مكان واحد.';

  @override
  String get facilitiesSearchHint => 'البحث عن منشأة';

  @override
  String get signInPromptTitle => 'تسجيل الدخول مطلوب';

  @override
  String get signInPromptBody =>
      'حجوزاتك وبيانات حسابك هتظهر هنا بعد تسجيل الدخول. التسجيل لسه مش متاح في النسخة دي.';

  @override
  String get notFoundTitle => 'الصفحة دي مش موجودة';

  @override
  String get notFoundBody => 'الرابط ممكن يكون اتغيّر أو مكتوب غلط.';

  @override
  String get backToHome => 'الرجوع للرئيسية';

  @override
  String get noAccessTitle => 'الصفحة دي مش متاحة لحسابك';

  @override
  String get noAccessBody =>
      'الصفحة دي مخصوصة لصلاحيات تانية. لو محتاج الوصول ليها ممكن تتواصل مع مسؤول الجامعة.';

  @override
  String get homeTitle => 'أهلًا في سبرنت';

  @override
  String get facilitiesTitle => 'منشآت الجامعة';

  @override
  String priceEgp(String amount) {
    return '$amount ج.م';
  }

  @override
  String get appearanceTitle => 'المظهر';

  @override
  String get appearanceSystem => 'حسب الجهاز';

  @override
  String get appearanceLight => 'فاتح';

  @override
  String get appearanceDark => 'غامق';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageAr => 'العربية';

  @override
  String get languageEn => 'English';

  @override
  String get demoEntry => 'شاشة العرض للمراجعين';

  @override
  String get optionSelected => 'مختار';

  @override
  String get dayShortSaturday => 'السبت';

  @override
  String get dayShortSunday => 'الحد';

  @override
  String get dayShortMonday => 'الاتنين';

  @override
  String get dayShortTuesday => 'التلات';

  @override
  String get dayShortWednesday => 'الأربع';

  @override
  String get dayShortThursday => 'الخميس';

  @override
  String get dayShortFriday => 'الجمعة';

  @override
  String get dayFullSaturday => 'السبت';

  @override
  String get dayFullSunday => 'الأحد';

  @override
  String get dayFullMonday => 'الاثنين';

  @override
  String get dayFullTuesday => 'الثلاثاء';

  @override
  String get dayFullWednesday => 'الأربعاء';

  @override
  String get dayFullThursday => 'الخميس';

  @override
  String get dayFullFriday => 'الجمعة';

  @override
  String get demoTitle => 'شاشة العرض';

  @override
  String get demoColours => 'الألوان';

  @override
  String get demoTypography => 'الخطوط';

  @override
  String get demoSpacing => 'المسافات';

  @override
  String get demoRadius => 'الزوايا';

  @override
  String get demoControls => 'عناصر التحكم حسب النظام';

  @override
  String get demoTypeSample => 'سبرنت – حجزك اتأكد 120';

  @override
  String get demoAppBarTrigger => 'عرض شريط العنوان الكبير';

  @override
  String get demoLargeTitle => 'عنوان كبير';

  @override
  String get demoDialogTrigger => 'عرض نافذة التأكيد';

  @override
  String get demoDialogTitle => 'إلغاء الحجز؟';

  @override
  String get demoDialogMessage => 'المكان هيرجع متاح لغيرك.';

  @override
  String get demoDialogConfirm => 'إلغاء الحجز';

  @override
  String get demoDialogKeep => 'التراجع';

  @override
  String get demoSheetTrigger => 'عرض قايمة الإجراءات';

  @override
  String get demoSheetTitle => 'إجراءات الحجز';

  @override
  String get demoSheetShare => 'مشاركة';

  @override
  String get demoSheetCalendar => 'إضافة للتقويم';

  @override
  String get demoSheetClose => 'إغلاق';

  @override
  String get demoSwitchLabel => 'تفعيل التذكيرات';

  @override
  String get demoLoaderLabel => 'جاري التحميل';

  @override
  String demoResult(String value) {
    return 'آخر اختيار: $value';
  }

  @override
  String get demoResultNone => 'لسه مفيش اختيار';

  @override
  String get demoAppearance => 'المظهر واللغة';

  @override
  String get roleBooker => 'حاجز';

  @override
  String get roleTrainer => 'مدرب';

  @override
  String get roleFacilityManager => 'مدير منشأة';

  @override
  String get roleVerifier => 'مسؤول توثيق';

  @override
  String get roleUnitAdmin => 'مسؤول جهة';

  @override
  String get roleSuperAdmin => 'مشرف عام';

  @override
  String get roleViewer => 'مراقب';

  @override
  String get tierInternal => 'سعر داخلي';

  @override
  String get tierExternal => 'سعر كامل';

  @override
  String profileRoles(String roles) {
    return 'الأدوار: $roles';
  }

  @override
  String profileTier(String tier) {
    return 'الشريحة: $tier';
  }

  @override
  String get demoUserTitle => 'عرض كمستخدم تاني';

  @override
  String get demoUserNote => 'للمراجعين فقط. من غير تسجيل دخول حقيقي.';

  @override
  String get demoGuest => 'ضيف (من غير حساب)';

  @override
  String get demoSettingsTitle => 'الإعدادات والوراثة';

  @override
  String get demoSettingsPick => 'اختيار وحدة';

  @override
  String demoSettingsUnit(String unit) {
    return 'الوحدة: $unit';
  }

  @override
  String get levelUnit => 'الوحدة';

  @override
  String get levelFacility => 'المنشأة';

  @override
  String get levelUniversity => 'الجامعة';

  @override
  String get levelDefault => 'افتراضي';

  @override
  String get demoNoLimit => 'بلا حد';

  @override
  String demoSettingsLevel(String level) {
    return 'من: $level';
  }

  @override
  String demoSwatchLabel(String name) {
    return '$name، فاتح وغامق';
  }

  @override
  String get buttonDisabledSuffix => '، غير متاح';

  @override
  String get buttonBusy => 'جاري التنفيذ…';

  @override
  String get fieldShowPassword => 'إظهار';

  @override
  String get fieldHidePassword => 'إخفاء';

  @override
  String get codeEntryLabel => 'كود التأكيد';

  @override
  String get codeEntrySentTo => 'الكود اتبعت على';

  @override
  String get codeEntryResend => 'إرسال الكود تاني';

  @override
  String codeEntryResendIn(int seconds) {
    return 'إرسال الكود تاني بعد $seconds ثانية';
  }

  @override
  String get fieldSearchHint => 'البحث';

  @override
  String slotAvailablePlaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أماكن',
      two: 'مكانين',
      one: 'مكان واحد',
    );
    return '$_temp0';
  }

  @override
  String get slotSelected => 'مختار';

  @override
  String slotFewLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فاضل $count',
      two: 'فاضل مكانين',
      one: 'فاضل 1',
    );
    return '$_temp0';
  }

  @override
  String slotFewLeftSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فاضل $count أماكن',
      two: 'فاضل مكانين',
      one: 'فاضل مكان واحد',
    );
    return '$_temp0';
  }

  @override
  String get slotFull => 'مكتمل';

  @override
  String get slotPast => 'فات';

  @override
  String slotSpoken(String time, String state) {
    return 'الساعة $time، $state';
  }

  @override
  String slotSpokenWithPrice(String time, String state, String price) {
    return 'الساعة $time، $state، $price';
  }

  @override
  String get dayToday => 'النهارده';

  @override
  String get dayHasRoom => 'فيه أماكن';

  @override
  String get dayClosed => 'مقفول';

  @override
  String daySpoken(String day, String state) {
    return 'يوم $day، $state';
  }

  @override
  String statusSpoken(String status) {
    return 'الحالة: $status';
  }

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusPendingPayment => 'في انتظار الدفع';

  @override
  String get statusCancelled => 'اتلغى';

  @override
  String get statusAttended => 'حضر';

  @override
  String get statusNoShow => 'غاب';

  @override
  String get statusExpired => 'انتهت المهلة';

  @override
  String get statusUnderReview => 'قيد المراجعة';

  @override
  String get statusVerified => 'موثّق';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusOpen => 'مفتوح';

  @override
  String get statusInProgress => 'جاري';

  @override
  String get statusResolved => 'اتحل';

  @override
  String get facilityPhotoPlaceholder => 'صورة المنشأة';

  @override
  String get facilityTrainerTag => 'بمدرب';

  @override
  String get facilityFreeTag => 'مجاني';

  @override
  String facilityUnitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وحدات',
      two: 'وحدتين',
      one: 'وحدة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get facilityAvailabilityPlenty => 'متاح النهارده';

  @override
  String get facilityAvailabilityFew => 'أماكن قليلة';

  @override
  String get facilityAvailabilityNone => 'مفيش مواعيد النهارده';

  @override
  String get facilityPriceInternalLabel => 'سعر الطلاب والعاملين';

  @override
  String get facilityPriceExternalLabel => 'السعر الكامل';

  @override
  String get facilityFree => 'مجاني';

  @override
  String facilitySpoken(
    String name,
    String unit,
    String availability,
    String price,
  ) {
    return 'منشأة $name، $unit، $availability، $price';
  }

  @override
  String get ticketCodeLabel => 'كود الحجز';

  @override
  String get ticketCopied => 'اتنسخ';

  @override
  String get ticketPaid => 'المدفوع';

  @override
  String ticketCancelUntil(String date) {
    return 'إلغاء مجاني لحد $date';
  }

  @override
  String get ticketCancelUnavailable => 'الإلغاء مش متاح';

  @override
  String get ticketQrUnavailable => 'QR غير متاح';

  @override
  String ticketSpoken(
    String facility,
    String dateTime,
    String status,
    String code,
  ) {
    return 'تذكرة $facility، $dateTime، $status، $code';
  }

  @override
  String get navMore => 'المزيد';

  @override
  String navBadgeSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غير مقروء',
      one: 'غير مقروء واحد',
    );
    return '$_temp0';
  }

  @override
  String statDeltaUp(String value) {
    return 'زيادة $value';
  }

  @override
  String statDeltaDown(String value) {
    return 'نقص $value';
  }

  @override
  String get statDeltaFlat => 'مفيش تغيير';

  @override
  String get statNoComparison => 'مفيش مقارنة';

  @override
  String get logoLabel => 'سبرنت';

  @override
  String get galleryTitle => 'معرض المكونات';

  @override
  String get gallerySampleNote => 'بيانات تجريبية';

  @override
  String get galleryTextSize => 'حجم النص';

  @override
  String get galleryReducedMotion => 'تقليل الحركة';

  @override
  String get galleryPlatformLook => 'شكل المنصة';

  @override
  String get galleryPlatformApple => 'آبل';

  @override
  String get galleryPlatformAndroid => 'أندرويد';

  @override
  String get galleryPlatformDesktop => 'ديسكتوب';

  @override
  String get galleryOpenFromDemo => 'معرض المكونات';

  @override
  String get galleryButtonSection => 'الأزرار';

  @override
  String get galleryTextFieldSection => 'حقول الإدخال';

  @override
  String get gallerySlotChipSection => 'مواعيد الحجز';

  @override
  String get galleryDayStripSection => 'شريط الأيام';

  @override
  String get galleryStatusBadgeSection => 'شارات الحالة';

  @override
  String get galleryFacilityCardSection => 'كروت المنشآت';

  @override
  String get galleryBookingTicketSection => 'تذاكر الحجز';

  @override
  String get galleryNavigationSection => 'التنقل';

  @override
  String get galleryStatTileSection => 'المؤشرات';

  @override
  String get galleryLogoSection => 'اللوجو';

  @override
  String get timeAm => 'صباحًا';

  @override
  String get timePm => 'مساءً';

  @override
  String get slotAvailableWord => 'متاح';

  @override
  String get signInTitle => 'تسجيل الدخول';

  @override
  String get signInIdentifierLabel => 'الإيميل أو رقم الموبايل';

  @override
  String get signInPasswordLabel => 'الباسورد';

  @override
  String get signInButton => 'تسجيل الدخول';

  @override
  String get signInBadCredentials => 'بيانات الدخول مش صحيحة';

  @override
  String signInLocked(int minutes) {
    return 'المحاولات كترت. الدخول متوقف مؤقتًا، وتقدر تحاول تاني بعد $minutes دقيقة.';
  }

  @override
  String get signInSuspended =>
      'الحساب ده موقوف حاليًا. ممكن التواصل مع إدارة الجامعة.';

  @override
  String get signInUnexpected =>
      'حصلت مشكلة غير متوقعة. ممكن المحاولة تاني بعد شوية.';

  @override
  String get signInForgot => 'نسيت الباسورد؟';

  @override
  String get signInCreateAccount => 'إنشاء حساب';

  @override
  String get signOutTitle => 'تأكيد تسجيل الخروج';

  @override
  String get signOutBody =>
      'هتفضل تقدر تتصفح التطبيق كزائر، وتسجّل دخول تاني في أي وقت.';

  @override
  String get signOutConfirm => 'تسجيل الخروج';

  @override
  String get signOutKeep => 'البقاء في الحساب';

  @override
  String accountCardSpoken(String name, String tier) {
    return 'حسابك: $name، $tier';
  }
}
