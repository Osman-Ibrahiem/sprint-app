import 'package:flutter/material.dart';
import 'package:sprint/core/a11y/focusable_tap.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// A titled single-choice list. The chosen row shows a check and the word
/// "مختار", so the state never relies on colour alone (FR-017).
class OptionGroup<T> extends StatelessWidget {
  const OptionGroup({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String title;
  final List<(T value, String label)> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.headline),
        const SizedBox(height: SprintSpacing.space2),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: SprintRadius.lgBorder,
            border: Border.all(color: colors.line),
          ),
          child: Column(
            children: [
              for (final (value, label) in options)
                FocusableTap(
                  label: label,
                  selected: value == selected,
                  onTap: () => onSelected(value),
                  builder: (context, hovered) => Container(
                    constraints: const BoxConstraints(
                      minHeight: SprintSize.controlHeight,
                    ),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: SprintSpacing.space4,
                      vertical: SprintSpacing.space2,
                    ),
                    color: hovered ? colors.surfaceSunken : Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(child: Text(label, style: context.text.body)),
                        if (value == selected) ...[
                          Text(
                            l10n.optionSelected,
                            style: context.text.caption
                                .copyWith(color: colors.inkMuted),
                          ),
                          const SizedBox(width: SprintSpacing.space2),
                          Icon(
                            Icons.check,
                            size: SprintSize.iconMd,
                            color: colors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
