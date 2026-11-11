import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Theme;

/// Lays out one or two panes so that nothing sits on a hinge or fold (FR-006).
///
/// - No separating feature: [start] fills the space and [end], if given, takes
///   the same width beside it.
/// - Vertical hinge or half-open fold: [start] fills the side before it, [end]
///   (or the background) the side after it, and the gap stays empty.
/// - Horizontal one (tabletop): everything is confined to the larger half.
///
/// Each pane gets its own [MediaQuery] size, so layout inside a pane follows
/// the pane's width (size classes, margins) and not the whole window. A fold
/// that is flat does not split: the screen is one continuous surface.
class DisplayFeatureLayout extends StatelessWidget {
  const DisplayFeatureLayout({required this.start, this.end, super.key});

  final Widget start;
  final Widget? end;

  /// Hinges always occlude; a fold separates only when not lying flat.
  static bool separates(DisplayFeature f) =>
      f.type == DisplayFeatureType.hinge ||
      (f.type == DisplayFeatureType.fold &&
          f.state != DisplayFeatureState.postureFlat);

  static Widget _pane(MediaQueryData media, double width, double height, Widget child) {
    return SizedBox(
      width: width,
      height: height,
      child: MediaQuery(
        data: media.copyWith(
          size: Size(width, height),
          displayFeatures: const [],
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final features = media.displayFeatures.where(separates).toList();
    if (features.isEmpty) {
      if (end == null) return start;
      return Row(children: [Expanded(child: start), Expanded(child: end!)]);
    }

    final f = features.first.bounds;
    final screen = media.size;
    final background = ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const SizedBox.expand(),
    );

    if (f.height >= f.width) {
      final rtl = Directionality.of(context) == TextDirection.rtl;
      final startWidth = (rtl ? screen.width - f.right : f.left)
          .clamp(0.0, screen.width);
      final endWidth =
          (rtl ? f.left : screen.width - f.right).clamp(0.0, screen.width);
      return Stack(
        children: [
          Positioned.fill(child: background),
          Row(
            children: [
              _pane(media, startWidth, screen.height, start),
              SizedBox(width: f.width),
              _pane(
                media,
                endWidth,
                screen.height,
                end ?? const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      );
    }

    final topHeight = f.top;
    final bottomHeight = screen.height - f.bottom;
    final useTop = topHeight >= bottomHeight;
    final height = useTop ? topHeight : bottomHeight;
    return Stack(
      children: [
        Positioned.fill(child: background),
        Positioned(
          left: 0,
          right: 0,
          top: useTop ? 0 : f.bottom,
          height: height,
          child: _pane(media, screen.width, height, start),
        ),
      ],
    );
  }
}
