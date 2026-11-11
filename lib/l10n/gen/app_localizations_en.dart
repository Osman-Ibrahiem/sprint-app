// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sprint';

  @override
  String get navHome => 'Home';

  @override
  String get navFacilities => 'Facilities';

  @override
  String get navBookings => 'My bookings';

  @override
  String get navProfile => 'Profile';

  @override
  String get navMainLabel => 'Main navigation';

  @override
  String get placeholderNote => 'This screen is still being built.';

  @override
  String get homeIntro =>
      'Nearby facilities and upcoming slots will show up here.';

  @override
  String get facilitiesIntro =>
      'All the university\'s sports facilities in one place.';

  @override
  String get facilitiesSearchHint => 'Search facilities';

  @override
  String get signInPromptTitle => 'Sign-in needed';

  @override
  String get signInPromptBody =>
      'Your bookings and account details will show here once you sign in. Sign-in isn\'t available in this version yet.';

  @override
  String get notFoundTitle => 'This page doesn\'t exist';

  @override
  String get notFoundBody => 'The link may have changed or been typed wrong.';

  @override
  String get backToHome => 'Back to home';

  @override
  String get homeTitle => 'Welcome to Sprint';

  @override
  String get facilitiesTitle => 'University facilities';

  @override
  String priceEgp(String amount) {
    return 'EGP $amount';
  }

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceSystem => 'Match device';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageAr => 'العربية';

  @override
  String get languageEn => 'English';

  @override
  String get demoEntry => 'Reviewer demo screen';

  @override
  String get optionSelected => 'Selected';
}
