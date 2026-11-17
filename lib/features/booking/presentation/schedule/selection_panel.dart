import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/presentation/schedule/selection_bar.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The selection and its main action beside the grid on expanded and large
/// windows, in place of the bottom bar (FR-042). Drawn even with nothing
/// chosen, so the layout does not jump; then it says what to do.
class SelectionPanel extends StatelessWidget {
  const SelectionPanel({
    required this.start,
    required this.end,
    required this.unitName,
    required this.trainerName,
    required this.priceText,
    required this.loading,
    required this.onContinue,
    super.key,
  });

  /// UTC instants, or null with no selection.
  final DateTime? start;
  final DateTime? end;
  final String? unitName;
  final String? trainerName;
  final String? priceText;
  final bool loading;
  final VoidCallback? onContinue;

  static const panelKey = ValueKey<String>('selection-panel');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final chosen = start != null && end != null;
    return Container(
      key: panelKey,
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.bookingPanelTitle, style: context.text.headline),
          ),
          const SizedBox(height: SprintSpacing.space2),
          if (!chosen)
            Text(
              l10n.bookingSelectionPrompt,
              style: context.text.body.copyWith(color: colors.inkMuted),
            )
          else
            Semantics(
              container: true,
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unitName != null)
                    Text(unitName!, style: context.text.bodyStrong),
                  if (trainerName != null)
                    Text(
                      l10n.bookingTrainerChosen(trainerName!),
                      style: context.text.body,
                    ),
                  Text(
                    selectionTimeText(context, start!, end!),
                    style: context.text.body,
                  ),
                  if (priceText != null)
                    Text(priceText!, style: context.text.number),
                ],
              ),
            ),
          const SizedBox(height: SprintSpacing.space4),
          SizedBox(
            width: double.infinity,
            child: SprintButton(
              key: SelectionBar.actionKey,
              label: l10n.bookingContinue,
              loading: loading,
              onPressed: chosen && !loading ? onContinue : null,
            ),
          ),
        ],
      ),
    );
  }
}
