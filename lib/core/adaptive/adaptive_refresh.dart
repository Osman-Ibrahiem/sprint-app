import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/context_extensions.dart';

/// Pull-to-refresh that follows the platform (adaptive.md, feature 005
/// research R4): the Cupertino-style indicator on Apple, the Material one on
/// Android, and nothing on the web and desktop, where a visible refresh action
/// does the same job. [child] must be a vertical scrollable.
class AdaptiveRefresh extends StatelessWidget {
  const AdaptiveRefresh({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return switch (adaptiveStyleOf(context)) {
      AdaptiveStyle.desktop => child,
      AdaptiveStyle.apple || AdaptiveStyle.android => RefreshIndicator.adaptive(
        onRefresh: onRefresh,
        color: colors.primary,
        backgroundColor: colors.surface,
        child: child,
      ),
    };
  }
}
