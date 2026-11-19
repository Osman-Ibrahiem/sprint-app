import 'package:flutter/widgets.dart';
import 'package:sprint/core/window/window_size.dart';

/// Limits [child] to [maxWidth] and centres it in the pane from the expanded
/// window class; compact and medium keep the full width as before. Used by the
/// notifications, account and edit-profile screens (design QA H2).
class ContentColumn extends StatelessWidget {
  const ContentColumn({required this.maxWidth, required this.child, super.key});

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = WindowSize.of(context);
    if (size.isCompact || size.isMedium) return child;
    // Side padding instead of an Align, so a child with an Expanded keeps
    // its tight height.
    return LayoutBuilder(
      builder: (context, c) {
        final side = ((c.maxWidth - maxWidth) / 2).clamp(0.0, double.infinity);
        return Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: side),
          child: child,
        );
      },
    );
  }
}
