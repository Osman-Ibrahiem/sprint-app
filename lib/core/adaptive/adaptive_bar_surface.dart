import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';

/// The background of a bar that sits over content (the tab bar): translucent
/// with a blur on Apple platforms, solid `surface` elsewhere (adaptive.md).
class AdaptiveBarSurface extends StatelessWidget {
  const AdaptiveBarSurface({required this.child, this.border, super.key});

  final Widget child;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final apple = adaptiveStyleOf(context) == AdaptiveStyle.apple;
    final bar = DecoratedBox(
      decoration: BoxDecoration(
        color: apple
            ? colors.surface
                .withValues(alpha: SprintExtras.tabBarTranslucentAlpha)
            : colors.surface,
        border: border,
      ),
      child: child,
    );
    if (!apple) return bar;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: SprintExtras.tabBarBlurSigma,
          sigmaY: SprintExtras.tabBarBlurSigma,
        ),
        child: bar,
      ),
    );
  }
}
