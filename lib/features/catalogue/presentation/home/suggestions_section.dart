import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/facility_card/facility_card.dart';
import 'package:sprint/features/catalogue/domain/home_content.dart';
import 'package:sprint/features/catalogue/presentation/widgets/facility_card_mapper.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Up to four suggested facilities, each with its reason in words (FR-004).
class SuggestionsSection extends ConsumerWidget {
  const SuggestionsSection({required this.suggestions, super.key});

  final List<Suggestion> suggestions;

  static ValueKey<String> reasonKey(String id) =>
      ValueKey<String>('suggestion-reason-$id');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final session = ref.watch(currentSessionProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.catalogueSuggestionsTitle, style: context.text.titleLg),
        ),
        const SizedBox(height: SprintSpacing.space3),
        for (final s in suggestions) ...[
          Builder(builder: (context) {
            final inputs = facilityCardInputs(
                summary: s.facility, session: session, l10n: l10n);
            final id = s.facility.facility.id;
            final reason = switch (s.reason) {
              BookedTypeBefore(:final type) =>
                l10n.catalogueSuggestionReasonBookedType(typeLabelOf(type, l10n)),
              OtherSuggestion() => l10n.catalogueSuggestionReasonOther,
            };
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FacilityCard(
                  kind: inputs.kind,
                  name: inputs.name,
                  owningUnit: inputs.owningUnit,
                  unitCount: inputs.unitCount,
                  tags: inputs.tags,
                  availability: inputs.availability,
                  availableCount: inputs.availableCount,
                  price: inputs.price,
                  onTap: () => context.go(AppPaths.facilityDetails(id)),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      top: SprintSpacing.space1),
                  child: Text(reason,
                      key: reasonKey(id),
                      style: context.text.caption.copyWith(color: colors.inkMuted)),
                ),
                const SizedBox(height: SprintSpacing.space3),
              ],
            );
          }),
        ],
      ],
    );
  }
}
