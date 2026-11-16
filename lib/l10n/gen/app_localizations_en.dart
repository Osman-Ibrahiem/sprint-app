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

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInIdentifierLabel => 'Email or mobile number';

  @override
  String get signInPasswordLabel => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signInBadCredentials => 'The sign-in details are not correct';

  @override
  String signInLocked(int minutes) {
    return 'Too many attempts. Sign in is paused, and you can try again in $minutes minutes.';
  }

  @override
  String get signInSuspended =>
      'This account is suspended. You can contact the university administration.';

  @override
  String get signInUnexpected =>
      'Something unexpected went wrong. You can try again in a moment.';

  @override
  String get signInForgot => 'Forgot your password?';

  @override
  String get signInCreateAccount => 'Create an account';

  @override
  String get forgotTitle => 'Reset password';

  @override
  String get forgotIntro =>
      'Enter the email or mobile number on the account, and we\'ll send a code to the account\'s email.';

  @override
  String get forgotSendButton => 'Send code';

  @override
  String get resetTitle => 'Choose a new password';

  @override
  String get resetSentNeutral =>
      'If the account exists, a code is on its way to the registered email.';

  @override
  String get resetNewPasswordLabel => 'New password';

  @override
  String get resetPasswordHint =>
      'At least 8 characters, with a letter and a digit';

  @override
  String get resetSaveButton => 'Save password';

  @override
  String resetCodeWrong(int tries) {
    return 'That code is wrong. Tries left: $tries.';
  }

  @override
  String get resetCodeExpired =>
      'This code has expired. You can ask for a new one.';

  @override
  String get resetCodeDead =>
      'No tries left on this code. You can ask for a new one.';

  @override
  String resetResendTooSoon(int seconds) {
    return 'You can ask for a new code in $seconds seconds.';
  }

  @override
  String get resetPasswordEmpty => 'A new password is required.';

  @override
  String get resetPasswordTooShort =>
      'The password needs at least 8 characters.';

  @override
  String get resetPasswordNeedsLetter =>
      'The password needs at least one letter.';

  @override
  String get resetPasswordNeedsDigit =>
      'The password needs at least one digit.';

  @override
  String get signOutTitle => 'Confirm sign out';

  @override
  String get signOutBody =>
      'You can keep browsing as a guest and sign in again at any time.';

  @override
  String get signOutConfirm => 'Sign out';

  @override
  String get signOutKeep => 'Stay signed in';

  @override
  String accountCardSpoken(String name, String tier) {
    return 'Your account: $name, $tier';
  }

  @override
  String get signUpTitle => 'Create an account';

  @override
  String get signUpButton => 'Create account';

  @override
  String get signUpNameLabel => 'Full name';

  @override
  String get signUpNameHelper => 'First and family name at least';

  @override
  String get signUpPhoneLabel => 'Mobile number';

  @override
  String get signUpPhoneHelper => 'An Egyptian number, for example 01012345678';

  @override
  String get signUpEmailLabel => 'Email';

  @override
  String get signUpEmailHelper =>
      'We\'ll send the account confirmation code here';

  @override
  String get signUpPasswordLabel => 'Password';

  @override
  String get signUpPasswordHelper =>
      'At least 8 characters, with a letter and a digit';

  @override
  String get signUpAlreadyHave => 'Already have an account?';

  @override
  String get validationNameEmpty => 'The name is required.';

  @override
  String get validationNameTooShort => 'The name is too short.';

  @override
  String get validationNameTooLong =>
      'The name is too long, 60 characters at most.';

  @override
  String get validationNameNeedsTwoWords =>
      'The name needs at least two words, first and family name.';

  @override
  String get validationNameInvalidCharacters =>
      'The name takes letters and spaces only.';

  @override
  String get validationPhoneEmpty => 'The mobile number is required.';

  @override
  String get validationPhoneInvalid =>
      'The mobile number must be 11 digits starting with 010, 011, 012 or 015.';

  @override
  String get validationEmailEmpty => 'The email is required.';

  @override
  String get validationEmailInvalid =>
      'The email is not written correctly, for example name@example.com.';

  @override
  String get validationPasswordEmpty => 'The password is required.';

  @override
  String get validationPasswordTooShort =>
      'The password needs at least 8 characters.';

  @override
  String get validationPasswordNeedsLetter =>
      'The password needs at least one letter.';

  @override
  String get validationPasswordNeedsDigit =>
      'The password needs at least one digit.';

  @override
  String get signUpEmailTaken => 'This email is already registered.';

  @override
  String get signUpPhoneTaken => 'This mobile number is already registered.';

  @override
  String get signUpTakenActions => 'You can sign in or reset the password.';

  @override
  String get confirmEmailTitle => 'Confirm your email';

  @override
  String get confirmEmailButton => 'Confirm';

  @override
  String get confirmCodeEmpty => 'The code has 6 digits.';

  @override
  String confirmCodeWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tries left',
      one: '1 try left',
    );
    return 'That code is not correct. $_temp0.';
  }

  @override
  String get confirmCodeExpired =>
      'This code has expired. You can send a new one.';

  @override
  String get confirmCodeDead =>
      'No tries left on this code. You can send a new one.';

  @override
  String get confirmNoPending =>
      'There is no pending confirmation for this email. You can create the account again.';

  @override
  String confirmResendTooSoon(int seconds) {
    return 'You can send a new code in $seconds seconds.';
  }

  @override
  String get confirmResent => 'We sent a new code.';

  @override
  String get emailConfirmSubject => 'Your Sprint account confirmation code';

  @override
  String emailConfirmBody(String code, int minutes) {
    return 'Confirmation code: $code\nThe code is valid for $minutes minutes. If you did not create this account, you can ignore this message.';
  }

  @override
  String get emailResetSubject => 'Your Sprint password reset code';

  @override
  String emailResetBody(String code, int minutes) {
    return 'Reset code: $code\nThe code is valid for $minutes minutes. If you did not ask for a reset, you can ignore this message.';
  }

  @override
  String get demoNoticeTitle => 'Demo only';

  @override
  String demoNoticeCode(String code) {
    return 'Demo code: $code';
  }

  @override
  String get demoNoticeDismiss => 'Hide';

  @override
  String get mailboxTitle => 'Demo mailbox';

  @override
  String get mailboxNote =>
      'Emails the app would have sent appear here. For reviewers only.';

  @override
  String get mailboxEmptyTitle => 'No messages yet';

  @override
  String get mailboxEmptyBody =>
      'Any confirmation or reset code that is sent will appear here.';

  @override
  String get mailboxTo => 'To';

  @override
  String get mailboxCopyCode => 'Copy code';

  @override
  String get mailboxCopied => 'Code copied.';
}
