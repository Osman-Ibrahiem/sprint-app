import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/booking/domain/schedule_notice.dart';
import 'package:sprint/features/booking/presentation/widgets/failure_message.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The inline notice above the grid: an icon, the words and a dismiss action,
/// announced as a live region (research R11). Never colour alone.
class ScheduleNoticeView extends StatelessWidget {
  const ScheduleNoticeView({
    required this.notice,
    required this.onDismiss,
    super.key,
  });

  final ScheduleNotice notice;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final message = scheduleNoticeMessage(context, notice);
    return Semantics(
      liveRegion: true,
      container: true,
      label: message,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsetsDirectional.only(
            start: SprintSpacing.space3,
            top: SprintSpacing.space1,
            bottom: SprintSpacing.space1,
          ),
          decoration: BoxDecoration(
            color: colors.warningSoft,
            borderRadius: SprintRadius.mdBorder,
          ),
          child: Row(
            children: [
              SprintIcon(
                PhosphorIconsRegular.info,
                size: SprintSize.iconMd,
                color: colors.ink,
              ),
              const SizedBox(width: SprintSpacing.space2),
              Expanded(child: Text(message, style: context.text.body)),
              Semantics(
                button: true,
                label: l10n.bookingNoticeDismiss,
                child: IconButton(
                  tooltip: l10n.bookingNoticeDismiss,
                  constraints: const BoxConstraints(
                    minWidth: SprintSize.controlHeight,
                    minHeight: SprintSize.controlHeight,
                  ),
                  icon: const SprintIcon(PhosphorIconsRegular.x),
                  onPressed: onDismiss,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
