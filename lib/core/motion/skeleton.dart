import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/reduced_motion.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';

/// A loading block on `surface-sunken`, shaped like the content to come. It
/// pulses its opacity once per `duration-pulse` and stays still under reduced
/// motion (FR-018). Used instead of a spinner for content.
class Skeleton extends StatefulWidget {
  const Skeleton({
    this.height,
    this.width,
    this.borderRadius = SprintRadius.lgBorder,
    super.key,
  });

  final double? height;
  final double? width;
  final BorderRadius borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  // One full pulse is fade out + fade in, so each leg is half the duration.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SprintMotion.durationPulse ~/ 2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ReducedMotion.of(context)) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = Tween<double>(begin: 1, end: SprintExtras.skeletonMinOpacity)
        .animate(
      CurvedAnimation(parent: _controller, curve: SprintMotion.easeStandard),
    );
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: opacity,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: context.colors.surfaceSunken,
            borderRadius: widget.borderRadius,
          ),
        ),
      ),
    );
  }
}
