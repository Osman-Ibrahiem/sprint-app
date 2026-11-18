import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/adaptive_traits.dart';
import 'package:sprint/core/a11y/sprint_focus_ring.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// Which of the three interaction states wins. Pressed beats hovered beats
/// focused (contracts/adaptive-additions.md).
enum AdaptivePressState { resting, pressed, hovered, focused }

/// One pressable wrapper for every widget: Apple fades, Android ripples,
/// desktop and web swap the colour on hover. The focus ring is shared with the
/// Foundation's keyboard behaviour.
class AdaptivePressable extends StatefulWidget {
  const AdaptivePressable({
    required this.label,
    required this.builder,
    required this.onTap,
    this.selected = false,
    this.restingColor,
    this.pressedColor,
    this.hoverColor,
    this.borderRadius = SprintRadius.smBorder,
    this.liveRegion = false,
    this.focusNode,
    this.expand = false,
    super.key,
  });

  /// Fills the width it is given (a full-width action) instead of wrapping its
  /// content.
  final bool expand;

  /// Spoken label. Disabled semantics are derived from [onTap].
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final Widget Function(BuildContext context, AdaptivePressState state) builder;
  final Color? restingColor;
  final Color? pressedColor;
  final Color? hoverColor;
  final BorderRadius borderRadius;

  /// Announces a state change to a screen reader (slot chips, badges).
  final bool liveRegion;

  /// The caller's node, used by the day strip to move focus with arrow keys.
  final FocusNode? focusNode;

  static const fadeKey = ValueKey<String>('adaptive-fade');
  static const rippleKey = ValueKey<String>('adaptive-ripple');
  static const surfaceKey = ValueKey<String>('adaptive-surface');

  @override
  State<AdaptivePressable> createState() => _AdaptivePressableState();
}

class _AdaptivePressableState extends State<AdaptivePressable> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focusVisible = false;

  AdaptivePressState get _state {
    if (_pressed) return AdaptivePressState.pressed;
    if (_hovered) return AdaptivePressState.hovered;
    if (_focusVisible) return AdaptivePressState.focused;
    return AdaptivePressState.resting;
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final traits = AdaptiveTraits.of(context);
    final state = _state;
    final enabled = widget.onTap != null;

    Widget buildSurface(BuildContext context) {
      final feedback = traits.pressFeedback;
      final hovered =
          state == AdaptivePressState.hovered &&
          feedback == PressFeedback.hover;
      final pressed = state == AdaptivePressState.pressed;

      var background = hovered
          ? (widget.hoverColor ?? widget.restingColor)
          : widget.restingColor;
      if (pressed && feedback == PressFeedback.hover) {
        background = widget.pressedColor ?? background;
      }

      Widget child = widget.builder(context, state);
      if (pressed && feedback == PressFeedback.ripple) {
        child = Stack(
          alignment: Alignment.center,
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: DecoratedBox(
                    key: AdaptivePressable.rippleKey,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          (widget.pressedColor ?? context.colors.primaryPressed)
                              .withValues(alpha: 0.4),
                    ),
                    child: const SizedBox(
                      width: SprintSpacing.space16,
                      height: SprintSpacing.space16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }

      Widget surface = DecoratedBox(
        key: AdaptivePressable.surfaceKey,
        decoration: BoxDecoration(
          color: background,
          borderRadius: widget.borderRadius,
        ),
        child: child,
      );

      if (pressed && feedback == PressFeedback.fade) {
        surface = Opacity(
          key: AdaptivePressable.fadeKey,
          opacity: SprintExtras.applePressedOpacity,
          child: surface,
        );
      }

      return surface;
    }

    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.label,
      liveRegion: widget.liveRegion,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          enabled: enabled,
          focusNode: widget.focusNode,
          mouseCursor: enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onShowHoverHighlight: (v) => setState(() => _hovered = v),
          onShowFocusHighlight: (v) => setState(() => _focusVisible = v),
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onTap?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onTapDown: enabled ? (_) => _setPressed(true) : null,
            onTapUp: enabled ? (_) => _setPressed(false) : null,
            onTapCancel: enabled ? () => _setPressed(false) : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: SprintSize.controlHeight,
                minHeight: SprintSize.controlHeight,
              ),
              // Wrap its content, so loose width does not stretch the control
              // over a whole row; tight width (a SizedBox, an Expanded) still
              // fills as before, and the 48 minimum above still centres it.
              child: widget.expand
                  ? SprintFocusRing(
                      expand: true,
                      visible: _focusVisible,
                      borderRadius: widget.borderRadius,
                      child: Builder(builder: buildSurface),
                    )
                  : Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: SprintFocusRing(
                        visible: _focusVisible,
                        borderRadius: widget.borderRadius,
                        child: Builder(builder: buildSurface),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
