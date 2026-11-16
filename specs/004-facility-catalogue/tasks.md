---

description: "Task list for the Facility Catalogue and Details feature"
---

# Tasks: Facility Catalogue and Details

**Input**: Design documents from `/specs/004-facility-catalogue/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Included. The plan's testing section and the constitution (a pull request needs static analysis, all automated tests and a web build to pass) require them. Each story lists its tests first, and they MUST fail before the code they cover exists.

**Organization**: Grouped by user story. Phase 2 builds what every story needs (pure rules, routes, providers, the screen skeleton, seed extras) so the three P1 stories and the P2 stories can then be built in any order and each can be shown on its own. A temporary stand-in (a name-only details pane) lives in Phase 2 and is replaced in US3.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: US1 guest home discovery · US2 list and filters · US3 facility details · US4 signed-in home · US5 share link · US6 every size, language and theme
- Paths are relative to the repository root (single Flutter package, see plan.md)

## Rules for every task

- Tokens only, no raw colours or numeric style literals; direction-aware layout; strings only in `lib/l10n/*.arb`, Arabic and English together, every new key prefixed `catalogue` (constitution II, V; plan R9). Settings are read through `SettingsRepository`, never typed into a screen (III).
- Files under `lib/features/catalogue/domain/` import nothing from Flutter, Riverpod or `data/`. Screens and providers read repository **interfaces** through `lib/core/providers/data_providers.dart`, never an `in_memory_*` class (IV).
- No platform checks outside `lib/core/adaptive/`. Use the 002 widgets as they are; add nothing to `lib/core/widgets/`.
- Edits to shared files (`routes.dart`, `app_router.dart`, the two ARB files, `seed_data.dart`, `pubspec.yaml`) are additive, one small task each, so the merge with feature 003 stays easy (plan R9). Do not edit `CLAUDE.md` or `docs/`.
- Commit messages cite BRD IDs. Branch: `004-facility-catalogue`. No force-push, no rebase, no history rewrite. Do not touch `/Users/osman/Projects/Sprint-App`.
- After editing an ARB file run `flutter gen-l10n`; after editing a Riverpod or Freezed file run `dart run build_runner build --delete-conflicting-outputs`.

---

## Phase 1: Setup

**Purpose**: A known-green baseline and the one new dependency.

- [X] T001 Run `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze` and `flutter test` on the clean branch. All must pass. Create `specs/004-facility-catalogue/evidence.md` with a "Baseline" section recording the date and the number of passing tests, so later regressions are visible.
- [X] T002 Add the runtime dependency `share_plus` with `flutter pub add share_plus` (changes `pubspec.yaml` and `pubspec.lock` only; one line in `pubspec.yaml`). Run `flutter analyze` to confirm nothing breaks. Commit this alone so the merge with 003's own `pubspec.yaml` edits is a one-line conflict at worst (R7, R9).
- [X] T003 [P] Add the guard test `test/guards/catalogue_domain_pure_test.dart`: scan every `.dart` file in `lib/features/catalogue/domain/` and fail if it imports `package:flutter`, `package:flutter_riverpod`, `package:riverpod_annotation` or anything under `features/*/data/` (contracts/providers.md, Guard expectations). Add a second check in the same file: no `.dart` file in `lib/features/catalogue/presentation/` may import a file whose name starts with `in_memory_` or `InMemoryDataLayer` (constitution IV; screens read interfaces through `lib/core/providers/data_providers.dart` only). It passes now and protects every later task.

---

## Phase 2: Foundational (blocks every user story)

**Purpose**: pure rules, routes, providers, the shared widgets and the screen skeleton. No user story starts before this phase is done.

### Pure domain rules (all in `lib/features/catalogue/domain/`, each with its test)

- [X] T004 [P] Create `lib/features/catalogue/domain/facility_filter.dart`: Freezed `FacilityFilter` with `FacilityType? type`, `String? owningUnitId`, `bool? free` (null = all; `free: true` = free only, `free: false` = paid only), a getter `isActive` (any field set) and `activeCount` (how many fields are set). Test `test/features/catalogue/domain/facility_filter_test.dart`: defaults are inactive, each field sets `isActive`, `activeCount` counts correctly (FR-008, FR-009).
- [X] T005 [P] Create `lib/features/catalogue/domain/today_availability.dart`: class `TodayAvailability { AvailabilityLevel level; int count; bool closedToday; }` using the 002 enum `AvailabilityLevel`, with `TodayAvailability.fromSlots(List<Slot> slots, {required int fewLeftThreshold})`. Rule verbatim from data-model.md: `count` = sum of `remaining` over slots where `isBookable`; `level` = `none` if `count == 0`, `few` if `count <= fewLeftThreshold` (BR-45), else `plenty`; `closedToday` = true when `slots` is empty. Test `test/features/catalogue/domain/today_availability_test.dart`: empty list, all `past`/`full`/`closed`, exactly the threshold, one above it, shared slots with different `remaining`, a threshold of 0 (FR-011).
- [X] T006 [P] Create `lib/features/catalogue/domain/facility_link.dart`: `FacilityLink.path(String id)` returns `/facilities/<id>`; `FacilityLink.parse(String location)` returns the id for `/facilities/<id>` (ignoring a trailing slash, a query, and a `/schedule` suffix) or null for anything else. Test `test/features/catalogue/domain/facility_link_test.dart`: round trip, no id, nested path, an id with unusual characters stays exact (FR-024, FR-025).
- [X] T007 [P] Create `lib/features/catalogue/domain/facility_summary.dart`: `FacilitySummary { Facility facility; String owningUnitName; int activeUnitCount; TodayAvailability today; TierPriceRange? priceInternal; TierPriceRange? priceExternal; }` with `TierPriceRange { int min; int max; }` (`isSingle` when equal), and a getter `kind` returning the 002 `FacilityKind`: `free` if `facility.isFree`, `withTrainer` if `facility.requiresTrainer`, else `paid`. Price fields are null for a free facility and for a facility whose active units have no price yet (never 0, data-model.md). Test `test/features/catalogue/domain/facility_summary_test.dart` for `kind` and `TierPriceRange.isSingle` (FR-011, FR-019).

### Seed extras (additive, new file)

- [X] T008 Create `lib/core/seed/seed_catalogue_extras.dart` with `List<OperatingHours> seedCatalogueExtraHours()` and `List<Closure> seedCatalogueExtraClosures(DateTime now)`. Hours: pool lane 6 (`SeedIds.pool6`, `ownerId` = the unit id) open only 4:00 pm to 10:00 pm, every day (unit-own hours, FR-021). Closure: a facility-scope closure (`ClosureScope.facility`, `scopeId: SeedIds.tennisFacility`, reason "صيانة الملاعب") from 5 days after today to 6 days after, built with `CairoTime.atWallClock` like `seedClosures` (upcoming, not current, so no other feature's test sees a closed tennis court today). Add a comment saying these are placeholders until Dr. Sara's data arrives (FR-029, R6).
- [X] T009 Wire the extras in `lib/core/seed/seed_data.dart` inside `SeedData.build`: change `hours: seedHours()` to `hours: [...seedHours(), ...seedCatalogueExtraHours()]` and `closures: seedClosures(now)` to `closures: [...seedClosures(now), ...seedCatalogueExtraClosures(now)]`, plus the import. Run the full `flutter test`. If any existing test breaks because of the extras, remove that extra from the seed and move it to a test fixture in `test/features/catalogue/fixtures/` instead of editing the Foundation's tests (R6). Record the outcome in `specs/004-facility-catalogue/evidence.md`.
- [X] T010 [P] Test `test/features/catalogue/seed_extras_test.dart` (adjust to the outcome of the previous task): lane 6 has its own hours and the other lanes do not; the tennis facility has an upcoming facility-scope closure; every seeded facility still has at least one active unit. Also create `test/features/catalogue/fixtures/catalogue_fixtures.dart` with a helper that builds a seed variant where the tennis facility is closed right now (a facility-scope closure covering today), for the tests that need a "closed today" state (T034, T056); it never edits the shared seed.

### Routes (three small additive edits, in this order)

- [X] T011 Edit `lib/app/router/routes.dart`: add `AppPaths.facilityDetails(String id)` returning `FacilityLink.path(id)` and `AppPaths.facilitySchedule(String id)` returning `'${FacilityLink.path(id)}/schedule'`, plus `AppRouteNames.facilityDetails = 'facilityDetails'` and `AppRouteNames.facilitySchedule = 'facilitySchedule'`. Add only; change no existing constant (contracts/routes.md).
- [X] T012 Edit `lib/app/router/routes.dart`: add an optional field `List<RouteBase> subRoutes` (default `const []`) to `ShellDestination`. No other change to the class (R1).
- [X] T013 Edit `lib/app/router/app_router.dart`: where the branch `GoRoute` is built for each destination, pass `routes: d.subRoutes`. Test `test/features/catalogue/presentation/router_subroutes_test.dart`: a destination with a sub-route resolves it inside the shell (navigation bar still present) and a destination without sub-routes behaves exactly as before (R1).

### Shared copy (one ARB task)

- [X] T014 Add the shared keys to `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` together, in one block at the end of each file, then run `flutter gen-l10n`. Keys: `catalogueTypeSwimming`, `catalogueTypeFootball`, `catalogueTypeGym`, `catalogueTypeTennis`, `catalogueTypeHall`, `catalogueTypeTraining` (the six `FacilityType` values); `catalogueErrorTitle`, `catalogueErrorBody`, `catalogueRetry` (FR-033); `catalogueFacilityNotFoundTitle`, `catalogueFacilityNotFoundBody`, `catalogueBackToFacilities` (FR-026); `cataloguePanePrompt` ("اختار منشأة تشوف تفاصيلها" and its English); `cataloguePriceRange` with a `{min}` and `{max}` placeholder ("{min}–{max} ج.م" / "EGP {min}–{max}"); `catalogueTagFree`, `catalogueTagTrainer`. Light Egyptian dialect, no imperative verbs, Western digits. The existing ARB parity guard must stay green.

### Providers and shared widgets

- [X] T015 Create `lib/features/catalogue/presentation/providers/catalogue_providers.dart` (Riverpod codegen) with: keep-alive notifier `FacilityFilterNotifier` (`setType`, `setOwningUnit`, `setFree`, `clear`); keep-alive notifier for the list scroll offset (a `double`, saved on scroll, read on build); `owningUnitOptions` (from `CatalogueRepository.listOwningUnits`); `facilitySummaries` which reads the filter, calls `CatalogueRepository.listFacilities(type:, owningUnitId:, free:)` (never `includeUnpublished`), and per facility: counts active units, resolves `SettingKeys.fewLeftThreshold` at facility scope, calls `AvailabilityRepository.slots(unitId, today, today)` for each active unit through `appClock` and Cairo time, builds `TodayAvailability.fromSlots`, and builds the two `TierPriceRange`s from `CatalogueRepository.prices(unitId)` of active units (R3, R8). Generate code. Tests `test/features/catalogue/presentation/providers_test.dart` with provider overrides: filter combinations (type, owning unit, free, paid, all together) return the expected facilities, unpublished never appear, a facility closed today is `none`, a throwing catalogue repository gives an error state and `ref.invalidate` recovers (R10, FR-007, FR-008, FR-027).
- [X] T016 [P] Create `lib/features/catalogue/presentation/widgets/facility_card_mapper.dart`: a function that takes a `FacilitySummary`, the `Session` (`lib/core/providers/session_provider.dart`) and `AppLocalizations`, and returns the inputs of the 002 `FacilityCard`: `kind`, `name`, `owningUnit`, `unitCount`, `tags` (sport type label from the `catalogueType*` keys; "بمدرب" for `requiresTrainer`; "مجاني" for `isFree`; never more than 3), `availability`, `availableCount`, `photo: null`, and `price` per the card README and research R8: guest gets both tiers; signed-in user gets their own tier with its audience label; one price per tier shows that price; differing prices show the range from `cataloguePriceRange`; a free facility shows no price. Test `test/features/catalogue/presentation/facility_card_mapper_test.dart` for each branch (FR-011, FR-017, FR-019, US-11).
- [X] T017 [P] Create `lib/features/catalogue/presentation/widgets/section_card.dart` (a titled container on `surface` with `SprintRadius`/`SprintSpacing` tokens, title in `titleMd`, optional trailing) and `lib/features/catalogue/presentation/widgets/catalogue_error_view.dart` (title, body, and a "إعادة المحاولة" button using `SprintButton`, 48dp, calling an `onRetry` callback). Widget test `test/features/catalogue/presentation/shared_widgets_test.dart`: both render, the retry callback fires, and the touch target is at least 48dp (FR-032, FR-033).
- [X] T018 [P] Create `lib/features/catalogue/presentation/facilities/facility_not_found.dart`: a friendly screen with an icon, `catalogueFacilityNotFoundTitle`, `catalogueFacilityNotFoundBody` and a `SprintButton` that goes to `AppPaths.facilities` (FR-026). Test `test/features/catalogue/presentation/facility_not_found_test.dart`.
- [X] T019 Create `lib/features/catalogue/presentation/facilities/facilities_screen.dart`: `FacilitiesScreen({String? selectedId})`. Layout by `WindowSize.of(context)` (R2): compact shows the list slot when `selectedId == null` and the details slot alone otherwise; medium and larger show both inside `DisplayFeatureLayout(start: list, end: details)` with the `cataloguePanePrompt` hint in the details slot when `selectedId == null`. For now the list slot is a placeholder box and the details slot is a minimal name-only pane (this stand-in is replaced by US2 and US3). Use `AdaptiveAppBar` on the details side whose back button runs `context.canPop() ? context.pop() : context.go(AppPaths.facilities)` (contracts/routes.md). A missing or unpublished id shows `FacilityNotFound`. Test `test/features/catalogue/presentation/facilities_screen_layout_test.dart`: at 400, 700 and 1000 logical px widths the right slots show; the same `selectedId` shows at every width; a missing id shows the not-found screen.
- [X] T020 Edit `lib/app/router/routes.dart` (facilities destination only): set its `builder` to `FacilitiesScreen()` and its `subRoutes` to one `GoRoute(path: ':id', name: AppRouteNames.facilityDetails, builder: ... FacilitiesScreen(selectedId: state.pathParameters['id']))`. Leave the home destination and all other destinations untouched. Extend `router_subroutes_test.dart` or add `test/features/catalogue/presentation/catalogue_routes_test.dart`: `/facilities` and `/facilities/<seed id>` resolve, the facilities tab stays selected, `/facilities/nope` shows the not-found screen, and `/home`, `/bookings`, `/profile` still resolve (contracts/routes.md).

**Checkpoint**: `flutter analyze` and `flutter test` are green; the facilities tab shows the skeleton; a facility id route shows a name-only pane.

---

## Phase 3: User Story 1 - A guest opens the app and discovers facilities (Priority: P1)

**Goal**: A signed-out guest sees discovery on the first screen (facility types, featured facilities with both prices) and can reach any facility in two taps (FR-001, FR-002, FR-006, US-01, SC-001).

**Independent Test**: Open the app signed out on seed data: home shows types and featured cards with no sign-in prompt; tapping a type opens the list filtered to it; tapping a card opens `/facilities/<id>`; skeleton cards show while loading.

### Tests for US1 (write first, they must fail)

- [X] T021 [P] [US1] `test/features/catalogue/presentation/home_guest_test.dart`: signed out, home shows one chip per facility type that has a published facility, a featured section with at most 6 cards ordered by today's availability count descending then name, a "عرض كل المنشآت" action, no sign-in prompt, and each card shows both tiers; tapping a type chip sets the filter and lands on `/facilities` filtered; tapping a card lands on `/facilities/<id>`; while the provider is loading, skeleton cards (the 002 `FacilityCard` with `isLoading: true`) show and no spinner shows (FR-001, FR-002, FR-006).

### Implementation for US1

- [X] T022 [US1] Add the US1 keys to both ARB files (one block, `catalogue` prefix) and run `flutter gen-l10n`: `catalogueHomeTitle`, `catalogueHomeTypesTitle`, `catalogueHomeFeaturedTitle`, `catalogueHomeSeeAll`, `catalogueHomeGuestHint`.
- [X] T023 [US1] Create `lib/features/catalogue/domain/home_content.dart` with the pure `HomeContent` view model (types, featured, upcoming, suggestions per data-model.md; `Suggestion` and `SuggestionReason` are added to it by the US4 rule task), then add to `catalogue_providers.dart` the provider `homeContent`, for now filling `types` (facility types with at least one published facility, fixed enum order) and `featured` (up to 6 `FacilitySummary`, sorted by `today.count` descending then by name; the cap 6 is one named constant). `upcoming` and `suggestions` stay empty until US4. Regenerate code. Add its cases to `providers_test.dart`.
- [X] T024 [US1] Create `lib/features/catalogue/presentation/home/home_screen.dart`: a scrolling page with the title, a horizontally scrolling row of type chips (each at least 48dp, a word and an icon, never colour alone), a featured section laid out as a single column on compact and a grid on medium and larger using the vertical `FacilityCard` layout from the mapper, and the "see all" action (`SprintButton`, the single main action). Loading shows skeleton cards, an error shows `CatalogueErrorView` with retry. Type chip tap: set the filter notifier then `context.go(AppPaths.facilities)`. Card tap: `context.go(AppPaths.facilityDetails(id))` (contracts/routes.md).
- [X] T025 [US1] Edit `lib/app/router/routes.dart` (home destination only): set its `builder` to `HomeScreen()`. Leave `home_placeholder.dart` in place (the Foundation's shell tests still use it). Run the US1 test and the existing shell tests (`test/shell/`), fix regressions.

**Checkpoint**: US1 is demonstrable on its own: the guest first screen is real.

---

## Phase 4: User Story 2 - Browse and filter the facility list (Priority: P1)

**Goal**: The list shows every published facility, filters by type, owning unit and free / paid, keeps its state, and uses master-detail on medium and larger (FR-007 – FR-013, SC-002, SC-006).

**Independent Test**: Open `/facilities` on seed data; apply each filter alone and combined; check chips, count, empty state and clear actions; select a facility at 1000px width and see it beside the list; resize to 400px and see it full screen; go back and see filters and scroll kept.

### Tests for US2 (write first)

- [X] T026 [P] [US2] `test/features/catalogue/presentation/facilities_list_test.dart`: all published facilities show on open; type, owning unit and free / paid filters work alone and with AND; active filters show as removable chips with the result count; "clear all" resets; filters that match nothing (tennis plus free) show the empty state naming the filters with a clear action; compact uses the horizontal card layout in one column and medium and larger a grid with the vertical layout; free and trainer tags show with words (FR-007 – FR-011).
- [X] T027 [P] [US2] `test/features/catalogue/presentation/facilities_state_test.dart`: set a filter and scroll, open a facility and go back — the filter and the scroll offset are unchanged; resize 400 → 1000 → 400 with a facility selected keeps the same facility and filter; a tap on a card at 1000px keeps the list visible and shows the facility in the pane; at 400px it pushes the details page and back returns to the list (FR-012, FR-013, SC-006).

### Implementation for US2

- [X] T028 [US2] Add the US2 keys to both ARB files (one block) and run `flutter gen-l10n`: `catalogueFiltersTitle`, `catalogueFilterAllTypes`, `catalogueFilterAllUnits`, `catalogueFilterAny`, `catalogueFilterFree`, `catalogueFilterPaid`, `catalogueFilterClearAll`, `catalogueFilterRemove` (with `{name}`), `catalogueResultCount` (plural with `{count}`), `catalogueEmptyTitle`, `catalogueEmptyBody` (with `{filters}`), `catalogueEmptyClear`.
- [X] T029 [US2] Create `lib/features/catalogue/presentation/facilities/facility_filter_bar.dart`: choice controls for type, owning unit (from `owningUnitOptions`) and free / paid, using the existing `OptionGroup` or `SprintButton`-based chips with 48dp targets and visible focus; active filters as removable chips each with a word; a "clear all" action when `activeCount > 0`; the result count line. All state goes through `FacilityFilterNotifier` (FR-009).
- [X] T030 [US2] Create `lib/features/catalogue/presentation/facilities/facility_list_view.dart`: a lazy `ListView`/`SliverGrid` of `FacilityCard`s from `facilitySummaries` (single column horizontal layout on compact, grid with vertical layout on medium and larger), skeleton cards while loading, `CatalogueErrorView` on error, the empty state of FR-010 with a clear action, the selected card visibly marked on medium and larger. Save the scroll offset to the scroll-offset notifier on scroll and restore it on build (R5). Card tap: `context.go(AppPaths.facilityDetails(id))`; the card marks itself selected when its id equals `selectedId`.
- [X] T031 [US2] Edit `facilities_screen.dart`: replace the list-slot placeholder with `FacilityFilterBar` plus `FacilityListView`. Keep the details slot as is. Run `facilities_list_test.dart` and `facilities_state_test.dart` and the earlier layout test.

**Checkpoint**: US1 and US2 both work; selecting a facility shows the name-only pane until US3.

---

## Phase 5: User Story 3 - See everything about a facility before booking (Priority: P1)

**Goal**: The facility page shows every FR-CAT-02 item plus the "قريبًا" action (FR-014 – FR-023, US-01, US-11, SC-003, SC-004).

**Independent Test**: Open the pool, the futsal pitch, the free hall, the academy and pool lane 6 on seed data and check each section against the seed; tap "عرض المواعيد" and see the "قريبًا" screen; go back.

### Pure rules for US3 (each with its test, in `lib/features/catalogue/domain/`)

- [X] T032 [P] [US3] Create `price_groups.dart`: `PriceGroup { List<String> unitIds; List<String> unitNames; bool coversAllUnits; BookingMode mode; int? internal; int? external; }` and `PriceGroups.build({required List<BookableUnit> units, required List<Price> prices, required BookingMode Function(String unitId) modeOf})`. Group active units by (mode, internal amount, external amount); `internal` / `external` are null when no price is set for that tier ("no price yet", never 0); a free facility produces no groups (the screen decides that, not this rule); inactive units never appear. Test `test/features/catalogue/domain/price_groups_test.dart`: six equal lanes become one group covering all units, two different pitches become two groups, mixed modes split groups, missing price is null (FR-017, FR-021, BR-15, BR-16).
- [X] T033 [P] [US3] Create `hours_view.dart`: `HoursView { List<DayHours> days; int todayDayOfWeek; bool closedNow; Map<String, List<DayHours>> unitOverrides; }` with `DayHours { int dayOfWeek; int? openMinutes; int? closeMinutes; }` and `HoursView.build({required List<OperatingHours> facilityHours, required Map<String, List<OperatingHours>> unitHours, required List<Closure> closures, required DateTime now})`. Days with no hours have null times ("مقفول"); `todayDayOfWeek` and all comparisons use Cairo time (`CairoTime`); `closedNow` is true inside a closure that covers the facility or all its units, or outside today's hours; `unitOverrides` holds only units whose weekly hours differ from the facility's. Test `test/features/catalogue/domain/hours_view_test.dart`: closed Friday (the hall), lane 6 override, equal unit hours produce no override, closure now and upcoming, just before opening and just after closing in Cairo time (FR-015, FR-016, FR-021, BR-05).

### Tests for US3 (write first)

- [X] T034 [P] [US3] `test/features/catalogue/presentation/facility_details_test.dart`: for each seed facility the page shows name, type, owning unit, description, location and the placeholder "صورة المنشأة" when there are no photos; hours with today marked and "مقفول" on closed days, 12-hour format; a closure with its dates in words and a "closed now" banner using a fixture; prices for both tiers per group with "للمكان الواحد" / "للحجز كله" and "120 ج.م" formatting, "كل الوحدات" when a group covers all units; a signed-in user's tier labelled "سعرك" with the other tier still visible, and a guest sees both unlabelled; the free hall shows "مجاني", no price and the no-payment note; the academy lists its three trainers with name, bio and capacity and the "choose a trainer first" note; a facility with no trainers says so; the units list shows active units only and lane 6 has its own hours line; the facts line shows the booking window and the free-range or session length from settings; "عرض المواعيد" is enabled and opens the "قريبًا" screen whose back returns, with no slots and no booking action on it; at 400px the app bar is still visible after scrolling to the bottom; a facility closed today (fixture) shows "مقفول النهارده" on the page while its card shows "مفيش مواعيد النهارده"; and a loop over every seeded facility checks that the price shown equals the seeded price for the tier (SC-004) (FR-014 – FR-022, FR-028).
- [X] T035 [P] [US3] `test/features/catalogue/presentation/photo_carousel_test.dart`: no images → placeholder; one image → no controls; three injected `ImageProvider`s → swipeable with a position indicator and an Arabic semantics label per image (Edge Cases, R6).

### Implementation for US3

- [X] T036 [US3] Add the US3 keys to both ARB files (one block) and run `flutter gen-l10n`: section titles (`catalogueSectionHours`, `catalogueSectionPrices`, `catalogueSectionTrainers`, `catalogueSectionUnits`, `catalogueSectionAvailability`, `catalogueSectionFacts`), `cataloguePhotoPlaceholder` ("صورة المنشأة"), `cataloguePhotoPosition` (`{index}` of `{count}`), day names, `catalogueHoursClosedDay` ("مقفول"), `catalogueHoursToday`, `catalogueClosedNow`, `catalogueClosedToday` ("مقفول النهارده"), `catalogueClosureRange` (`{from}`–`{to}`), `cataloguePriceInternalLabel`, `cataloguePriceExternalLabel`, `cataloguePriceYours` ("سعرك"), `cataloguePriceBasisShared` ("للمكان الواحد"), `cataloguePriceBasisExclusive` ("للحجز كله"), `cataloguePriceAllUnits` ("كل الوحدات"), `cataloguePriceNotSet`, `catalogueFreeNoPayment`, `catalogueTrainerCapacity`, `catalogueTrainersNone`, `catalogueTrainerFirst`, `catalogueTrainerUnnamed`, `catalogueUnitOwnHours`, `catalogueFactWindow` (`{days}`), `catalogueFactMaxRange` (`{hours}`), `catalogueFactSession` (`{minutes}`), `catalogueAvailabilityToday`, `catalogueScheduleAction` ("عرض المواعيد"), `catalogueScheduleSoonTitle`, `catalogueScheduleSoonBody`, `catalogueScheduleSoonBack`.
- [X] T037 [US3] Create `lib/features/catalogue/domain/facility_details.dart` with the pure `FacilityDetails` and `TrainerView` view models (fields per data-model.md: facility, owningUnitName, hours, closures, priceGroups, trainers, units with optional own hours, today, facts), then add to `catalogue_providers.dart` the provider `facilityDetails(String id)` returning null for a missing or unpublished id. It reads catalogue (facility, units, hours of the facility and of each unit, closures, prices, trainers), identity (`getUser(trainer.userId)` for each trainer name, `catalogueTrainerUnnamed` when missing), settings (`bookingMode` per unit; `bookingWindowDays` at facility scope; `maxRangeHours` for a free facility; `sessionMinutes` for a trainer facility; `fewLeftThreshold`), availability (today's slots) and the clock. Regenerate code; add cases to `providers_test.dart` including a missing id and an unpublished facility (FR-014 – FR-021, FR-027, FR-028).
- [X] T038 [P] [US3] Create `lib/features/catalogue/presentation/details/photo_carousel.dart`: a `PageView` of `ImageProvider`s with a position indicator and an Arabic label per image (`Semantics`), the `cataloguePhotoPlaceholder` panel on `surface-sunken` when there are none, no controls for one image; respects reduced motion for page animations.
- [X] T039 [P] [US3] Create `lib/features/catalogue/presentation/details/hours_section.dart`, `price_section.dart`, `trainers_section.dart`, `units_section.dart` and `availability_section.dart`, each a `SectionCard` taking plain values from `FacilityDetails`. Prices follow research R8 (per group, both tiers, basis, "سعرك" on the user's tier, "مجاني" and the no-payment note for a free facility, "السعر لسه مش محدد" for a null price). The availability section shows `TodayAvailability` in words and an enabled `SprintButton` "عرض المواعيد" that pushes `AppPaths.facilitySchedule(id)` (FR-022).
- [X] T040 [US3] Create `lib/features/catalogue/presentation/details/facility_details_view.dart`: the page body used full screen on compact and in the pane on medium and larger: carousel, header (name, tags, owning unit, location), closed-now banner (the page says "مقفول النهارده" when the facility is closed today, using `catalogueClosedToday`), facts line, then the five sections, skeleton while loading, `CatalogueErrorView` on error, `FacilityNotFound` when the provider returns null. On compact the app bar (facility name, back, and later the share action) stays pinned while the body scrolls (spec US3 scenario 10); on medium and larger the pane scrolls under its own pinned header.
- [X] T041 [US3] Create `lib/features/catalogue/presentation/details/schedule_coming_soon_screen.dart`: title, `catalogueScheduleSoonBody` (the 7-day slots arrive soon), a back action to the facility, no slots, no booking action. Add its route as a child of `:id` in the facilities `subRoutes` (`path: 'schedule'`, `name: AppRouteNames.facilitySchedule`) in `routes.dart` (additive, FR-022).
- [X] T042 [US3] Edit `facilities_screen.dart`: replace the name-only pane stand-in with `FacilityDetailsView`. Run `facility_details_test.dart`, `photo_carousel_test.dart`, `price_groups_test.dart`, `hours_view_test.dart` and the whole suite.

**Checkpoint**: the P1 journey (home → list → details) works end to end for a guest.

---

## Phase 6: User Story 4 - A signed-in user sees upcoming bookings and suggestions on home (Priority: P2)

**Goal**: Signed-in home shows upcoming confirmed bookings first, then four explainable suggestions; a user with none sees discovery and a note; signing out returns to guest content (FR-003 – FR-005, US4).

**Independent Test**: With the reviewer switcher, compare home for a guest, the verified booker (has upcoming bookings) and a user with none.

### Tests for US4 (write first)

- [X] T043 [P] [US4] `test/features/catalogue/domain/suggestion_rule_test.dart`: at most 4 suggestions; facilities of previously booked types come first, ordered by how often the type was booked then by name, each with reason `bookedTypeBefore(type)`; the rest follow by name with reason `other`; never a facility where the user has an upcoming confirmed booking; a user with no history gets none (the caller shows featured); unpublished facilities never appear; deterministic for the same input (FR-004, R4).
- [X] T044 [P] [US4] `test/features/catalogue/presentation/home_signed_in_test.dart`: the verified seeded booker sees upcoming `CONFIRMED` bookings first, soonest first, each with status, facility, date and 12-hour time, plus a "عرض الكل" link to `AppPaths.bookings`; only upcoming confirmed bookings appear (not pending, cancelled, expired, attended or no-show); a user with none sees discovery and the short note; suggestions show their reason in words; switching to guest removes all personal content without a stale frame (FR-003, FR-005, US4 scenario 4 and 5).

### Implementation for US4

- [X] T045 [US4] Create `lib/features/catalogue/domain/suggestion_rule.dart` and put `SuggestionReason` (`bookedTypeBefore(FacilityType)` and `other`) and `Suggestion { FacilitySummary facility; SuggestionReason reason; }` in `home_content.dart` (T023). The rule is `SuggestionRule.pick({required List<FacilitySummary> facilities, required List<Booking> pastBookings, required Set<String> upcomingFacilityIds, int limit = 4})` implementing exactly the rule in research R4 (past bookings = confirmed, attended and no-show; `limit` default 4 is a named constant).
- [X] T046 [US4] Add the US4 keys to both ARB files (one block) and run `flutter gen-l10n`: `catalogueUpcomingTitle`, `catalogueUpcomingSeeAll`, `catalogueUpcomingNone`, `catalogueBookingSpoken` (`{facility}`, `{date}`, `{time}`, `{status}`), `catalogueSuggestionsTitle`, `catalogueSuggestionReasonBookedType` (`{type}`, "لأنك حجزت {type} قبل كده"), `catalogueSuggestionReasonOther`.
- [X] T047 [US4] Extend the `homeContent` provider: it watches `currentSessionProvider`; for a signed-in user it reads `BookingRepository.listForUser(userId)` (all, for history) and `listForUser(userId, upcoming: true)`, keeps `CONFIRMED` bookings with start in the future, resolves facility names from the catalogue, sorts soonest first, and fills `suggestions` with `SuggestionRule.pick`. Guest: `upcoming` and `suggestions` stay empty. A change of the session invalidates the provider. Regenerate code and add cases to `providers_test.dart` (FR-003, FR-004).
- [X] T048 [P] [US4] Create `lib/features/catalogue/presentation/home/upcoming_bookings_section.dart`: compact booking rows (a `StatusBadge` with word and icon, facility name, Cairo date and 12-hour time, the booking code wrapped in an LTR isolate only if shown) each at least 48dp with an Arabic semantics label from `catalogueBookingSpoken`, and the "عرض الكل" action. Do not use the full `BookingTicket` here (research R4: the QR belongs to feature 7). Tapping a row goes to `AppPaths.bookings` (feature 7 owns the screen).
- [X] T049 [P] [US4] Create `lib/features/catalogue/presentation/home/suggestions_section.dart`: up to 4 `FacilityCard`s from the mapper, each with its reason sentence below in `caption` style, never a lone colour cue.
- [X] T050 [US4] Edit `home_screen.dart`: for a signed-in user show the upcoming section first (or the `catalogueUpcomingNone` note followed by discovery when empty), then suggestions when present, then the types and featured sections; a guest still sees only the US1 layout. Run `home_signed_in_test.dart`, `home_guest_test.dart` and `suggestion_rule_test.dart`.

**Checkpoint**: the signed-in home works and the guest home is unchanged.

---

## Phase 7: User Story 5 - Share a facility with a link (Priority: P3)

**Goal**: A share action on each facility page produces `/facilities/<id>`; the link opens the facility signed out, on the web and in the app; a bad link shows the not-found screen (FR-024 – FR-026, FR-CAT-04).

**Independent Test**: Share a facility, open the link in a new web tab, reload on a facility URL, and open a link to a missing facility.

### Tests for US5 (write first)

- [X] T051 [P] [US5] `test/features/catalogue/presentation/share_test.dart`: the details page has a share action; tapping it calls the `ShareAction` seam (overridden with a recorder) with a URL ending in `/#/facilities/<id>` (or the compile-time base plus that path) and a text containing the facility name; a copy-link item calls `copy` with the same URL; the URL is never built from the facility name (FR-024). Also a router test: the location `/facilities/<seed id>` opens that facility signed out with no redirect, and `/facilities/nope` shows the not-found screen, never a blank screen (FR-025, FR-026, SC-007).

### Implementation for US5

- [X] T052 [US5] Add the US5 keys to both ARB files (one block) and run `flutter gen-l10n`: `catalogueShareAction`, `catalogueShareCopyLink`, `catalogueShareCopied`, `catalogueShareText` (`{name}`).
- [X] T053 [US5] Create `lib/features/catalogue/presentation/providers/share_provider.dart`: abstract `ShareAction { Future<void> share({required String text, required String url}); Future<void> copy(String url); }`, a default implementation using `share_plus` and `Clipboard`, and a provider `shareAction` that tests override. A `shareUrlFor(String id)` helper builds the full URL: on web from `Uri.base` (origin, base href, `#`, `FacilityLink.path(id)`); elsewhere from the compile-time value `String.fromEnvironment('SPRINT_WEB_BASE')` plus `#` plus the path; when that value is empty it returns just `FacilityLink.path(id)` and the share text carries the facility name (R7). The web check MUST live in a new file `lib/core/adaptive/web_origin.dart` exposing `String? webBaseUrl()` (returns origin plus base href on the web, null elsewhere; this is the only place `kIsWeb` and `Uri.base` are used), because the no-platform-checks guard bans `kIsWeb` anywhere else. `share_provider.dart` calls `webBaseUrl()` and never names a platform. Add a one-case test in `test/core/adaptive/web_origin_test.dart` (null on the VM test runner).
- [X] T054 [US5] Add the share action to the details app bar and a "نسخ اللينك" item in `facility_details_view.dart`, with a confirmation (an adaptive toast or sheet message, `catalogueShareCopied`) after copying. 48dp targets and Arabic semantics labels.
- [X] T055 [P] [US5] Edit `.github/workflows/deploy.yml`: add `--dart-define=SPRINT_WEB_BASE=<the Pages URL of this repository, https://<owner>.github.io/sprint-app/>` to the existing `flutter build web` line (`--base-href /sprint-app/` stays). Take the owner from this repository's `git remote get-url origin`. Do not change anything else in the workflow.

**Checkpoint**: every facility page is shareable and the link round-trips.

---

## Phase 8: User Story 6 - It works on every screen, language and theme (Priority: P2)

**Goal**: The three screens hold up in Arabic and English, light and dark, at 200% text, at every size class, with a screen reader, a keyboard, reduced motion, a hinge, and a failing repository (FR-030 – FR-034, SC-005, SC-008).

**Independent Test**: Walk home, list and details through the matrix in `quickstart.md` scenario 6 and run the new tests.

- [X] T056 [P] [US6] `test/features/catalogue/presentation/matrix_test.dart`: pump home, the list and the details of the pool at widths 400, 700, 1000 and 1300, in `ar` and `en`, light and dark, at text scale 1.0 and 2.0; fail on any overflow or `RenderFlex` error; every interactive element is at least 48dp; no hard-coded left/right alignment (the source scan guard also runs) (FR-030 – FR-032, SC-005).
- [X] T057 [P] [US6] `test/features/catalogue/presentation/semantics_test.dart`: cards, filter chips, type chips, booking rows, hours rows and price rows each expose a meaningful Arabic label (name, type, unit, availability, price and whose price), not "button"; the carousel images have labels (FR-032, SC-008).
- [X] T058 [P] [US6] `test/features/catalogue/presentation/keyboard_motion_test.dart`: Tab reaches filters, cards and the details actions in a sensible order with a visible focus ring; Enter and Space activate; with `disableAnimations` true the carousel, skeletons and list changes do not animate (FR-032, constitution V).
- [X] T059 [P] [US6] `test/features/catalogue/presentation/failure_and_hinge_test.dart`: a catalogue repository override that throws once shows `CatalogueErrorView` on home, list and details and the retry button reloads without leaving the screen; with a vertical hinge `DisplayFeature` at 1000px the list and the details pane stay on their own sides and nothing sits under the hinge; and changing `displayFeatures` from none to a vertical fold and back, with a filter set and a facility selected, keeps both the filter and the selected facility (FR-013, FR-033, R10, constitution V).
- [X] T060 [US6] Fix every failure the four tests above find, in the screens and widgets only (no test is weakened). If a fix needs a new ARB key, add it in one block with Arabic and English together and run `flutter gen-l10n`.

---

## Phase 9: Polish and release

**Purpose**: Final checks, evidence and the merge with feature 003.

- [X] T061 Run `flutter analyze`, `flutter test` (the whole suite including the Foundation's guards: tokens, direction, strings, ARB parity, fonts, no platform checks, presentation-only, the new domain-purity guard) and `flutter build web --release --base-href /sprint-app/`. All three must pass. Fix any finding.
- [ ] T062 Walk `specs/004-facility-catalogue/quickstart.md` scenarios 1 to 6 by hand on web (and, where a simulator or device is available, on iOS and Android), at a compact, medium and wide window in Arabic and English. Record what was checked and what was not in `specs/004-facility-catalogue/evidence.md` (SC-001 – SC-008, SC-010).
- [x] T063 Measure the web load time of home, list and details the way the 002 evidence did (`specs/002-design-system-widgets/evidence.md`) and record the numbers in `evidence.md`; the first route must not import more than the Foundation's budget allows (SC-009, NFR-01). Also time a filter change on the list (tap a filter chip to the new result count on screen) on seed data and record it; it must be under 1 second (SC-002).
- [x] T064 Moved to feature 003 (2026-11-16): 004 is merged into `develop` first, because its CI is green and 003's is not yet. Feature 003 then merges `develop` into its branch (a merge commit, never a rebase) and resolves the overlap in `routes.dart`, `app_router.dart`, the two ARB files, `seed_data.dart`, `sprint_format.dart`, `pubspec.yaml` and `pubspec.lock` (plan R9). Nothing to merge on this branch.
- [x] T065 Open the pull request against `develop` (one PR for the feature). The description lists the BRD IDs covered (FR-CAT-01 to FR-CAT-04, US-01 catalogue half, US-11 display, BR-05, BR-15 – BR-17, BR-19, BR-45), the out-of-scope list from the spec, the amended FR-029, and the evidence file. Do not edit `CLAUDE.md` in this PR: the "built" line for feature 4 is added after the merge, in a separate docs PR, as for 002.

---

## Dependencies and execution order

- **Phase 1** first. **Phase 2** blocks every story; inside it: the four pure rules, the seed extras and the shared widgets can run in parallel (`[P]`), but the three routes tasks run in order, the shared ARB task comes before the mapper and the screens, and the providers task comes before the mapper and the screen skeleton.
- **US1, US2, US3** (all P1) depend only on Phase 2 and can be built in any order or in parallel by different people; each replaces its own stand-in (home placeholder, list slot, name-only pane). Their ARB-edit and `catalogue_providers.dart` tasks touch the same files, so run those tasks one after another even when the stories are parallel.
- **US4** depends on US1 (home screen and `homeContent`). **US5** depends on US3 (the details page). **US6** depends on US1, US2 and US3 (and on US4 and US5 if they are built).
- **Phase 9** is last; the merge task waits for feature 003 to land in `develop`.

### Parallel examples

- Phase 2: the four pure-rule tasks with their tests, `seed_catalogue_extras.dart`, `section_card.dart` with `catalogue_error_view.dart`, and `facility_not_found.dart` touch different files.
- US3: `price_groups.dart` and `hours_view.dart` with their tests, `photo_carousel.dart`, and the five section widgets are all different files.
- US6: the four test files can be written side by side.

## Implementation strategy

- **MVP**: Phase 1, Phase 2 and US1 (the guest first screen), then US3 and US2 to complete the P1 journey. That is what the defense walk-through needs first (SC-010).
- **Incremental delivery**: US4 next (signed-in home), then US6 (the matrix), then US5 (share, Should priority). Merge `develop` into the branch as soon as 003 lands, not at the very end, to keep conflicts small.
- Keep each commit small and green: one task, one commit, with BRD IDs in the message.
