import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Platform scroll feel (adaptive.md): bounce on Apple, stretch on Android,
/// visible scrollbar on web and desktop.
class SprintScrollBehavior extends MaterialScrollBehavior {
  const SprintScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };

  bool _isApple(TargetPlatform p) =>
      p == TargetPlatform.iOS || p == TargetPlatform.macOS;

  bool _hasScrollbar(BuildContext context) {
    final p = getPlatform(context);
    return kIsWeb ||
        p == TargetPlatform.macOS ||
        p == TargetPlatform.windows ||
        p == TargetPlatform.linux;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final p = getPlatform(context);
    return _isApple(p)
        ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
        : const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (!_hasScrollbar(context)) return child;
    return Scrollbar(controller: details.controller, child: child);
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Apple bounces; Android stretches (Material 3 default); desktop none.
    return getPlatform(context) == TargetPlatform.android
        ? StretchingOverscrollIndicator(
            axisDirection: details.direction,
            child: child,
          )
        : child;
  }
}
