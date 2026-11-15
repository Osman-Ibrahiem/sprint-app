import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/slot_chip/slot_chip.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Every chip state, a shared and an exclusive unit, and a range fill.
class SlotChipSection extends StatefulWidget {
  const SlotChipSection({
    required this.l10n,
    required this.fewLeftThreshold,
    super.key,
  });

  final AppLocalizations l10n;
  final int fewLeftThreshold;

  @override
  State<SlotChipSection> createState() => _SlotChipSectionState();
}

class _SlotChipSectionState extends State<SlotChipSection> {
  SlotState _selected = SlotState.available;
  final _start = DateTime(2026, 11, 10, 18);

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return GallerySection(
      title: l10n.gallerySlotChipSection,
      caption:
          '${l10n.gallerySampleNote} · ${l10n.slotFewLeft(widget.fewLeftThreshold)}',
      children: [
        for (final state in SlotState.values)
          GalleryRow(
            label: switch (state) {
              SlotState.available => l10n.slotAvailableWord,
              SlotState.selected => l10n.slotSelected,
              SlotState.fewLeft => l10n.slotFewLeft(2),
              SlotState.full => l10n.slotFull,
              SlotState.past => l10n.slotPast,
            },
            child: SlotChip(
              start: _start,
              state: state,
              remaining: state == SlotState.available
                  ? 5
                  : state == SlotState.fewLeft
                      ? 2
                      : state == SlotState.full
                          ? 0
                          : null,
              fewLeftThreshold: widget.fewLeftThreshold,
              price: 120,
              onSelected: () => setState(() => _selected = SlotState.selected),
            ),
          ),
        GalleryRow(
          label: l10n.slotAvailableWord,
          child: Wrap(
            spacing: SprintSpacing.space2,
            runSpacing: SprintSpacing.space2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SlotChip(
                start: _start,
                state: SlotState.available,
                remaining: null,
                fewLeftThreshold: widget.fewLeftThreshold,
                onSelected: () {},
              ),
              SlotChip(
                start: _start,
                state: _selected,
                remaining: 5,
                fewLeftThreshold: widget.fewLeftThreshold,
                rangeFill: true,
                onSelected: () {},
              ),
              SlotChip(
                start: _start.add(const Duration(hours: 1)),
                state: SlotState.selected,
                remaining: 5,
                fewLeftThreshold: widget.fewLeftThreshold,
                onSelected: () {},
              ),
              SlotChip(
                start: _start.add(const Duration(hours: 2)),
                state: SlotState.available,
                remaining: 5,
                fewLeftThreshold: widget.fewLeftThreshold,
                rangeFill: true,
                onSelected: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
