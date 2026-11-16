import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/facility_card/facility_card.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_filter_bar.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';
import 'package:sprint/features/catalogue/presentation/widgets/catalogue_error_view.dart';
import 'package:sprint/features/catalogue/presentation/widgets/facility_card_mapper.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The filter bar plus a lazy list or grid of facility cards. Filters and the
/// scroll offset live in keep-alive providers (FR-007 – FR-013, R5).
class FacilityListView extends ConsumerStatefulWidget {
  const FacilityListView({this.selectedId, super.key});

  final String? selectedId;

  static const emptyKey = ValueKey<String>('facilities-empty');
  static ValueKey<String> cardKey(String id) =>
      ValueKey<String>('facility-card-$id');

  @override
  ConsumerState<FacilityListView> createState() => _FacilityListViewState();
}

const _minColumnWidth = 300.0;

class _FacilityListViewState extends ConsumerState<FacilityListView> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        ScrollController(
          initialScrollOffset: ref.read(facilitiesListScrollOffsetProvider),
        )..addListener(() {
          ref
              .read(facilitiesListScrollOffsetProvider.notifier)
              .save(_controller.offset);
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaries = ref.watch(facilitySummariesProvider);
    final session = ref.watch(currentSessionProvider);
    final size = WindowSize.of(context);
    final horizontal = size.isCompact;
    final showSelection = !size.isCompact;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Columns follow the list's own width, so a narrow pane never squeezes
        // a card (FR-030).
        final columns = horizontal
            ? 1
            : (constraints.maxWidth / _minColumnWidth).floor().clamp(1, 3);
        return CustomScrollView(
          controller: _controller,
          slivers: [
            const SliverToBoxAdapter(child: FacilityFilterBar()),
            ...switch (summaries) {
              AsyncData(:final value) when value.isEmpty => [
                const SliverToBoxAdapter(child: _Empty()),
              ],
              AsyncData(:final value) => [
                SliverPadding(
                  padding: const EdgeInsetsDirectional.only(
                    start: SprintSpacing.space4,
                    end: SprintSpacing.space4,
                    bottom: SprintSpacing.space8,
                  ),
                  sliver: SliverList.separated(
                    itemCount: (value.length / columns).ceil(),
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: SprintSpacing.space4),
                    itemBuilder: (context, row) => IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var c = 0; c < columns; c++) ...[
                            if (c > 0)
                              const SizedBox(width: SprintSpacing.space4),
                            Expanded(
                              child: row * columns + c < value.length
                                  ? _Card(
                                      summary: value[row * columns + c],
                                      session: session,
                                      horizontal: horizontal,
                                      selected:
                                          showSelection &&
                                          value[row * columns + c]
                                                  .facility
                                                  .id ==
                                              widget.selectedId,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              AsyncError() => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: CatalogueErrorView(
                    onRetry: () => ref.invalidate(facilitySummariesProvider),
                  ),
                ),
              ],
              _ => [
                SliverPadding(
                  padding: const EdgeInsetsDirectional.all(
                    SprintSpacing.space4,
                  ),
                  sliver: SliverList.separated(
                    itemCount: 3,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: SprintSpacing.space4),
                    itemBuilder: (_, _) => FacilityCard.loading(
                      layout: horizontal
                          ? FacilityCardLayout.horizontal
                          : FacilityCardLayout.vertical,
                    ),
                  ),
                ),
              ],
            },
          ],
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.summary,
    required this.session,
    required this.horizontal,
    required this.selected,
  });

  final FacilitySummary summary;
  final Session session;
  final bool horizontal;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final inputs = facilityCardInputs(
      summary: summary,
      session: session,
      l10n: l10n,
    );
    final id = summary.facility.id;
    final card = FacilityCard(
      key: FacilityListView.cardKey(id),
      layout: horizontal
          ? FacilityCardLayout.horizontal
          : FacilityCardLayout.vertical,
      kind: inputs.kind,
      name: inputs.name,
      owningUnit: inputs.owningUnit,
      unitCount: inputs.unitCount,
      tags: inputs.tags,
      availability: inputs.availability,
      availableCount: inputs.availableCount,
      price: inputs.price,
      onTap: () => context.go(AppPaths.facilityDetails(id)),
    );
    if (!selected) return card;
    return Semantics(
      selected: true,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: SprintRadius.lgBorder,
          border: Border.all(
            color: colors.primary,
            width: SprintExtras.focusRingWidth,
          ),
        ),
        child: card,
      ),
    );
  }
}

class _Empty extends ConsumerWidget {
  const _Empty();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final filter = ref.watch(facilityFilterProvider);
    final units = ref.watch(owningUnitOptionsProvider).value ?? const [];
    final names = <String>[
      if (filter.type != null) typeLabelOf(filter.type!, l10n),
      for (final u in units)
        if (u.id == filter.owningUnitId) u.name,
      if (filter.free != null)
        filter.free! ? l10n.catalogueFilterFree : l10n.catalogueFilterPaid,
    ];
    return Padding(
      key: FacilityListView.emptyKey,
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
      child: Column(
        children: [
          Icon(
            PhosphorIconsRegular.magnifyingGlass,
            size: SprintSize.iconLg,
            color: colors.inkMuted,
          ),
          const SizedBox(height: SprintSpacing.space3),
          Text(
            l10n.catalogueEmptyTitle,
            style: context.text.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SprintSpacing.space2),
          Text(
            l10n.catalogueEmptyBody(names.join(' + ')),
            style: context.text.body.copyWith(color: colors.inkMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SprintSpacing.space4),
          SprintButton(
            label: l10n.catalogueEmptyClear,
            onPressed: ref.read(facilityFilterProvider.notifier).clear,
          ),
        ],
      ),
    );
  }
}
