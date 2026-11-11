import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// How a control should look and behave. Decided here and nowhere else:
/// screens never name a platform (FR-019, adaptive.md).
enum AdaptiveStyle {
  /// iOS, iPadOS and native macOS.
  apple,

  /// Android.
  android,

  /// The web, Windows and Linux (and desktop browsers on a Mac).
  desktop,
}

AdaptiveStyle adaptiveStyleFor(TargetPlatform platform, {required bool isWeb}) {
  return switch (platform) {
    TargetPlatform.iOS => AdaptiveStyle.apple,
    TargetPlatform.android => AdaptiveStyle.android,
    TargetPlatform.macOS => isWeb ? AdaptiveStyle.desktop : AdaptiveStyle.apple,
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.fuchsia =>
      AdaptiveStyle.desktop,
  };
}

AdaptiveStyle adaptiveStyleOf(BuildContext context) =>
    adaptiveStyleFor(Theme.of(context).platform, isWeb: kIsWeb);

/// For code that has no [BuildContext], such as `preferredSize`.
AdaptiveStyle adaptiveStyleOfHost() =>
    adaptiveStyleFor(defaultTargetPlatform, isWeb: kIsWeb);
