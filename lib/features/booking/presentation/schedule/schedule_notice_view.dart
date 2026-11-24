import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/features/booking/domain/schedule_notice.dart';
import 'package:sprint/features/booking/presentation/widgets/failure_message.dart';
import 'package:sprint/core/widgets/banner/banner.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The inline notice above the grid: an icon, the words and a dismiss action,
/// announced as a live region (research R11). Never colour alone. The dismiss
/// button is outside the announced sentence, so a screen reader can reach it.
class ScheduleNoticeView extends StatelessWidget {
  const ScheduleNoticeView({
    required this.notice,
    required this.onDismiss,
    super.key,
  });

  final ScheduleNotice notice;
  final VoidCallback onDismiss;

  static const dismissKey = ValueKey<String>('notice-dismiss');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SprintBanner(
      tone: SprintBannerTone.hold,
      // A refusal, not a countdown: the warning sign, not the hold's
      // hourglass.
      icon: PhosphorIconsRegular.warningCircle,
      text: scheduleNoticeMessage(context, notice),
      trailing: Semantics(
        button: true,
        label: l10n.bookingNoticeDismiss,
        excludeSemantics: true,
        onTap: onDismiss,
        child: IconButton(
          key: dismissKey,
          tooltip: l10n.bookingNoticeDismiss,
          constraints: const BoxConstraints(
            minWidth: SprintSize.controlHeight,
            minHeight: SprintSize.controlHeight,
          ),
          icon: const SprintIcon(PhosphorIconsRegular.x),
          onPressed: onDismiss,
        ),
      ),
    );
  }
}
