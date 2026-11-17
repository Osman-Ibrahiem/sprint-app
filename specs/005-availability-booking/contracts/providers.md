# Contract: Repositories, providers and pure rules

Presentation reads only what is listed here. Providers are Riverpod codegen in
`lib/features/booking/presentation/providers/`. Pure rules live in `lib/features/booking/domain/` and
import nothing from Flutter, Riverpod or `data/`. Shapes are in [../data-model.md](../data-model.md).

## Repository interface changes

| Interface | Member | Contract |
| --- | --- | --- |
| `BookingRepository` | `Future<Result<BookingQuote>> quote(BookingRequest)` | Runs every check `create` runs, in the same order and the same serial queue, and writes nothing. A guest request (`userId == null`) returns `Err(NotPermitted)`. Two calls with nothing changed between them return equal quotes. |
| `BookingRepository` | `Stream<void> get changes` | Fires after each successful write. |
| `BookingRepository` | `create` | Unchanged contract. Refusals now carry the optional details in data-model.md. Offers are not applied while `applyOffers` is off (research R7b). |
| `AvailabilityRepository` | `slots` | Unchanged signature. `Slot.state` uses the unit's resolved `fewLeftThreshold` (research R5). |

Refusal order in `quote` and `create` (first failing check wins): not permitted → unit or facility not
found → trainer not found → outside window → past → closed or off-grid → range too long → overlaps own
booking → cap reached → taken or full (first failing slot in `at`) → price not found.

## Providers

| Provider | Returns | Reads | Notes |
| --- | --- | --- | --- |
| `facilitySchedule(facilityId, trainerId?)` | `AsyncValue<FacilitySchedule?>` | catalogue, availability, settings, identity (trainer names), app clock | auto-dispose; `null` = missing or unpublished facility; loads the whole window in parallel; invalidated by the triggers below |
| `myUpcomingBookings` | `AsyncValue<List<Booking>>` | `currentSession`, bookings | empty for a guest; feeds `OwnOverlap` at the tap |
| `scheduleController(facilityId)` (notifier) | `ScheduleUiState` (the resolved selection, the current notice, whether a continue is in flight) | `facilitySchedule`, `myUpcomingBookings`, `currentSession`, bookings | `selectDay`, `selectUnit`, `selectTrainer`, `tapSlot`, `dismissNotice`, `refresh`, `continueToSummary` (returns the location to go to, or sets a notice) |
| `bookingSummary(facilityId, selection, shown)` | `AsyncValue<Result<BookingSummaryView>>` | bookings (`quote`), catalogue, `currentSession` | auto-dispose; re-run on session change |
| `confirmBooking(facilityId, selection)` (notifier) | `AsyncValue<Booking?>` | bookings | `submit()` quotes, then for a free booking creates; ignores calls while one is running (FR-029); for a paid booking returns after the quote |
| `bookingById(bookingId)` | `AsyncValue<Booking?>` | bookings, `currentSession` | `null` when missing or not the signed-in user's |

Refresh triggers for `facilitySchedule` (FR-009): the screen opening, a change of day, unit or trainer,
the manual refresh action, the app resuming, an event on `BookingRepository.changes`, a session
change, and a timer to the next slot boundary taken from the app clock. During a refresh the previous
value stays visible.

Rules for every provider:

- `loading` on first load shows a skeleton shaped like the content; an error that is not a rule
  refusal shows the error view with a retry that invalidates the provider.
- No provider exposes an `in_memory_*` class; they depend on the interface providers in
  `lib/core/providers/data_providers.dart`.
- No provider holds the selection; the address does (routes.md).

## Pure rules

| Rule | Shape | Spec |
| --- | --- | --- |
| `BookingPath.of` | `(Facility) → BookingPath` | FR-013 |
| `ScheduleSelection.fromQuery` / `toQuery` | `(Map<String,String>) ↔ ScheduleSelection` | FR-012 |
| `ScheduleBuilder.build` | `(facility, units, settings per unit, slots per unit, prices, trainers, trainer?, now) → FacilitySchedule` | FR-002 – FR-008, FR-017, FR-018 |
| `SelectionResolver.resolve` | `(ScheduleSelection, FacilitySchedule) → (ScheduleSelection, notices)` | FR-003, FR-010, FR-012 |
| `SlotSelection.tap` | `(ScheduleSelection, ScheduleSlot) → ScheduleSelection` | FR-014 |
| `RangeSelection.tap` | `(ScheduleSelection, ScheduleSlot, daySlots, maxRangeHours) → Result<ScheduleSelection>` | FR-015, FR-016 |
| `OwnOverlap.find` | `(List<Booking>, start, end, now) → Booking?` | FR-033 |
| `ConflictChecker.check` (changed) | per-slot places; `at` on the refusal | FR-034, research R7a |

## UI contracts

| Piece | Contract |
| --- | --- |
| Day strip | the existing `DayStrip` with `ScheduleDay` mapped to `DayStripDay`; nothing added to the widget |
| Unit picker | horizontal choice chips (the existing `OptionGroup`), one per active unit, each with a word for "has places" in its semantics label and a visible mark that is not colour alone; hidden for a single unit and in the trainer path |
| Slot grid | the existing `SlotChip` in a wrapping grid (`SprintExtras` chip sizes, `space-2` gaps), early to late in reading direction; `rangeFill` for the middle of a range; price passed for the spoken label |
| Main action | one `SprintButton` primary per screen: "متابعة" (schedule), "متابعة للدفع" or "تأكيد الحجز" (summary), "الرجوع للرئيسية" (success). Bottom bar on compact and medium; selection panel beside the grid on expanded and large |
| Notice | inline above the grid: icon, words, dismiss; a live region for screen readers |
| Refresh | `AdaptiveRefresh` (new, `lib/core/adaptive/`): the platform's pull-to-refresh on touch; an app-bar refresh action on every platform |
| Haptics | the existing adaptive haptic on selecting a slot (SlotChip README) |
| Booking code | wrapped with the existing LTR isolate |

## Failure → message (one mapping, FR-032)

| Failure | Message says |
| --- | --- |
| `SlotTaken` | the slot was just booked; choose another |
| `SlotFull` | the slot is now full; choose another |
| `SlotPast` | the slot's time has passed |
| `OutsideWindow` | booking opens N days ahead only |
| `ClosedSlot` | that hour is not available (names the hour when `at` is set) |
| `RangeTooLong` | the maximum is N hours |
| `OverlapsOwnBooking` | you already have a booking then (names its facility and time) |
| `TooManyActiveBookings` | you have reached N active bookings |
| `NotPermitted` | this account cannot book |
| `NotFound` | the facility, unit, trainer or price is not available |
