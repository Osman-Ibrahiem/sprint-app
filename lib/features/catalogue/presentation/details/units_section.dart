import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/catalogue/domain/facility_details.dart';
import 'package:sprint/features/catalogue/domain/hours_view.dart';
import 'package:sprint/features/catalogue/presentation/details/hours_section.dart';
import 'package:sprint/features/catalogue/presentation/widgets/section_card.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

class UnitsSection extends StatelessWidget {
  const UnitsSection({required this.units, super.key});

  final List<UnitView> units;

  static ValueKey<String> unitKey(String id) => ValueKey<String>('unit-$id');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return SectionCard(
      title: l10n.catalogueSectionUnits,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final u in units)
            Padding(
              key: unitKey(u.id),
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: SprintSpacing.space1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u.name, style: context.text.body),
                  if (u.ownHours != null)
                    Text(
                      l10n.catalogueUnitOwnHours(_summary(u.ownHours!, l10n)),
                      style: context.text.caption.copyWith(
                        color: colors.inkMuted,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// One line when every open day shares the same times, else the first open
  /// day's times.
  static String _summary(List<DayHours> days, AppLocalizations l10n) {
    final open = days.where((d) => !d.isClosed).toList();
    if (open.isEmpty) return l10n.catalogueHoursClosedDay;
    return hoursLine(open.first, l10n);
  }
}
