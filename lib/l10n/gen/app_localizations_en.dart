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
      'Your bookings and account details will show here once you sign in.';

  @override
  String get gateTitle => 'This step needs an account';

  @override
  String gateBody(String reason) {
    return 'Sign in or create an account $reason';
  }

  @override
  String get gateSignIn => 'Sign in';

  @override
  String get gateSignUp => 'Create an account';

  @override
  String get gateDismiss => 'Not now';

  @override
  String get gateReasonBook => 'to book';

  @override
  String get gateReasonBookings => 'to see your bookings';

  @override
  String get gateReasonVerification => 'to request verification';

  @override
  String get gateReasonProfile => 'to see your account details';

  @override
  String get gateDemoBookSlot => 'Book this slot';

  @override
  String get gateDemoTitle => 'Account gate try-out';

  @override
  String get gateDemoIntro =>
      'Pick a slot, then tap book. A guest sees the account prompt, and after signing in comes back here with the slot still selected.';

  @override
  String get gateDemoReady =>
      'Account ready. Nothing was booked; tap again to continue.';

  @override
  String get gateDemoDismissed =>
      'Closed without signing in, and the slot is still selected.';

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
  String get demoUserNote =>
      'For reviewers only. Switches accounts without a password.';

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
  String get demoResetButton => 'Reset demo data';

  @override
  String get demoResetTitle => 'Reset the demo data?';

  @override
  String get demoResetBody =>
      'Every booking, account and request made so far is removed and the data goes back to how it started. Theme and language stay as they are.';

  @override
  String get demoResetConfirm => 'Reset data';

  @override
  String get demoResetKeep => 'Cancel';

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

  @override
  String get catalogueTypeSwimming => 'Swimming';

  @override
  String get catalogueTypeFootball => 'Football';

  @override
  String get catalogueTypeGym => 'Gym';

  @override
  String get catalogueTypeTennis => 'Tennis';

  @override
  String get catalogueTypeHall => 'Hall';

  @override
  String get catalogueTypeTraining => 'Training';

  @override
  String get catalogueErrorTitle => 'Something went wrong';

  @override
  String get catalogueErrorBody =>
      'This content isn\'t showing right now. Trying again may fix it.';

  @override
  String get catalogueRetry => 'Try again';

  @override
  String get catalogueFacilityNotFoundTitle => 'Facility not found';

  @override
  String get catalogueFacilityNotFoundBody =>
      'The link may be wrong, or the facility isn\'t published.';

  @override
  String get catalogueBackToFacilities => 'Back to facilities';

  @override
  String get cataloguePanePrompt => 'Pick a facility to see its details';

  @override
  String cataloguePriceRange(String min, String max) {
    return 'EGP $min–$max';
  }

  @override
  String get catalogueTagFree => 'Free';

  @override
  String get catalogueTagTrainer => 'With a trainer';

  @override
  String get catalogueHomeTitle => 'Discover facilities';

  @override
  String get catalogueHomeTypesTitle => 'Facility types';

  @override
  String get catalogueHomeFeaturedTitle => 'Featured facilities';

  @override
  String get catalogueHomeSeeAll => 'See all facilities';

  @override
  String get catalogueHomeGuestHint =>
      'You can browse every facility without signing in.';

  @override
  String get catalogueFiltersTitle => 'Filters';

  @override
  String get catalogueFilterAllTypes => 'All types';

  @override
  String get catalogueFilterAllUnits => 'All units';

  @override
  String get catalogueFilterAny => 'Free or paid';

  @override
  String get catalogueFilterFree => 'Free';

  @override
  String get catalogueFilterPaid => 'Paid';

  @override
  String get catalogueFilterClearAll => 'Clear all';

  @override
  String catalogueFilterRemove(String name) {
    return 'Remove filter $name';
  }

  @override
  String catalogueResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count facilities',
      one: '1 facility',
      zero: 'No facilities',
    );
    return '$_temp0';
  }

  @override
  String get catalogueEmptyTitle => 'No facilities match';

  @override
  String catalogueEmptyBody(String filters) {
    return 'Nothing matches these filters: $filters';
  }

  @override
  String get catalogueEmptyClear => 'Clear filters';

  @override
  String get catalogueSectionHours => 'Opening hours';

  @override
  String get catalogueSectionPrices => 'Prices';

  @override
  String get catalogueSectionTrainers => 'Trainers';

  @override
  String get catalogueSectionUnits => 'Units';

  @override
  String get catalogueSectionAvailability => 'Available today';

  @override
  String get catalogueSectionFacts => 'Booking info';

  @override
  String get cataloguePhotoPlaceholder => 'Facility photo';

  @override
  String cataloguePhotoPosition(int index, int count) {
    return 'Photo $index of $count';
  }

  @override
  String catalogueDayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'Monday',
      '2': 'Tuesday',
      '3': 'Wednesday',
      '4': 'Thursday',
      '5': 'Friday',
      '6': 'Saturday',
      'other': 'Sunday',
    });
    return '$_temp0';
  }

  @override
  String get catalogueHoursClosedDay => 'Closed';

  @override
  String get catalogueHoursToday => 'Today';

  @override
  String get catalogueClosedNow => 'Closed right now';

  @override
  String get catalogueClosedToday => 'Closed today';

  @override
  String get catalogueListSeparator => ', ';

  @override
  String catalogueClosureRange(String from, String to) {
    return '$from to $to';
  }

  @override
  String get cataloguePriceInternalLabel => 'Students and staff price';

  @override
  String get cataloguePriceExternalLabel => 'Standard price';

  @override
  String get cataloguePriceYours => 'Your price';

  @override
  String get cataloguePriceBasisShared => 'Per place';

  @override
  String get cataloguePriceBasisExclusive => 'Per booking';

  @override
  String get cataloguePriceAllUnits => 'All units';

  @override
  String get cataloguePriceNotSet => 'Price not set yet';

  @override
  String get catalogueFreeNoPayment =>
      'This facility is free, with no payment.';

  @override
  String catalogueTrainerCapacity(int count) {
    return 'Takes $count per session';
  }

  @override
  String get catalogueTrainersNone => 'No trainers right now';

  @override
  String get catalogueTrainerFirst => 'Choose a trainer first';

  @override
  String get catalogueTrainerUnnamed => 'Trainer';

  @override
  String catalogueUnitOwnHours(String hours) {
    return 'Own hours: $hours';
  }

  @override
  String catalogueFactWindow(int days) {
    return 'Book up to $days days ahead';
  }

  @override
  String catalogueFactMaxRange(int hours) {
    return 'Up to $hours hours per booking';
  }

  @override
  String catalogueFactSession(int minutes) {
    return 'Session length $minutes minutes';
  }

  @override
  String get verifTitle => 'Verification request';

  @override
  String get verifRenewTitle => 'Renew verification';

  @override
  String get verifIntro =>
      'Once verified you book at the internal price. We check your details and ID card photo.';

  @override
  String get verifTypeTitle => 'Account type';

  @override
  String get verifTypeStudent => 'Student';

  @override
  String get verifTypeStaff => 'Staff';

  @override
  String get verifTypeFaculty => 'Faculty member';

  @override
  String get verifNationalIdLabel => 'National ID';

  @override
  String get verifNationalIdHelper => '14 digits, as written on the card.';

  @override
  String get verifCodeLabel => 'University or staff code';

  @override
  String get verifCodeHelper =>
      'Digits or English letters, up to 20 characters.';

  @override
  String get verifUnitTitle => 'Faculty or department';

  @override
  String get verifPhotoLabel => 'ID card photo';

  @override
  String get verifPhotoHelper =>
      'A clear photo of the whole card. It is resized automatically before sending.';

  @override
  String get verifPhotoChoose => 'Choose photo';

  @override
  String get verifPhotoReplace => 'Change photo';

  @override
  String get verifPhotoSourceTitle => 'ID card photo';

  @override
  String get verifPhotoCamera => 'Take a photo';

  @override
  String get verifPhotoGallery => 'Choose from photos or files';

  @override
  String get verifPhotoCancel => 'Cancel';

  @override
  String get verifPhotoProcessing => 'Preparing the photo';

  @override
  String get verifPhotoPreviewSpoken => 'ID card photo preview';

  @override
  String get verifPhotoNotImage =>
      'That file is not an image. Choose another one.';

  @override
  String get verifErrNationalIdEmpty => 'National ID is required.';

  @override
  String get verifErrNationalIdLength => 'National ID must be 14 digits.';

  @override
  String get verifErrNationalIdCentury =>
      'The first digit of the national ID must be 2 or 3.';

  @override
  String get verifErrNationalIdBirthDate =>
      'The birth date inside the national ID is not valid.';

  @override
  String get verifErrNationalIdFuture =>
      'The birth date inside the national ID is in the future.';

  @override
  String get verifErrNationalIdGovernorate =>
      'The governorate code inside the national ID is not valid.';

  @override
  String get verifErrCodeEmpty => 'The code is required.';

  @override
  String get verifErrCodeInvalid =>
      'The code must be 1 to 20 digits or English letters.';

  @override
  String get verifErrUnitEmpty => 'Choose the faculty or department.';

  @override
  String get verifErrPhotoEmpty => 'The ID card photo is required.';

  @override
  String get verifSubmit => 'Send request';

  @override
  String get verifSubmitting => 'Sending the request';

  @override
  String verifResultApproved(String date) {
    return 'Verified. Your price is internal until $date.';
  }

  @override
  String get verifResultPending =>
      'Request sent and under review. Until it is done you stay on the full price.';

  @override
  String verifResultRejected(String reason) {
    return 'The request was refused. Reason: $reason';
  }

  @override
  String get verifResultDone => 'Done';

  @override
  String get verifReasonDuplicate =>
      'This national ID already has a verification request from another account.';

  @override
  String get verifStorageFull =>
      'The photo was not saved, you can send it again';

  @override
  String get verifAlreadyPending => 'You already have a request under review.';

  @override
  String get verifCardTitle => 'Verification';

  @override
  String verifCardSpoken(String status) {
    return 'Verification: $status';
  }

  @override
  String get verifStatusNone => 'Not verified';

  @override
  String get verifStatusExpired => 'Verification expired';

  @override
  String get verifNoneBody =>
      'Your account is on the full price. Once verified you book at the internal price.';

  @override
  String get verifPendingBody =>
      'Your request is under review. Until it is done you stay on the full price.';

  @override
  String verifApprovedUntil(String date) {
    return 'Verified until $date';
  }

  @override
  String get verifRejectedBody => 'The request was refused.';

  @override
  String verifReasonLabel(String reason) {
    return 'Reason: $reason';
  }

  @override
  String verifExpiredBody(String date) {
    return 'Verification expired on $date. The price is full until you renew.';
  }

  @override
  String get verifActionRequest => 'Request verification';

  @override
  String get verifActionRenew => 'Renew verification';

  @override
  String get verifActionAgain => 'Send a new request';

  @override
  String get verifActionWait => 'Waiting for review';

  @override
  String verifNationalIdMasked(String id) {
    return 'National ID: $id';
  }

  @override
  String get verifRevSection => 'Verification';

  @override
  String get verifRevQueueTitle => 'Verification requests';

  @override
  String get verifRevQueueEmpty => 'No requests waiting for review.';

  @override
  String verifRevWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Waiting $count minutes',
      one: 'Waiting 1 minute',
      zero: 'Waiting less than a minute',
    );
    return '$_temp0';
  }

  @override
  String verifRevWaitHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Waiting $count hours',
      one: 'Waiting 1 hour',
    );
    return '$_temp0';
  }

  @override
  String verifRevWaitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Waiting $count days',
      one: 'Waiting 1 day',
    );
    return '$_temp0';
  }

  @override
  String get verifRevPricing => 'Priced as internal once approved';

  @override
  String verifRevRowSpoken(String name, String type, String unit, String wait) {
    return 'Request from $name, $type, $unit, $wait';
  }

  @override
  String get verifRevDetailTitle => 'Request details';

  @override
  String get verifRevPickPrompt =>
      'Choosing a request from the list shows its details here.';

  @override
  String get verifRevName => 'Name';

  @override
  String get verifRevType => 'Type';

  @override
  String get verifRevCode => 'Code';

  @override
  String get verifRevUnit => 'Faculty or department';

  @override
  String get verifRevSubmitted => 'Sent';

  @override
  String get verifRevNationalId => 'National ID';

  @override
  String get verifRevPhoto => 'ID card photo';

  @override
  String verifRevPhotoSpoken(String name) {
    return 'ID card photo of $name';
  }

  @override
  String get verifRevPhotoMissing => 'The photo is not available.';

  @override
  String get verifRevApprove => 'Approve request';

  @override
  String get verifRevReject => 'Reject request';

  @override
  String get verifRevRejectTitle => 'Reject request';

  @override
  String get verifRevReasonLabel => 'Reason for rejection';

  @override
  String get verifRevReasonHelper =>
      'At least 10 characters. The person will see the reason.';

  @override
  String get verifRevReasonConfirm => 'Confirm rejection';

  @override
  String get verifRevReasonCancel => 'Back';

  @override
  String get verifRevAlreadyDecided => 'This request was already decided.';

  @override
  String get verifRevOwnRequest => 'You cannot review your own request.';

  @override
  String get verifRevDecidedApproved =>
      'The request was approved and the person now pays the internal price.';

  @override
  String get verifRevDecidedRejected =>
      'The request was rejected and the person can see the reason.';

  @override
  String get verifRevUpload => 'Upload sheet';

  @override
  String get sheetTitle => 'Upload verification sheet';

  @override
  String get sheetHelp =>
      'A UTF-8 CSV file with 3 columns in this order: national ID, code, type (student, staff or faculty). The first row may be headings.';

  @override
  String get sheetPick => 'Choose a CSV file';

  @override
  String get sheetSummaryTitle => 'Upload summary';

  @override
  String get sheetSummaryRead => 'Rows read';

  @override
  String get sheetSummaryAdded => 'Rows added';

  @override
  String get sheetSummaryDuplicates => 'Duplicate rows skipped';

  @override
  String get sheetSummaryInvalid => 'Invalid rows skipped';

  @override
  String get sheetSummaryApproved => 'Requests approved automatically';

  @override
  String get sheetProblemsTitle => 'Skipped rows';

  @override
  String sheetProblemRow(String row, String reason) {
    return 'Row $row: $reason';
  }

  @override
  String get sheetReasonColumns => 'Wrong number of columns';

  @override
  String get sheetReasonCode => 'The code is not valid';

  @override
  String get sheetReasonType => 'The type is not known';

  @override
  String get sheetReasonOther => 'The row is not valid';

  @override
  String get sheetErrBadColumns =>
      'The columns are not the expected ones, and nothing was added.';

  @override
  String get sheetErrNoRows =>
      'The file has no valid rows, and nothing was added.';

  @override
  String get sheetErrRead =>
      'The file could not be read. You can try another CSV file.';

  @override
  String get sheetBatchesTitle => 'Earlier uploads';

  @override
  String get sheetBatchesEmpty => 'No uploads yet.';

  @override
  String sheetBatchLine(int added, int approved, int skipped) {
    return 'Added $added, approved $approved, skipped $skipped';
  }

  @override
  String verifNoticeApproved(String date) {
    return 'Your verification request was approved. Verified until $date.';
  }

  @override
  String verifNoticeRejected(String reason) {
    return 'Your verification request was rejected. Reason: $reason';
  }

  @override
  String get catalogueAvailabilityToday => 'Available today';

  @override
  String get catalogueScheduleAction => 'View times';

  @override
  String get catalogueUpcomingTitle => 'Your upcoming bookings';

  @override
  String get catalogueUpcomingSeeAll => 'See all';

  @override
  String get catalogueUpcomingNone =>
      'No upcoming bookings. Pick a facility to start.';

  @override
  String catalogueBookingSpoken(
    String facility,
    String date,
    String time,
    String status,
  ) {
    return 'Booking at $facility, $date, at $time, $status';
  }

  @override
  String get catalogueSuggestionsTitle => 'Suggested for you';

  @override
  String catalogueSuggestionReasonBookedType(String type) {
    return 'Because you booked $type before';
  }

  @override
  String get catalogueSuggestionReasonOther => 'You might like this';

  @override
  String get catalogueShareAction => 'Share facility';

  @override
  String get catalogueShareCopyLink => 'Copy link';

  @override
  String get catalogueShareCopied => 'Link copied';

  @override
  String catalogueShareText(String name) {
    return 'Check out $name on Sprint';
  }

  @override
  String get bookingScheduleHeading => 'Times';

  @override
  String get bookingRefreshAction => 'Refresh times';

  @override
  String get bookingContinue => 'Continue';

  @override
  String get bookingUnitLabel => 'Unit';

  @override
  String bookingUnitHasPlaces(String unit) {
    return '$unit, places available';
  }

  @override
  String bookingUnitNoPlaces(String unit) {
    return '$unit, no places that day';
  }

  @override
  String get bookingNothingLeftDay =>
      'Nothing is left on this day. Other days have places.';

  @override
  String get bookingNothingLeftWindow => 'Nothing is left in the coming days.';

  @override
  String get bookingNoUnitsTitle => 'No times to book';

  @override
  String get bookingNoUnitsBody =>
      'This facility has no bookable times right now.';

  @override
  String get bookingBackToFacility => 'Back to the facility';

  @override
  String get bookingErrorTitle => 'The times did not load';

  @override
  String get bookingErrorBody => 'This may be a temporary problem.';

  @override
  String get bookingRetry => 'Retry';

  @override
  String get bookingChoiceGone =>
      'The earlier choice is no longer available. These are the nearest times.';

  @override
  String get bookingNoticeDismiss => 'Dismiss message';

  @override
  String bookingRangeHint(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Pick the first and last hour, up to $hours hours in a row',
      one: 'One hour per booking here',
    );
    return '$_temp0';
  }

  @override
  String bookingLengthHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String bookingLengthMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String bookingTimeWithLength(String time, String length) {
    return 'Time $time, length $length';
  }

  @override
  String get bookingFree => 'Free';

  @override
  String get bookingPanelTitle => 'Your choice';

  @override
  String get bookingSelectionPrompt => 'No time chosen yet';

  @override
  String get bookingGateReason => 'to book';

  @override
  String get bookingFailSlotTaken =>
      'This time was just booked. Other times are available.';

  @override
  String bookingFailSlotTakenAt(String time) {
    return '$time was just booked, so this range is not available.';
  }

  @override
  String get bookingFailSlotFull =>
      'This time is now full. Other times are available.';

  @override
  String bookingFailSlotFullAt(String time) {
    return '$time is full, so this range is not available.';
  }

  @override
  String get bookingFailSlotPast => 'This time has passed.';

  @override
  String get bookingFailOutsideWindow =>
      'Booking is open for the coming days only.';

  @override
  String get bookingFailClosed => 'This time is not available.';

  @override
  String bookingFailClosedAt(String time) {
    return '$time is not available, so this range is not available.';
  }

  @override
  String bookingFailRangeTooLong(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'The longest booking is $hours hours.',
      one: 'The longest booking is 1 hour.',
    );
    return '$_temp0';
  }

  @override
  String get bookingFailRangeTooLongGeneric =>
      'The range is longer than allowed.';

  @override
  String bookingFailOverlap(String facility, String when) {
    return 'You already have a booking then: $facility, $when.';
  }

  @override
  String get bookingFailOverlapGeneric =>
      'You already have another booking at that time.';

  @override
  String bookingFailTooMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have reached the limit of $count active bookings.',
      one: 'You have reached the limit of 1 active booking.',
    );
    return '$_temp0';
  }

  @override
  String get bookingFailTooManyGeneric =>
      'You have reached the limit of active bookings.';

  @override
  String get bookingFailNotPermitted => 'This account cannot book.';

  @override
  String get bookingFailNotFound =>
      'The facility or the time is not available right now.';

  @override
  String get bookingFailGeneric =>
      'The booking did not go through. You can try again.';

  @override
  String get bookingSummaryTitle => 'Booking summary';

  @override
  String get bookingRowFacility => 'Facility';

  @override
  String get bookingRowUnit => 'Unit';

  @override
  String get bookingRowDate => 'Day';

  @override
  String get bookingRowTime => 'Time';

  @override
  String get bookingRowLength => 'Length';

  @override
  String get bookingRowCoverage => 'The booking covers';

  @override
  String get bookingRowTrainer => 'Trainer';

  @override
  String get bookingRowTier => 'Price tier';

  @override
  String get bookingRowPrice => 'Price';

  @override
  String get bookingRowPolicy => 'Cancellation policy';

  @override
  String get bookingCoverageWhole => 'The whole unit';

  @override
  String bookingCoverageWholeMax(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The whole unit, up to $count participants',
      one: 'The whole unit, for 1 participant',
    );
    return '$_temp0';
  }

  @override
  String get bookingCoverageOnePlace => 'One place';

  @override
  String bookingSessionLength(int minutes) {
    return '$minutes-minute session';
  }

  @override
  String bookingPolicyCutoff(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'You can cancel up to $hours hours before the start.',
      one: 'You can cancel up to 1 hour before the start.',
      zero: 'You can cancel until the start time.',
    );
    return '$_temp0';
  }

  @override
  String get bookingPolicyRefundFull => 'The full amount is refunded.';

  @override
  String bookingPolicyRefundPartial(int percent) {
    return '$percent% of the amount is refunded.';
  }

  @override
  String get bookingPolicyRefundNone => 'The amount is not refunded.';

  @override
  String get bookingVerifyHint =>
      'A verified account gets the student and staff price.';

  @override
  String get bookingVerifyAction => 'Verification request';

  @override
  String get bookingVerifyPending =>
      'Your verification request is under review. The internal price applies to new bookings after approval.';

  @override
  String get bookingPriceChanged =>
      'The price changed from what the schedule showed. This is the current price.';

  @override
  String get bookingPayAction => 'Continue to payment';

  @override
  String get bookingConfirmAction => 'Confirm booking';

  @override
  String get bookingFreeNoPayment =>
      'This booking is free and has no payment step.';

  @override
  String get bookingCheckoutSoonTitle => 'Payment is coming soon';

  @override
  String get bookingCheckoutSoonBody =>
      'The payment step arrives soon. Your choice is kept in the summary.';

  @override
  String get bookingBackToSummary => 'Back to the summary';

  @override
  String get bookingDoneTitle => 'Booking confirmed';

  @override
  String get bookingDoneBody =>
      'The booking is on your account and shows on home.';

  @override
  String get bookingDoneCode => 'Booking code';

  @override
  String get bookingDoneHome => 'Back to home';

  @override
  String get bookingDoneNotFoundTitle => 'Booking not found';

  @override
  String get bookingDoneNotFoundBody =>
      'The link may be wrong, or the booking belongs to another account.';

  @override
  String get bookingTrainerStepTitle => 'Choosing a trainer';

  @override
  String get bookingTrainerStepBody => 'Times show after a trainer is chosen.';

  @override
  String get bookingTrainerHasSessions => 'Has sessions in the coming days';

  @override
  String get bookingTrainerNoSessions => 'No sessions in the coming days';

  @override
  String get bookingTrainerNoName => 'Trainer';

  @override
  String get bookingTrainerChange => 'Change trainer';

  @override
  String bookingTrainerChosen(String name) {
    return 'Trainer: $name';
  }

  @override
  String get bookingNoTrainersTitle => 'No trainers available';

  @override
  String get bookingNoTrainersBody =>
      'This facility has no trainers to book yet.';

  @override
  String get bookingTrainerNoSessionsBody =>
      'This trainer has no sessions in the coming days.';

  @override
  String bookingTrainerRowSpoken(String name, String bio, String sessions) {
    return 'Trainer $name, $bio, $sessions';
  }

  @override
  String get splashTagline => 'Book without the crowd';

  @override
  String get splashCaption => 'Tanta University';
}
