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
  String get noAccessTitle => 'This page isn\'t available for your account';

  @override
  String get noAccessBody =>
      'This page is for other permissions. If you need access, you can contact the university administrator.';

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

  @override
  String get dayShortSaturday => 'Sat';

  @override
  String get dayShortSunday => 'Sun';

  @override
  String get dayShortMonday => 'Mon';

  @override
  String get dayShortTuesday => 'Tue';

  @override
  String get dayShortWednesday => 'Wed';

  @override
  String get dayShortThursday => 'Thu';

  @override
  String get dayShortFriday => 'Fri';

  @override
  String get dayFullSaturday => 'Saturday';

  @override
  String get dayFullSunday => 'Sunday';

  @override
  String get dayFullMonday => 'Monday';

  @override
  String get dayFullTuesday => 'Tuesday';

  @override
  String get dayFullWednesday => 'Wednesday';

  @override
  String get dayFullThursday => 'Thursday';

  @override
  String get dayFullFriday => 'Friday';

  @override
  String get demoTitle => 'Demo screen';

  @override
  String get demoColours => 'Colours';

  @override
  String get demoTypography => 'Type';

  @override
  String get demoSpacing => 'Spacing';

  @override
  String get demoRadius => 'Radius';

  @override
  String get demoControls => 'Platform controls';

  @override
  String get demoTypeSample => 'Sprint – booking confirmed 120';

  @override
  String get demoAppBarTrigger => 'Show large-title app bar';

  @override
  String get demoLargeTitle => 'Large title';

  @override
  String get demoDialogTrigger => 'Show confirmation dialog';

  @override
  String get demoDialogTitle => 'Cancel this booking?';

  @override
  String get demoDialogMessage => 'The place will open up for others.';

  @override
  String get demoDialogConfirm => 'Cancel booking';

  @override
  String get demoDialogKeep => 'Keep booking';

  @override
  String get demoSheetTrigger => 'Show actions';

  @override
  String get demoSheetTitle => 'Booking actions';

  @override
  String get demoSheetShare => 'Share';

  @override
  String get demoSheetCalendar => 'Add to calendar';

  @override
  String get demoSheetClose => 'Close';

  @override
  String get demoSwitchLabel => 'Reminders';

  @override
  String get demoLoaderLabel => 'Loading';

  @override
  String demoResult(String value) {
    return 'Last choice: $value';
  }

  @override
  String get demoResultNone => 'Nothing chosen yet';

  @override
  String get demoAppearance => 'Appearance and language';

  @override
  String get roleBooker => 'Booker';

  @override
  String get roleTrainer => 'Trainer';

  @override
  String get roleFacilityManager => 'Facility manager';

  @override
  String get roleVerifier => 'Verifier';

  @override
  String get roleUnitAdmin => 'Unit admin';

  @override
  String get roleSuperAdmin => 'Super admin';

  @override
  String get roleViewer => 'Viewer';

  @override
  String get tierInternal => 'Internal price';

  @override
  String get tierExternal => 'Full price';

  @override
  String profileRoles(String roles) {
    return 'Roles: $roles';
  }

  @override
  String profileTier(String tier) {
    return 'Tier: $tier';
  }

  @override
  String get demoUserTitle => 'View as another user';

  @override
  String get demoUserNote => 'For reviewers only. There is no real sign-in.';

  @override
  String get demoGuest => 'Guest (no account)';

  @override
  String get demoSettingsTitle => 'Settings and inheritance';

  @override
  String get demoSettingsPick => 'Choose a unit';

  @override
  String demoSettingsUnit(String unit) {
    return 'Unit: $unit';
  }

  @override
  String get levelUnit => 'Unit';

  @override
  String get levelFacility => 'Facility';

  @override
  String get levelUniversity => 'University';

  @override
  String get levelDefault => 'Default';

  @override
  String get demoNoLimit => 'No limit';

  @override
  String demoSettingsLevel(String level) {
    return 'From: $level';
  }

  @override
  String demoSwatchLabel(String name) {
    return '$name, light and dark';
  }

  @override
  String get buttonDisabledSuffix => ', unavailable';

  @override
  String get buttonBusy => 'Working…';

  @override
  String get fieldShowPassword => 'Show';

  @override
  String get fieldHidePassword => 'Hide';

  @override
  String get codeEntryLabel => 'Confirmation code';

  @override
  String get codeEntrySentTo => 'The code was sent to';

  @override
  String get codeEntryResend => 'Resend the code';

  @override
  String codeEntryResendIn(int seconds) {
    return 'Resend the code in $seconds s';
  }

  @override
  String get fieldSearchHint => 'Search';

  @override
  String slotAvailablePlaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String get slotSelected => 'Selected';

  @override
  String slotFewLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places left',
      one: '1 place left',
    );
    return '$_temp0';
  }

  @override
  String slotFewLeftSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places left',
      one: 'one place left',
    );
    return '$_temp0';
  }

  @override
  String get slotFull => 'Full';

  @override
  String get slotPast => 'Past';

  @override
  String slotSpoken(String time, String state) {
    return 'At $time, $state';
  }

  @override
  String slotSpokenWithPrice(String time, String state, String price) {
    return 'At $time, $state, $price';
  }

  @override
  String get dayToday => 'Today';

  @override
  String get dayHasRoom => 'Places available';

  @override
  String get dayClosed => 'Closed';

  @override
  String daySpoken(String day, String state) {
    return 'Day $day, $state';
  }

  @override
  String statusSpoken(String status) {
    return 'Status: $status';
  }

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPendingPayment => 'Awaiting payment';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusAttended => 'Attended';

  @override
  String get statusNoShow => 'No-show';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusUnderReview => 'Under review';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get facilityPhotoPlaceholder => 'Facility photo';

  @override
  String get facilityTrainerTag => 'With trainer';

  @override
  String get facilityFreeTag => 'Free';

  @override
  String facilityUnitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units',
      one: '1 unit',
    );
    return '$_temp0';
  }

  @override
  String get facilityAvailabilityPlenty => 'Available today';

  @override
  String get facilityAvailabilityFew => 'Few places left';

  @override
  String get facilityAvailabilityNone => 'No slots today';

  @override
  String get facilityPriceInternalLabel => 'Student and staff price';

  @override
  String get facilityPriceExternalLabel => 'Full price';

  @override
  String get facilityFree => 'Free';

  @override
  String facilitySpoken(
    String name,
    String unit,
    String availability,
    String price,
  ) {
    return 'Facility $name, $unit, $availability, $price';
  }

  @override
  String get ticketCodeLabel => 'Booking code';

  @override
  String get ticketCopied => 'Copied';

  @override
  String get ticketPaid => 'Paid';

  @override
  String ticketCancelUntil(String date) {
    return 'Free cancellation until $date';
  }

  @override
  String get ticketCancelUnavailable => 'Cancellation unavailable';

  @override
  String get ticketQrUnavailable => 'QR unavailable';

  @override
  String ticketSpoken(
    String facility,
    String dateTime,
    String status,
    String code,
  ) {
    return 'Ticket $facility, $dateTime, $status, $code';
  }

  @override
  String get navMore => 'More';

  @override
  String navBadgeSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread',
      one: '1 unread',
    );
    return '$_temp0';
  }

  @override
  String statDeltaUp(String value) {
    return 'Up $value';
  }

  @override
  String statDeltaDown(String value) {
    return 'Down $value';
  }

  @override
  String get statDeltaFlat => 'No change';

  @override
  String get statNoComparison => 'No comparison';

  @override
  String get logoLabel => 'Sprint';

  @override
  String get galleryTitle => 'Component gallery';

  @override
  String get gallerySampleNote => 'Sample data';

  @override
  String get galleryTextSize => 'Text size';

  @override
  String get galleryReducedMotion => 'Reduced motion';

  @override
  String get galleryPlatformLook => 'Platform look';

  @override
  String get galleryPlatformApple => 'Apple';

  @override
  String get galleryPlatformAndroid => 'Android';

  @override
  String get galleryPlatformDesktop => 'Desktop';

  @override
  String get galleryOpenFromDemo => 'Component gallery';

  @override
  String get galleryButtonSection => 'Buttons';

  @override
  String get galleryTextFieldSection => 'Text fields';

  @override
  String get gallerySlotChipSection => 'Slot chips';

  @override
  String get galleryDayStripSection => 'Day strip';

  @override
  String get galleryStatusBadgeSection => 'Status badges';

  @override
  String get galleryFacilityCardSection => 'Facility cards';

  @override
  String get galleryBookingTicketSection => 'Booking tickets';

  @override
  String get galleryNavigationSection => 'Navigation';

  @override
  String get galleryStatTileSection => 'Stat tiles';

  @override
  String get galleryLogoSection => 'Logo';

  @override
  String get timeAm => 'AM';

  @override
  String get timePm => 'PM';

  @override
  String get slotAvailableWord => 'Available';
}
