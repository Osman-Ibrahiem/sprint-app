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
      'حجوزاتك وبيانات حسابك هتظهر هنا بعد تسجيل الدخول.';

  @override
  String get gateTitle => 'الخطوة دي محتاجة حساب';

  @override
  String gateBody(String reason) {
    return 'تسجيل الدخول أو إنشاء حساب $reason';
  }

  @override
  String get gateSignIn => 'تسجيل الدخول';

  @override
  String get gateSignUp => 'إنشاء حساب';

  @override
  String get gateDismiss => 'مش دلوقتي';

  @override
  String get gateReasonBook => 'عشان تحجز';

  @override
  String get gateReasonBookings => 'عشان تشوف حجوزاتك';

  @override
  String get gateReasonVerification => 'عشان تطلب التوثيق';

  @override
  String get gateReasonProfile => 'عشان تشوف بيانات حسابك';

  @override
  String get gateDemoBookSlot => 'حجز الميعاد ده';

  @override
  String get gateDemoTitle => 'تجربة طلب الحساب';

  @override
  String get gateDemoIntro =>
      'بعد اختيار ميعاد والضغط على الحجز، الزائر بتظهر له نافذة الحساب، وبعد الدخول بيرجع هنا والميعاد لسه مختار.';

  @override
  String get gateDemoReady =>
      'الحساب جاهز. الحجز ماتمش لوحده، ومحتاج ضغطة جديدة.';

  @override
  String get gateDemoDismissed =>
      'اتقفلت من غير تسجيل دخول، ولسه الميعاد مختار.';

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
  String get demoUserNote =>
      'للمراجعين فقط. التبديل بين الحسابات من غير باسورد.';

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
  String get codeEntrySentTo => 'بعتنا كود على';

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
  String get ticketShowTrainer =>
      'الكود بيتعرض للمدرب عند الدخول · السطوع العالي أوضح';

  @override
  String get ticketCodeLabel => 'كود الحجز';

  @override
  String get ticketCopied => 'اتنسخ';

  @override
  String get ticketPaid => 'المدفوع';

  @override
  String ticketCancelUntil(String date) {
    return 'الإلغاء متاح لحد $date';
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
  String get forgotTitle => 'استرجاع الباسورد';

  @override
  String get forgotIntro =>
      'اكتب الإيميل أو رقم الموبايل المسجّل، وهنبعت كود على إيميل الحساب.';

  @override
  String get forgotSendButton => 'إرسال الكود';

  @override
  String get resetTitle => 'باسورد جديد';

  @override
  String get resetSentNeutral =>
      'لو الحساب موجود هيوصله كود على الإيميل المسجّل.';

  @override
  String get resetNewPasswordLabel => 'الباسورد الجديد';

  @override
  String get resetPasswordHint => '8 حروف على الأقل، فيها حرف ورقم';

  @override
  String get resetSaveButton => 'حفظ الباسورد';

  @override
  String resetCodeWrong(int tries) {
    return 'الكود غلط. المحاولات المتبقية: $tries.';
  }

  @override
  String get resetCodeExpired => 'الكود انتهت صلاحيته. ممكن تطلب كود جديد.';

  @override
  String get resetCodeDead => 'محاولات الكود خلصت. ممكن تطلب كود جديد.';

  @override
  String resetResendTooSoon(int seconds) {
    return 'ممكن تطلب كود جديد بعد $seconds ثانية.';
  }

  @override
  String get resetPasswordEmpty => 'الباسورد الجديد مطلوب.';

  @override
  String get resetPasswordTooShort => 'الباسورد لازم يكون 8 حروف على الأقل.';

  @override
  String get resetPasswordNeedsLetter =>
      'الباسورد لازم فيه حرف واحد على الأقل.';

  @override
  String get resetPasswordNeedsDigit => 'الباسورد لازم فيه رقم واحد على الأقل.';

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

  @override
  String get signUpTitle => 'إنشاء حساب';

  @override
  String get signUpButton => 'إنشاء الحساب';

  @override
  String get signUpNameLabel => 'الاسم بالكامل';

  @override
  String get signUpNameHelper => 'الاسم الأول واسم العيلة على الأقل';

  @override
  String get signUpPhoneLabel => 'رقم الموبايل';

  @override
  String get signUpPhoneHelper => 'رقم مصري، مثال 01012345678';

  @override
  String get signUpEmailLabel => 'الإيميل';

  @override
  String get signUpEmailHelper => 'هنبعت عليه كود تأكيد الحساب';

  @override
  String get signUpPasswordLabel => 'الباسورد';

  @override
  String get signUpPasswordHelper => '8 حروف على الأقل، فيها حرف ورقم';

  @override
  String get signUpAlreadyHave => 'عندك حساب؟';

  @override
  String get validationNameEmpty => 'الاسم مطلوب.';

  @override
  String get validationNameTooShort => 'الاسم قصير أوي.';

  @override
  String get validationNameTooLong => 'الاسم طويل، الحد الأقصى 60 حرف.';

  @override
  String get validationNameNeedsTwoWords =>
      'الاسم لازم يكون كلمتين على الأقل، الاسم الأول واسم العيلة.';

  @override
  String get validationNameInvalidCharacters => 'الاسم يقبل حروف ومسافات بس.';

  @override
  String get validationPhoneEmpty => 'رقم الموبايل مطلوب.';

  @override
  String get validationPhoneInvalid =>
      'رقم الموبايل لازم يكون 11 رقم ويبدأ بـ 010 أو 011 أو 012 أو 015.';

  @override
  String get validationEmailEmpty => 'الإيميل مطلوب.';

  @override
  String get validationEmailInvalid =>
      'الإيميل مش مكتوب صح، مثال name@example.com.';

  @override
  String get validationPasswordEmpty => 'الباسورد مطلوب.';

  @override
  String get validationPasswordTooShort =>
      'الباسورد لازم يكون 8 حروف على الأقل.';

  @override
  String get validationPasswordNeedsLetter =>
      'الباسورد لازم فيه حرف واحد على الأقل.';

  @override
  String get validationPasswordNeedsDigit =>
      'الباسورد لازم فيه رقم واحد على الأقل.';

  @override
  String get signUpEmailTaken => 'الإيميل ده مسجل قبل كده.';

  @override
  String get signUpPhoneTaken => 'رقم الموبايل ده مسجل قبل كده.';

  @override
  String get signUpTakenActions => 'ممكن تسجيل الدخول أو استرجاع الباسورد.';

  @override
  String get confirmEmailTitle => 'تأكيد الإيميل';

  @override
  String get confirmEmailButton => 'تأكيد';

  @override
  String get confirmCodeEmpty => 'الكود مكوّن من 6 أرقام.';

  @override
  String confirmCodeWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فاضلك $count محاولات',
      two: 'فاضلك محاولتين',
      one: 'فاضلك محاولة واحدة',
    );
    return 'الكود مش صحيح. $_temp0.';
  }

  @override
  String get confirmCodeExpired => 'الكود انتهت صلاحيته. ممكن إرسال كود جديد.';

  @override
  String get confirmCodeDead =>
      'المحاولات خلصت على الكود ده. ممكن إرسال كود جديد.';

  @override
  String get confirmNoPending =>
      'مفيش تأكيد معلّق للإيميل ده. ممكن إنشاء حساب من جديد.';

  @override
  String confirmResendTooSoon(int seconds) {
    return 'ممكن إرسال كود جديد بعد $seconds ثانية.';
  }

  @override
  String get confirmResent => 'بعتنا كود جديد.';

  @override
  String get emailConfirmSubject => 'كود تأكيد حسابك في سبرنت';

  @override
  String emailConfirmBody(String code, int minutes) {
    return 'كود التأكيد: $code\nالكود صالح لمدة $minutes دقيقة. لو مش إنت اللي عملت الحساب، ممكن تتجاهل الرسالة دي.';
  }

  @override
  String get emailResetSubject => 'كود استرجاع الباسورد في سبرنت';

  @override
  String emailResetBody(String code, int minutes) {
    return 'كود الاسترجاع: $code\nالكود صالح لمدة $minutes دقيقة. لو مش إنت اللي طلبت الاسترجاع، ممكن تتجاهل الرسالة دي.';
  }

  @override
  String get demoNoticeTitle => 'للعرض بس';

  @override
  String demoNoticeCode(String code) {
    return 'كود التجربة: $code';
  }

  @override
  String get demoNoticeDismiss => 'إخفاء';

  @override
  String get mailboxTitle => 'صندوق البريد التجريبي';

  @override
  String get demoResetButton => 'إرجاع الداتا التجريبية';

  @override
  String get demoResetTitle => 'إرجاع الداتا التجريبية؟';

  @override
  String get demoResetBody =>
      'كل الحجوزات والحسابات والطلبات اللي اتعملت هتتمسح، والداتا هترجع زي أول مرة. المظهر واللغة هيفضلوا زي ما هما.';

  @override
  String get demoResetConfirm => 'إرجاع الداتا';

  @override
  String get demoResetKeep => 'إلغاء';

  @override
  String get mailboxNote =>
      'الرسائل اللي التطبيق كان هيبعتها بالإيميل بتظهر هنا. للمراجعين فقط.';

  @override
  String get mailboxEmptyTitle => 'مفيش رسائل لسه';

  @override
  String get mailboxEmptyBody => 'أي كود تأكيد أو استرجاع هيتبعت هيظهر هنا.';

  @override
  String get mailboxTo => 'إلى';

  @override
  String get mailboxCopyCode => 'نسخ الكود';

  @override
  String get mailboxCopied => 'الكود اتنسخ.';

  @override
  String get catalogueTypeSwimming => 'سباحة';

  @override
  String get catalogueTypeFootball => 'كرة قدم';

  @override
  String get catalogueTypeGym => 'لياقة بدنية';

  @override
  String get catalogueTypeTennis => 'تنس';

  @override
  String get catalogueTypeHall => 'صالة';

  @override
  String get catalogueTypeTraining => 'تدريب';

  @override
  String get catalogueErrorTitle => 'حصلت مشكلة';

  @override
  String get catalogueErrorBody =>
      'المحتوى مش ظاهر دلوقتي. المحاولة تاني ممكن تحل المشكلة.';

  @override
  String get catalogueRetry => 'إعادة المحاولة';

  @override
  String get catalogueFacilityNotFoundTitle => 'المنشأة مش موجودة';

  @override
  String get catalogueFacilityNotFoundBody =>
      'الرابط ممكن يكون غلط أو المنشأة مش منشورة.';

  @override
  String get catalogueBackToFacilities => 'الرجوع للمنشآت';

  @override
  String get cataloguePanePrompt => 'اختار منشأة تشوف تفاصيلها';

  @override
  String cataloguePriceRange(String min, String max) {
    return '$min–$max ج.م';
  }

  @override
  String get catalogueTagFree => 'مجاني';

  @override
  String get catalogueTagTrainer => 'بمدرب';

  @override
  String get catalogueHomeTitle => 'اكتشف المنشآت';

  @override
  String get catalogueHomeTypesTitle => 'أنواع المنشآت';

  @override
  String get catalogueHomeFeaturedTitle => 'منشآت مميزة';

  @override
  String get catalogueHomeSeeAll => 'عرض كل المنشآت';

  @override
  String get catalogueHomeGuestHint => 'تقدر تشوف كل المنشآت من غير تسجيل.';

  @override
  String get catalogueFiltersTitle => 'الفلاتر';

  @override
  String get catalogueFilterAllTypes => 'كل الأنواع';

  @override
  String get catalogueFilterAllUnits => 'كل الجهات';

  @override
  String get catalogueFilterAny => 'مجاني أو مدفوع';

  @override
  String get catalogueFilterFree => 'مجاني';

  @override
  String get catalogueFilterPaid => 'مدفوع';

  @override
  String get catalogueFilterClearAll => 'مسح الكل';

  @override
  String catalogueFilterRemove(String name) {
    return 'إزالة فلتر $name';
  }

  @override
  String catalogueResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منشأة',
      few: '$count منشآت',
      two: 'منشأتين',
      one: 'منشأة واحدة',
      zero: 'مفيش منشآت',
    );
    return '$_temp0';
  }

  @override
  String get catalogueEmptyTitle => 'مفيش منشآت مطابقة';

  @override
  String catalogueEmptyBody(String filters) {
    return 'مفيش حاجة بتطابق الفلاتر دي: $filters';
  }

  @override
  String get catalogueEmptyClear => 'مسح الفلاتر';

  @override
  String get catalogueSectionHours => 'مواعيد العمل';

  @override
  String get catalogueSectionPrices => 'الأسعار';

  @override
  String get catalogueSectionTrainers => 'المدربين';

  @override
  String get catalogueSectionUnits => 'الوحدات';

  @override
  String get catalogueSectionAvailability => 'المتاح النهارده';

  @override
  String get catalogueSectionFacts => 'معلومات الحجز';

  @override
  String get cataloguePhotoPlaceholder => 'صورة المنشأة';

  @override
  String cataloguePhotoPosition(int index, int count) {
    return 'صورة $index من $count';
  }

  @override
  String catalogueDayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'الاثنين',
      '2': 'الثلاثاء',
      '3': 'الأربعاء',
      '4': 'الخميس',
      '5': 'الجمعة',
      '6': 'السبت',
      'other': 'الأحد',
    });
    return '$_temp0';
  }

  @override
  String get catalogueHoursClosedDay => 'مقفول';

  @override
  String get catalogueHoursToday => 'النهارده';

  @override
  String get catalogueClosedNow => 'مقفول دلوقتي';

  @override
  String get catalogueClosedToday => 'مقفول النهارده';

  @override
  String get catalogueListSeparator => '، ';

  @override
  String catalogueClosureRange(String from, String to) {
    return 'من $from إلى $to';
  }

  @override
  String get cataloguePriceInternalLabel => 'سعر الطلبة والعاملين';

  @override
  String get cataloguePriceExternalLabel => 'السعر العادي';

  @override
  String get cataloguePriceYours => 'سعرك';

  @override
  String get cataloguePriceBasisShared => 'للمكان الواحد';

  @override
  String get cataloguePriceBasisExclusive => 'للحجز كله';

  @override
  String get cataloguePriceAllUnits => 'كل الوحدات';

  @override
  String get cataloguePriceNotSet => 'السعر لسه مش محدد';

  @override
  String get catalogueFreeNoPayment => 'المنشأة دي مجانية ومفيش دفع.';

  @override
  String catalogueTrainerCapacity(int count) {
    return 'بياخد $count في الحصة';
  }

  @override
  String get catalogueTrainersNone => 'مفيش مدربين دلوقتي';

  @override
  String get catalogueTrainerFirst => 'لازم تختار المدرب الأول';

  @override
  String get catalogueTrainerUnnamed => 'مدرب';

  @override
  String catalogueUnitOwnHours(String hours) {
    return 'مواعيد خاصة: $hours';
  }

  @override
  String catalogueFactWindow(int days) {
    return 'الحجز لحد $days أيام قدام';
  }

  @override
  String catalogueFactMaxRange(int hours) {
    return 'أقصى مدة للحجز $hours ساعات';
  }

  @override
  String catalogueFactSession(int minutes) {
    return 'مدة الحصة $minutes دقيقة';
  }

  @override
  String get verifTitle => 'طلب التوثيق';

  @override
  String get verifRenewTitle => 'تجديد التوثيق';

  @override
  String get verifIntro =>
      'بعد التوثيق بتحجز بالسعر الداخلي. بنراجع البيانات وصورة البطاقة.';

  @override
  String get verifTypeTitle => 'نوع الحساب';

  @override
  String get verifTypeStudent => 'طالب';

  @override
  String get verifTypeStaff => 'موظف';

  @override
  String get verifTypeFaculty => 'عضو هيئة تدريس';

  @override
  String get verifNationalIdLabel => 'الرقم القومي';

  @override
  String get verifNationalIdHelper => '14 رقم زي ما هو مكتوب في البطاقة.';

  @override
  String get verifCodeLabel => 'الكود الجامعي أو الوظيفي';

  @override
  String get verifCodeHelper => 'أرقام أو حروف إنجليزي، لحد 20 خانة.';

  @override
  String get verifUnitTitle => 'الكلية أو الإدارة';

  @override
  String get verifPhotoLabel => 'صورة البطاقة';

  @override
  String get verifPhotoHelper =>
      'صورة واضحة للبطاقة كلها. بنصغّرها تلقائي قبل الإرسال.';

  @override
  String get verifPhotoChoose => 'اختيار الصورة';

  @override
  String get verifPhotoReplace => 'تغيير الصورة';

  @override
  String get verifPhotoSourceTitle => 'صورة البطاقة';

  @override
  String get verifPhotoCamera => 'تصوير بالكاميرا';

  @override
  String get verifPhotoGallery => 'اختيار من الصور أو الملفات';

  @override
  String get verifPhotoCancel => 'إلغاء';

  @override
  String get verifPhotoProcessing => 'جاري تجهيز الصورة';

  @override
  String get verifPhotoPreviewSpoken => 'معاينة صورة البطاقة';

  @override
  String get verifPhotoNotImage => 'الملف ده مش صورة. اختار صورة تانية.';

  @override
  String get verifErrNationalIdEmpty => 'الرقم القومي مطلوب.';

  @override
  String get verifErrNationalIdLength => 'الرقم القومي لازم يكون 14 رقم.';

  @override
  String get verifErrNationalIdCentury =>
      'أول رقم في الرقم القومي لازم يكون 2 أو 3.';

  @override
  String get verifErrNationalIdBirthDate =>
      'تاريخ الميلاد جوه الرقم القومي مش صحيح.';

  @override
  String get verifErrNationalIdFuture =>
      'تاريخ الميلاد جوه الرقم القومي لسه ماجاش.';

  @override
  String get verifErrNationalIdGovernorate =>
      'كود المحافظة جوه الرقم القومي مش صحيح.';

  @override
  String get verifErrCodeEmpty => 'الكود مطلوب.';

  @override
  String get verifErrCodeInvalid =>
      'الكود لازم يكون من 1 لـ 20 رقم أو حرف إنجليزي.';

  @override
  String get verifErrUnitEmpty => 'اختار الكلية أو الإدارة.';

  @override
  String get verifErrPhotoEmpty => 'صورة البطاقة مطلوبة.';

  @override
  String get verifSubmit => 'إرسال الطلب';

  @override
  String get verifSubmitting => 'جاري إرسال الطلب';

  @override
  String verifResultApproved(String date) {
    return 'تم التوثيق. سعرك داخلي لحد $date.';
  }

  @override
  String get verifResultPending =>
      'الطلب اتبعت وبيتراجع. لحد ما يخلص هتفضل بالسعر الكامل.';

  @override
  String verifResultRejected(String reason) {
    return 'الطلب اترفض. السبب: $reason';
  }

  @override
  String get verifResultDone => 'تمام';

  @override
  String get verifReasonDuplicate =>
      'الرقم القومي ده عليه طلب توثيق من حساب تاني.';

  @override
  String get verifStorageFull => 'الصورة متحفظتش، ممكن تبعتها تاني';

  @override
  String get verifAlreadyPending => 'عندك طلب قيد المراجعة بالفعل.';

  @override
  String get verifCardTitle => 'التوثيق';

  @override
  String verifCardSpoken(String status) {
    return 'التوثيق: $status';
  }

  @override
  String get verifStatusNone => 'غير موثّق';

  @override
  String get verifStatusExpired => 'التوثيق انتهى';

  @override
  String get verifNoneBody =>
      'حسابك بالسعر الكامل. بعد التوثيق بتحجز بالسعر الداخلي.';

  @override
  String get verifPendingBody =>
      'طلبك قيد المراجعة. لحد ما يخلص هتفضل بالسعر الكامل.';

  @override
  String verifApprovedUntil(String date) {
    return 'متوثق لحد $date';
  }

  @override
  String get verifRejectedBody => 'الطلب اترفض.';

  @override
  String verifReasonLabel(String reason) {
    return 'السبب: $reason';
  }

  @override
  String verifExpiredBody(String date) {
    return 'التوثيق انتهى يوم $date. السعر دلوقتي كامل لحد التجديد.';
  }

  @override
  String get verifActionRequest => 'طلب التوثيق';

  @override
  String get verifActionRenew => 'تجديد التوثيق';

  @override
  String get verifActionAgain => 'إرسال طلب جديد';

  @override
  String get verifActionWait => 'في انتظار المراجعة';

  @override
  String verifNationalIdMasked(String id) {
    return 'الرقم القومي: $id';
  }

  @override
  String get verifRevSection => 'التوثيق';

  @override
  String get verifRevQueueTitle => 'طلبات التوثيق';

  @override
  String get verifRevQueueEmpty => 'مفيش طلبات مستنية المراجعة.';

  @override
  String verifRevWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مستني من $count دقايق',
      two: 'مستني من دقيقتين',
      one: 'مستني من دقيقة',
      zero: 'مستني من أقل من دقيقة',
    );
    return '$_temp0';
  }

  @override
  String verifRevWaitHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مستني من $count ساعات',
      two: 'مستني من ساعتين',
      one: 'مستني من ساعة',
    );
    return '$_temp0';
  }

  @override
  String verifRevWaitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مستني من $count أيام',
      two: 'مستني من يومين',
      one: 'مستني من يوم',
    );
    return '$_temp0';
  }

  @override
  String get verifRevPricing => 'بعد القبول هيتحاسب بالسعر الداخلي';

  @override
  String verifRevRowSpoken(String name, String type, String unit, String wait) {
    return 'طلب $name، $type، $unit، $wait';
  }

  @override
  String get verifRevDetailTitle => 'تفاصيل الطلب';

  @override
  String get verifRevPickPrompt => 'اختيار طلب من القائمة بيعرض تفاصيله هنا.';

  @override
  String get verifRevName => 'الاسم';

  @override
  String get verifRevType => 'النوع';

  @override
  String get verifRevCode => 'الكود';

  @override
  String get verifRevUnit => 'الكلية أو الإدارة';

  @override
  String get verifRevSubmitted => 'وقت الإرسال';

  @override
  String get verifRevNationalId => 'الرقم القومي';

  @override
  String get verifRevPhoto => 'صورة البطاقة';

  @override
  String verifRevPhotoSpoken(String name) {
    return 'صورة بطاقة $name';
  }

  @override
  String get verifRevPhotoMissing => 'الصورة مش موجودة.';

  @override
  String get verifRevApprove => 'قبول الطلب';

  @override
  String get verifRevReject => 'رفض الطلب';

  @override
  String get verifRevRejectTitle => 'رفض الطلب';

  @override
  String get verifRevReasonLabel => 'سبب الرفض';

  @override
  String get verifRevReasonHelper =>
      '10 حروف على الأقل، والسبب هيظهر لصاحب الطلب.';

  @override
  String get verifRevReasonConfirm => 'تأكيد الرفض';

  @override
  String get verifRevReasonCancel => 'رجوع';

  @override
  String get verifRevAlreadyDecided => 'الطلب ده اتقرر فيه قبل كده.';

  @override
  String get verifRevOwnRequest => 'طلبك أنت مينفعش تراجعه بنفسك.';

  @override
  String get verifRevDecidedApproved =>
      'تم قبول الطلب، وصاحبه بقى بالسعر الداخلي.';

  @override
  String get verifRevDecidedRejected => 'تم رفض الطلب، والسبب ظاهر لصاحبه.';

  @override
  String get verifRevUpload => 'رفع الشيت';

  @override
  String get sheetTitle => 'رفع شيت التوثيق';

  @override
  String get sheetHelp =>
      'ملف CSV بترميز UTF-8 فيه 3 أعمدة بالترتيب: الرقم القومي، الكود، النوع (طالب أو موظف أو عضو هيئة تدريس). الصف الأول ممكن يبقى عناوين.';

  @override
  String get sheetPick => 'اختيار ملف CSV';

  @override
  String get sheetSummaryTitle => 'ملخص الرفع';

  @override
  String get sheetSummaryRead => 'صفوف اتقرت';

  @override
  String get sheetSummaryAdded => 'صفوف اتضافت';

  @override
  String get sheetSummaryDuplicates => 'صفوف مكررة اتجاهلت';

  @override
  String get sheetSummaryInvalid => 'صفوف غلط اتجاهلت';

  @override
  String get sheetSummaryApproved => 'طلبات اتقبلت تلقائي';

  @override
  String get sheetProblemsTitle => 'الصفوف اللي اتجاهلت';

  @override
  String sheetProblemRow(String row, String reason) {
    return 'صف $row: $reason';
  }

  @override
  String get sheetReasonColumns => 'عدد الأعمدة غلط';

  @override
  String get sheetReasonCode => 'الكود مش صالح';

  @override
  String get sheetReasonType => 'النوع مش معروف';

  @override
  String get sheetReasonOther => 'الصف مش صالح';

  @override
  String get sheetErrBadColumns => 'الأعمدة مش زي المتوقع، ومفيش حاجة اتضافت.';

  @override
  String get sheetErrNoRows => 'مفيش صفوف صالحة في الملف، ومفيش حاجة اتضافت.';

  @override
  String get sheetErrRead => 'الملف ماتقراش. ممكن تجرب ملف CSV تاني.';

  @override
  String get sheetBatchesTitle => 'الرفعات اللي فاتت';

  @override
  String get sheetBatchesEmpty => 'لسه مفيش رفعات.';

  @override
  String sheetBatchLine(int added, int approved, int skipped) {
    return 'اتضاف $added، اتقبل $approved، اتجاهل $skipped';
  }

  @override
  String verifNoticeApproved(String date) {
    return 'تم قبول طلب التوثيق. متوثق لحد $date.';
  }

  @override
  String verifNoticeRejected(String reason) {
    return 'طلب التوثيق اترفض. السبب: $reason';
  }

  @override
  String get catalogueAvailabilityToday => 'المتاح النهارده';

  @override
  String get catalogueScheduleAction => 'عرض المواعيد';

  @override
  String get catalogueUpcomingTitle => 'حجوزاتك الجاية';

  @override
  String get catalogueUpcomingSeeAll => 'عرض الكل';

  @override
  String get catalogueUpcomingNone => 'مفيش حجوزات جاية. اختار منشأة وابدأ.';

  @override
  String catalogueBookingSpoken(
    String facility,
    String date,
    String time,
    String status,
  ) {
    return 'حجز في $facility، $date، الساعة $time، $status';
  }

  @override
  String get catalogueSuggestionsTitle => 'مقترحة ليك';

  @override
  String catalogueSuggestionReasonBookedType(String type) {
    return 'لأنك حجزت $type قبل كده';
  }

  @override
  String get catalogueSuggestionReasonOther => 'ممكن تعجبك';

  @override
  String get catalogueShareAction => 'مشاركة المنشأة';

  @override
  String get catalogueShareCopyLink => 'نسخ اللينك';

  @override
  String get catalogueShareCopied => 'اتنسخ اللينك';

  @override
  String catalogueShareText(String name) {
    return 'شوف $name على سبرنت';
  }

  @override
  String get bookingScheduleHeading => 'المواعيد';

  @override
  String get bookingRefreshAction => 'تحديث المواعيد';

  @override
  String get bookingContinue => 'متابعة';

  @override
  String get bookingUnitLabel => 'الوحدة';

  @override
  String bookingUnitHasPlaces(String unit) {
    return '$unit، فيه أماكن';
  }

  @override
  String bookingUnitNoPlaces(String unit) {
    return '$unit، مفيش أماكن في اليوم ده';
  }

  @override
  String get bookingNothingLeftDay =>
      'مفيش مواعيد فاضلة في اليوم ده، وفيه أيام تانية متاحة.';

  @override
  String get bookingNothingLeftWindow => 'مفيش مواعيد فاضلة في الأيام الجاية.';

  @override
  String get bookingNoUnitsTitle => 'مفيش مواعيد للحجز';

  @override
  String get bookingNoUnitsBody =>
      'المنشأة دي ملهاش مواعيد متاحة للحجز دلوقتي.';

  @override
  String get bookingBackToFacility => 'الرجوع للمنشأة';

  @override
  String get bookingErrorTitle => 'المواعيد متحمّلتش';

  @override
  String get bookingErrorBody => 'ممكن تكون مشكلة مؤقتة.';

  @override
  String get bookingRetry => 'إعادة المحاولة';

  @override
  String get bookingChoiceGone =>
      'الاختيار اللي فات مبقاش متاح، فدي أقرب مواعيد متاحة.';

  @override
  String get bookingNoticeDismiss => 'إغلاق الرسالة';

  @override
  String bookingRangeHint(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'الحجز بأول ساعة وآخر ساعة، لحد $hours ساعات متتالية',
      two: 'الحجز بأول ساعة وآخر ساعة، لحد ساعتين متتاليتين',
      one: 'الحجز هنا ساعة واحدة في المرة',
    );
    return '$_temp0';
  }

  @override
  String bookingLengthHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours ساعات',
      two: 'ساعتين',
      one: 'ساعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String bookingLengthMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String bookingTimeWithLength(String time, String length) {
    return 'الوقت $time، المدة $length';
  }

  @override
  String get bookingFree => 'مجاني';

  @override
  String get bookingPanelTitle => 'اختيارك';

  @override
  String get bookingSelectionPrompt => 'لسه مفيش ميعاد مختار';

  @override
  String get bookingGateReason => 'عشان تحجز';

  @override
  String get bookingFailSlotTaken =>
      'الميعاد ده اتحجز لسه. فيه مواعيد تانية متاحة.';

  @override
  String bookingFailSlotTakenAt(String time) {
    return 'الساعة $time اتحجزت لسه، فالنطاق ده مش متاح.';
  }

  @override
  String get bookingFailSlotFull =>
      'الميعاد ده اكتمل لسه. فيه مواعيد تانية متاحة.';

  @override
  String bookingFailSlotFullAt(String time) {
    return 'الساعة $time مكتملة، فالنطاق ده مش متاح.';
  }

  @override
  String get bookingFailSlotPast => 'وقت الميعاد ده فات.';

  @override
  String get bookingFailOutsideWindow => 'الحجز متاح للأيام القريبة بس.';

  @override
  String get bookingFailClosed => 'الميعاد ده مش متاح.';

  @override
  String bookingFailClosedAt(String time) {
    return 'الساعة $time مش متاحة، فالنطاق ده مش متاح.';
  }

  @override
  String bookingFailRangeTooLong(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'أقصى مدة للحجز $hours ساعات.',
      two: 'أقصى مدة للحجز ساعتين.',
      one: 'أقصى مدة للحجز ساعة واحدة.',
    );
    return '$_temp0';
  }

  @override
  String get bookingFailRangeTooLongGeneric => 'النطاق أطول من المسموح.';

  @override
  String bookingFailOverlap(String facility, String when) {
    return 'عندك حجز في نفس الوقت: $facility، $when.';
  }

  @override
  String get bookingFailOverlapGeneric => 'عندك حجز تاني في نفس الوقت.';

  @override
  String bookingFailTooMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'وصلت للحد الأقصى: $count حجوزات نشطة.',
      two: 'وصلت للحد الأقصى: حجزين نشطين.',
      one: 'وصلت للحد الأقصى: حجز نشط واحد.',
    );
    return '$_temp0';
  }

  @override
  String get bookingFailTooManyGeneric => 'وصلت للحد الأقصى للحجوزات النشطة.';

  @override
  String get bookingFailNotPermitted => 'الحساب ده مش مسموحله يحجز.';

  @override
  String get bookingFailNotFound => 'المنشأة أو الميعاد مش متاحين دلوقتي.';

  @override
  String get bookingFailGeneric => 'الحجز متمّش. المحاولة تاني ممكنة.';

  @override
  String get bookingSummaryTitle => 'ملخص الحجز';

  @override
  String get bookingRowFacility => 'المنشأة';

  @override
  String get bookingRowUnit => 'الوحدة';

  @override
  String get bookingRowDate => 'اليوم';

  @override
  String get bookingRowTime => 'الوقت';

  @override
  String get bookingRowLength => 'المدة';

  @override
  String get bookingRowCoverage => 'الحجز يشمل';

  @override
  String get bookingRowTrainer => 'المدرب';

  @override
  String get bookingRowTier => 'الشريحة';

  @override
  String get bookingRowPrice => 'السعر';

  @override
  String get bookingRowPolicy => 'سياسة الإلغاء';

  @override
  String get bookingCoverageWhole => 'الوحدة كلها';

  @override
  String bookingCoverageWholeMax(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الوحدة كلها، لحد $count مشارك',
      two: 'الوحدة كلها، لحد مشاركين',
      one: 'الوحدة كلها، لمشارك واحد',
    );
    return '$_temp0';
  }

  @override
  String get bookingCoverageOnePlace => 'مكان واحد';

  @override
  String bookingSessionLength(int minutes) {
    return 'حصة $minutes دقيقة';
  }

  @override
  String bookingPolicyCutoff(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'الإلغاء متاح لحد $hours ساعات قبل الميعاد.',
      two: 'الإلغاء متاح لحد ساعتين قبل الميعاد.',
      one: 'الإلغاء متاح لحد ساعة قبل الميعاد.',
      zero: 'الإلغاء متاح لحد وقت الميعاد.',
    );
    return '$_temp0';
  }

  @override
  String get bookingPolicyRefundFull => 'المبلغ بيرجع كامل.';

  @override
  String bookingPolicyRefundPartial(int percent) {
    return 'بيرجع $percent% من المبلغ.';
  }

  @override
  String get bookingPolicyRefundNone => 'المبلغ مش بيرجع.';

  @override
  String get bookingVerifyHint => 'توثيق الحساب بيدّي سعر الطلاب والعاملين.';

  @override
  String get bookingVerifyAction => 'طلب توثيق';

  @override
  String get bookingVerifyPending =>
      'طلب التوثيق قيد المراجعة. السعر الداخلي بيسري على الحجوزات الجديدة بعد الموافقة.';

  @override
  String get bookingPriceChanged =>
      'السعر اتغيّر عن اللي ظهر في المواعيد. ده السعر الحالي.';

  @override
  String get bookingPayAction => 'متابعة للدفع';

  @override
  String get bookingConfirmAction => 'تأكيد الحجز';

  @override
  String get bookingFreeNoPayment => 'الحجز مجاني ومفيش خطوة دفع.';

  @override
  String get bookingCheckoutSoonTitle => 'الدفع قريبًا';

  @override
  String get bookingCheckoutSoonBody =>
      'خطوة الدفع هتتضاف قريب. اختيارك محفوظ في الملخص.';

  @override
  String get bookingBackToSummary => 'الرجوع للملخص';

  @override
  String get bookingDoneTitle => 'الحجز اتأكد';

  @override
  String get bookingDoneBody => 'الحجز متسجل على حسابك، وهيظهر في الرئيسية.';

  @override
  String get bookingDoneCode => 'رقم الحجز';

  @override
  String get bookingDoneHome => 'الرجوع للرئيسية';

  @override
  String get bookingDoneNotFoundTitle => 'الحجز مش موجود';

  @override
  String get bookingDoneNotFoundBody =>
      'ممكن يكون اللينك غلط أو الحجز تبع حساب تاني.';

  @override
  String get bookingTrainerStepTitle => 'اختيار المدرب';

  @override
  String get bookingTrainerStepBody => 'المواعيد بتظهر بعد اختيار المدرب.';

  @override
  String get bookingTrainerHasSessions => 'عنده حصص في الأيام الجاية';

  @override
  String get bookingTrainerNoSessions => 'مفيش حصص في الأيام الجاية';

  @override
  String get bookingTrainerNoName => 'مدرب';

  @override
  String get bookingTrainerChange => 'تغيير المدرب';

  @override
  String bookingTrainerChosen(String name) {
    return 'المدرب: $name';
  }

  @override
  String get bookingNoTrainersTitle => 'مفيش مدربين متاحين';

  @override
  String get bookingNoTrainersBody => 'المنشأة دي لسه ملهاش مدربين للحجز.';

  @override
  String get bookingTrainerNoSessionsBody =>
      'المدرب ده ملوش حصص في الأيام الجاية.';

  @override
  String bookingTrainerRowSpoken(String name, String bio, String sessions) {
    return 'المدرب $name، $bio، $sessions';
  }

  @override
  String get checkoutTitle => 'الدفع';

  @override
  String get checkoutHoldTitle => 'المكان متحجز لك لحد ما الدفع يخلص';

  @override
  String checkoutHoldRemaining(String time) {
    return 'فاضل $time دقيقة، وبعدها المكان يرجع متاح';
  }

  @override
  String get checkoutLastMinuteTitle => 'المهلة على وشك تخلص';

  @override
  String checkoutLastMinuteBody(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'فاضل $seconds ثانية، وبعدها المكان يرجع متاح',
      two: 'فاضل ثانيتين، وبعدها المكان يرجع متاح',
      one: 'فاضل ثانية واحدة، وبعدها المكان يرجع متاح',
    );
    return '$_temp0';
  }

  @override
  String get checkoutTierInternal => 'داخلي · موثّق';

  @override
  String get checkoutTierExternal => 'خارجي · السعر الكامل';

  @override
  String get checkoutPolicyTitle => 'سياسة الإلغاء';

  @override
  String checkoutPolicyBody(String until, String hours, int percent) {
    return 'الإلغاء متاح لحد $until ($hours قبل الميعاد) والفلوس بترجع $percent% على نفس وسيلة الدفع. بعد كده زرار الإلغاء بيختفي.';
  }

  @override
  String get checkoutRowTime => 'الميعاد';

  @override
  String get checkoutRowTotal => 'الإجمالي';

  @override
  String get checkoutMethodTitle => 'الدفع الإلكتروني';

  @override
  String get checkoutMethodSubtitle =>
      'بطاقة بنكية أو محفظة موبايل · صفحة المزوّد الآمنة';

  @override
  String get checkoutSandboxTag => 'وضع الاختبار · مفيش فلوس حقيقية بتتخصم';

  @override
  String checkoutPay(String amount) {
    return 'الدفع · $amount';
  }

  @override
  String checkoutPaySpoken(int amount) {
    return 'الدفع، $amount جنيه';
  }

  @override
  String get checkoutStartError =>
      'بدء الدفع ماتمّش. المكان لسه متحجز لك، وممكن تحاول تاني.';

  @override
  String get checkoutFailedTitle => 'الدفع ماتمّش. ممكن تحاول تاني';

  @override
  String get checkoutFailedBody => 'المكان لسه متحجز لك لحد ما المهلة تخلص.';

  @override
  String checkoutRetry(String amount) {
    return 'إعادة المحاولة · $amount';
  }

  @override
  String get holdExpiredTitle => 'المهلة خلصت';

  @override
  String get holdExpiredBody =>
      'المكان رجع متاح للناس. ممكن تختار الميعاد من جديد.';

  @override
  String get holdExpiredPickAnother => 'اختيار ميعاد تاني';

  @override
  String get checkoutLeaveTitle => 'ترك الدفع؟';

  @override
  String get checkoutLeaveBody =>
      'لو سبت الصفحة دلوقتي، المكان بيرجع متاح للناس.';

  @override
  String get checkoutLeaveConfirm => 'ترك الدفع';

  @override
  String get checkoutLeaveStay => 'إكمال الدفع';

  @override
  String get checkoutCancelledTitle => 'الدفع اتلغى';

  @override
  String get checkoutCancelledBody => 'المكان لسه متحجز لك، وممكن تحاول تاني';

  @override
  String get gatewayTitle => 'الدفع الآمن';

  @override
  String get gatewayHoldTitle => 'المكان متحجز لك';

  @override
  String gatewayHoldBody(String time) {
    return 'فاضل $time دقيقة لإكمال الدفع';
  }

  @override
  String get gatewayAmountLabel => 'المبلغ المطلوب';

  @override
  String gatewayMerchant(String facility) {
    return 'سبرنت · $facility';
  }

  @override
  String get gatewayCardNumber => 'رقم البطاقة';

  @override
  String get gatewayCardExpiry => 'تاريخ الانتهاء';

  @override
  String get gatewayCardCvc => 'رمز الأمان';

  @override
  String get gatewayCardName => 'اسم حامل البطاقة';

  @override
  String get gatewayCardNameHint => 'الاسم زي ما هو على البطاقة';

  @override
  String get gatewayNotice =>
      'الصفحة دي بتاعة مزوّد الدفع. بعد التأكيد بنرجعلك للتطبيق';

  @override
  String gatewayConfirm(String amount) {
    return 'تأكيد الدفع · $amount';
  }

  @override
  String get gatewayCancel => 'إلغاء';

  @override
  String get gatewayErrCardNumber => 'رقم البطاقة مش صحيح';

  @override
  String get gatewayErrExpiry => 'تاريخ الانتهاء مش صحيح أو فات';

  @override
  String get gatewayErrCvc => 'رمز الأمان لازم يكون 3 أو 4 أرقام';

  @override
  String get gatewayErrName => 'اسم حامل البطاقة مطلوب';

  @override
  String get gatewayExpiryHint => 'MM / YY';

  @override
  String get gatewayCvcHint => '000';

  @override
  String get processingTitle => 'بنأكد الدفع';

  @override
  String get processingBody =>
      'التأكيد بييجي من مزوّد الدفع وممكن ياخد لحظات، والأحسن إن الشاشة تفضل مفتوحة';

  @override
  String processingHeld(String time) {
    return 'المكان متحجز لك، فاضل $time دقيقة';
  }

  @override
  String get awaitingTitle => 'لسه مستنيين تأكيد الدفع';

  @override
  String get awaitingBody =>
      'لو الخصم حصل ومتأكدش الحجز، الفلوس بترجع لوحدها. المكان متحجز لك لحد ما التأكيد يوصل';

  @override
  String get awaitingRefresh => 'تحديث الحالة';

  @override
  String get awaitingRefreshing => 'جاري تحديث الحالة';

  @override
  String get awaitingBackToBookings => 'الرجوع للحجوزات';

  @override
  String get receiptTitle => 'إيصال دفع';

  @override
  String get receiptNumber => 'رقم الإيصال';

  @override
  String get receiptBookingCode => 'رقم الحجز';

  @override
  String get receiptDate => 'التاريخ';

  @override
  String get receiptUnit => 'الوحدة';

  @override
  String get receiptTier => 'الشريحة';

  @override
  String get receiptMethod => 'وسيلة الدفع';

  @override
  String receiptMethodCard(String last4) {
    return 'بطاقة تنتهي بـ $last4 · اختبار';
  }

  @override
  String get receiptTotalPaid => 'الإجمالي المدفوع';

  @override
  String get receiptRefund => 'المبلغ المسترد';

  @override
  String get receiptSave => 'حفظ الإيصال PDF';

  @override
  String get receiptShare => 'مشاركة الإيصال';

  @override
  String get receiptNavTitle => 'الإيصال';

  @override
  String get receiptPdfFailed => 'الـ PDF ماتعملش. اتشاركت نسخة نصية بدله';

  @override
  String get receiptNotFoundTitle => 'الإيصال مش موجود';

  @override
  String get receiptNotFoundBody =>
      'مفيش إيصال للحجز ده. الإيصال بيظهر بعد دفع ناجح.';

  @override
  String get confirmedTitle => 'حجزك اتأكد';

  @override
  String confirmedSubtitle(String lead) {
    return 'وصلك إشعار بالتفاصيل، وهنفكرك قبل الميعاد بـ$lead.';
  }

  @override
  String get confirmedReceiptRow => 'إيصال الدفع';

  @override
  String leadHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours ساعات',
      two: 'ساعتين',
      one: 'ساعة',
    );
    return '$_temp0';
  }

  @override
  String leadHoursHalf(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours ساعات ونص',
      two: 'ساعتين ونص',
      one: 'ساعة ونص',
      zero: 'نص ساعة',
    );
    return '$_temp0';
  }

  @override
  String leadMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes دقيقة',
      two: 'دقيقتين',
      one: 'دقيقة',
    );
    return '$_temp0';
  }

  @override
  String get demoPaymentTitle => 'الدفع التجريبي';

  @override
  String get demoPaymentNote =>
      'بيحدد اللي هيحصل لما صفحة المزوّد تأكد الدفع. للعرض بس.';

  @override
  String get demoPaymentSuccess => 'نجاح';

  @override
  String get demoPaymentFail => 'فشل';

  @override
  String get demoPaymentDelay => 'تأخير';

  @override
  String demoPaymentDelayPreset(int seconds) {
    return '$seconds ثانية';
  }

  @override
  String get demoPaymentDelayAfterMax => 'بعد الحد الأقصى';

  @override
  String demoPaymentCurrent(String value) {
    return 'الاختيار الحالي: $value';
  }

  @override
  String demoPaymentDelayCurrent(int seconds) {
    return 'تأخير $seconds ثانية، وبعدها نجاح';
  }

  @override
  String get ticketQrLabel => 'رمز الحضور، بيتعرض للمدرب عند الدخول';

  @override
  String get splashTagline => 'احجز من غير زحمة';

  @override
  String get splashCaption => 'جامعة طنطا';

  @override
  String get notificationBellLabel => 'الإشعارات';

  @override
  String notificationBellLabelUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إشعارات جديدة',
      two: 'إشعارين جدد',
      one: 'إشعار جديد واحد',
    );
    return 'الإشعارات، $_temp0';
  }

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonBack => 'رجوع';

  @override
  String lockedFieldReadOnly(String reason) {
    return 'للقراءة فقط، $reason';
  }

  @override
  String get lockedFieldIcon => 'مقفول';

  @override
  String get searchClear => 'مسح البحث';

  @override
  String get popoverClose => 'إغلاق القائمة';

  @override
  String get dialogConfirmDestructive => 'تأكيد';

  @override
  String get gallery007Section => 'جزء حجوزاتي والإشعارات والحساب';

  @override
  String get gallery007SampleTitle => 'تم تأكيد حجزك';

  @override
  String get gallery007SampleBody => 'حمام السباحة الأولمبي · حارة 2';

  @override
  String get gallery007SampleTime => '4:00 م';

  @override
  String get gallery007SampleDate => 'الخميس 12 نوفمبر · 6:00 – 8:00 م';

  @override
  String get gallery007SampleAction => 'عرض التذكرة';

  @override
  String get gallery007SampleUpcoming => 'الجاية (3)';

  @override
  String get gallery007SamplePast => 'اللي فاتت';

  @override
  String get gallery007SampleLanguage => 'اللغة';

  @override
  String get gallery007SampleLanguageValue => 'العربية';

  @override
  String get gallery007SampleSignOut => 'تسجيل الخروج';

  @override
  String get gallery007SampleName => 'منى سالم';

  @override
  String get gallery007SampleLockedHelper =>
      'مربوط بتسجيل الدخول ومش بيتعدل من هنا';

  @override
  String get gallery007SampleBanner =>
      'الحجز اتلغى. الفلوس هترجع على نفس وسيلة الدفع.';

  @override
  String get gallery007OpenDialog => 'فتح نافذة التأكيد';

  @override
  String get gallery007DialogTitle => 'إلغاء الحجز؟';

  @override
  String get gallery007DialogBack => 'الرجوع';

  @override
  String get gallery007OpenPopover => 'فتح القائمة';

  @override
  String get gallery007SampleSearch => 'بحث';

  @override
  String get gallery007SampleSearchCancel => 'إلغاء';

  @override
  String get gallery007SampleEmailLabel => 'الإيميل';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get catalogueFacilitiesTitle => 'كل المنشآت';

  @override
  String get bookingsTitle => 'حجوزاتي';

  @override
  String bookingsSegmentUpcoming(int count) {
    return 'الجاية ($count)';
  }

  @override
  String get bookingsSegmentUpcomingPlain => 'الجاية';

  @override
  String get bookingsSegmentPast => 'اللي فاتت';

  @override
  String bookingsSegmentUpcomingSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حجوزات',
      two: 'حجزين',
      one: 'حجز واحد',
    );
    return 'الجاية، $_temp0';
  }

  @override
  String get bookingsEmptyTitle => 'لسه مفيش حجوزات.';

  @override
  String get bookingsEmptyBody => 'المنشآت مستنياك';

  @override
  String get bookingsUpcomingEmptyTitle => 'مفيش حجوزات جاية';

  @override
  String get bookingsUpcomingEmptyBody =>
      'حجوزاتك القديمة موجودة في \"اللي فاتت\".';

  @override
  String get bookingsPastEmptyTitle => 'مفيش حجوزات سابقة';

  @override
  String get bookingsBrowse => 'استعراض المنشآت';

  @override
  String get bookingsNoneSelected => 'مفيش حجز محدد';

  @override
  String get bookingsActionTicket => 'عرض التذكرة';

  @override
  String get bookingsActionPay => 'إكمال الدفع';

  @override
  String get bookingsActionDetails => 'التفاصيل';

  @override
  String get bookingsToday => 'النهارده';

  @override
  String get bookingsNoteFree => 'مجاني';

  @override
  String bookingsNoteTrainer(String name) {
    return 'مع $name';
  }

  @override
  String bookingsNoteHold(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فاضل $count دقايق للدفع',
      two: 'فاضل دقيقتين للدفع',
      one: 'فاضل دقيقة للدفع',
    );
    return '$_temp0';
  }

  @override
  String bookingsRowSpoken(
    String status,
    String date,
    String facility,
    String notes,
    String code,
    String action,
  ) {
    return '$status، $date، $facility، $notes، رقم الحجز $code، $action';
  }

  @override
  String get bookingsLoadError => 'مقدرناش نحمّل حجوزاتك.';

  @override
  String get bookingsRetry => 'إعادة المحاولة';

  @override
  String get bookingDetailsTitle => 'تفاصيل الحجز';

  @override
  String get bookingDetailsNotFoundTitle => 'الحجز مش موجود';

  @override
  String get bookingDetailsNotFoundBody => 'مش لاقيين الحجز ده في حجوزاتك.';

  @override
  String get bookingDetailsBackToBookings => 'العودة للحجوزات';

  @override
  String get bookingDetailsTier => 'الشريحة';

  @override
  String get bookingDetailsTierInternal => 'داخلي';

  @override
  String get bookingDetailsTierExternal => 'خارجي';

  @override
  String get bookingDetailsPaid => 'المدفوع';

  @override
  String get bookingDetailsAmount => 'المبلغ';

  @override
  String get bookingDetailsRequired => 'المطلوب';

  @override
  String get bookingDetailsNotPaid => 'ما اتدفعش';

  @override
  String get bookingDetailsPrice => 'السعر';

  @override
  String get bookingDetailsFree => 'مجاني';

  @override
  String get bookingDetailsCode => 'رقم الحجز';

  @override
  String get bookingDetailsCancel => 'إلغاء الحجز';

  @override
  String bookingDetailsPay(String amount) {
    return 'إكمال الدفع · $amount';
  }

  @override
  String get bookingDetailsReceipt => 'إيصال الدفع';

  @override
  String get bookingDetailsHoldTitle => 'المكان متحجز لك';

  @override
  String bookingDetailsHoldSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فاضل $count دقايق للدفع، وبعدها المكان يرجع متاح',
      two: 'فاضل دقيقتين للدفع، وبعدها المكان يرجع متاح',
      one: 'فاضل دقيقة للدفع، وبعدها المكان يرجع متاح',
    );
    return '$_temp0';
  }

  @override
  String bookingDetailsAfterCutoff(String when) {
    return 'الإلغاء كان متاح لحد $when، وبعده زرار الإلغاء بيختفي.';
  }

  @override
  String get bookingDetailsAttended => 'تم تسجيل حضورك. شكرًا لاستخدامك سبرنت';

  @override
  String get bookingDetailsNoShow =>
      'الحجز ده عدّى من غير حضور. مفيش أي رسوم أو عقوبة';

  @override
  String get bookingDetailsExpired =>
      'المهلة خلصت من غير دفع، والمكان رجع متاح';

  @override
  String get bookingDetailsCancelledByYou => 'الحجز اتلغى.';

  @override
  String get bookingDetailsCancelledByFacility => 'لغته إدارة المنشأة.';

  @override
  String bookingDetailsCancelReason(String reason) {
    return 'السبب: $reason';
  }

  @override
  String bookingDetailsFacilityRefund(String amount) {
    return 'الـ $amount رجعت كاملة، واتبلّغت فورًا.';
  }

  @override
  String bookingDetailsRefundFull(String amount) {
    return 'الـ $amount هترجع على نفس وسيلة الدفع.';
  }

  @override
  String bookingDetailsRefundPartial(String refund, String paid) {
    return 'هيرجع $refund من $paid على نفس وسيلة الدفع.';
  }

  @override
  String get bookingDetailsRefundNone => 'مفيش مبلغ هيرجع.';

  @override
  String get bookingDetailsFreeCancelled =>
      'الحجز كان مجاني، والمكان رجع متاح.';

  @override
  String get bookingDetailsPendingCancelled => 'الحجز اتلغى ومفيش فلوس اتسحبت.';

  @override
  String bookingTicketSpoken(String status, String facility, String date) {
    return 'حجز $status، $facility، $date';
  }

  @override
  String get cancelDialogTitle => 'إلغاء الحجز؟';

  @override
  String get cancelActionConfirm => 'إلغاء الحجز';

  @override
  String get cancelActionBack => 'الرجوع';

  @override
  String cancelMessageFull(String amount) {
    return 'هترجع $amount كاملة على نفس وسيلة الدفع.';
  }

  @override
  String cancelMessagePartial(String refund, String paid) {
    return 'هيرجع $refund من $paid على نفس وسيلة الدفع.';
  }

  @override
  String get cancelMessageNone =>
      'الإلغاء دلوقتي من غير استرداد، ومفيش مبلغ هيرجع.';

  @override
  String get cancelMessageFree =>
      'الحجز مجاني، فمفيش مبلغ يرجع. المكان هيرجع متاح لغيرك.';

  @override
  String get cancelMessagePending => 'هنلغي الحجز ومفيش فلوس اتسحبت.';

  @override
  String get cancelClosedTitle => 'فات وقت الإلغاء';

  @override
  String cancelClosedBody(String when) {
    return 'الإلغاء كان متاح لحد $when.';
  }

  @override
  String get cancelAlreadyTitle => 'الحجز ده اتلغى قبل كده';

  @override
  String get cancelFailed => 'الإلغاء ماتمش والحجز زي ما هو.';

  @override
  String get cancelNotAllowedBody => 'الحجز ده مينفعش يتلغي دلوقتي.';

  @override
  String get cancelResultTitle => 'الحجز اتلغى';

  @override
  String get cancelResultBack => 'العودة للحجوزات';
}
