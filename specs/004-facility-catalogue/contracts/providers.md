# Contract: Providers and pure services

Presentation reads only these. Providers are Riverpod codegen in
`lib/features/catalogue/presentation/providers/`. Pure services live in
`lib/features/catalogue/domain/` and import nothing from Flutter, Riverpod or `data/`.

## Providers

| Provider | Returns | Reads | Notes |
| --- | --- | --- | --- |
| `facilityFilter` (keep-alive notifier) | `FacilityFilter` | none | `setType`, `setOwningUnit`, `setFree`, `clear`; survives navigation (R5) |
| `facilitiesListScrollOffset` (keep-alive notifier) | `double` | none | saved on scroll, restored on build |
| `facilitySummaries` | `AsyncValue<List<FacilitySummary>>` | `facilityFilter`, catalogue, availability, settings | published only; applies the filter through the repository parameters |
| `owningUnitOptions` | `AsyncValue<List<OwningUnit>>` | catalogue | filter chips |
| `facilityDetails(id)` | `AsyncValue<FacilityDetails?>` | catalogue, identity, availability, settings, clock | `null` = missing or unpublished → not-found |
| `homeContent` | `AsyncValue<HomeContent>` | `currentSession`, catalogue, bookings, availability, settings | guest: featured; signed in: upcoming plus suggestions |
| `shareAction` | `ShareAction` | none | `share(text, url)` and `copy(url)`; overridden in tests |

- Every `AsyncValue` has a skeleton for `loading` and an error state with a retry that does
  `ref.invalidate(...)` (R10).
- Providers never expose an in-memory class; they depend on the interface providers in
  `lib/core/providers/data_providers.dart`.
- A change of the signed-in user (`currentSession`) invalidates `homeContent` and the price tier shown
  on cards (US4 scenario 4).

## Pure services (all synchronous, no I/O, "now" and settings are parameters)

| Service | Signature (shape) | Spec |
| --- | --- | --- |
| `TodayAvailability.fromSlots` | `(List<Slot>, {required int fewLeftThreshold}) → TodayAvailability` | FR-011, BR-45 |
| `SuggestionRule.pick` | `({facilities, pastBookings, upcomingFacilityIds, summaryOf, limit = 4}) → List<Suggestion>` | FR-004 |
| `PriceGroups.build` | `({units, prices, modeOf}) → List<PriceGroup>` | FR-017, BR-15, BR-16 |
| `HoursView.build` | `({facilityHours, unitHours, closures, now}) → HoursView` | FR-015, FR-016, FR-021 |
| `FacilityLink.path / parse` | `(String id) → String` / `(String location) → String?` | FR-024, FR-025 |

## Share seam

`ShareAction` is an abstract class with `Future<void> share({required String text, required String url})`
and `Future<void> copy(String url)`. The default implementation uses `share_plus` and the clipboard;
tests override `shareAction` with a recorder.

## Guard expectations

- The existing guards scan the new files: tokens only, directional layout, strings in ARB, ARB parity
  (Arabic and English keys equal), fonts, and no platform checks outside `lib/core/adaptive/`.
- A new check keeps `lib/features/catalogue/domain/` free of `package:flutter`, `riverpod` and `data/`
  imports (the pure-rules promise).
