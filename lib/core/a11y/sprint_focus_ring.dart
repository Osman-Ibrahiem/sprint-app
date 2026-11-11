import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';

/// Draws the `focus-ring` around [child] while [visible] (keyboard focus only).
class SprintFocusRing extends StatelessWidget {
  const SprintFocusRing({
    required this.visible,
    required this.borderRadius,
    required this.child,
    super.key,
  });

  final bool visible;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const o = -SprintExtras.focusRingOffset;
    return Stack(
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
