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
/// failure.
enum BannerTone { hold, neutral, success, info, danger }

/// An icon and a sentence on a soft surface, announced as a live region. Never
/// colour alone: the [icon] always shows. [trailing] (a dismiss action) stays
/// in the semantics tree so a screen reader can reach it.
class Banner extends StatelessWidget {
  const Banner({
    required this.tone,
    required this.text,
    this.icon,
    this.trailing,
    super.key,
  });

  final BannerTone tone;
  final String text;

  /// The icon of this use; a per-tone default when null.
  final IconData? icon;
  final Widget? trailing;

  static const bannerKey = ValueKey<String>('banner');

  (Color, Color) _tint(SprintColors c) => switch (tone) {
    BannerTone.hold => (c.warningSoft, c.ink),
    BannerTone.neutral => (c.surfaceSunken, c.ink),
    BannerTone.success => (c.successSoft, c.success),
    BannerTone.info => (c.primarySoft, c.onPrimarySoft),
    BannerTone.danger => (c.dangerSoft, c.danger),
  };

  IconData get _defaultIcon => switch (tone) {
    BannerTone.hold => PhosphorIconsRegular.info,
    BannerTone.success => PhosphorIconsRegular.checkCircle,
    BannerTone.danger => PhosphorIconsRegular.xCircle,
    _ => PhosphorIconsRegular.info,
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
          SprintIcon(icon ?? _defaultIcon, size: SprintSize.iconMd, color: fg),
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
