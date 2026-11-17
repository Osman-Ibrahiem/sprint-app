import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';

/// A static icon, a title, an optional sentence and an optional action, in the
/// middle of the screen. The one empty, error and "coming soon" layout of the
/// booking flow (Lottie empty states are feature 11).
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    this.body,
    this.iconColor,
    this.actionLabel,
    this.actionIcon,
    this.actionVariant = SprintButtonVariant.secondary,
    this.actionKey,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Color? iconColor;
  final String? actionLabel;
  final SprintButtonIcon? actionIcon;
  final SprintButtonVariant actionVariant;
  final Key? actionKey;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SprintIcon(
              icon,
              size: SprintSize.iconLg,
              color: iconColor ?? colors.inkMuted,
            ),
            const SizedBox(height: SprintSpacing.space3),
            Text(
              title,
              style: context.text.headline,
              textAlign: TextAlign.center,
            ),
            if (body != null) ...[
              const SizedBox(height: SprintSpacing.space2),
              Text(
                body!,
                style: context.text.body.copyWith(color: colors.inkMuted),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: SprintSpacing.space4),
              SprintButton(
                key: actionKey,
                label: actionLabel!,
                icon: actionIcon,
                variant: actionVariant,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
