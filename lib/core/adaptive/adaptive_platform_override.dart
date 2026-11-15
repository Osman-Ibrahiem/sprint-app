import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/platform.dart';

/// Wraps [child] in a [Theme] whose target platform makes `adaptiveStyleOf`
/// return [style]. Used by the gallery and by tests; never persisted
/// (contracts/adaptive-additions.md).
class AdaptivePlatformOverride extends StatelessWidget {
  const AdaptivePlatformOverride({
    required this.style,
    required this.child,
    super.key,
  });

  final AdaptiveStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final platform = switch (style) {
      AdaptiveStyle.apple => TargetPlatform.iOS,
      AdaptiveStyle.android => TargetPlatform.android,
      AdaptiveStyle.desktop => TargetPlatform.windows,
    };
    return Theme(
      data: Theme.of(context).copyWith(platform: platform),
      child: child,
    );
  }
}
