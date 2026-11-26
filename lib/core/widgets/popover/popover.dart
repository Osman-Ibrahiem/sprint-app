import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// One row of a [SprintPopover]: a label and a radio at the row's end.
/// [selected] fills the radio; the other rows show an empty ring.
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
/// (Popover README; decision K2 of refactor 000): `surface-raised`, 1px
/// `line`, `radius-lg`, `shadow-popover`, rows 48 high with a radio each.
/// 260 wide at least, growing with its longest label up to 380; a label
/// longer than that wraps, never an ellipsis. Escape and an outside tap close
/// it and focus goes back to the trigger. No platform checks: the caller
/// decides whether to show a popover or a sheet.
class SprintPopover<T> extends StatelessWidget {
  const SprintPopover({
    required this.options,
    required this.onSelected,
    super.key,
  });

  final List<PopoverOption<T>> options;
  final ValueChanged<T> onSelected;

  static const panelKey = ValueKey<String>('sprint-popover');
  static ValueKey<String> rowKey(int i) => ValueKey<String>('popover-row-$i');
  static ValueKey<String> radioKey(int i) =>
      ValueKey<String>('popover-radio-$i');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: SprintExtras.popoverMinWidth,
        maxWidth: SprintExtras.popoverMaxWidth,
      ),
      // As wide as the longest row wants, inside the bounds above.
      child: IntrinsicWidth(
        child: Container(
          key: panelKey,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: SprintSpacing.space4,
            vertical: SprintSpacing.space2,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            borderRadius: SprintRadius.lgBorder,
            border: Border.all(color: colors.line),
            boxShadow: colors.shadowPopover,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(height: SprintSpacing.space1),
                _Row<T>(
                  key: rowKey(i),
                  index: i,
                  option: options[i],
                  onSelected: onSelected,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Row<T> extends StatelessWidget {
  const _Row({
    required this.index,
    required this.option,
    required this.onSelected,
    super.key,
  });

  final int index;
  final PopoverOption<T> option;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // One node per row, announced as a radio button with its label and
    // whether it is the selected one.
    return MergeSemantics(
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: option.selected,
        child: AdaptivePressable(
          label: option.label,
          selected: option.selected,
          expand: true,
          borderRadius: SprintRadius.smBorder,
          hoverColor: colors.surfaceSunken,
          pressedColor: colors.surfaceSunken,
          onTap: () => onSelected(option.value),
          builder: (context, _) => ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: SprintSize.controlHeight,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: SprintSpacing.space3,
              ),
              // The label at the start takes the free space and wraps; the
              // radio sits flush at the end, centred on the label.
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option.label,
                      textAlign: TextAlign.start,
                      style: context.text.body.copyWith(color: colors.ink),
                    ),
                  ),
                  const SizedBox(width: SprintSpacing.space3),
                  _PopoverRadio(
                    key: SprintPopover.radioKey(index),
                    selected: option.selected,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The row's radio (Figma `Popover`, decision K2): a 22 circle with no fill.
/// Selected: a `primary` ring 6 wide, its centre showing the panel through.
/// Unselected: a `control-border` ring 2 wide.
class _PopoverRadio extends StatelessWidget {
  const _PopoverRadio({required this.selected, super.key});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: SprintExtras.popoverRadioSize,
      height: SprintExtras.popoverRadioSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.primary : colors.controlBorder,
          width: selected
              ? SprintExtras.popoverRadioSelectedRing
              : SprintExtras.popoverRadioRing,
        ),
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
  final overlay =
      Overlay.of(anchorContext).context.findRenderObject()! as RenderBox;
  final rtl = Directionality.of(anchorContext) == TextDirection.rtl;
  final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final size = box.size;
  final focus = FocusScope.of(anchorContext);

  return showGeneralDialog<T>(
    context: anchorContext,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(anchorContext)
        .modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (ctx, _, _) => CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(ctx).pop(),
      },
      child: Focus(
        autofocus: true,
        child: CustomSingleChildLayout(
          delegate: _AnchorLayout(anchor: topLeft & size, rtl: rtl),
          child: SprintPopover<T>(
            options: options,
            onSelected: (v) => Navigator.of(ctx).pop(v),
          ),
        ),
      ),
    ),
  ).whenComplete(focus.requestFocus);
}

/// Places the popover under its trigger using the popover's real width: its
/// start edge on the trigger's start edge (the right edge in Arabic), kept
/// `space-2` inside the window on both sides.
class _AnchorLayout extends SingleChildLayoutDelegate {
  const _AnchorLayout({required this.anchor, required this.rtl});

  final Rect anchor;
  final bool rtl;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen().deflate(
        const EdgeInsets.symmetric(horizontal: SprintSpacing.space2),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final wanted = rtl ? anchor.right - childSize.width : anchor.left;
    final maxLeft = size.width - childSize.width - SprintSpacing.space2;
    final left = maxLeft < SprintSpacing.space2
        ? SprintSpacing.space2
        : wanted.clamp(SprintSpacing.space2, maxLeft);
    return Offset(left, anchor.bottom + SprintSpacing.space1);
  }

  @override
  bool shouldRelayout(_AnchorLayout old) =>
      old.anchor != anchor || old.rtl != rtl;
}
