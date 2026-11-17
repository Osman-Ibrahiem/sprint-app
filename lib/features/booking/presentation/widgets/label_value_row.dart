import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// A small label over its value, read by a screen reader as "label: value".
/// Used by the summary and the success screen.
class LabelValueRow extends StatelessWidget {
  const LabelValueRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: SprintSpacing.space3),
      child: Semantics(
        container: true,
        label: '$label: $value',
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.text.label.copyWith(color: colors.inkMuted),
              ),
              Text(value, style: context.text.bodyStrong),
            ],
          ),
        ),
      ),
    );
  }
}
