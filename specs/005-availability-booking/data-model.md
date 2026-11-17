# Data Model: Availability and Booking

What this feature adds on top of the Foundation's entities (`Facility`, `BookableUnit`, `Slot`,
`Booking`, `UnitSettings`, `Trainer`, `Price`, `Failure`). Stored entities do not change shape;
`Booking` is created here only for free facilities. Everything below is either a view model (built for
a screen, never stored) or a pure rule. Pure means: no Flutter, no Riverpod, no repository, and "now"
is a parameter.

All instants are UTC; days and wall-clock times are Africa/Cairo (NFR-03).

## Changed contracts (existing types)

### `BookingRepository` (interface)

| Member | Change | Notes |
| --- | --- | --- |
| `quote(BookingRequest) → Result<BookingQuote>` | new | same checks as `create`, writes nothing (R6) |
| `Stream<void> get changes` | new | fires after every successful write (R4) |
| `create`, `get`, `listForUser`, … | unchanged | `create` is used here for free bookings only |

### `BookingQuote` (new, domain, immutable)

| Field | Type | Meaning |
| --- | --- | --- |
| `facilityId`, `unitId`, `trainerId?` | ids | what would be booked |
| `start`, `end` | `DateTime` | the requested period |
| `tier` | `PriceTier` | the booker's tier now (BR-17) |
| `amount` | `int` | whole EGP for this booking; 0 when free |
| `requiresPayment` | `bool` | `amount > 0` (BR-19) |
| `mode` | `BookingMode` | decides "whole unit" or "one place" and the price basis (BR-16) |
| `maxParticipants` | `int?` | shown for `EXCLUSIVE` (BR-02) |
| `cancellationCutoffHours` | `int` | for the policy line (BR-30) |
| `refundPercent` | `int` | for the policy line (BR-31) |

### `Failure` (additive optional fields, R6)

`OverlapsOwnBooking.bookingId`, `TooManyActiveBookings.max`, `RangeTooLong.maxHours`, and `at` on
`SlotTaken`, `SlotFull`, `SlotPast`, `ClosedSlot`. All nullable, all default to null.

### `ConflictChecker` (rule fix, R7a)

Places are checked for each grid slot of the request, not summed over the request. Inputs gain the
slot boundaries of the request (or the granularity). Output is unchanged except that `SlotTaken` and
`SlotFull` carry `at`.

### In-memory repositories

- `InMemoryAvailabilityRepository` resolves `fewLeftThreshold` per unit (R5).
- `InMemoryBookingRepository` gains `applyOffers` (default `false`, R7b) and one shared check used by
  `quote` and `create`.

## New pure rules (`lib/features/booking/domain/`)

### `BookingPath`

`enum BookingPath { slot, range, trainer }` and `BookingPath.of(Facility)`:
`requiresTrainer → trainer`; else `isFree → range`; else `slot` (FR-013).

### `ScheduleSelection`

The address state (R2).

| Field | Type | Rule |
| --- | --- | --- |
| `day` | Cairo date? | `yyyy-MM-dd`; ignored when unparsable |
| `unitId` | `String?` | not used in the trainer path's address until a session is chosen |
| `trainerId` | `String?` | trainer path only |
| `start`, `end` | Cairo wall-clock minutes? | both or neither; `end > start` |

`fromQuery(Map<String,String>)` and `toQuery()` round-trip. `hasTime` is true when `start` and `end`
are set. `clearTime()`, `withDay`, `withUnit`, `withTrainer` return copies; changing the trainer or
unit clears the time, changing the day clears the time and keeps unit and trainer (FR-019).

### `FacilitySchedule` (view model) and `ScheduleBuilder`

Built once per load from the repositories' answers (R4).

| Field | Type | Meaning |
| --- | --- | --- |
| `facility` | `Facility` | published |
| `path` | `BookingPath` | |
| `today` | Cairo date | from the app clock |
| `days` | `List<ScheduleDay>` | one per window day |
| `units` | `List<ScheduleUnit>` | active units, catalogue order; in the trainer path, only units where the trainer works |
| `trainers` | `List<ScheduleTrainer>` | trainer path only |
| `trainer` | `ScheduleTrainer?` | the chosen one |
| `slots` | `Map<(unitId, day), List<Slot>>` | every generated slot, in time order |

`ScheduleDay`: `date`, `hasAvailability` (any unit has a bookable slot), `isClosed` (no unit has any
slot). Maps directly onto `DayStripDay`.

`ScheduleUnit`: `id`, `name`, `mode`, `capacity`, `maxParticipants`, `fewLeftThreshold`,
`maxRangeHours`, `granularityMinutes`, `sessionMinutes`, `priceInternal?`, `priceExternal?`, and
`hasPlacesOn(day)`.

`ScheduleTrainer`: `id`, `name?`, `bio`, `capacity`, `hasSessionsInWindow`.

`ScheduleSlot` (what the grid draws): `unitId`, `unitName`, `slot`. In the slot and range paths the
grid lists the selected unit's slots for the selected day. In the trainer path `sessionsOn(day)`
merges the trainer's units by start time; equal starts keep the first bookable in catalogue order
(R8).

Defaults: `defaultDay` is the first day with availability, else the first day that is not closed, else
today. `defaultUnit(day)` is the first unit with places that day, else the first unit.

### `SelectionResolver`

`resolve(ScheduleSelection, FacilitySchedule) → (ScheduleSelection, List<SelectionNotice>)`. Replaces
an unknown or out-of-window day, an unknown or inactive unit, an unknown trainer, and a time that is
not a run of bookable slots, with the defaults, and reports what it dropped so the screen can say "the
earlier choice is no longer available" (FR-010, FR-012).

### `SlotSelection` and `RangeSelection`

- `SlotSelection.tap(current, tapped)`: bookable only; same slot again clears.
- `RangeSelection.tap(current, tapped, daySlots, maxRangeHours) → Result<ScheduleSelection>`:
  the rules in R8. Refusals: `ClosedSlot` / `SlotFull` / `SlotTaken` / `SlotPast` with `at`, or
  `RangeTooLong` with `maxHours`.

### `OwnOverlap`

`find(List<Booking> mine, DateTime start, DateTime end, DateTime now) → Booking?`: the first of the
booker's bookings that holds a place and overlaps (BR-13), using `Booking.holdsPlace` and
`Booking.overlaps`. Used at the tap; `quote` repeats it.

### `BookingSummaryView` (view model)

What the summary screen shows (FR-024): facility name, unit name, trainer name?, date, start, end,
length in minutes, coverage (`wholeUnit(maxParticipants?)` or `onePlace`), tier, amount or free, price
basis, cancellation cutoff hours, refund percent, verification hint (`none`, `canVerify`,
`underReview`), and `priceChanged` (the quote differs from `shown`).

### `ScheduleNotice`

`enum`-like value for the inline notice (R11): a `Failure` to explain, or `choiceNoLongerAvailable`.
One mapping function turns it into a localised message with its details (the other booking's facility
and time, the cap, the maximum hours, the conflicting hour).

## State transitions

Only one, and only for free facilities:

```text
[summary: تأكيد الحجز] → BookingRepository.create → Booking(CONFIRMED)   (BR-19)
```

Paid facilities create nothing here. `PENDING_PAYMENT`, the Hold and every later transition are
feature 6 and feature 7.

Screen states of the flow:

```text
schedule (no selection) → schedule (selection) → [guest: account gate → schedule (selection)]
   → summary → paid: checkout "قريبًا"
             → free: done/<bookingId>
any refusal → schedule (selection cleared, notice shown)
```

## Validation rules (where each one lives)

| Rule | BRD | Authority | Also checked for speed |
| --- | --- | --- | --- |
| Inside the booking window | BR-06 | `quote` / `create` | days outside the window are never drawn |
| Not past, lead time | BR-07 | `quote` / `create` | past slots are not tappable |
| On the grid, open, no closure | BR-05 | `quote` / `create` | closed slots are not generated |
| One slot, or a range up to the maximum | BR-08, BR-09 | `quote` / `create` | `RangeSelection` |
| Places in each slot | BR-02, BR-03, BR-09 | `quote` / `create` (per slot, R7a) | full slots are not tappable |
| No overlap with own bookings | BR-13 | `quote` / `create` | `OwnOverlap` at the tap |
| Active-bookings cap | BR-14 | `quote` / `create` | none |
| Tier and price | BR-15 – BR-18 | `quote` / `create` | schedule price line (display only) |
| Permission to book | BRD §6 | `quote` / `create` | account gate |

## Settings read (FR-036)

`bookingMode`, `capacity`, `maxParticipants`, `bookingWindowDays`, `fewLeftThreshold`,
`minLeadMinutes`, `slotGranularityMinutes`, `maxRangeHours`, `sessionMinutes`,
`maxActiveBookingsPerUser`, `cancellationCutoffHours`, `refundPercent`, each resolved unit → facility
→ university → BRD default through `SettingsRepository` (`UnitSettings.resolve`, plus
`fewLeftThreshold` on its own). `holdMinutes` is not read here.
