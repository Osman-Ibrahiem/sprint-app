import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint/core/adaptive/adaptive_haptics.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/adaptive/adaptive_traits.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
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
            _DayPill(
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
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(width: SprintSpacing.space2),
                      SizedBox(
                        width: SprintSpacing.space16,
                        child: items[i],
                      ),
                    ],
                  ],
                ),
              )
            : Row(
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

class _DayPill extends StatelessWidget {
  const _DayPill({
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

    final inactive = day.isClosed;
    final nameColor = selected
        ? colors.onPrimary
        : isToday
            ? colors.primary
            : inactive
                ? colors.inkDisabled
                : colors.inkMuted;
    final numberColor = selected
        ? colors.onPrimary
        : inactive
            ? colors.inkDisabled
            : colors.ink;

    return AdaptivePressable(
      label: spoken,
      selected: selected,
      liveRegion: true,
      focusNode: focusNode,
      onTap: onTap,
      restingColor: selected ? colors.primary : colors.surface,
      pressedColor: colors.primaryPressed,
      hoverColor: colors.surfaceSunken,
      borderRadius: SprintRadius.fullBorder,
      builder: (context, state) => Container(
        constraints: const BoxConstraints(
          minHeight: SprintExtras.dayPillHeight,
        ),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SprintSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: SprintRadius.fullBorder,
          border: selected
              ? null
              : Border.all(
                  color: colors.line,
                  width: SprintExtras.hairlineWidth,
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayName,
              style: context.text.micro.copyWith(color: nameColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: SprintSpacing.space1),
            Text(
              format.number(day.date.day),
              style: context.text.number.copyWith(color: numberColor),
            ),
            const SizedBox(height: SprintSpacing.space1),
            if (!day.isClosed)
              Container(
                width: SprintSpacing.space1,
                height: SprintSpacing.space1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? colors.onPrimary
                      : day.hasAvailability
                          ? colors.success
                          : Colors.transparent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
