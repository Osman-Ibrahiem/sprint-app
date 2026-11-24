import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint/core/adaptive/adaptive_haptics.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/adaptive/adaptive_traits.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/day_strip/day_strip_day.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The booking window as a strip of days (DayStrip README, FR-028 – FR-031).
class DayStrip extends StatefulWidget {
  const DayStrip({
    required this.days,
    required this.today,
    required this.onSelected,
    this.selected,
    super.key,
  }) : assert(days.length > 0);

  final List<DayStripDay> days;
  final DateTime today;
  final DateTime? selected;
  final ValueChanged<DayStripDay> onSelected;

  /// One day's whole item (its tail when selected), its circle and its name.
  static ValueKey<String> itemKey(DateTime d) =>
      ValueKey<String>('day-item-${d.year}-${d.month}-${d.day}');
  static ValueKey<String> circleKey(DateTime d) =>
      ValueKey<String>('day-circle-${d.year}-${d.month}-${d.day}');
  static ValueKey<String> nameKey(DateTime d) =>
      ValueKey<String>('day-name-${d.year}-${d.month}-${d.day}');

  /// The first day with room, else the first open day, else null.
  static DayStripDay? defaultSelection(List<DayStripDay> days) {
    for (final day in days) {
      if (!day.isClosed && day.hasAvailability) return day;
    }
    for (final day in days) {
      if (!day.isClosed) return day;
    }
    return null;
  }

  @override
  State<DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<DayStrip> {
  final List<FocusNode> _nodes = [];
  final GlobalKey _selectedKey = GlobalKey();
  int _focused = 0;

  @override
  void initState() {
    super.initState();
    _syncNodes();
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
  }

  @override
  void didUpdateWidget(DayStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
    if (oldWidget.selected != widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
    }
  }

  void _syncNodes() {
    while (_nodes.length < widget.days.length) {
      final index = _nodes.length;
      _nodes.add(
        FocusNode(debugLabel: 'day-$index')
          ..addListener(() {
            if (_nodes[index].hasFocus) setState(() => _focused = index);
          }),
      );
    }
    assert(
      widget.days.isEmpty ||
          _asDate(widget.days.first.date) == _asDate(widget.today),
      'the first day must be today',
    );
    for (var i = 1; i < widget.days.length; i++) {
      assert(
        _asDate(widget.days[i].date)
                .difference(_asDate(widget.days[i - 1].date))
                .inDays ==
            1,
        'days must be consecutive',
      );
    }
    for (final day in widget.days) {
      assert(!_asDate(day.date).isBefore(_asDate(widget.today)),
          'no day before today');
    }
  }

  DateTime _asDate(DateTime d) => DateTime(d.year, d.month, d.day);

  void _revealSelected() {
    final context = _selectedKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, alignment: 0.5);
    }
  }

  void _moveFocus(int delta) {
    if (_nodes.isEmpty) return;
    final next = (_focused + delta) % _nodes.length;
    _nodes[(next + _nodes.length) % _nodes.length].requestFocus();
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final traits = AdaptiveTraits.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final chosen = widget.selected ??
        DayStrip.defaultSelection(widget.days)?.date;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            WindowSize.fromWidth(constraints.maxWidth) == WindowSize.compact;
        final items = [
          for (var i = 0; i < widget.days.length; i++)
            _DayItem(
              key: _isSameDay(widget.days[i].date, chosen) ? _selectedKey : null,
              day: widget.days[i],
              today: widget.today,
              selected: _isSameDay(widget.days[i].date, chosen),
              focusNode: _nodes[i],
              onTap: widget.days[i].isClosed
                  ? null
                  : () {
                      AdaptiveHaptics.selection(context);
                      widget.onSelected(widget.days[i]);
                    },
            ),
        ];

        final strip = compact
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: SprintSpacing.space2),
                      // At least 64 wide; wider when a name or a 200% number
                      // needs it, never cut.
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: SprintSpacing.space16,
                        ),
                        child: items[i],
                      ),
                    ],
                  ],
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: SprintSpacing.space2),
                    Expanded(child: items[i]),
                  ],
                ],
              );

        return CallbackShortcuts(
          bindings: traits.keyboardFocusRing
              ? {
                  const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                      _moveFocus(rtl ? -1 : 1),
                  const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                      _moveFocus(rtl ? 1 : -1),
                }
              : const {},
          child: strip,
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime? b) =>
      b != null && a.year == b.year && a.month == b.month && a.day == b.day;
}

/// One day of the strip, v2 (decision 18 of refactor 000, approved
/// 2026-11-24; Figma "DayItem v2"): the date number alone in a circle of at
/// least 48, the day name under it and the availability dot under the name.
///
/// - Selected: a `primary` tail behind circle and name; the circle stays
///   `surface` with the number in `primary`, the name and dot `on-primary`.
/// - Today: a `primary` ring and the name in `primary`.
/// - Closed: a dashed `control-border` circle, disabled text, no dot.
///
/// Large text: the number scales fully (the circle grows with it); the name's
/// scale stops at `navLabelMaxTextScale` (1.3) so the longest name
/// ("الأربعاء", "النهارده") fits whole, and it keeps at least `space-2` on
/// each side inside the tail, which may grow a little past the circle.
class _DayItem extends StatelessWidget {
  const _DayItem({
    required this.day,
    required this.today,
    required this.selected,
    required this.focusNode,
    required this.onTap,
    super.key,
  });

  final DayStripDay day;
  final DateTime today;
  final bool selected;
  final FocusNode focusNode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);
    final isToday = day.date.year == today.year &&
        day.date.month == today.month &&
        day.date.day == today.day;

    final dayName = isToday
        ? l10n.dayToday
        : format.dayName(day.date, short: true);
    final state = day.isClosed
        ? l10n.dayClosed
        : day.hasAvailability
            ? l10n.dayHasRoom
            : l10n.slotAvailableWord;
    final spoken = l10n.daySpoken(dayName, state);

    final closed = day.isClosed;
    final nameColor = selected
        ? colors.onPrimary
        : closed
            ? colors.inkDisabled
            : isToday
                ? colors.primary
                : colors.inkMuted;
    final numberColor = closed
        ? colors.inkDisabled
        : selected
            ? colors.primary
            : colors.ink;

    // The circle grows with the number so it stays a circle at 200%.
    final scaler = MediaQuery.textScalerOf(context);
    final number = context.text.number;
    final numberLine = scaler.scale(number.fontSize!) * number.height!;
    final diameter = math.max(
      SprintSize.controlHeight,
      numberLine + SprintSpacing.space2 * 2,
    );

    final ringColor = isToday && !closed ? colors.primary : colors.controlBorder;
    final ringWidth = isToday && !closed
        ? SprintExtras.selectedBorderWidth
        : SprintExtras.hairlineWidth;

    final Widget circle = SizedBox.square(
      key: DayStrip.circleKey(day.date),
      dimension: diameter,
      child: CustomPaint(
        painter: closed
            ? _DashedCirclePainter(
                color: colors.controlBorder,
                width: SprintExtras.hairlineWidth,
              )
            : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: closed ? null : colors.surface,
            border: closed
                ? null
                : Border.all(color: ringColor, width: ringWidth),
          ),
          child: Center(
            child: Text(
              format.number(day.date.day),
              style: number.copyWith(color: numberColor),
            ),
          ),
        ),
      ),
    );

    return AdaptivePressable(
      label: spoken,
      selected: selected,
      liveRegion: true,
      focusNode: focusNode,
      onTap: onTap,
      restingColor: selected ? colors.primary : null,
      pressedColor: selected ? colors.primaryPressed : colors.surfaceSunken,
      hoverColor: selected ? colors.primaryHover : colors.surfaceSunken,
      borderRadius: SprintRadius.fullBorder,
      builder: (context, _) => Padding(
        key: DayStrip.itemKey(day.date),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SprintSpacing.space2,
          vertical: SprintSpacing.space1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            circle,
            const SizedBox(height: SprintSpacing.space1),
            MediaQuery.withClampedTextScaling(
              maxScaleFactor: SprintExtras.navLabelMaxTextScale,
              child: Text(
                dayName,
                key: DayStrip.nameKey(day.date),
                textAlign: TextAlign.center,
                style: context.text.micro.copyWith(color: nameColor),
              ),
            ),
            const SizedBox(height: SprintSpacing.space1),
            Container(
              width: SprintSpacing.space1,
              height: SprintSpacing.space1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: closed || !day.hasAvailability
                    ? Colors.transparent
                    : selected
                        ? colors.onPrimary
                        : colors.success,
              ),
            ),
            const SizedBox(height: SprintSpacing.space1),
          ],
        ),
      ),
    );
  }
}

/// The closed day's circle: a dashed `control-border` outline.
class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - width) / 2;
    final center = size.center(Offset.zero);
    final circumference = 2 * math.pi * radius;
    const dash = SprintSpacing.space1;
    const gap = SprintSpacing.space1;
    final count = (circumference / (dash + gap)).floor();
    final step = 2 * math.pi / count;
    final sweep = step * dash / (dash + gap);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final rect = Rect.fromCircle(center: center, radius: radius);
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, i * step, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) =>
      old.color != color || old.width != width;
}
