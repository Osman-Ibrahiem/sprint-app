import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';

/// A switch in the platform's look, coloured `primary` when on. The Material
/// switch also shows a check in its thumb, so the state is not colour alone.
class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final apple = adaptiveStyleOf(context) == AdaptiveStyle.apple;

    final Widget control = apple
        ? CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: colors.primary,
            inactiveTrackColor: colors.controlBorder,
            thumbColor: colors.surface,
          )
        : Switch(
            value: value,
            onChanged: onChanged,
            thumbIcon: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Icon(Icons.check, size: SprintSize.iconSm)
                  : null,
            ),
          );

    return MergeSemantics(
      child: Semantics(
        label: semanticLabel,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: SprintSize.controlHeight,
            minHeight: SprintSize.controlHeight,
          ),
          child: Center(child: control),
        ),
      ),
    );
  }
}
