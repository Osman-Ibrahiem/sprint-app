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
}
