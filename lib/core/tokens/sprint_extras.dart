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

  /// Apple tab bar: translucent over the content (adaptive.md). The blur
  /// strength is the `blur-bar` token (`SprintBlur.barSigma`).
  static const double tabBarTranslucentAlpha = 0.85;

  /// Navigation labels (tab bar and rail) stop growing at this text scale
  /// and stay visible; the rest of the app scales to 200% (decision T2,
  /// refactor 000).
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

  /// The old day pill height (64), still the unit of a few skeletons.
  static const double dayPillHeight = 64;

  /// DayStrip v2 (decision 18): circle 48, name, dot and their gaps, at 100%
  /// text; the schedule's loading skeleton uses it.
  static const double dayItemHeight = 88;

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

  /// The success and failure moments' stand-in: a disc of 160 with a 72 icon
  /// (decision 19 of refactor 000 replaced the brand tile with a check).
  /// The widest share of a label-and-value row a label may take (the value
  /// takes the rest), so values stay on one line where they fit.
  static const double rowLabelShare = 0.45;

  /// The hourglass disc of the waiting and expired states (design: 96, icon 40).
  static const double stateDisc = 96;
  static const double stateDiscIcon = 40;

  static const double momentOuter = 160;
  static const double momentIcon = 72;
  static const double momentBadge = 44;
  static const double momentBadgeInset = 8;

  /// The loader on the processing screen (design: a ring of about 72).
  static const double processingLoader = 72;

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

  // Feature 007 layout constants of the design pack (R13). Figma states them
  // as raw numbers with no token; promote them with the others later.

  /// Selected BookingRow border, drawn inside so the height does not change.
  static const double selectedBorderWidth = 2;

  /// Medium-class pane widths: list pane of My bookings and Notifications,
  /// Account column, edit-profile column and the wide dialog.
  static const double medium007ListPane = 300;
  static const double mediumFacilitiesPane = 260;
  static const double mediumAccountColumn = 360;
  static const double wideDialogWidth = 400;

  /// Popover README (decision K2): 260 wide at least, growing with its
  /// longest label up to 380.
  static const double popoverMinWidth = 260;
  static const double popoverMaxWidth = 380;

  /// Space below the last item of a scrolling screen so the tab bar or a bar
  /// never covers it, and the larger spacer above a screen's last action.
  static const double screenBottomPadding = 140;
  static const double spacer32 = 32;

  /// Heights of rows and skeleton shapes drawn in Figma.
  static const double bookingRowHeight = 190;
  static const double bookingRowSelectedHeight = 194;
  static const double bookingRowWrappedHeight = 210;
  static const double settingsRowHeight = 52;
  static const double notificationCardHeight = 110;
  static const double profileCardHeight = 140;

  /// NotificationBell and NotificationCard anatomy.
  static const double bellBadgeMinWidth = 18;
  static const double bellBadgePaddingX = 5;
  static const double bellBadgeTop = 6;
  static const double bellBadgeOffset = 26;
  static const double notificationIconTile = 40;
  static const double unreadDot = 8;

  /// Avatar sizes (README of the pack): account card and edit profile.
  static const double avatarLarge = 64;
  static const double avatarSmall = 48;

  /// SegmentedControl: the segment is the track minus its padding; the whole
  /// track height is the hit area.
  static const double segmentHeight = 40;

  /// Search clear button and its icon.
  static const double searchClearTarget = 48;

  /// List pane of "حجوزاتي" from the expanded and the large class.
  static const double bookingsListPaneExpanded = 360;
  static const double bookingsListPaneLarge = 400;

  /// How often an open booking's details re-read the clock (hold countdown,
  /// cancellation cutoff); a presentation constant.
  static const Duration detailsRefreshPeriod = Duration(seconds: 15);

  /// Content columns of the wide layouts (Figma, design QA H2): notifications
  /// 800 on Large, accounts 560, edit profile 440 (Medium draws notifications
  /// at 512; Medium and Compact keep the full pane). Applied from the expanded
  /// window class by `ContentColumn`.
  static const double notificationsColumnMax = 800;
  static const double accountColumnMax = 560;
  static const double editProfileColumnMax = 440;
}
