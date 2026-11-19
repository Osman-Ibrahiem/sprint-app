import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/core/widgets/status_badge/status_badge.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// One booking in "حجوزاتي" (BookingRow README, FR-MYB-02). The whole row is
/// the target. Plain values only: the caller builds [dateLabel], [notes] and
/// [action] with the right words. [selected] (master-detail) draws a 2 px
/// primary border inside the row, so its height never changes.
class BookingRow extends StatelessWidget {
  const BookingRow({
    required this.status,
    required this.facilityName,
    required this.notes,
    required this.dateLabel,
    required this.isToday,
    required this.code,
    required this.action,
    required this.onTap,
    required this.semanticLabel,
    this.selected = false,
    super.key,
  });

  final SprintStatus status;
  final String facilityName;
  final String notes;
  final String dateLabel;
  final bool isToday;
  final String code;
  final String action;
  final VoidCallback onTap;
  final bool selected;

  /// The whole row read as one node: status, date, facility, notes, code,
  /// action.
  final String semanticLabel;

  static const selectedKey = ValueKey<String>('booking-row-selected');
  static const dateChipKey = ValueKey<String>('booking-row-date');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    final chip = Container(
      key: dateChipKey,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: SprintSpacing.space3,
        vertical: SprintSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: isToday ? colors.volt : colors.surfaceSunken,
        borderRadius: SprintRadius.smBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              dateLabel,
              style: text.label.copyWith(
                color: isToday ? colors.onVolt : colors.ink,
              ),
            ),
          ),
          const SizedBox(width: SprintSpacing.space2),
          SprintIcon(
            PhosphorIconsRegular.clock,
            size: SprintSize.iconSm,
            color: isToday ? colors.onVolt : colors.ink,
          ),
        ],
      ),
    );

    final body = Padding(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            chip: chip,
            badge: StatusBadge(status: status),
            chipText: dateLabel,
            chipStyle: text.label,
            badgeText: status.label(AppLocalizations.of(context)),
            badgeStyle: text.micro,
          ),
          const SizedBox(height: SprintSpacing.space2),
          Text(facilityName, style: text.headline.copyWith(color: colors.ink)),
          const SizedBox(height: SprintSpacing.space2),
          Text(notes, style: text.caption.copyWith(color: colors.inkMuted)),
          const SizedBox(height: SprintSpacing.space2),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: SprintSpacing.space2,
            children: [
              LtrIsolate(
                child: Text(
                  code,
                  style: text.code.copyWith(color: colors.inkMuted),
                ),
              ),
              Text(action, style: text.label.copyWith(color: colors.primary)),
            ],
          ),
        ],
      ),
    );

    return AdaptivePressable(
      label: semanticLabel,
      selected: selected,
      onTap: onTap,
      expand: true,
      borderRadius: SprintRadius.lgBorder,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: SprintRadius.lgBorder,
          boxShadow: colors.shadowCard,
        ),
        child: Stack(
          children: [
            ExcludeSemantics(child: body),
            if (selected)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    key: selectedKey,
                    decoration: BoxDecoration(
                      borderRadius: SprintRadius.lgBorder,
                      border: Border.all(
                        color: colors.primary,
                        width: SprintExtras.selectedBorderWidth,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The date chip at the start and the status badge at the end of one line;
/// when the two do not fit, the badge keeps the end edge on its own line and
/// the chip goes under it at the start (BookingRow README, design QA H3).
class _Header extends StatelessWidget {
  const _Header({
    required this.chip,
    required this.badge,
    required this.chipText,
    required this.chipStyle,
    required this.badgeText,
    required this.badgeStyle,
  });

  final Widget chip;
  final Widget badge;
  final String chipText;
  final TextStyle chipStyle;
  final String badgeText;
  final TextStyle badgeStyle;

  double _textWidth(BuildContext context, String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    // chip: padding 2 x space3, gap space2, icon; badge: padding 2 x space3,
    // gap space1, icon.
    final chipWidth =
        _textWidth(context, chipText, chipStyle) +
        SprintSpacing.space3 * 2 +
        SprintSpacing.space2 +
        SprintSize.iconSm;
    final badgeWidth =
        _textWidth(context, badgeText, badgeStyle) +
        SprintSpacing.space3 * 2 +
        SprintSpacing.space1 +
        SprintSize.iconSm;
    return LayoutBuilder(
      builder: (context, c) {
        final fits =
            chipWidth + badgeWidth + SprintSpacing.space2 <= c.maxWidth;
        if (fits) {
          return Row(
            children: [
              Flexible(child: chip),
              const Spacer(),
              badge,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(alignment: AlignmentDirectional.centerEnd, child: badge),
            const SizedBox(height: SprintSpacing.space2),
            Align(alignment: AlignmentDirectional.centerStart, child: chip),
          ],
        );
      },
    );
  }
}
