import 'package:flutter/widgets.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';

/// Reduced-motion helpers (FR-018). Under the system setting, motion becomes a
/// `duration-fast` fade, or nothing when the motion explains nothing.
abstract final class ReducedMotion {
  static bool of(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// A fade replaces the motion: [normal] normally, `duration-fast` if reduced.
  static Duration fade(BuildContext context, Duration normal) =>
      of(context) ? SprintMotion.durationFast : normal;

  /// The motion is dropped: [normal] normally, zero if reduced.
  static Duration skip(BuildContext context, Duration normal) =>
      of(context) ? Duration.zero : normal;
}
