import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "ساعة واحدة" / "90 دقيقة" for a chosen period (UTC instants).
String selectionLengthText(BuildContext context, DateTime start, DateTime end) {
  final l10n = AppLocalizations.of(context);
  final minutes = end.difference(start).inMinutes;
  return minutes % 60 == 0
      ? l10n.bookingLengthHours(minutes ~/ 60)
      : l10n.bookingLengthMinutes(minutes);
}

/// "الوقت 5:00 – 6:00 م، المدة ساعة واحدة" for a chosen period. Shared by the
/// bottom bar and the side panel.
String selectionTimeText(BuildContext context, DateTime start, DateTime end) {
  final l10n = AppLocalizations.of(context);
  final format = SprintFormat.of(context);
  return l10n.bookingTimeWithLength(
    format.instantRange(start, end),
    selectionLengthText(context, start, end),
  );
}

/// The bottom bar of compact and medium windows: the chosen time and price and
/// the single primary action "متابعة" (FR-020). Drawn only with a selection.
class SelectionBar extends StatelessWidget {
  const SelectionBar({
    required this.start,
    required this.end,
    required this.priceText,
    required this.loading,
    required this.onContinue,
    super.key,
  });

  final DateTime start;
  final DateTime end;

  /// "120 ج.م", "مجاني", or null for a guest, whose price is the line above.
  final String? priceText;
  final bool loading;
  final VoidCallback? onContinue;

  static const barKey = ValueKey<String>('selection-bar');
  static const actionKey = ValueKey<String>('selection-continue');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      key: barKey,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.line,
            width: SprintExtras.hairlineWidth,
          ),
        ),
      ),
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      child: SafeArea(
        top: false,
        child: _layout(
          context,
          info: Semantics(
            container: true,
            liveRegion: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectionTimeText(context, start, end),
                  style: context.text.bodyStrong,
                ),
                if (priceText != null)
                  Text(
                    priceText!,
                    style: context.text.number.copyWith(color: colors.inkMuted),
                  ),
              ],
            ),
          ),
          action: SprintButton(
            key: actionKey,
            label: l10n.bookingContinue,
            loading: loading,
            onPressed: loading ? null : onContinue,
          ),
        ),
      ),
    );
  }
}

/// Beside each other normally, stacked from large text on (FR-041).
Widget _layout(
  BuildContext context, {
  required Widget info,
  required Widget action,
}) {
  final stacked =
      MediaQuery.textScalerOf(context).scale(1) >=
      SprintExtras.bookingBarStackTextScale;
  if (stacked) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        info,
        const SizedBox(height: SprintSpacing.space3),
        action,
      ],
    );
  }
  return Row(
    children: [
      Expanded(child: info),
      const SizedBox(width: SprintSpacing.space3),
      action,
    ],
  );
}
