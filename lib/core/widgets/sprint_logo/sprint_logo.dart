import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The five logo forms the system ships (contracts/widgets.md).
enum LogoVariant { mark, tilePrimary, tileInk, lockupAr, lockupEn }

/// Draws the Sprint mark and its lockups. The SVGs carry fixed colours in both
/// themes; only the bare mark switches to the primary tile when `volt` would
/// not have enough contrast with the surface behind it.
class SprintLogo extends StatelessWidget {
  const SprintLogo({
    required this.variant,
    this.size,
    this.backgroundColor,
    super.key,
  });

  final LogoVariant variant;

  /// Tile or mark height; clamped to at least [SprintExtras.logoMinSize].
  final double? size;

  /// The surface the logo sits on, used for the bare-mark contrast rule.
  final Color? backgroundColor;

  static const markAsset = 'docs/design-system/logo/sprint-mark.svg';
  static const tilePrimaryAsset =
      'docs/design-system/logo/sprint-tile-primary.svg';
  static const tileInkAsset = 'docs/design-system/logo/sprint-tile-ink.svg';

  static const markKey = ValueKey<String>('logo-mark');

  /// The SVG decision, exposed so the gallery and tests can name it.
  static String assetFor(
    LogoVariant variant, {
    required double backgroundLuminance,
  }) {
    switch (variant) {
      case LogoVariant.mark:
        return _contrastWithVolt(backgroundLuminance) >=
                SprintExtras.logoMarkContrastThreshold
            ? markAsset
            : tilePrimaryAsset;
      case LogoVariant.tilePrimary:
      case LogoVariant.lockupAr:
      case LogoVariant.lockupEn:
        return tilePrimaryAsset;
      case LogoVariant.tileInk:
        return tileInkAsset;
    }
  }

  static double _contrastWithVolt(double backgroundLuminance) {
    final volt = SprintColors.light.volt.computeLuminance();
    final lighter = backgroundLuminance > volt
        ? backgroundLuminance
        : volt;
    final darker = backgroundLuminance > volt
        ? volt
        : backgroundLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }

  bool get _isLockup =>
      variant == LogoVariant.lockupAr || variant == LogoVariant.lockupEn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = (this.size ?? 32).clamp(
      SprintExtras.logoMinSize,
      double.infinity,
    );
    final background = backgroundColor ?? context.colors.bg;
    final asset = assetFor(
      variant,
      backgroundLuminance: background.computeLuminance(),
    );

    final logo = SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );

    if (!_isLockup) {
      return Semantics(
        label: l10n.logoLabel,
        image: true,
        child: ExcludeSemantics(
          child: SizedBox(
            key: markKey,
            width: size,
            height: size,
            child: logo,
          ),
        ),
      );
    }

    return Semantics(
      label: l10n.logoLabel,
      image: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              key: markKey,
              width: size,
              height: size,
              child: logo,
            ),
            const SizedBox(width: SprintSpacing.space3),
            Flexible(
              child: Text(
                l10n.logoLabel,
                style: context.text.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
