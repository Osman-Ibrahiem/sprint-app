import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';

/// Draws the `focus-ring` around [child] while [visible] (keyboard focus only).
class SprintFocusRing extends StatelessWidget {
  const SprintFocusRing({
    required this.visible,
    required this.borderRadius,
    required this.child,
    this.expand = false,
    super.key,
  });

  final bool visible;
  final BorderRadius borderRadius;
  final Widget child;

  /// Passes the parent's width through to [child] (a full-width action).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    const o = -SprintExtras.focusRingOffset;
    return Stack(
      fit: expand ? StackFit.passthrough : StackFit.loose,
      clipBehavior: Clip.none,
      children: [
        child,
        if (visible)
          Positioned(
            left: o,
            top: o,
            right: o,
            bottom: o,
            child: IgnorePointer(
              child: DecoratedBox(
                key: const ValueKey('focus-ring-visible'),
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: context.colors.focusRing,
                    width: SprintExtras.focusRingWidth,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
