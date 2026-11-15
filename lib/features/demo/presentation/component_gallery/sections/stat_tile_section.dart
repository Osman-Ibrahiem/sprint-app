import 'package:flutter/material.dart';
import 'package:sprint/core/widgets/stat_tile/stat_tile.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Up, down, flat and no comparison, with money and rate values, and the
/// loading form.
class StatTileSection extends StatelessWidget {
  const StatTileSection({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    const tileWidth = 180.0;
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final comparison = ar ? 'عن الأسبوع اللي فات' : 'vs last week';
    final money = ar ? 'ج.م' : 'EGP';
    final label = ar ? 'الإيراد' : 'Revenue';
    final period = ar ? 'الأسبوع ده' : 'This week';
    Widget tile(Widget child) => SizedBox(width: tileWidth, child: child);
    return GallerySection(
      title: l10n.galleryStatTileSection,
      caption: l10n.gallerySampleNote,
      children: [
        tile(StatTile(
          label: label,
          period: period,
          value: '1,250,000',
          unit: money,
          delta: StatDelta(trend: StatTrend.up, text: '12%', comparison: comparison),
        )),
        tile(StatTile(
          label: ar ? 'الإلغاءات' : 'Cancellations',
          period: period,
          value: '8%',
          delta: StatDelta(
            trend: StatTrend.up,
            text: '3%',
            comparison: comparison,
            higherIsBetter: false,
          ),
          onTap: () {},
        )),
        tile(StatTile(
          label: ar ? 'نسبة الإشغال' : 'Occupancy',
          period: period,
          value: '73%',
          delta: StatDelta(trend: StatTrend.down, text: '5%', comparison: comparison),
        )),
        tile(StatTile(
          label: ar ? 'الحجوزات' : 'Bookings',
          period: period,
          value: '412',
          delta: StatDelta(trend: StatTrend.flat, text: '0%', comparison: comparison),
        )),
        tile(StatTile(label: label, period: period, value: '15,400', unit: money)),
        tile(const StatTile.loading()),
      ],
    );
  }
}
