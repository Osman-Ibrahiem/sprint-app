import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

/// The five tones of the shared banner (Banner README): `hold` is a payment
/// or notice on `warning-soft`, `neutral` is quiet, `success` is money on its
/// way, `info` is a note on `primary-soft`, `danger` is a cancellation or
/// failure. Each tone has its own icon (decision U4 of refactor 000).
enum SprintBannerTone { hold, neutral, success, info, danger }

/// An icon and a sentence on a soft surface, announced as a live region
/// (Figma `Banner`). Never colour alone: the tone's icon always shows. [trailing] (a dismiss action) stays
/// in the semantics tree so a screen reader can reach it.
class SprintBanner extends StatelessWidget {
  const SprintBanner({
    required this.tone,
    required this.text,
    this.icon,
    this.trailing,
    super.key,
  });

  final SprintBannerTone tone;
  final String text;

  /// A more specific icon of the same meaning for this use (a clock for a
  /// cutoff); the tone's own icon ([iconFor]) when null.
  final IconData? icon;
  final Widget? trailing;

  static const bannerKey = ValueKey<String>('banner');

  (Color, Color) _tint(SprintColors c) => switch (tone) {
    SprintBannerTone.hold => (c.warningSoft, c.ink),
    SprintBannerTone.neutral => (c.surfaceSunken, c.ink),
    SprintBannerTone.success => (c.successSoft, c.success),
    SprintBannerTone.info => (c.primarySoft, c.onPrimarySoft),
    SprintBannerTone.danger => (c.dangerSoft, c.danger),
  };

  /// The icon each tone carries (decision U4): success check-circle, danger
  /// x-circle, info and neutral info, hold hourglass.
  static IconData iconFor(SprintBannerTone tone) => switch (tone) {
    SprintBannerTone.hold => PhosphorIconsRegular.hourglass,
    SprintBannerTone.success => PhosphorIconsRegular.checkCircle,
    SprintBannerTone.danger => PhosphorIconsRegular.xCircle,
    SprintBannerTone.info ||
    SprintBannerTone.neutral => PhosphorIconsRegular.info,
  };

  @override
  Widget build(BuildContext context) {
    final (fill, fg) = _tint(context.colors);
    return Container(
      key: bannerKey,
      constraints: const BoxConstraints(minHeight: SprintSize.controlHeight),
      padding: EdgeInsetsDirectional.only(
        start: SprintSpacing.space3,
        end: trailing == null ? SprintSpacing.space3 : 0,
        top: trailing == null ? SprintSpacing.space3 : SprintSpacing.space1,
        bottom: trailing == null ? SprintSpacing.space3 : SprintSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: SprintRadius.mdBorder,
      ),
      child: Row(
        children: [
          SprintIcon(icon ?? iconFor(tone), size: SprintSize.iconMd, color: fg),
          const SizedBox(width: SprintSpacing.space2),
          Expanded(
            child: Semantics(
              liveRegion: true,
              container: true,
              label: text,
              child: ExcludeSemantics(
                child: Text(text, style: context.text.body.copyWith(color: fg)),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
