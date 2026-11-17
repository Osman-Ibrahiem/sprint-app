/// Constants that the design docs state in prose but that `tokens.json` does
/// not carry. They are NOT tokens: if one is promoted to a token, move it to
/// `tokens.json` and the generator instead.
abstract final class SprintExtras {
  /// Focus ring: 2px solid line, 2px away from the element
  /// (README § الوصولية).
  static const double focusRingWidth = 2;
  static const double focusRingOffset = 2;

  /// iOS press feedback: the fill fades to 70% (adaptive.md).
  static const double applePressedOpacity = 0.7;

  /// Apple tab bar: translucent with a blur over the content (adaptive.md).
  /// The strength is a design judgement, not a documented value.
  static const double tabBarBlurSigma = 24;
  static const double tabBarTranslucentAlpha = 0.85;

  /// Above this text scale, narrow navigation drops visible labels and keeps
  /// the icon plus its spoken label, so nothing is clipped at 200% (FR-017).
  static const double navLabelMaxTextScale = 1.3;

  /// Lowest opacity of the skeleton pulse (a design judgement; the docs only
  /// fix the cycle length, `duration-pulse`).
  static const double skeletonMinOpacity = 0.5;

  /// Under reduced motion the loader stops spinning and shows a fixed
  /// three-quarter ring, so the busy state stays visible without motion.
  static const double reducedMotionLoaderProgress = 0.75;

  /// SlotChip README § القواعد: at least 56 high and 100 wide.
  static const double slotChipMinHeight = 56;
  static const double slotChipMinWidth = 100;

  /// DayStrip README § الشكل: each day pill is 64 high.
  static const double dayPillHeight = 64;

  /// StatusBadge README § الشكل: pill height 28.
  static const double statusBadgeHeight = 28;

  /// Component READMEs: the resting 1 px border (secondary button, chips,
  /// text fields).
  static const double hairlineWidth = 1;

  /// BookingTicket README § الشكل: 340 wide on compact.
  static const double ticketWidth = 340;

  /// FacilityCard README § الشكل: photo on the start side, 112 wide in the
  /// horizontal layout. The vertical layout uses a 16:9 photo.
  static const double facilityPhotoWidth = 112;
  static const double facilityPhotoAspect = 16 / 9;

  /// BookingTicket README § الشكل: a quiet margin of 12 around the QR.
  static const double qrQuietMargin = 12;

  /// BookingTicket README § الشكل: the two half-circle notches on the dashed
  /// divider; half the ticket width, a design judgement from the preview.
  static const double ticketNotchRadius = 10;

  /// SprintLogo README: never drawn below 16.
  static const double logoMinSize = 16;

  /// SprintLogo README: a bare mark needs 3:1 contrast with its background
  /// against `volt`; below it the primary tile is used.
  static const double logoMarkContrastThreshold = 3;

  /// AppNavigation README: a badge count above 99 reads "99+".
  static const int navigationBadgeCap = 99;

  /// Auth forms (feature 003, contracts/ui.md): the centred form column is
  /// capped at 480, and the ID card preview is 200 high. Follow-up: promote
  /// both to `tokens.json` and the generator, then remove them here.
  static const double authFormMaxWidth = 480;
  static const double idCardPreviewHeight = 200;

  /// One tick of a visible countdown (resend code). A clock step, not
  /// motion, so it is not a `SprintMotion` token.
  static const Duration countdownTick = Duration(seconds: 1);

  /// Booking schedule (feature 005): the side panel on wide windows, and the
  /// narrowest pane that still has room for it beside the slot grid.
  static const double bookingPanelWidth = 200;
  static const double bookingPanelMinPaneWidth = 480;

  /// From this text scale the booking bar stacks its text above its action
  /// instead of beside it, so large text never squeezes either.
  static const double bookingBarStackTextScale = 1.3;
}
