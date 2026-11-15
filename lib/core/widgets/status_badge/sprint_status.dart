import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Every status the design system shows, with one word, one icon and one
/// colour pair each (contracts/widgets.md).
enum SprintStatus {
  confirmed,
  pendingPayment,
  cancelled,
  attended,
  noShow,
  expired,
  underReview,
  verified,
  rejected,
  open,
  inProgress,
  resolved,
}

extension SprintStatusStyle on SprintStatus {
  String label(AppLocalizations l10n) => switch (this) {
        SprintStatus.confirmed => l10n.statusConfirmed,
        SprintStatus.pendingPayment => l10n.statusPendingPayment,
        SprintStatus.cancelled => l10n.statusCancelled,
        SprintStatus.attended => l10n.statusAttended,
        SprintStatus.noShow => l10n.statusNoShow,
        SprintStatus.expired => l10n.statusExpired,
        SprintStatus.underReview => l10n.statusUnderReview,
        SprintStatus.verified => l10n.statusVerified,
        SprintStatus.rejected => l10n.statusRejected,
        SprintStatus.open => l10n.statusOpen,
        SprintStatus.inProgress => l10n.statusInProgress,
        SprintStatus.resolved => l10n.statusResolved,
      };

  IconData get icon => switch (this) {
        SprintStatus.confirmed => PhosphorIconsRegular.checkCircle,
        SprintStatus.pendingPayment => PhosphorIconsRegular.clock,
        SprintStatus.cancelled => PhosphorIconsRegular.xCircle,
        SprintStatus.attended => PhosphorIconsRegular.userCheck,
        SprintStatus.noShow => PhosphorIconsRegular.userMinus,
        SprintStatus.expired => PhosphorIconsRegular.hourglass,
        SprintStatus.underReview => PhosphorIconsRegular.clock,
        SprintStatus.verified => PhosphorIconsRegular.sealCheck,
        SprintStatus.rejected => PhosphorIconsRegular.xCircle,
        SprintStatus.open => PhosphorIconsRegular.warningCircle,
        SprintStatus.inProgress => PhosphorIconsRegular.wrench,
        SprintStatus.resolved => PhosphorIconsRegular.checkCircle,
      };

  /// (foreground, background) from the contract's table.
  (Color, Color) colors(SprintColors c) => switch (this) {
        SprintStatus.confirmed ||
        SprintStatus.verified ||
        SprintStatus.resolved =>
          (c.success, c.successSoft),
        SprintStatus.pendingPayment ||
        SprintStatus.underReview ||
        SprintStatus.open =>
          (c.warning, c.warningSoft),
        SprintStatus.cancelled || SprintStatus.rejected => (c.danger, c.dangerSoft),
        SprintStatus.attended || SprintStatus.inProgress => (
            c.onPrimarySoft,
            c.primarySoft,
          ),
        SprintStatus.noShow ||
        SprintStatus.expired =>
          (c.inkMuted, c.surfaceSunken),
      };
}
