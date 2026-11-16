import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/catalogue/domain/facility_details.dart';
import 'package:sprint/features/catalogue/presentation/widgets/section_card.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

class TrainersSection extends StatelessWidget {
  const TrainersSection({required this.trainers, super.key});

  final List<TrainerView> trainers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return SectionCard(
      title: l10n.catalogueSectionTrainers,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trainers.isEmpty)
            Text(
              l10n.catalogueTrainersNone,
              style: context.text.body.copyWith(color: colors.inkMuted),
            )
          else ...[
            for (final t in trainers) ...[
              Text(
                t.name ?? l10n.catalogueTrainerUnnamed,
                style: context.text.label,
              ),
              Text(t.bio, style: context.text.body),
              Text(
                l10n.catalogueTrainerCapacity(t.capacity),
                style: context.text.caption.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: SprintSpacing.space3),
            ],
            Text(
              l10n.catalogueTrainerFirst,
              style: context.text.caption.copyWith(color: colors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}
