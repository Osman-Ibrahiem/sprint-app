import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// A titled container for one section of the details page: `surface`, the
/// `radius-lg` corner and token spacing. The title is a heading for a screen
/// reader and can carry one trailing control.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.title,
    required this.child,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: context.text.title),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: SprintSpacing.space2),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: SprintSpacing.space3),
          child,
        ],
      ),
    );
  }
}
