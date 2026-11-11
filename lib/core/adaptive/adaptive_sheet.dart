import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// One row of a [showSprintSheet]. [value] is what the sheet returns.
class SprintSheetAction<T> {
  const SprintSheetAction({
    required this.label,
    this.value,
    this.isDestructive = false,
  });

  final String label;
  final T? value;
  final bool isDestructive;
}

/// A list of actions in the platform's form: action sheet on Apple, modal
/// bottom sheet on Android, a menu anchored to [anchor] (or [context]) on
/// desktop. Esc closes where there is a keyboard. With [builder] the content is
/// custom (a modal popup, bottom sheet or dialog respectively).
Future<T?> showSprintSheet<T>({
  required BuildContext context,
  String? title,
  List<SprintSheetAction<T>> actions = const [],
  WidgetBuilder? builder,
  String? cancelLabel,
  BuildContext? anchor,
}) {
  switch (adaptiveStyleOf(context)) {
    case AdaptiveStyle.apple:
      return showCupertinoModalPopup<T>(
        context: context,
        builder: builder ??
            (ctx) => CupertinoActionSheet(
                  title: title == null ? null : Text(title),
                  actions: [
                    for (final a in actions)
                      CupertinoActionSheetAction(
                        isDestructiveAction: a.isDestructive,
                        onPressed: () => Navigator.of(ctx).pop(a.value),
                        child: Text(a.label),
                      ),
                  ],
                  cancelButton: cancelLabel == null
                      ? null
                      : CupertinoActionSheetAction(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(cancelLabel),
                        ),
                ),
      );
    case AdaptiveStyle.android:
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: builder != null,
        showDragHandle: true,
        builder: (ctx) => CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                Navigator.of(ctx).pop(),
          },
          child: Focus(
            autofocus: true,
            child: builder != null
                ? builder(ctx)
                : _SheetBody<T>(title: title, actions: actions),
          ),
        ),
      );
    case AdaptiveStyle.desktop:
      if (builder != null) {
        return showDialog<T>(context: context, builder: builder);
      }
      final target = (anchor ?? context).findRenderObject()! as RenderBox;
      final overlay =
          Overlay.of(context).context.findRenderObject()! as RenderBox;
      final rect = Rect.fromPoints(
        target.localToGlobal(Offset.zero, ancestor: overlay),
        target.localToGlobal(target.size.bottomRight(Offset.zero),
            ancestor: overlay),
      );
      final colors = context.colors;
      return showMenu<T>(
        context: context,
        position: RelativeRect.fromRect(rect, Offset.zero & overlay.size),
        items: [
          for (final a in actions)
            PopupMenuItem<T>(
              value: a.value,
              child: Text(
                a.label,
                style: context.text.body.copyWith(
                  color: a.isDestructive ? colors.danger : colors.ink,
                ),
              ),
            ),
        ],
      );
  }
}

class _SheetBody<T> extends StatelessWidget {
  const _SheetBody({required this.title, required this.actions});

  final String? title;
  final List<SprintSheetAction<T>> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: SprintSpacing.space5,
                vertical: SprintSpacing.space2,
              ),
              child: Text(title!, style: context.text.headline),
            ),
          for (final a in actions)
            InkWell(
              onTap: () => Navigator.of(context).pop(a.value),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: SprintSize.controlHeight),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: SprintSpacing.space5,
                    vertical: SprintSpacing.space3,
                  ),
                  child: Text(
                    a.label,
                    style: context.text.body.copyWith(
                      color: a.isDestructive ? colors.danger : colors.ink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
