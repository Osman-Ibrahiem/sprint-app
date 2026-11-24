import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/adaptive_haptics.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/reduced_motion.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// A bookable time with its state written in words, so colour is never the
/// only signal (SlotChip README, FR-023 – FR-027).
class SlotChip extends StatelessWidget {
  const SlotChip({
    required this.start,
    required this.state,
    required this.fewLeftThreshold,
    this.remaining,
    this.price,
    this.onSelected,
    super.key,
  });

  /// Derives the state with [resolveSlotState] so every screen agrees.
  factory SlotChip.resolved({
    required DateTime start,
    required int fewLeftThreshold,
    int? remaining,
    num? price,
    VoidCallback? onSelected,
    bool isPast = false,
    bool isSelected = false,
    bool isFull = false,
    bool isInRange = false,
    Key? key,
  }) {
    return SlotChip(
      key: key,
      start: start,
      state: resolveSlotState(
        remaining: remaining,
        fewLeftThreshold: fewLeftThreshold,
        isPast: isPast,
        isSelected: isSelected,
        isFull: isFull,
        isInRange: isInRange,
      ),
      fewLeftThreshold: fewLeftThreshold,
      remaining: remaining,
      price: price,
      onSelected: onSelected,
    );
  }

  final DateTime start;
  final SlotState state;

  /// The remaining places on a shared unit; null on an exclusive one.
  final int? remaining;

  /// Spoken only ("الساعة 6 مساءً، فاضل مكان واحد، 120 ج.م").
  final num? price;

  final int fewLeftThreshold;
  final VoidCallback? onSelected;

  static const visualKey = ValueKey<String>('slot-chip-visual');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);

    final (background, foreground, border, word) = switch (state) {
      SlotState.available => (
        colors.surface,
        colors.ink,
        Border.all(
          color: colors.controlBorder,
          width: SprintExtras.hairlineWidth,
        ),
        remaining == null ? null : l10n.slotAvailablePlaces(remaining!),
      ),
      SlotState.selected => (
        colors.primary,
        colors.onPrimary,
        null,
        l10n.slotSelected,
      ),
      SlotState.fewLeft => (
        colors.volt,
        colors.onVolt,
        null,
        l10n.slotFewLeft(remaining ?? 0),
      ),
      SlotState.full => (
        colors.surfaceSunken,
        colors.inkMuted,
        null,
        l10n.slotFull,
      ),
      SlotState.past => (
        null,
        colors.inkDisabled,
        Border.all(color: colors.line, width: SprintExtras.hairlineWidth),
        l10n.slotPast,
      ),
      // Between the two ends of a free range: tinted and named, never colour
      // alone (decision 3, refactor 000).
      SlotState.inRange => (
        colors.primarySoft,
        colors.onPrimarySoft,
        Border.all(
          color: colors.controlBorder,
          width: SprintExtras.hairlineWidth,
        ),
        l10n.slotInRange,
      ),
    };

    final spokenState = switch (state) {
      SlotState.available =>
        remaining == null
            ? l10n.slotAvailableWord
            : l10n.slotAvailablePlaces(remaining!),
      SlotState.selected => l10n.slotSelected,
      SlotState.fewLeft => l10n.slotFewLeftSpoken(remaining ?? 0),
      SlotState.full => l10n.slotFull,
      SlotState.past => l10n.slotPast,
      SlotState.inRange => l10n.slotInRange,
    };
    final spokenTime =
        '${start.hour % 12 == 0 ? 12 : start.hour % 12} '
        '${start.hour >= 12 ? l10n.timePm : l10n.timeAm}';
    final spoken = price == null
        ? l10n.slotSpoken(spokenTime, spokenState)
        : l10n.slotSpokenWithPrice(
            spokenTime,
            spokenState,
            format.price(price!),
          );

    final pressable = state != SlotState.full && state != SlotState.past;
    final duration = ReducedMotion.fade(context, SprintMotion.durationBase);

    return AdaptivePressable(
      label: spoken,
      selected: state == SlotState.selected,
      liveRegion: true,
      onTap: pressable && onSelected != null
          ? () {
              AdaptiveHaptics.selection(context);
              onSelected!();
            }
          : null,
      pressedColor: colors.primaryPressed,
      hoverColor: colors.surfaceSunken,
      borderRadius: SprintRadius.smBorder,
      builder: (context, pressState) => AnimatedContainer(
        key: visualKey,
        duration: duration,
        constraints: const BoxConstraints(
          minWidth: SprintExtras.slotChipMinWidth,
          minHeight: SprintExtras.slotChipMinHeight,
        ),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SprintSpacing.space3,
          vertical: SprintSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: SprintRadius.smBorder,
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              format.localTime(start),
              style: context.text.number.copyWith(color: foreground),
            ),
            if (word != null) ...[
              const SizedBox(height: SprintSpacing.space1),
              AnimatedSwitcher(
                duration: duration,
                child: Text(
                  word,
                  key: ValueKey<String>(word),
                  style: context.text.micro.copyWith(color: foreground),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
