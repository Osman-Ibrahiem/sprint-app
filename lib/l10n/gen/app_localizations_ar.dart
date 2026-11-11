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
}
