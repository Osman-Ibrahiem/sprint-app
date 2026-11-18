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

  /// How many slot-shaped skeletons the schedule shows while it loads.
  static const int bookingSkeletonChips = 8;

  /// Checkout, provider page and confirmation (feature 006, design-pack
  /// adaptive.md). Widths the tokens lack, from the Figma frames.
  /// TODO(tokens): promote these to `tokens.json` with the other `SprintExtras`
  /// sizes (decisions.md 2026-11-15 follow-up), then remove them here.

  /// The payment column of the two-column checkout (Figma "الدفع" 372).
  static const double checkoutPaymentColumn = 372;

  /// The narrowest the booking-summary column may get beside it (Figma 260);
  /// it takes the rest of the pane when the pane is wider.
  static const double checkoutSummaryColumnMin = 260;

  /// The centred single column of the provider page, processing, awaiting and
  /// receipt screens (Figma 480).
  static const double centredColumn = 480;

  /// One column of the two-column confirmation from the expanded class (Figma
  /// 358), and the gap between them (48).
  /// How long processing may last before the screen says it is still waiting
  /// (research R14): a presentation timing, not a BRD setting.
  static const Duration checkoutProcessingWait = Duration(seconds: 20);

  /// The success moment's stand-in (design: tile 88 in a ring 128 in a disc 160).
  /// The widest share of a label-and-value row a label may take (the value
  /// takes the rest), so values stay on one line where they fit.
  static const double rowLabelShare = 0.45;

  /// The hourglass disc of the waiting and expired states (design: 96, icon 40).
  static const double stateDisc = 96;
  static const double stateDiscIcon = 40;

  static const double momentOuter = 160;
  static const double momentFailureIcon = 72;
  static const double momentBadge = 44;
  static const double momentBadgeInset = 8;

  /// The loader on the processing screen (design: a ring of about 72).
  static const double processingLoader = 72;
  static const double momentRing = 128;
  static const double momentTile = 88;

  static const double confirmationColumn = 358;
  static const double confirmationGap = 48;

  /// The narrowest pane that fits both confirmation columns and the margins
  /// (2 x 358 + 48 + 2 x 24).
  static const double confirmationTwoColumnsMinWidth =
      confirmationColumn * 2 + confirmationGap + 48;

  /// The receipt PDF (feature 006, R9): print metrics in points, not screen
  /// layout. TODO(tokens): promote with the others (decisions.md 2026-11-15).
  static const double receiptPdfMargin = 32;
  static const double receiptPdfTitleSize = 20;
  static const double receiptPdfBodySize = 12;
  static const double receiptPdfRowGap = 8;
  static const double receiptPdfSectionGap = 16;
  static const double receiptPdfTagGap = 6;
}
