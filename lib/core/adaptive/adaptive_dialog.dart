import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/core/widgets/wide_dialog/wide_dialog.dart';
import 'package:sprint/core/window/window_size.dart';

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
  // From the medium window class every platform shows the wide dialog
  // (WideDialog README); below it the platform's own alert.
  if (!WindowSize.of(context).isCompact) {
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
            child: WideDialog(
              key: const ValueKey('sprint-dialog-desktop'),
              title: title,
              message: message,
              actions: [
                for (final a in actions)
                  WideDialogAction(
                    label: a.label,
                    destructive: a.isDestructive,
                    onPressed: () => Navigator.of(ctx).pop(a.value),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
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
          // The text carries the colour itself: `button` has its own colour
          // and would hide the button style's.
          child: Text(
            a.label,
            style: ctx.text.button.copyWith(
              color: a.isDestructive ? colors.danger : colors.primary,
            ),
          ),
        ),
    ],
  );
}

/// A dialog with one text field, in the platform's form. The confirm button
/// stays off until the trimmed text has at least [minLength] characters, and
/// the dialog returns the trimmed text, or null when dismissed. The field
/// shows [fieldLabel] and [helper] (for example a reason, FR-034).
Future<String?> showSprintInputDialog({
  required BuildContext context,
  required String title,
  required String fieldLabel,
  required String confirmLabel,
  required String cancelLabel,
  String? helper,
  int minLength = 1,
}) {
  Widget dialog(BuildContext ctx, {required bool apple, Key? key}) =>
      _InputDialog(
        key: key,
        apple: apple,
        title: title,
        fieldLabel: fieldLabel,
        helper: helper,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        minLength: minLength,
      );
  switch (adaptiveStyleOf(context)) {
    case AdaptiveStyle.apple:
      return showCupertinoDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => dialog(ctx, apple: true),
      );
    case AdaptiveStyle.android:
      return showDialog<String>(
        context: context,
        builder: (ctx) => dialog(ctx, apple: false),
      );
    case AdaptiveStyle.desktop:
      return showDialog<String>(
        context: context,
        builder: (ctx) => dialog(
          ctx,
          apple: false,
          key: const ValueKey('sprint-dialog-desktop'),
        ),
      );
  }
}

class _InputDialog extends StatefulWidget {
  const _InputDialog({
    required this.apple,
    required this.title,
    required this.fieldLabel,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.minLength,
    this.helper,
    super.key,
  });

  final bool apple;
  final String title;
  final String fieldLabel;
  final String? helper;
  final String confirmLabel;
  final String cancelLabel;
  final int minLength;

  @override
  State<_InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<_InputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid => _controller.text.trim().length >= widget.minLength;

  void _confirm() {
    if (_valid) Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final field = Padding(
      padding: const EdgeInsetsDirectional.only(top: SprintSpacing.space3),
      child: SprintTextField(
        label: widget.fieldLabel,
        helper: widget.helper,
        controller: _controller,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _confirm(),
      ),
    );
    if (widget.apple) {
      return CupertinoAlertDialog(
        title: Text(widget.title),
        content: Material(type: MaterialType.transparency, child: field),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.cancelLabel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            isDestructiveAction: true,
            onPressed: _valid ? _confirm : null,
            child: Text(widget.confirmLabel),
          ),
        ],
      );
    }
    final colors = context.colors;
    return AlertDialog(
      title: Text(widget.title, style: context.text.title),
      content: SingleChildScrollView(child: field),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel, style: context.text.button),
        ),
        TextButton(
          onPressed: _valid ? _confirm : null,
          style: TextButton.styleFrom(foregroundColor: colors.danger),
          child: Text(widget.confirmLabel, style: context.text.button),
        ),
      ],
    );
  }
}
