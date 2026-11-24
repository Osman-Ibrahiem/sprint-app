import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/reduced_motion.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// Two or more equal segments on a sunken track (SegmentedControl README,
/// FR-MYB-02). Labels are final strings (counts included); the whole 48 row of
/// a segment is its hit area, and the arrow keys move the selection.
class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.semanticLabels,
    super.key,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  /// Spoken form of each segment ("الجاية، 3 حجوزات"); the label by default.
  final List<String>? semanticLabels;

  static ValueKey<String> segmentKey(int i) => ValueKey<String>('segment-$i');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = ReducedMotion.fade(context, SprintMotion.durationBase);
    final rtl = Directionality.of(context) == TextDirection.rtl;

    // At least 48 high; a label too long for its half takes a second line
    // and the track grows with it, never an ellipsis (decision T1).
    return Container(
      constraints: const BoxConstraints(minHeight: SprintSize.controlHeight),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: SprintSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: SprintRadius.mdBorder,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0) const SizedBox(width: SprintSpacing.space1),
              Expanded(
                child: Focus(
                  onKeyEvent: (node, event) {
                    if (event is! KeyDownEvent) return KeyEventResult.ignored;
                    final forward = rtl
                        ? LogicalKeyboardKey.arrowLeft
                        : LogicalKeyboardKey.arrowRight;
                    final back = rtl
                        ? LogicalKeyboardKey.arrowRight
                        : LogicalKeyboardKey.arrowLeft;
                    if (event.logicalKey == forward && i < labels.length - 1) {
                      onChanged(i + 1);
                      return KeyEventResult.handled;
                    }
                    if (event.logicalKey == back && i > 0) {
                      onChanged(i - 1);
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: AdaptivePressable(
                    key: segmentKey(i),
                    label: semanticLabels?[i] ?? labels[i],
                    selected: i == selected,
                    onTap: () => onChanged(i),
                    expand: true,
                    borderRadius: SprintRadius.smBorder,
                    builder: (context, _) => ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: SprintSize.controlHeight,
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: duration,
                          curve: SprintMotion.easeStandard,
                          constraints: const BoxConstraints(
                            minHeight: SprintExtras.segmentHeight,
                          ),
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: SprintSpacing.space2,
                            vertical: SprintSpacing.space1,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: i == selected
                                ? colors.surface
                                : Colors.transparent,
                            borderRadius: SprintRadius.smBorder,
                          ),
                          child: Text(
                            labels[i],
                            textAlign: TextAlign.center,
                            style: context.text.label.copyWith(
                              color: i == selected
                                  ? colors.ink
                                  : colors.inkMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
