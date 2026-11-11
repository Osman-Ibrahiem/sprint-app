import 'package:flutter/widgets.dart';

/// An icon that mirrors in right-to-left layouts when [mirror] is true.
/// Mirror only directional icons (arrows, chevrons, send); never clocks, QR,
/// ticks, logos or icons with digits or Latin letters (README § الأيقونات).
class DirectionalIcon extends StatelessWidget {
  const DirectionalIcon(
    this.icon, {
    this.mirror = true,
    this.size,
    this.color,
    super.key,
  });

  final IconData icon;
  final bool mirror;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final i = Icon(icon, size: size, color: color);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return mirror && rtl ? Transform.flip(flipX: true, child: i) : i;
  }
}
