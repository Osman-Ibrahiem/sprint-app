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
}
