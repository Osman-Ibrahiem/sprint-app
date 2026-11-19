import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';

/// One button of a [WideDialog].
class WideDialogAction {
  const WideDialogAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onPressed;

  /// Danger fill, listed first in reading order.
  final bool destructive;
}

/// The confirmation dialog from the medium window class (WideDialog README):
/// centred, 400 wide, `radius-xl`, real buttons 48 high, destructive action
/// first in reading order. Enter and Esc are handled by `showSprintDialog`.
class WideDialog extends StatelessWidget {
  const WideDialog({
    required this.title,
    required this.actions,
    this.message,
    super.key,
  });

  final String title;
  final String? message;
  final List<WideDialogAction> actions;

  static const panelKey = ValueKey<String>('wide-dialog-panel');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ordered = [
      ...actions.where((a) => a.destructive),
      ...actions.where((a) => !a.destructive),
    ];
    return Dialog(
      backgroundColor: colors.surfaceRaised,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: SprintRadius.xlBorder,
        side: BorderSide(color: colors.line),
      ),
      // Exactly 400 wide (WideDialog README), not "up to 400": the dialog
      // would otherwise hug its text and come out about 320.
      child: SizedBox(
        key: panelKey,
        width: SprintExtras.wideDialogWidth,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.title.copyWith(color: colors.ink)),
              if (message != null) ...[
                const SizedBox(height: SprintSpacing.space3),
                Text(
                  message!,
                  style: context.text.body.copyWith(color: colors.inkMuted),
                ),
              ],
              const SizedBox(height: SprintSpacing.space6),
              Wrap(
                spacing: SprintSpacing.space2,
                runSpacing: SprintSpacing.space2,
                children: [
                  for (final a in ordered)
                    SprintButton(
                      label: a.label,
                      variant: a.destructive
                          ? SprintButtonVariant.danger
                          : SprintButtonVariant.ghost,
                      onPressed: a.onPressed,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
