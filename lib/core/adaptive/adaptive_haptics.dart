import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sprint/core/adaptive/adaptive_traits.dart';

/// A light selection haptic where the platform has one, and nothing elsewhere.
/// Never throws when there is no haptic engine (contracts/adaptive-additions.md).
abstract final class AdaptiveHaptics {
  static Future<void> selection(BuildContext context) async {
    if (!AdaptiveTraits.of(context).hapticsOnSelect) return;
    try {
      await HapticFeedback.selectionClick();
    } on Object {
      // A desktop, web or emulator target may have no haptic channel.
    }
  }
}
