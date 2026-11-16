import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/facility_card/facility_card_data.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/catalogue/domain/today_availability.dart';
import 'package:sprint/features/catalogue/presentation/widgets/section_card.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

class AvailabilitySection extends StatelessWidget {
  const AvailabilitySection({
    required this.facilityId,
    required this.today,
    super.key,
  });

  final String facilityId;
  final TodayAvailability today;

  static const actionKey = ValueKey<String>('schedule-action');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final word = today.closedToday
        ? l10n.catalogueClosedToday
        : switch (today.level) {
            AvailabilityLevel.plenty => l10n.facilityAvailabilityPlenty,
            AvailabilityLevel.few => l10n.facilityAvailabilityFew,
            AvailabilityLevel.none => l10n.facilityAvailabilityNone,
          };
    return SectionCard(
      title: l10n.catalogueSectionAvailability,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(word, style: context.text.body),
          const SizedBox(height: SprintSpacing.space3),
          SprintButton(
            key: actionKey,
            label: l10n.catalogueScheduleAction,
            icon: const SprintButtonIcon(
              PhosphorIconsRegular.arrowRight,
              position: SprintButtonIconPosition.end,
              mirrorInRtl: true,
            ),
            onPressed: () => context.go(AppPaths.facilitySchedule(facilityId)),
          ),
        ],
      ),
    );
  }
}
