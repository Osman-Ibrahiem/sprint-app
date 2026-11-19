import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// One row of a [SprintPopover]: a label and, when [selected], a check.
class PopoverOption<T> {
  const PopoverOption({
    required this.value,
    required this.label,
    this.selected = false,
  });

  final T value;
  final String label;
  final bool selected;
}

/// A panel anchored next to its trigger, from the medium window class
/// (Popover README): `surface-raised`, 1px `line`, rows 48 high, Escape and an
/// outside tap close it and focus goes back to the trigger. No platform
/// checks: the caller decides whether to show a popover or a sheet.
class SprintPopover<T> extends StatelessWidget {
  const SprintPopover({
    required this.options,
    required this.onSelected,
    this.width = popoverWidth,
    super.key,
  });

  /// README: 260 wide.
  static const double popoverWidth = 260;

  final List<PopoverOption<T>> options;
  final ValueChanged<T> onSelected;
  final double width;

  static const panelKey = ValueKey<String>('sprint-popover');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      key: panelKey,
      width: width,
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space2),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
        boxShadow: colors.shadowPopover,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final o in options)
            AdaptivePressable(
              label: o.label,
              selected: o.selected,
              expand: true,
              borderRadius: SprintRadius.smBorder,
              onTap: () => onSelected(o.value),
              builder: (context, _) => ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: SprintSize.controlHeight,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: SprintSpacing.space3,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          o.label,
                          style: context.text.body.copyWith(color: colors.ink),
                        ),
                      ),
                      if (o.selected)
                        SprintIcon(
                          PhosphorIconsFill.checkCircle,
                          size: SprintSize.iconLg,
                          color: colors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shows a [SprintPopover] anchored below the widget of [anchorContext] and
/// returns the chosen value, or null when closed. Escape and a tap outside
/// close it; focus returns to the trigger.
Future<T?> showSprintPopover<T>({
  required BuildContext anchorContext,
  required List<PopoverOption<T>> options,
}) {
  final box = anchorContext.findRenderObject()! as RenderBox;
  final overlay = Overlay.of(anchorContext).context.findRenderObject()! as RenderBox;
  final rtl = Directionality.of(anchorContext) == TextDirection.rtl;
  final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final size = box.size;
  final focus = FocusScope.of(anchorContext);

  return showGeneralDialog<T>(
    context: anchorContext,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(anchorContext).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (ctx, _, _) {
      final left = rtl
          ? topLeft.dx + size.width - SprintPopover.popoverWidth
          : topLeft.dx;
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(ctx).pop(),
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              Positioned(
                left: left.clamp(
                  SprintSpacing.space2,
                  overlay.size.width -
                      SprintPopover.popoverWidth -
                      SprintSpacing.space2,
                ),
                top: topLeft.dy + size.height + SprintSpacing.space1,
                child: SprintPopover<T>(
                  options: options,
                  onSelected: (v) => Navigator.of(ctx).pop(v),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).whenComplete(focus.requestFocus);
}
