import 'package:flutter/widgets.dart';

/// The icon for everything that is not directional: ticks, magnifier, clock,
/// calendar, share, link, QR and so on. They must never mirror in RTL
/// (CLAUDE.md: mirror directional icons only; README § الأيقونات).
///
/// Every Phosphor glyph is declared with `matchTextDirection: true`, so a
/// plain [Icon] flips itself in RTL. Fixing the icon's own direction to LTR
/// stops that. Arrows and chevrons go through `DirectionalIcon` instead,
/// which is the only other place that builds a raw [Icon].
class SprintIcon extends StatelessWidget {
  const SprintIcon(
    this.icon, {
    this.size,
    this.color,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Icon(
    icon,
    size: size,
    color: color,
    semanticLabel: semanticLabel,
    textDirection: TextDirection.ltr,
  );
}
