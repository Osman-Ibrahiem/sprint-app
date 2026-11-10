import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/widgets.dart';

/// Lays out one or two panes so that nothing sits on a hinge or fold (FR-006).
///
/// - No separating feature: [start] fills the space and [end], if given, takes
///   the same width beside it.
/// - Vertical hinge: [start] fills the side before it, [end] (or nothing) the
///   side after it, and the hinge gap stays empty.
/// - Horizontal hinge (tabletop): everything is confined to the larger half.
///
/// The widget is assumed to span the window width, as the shell does.
class DisplayFeatureLayout extends StatelessWidget {
  const DisplayFeatureLayout({required this.start, this.end, super.key});

  final Widget start;
  final Widget? end;

  static bool _separates(DisplayFeature f) =>
      f.type == DisplayFeatureType.hinge || f.type == DisplayFeatureType.fold;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final features = media.displayFeatures.where(_separates).toList();
    if (features.isEmpty) {
      if (end == null) return start;
      return Row(children: [Expanded(child: start), Expanded(child: end!)]);
    }

    final f = features.first.bounds;
    final screen = media.size;

    if (f.height >= f.width) {
      final rtl = Directionality.of(context) == TextDirection.rtl;
      final startWidth = rtl ? screen.width - f.right : f.left;
      final endWidth = rtl ? f.left : screen.width - f.right;
      return Row(
        children: [
          SizedBox(width: startWidth.clamp(0, screen.width), child: start),
          SizedBox(width: f.width),
          SizedBox(
            width: endWidth.clamp(0, screen.width),
            child: end ?? const SizedBox.shrink(),
          ),
        ],
      );
    }

    final topHeight = f.top;
    final bottomHeight = screen.height - f.bottom;
    final useTop = topHeight >= bottomHeight;
    return Column(
      children: [
        if (!useTop) SizedBox(height: f.bottom),
        Expanded(child: start),
        if (useTop) SizedBox(height: screen.height - f.top),
      ],
    );
  }
}
