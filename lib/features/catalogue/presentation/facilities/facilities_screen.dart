import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/window/display_feature_layout.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/catalogue/presentation/details/facility_details_view.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_list_view.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';
import 'package:sprint/features/catalogue/presentation/providers/share_provider.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The facilities master-detail screen. One URL always means the same facility
/// at every width (R2): compact shows the list or the details alone, medium and
/// larger show both, and a hinge never sits under content (FR-007 – FR-014).
class FacilitiesScreen extends StatelessWidget {
  const FacilitiesScreen({this.selectedId, super.key});

  static const listSlotKey = ValueKey<String>('facilities-list-slot');
  static const detailsSlotKey = ValueKey<String>('facilities-details-slot');
  static const shareKey = _DetailsSlot.shareKey;
  static const copyKey = _DetailsSlot.copyKey;

  /// The facility shown in the details slot, or null for none.
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final size = WindowSize.of(context);
    final list = KeyedSubtree(
      key: listSlotKey,
      child: FacilityListView(selectedId: selectedId),
    );

    if (selectedId == null) {
      if (size.isCompact) return list;
      return DisplayFeatureLayout(
        start: list,
        end: KeyedSubtree(key: detailsSlotKey, child: const _PanePrompt()),
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

  static const shareKey = ValueKey<String>('details-share');
  static const copyKey = ValueKey<String>('details-copy-link');

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
          leading: AdaptiveBackButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppPaths.facilities),
          ),
          actions: [
            if (facility.value != null) ...[
              IconButton(
                key: shareKey,
                tooltip: l10n.catalogueShareAction,
                icon: const Icon(PhosphorIconsRegular.shareNetwork),
                onPressed: () => ref
                    .read(shareActionProvider)
                    .share(
                      text: l10n.catalogueShareText(facility.value!.name),
                      url: shareUrlFor(id),
                    ),
              ),
              IconButton(
                key: copyKey,
                tooltip: l10n.catalogueShareCopyLink,
                icon: const Icon(PhosphorIconsRegular.link),
                onPressed: () async {
                  await ref.read(shareActionProvider).copy(shareUrlFor(id));
                  if (!context.mounted) return;
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content: Text(l10n.catalogueShareCopied)),
                  );
                },
              ),
            ],
          ],
        ),
        Expanded(child: FacilityDetailsView(id: id)),
      ],
    );
  }
}
