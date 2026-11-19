import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/catalogue/data/recent_searches_store.dart';
import 'package:sprint/features/catalogue/domain/facility_search.dart';
import 'package:sprint/features/catalogue/domain/facility_summary.dart';
import 'package:sprint/features/catalogue/domain/search_suggestions.dart';
import 'package:sprint/features/catalogue/presentation/providers/catalogue_providers.dart';
import 'package:sprint/features/catalogue/presentation/widgets/facility_card_mapper.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Days of bookings behind "الأكتر حجزًا" (presentation constant).
const int mostBookedDays = 30;

/// The text in the search field (FR-CAT-05). Kept across navigation and in the
/// address (`?q=`).
class SearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final searchQueryProvider = NotifierProvider<SearchQuery, String>(
  SearchQuery.new,
);

/// The filtered facilities with the search applied: names, type labels and
/// owning units, open ones first by places available today.
final searchedSummariesProvider = FutureProvider.autoDispose<
  List<FacilitySummary>
>((ref) async {
  final all = await ref.watch(facilitySummariesProvider.future);
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return all;
  final l10n = lookupAppLocalizations(ref.watch(localeProvider));
  return FacilitySearch.filter(
    all,
    query,
    typeLabelOf: (t) => typeLabelOf(t, l10n),
  );
});

/// What the empty focused field offers: two most-booked facilities and the
/// recent terms.
class SuggestionView {
  const SuggestionView({required this.mostBooked, required this.recents});

  final List<FacilitySummary> mostBooked;
  final List<String> recents;
}

final searchSuggestionsProvider = FutureProvider.autoDispose<SuggestionView>((
  ref,
) async {
  final all = await ref.watch(facilitySummariesProvider.future);
  final until = ref.watch(appClockProvider).now();
  final since = until.subtract(const Duration(days: mostBookedDays));
  final counts = await ref
      .watch(bookingRepositoryProvider)
      .bookedCounts(since: since, until: until);
  final ids = SearchSuggestions.mostBookedFrom(all, counts);
  return SuggestionView(
    mostBooked: [
      for (final id in ids) all.firstWhere((s) => s.facility.id == id),
    ],
    recents: ref.watch(recentSearchesStoreProvider).read(),
  );
});
