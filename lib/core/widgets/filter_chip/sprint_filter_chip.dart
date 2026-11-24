import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// A pill that turns a filter on or off (decision 21 of refactor 000, Figma
/// `FilterChip`: selected, unselected).
///
/// Unselected: `surface` with a 1px `control-border`, since the border is
/// what defines the control (3:1 on every ground, decision C1); `line` is
/// decorative only. Selected: `primary-soft` with a `primary` border and a
/// check, so the state never rests on colour alone. 48 high at least.
class SprintFilterChip extends StatelessWidget {
  const SprintFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.trailingIcon,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// An icon before the label (a facility type); the check then sits after
  /// the label when selected.
  final IconData? icon;

  /// An icon after the label instead of the check (the "x" of an active
  /// filter that removes it).
  final IconData? trailingIcon;

  /// What a screen reader says instead of [label] ("إزالة فلتر سباحة").
  final String? semanticLabel;

  static const visualKey = ValueKey<String>('sprint-filter-chip-visual');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ink = selected ? colors.onPrimarySoft : colors.ink;
    final showCheck = selected && trailingIcon == null;
    final check = SprintIcon(
      PhosphorIconsRegular.check,
      size: SprintSize.iconSm,
      color: colors.onPrimarySoft,
    );

    return AdaptivePressable(
      label: semanticLabel ?? label,
      selected: selected,
      onTap: onTap,
      restingColor: selected ? colors.primarySoft : colors.surface,
      hoverColor: selected ? colors.primarySoftHover : colors.surfaceSunken,
      pressedColor: selected ? colors.primarySoftPressed : colors.surfaceSunken,
      borderRadius: SprintRadius.fullBorder,
      builder: (context, state) => Container(
        key: visualKey,
        constraints: const BoxConstraints(minHeight: SprintSize.controlHeight),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SprintSpacing.space4,
          vertical: SprintSpacing.space2,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? colors.primary : colors.controlBorder,
            width: SprintExtras.hairlineWidth,
          ),
          borderRadius: SprintRadius.fullBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              SprintIcon(
                icon!,
                size: SprintSize.iconMd,
                color: selected ? colors.onPrimarySoft : colors.inkMuted,
              ),
              const SizedBox(width: SprintSpacing.space2),
            ] else if (showCheck) ...[
              check,
              const SizedBox(width: SprintSpacing.space1),
            ],
            Flexible(
              child: Text(label, style: context.text.label.copyWith(color: ink)),
            ),
            if (icon != null && showCheck) ...[
              const SizedBox(width: SprintSpacing.space1),
              check,
            ],
            if (trailingIcon != null) ...[
              const SizedBox(width: SprintSpacing.space1),
              SprintIcon(
                trailingIcon!,
                size: SprintSize.iconSm,
                color: colors.onPrimarySoft,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
