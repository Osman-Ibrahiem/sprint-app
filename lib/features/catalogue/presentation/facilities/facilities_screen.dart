import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/window/display_feature_layout.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/catalogue/domain/facility.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_not_found.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';
import 'package:sprint/features/catalogue/presentation/widgets/catalogue_error_view.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The facilities master-detail screen. One URL always means the same facility
/// at every width (R2): compact shows the list or the details alone, medium and
/// larger show both, and a hinge never sits under content (FR-007 – FR-014).
class FacilitiesScreen extends StatelessWidget {
  const FacilitiesScreen({this.selectedId, super.key});

  static const listSlotKey = ValueKey<String>('facilities-list-slot');
  static const detailsSlotKey = ValueKey<String>('facilities-details-slot');

  /// The facility shown in the details slot, or null for none.
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final size = WindowSize.of(context);
    final list = KeyedSubtree(
      key: listSlotKey,
      child: const _ListPlaceholder(),
    );

    if (selectedId == null) {
      if (size.isCompact) return list;
      return DisplayFeatureLayout(
        start: list,
        end: KeyedSubtree(
          key: detailsSlotKey,
          child: const _PanePrompt(),
        ),
      );
    }

    final details = KeyedSubtree(
      key: detailsSlotKey,
      child: _DetailsSlot(id: selectedId!),
    );
    if (size.isCompact) return details;
    return DisplayFeatureLayout(start: list, end: details);
  }
}

/// Stand-in for the list until US2 replaces it.
class _ListPlaceholder extends StatelessWidget {
  const _ListPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      children: const [
        Skeleton(height: SprintSize.controlHeight * 2),
        SizedBox(height: SprintSpacing.space4),
        Skeleton(height: SprintSize.controlHeight * 2),
        SizedBox(height: SprintSpacing.space4),
        Skeleton(height: SprintSize.controlHeight * 2),
      ],
    );
  }
}

class _PanePrompt extends StatelessWidget {
  const _PanePrompt();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
        child: Text(
          AppLocalizations.of(context).cataloguePanePrompt,
          style: context.text.body.copyWith(color: colors.inkMuted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _DetailsSlot extends ConsumerWidget {
  const _DetailsSlot({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final facility = ref.watch(facilityByIdProvider(id));

    final title = switch (facility) {
      AsyncData(:final value) =>
        value?.name ?? l10n.catalogueFacilityNotFoundTitle,
      _ => l10n.facilitiesTitle,
    };

    return Column(
      children: [
        AdaptiveAppBar(
          title: title,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const DirectionalIcon(PhosphorIconsRegular.arrowRight),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppPaths.facilities),
          ),
        ),
        Expanded(
          child: switch (facility) {
            AsyncData(:final value) =>
              value == null ? const FacilityNotFound() : _NameOnly(facility: value),
            AsyncError() => CatalogueErrorView(
                onRetry: () => ref.invalidate(facilityByIdProvider(id)),
              ),
            _ => const Center(child: Skeleton(height: SprintSize.controlHeight * 3)),
          },
        ),
      ],
    );
  }
}

/// The name-only details stand-in, replaced by US3.
class _NameOnly extends StatelessWidget {
  const _NameOnly({required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      children: [
        Text(facility.name, style: context.text.titleLg),
        const SizedBox(height: SprintSpacing.space2),
        Text(facility.description, style: context.text.body),
      ],
    );
  }
}
