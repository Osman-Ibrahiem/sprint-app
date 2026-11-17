---

description: "Task list for the Availability and Booking feature"
---

# Tasks: Availability and Booking

**Input**: Design documents from `/specs/005-availability-booking/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Included. The plan's testing section (research R14) and the constitution (a pull request needs static analysis, all automated tests and a web build to pass) require them. Each story lists its tests first, and they MUST fail before the code they cover exists.

**Organization**: Grouped by user story. Phase 2 corrects the Foundation's rules, adds `quote`, and builds what every story needs (pure rules, the address state, routes, providers, shared widgets, seed). After it, US1 is the base screen; US2, US3, US4 and US5 each add one path on top of it and can be shown on their own.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: US1 schedule · US2 paid slot to summary · US3 guest gate and return · US4 free range · US5 trainer · US6 tier price · US7 every size, language and theme
- Paths are relative to the repository root (single Flutter package, see plan.md)

## Rules for every task

- These rules carry the cross-cutting requirements FR-035, FR-036 and FR-039 – FR-043; the guard tests and US7's tests check them.
- Tokens only, no raw colours or numeric style literals (sizes the tokens lack come from `SprintExtras`); direction-aware layout; strings only in `lib/l10n/*.arb`, Arabic and English together, every new key prefixed `booking` (constitution II, V; research R13). Copy is light Egyptian dialect, actions are verbal nouns, Western digits, 12-hour time, "120 ج.م" / "EGP 120" through `SprintFormat`.
- Every setting is read through `SettingsRepository` (`UnitSettings.resolve`, plus `fewLeftThreshold`), never typed into a screen or a rule (constitution III, FR-036).
- Files under `lib/features/booking/domain/` import nothing from Flutter, Riverpod or `data/`. Screens and providers read repository **interfaces** through `lib/core/providers/data_providers.dart`, never an `in_memory_*` class (constitution IV).
- No platform checks outside `lib/core/adaptive/`. Use `DayStrip`, `SlotChip`, `StatusBadge`, `SprintButton` and `OptionGroup` as they are: no new state, no restyling, nothing added to `lib/core/widgets/`. Icons through `SprintIcon` / `DirectionalIcon` only.
- One primary `SprintButton` per screen. Every state carries a word or an icon. Targets are at least 48dp. Loading shows skeletons, not spinners. Motion respects reduce-motion.
- No Hold, no payment and no `PENDING_PAYMENT` booking is created anywhere in this feature. `BookingRepository.create` is called only for a free facility.
- The selection lives in the address (contracts/routes.md). No provider or widget stores it.
- Do not edit `CLAUDE.md`, tokens, or anything under `docs/` (the two `docs/decisions.md` rows are already committed).
- Commit messages cite BRD IDs. Branch: `005-availability-booking`. No force-push, no rebase, no history rewrite.
- After editing an ARB file run `flutter gen-l10n`; after editing a Riverpod or Freezed file run `dart run build_runner build --delete-conflicting-outputs`.

---

## Phase 1: Setup

**Purpose**: A known-green baseline and the guard that protects the new folder.

- [X] T001 Run `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze` and `flutter test` on the clean branch. All must pass. Create `specs/005-availability-booking/evidence.md` with a "Baseline" section recording the date and the number of passing tests.
- [X] T002 [P] Add the guard test `test/guards/booking_domain_pure_test.dart`, modelled on `test/guards/catalogue_domain_pure_test.dart`: every `.dart` file in `lib/features/booking/domain/` fails the test if it imports `package:flutter`, `package:flutter_riverpod`, `package:riverpod_annotation` or anything under `features/*/data/`; and no `.dart` file under `lib/features/booking/presentation/` may import a file whose name starts with `in_memory_` or mention `InMemoryDataLayer`. It passes now (the presentation folder does not exist yet) and protects every later task.

---

## Phase 2: Foundational (blocks every user story)

**Purpose**: repository and rule corrections, `quote`, the pure rules and address state, routes, providers, shared widgets and seed. No user story starts before this phase is done.

### Repository and rule changes (research R5, R6, R7)

- [X] T003 [P] In `lib/core/result/failure.dart` add optional, nullable fields with `const` constructors that keep every existing call compiling: `OverlapsOwnBooking({this.bookingId})` (`String?`), `TooManyActiveBookings({this.max})` (`int?`), `RangeTooLong({this.maxHours})` (`int?`), and `{this.at}` (`DateTime?`, UTC) on `SlotTaken`, `SlotFull`, `SlotPast` and `ClosedSlot` (data-model.md "Failure"). No other failure changes.
- [X] T004 Tests first, in `test/features/booking/conflict_checker_test.dart` (add cases, keep the existing ones): (a) shared unit, capacity 2, a three-slot request, one existing booking in slot one and one in slot three → accepted; (b) the same with two bookings in slot two → `SlotFull` with `at` = start of slot two; (c) exclusive unit, three-slot request, booking in slot three → `SlotTaken` with `at` = start of slot three; (d) trainer capacity is also checked per slot; (e) `OverlapsOwnBooking.bookingId` is the overlapping booking's id; (f) `TooManyActiveBookings.max` is the setting's value. They must fail.
- [X] T005 Change `lib/features/booking/domain/conflict_checker.dart` so places are checked for each grid slot of the request instead of summed over it (research R7a): `BookingProposal` gains `slotMinutes` (the granularity or session length of the request), the checker steps from `start` to `end` by it and applies the exclusive, shared and trainer-capacity checks to each step, returning the first failure with `at`. Fill `bookingId` and `max` on the two personal refusals. Update the one caller in `lib/features/booking/data/in_memory_booking_repository.dart` to pass `slotMinutes` (session minutes for a trainer facility, else granularity). T004 passes.
- [X] T006 [P] Create `lib/features/booking/domain/booking_quote.dart`: immutable `BookingQuote` with exactly the fields in data-model.md: `facilityId`, `unitId`, `trainerId?`, `start`, `end`, `tier` (`PriceTier`), `amount` (`int`, whole EGP, 0 when free), `requiresPayment` (`amount > 0`), `mode` (`BookingMode`), `maxParticipants` (`int?`), `cancellationCutoffHours` (`int`), `refundPercent` (`int`). Value equality.
- [X] T007 Tests first, new file `test/features/booking/data/booking_quote_test.dart`, using the helpers in `test/helpers/data_env.dart`: `quote` returns `Err(NotPermitted)` for a null `userId`; returns each refusal in the order in contracts/providers.md ("Refusal order"), one test per refusal; returns a quote whose tier and amount equal what `create` then stores; writes nothing (`listForUser` and `allBookings` unchanged, no `changes` event); two calls with nothing changed return equal quotes; `changes` fires once after a successful `create`; with the seeded pool offer active, `quote` and `create` return the regular price by default and the discounted one only when the repository is built with `applyOffers: true`; two `create` calls started together with `Future.wait` for the same exclusive slot give exactly one `Ok` and one `Err(SlotTaken)`, and for the last shared place one `Ok` and one `Err(SlotFull)` (FR-034, SC-005).
- [X] T008 In `lib/features/booking/domain/booking_repository.dart` add `Future<Result<BookingQuote>> quote(BookingRequest request);` and `Stream<void> get changes;` with doc comments from contracts/providers.md. In `lib/features/booking/data/in_memory_booking_repository.dart`: move everything `_create` does before the write into one private `_check(BookingRequest)` that returns the resolved unit, facility, trainer, settings, seats, tier and `PriceQuote` or a `Failure`; `create` calls it then writes; `quote` calls it inside `_serial` **without** `notifyChanged` and maps the result to `BookingQuote`; add the constructor parameter `applyOffers` (default `false`) and pass `const []` as the offers when it is off. Update any other implementer of the interface under `lib/` and `test/` so the project compiles. In `test/features/booking/booking_repository_test.dart` pass `applyOffers: true` only to the tests that assert an offer price. T007 passes.
- [X] T009 Tests first, then code, for the few-left setting (research R5, BR-45): add `test/features/booking/data/availability_threshold_test.dart` (a shared unit with 3 places left is `available` with the default threshold 2, becomes `fewLeft` when `fewLeftThreshold` is set to 3 at the unit, and at the facility when the unit has no value). Then in `lib/features/booking/data/in_memory_availability_repository.dart` resolve `SettingKeys.fewLeftThreshold` with `unitId` and `facilityId` and call `AvailabilityService(fewLeftThreshold: …).slots(...)` instead of the injected default. In `lib/features/booking/domain/availability_service.dart` correct the doc comment on `fewLeftThreshold`, which calls it "a display hint, not a BRD setting": it is the `fewLeftThreshold` setting (BR-45) and the default is only for tests. Update the wiring in `lib/core/data/in_memory_data_layer.dart` if it passes a service instance.
- [X] T010 [P] Create `lib/core/seed/seed_booking_extras.dart` and wire it into the seed with one line in `lib/core/seed/seed_data.dart` (research R12), everything relative to "now" like `seed_bookings.dart`: (a) two `CONFIRMED` bookings by two different seeded users in the same slot of lane 2 (`SeedIds.pool2`, capacity 3) on day +2 at 11:00, so one place is left and the slot is few-left; (b) two more `CONFIRMED` bookings with `trainerId: SeedIds.trainerRecord1` for the session that already has one (room 1, day +4, 10:00), so trainer 1 (capacity 3) is at capacity while the room (capacity 6) has places. First read `lib/core/seed/seed_users.dart` to confirm trainer 1 is available in room 1 at that hour; if not, use an hour inside the seeded availability and say so in a comment. Mark the file as placeholder data until Dr. Sara's data arrives (FR-037). Add `test/core/seed/seed_booking_extras_test.dart` asserting both states through `AvailabilityRepository.slots` with a fixed clock, and that no seeded user ends up with two overlapping bookings.

### Pure rules and address state

- [X] T011 [P] `lib/features/booking/domain/booking_path.dart` with `test/features/booking/domain/booking_path_test.dart`: `enum BookingPath { slot, range, trainer }` and `BookingPath.of(Facility)`: `requiresTrainer → trainer`; else `isFree → range`; else `slot`; a free facility that requires a trainer is `trainer` (FR-013, research R8).
- [X] T012 [P] `lib/features/booking/domain/schedule_selection.dart` with `test/features/booking/domain/schedule_selection_test.dart` (data-model.md, contracts/routes.md): immutable value with `day` (Cairo date, nullable), `unitId?`, `trainerId?`, `startMinutes?`, `endMinutes?`; `fromQuery(Map<String,String>)` reads `day` as `yyyy-MM-dd`, `unit`, `trainer`, `start` and `end` as Cairo wall-clock `HHmm`, and drops anything unparsable, a `start` without `end`, and `end <= start`; `toQuery()` writes only what is set, in a fixed key order; round-trip equality; `hasTime`; `clearTime()`; `withDay` (clears the time, keeps unit and trainer), `withUnit` (clears the time), `withTrainer` (clears the time and the unit); `startInstant` / `endInstant` convert to UTC through `CairoTime.atWallClock`.
- [X] T013 [P] `lib/features/booking/domain/facility_schedule.dart` with `test/features/booking/domain/facility_schedule_test.dart`: the view models `FacilitySchedule`, `ScheduleDay`, `ScheduleUnit`, `ScheduleTrainer`, `ScheduleSlot` with the fields in data-model.md, and the pure `ScheduleBuilder.build(facility, units, settingsByUnit, fewLeftByUnit, slotsByUnit, pricesByUnit, trainers, trainer, now)`. Rules to test: one `ScheduleDay` per day of the longest `bookingWindowDays` among the units, starting today (Cairo); `isClosed` when no unit has any slot that day; `hasAvailability` when any unit has a bookable slot; `units` are active units in catalogue order (trainer path: only units where the chosen trainer has slots); `hasPlacesOn(day)`; `defaultDay` = first day with availability, else first not-closed day, else today; `defaultUnit(day)` = first unit with places that day, else the first unit; `slotsFor(unitId, day)` in time order; `sessionsOn(day)` merges the trainer's units by start and, for equal starts, keeps the first bookable in catalogue order; `ScheduleTrainer.hasSessionsInWindow`.
- [X] T014 [P] `lib/features/booking/domain/selection_resolver.dart` with `test/features/booking/domain/selection_resolver_test.dart`: `resolve(ScheduleSelection, FacilitySchedule)` returns the selection to show and a list of notices. Unknown, past, closed or out-of-window day → `defaultDay`; unknown or inactive unit → `defaultUnit(day)`; unknown trainer → no trainer; a time that is not a run of bookable slots of that unit and day → time cleared; each replacement of something the address **did** carry adds a `choiceNoLongerAvailable` notice, while filling a missing value adds none. Also, in the trainer path a chosen time fixes the unit from the session (FR-003, FR-010, FR-012, FR-018).
- [X] T015 [P] `lib/features/booking/domain/own_overlap.dart` with `test/features/booking/domain/own_overlap_test.dart`: `OwnOverlap.find(List<Booking> mine, DateTime start, DateTime end, DateTime now) → Booking?` using only `Booking.holdsPlace(now)` and `Booking.overlaps`; cancelled and expired bookings and adjacent (touching) times do not count (BR-13, FR-033).

### Routes, providers and shared pieces

- [X] T016 Tests first, new file `test/features/booking/presentation/booking_routes_test.dart` with a harness router (see `test/features/catalogue/presentation/catalogue_routes_test.dart`): `/facilities/<id>/schedule` builds the schedule screen (not the coming-soon screen) inside the shell with the facilities tab selected; query parameters reach the screen as a `ScheduleSelection`; `summary`, `checkout` and `done/<bookingId>` send a guest to `/sign-in?from=<same location with its query>`; `summary` and `checkout` without a complete selection (`day`, `unit`, `start`, `end`) redirect to the schedule with what is valid; at a medium width the schedule renders in the details pane beside the list. They must fail.
- [X] T017 In `lib/features/catalogue/presentation/facilities/facilities_screen.dart` add the optional `paneBuilder` (`Widget Function(BuildContext)?`): when set, it replaces the **whole** details slot for that route, including the slot's app bar and its share actions, at every width, so the booking screen it returns owns its own `AdaptiveAppBar` and there is never a second bar; the list slot, `DisplayFeatureLayout` and the compact / wide switch stay as they are (research R1). The catalogue must not import anything from `features/booking`. Add a case to `test/features/catalogue/presentation/facilities_screen_layout_test.dart`: with a `paneBuilder` exactly one app bar shows at 400 and at 1000, and the list is still on the start side at 1000. Keep the existing catalogue tests green.
- [X] T018 In `lib/app/router/routes.dart`: `AppPaths.facilitySchedule(id, [ScheduleSelection? selection])`, `bookingSummary(id, selection, {int? shown})`, `bookingCheckout(id, selection)` and `bookingDone(id, bookingId)` exactly as in contracts/routes.md, building the query only through `ScheduleSelection.toQuery()`; `AppRouteNames.bookingSummary`, `bookingCheckout`, `bookingDone`; the `schedule` route's builder returns `FacilitiesScreen(selectedId: id, paneBuilder: …)` with the schedule screen; add three child `GatedRoute`s (`summary`, `checkout`, `done/:bookingId`) with `RouteAccess(requiresAccount: true)` and the incomplete-selection redirect. Until their screens exist, point each at a minimal private stand-in in the same folder as its future file. Delete `lib/features/catalogue/presentation/details/schedule_coming_soon_screen.dart`, its tests, and the ARB keys `catalogueScheduleSoonTitle`, `catalogueScheduleSoonBody`, `catalogueScheduleSoonBack` from both ARB files. T016 passes.
- [X] T019 Add the shared ARB keys in one block to `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` and run `flutter gen-l10n`: the schedule title, refresh action ("تحديث المواعيد"), the main action ("متابعة"), closed-day and nothing-left lines, unit-has-places semantics, the error and empty-state lines (no units, no slots to book), and one message per row of the "Failure → message" table in contracts/providers.md with its placeholders (the other booking's facility and time, the cap, the maximum hours, the conflicting hour, the window days), plus the "your earlier choice is no longer available" line. All prefixed `booking`. Later story tasks add their own keys in their own blocks.
- [X] T020 [P] `lib/features/booking/presentation/widgets/failure_message.dart` with `test/features/booking/presentation/failure_message_test.dart`: one function from a `Failure` (plus the looked-up names it needs) to the localised message, covering every row of the table in contracts/providers.md; hours and dates through `SprintFormat`; an unknown failure falls back to a general line, never a technical text (FR-032, SC-009).
- [X] T021 [P] `lib/features/booking/presentation/schedule/schedule_notice.dart` with a widget test: the inline notice (an icon through `SprintIcon`, the words, a 48dp dismiss action) drawn from tokens, wrapped in `Semantics(liveRegion: true)`, no colour-only meaning (research R11). And `lib/features/booking/presentation/widgets/booking_error_view.dart`: the booking feature's own error-with-retry view for non-rule failures (words, a static icon, a secondary retry action), with its strings under the `booking` prefix. Do not import the catalogue's `CatalogueErrorView`: features do not import each other's presentation code.
- [X] T022 [P] `lib/core/adaptive/adaptive_refresh.dart` with `test/core/adaptive/adaptive_refresh_test.dart`: `AdaptiveRefresh(onRefresh, child)` uses the platform's pull-to-refresh on touch platforms (Cupertino sliver control on Apple, Material indicator on Android, coloured from tokens) and is a plain pass-through where there is no touch pull (web, desktop); platform decisions go through the existing `AdaptiveTraits` / `adaptive_platform_override.dart`, so the test can force each platform (research R4). It honours reduce-motion.
- [X] T023 Create `lib/features/booking/presentation/providers/booking_providers.dart` (Riverpod codegen) with `facilitySchedule(facilityId, trainerId)` and `myUpcomingBookings`, and `test/features/booking/presentation/booking_providers_test.dart` (contracts/providers.md). `facilitySchedule` is auto-dispose, returns `null` for a missing or unpublished facility, and loads in parallel (`Future.wait`): active units, `UnitSettings.resolve` and `fewLeftThreshold` per unit, `AvailabilityRepository.slots(unit, today, lastWindowDay, trainerId:)` per unit, prices per unit, and for a trainer facility the trainers with their names from `IdentityRepository` and each trainer's slots (for `hasSessionsInWindow`); then `ScheduleBuilder.build`. It re-runs on: `BookingRepository.changes`, a change of `currentSessionProvider`, and a one-shot timer set from `appClockProvider` to the next slot start in the loaded data. `myUpcomingBookings` is `listForUser(userId, upcoming: true)` or empty for a guest. Tests: null for an unpublished id; one load covers every window day; a new booking by another user changes the slot's state without a manual refresh; the timer flips a slot to past with a fake clock; moving the fake clock past Cairo midnight and refreshing drops yesterday from the days and adds a new last day; a slot that ends after midnight belongs to the day it starts on.

**Checkpoint**: `flutter analyze` and `flutter test` are green; the schedule route opens a stand-in.

---

## Phase 3: User Story 1 - See a facility's slots for the coming days (Priority: P1) 🎯 MVP

**Goal**: Anyone opens "عرض المواعيد" and sees the days of the booking window, the unit picker and the selected unit's slots with their states, for a paid facility (the slot path).

**Independent Test**: quickstart.md scenarios 1 and 2, signed out, on the pool and the futsal pitch.

### Tests for User Story 1

- [X] T024 [P] [US1] `test/features/booking/presentation/schedule_screen_test.dart` on seed data with a fixed clock, signed out: the strip has `bookingWindowDays` days starting today and none after; with no parameters the first day with availability and the first unit with places are selected; lane 2 on day +3 shows 10:00 as "مكتمل" and is not tappable; lane 2 on day +2 shows the few-left word at 11:00; an exclusive unit shows no count; today's earlier slots show "فات" and are not tappable; pitch A on day +3 shows no slots while pitch B does; the hall's Friday is a closed day and cannot be selected; a facility with one unit shows its name and no picker; both tier prices show for a guest with their labels; nothing prompts for sign-in while browsing (spec US1 scenarios 1 – 7, 10; FR-001 – FR-008).
- [X] T025 [P] [US1] `test/features/booking/presentation/schedule_states_test.dart`: skeletons shaped like the strip and the grid on first load; a repository that throws shows the error view and retry reloads in place; a facility with no active units shows the "no slots to book" state with a way back; a day with only full and past slots shows the grid plus the nothing-left line; a missing facility id shows feature 004's not-found; changing the booking window, capacity or minimum lead at the unit, facility and university level changes the screen accordingly; one parameterised case per remaining schedule setting: `bookingMode` shared → exclusive hides the count and makes a slot with one booking full, `slotGranularityMinutes` 60 → 30 doubles the slots, and (on the academy) `sessionMinutes` 60 → 90 changes the session length; the refresh action reloads; an `AppLifecycleState.resumed` event reloads; previous data stays visible during a reload; calling the demo-data reset while the schedule is open reloads it from the seed and clears a selection that no longer exists (spec US1 scenarios 8, 9; spec edge cases; FR-009, FR-011, FR-036; SC-008).
- [X] T026 [P] [US1] `test/features/booking/presentation/schedule_address_test.dart`: selecting a day or unit replaces the location (query updated, back stack length unchanged, back returns to the facility page in one step); reopening a location with `day` and `unit` shows them; an invalid `day` or `unit` falls back to the defaults, replaces the address and shows the "no longer available" notice; dismissing the notice removes it (FR-012, contracts/routes.md).

### Implementation for User Story 1

- [X] T027 [P] [US1] `lib/features/booking/presentation/schedule/schedule_day_section.dart`: maps `ScheduleDay` to `DayStripDay` and renders the existing `DayStrip` with `today` from the app clock; `onSelected` reports the day; closed days are passed as `isClosed` (the widget already disables and announces them).
- [X] T028 [P] [US1] `lib/features/booking/presentation/schedule/unit_picker.dart`: the existing `OptionGroup` with one option per `ScheduleUnit`; each option's semantics label adds the localised "فيه أماكن" / "مفيش أماكن" for the selected day and shows a visible non-colour mark; horizontally scrollable on compact; returns nothing for a single unit (shows the unit's name as a label instead) (FR-008).
- [X] T029 [P] [US1] `lib/features/booking/presentation/schedule/slot_grid.dart`: a wrapping, lazily built grid of the existing `SlotChip` (minimum sizes from `SprintExtras`, `space-2` gaps, early to late in reading direction); maps domain `SlotState` to the widget's state with `resolveSlotState` and the unit's `fewLeftThreshold`; `remaining` only for `SHARED`; `price` passed for the spoken label; `selected` and `rangeFill` from the given `ScheduleSelection`; `onSelected` only for bookable slots (FR-005 – FR-007).
- [X] T030 [P] [US1] `lib/features/booking/presentation/schedule/price_line.dart`: for the given `ScheduleUnit`, both tiers with their labels for a guest, or the signed-in tier with "سعرك" (reuse feature 004's label keys), with the basis word ("للمكان الواحد" for `SHARED`, "للحجز كله" for `EXCLUSIVE`), or "مجاني" for a free facility; "السعر لسه متحددش" when a price is missing; amounts through `SprintFormat` (FR-026 display half, BR-15, BR-16).
- [X] T031 [US1] `lib/features/booking/presentation/schedule/schedule_screen.dart`, replacing the stand-in from T018: reads `facilitySchedule` and the `ScheduleSelection` from the route, runs `SelectionResolver`, and replaces the address when the resolver changed something it was given; `AdaptiveAppBar` with the facility name, back, and the refresh action; body in `AdaptiveRefresh`: notice (when any), `ScheduleDaySection`, `UnitPicker`, `PriceLine`, the nothing-left line when it applies, `SlotGrid`; skeleton, error and empty states; refresh on app resume with an `AppLifecycleListener`; selecting a day or unit invalidates `facilitySchedule` and replaces the address. Add this story's ARB keys in one block. T024 – T026 pass.

**Checkpoint**: the schedule is browsable by a guest for every paid facility; nothing can be selected yet.

---

## Phase 4: User Story 2 - Book one slot in a paid facility, up to the summary (Priority: P1)

**Goal**: A signed-in booker selects one slot and continues to a summary that ends at the "قريبًا" checkout hand-off.

**Independent Test**: quickstart.md scenarios 4, 5 and 6, signed in as a seeded booker.

### Tests for User Story 2

- [X] T032 [P] [US2] `test/features/booking/domain/slot_selection_test.dart`: `SlotSelection.tap(current, tapped)` selects a bookable slot (sets `unitId`, `startMinutes`, `endMinutes`), moves the selection to another slot, clears it when the selected slot is tapped again, and ignores full and past slots (FR-014).
- [X] T033 [P] [US2] `test/features/booking/presentation/slot_path_test.dart`, signed in as the internal booker: tapping an available slot shows it as "مختار" and shows the main action "متابعة" with the time and price; tapping another moves the selection; with no selection the action is not active; tapping a slot that overlaps the booker's own seeded booking (lane 1, day +3, 6:00 م, tried on the tennis court at the same time) does not select it and shows the notice naming the pool and its time; with `maxActiveBookingsPerUser` set to the booker's current count, "متابعة" shows the cap notice; when another user's booking takes the selected slot before "متابعة", the notice says it was booked, the selection clears and the chip shows "مكتمل"; on success the app is on `summary` with the same selection and `shown`; and signed in as a non-booker role (`SeedIds.hallManager` and `SeedIds.trainer1`) the same slot can be selected and reaches the summary (spec US2 scenarios 1, 2, 5 – 7; FR-020, FR-023, FR-033).
- [X] T034 [P] [US2] `test/features/booking/presentation/booking_summary_test.dart`: for the futsal pitch as the internal booker the summary shows facility, unit, date, start and end, length, "الملعب كله" with 22 participants, the tier in words, 140 ج.م with "للحجز كله", and the cancellation policy from the settings; for a pool lane it shows "مكان واحد", "للمكان الواحد" and the pool's 4-hour cutoff; for the gym it shows the 50% refund wording; a refund of 0 has its own wording; the main action is "متابعة للدفع" and is the only primary button; tapping it opens `checkout` and stores no booking (`listForUser` unchanged); a slot taken before the tap returns to the schedule with the selection cleared and the notice; back from the summary shows the schedule with the same selection; back from `checkout` shows the summary; signing out while on the summary opens sign-in with `from` set to the summary location, and signing in again returns to it (spec US2 scenarios 3, 4, 8; spec edge cases; contracts/routes.md; FR-024, FR-025, FR-028, FR-031).

### Implementation for User Story 2

- [X] T035 [P] [US2] `lib/features/booking/domain/slot_selection.dart`: the rule in T032.
- [X] T036 [P] [US2] `lib/features/booking/domain/booking_summary_view.dart`: the view model in data-model.md (`coverage` as `wholeUnit(maxParticipants?)` or `onePlace`; `verificationHint` as `none`, `canVerify`, `underReview`; `priceChanged`) and a pure factory from a `BookingQuote`, the names, the session's verification state and `shown`. Unit test in `test/features/booking/domain/booking_summary_view_test.dart`.
- [X] T037 [US2] In `lib/features/booking/presentation/providers/booking_providers.dart` add `scheduleController(facilityId)` (state: current notice, continue in flight) with `tapSlot` (path-aware; for a signed-in user checks `OwnOverlap.find` against `myUpcomingBookings` first and sets the notice instead of selecting), `dismissNotice`, `refresh`, and `continueToSummary` (reloads `facilitySchedule`, re-resolves the selection, calls `BookingRepository.quote`, and returns the summary location or sets a notice and clears the time); and `bookingSummary(facilityId, selection, shown)` (quote plus catalogue names → `Result<BookingSummaryView>`, re-run on session change). Extend `booking_providers_test.dart` for both.
- [X] T038 [P] [US2] `lib/features/booking/presentation/schedule/selection_bar.dart`: the bottom bar for compact and medium: the selected time (and length), the price or "مجاني", and the single primary `SprintButton` "متابعة" with its loading state; hidden when nothing is selected; respects the safe area and never covers the last row of the grid (the grid gets matching bottom padding).
- [X] T039 [US2] Wire selection into `lib/features/booking/presentation/schedule/schedule_screen.dart`: `SlotGrid.onSelected` → `scheduleController.tapSlot` → replace the address; the adaptive haptic on a successful selection; `SelectionBar` → `continueToSummary` → `context.push` of the returned location; the notice from the controller. Guests can select (the gate is US3's task; until then "متابعة" as a guest shows the `NotPermitted` message).
- [X] T040 [P] [US2] `lib/features/booking/presentation/summary/cancellation_policy_text.dart` with a unit-style widget test: builds the policy sentence from `cancellationCutoffHours` and `refundPercent` with plural-aware ARB strings: full refund, partial refund (states the percent), no refund; hours in Western digits (FR-025, BR-30, BR-31).
- [X] T041 [US2] `lib/features/booking/presentation/summary/summary_rows.dart` and `booking_summary_screen.dart`, replacing the stand-in: `AdaptiveAppBar` with back; rows for every `BookingSummaryView` field, each with a label; the policy text; skeleton while the quote loads; a refusal from the quote pops to the schedule with the notice (through `scheduleController`) and the time cleared; the primary action "متابعة للدفع" quotes again then pushes `AppPaths.bookingCheckout`. And `lib/features/booking/presentation/checkout/checkout_coming_soon_screen.dart`, replacing its stand-in: a title, one line saying payment arrives soon, and a secondary action back to the summary; no price entry, no payment control. Add this story's ARB keys in one block. T032 – T034 pass.

**Checkpoint**: the paid slot path runs from the facility page to the checkout placeholder for a signed-in booker.

---

## Phase 5: User Story 3 - A guest picks a slot, signs in and comes back to it (Priority: P1)

**Goal**: A guest's "متابعة" opens the account gate and returns to the same selection.

**Independent Test**: quickstart.md scenario 3.

### Tests for User Story 3

- [X] T042 [P] [US3] `test/acceptance/us01_slots_guest_return_test.dart`, using `test/helpers/sign_in_steps.dart` and `sign_up_steps.dart`: a guest selects a pool slot and taps "متابعة" → the gate prompt names the reason; sign in as the external booker → the schedule is on top again with the same facility, day, unit and slot selected, the price line now shows "السعر الكامل" only, and no navigation happened by itself; tapping "متابعة" again opens the summary. The same through sign-up with a new account (an `EXTERNAL` account, full price, no verification step). Dismissing the gate keeps the selection and books nothing. If the slot is taken while signing in, the return shows the notice and clears the selection. If the returning user has an overlapping booking, the return shows the overlap notice and clears the selection. Opening the `summary` location directly as a guest redirects to sign-in and lands back on the summary with the same selection (spec US3 scenarios 1 – 6; FR-021 – FR-023, FR-033).

### Implementation for User Story 3

- [X] T043 [US3] In `lib/features/booking/presentation/schedule/schedule_screen.dart` and `scheduleController`: when the session is a guest, "متابعة" calls `requireAccount(context, ref, l10n.bookingGateReason)` from `lib/features/auth/presentation/account_gate.dart`; on `true` invalidate `facilitySchedule` and `myUpcomingBookings`, re-resolve the selection, run the `OwnOverlap` check, show any notice, and stop (the user taps again); on `false` do nothing. Add the reason key ("عشان تحجز") to both ARB files. T042 passes.

**Checkpoint**: US-01's second half is complete.

---

## Phase 6: User Story 4 - Book a range of hours in a free facility (Priority: P1)

**Goal**: The range path, a stored `CONFIRMED` booking, and the simple success screen.

**Independent Test**: quickstart.md scenario 7 on the free hall.

### Tests for User Story 4

- [X] T044 [P] [US4] `test/features/booking/domain/range_selection_test.dart` for `RangeSelection.tap(current, tapped, daySlots, maxRangeHours)`: first tap → a one-slot range; second tap on a later slot → the range from the first to the end of the second; second tap on an earlier slot → the range from the earlier to the later; a tap when a range of two or more is chosen → a new one-slot range from that slot; tapping the only selected slot again clears it; a full, past or missing slot inside → `Err` of the matching failure with `at` = that slot's start; longer than `maxRangeHours` → `Err(RangeTooLong(maxHours))`; granularity other than 60 minutes still counts hours by duration; a shared unit accepts a range when every slot has at least one place (FR-015, FR-016, spec edge cases).
- [X] T045 [P] [US4] `test/acceptance/us08_free_range_test.dart` on the seeded hall, signed in, with a fixed clock chosen so that neither today nor day +4 is a Friday (the hall is closed on Fridays): the schedule explains the range rule with the maximum from the setting; tapping 4:00 م then 6:00 م shows the ends as "مختار", the middle with the range fill, and "4:00 م – 7:00 م، 3 ساعات" in words by the action; extending to a fourth hour is refused with the maximum; on hall 1, day +4, 9:00 ص to 11:00 ص is refused naming 10:00 ص; the summary shows "مجاني", no tier price, no payment step and the single primary action "تأكيد الحجز"; confirming creates exactly one `CONFIRMED` booking with `priceAtBooking` 0 and the booker's tier, even when the action is tapped twice quickly; the app lands on the success screen with the booking code inside an LTR isolate, the facility, unit, date and time, a status word, and no QR; back from it shows the schedule with those hours now "مكتمل"; "الرجوع للرئيسية" goes home, where the booking is listed under upcoming; two users confirming overlapping ranges together give one booking and one "just booked" notice; `done/<id>` for another user's booking shows not-found; changing `maxRangeHours` to 2 changes the limit; the confirmed booking is still there after the data layer is rebuilt from the saved demo snapshot, and is gone after the demo-data reset (spec US4 scenarios 1 – 9; FR-029, FR-030, FR-034, FR-038).

### Implementation for User Story 4

- [X] T046 [P] [US4] `lib/features/booking/domain/range_selection.dart`: the rule in T044.
- [X] T047 [US4] Range path in the schedule: `scheduleController.tapSlot` uses `RangeSelection.tap` when `BookingPath.range` and turns an `Err` into the notice; `lib/features/booking/presentation/schedule/schedule_screen.dart` shows the explanatory line (maximum hours and granularity from the unit's settings) above the grid and `SlotGrid` draws `rangeFill` for slots strictly between the ends; `SelectionBar` shows start, end and length in words and "مجاني".
- [X] T048 [US4] In `lib/features/booking/presentation/providers/booking_providers.dart` add `confirmBooking(facilityId, selection)` (`submit()` quotes; when `requiresPayment` is false it calls `BookingRepository.create` with `seats: 1`; a second `submit()` while one is running returns the same future; result is the `Booking` or the `Failure`) and `bookingById(bookingId)` (`null` when missing or `userId` is not the signed-in user's). Extend `booking_providers_test.dart`.
- [X] T049 [US4] In `lib/features/booking/presentation/summary/booking_summary_screen.dart`: for a quote that needs no payment show "مجاني" in place of the price rows, hide the tier price, and make the primary action "تأكيد الحجز" with a loading state; on success `context.go(AppPaths.bookingDone(...))`; on a rule refusal return to the schedule with the notice and the time cleared; on any other error show a retry that cannot create a second booking.
- [X] T050 [US4] `lib/features/booking/presentation/done/booking_done_screen.dart`, replacing its stand-in: a static success icon and a confirmation line, `StatusBadge` for confirmed, the booking code wrapped with the LTR isolate from `lib/core/l10n/ltr_isolate.dart`, facility, unit, date, start and end, and the single primary action "الرجوع للرئيسية" (`context.go(AppPaths.home)`); not-found state with a way home; no QR and no `BookingTicket`; no Lottie (feature 11). Add this story's ARB keys in one block. T044 and T045 pass.

**Checkpoint**: US-08 works end to end and the booking survives a reload (demo snapshot).

---

## Phase 7: User Story 5 - Book a session with a trainer (Priority: P2)

**Goal**: Trainer first, then one grid of that trainer's sessions, then the same summary.

**Independent Test**: quickstart.md scenario 8 on the academy.

### Tests for User Story 5

- [X] T051 [P] [US5] `test/acceptance/us09_trainer_test.dart` on the seeded academy: "عرض المواعيد" shows the trainer step first with each trainer's name, bio and whether they have sessions in the window; no slots show before a trainer is chosen; choosing trainer 1 puts `trainer` in the address and shows one grid of sessions of the session length from settings, with no unit picker, only inside the trainer's availability; days with no session for that trainer are not marked as available; the day +4 10:00 ص session shows "مكتمل" while the room has places; the places left equal the smaller of the room's and the trainer's; "تغيير المدرب" returns to the trainer step and clears the time but keeps the day when still valid; the summary adds the trainer's name, the room and the session length and ends at "متابعة للدفع"; a trainer facility with no trainers, and a trainer with no sessions in the window, each show their own empty state with a way back; reloading with `trainer` and a time in the address restores both (spec US5 scenarios 1 – 7; FR-017 – FR-019).

### Implementation for User Story 5

- [X] T052 [P] [US5] `lib/features/booking/presentation/schedule/trainer_step.dart`: `TrainerList` (one 48dp-or-taller selectable row per `ScheduleTrainer`: name or a neutral label when missing, bio, a word for "has sessions" / "no sessions in the coming days"; a trainer without sessions stays selectable and leads to the empty state) and `ChosenTrainerRow` (the trainer's name with a secondary "تغيير المدرب" action).
- [X] T053 [US5] Trainer path in `lib/features/booking/presentation/schedule/schedule_screen.dart` and `scheduleController`: with `BookingPath.trainer` and no `trainer` in the address show `TrainerList` only; `selectTrainer` replaces the address through `ScheduleSelection.withTrainer` and loads `facilitySchedule(facilityId, trainerId)`; with a trainer show `ChosenTrainerRow`, the day strip, no `UnitPicker`, and `SlotGrid` fed by `FacilitySchedule.sessionsOn(day)`; a tapped session sets `unitId` from the session; the price line uses the selected session's unit (or the first session's unit before a selection); the quote and the booking request carry `trainerId`.
- [X] T054 [US5] In `lib/features/booking/presentation/summary/summary_rows.dart` add the trainer row and the session-length wording when `trainerName` is set. Add this story's ARB keys in one block. T051 passes.

**Checkpoint**: all three paths work.

---

## Phase 8: User Story 6 - The price I see is my tier's price (Priority: P2)

**Goal**: One price per person everywhere in the flow, the verification pointer, and the price-changed notice.

**Independent Test**: quickstart.md scenario 9 with the internal, external, pending and guest accounts.

### Tests for User Story 6

- [X] T055 [P] [US6] `test/acceptance/us11_tier_price_test.dart`: for one pool slot, the internal booker sees 20 ج.م with "سعر الطلاب والعاملين" on the schedule and the summary; the external booker sees 40 ج.م with "السعر الكامل" and a line linking to `/profile/verification`; the user with a pending request sees 40 ج.م and "under review" instead of the link; a guest sees both tiers on the schedule; an exclusive pitch shows the booker's own tier price "للحجز كله"; opening the summary with `shown=40` after the user became internal shows 20 ج.م and the price-changed notice; a free booking made as `EXTERNAL` keeps `tierAtBooking` external after the user is verified; no price anywhere is discounted by a seeded offer (the pool on a Thursday afternoon as internal still shows 20 ج.م) (spec US6 scenarios 1 – 6; FR-026, FR-027; research R7b).

### Implementation for User Story 6

- [X] T056 [US6] In `lib/features/booking/presentation/summary/booking_summary_screen.dart` and `summary_rows.dart`: the tier row in words; the verification hint (`canVerify` → a line with a secondary link to `AppPaths.profileVerification`; `underReview` → the under-review line; `none` → nothing), never blocking the booking; the price-changed notice when `priceChanged` is true, reusing `ScheduleNotice`. Confirm `PriceLine` (T030) re-renders on session change. Add this story's ARB keys in one block. T055 passes.

**Checkpoint**: prices and tiers match the seed for every account kind (SC-006).

---

## Phase 9: User Story 7 - It works on every screen, language and theme (Priority: P2)

**Goal**: The wide-window selection panel, and the adaptive, accessibility and motion matrix.

**Independent Test**: quickstart.md scenario 11 and the new tests.

### Tests for User Story 7

- [X] T057 [P] [US7] `test/features/booking/presentation/matrix_test.dart`: pump the schedule (slot, range and trainer paths, with and without a selection), the summary (paid and free), the success screen and the checkout placeholder at widths 400, 700, 1000 and 1300, in `ar` and `en`, light and dark, at text scale 1.0 and 2.0; fail on any overflow or `RenderFlex` error; every interactive element is at least 48dp (the Apple navigation bar keeps 44pt); in Arabic today is at the start (right) of the strip and slots run early to late in reading direction (spec US7 scenarios 1, 2, 6; SC-010).
- [X] T058 [P] [US7] `test/features/booking/presentation/layout_and_state_test.dart`: at 700 and wider the schedule, summary and success render in the details pane beside the list; at 1000 and 1300 the selection shows in a side panel beside the grid and the bottom bar is absent; at 400 and 700 the bottom bar shows; resizing 1300 → 400 → 1300, and adding then removing a vertical hinge `DisplayFeature`, keeps the facility, day, unit, trainer and selection and puts nothing under the hinge (spec US7 scenarios 3, 4; FR-042; SC-011).
- [X] T059 [P] [US7] `test/features/booking/presentation/semantics_keyboard_motion_test.dart`: a slot reads as a sentence with its time, state and price, and a full or past slot says why it cannot be chosen; days, units, trainers, the notice (live region) and the summary rows have meaningful Arabic labels; Tab reaches days, units or trainers, slots and the action in that order with a visible focus ring, and Enter or Space selects; with `disableAnimations` true selection changes and the notice do not animate (spec US7 scenarios 5, 7, 8; SC-010).

### Implementation for User Story 7

- [X] T060 [P] [US7] `lib/features/booking/presentation/schedule/selection_panel.dart`: the side panel for expanded and large: a prompt in words when nothing is selected, otherwise the unit (and trainer), time, length, price or "مجاني", and the single primary "متابعة"; same callbacks as `SelectionBar`.
- [X] T061 [US7] In `lib/features/booking/presentation/schedule/schedule_screen.dart` choose `SelectionBar` or `SelectionPanel` from the width of the schedule's own area (`WindowSize` of the pane, not the device), laying the grid and panel out with directional widgets; constrain the summary and success content to a readable maximum width on wide panes.
- [X] T062 [US7] Fix every failure T057 – T059 find, in the booking screens and widgets only (no test is weakened, no design-system widget is changed). If a fix needs a new ARB key, add it in one block with Arabic and English together and run `flutter gen-l10n`.

**Checkpoint**: all seven stories are complete.

---

## Phase 10: Polish and release

**Purpose**: the remaining acceptance tests, copy review, final checks, evidence and the pull request.

- [X] T063 [P] `test/acceptance/us06_exclusive_to_summary_test.dart` and `test/acceptance/us07_shared_place_test.dart`: the two BRD stories walked from the facility page. US-06: an exclusive pitch slot to the summary and the checkout placeholder; a second account that books the same hour (through the repository in the test) makes the first account's "متابعة" show the taken notice. US-07: a shared lane with capacity 3 and two bookings shows one place left; a free shared unit configured in the test with capacity 6 and five bookings accepts one more and then shows "مكتمل" and is not selectable.
- [X] T064 [P] Write `specs/005-availability-booking/copy-review.md` like `specs/003-auth-verification/copy-review.md`: every new Arabic string with its English, checked against the copy rules (dialect, no imperative verbs, verbal-noun actions, Western digits, 12-hour time, currency format). Fix the ARB files where a string fails.
- [X] T065 Run `flutter analyze`, `flutter test` (the whole suite, including every guard: tokens, direction, strings, ARB parity, fonts, no platform checks, no raw icon, presentation-only, catalogue and booking domain purity) and `flutter build web --release --base-href /sprint-app/`. All three must pass. Fix any finding.
- [ ] T066 (partly done: see evidence.md) Walk `specs/005-availability-booking/quickstart.md` scenarios 1 to 11 by hand on web at a compact, a medium and a wide window in Arabic and English, and scenarios 1, 4, 7 and 8 on one iOS and one Android target where a simulator or device is available. Use "إرجاع الداتا التجريبية" first. Record what was checked and what was not in `specs/005-availability-booking/evidence.md` (SC-001 – SC-012).
- [ ] T067 (partly done: see evidence.md) Measure and record in `evidence.md`: the time from tapping "عرض المواعيد" to the slots being on screen on web with seed data (must be under 2 seconds, SC-001, NFR-09), and the web first-load time the way `specs/002-design-system-widgets/evidence.md` did, with no regression against the 004 numbers.
- [ ] T068 Open the pull request against `develop` (one PR for the feature). The description lists the BRD IDs covered (FR-AVL-01, FR-AVL-02, FR-BKG-01 – FR-BKG-04; US-01 slots half, US-06 to the summary, US-07, US-08, US-09, US-11, US-23; BR-01 – BR-03, BR-05 – BR-11, BR-13 – BR-19, BR-21, BR-30, BR-31, BR-45), the out-of-scope list from the spec, the three Foundation rule corrections (research R5, R7a, R7b), the two `docs/decisions.md` rows, and the evidence file. Do not edit `CLAUDE.md` in this PR: the "built" line for feature 5 is added after the merge, in a separate docs PR.

---

## Dependencies and execution order

- **Phase 1** first. **Phase 2** blocks every story. Inside it: T003 before T004 – T008; T004 before T005; T006 before T007 – T008; T008 before T009's wiring edit and before T010's test; T011 – T015 are independent of each other and of the repository tasks (T013 before T014); T016 → T017 → T018 → T019 in order (T018 and T019 both edit the ARB files); T019 before T020 and T021; T023 needs T008, T009, T011 and T013.
- **US1** needs Phase 2 only. **US2** needs US1 (it adds selection and the summary to the schedule). **US3** needs US2 (the gate sits on "متابعة" and returns toward the summary). **US4** needs US2 (the summary screen and the controller). **US5** needs US2. **US6** needs US2 and, for the frozen-tier test, US4. **US7** needs US1 – US5.
- US4 and US5 are independent of each other and of US3, so after US2 they can be built in parallel by different people. They touch the same files (`schedule_screen.dart`, `booking_providers.dart`, `summary_rows.dart`, the ARB files), so those edits go one after another even then.
- **Phase 10** is last.

### Parallel examples

- Phase 2: T003, T006, T010, T011, T012, T013, T015 and T022 touch different files and can start together; so can T019 – T021 once T019's keys exist.
- US1: the three test files (T024 – T026), then the four widgets (T027 – T030), before T031 assembles them.
- US2: T032 – T034 (tests), then T035, T036, T038 and T040 side by side, then T037, T039 and T041 in order.
- US7: the three test files and T060 can be written side by side.

## Implementation strategy

- **MVP**: Phase 1, Phase 2 and US1 give a browsable schedule that already replaces "قريبًا". US2 and US3 complete the paid journey to the summary; US4 completes the first journey that ends in a stored booking. Those four are the P1 scope to show Dr. Sara.
- **Incremental delivery**: US5 (trainer), then US6 (tier wording and notices), then US7 (wide layout and the matrix), then Phase 10.
- Every flow must run to its end with no dead end, because the defense is a recorded video of the working system (decisions.md 2026-11-16): the paid path ends on a deliberate "قريبًا" screen with a way back, never on a blank or broken screen.
- Keep each commit small and green: one task, one commit, with BRD IDs in the message.
