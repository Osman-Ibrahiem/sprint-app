import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/a11y/focusable_tap.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// One choice chip per active unit, above a single slot grid (clarify Q1,
/// FR-008). Each carries a visible mark, and words for screen readers, for
/// "has places that day". A facility with one unit shows its name only.
class UnitPicker extends StatelessWidget {
  const UnitPicker({
    required this.units,
    required this.selectedId,
    required this.hasPlaces,
    required this.onSelected,
    super.key,
  });

  final List<ScheduleUnit> units;
  final String? selectedId;

  /// Whether a unit has a bookable slot on the selected day.
  final bool Function(String unitId) hasPlaces;
  final ValueChanged<String> onSelected;

  static ValueKey<String> chipKey(String unitId) => ValueKey('unit-$unitId');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    if (units.length == 1) {
      return Semantics(
        container: true,
        label: '${l10n.bookingUnitLabel}: ${units.single.name}',
        child: ExcludeSemantics(
          child: Text(units.single.name, style: context.text.headline),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bookingUnitLabel,
          style: context.text.caption.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: SprintSpacing.space2),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < units.length; i++) ...[
                if (i > 0) const SizedBox(width: SprintSpacing.space2),
                _UnitChip(
                  key: chipKey(units[i].id),
                  unit: units[i],
                  selected: units[i].id == selectedId,
                  hasPlaces: hasPlaces(units[i].id),
                  onTap: () => onSelected(units[i].id),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    super.key,
    required this.unit,
    required this.selected,
    required this.hasPlaces,
    required this.onTap,
  });

  final ScheduleUnit unit;
  final bool selected;
  final bool hasPlaces;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final label = hasPlaces
        ? l10n.bookingUnitHasPlaces(unit.name)
        : l10n.bookingUnitNoPlaces(unit.name);
    final foreground = selected ? colors.onPrimary : colors.ink;
    return FocusableTap(
      label: label,
      selected: selected,
      onTap: onTap,
      builder: (context, hovered) => Container(
        constraints: const BoxConstraints(minHeight: SprintSize.controlHeight),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SprintSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary
              : hovered
              ? colors.surfaceSunken
              : colors.surface,
          borderRadius: SprintRadius.mdBorder,
          border: Border.all(
            color: selected ? colors.primary : colors.controlBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SprintIcon(
              hasPlaces
                  ? PhosphorIconsRegular.checkCircle
                  : PhosphorIconsRegular.prohibit,
              size: SprintSize.iconSm,
              color: selected
                  ? colors.onPrimary
                  : hasPlaces
                  ? colors.success
                  : colors.inkDisabled,
            ),
            const SizedBox(width: SprintSpacing.space2),
            Text(
              unit.name,
              style: context.text.label.copyWith(
                color: hasPlaces || selected ? foreground : colors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
