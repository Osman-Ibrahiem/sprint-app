import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/slot_chip/slot_chip.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart' as chip;
import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/features/booking/domain/schedule_selection.dart';
import 'package:sprint/features/booking/domain/slot.dart';
import 'package:sprint/features/catalogue/domain/price.dart';

/// The existing [SlotChip] in a wrapping grid, early to late in reading
/// direction (FR-005 – FR-007). The domain slot state decides the look (BR-45
/// is already applied by the availability repository); selection and the range
/// fill come from the address's [selection]. Only bookable slots get a tap.
class SlotGrid extends StatelessWidget {
  const SlotGrid({
    required this.slots,
    required this.units,
    required this.selection,
    this.tier,
    this.onTap,
    super.key,
  });

  final List<ScheduleSlot> slots;
  final Map<String, ScheduleUnit> units;
  final ScheduleSelection selection;

  /// The signed-in person's tier, to speak the price; null for a guest.
  final PriceTier? tier;
  final ValueChanged<ScheduleSlot>? onTap;

  bool _isSelected(ScheduleSlot s) =>
      selection.hasTime &&
      selection.unitId == s.unitId &&
      (s.startMinutes == selection.startMinutes ||
          s.endMinutes == selection.endMinutes);

  bool _inRange(ScheduleSlot s) =>
      selection.hasTime &&
      selection.unitId == s.unitId &&
      s.startMinutes > selection.startMinutes! &&
      s.endMinutes < selection.endMinutes!;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // As many columns as fit at the chip's minimum width (SlotChip README),
        // each stretched to share the row. The chip itself centres inside its
        // box and would otherwise take the whole row.
        const gap = SprintSpacing.space2;
        const minWidth = SprintExtras.slotChipMinWidth;
        final columns = math.max(
          1,
          ((constraints.maxWidth + gap) / (minWidth + gap)).floor(),
        );
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final s in slots) SizedBox(width: width, child: _chip(s)),
          ],
        );
      },
    );
  }

  Widget _chip(ScheduleSlot s) {
    final unit = units[s.unitId];
    final shared = unit?.isShared ?? false;
    final selected = _isSelected(s);
    final state = selected
        ? chip.SlotState.selected
        : switch (s.slot.state) {
            SlotState.available => chip.SlotState.available,
            SlotState.fewLeft => chip.SlotState.fewLeft,
            SlotState.full => chip.SlotState.full,
            SlotState.past || SlotState.closed => chip.SlotState.past,
          };
    return SlotChip(
      key: ValueKey('slot-${s.unitId}-${s.startMinutes}'),
      start: CairoTime.toCairo(s.slot.start),
      state: state,
      fewLeftThreshold: unit?.fewLeftThreshold ?? 0,
      remaining: shared ? s.slot.remaining : null,
      price: tier == null ? null : unit?.priceFor(tier!),
      rangeFill: _inRange(s),
      onSelected: s.isBookable && onTap != null ? () => onTap!(s) : null,
    );
  }
}
