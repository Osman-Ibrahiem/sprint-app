import 'package:flutter/material.dart';
import 'package:sprint/core/widgets/day_strip/day_strip.dart';
import 'package:sprint/core/widgets/day_strip/day_strip_day.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// A sample booking window, read through the settings repository by the
/// gallery screen, including a closed day.
class DayStripSection extends StatefulWidget {
  const DayStripSection({
    required this.l10n,
    required this.bookingWindowDays,
    super.key,
  });

  final AppLocalizations l10n;
  final int bookingWindowDays;

  @override
  State<DayStripSection> createState() => _DayStripSectionState();
}

class _DayStripSectionState extends State<DayStripSection> {
  late final DateTime _today = _dateOnly(DateTime.now());
  late final List<DayStripDay> _days = [
    for (var i = 0; i < widget.bookingWindowDays.clamp(1, 30); i++)
      DayStripDay(
        date: _today.add(Duration(days: i)),
        hasAvailability: i % 3 != 1,
        isClosed: i == 2 || i == 9,
      ),
  ];
  DateTime? _selected;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _selected = DayStrip.defaultSelection(_days)?.date;
  }

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: widget.l10n.galleryDayStripSection,
      caption:
          '${widget.l10n.gallerySampleNote} · ${_days.length}/${widget.bookingWindowDays}',
      children: [
        DayStrip(
          days: _days,
          today: _today,
          selected: _selected,
          onSelected: (day) => setState(() => _selected = day.date),
        ),
      ],
    );
  }
}
