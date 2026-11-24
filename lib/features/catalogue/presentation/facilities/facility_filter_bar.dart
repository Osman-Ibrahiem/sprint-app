import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/widgets/filter_chip/sprint_filter_chip.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';
import 'package:sprint/features/catalogue/presentation/search/search_providers.dart';
import 'package:sprint/features/catalogue/presentation/widgets/facility_card_mapper.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Type, owning unit and free / paid filters, the active filters as removable
/// chips, "clear all" and the result count (FR-008 – FR-010).
class FacilityFilterBar extends ConsumerWidget {
  const FacilityFilterBar({super.key});

  static const clearAllKey = ValueKey<String>('filter-clear-all');
  static const countKey = ValueKey<String>('filter-count');
  static ValueKey<String> typeKey(FacilityType? t) =>
      ValueKey<String>('filter-type-${t?.name ?? 'all'}');
  static ValueKey<String> unitKey(String? id) =>
      ValueKey<String>('filter-unit-${id ?? 'all'}');
  static ValueKey<String> freeKey(bool? f) => ValueKey<String>(
    'filter-free-${f == null
        ? 'any'
        : f
        ? 'free'
        : 'paid'}',
  );
  static ValueKey<String> activeKey(String name) =>
      ValueKey<String>('filter-active-$name');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(facilityFilterProvider);
    final notifier = ref.read(facilityFilterProvider.notifier);
    final units = ref.watch(owningUnitOptionsProvider).value ?? const [];
    final count = ref.watch(searchedSummariesProvider).value?.length;

    final unitName = filter.owningUnitId == null
        ? null
        : units
              .where((u) => u.id == filter.owningUnitId)
              .map((u) => u.name)
              .firstOrNull;

    final active = <(String, VoidCallback)>[
      if (filter.type != null)
        (typeLabelOf(filter.type!, l10n), () => notifier.setType(null)),
      if (unitName != null) (unitName, () => notifier.setOwningUnit(null)),
      if (filter.free != null)
        (
          filter.free! ? l10n.catalogueFilterFree : l10n.catalogueFilterPaid,
          () => notifier.setFree(null),
        ),
    ];

    return Padding(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.catalogueFiltersTitle,
              style: context.text.headline,
            ),
          ),
          const SizedBox(height: SprintSpacing.space2),
          _Row(
            children: [
              SprintFilterChip(
                key: typeKey(null),
                label: l10n.catalogueFilterAllTypes,
                selected: filter.type == null,
                onTap: () => notifier.setType(null),
              ),
              for (final t in FacilityType.values)
                SprintFilterChip(
                  key: typeKey(t),
                  label: typeLabelOf(t, l10n),
                  selected: filter.type == t,
                  onTap: () => notifier.setType(t),
                ),
            ],
          ),
          const SizedBox(height: SprintSpacing.space2),
          _Row(
            children: [
              SprintFilterChip(
                key: unitKey(null),
                label: l10n.catalogueFilterAllUnits,
                selected: filter.owningUnitId == null,
                onTap: () => notifier.setOwningUnit(null),
              ),
              for (final u in units)
                SprintFilterChip(
                  key: unitKey(u.id),
                  label: u.name,
                  selected: filter.owningUnitId == u.id,
                  onTap: () => notifier.setOwningUnit(u.id),
                ),
            ],
          ),
          const SizedBox(height: SprintSpacing.space2),
          _Row(
            children: [
              SprintFilterChip(
                key: freeKey(null),
                label: l10n.catalogueFilterAny,
                selected: filter.free == null,
                onTap: () => notifier.setFree(null),
              ),
              SprintFilterChip(
                key: freeKey(true),
                label: l10n.catalogueFilterFree,
                selected: filter.free == true,
                onTap: () => notifier.setFree(true),
              ),
              SprintFilterChip(
                key: freeKey(false),
                label: l10n.catalogueFilterPaid,
                selected: filter.free == false,
                onTap: () => notifier.setFree(false),
              ),
            ],
          ),
          if (active.isNotEmpty) ...[
            const SizedBox(height: SprintSpacing.space3),
            Wrap(
              spacing: SprintSpacing.space2,
              runSpacing: SprintSpacing.space2,
              children: [
                for (final (name, onRemove) in active)
                  SprintFilterChip(
                    key: activeKey(name),
                    label: name,
                    selected: true,
                    semanticLabel: l10n.catalogueFilterRemove(name),
                    trailingIcon: PhosphorIconsRegular.x,
                    onTap: onRemove,
                  ),
                SprintFilterChip(
                  key: clearAllKey,
                  label: l10n.catalogueFilterClearAll,
                  selected: false,
                  onTap: notifier.clear,
                ),
              ],
            ),
          ],
          if (count != null) ...[
            const SizedBox(height: SprintSpacing.space2),
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.catalogueResultCount(count),
                key: countKey,
                style: context.text.caption.copyWith(
                  color: context.colors.inkMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final c in children)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: SprintSpacing.space2,
            ),
            child: c,
          ),
      ],
    ),
  );
}
