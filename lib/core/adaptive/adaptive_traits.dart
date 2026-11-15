import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/platform.dart';

/// The one platform decision in the product, turned into answers a widget can
/// use without knowing which platform it got (contracts/adaptive-additions.md).
enum PressFeedback {
  /// Apple: the whole control fades, no ripple.
  fade,

  /// Android: an ink ripple in the pressed colour.
  ripple,

  /// Desktop and web: a colour swap on hover and a pointer cursor.
  hover,
}

@immutable
class AdaptiveTraits {
  const AdaptiveTraits({
    required this.pressFeedback,
    required this.hapticsOnSelect,
    required this.tabBarPill,
    required this.numberShortcuts,
    required this.keyboardFocusRing,
  });

  final PressFeedback pressFeedback;
  final bool hapticsOnSelect;
  final bool tabBarPill;
  final bool numberShortcuts;
  final bool keyboardFocusRing;

  /// The trait table of the contract, bound to `adaptiveStyleOf` so widgets
  /// never name a platform (research R2).
  static AdaptiveTraits of(BuildContext context) =>
      switch (adaptiveStyleOf(context)) {
        AdaptiveStyle.apple => const AdaptiveTraits(
            pressFeedback: PressFeedback.fade,
            hapticsOnSelect: true,
            tabBarPill: false,
            numberShortcuts: false,
            keyboardFocusRing: true,
          ),
        AdaptiveStyle.android => const AdaptiveTraits(
            pressFeedback: PressFeedback.ripple,
            hapticsOnSelect: true,
            tabBarPill: true,
            numberShortcuts: false,
            keyboardFocusRing: true,
          ),
        AdaptiveStyle.desktop => const AdaptiveTraits(
            pressFeedback: PressFeedback.hover,
            hapticsOnSelect: false,
            tabBarPill: false,
            numberShortcuts: true,
            keyboardFocusRing: true,
          ),
      };
}
