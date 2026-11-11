import 'package:flutter/widgets.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';

/// Window width classes (FR-002). Layout follows width, never device names.
enum WindowSize {
  compact,
  medium,
  expanded,
  large;

  static WindowSize fromWidth(double width) {
    if (width >= SprintSize.bpLarge) return WindowSize.large;
    if (width >= SprintSize.bpExpanded) return WindowSize.expanded;
    if (width >= SprintSize.bpMedium) return WindowSize.medium;
    return WindowSize.compact;
  }

  static WindowSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  bool get isCompact => this == WindowSize.compact;
  bool get isMedium => this == WindowSize.medium;

  /// Expanded and large both use the sidebar.
  bool get isWide => index >= WindowSize.expanded.index;
}
