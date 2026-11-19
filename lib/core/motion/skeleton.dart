import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/reduced_motion.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

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

/// The shape of the real account card while it loads: a 140 high card with a
/// circle and two lines (Account loading, FR-MYB-03).
class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({super.key});

  static const key0 = ValueKey<String>('skeleton-profile-card');

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      key: key0,
      height: SprintExtras.profileCardHeight,
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: SprintRadius.lgBorder,
      ),
      child: Row(
        children: [
          const Skeleton(
            width: SprintExtras.avatarLarge,
            height: SprintExtras.avatarLarge,
            borderRadius: SprintRadius.fullBorder,
          ),
          const SizedBox(width: SprintSpacing.space4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton(
                  height: SprintSpacing.space5,
                  borderRadius: SprintRadius.smBorder,
                ),
                SizedBox(height: SprintSpacing.space2),
                Skeleton(
                  height: SprintSpacing.space4,
                  width: SprintExtras.mediumFacilitiesPane,
                  borderRadius: SprintRadius.smBorder,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// One settings row while it loads (52 high, a label bar).
class SettingsRowSkeleton extends StatelessWidget {
  const SettingsRowSkeleton({super.key});

  static const key0 = ValueKey<String>('skeleton-settings-row');

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      key: key0,
      height: SprintExtras.settingsRowHeight,
      child: const Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: SprintSpacing.space4,
          vertical: SprintSpacing.space4,
        ),
        child: Skeleton(borderRadius: SprintRadius.smBorder),
      ),
    ),
  );
}
