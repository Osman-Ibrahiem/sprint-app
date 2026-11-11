import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/context_extensions.dart';

/// One button of a [showSprintDialog]. [value] is what the dialog returns.
class SprintDialogAction<T> {
  const SprintDialogAction({
    required this.label,
    this.value,
    this.isDestructive = false,
    this.isDefault = false,
  });

  final String label;
  final T? value;

  /// Destructive actions use `danger` and always carry their word.
  final bool isDestructive;

  /// The action Enter confirms on desktop.
  final bool isDefault;
}

/// A confirmation dialog in the platform's form: Cupertino alert on Apple,
/// Material dialog on Android, centred dialog with Enter and Esc on desktop.
/// Returns the chosen action's value, or null when dismissed.
Future<T?> showSprintDialog<T>({
  required BuildContext context,
  required String title,
  required List<SprintDialogAction<T>> actions,
  String? message,
}) {
  switch (adaptiveStyleOf(context)) {
    case AdaptiveStyle.apple:
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: message == null ? null : Text(message),
          actions: [
            for (final a in actions)
              CupertinoDialogAction(
                isDefaultAction: a.isDefault,
                isDestructiveAction: a.isDestructive,
                onPressed: () => Navigator.of(ctx).pop(a.value),
                child: Text(a.label),
              ),
          ],
        ),
      );
    case AdaptiveStyle.android:
      return showDialog<T>(
        context: context,
        builder: (ctx) => _materialDialog(ctx, title, message, actions),
      );
    case AdaptiveStyle.desktop:
      return showDialog<T>(
        context: context,
        builder: (ctx) {
          SprintDialogAction<T>? def;
          for (final a in actions) {
            if (a.isDefault) def = a;
          }
          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.enter): () {
                if (def != null) Navigator.of(ctx).pop(def.value);
              },
              const SingleActivator(LogicalKeyboardKey.escape): () =>
                  Navigator.of(ctx).pop(),
            },
            child: Focus(
              autofocus: true,
              child: _materialDialog(
                ctx,
                title,
                message,
                actions,
                key: const ValueKey('sprint-dialog-desktop'),
              ),
            ),
          );
        },
      );
  }
}

Widget _materialDialog<T>(
  BuildContext ctx,
  String title,
  String? message,
  List<SprintDialogAction<T>> actions, {
  Key? key,
}) {
  final colors = ctx.colors;
  return AlertDialog(
    key: key,
    title: Text(title, style: ctx.text.title),
    content: message == null ? null : Text(message, style: ctx.text.body),
    actions: [
      for (final a in actions)
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(a.value),
          style: a.isDestructive
              ? TextButton.styleFrom(foregroundColor: colors.danger)
              : null,
          child: Text(a.label, style: ctx.text.button),
        ),
    ],
  );
}
