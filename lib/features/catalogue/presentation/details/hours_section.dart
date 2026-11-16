import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/catalogue/domain/closure.dart';
import 'package:sprint/features/catalogue/domain/hours_view.dart';
import 'package:sprint/features/catalogue/presentation/widgets/clock_text.dart';
import 'package:sprint/features/catalogue/presentation/widgets/section_card.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "8:00 ص – 10:00 م", or the closed word.
String hoursLine(DayHours day, AppLocalizations l10n) {
  if (day.isClosed) return l10n.catalogueHoursClosedDay;
  String at(int m) => minutesText(m, l10n);
  return '${at(day.openMinutes!)} – ${at(day.closeMinutes!)}';
}

class HoursSection extends StatelessWidget {
  const HoursSection({required this.hours, required this.closures, super.key});

  final HoursView hours;
  final List<Closure> closures;

  static ValueKey<String> dayKey(int d) => ValueKey<String>('hours-day-$d');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final f = SprintFormat(l10n.localeName);
    return SectionCard(
      title: l10n.catalogueSectionHours,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final day in hours.days)
            Builder(
              builder: (context) {
                final isToday = day.dayOfWeek == hours.todayDayOfWeek;
                final name = l10n.catalogueDayName('${day.dayOfWeek}');
                final line = hoursLine(day, l10n);
                return Semantics(
                  container: true,
                  label: '$name: $line',
                  child: ExcludeSemantics(
                    child: Padding(
                      key: dayKey(day.dayOfWeek),
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: SprintSpacing.space1,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              isToday
                                  ? '$name · ${l10n.catalogueHoursToday}'
                                  : name,
                              style: isToday
                                  ? context.text.label
                                  : context.text.body,
                            ),
                          ),
                          const SizedBox(width: SprintSpacing.space2),
                          Flexible(
                            child: Text(
                              line,
                              textAlign: TextAlign.end,
                              style: (isToday
                                      ? context.text.label
                                      : context.text.body)
                                  .copyWith(
                                color: day.isClosed
                                    ? colors.inkMuted
                                    : colors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          for (final c in closures) ...[
            const SizedBox(height: SprintSpacing.space2),
            Text(
              '${c.reason} · ${l10n.catalogueClosureRange(f.date(c.from), f.date(c.to))}',
              style: context.text.caption.copyWith(color: colors.warning),
            ),
          ],
        ],
      ),
    );
  }
}
