import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/catalogue/domain/facility_details.dart';
import 'package:sprint/features/catalogue/presentation/details/availability_section.dart';
import 'package:sprint/features/catalogue/presentation/details/hours_section.dart';
import 'package:sprint/features/catalogue/presentation/details/photo_carousel.dart';
import 'package:sprint/features/catalogue/presentation/details/price_section.dart';
import 'package:sprint/features/catalogue/presentation/details/trainers_section.dart';
import 'package:sprint/features/catalogue/presentation/details/units_section.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_not_found.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';
import 'package:sprint/features/catalogue/presentation/widgets/catalogue_error_view.dart';
import 'package:sprint/features/catalogue/presentation/widgets/facility_card_mapper.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The details body: full screen on compact, in the pane on larger windows.
/// The caller owns the pinned app bar (FR-014 – FR-022, FR-028).
class FacilityDetailsView extends ConsumerWidget {
  const FacilityDetailsView({required this.id, super.key});

  final String id;

  static const closedBannerKey = ValueKey<String>('details-closed-banner');
  static const factsKey = ValueKey<String>('details-facts');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(facilityDetailsProvider(id));
    return switch (details) {
      AsyncData(:final value) =>
        value == null ? const FacilityNotFound() : _Loaded(details: value),
      AsyncError() => CatalogueErrorView(
        compact: true,
        onRetry: () => ref.invalidate(facilityDetailsProvider(id)),
      ),
      _ => ListView(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
        children: const [
          Skeleton(height: SprintSize.controlHeight * 3),
          SizedBox(height: SprintSpacing.space4),
          Skeleton(height: SprintSize.controlHeight * 2),
        ],
      ),
    };
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.details});

  final FacilityDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final session = ref.watch(currentSessionProvider);
    final f = details.facility;
    const gap = SizedBox(height: SprintSpacing.space4);

    final facts = <String>[
      l10n.catalogueFactWindow(details.facts.bookingWindowDays),
      if (details.facts.maxRangeHours != null)
        l10n.catalogueFactMaxRange(details.facts.maxRangeHours!),
      if (details.facts.sessionMinutes != null)
        l10n.catalogueFactSession(details.facts.sessionMinutes!),
    ];

    return ListView(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      children: [
        // Photos are not seeded yet; the carousel shows its placeholder.
        const PhotoCarousel(photos: []),
        gap,
        Semantics(
          header: true,
          child: Text(f.name, style: context.text.titleLg),
        ),
        const SizedBox(height: SprintSpacing.space1),
        Text(
          '${typeLabelOf(f.type, l10n)} · ${details.owningUnitName}',
          style: context.text.label.copyWith(color: colors.inkMuted),
        ),
        Text(
          f.location,
          style: context.text.body.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: SprintSpacing.space2),
        Text(f.description, style: context.text.body),
        if (details.hours.closedNow || details.today.closedToday) ...[
          gap,
          Container(
            key: FacilityDetailsView.closedBannerKey,
            padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              border: Border.all(color: colors.warning),
              borderRadius: BorderRadius.circular(SprintSpacing.space2),
            ),
            child: Text(
              details.today.closedToday
                  ? l10n.catalogueClosedToday
                  : l10n.catalogueClosedNow,
              style: context.text.label,
            ),
          ),
        ],
        gap,
        Text(
          facts.join(' · '),
          key: FacilityDetailsView.factsKey,
          style: context.text.caption.copyWith(color: colors.inkMuted),
        ),
        gap,
        AvailabilitySection(facilityId: f.id, today: details.today),
        gap,
        HoursSection(hours: details.hours, closures: details.closures),
        gap,
        PriceSection(
          groups: details.priceGroups,
          isFree: f.isFree,
          session: session,
        ),
        if (f.requiresTrainer) ...[
          gap,
          TrainersSection(trainers: details.trainers),
        ],
        gap,
        UnitsSection(units: details.units),
      ],
    );
  }
}
