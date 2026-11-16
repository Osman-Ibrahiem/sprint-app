import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/facility_card/facility_card.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';
import 'package:sprint/features/catalogue/domain/home_content.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';
import 'package:sprint/features/catalogue/presentation/widgets/catalogue_error_view.dart';
import 'package:sprint/features/catalogue/presentation/widgets/facility_card_mapper.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The first screen: a guest discovers facility types and featured facilities
/// and reaches any facility in two taps (FR-001, FR-002, FR-006).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static ValueKey<String> typeChipKey(FacilityType type) =>
      ValueKey<String>('home-type-chip-${type.name}');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final content = ref.watch(homeContentProvider);
    final session = ref.watch(currentSessionProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.only(
          start: SprintSpacing.space4,
          end: SprintSpacing.space4,
          top: SprintSpacing.space6,
          bottom: SprintSpacing.space8,
        ),
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.catalogueHomeTitle,
              style: context.text.display,
            ),
          ),
          if (session.isGuest) ...[
            const SizedBox(height: SprintSpacing.space2),
            Text(
              l10n.catalogueHomeGuestHint,
              style: context.text.body.copyWith(color: context.colors.inkMuted),
            ),
          ],
          const SizedBox(height: SprintSpacing.space6),
          content.when(
            data: (value) => _Loaded(
              content: value,
              session: session,
            ),
            loading: _Loading.new,
            error: (error, stack) => CatalogueErrorView(
              onRetry: () => ref.invalidate(homeContentProvider),
            ),
          ),
        ],
      ),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.content, required this.session});

  final HomeContent content;
  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(facilityFilterProvider);
    final cards = [
      for (final summary in content.featured)
        _facilityCard(context, ref, summary),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (content.types.isNotEmpty) ...[
          _SectionTitle(text: l10n.catalogueHomeTypesTitle),
          const SizedBox(height: SprintSpacing.space2),
          _TypeChips(
            types: content.types,
            selected: filter.type,
            onSelected: (type) {
              ref.read(facilityFilterProvider.notifier).setType(type);
              context.go(AppPaths.facilities);
            },
          ),
          const SizedBox(height: SprintSpacing.space6),
        ],
        _SectionTitle(text: l10n.catalogueHomeFeaturedTitle),
        const SizedBox(height: SprintSpacing.space3),
        _CardGrid(children: cards),
        const SizedBox(height: SprintSpacing.space4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SprintButton(
            label: l10n.catalogueHomeSeeAll,
            variant: SprintButtonVariant.secondary,
            icon: const SprintButtonIcon(
              PhosphorIconsRegular.arrowRight,
              position: SprintButtonIconPosition.end,
              mirrorInRtl: true,
            ),
            onPressed: () => context.go(AppPaths.facilities),
          ),
        ),
      ],
    );
  }

  Widget _facilityCard(
    BuildContext context,
    WidgetRef ref,
    FacilitySummary summary,
  ) {
    final l10n = AppLocalizations.of(context);
    final inputs = facilityCardInputs(
      summary: summary,
      session: session,
      l10n: l10n,
    );
    return FacilityCard(
      kind: inputs.kind,
      name: inputs.name,
      owningUnit: inputs.owningUnit,
      unitCount: inputs.unitCount,
      tags: inputs.tags,
      availability: inputs.availability,
      availableCount: inputs.availableCount,
      price: inputs.price,
      onTap: () => context.go(AppPaths.facilityDetails(summary.facility.id)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: context.text.titleLg),
    );
  }
}

class _TypeChips extends StatelessWidget {
  const _TypeChips({
    required this.types,
    required this.selected,
    required this.onSelected,
  });

  final List<FacilityType> types;
  final FacilityType? selected;
  final ValueChanged<FacilityType> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final type in types)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: SprintSpacing.space2),
              child: _TypeChip(
                key: HomeScreen.typeChipKey(type),
                type: type,
                label: typeLabelOf(type, l10n),
                icon: _typeIcon(type),
                selected: type == selected,
                onTap: () => onSelected(type),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final FacilityType type;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AdaptivePressable(
      label: label,
      selected: selected,
      onTap: onTap,
      restingColor: selected ? colors.primarySoft : colors.surface,
      hoverColor: selected ? colors.primarySoft : colors.surfaceSunken,
      borderRadius: SprintRadius.fullBorder,
      builder: (context, state) => Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SprintSpacing.space4,
          vertical: SprintSpacing.space2,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? colors.primary : colors.line),
          borderRadius: SprintRadius.fullBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: SprintSize.iconMd,
              color: selected ? colors.onPrimarySoft : colors.inkMuted,
            ),
            const SizedBox(width: SprintSpacing.space2),
            Text(
              label,
              style: context.text.label.copyWith(
                color: selected ? colors.onPrimarySoft : colors.ink,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: SprintSpacing.space1),
              Icon(
                PhosphorIconsRegular.check,
                size: SprintSize.iconSm,
                color: colors.onPrimarySoft,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One column on compact, up to three on larger windows (FR-030, SC-005).
class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final columns = switch (WindowSize.of(context)) {
      WindowSize.compact => 1,
      WindowSize.medium => 2,
      WindowSize.expanded || WindowSize.large => 3,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = SprintSpacing.space4;
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return _CardGrid(
      children: const [
        FacilityCard.loading(),
        FacilityCard.loading(),
        FacilityCard.loading(),
      ],
    );
  }
}

IconData _typeIcon(FacilityType type) => switch (type) {
      FacilityType.swimming => PhosphorIconsRegular.swimmingPool,
      FacilityType.football => PhosphorIconsRegular.soccerBall,
      FacilityType.gym => PhosphorIconsRegular.barbell,
      FacilityType.tennis => PhosphorIconsRegular.tennisBall,
      FacilityType.hall => PhosphorIconsRegular.warehouse,
      FacilityType.training => PhosphorIconsRegular.chalkboardTeacher,
    };
