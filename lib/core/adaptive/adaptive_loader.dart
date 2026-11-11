import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/reduced_motion.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';

/// Activity indicator on Apple, circular progress elsewhere. For buttons and
/// short operations only; content loads with skeletons (FR-018). It stops
/// spinning under reduced motion.
class AdaptiveLoader extends StatelessWidget {
  const AdaptiveLoader({
    required this.semanticLabel,
    this.size = SprintSize.iconLg,
    super.key,
  });

  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final apple = adaptiveStyleOf(context) == AdaptiveStyle.apple;
    final still = ReducedMotion.of(context);
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: apple
              ? (still
                  ? CupertinoActivityIndicator.partiallyRevealed(
                      radius: size / 2,
                      color: colors.primary,
                      progress: SprintExtras.reducedMotionLoaderProgress,
                    )
                  : CupertinoActivityIndicator(
                      radius: size / 2,
                      color: colors.primary,
                    ))
              : CircularProgressIndicator(
                  color: colors.primary,
                  value: still ? SprintExtras.reducedMotionLoaderProgress : null,
                ),
        ),
      ),
    );
  }
}
