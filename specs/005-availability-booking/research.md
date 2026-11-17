# Research: Availability and Booking

Decisions for [plan.md](plan.md). Each one says what was chosen, why, and what was rejected. The
Foundation already has the booking rules (`lib/features/booking/domain/`) and the in-memory
repositories; this feature adds the presentation layer and closes the gaps listed in R4 – R7.

## R1. Where the screens plug in

**Decision**: A new `lib/features/booking/presentation/` beside the existing `domain/` and `data/`.
The existing route `/facilities/:id/schedule` keeps its path and name and now shows the schedule; it
gains three children: `summary`, `checkout` (the "قريبًا" hand-off) and `done/:bookingId`. Feature
004's `ScheduleComingSoonScreen`, its three ARB keys and its test are deleted.

The schedule shows where facility details show: full screen on compact, in the details pane beside the
list from medium up. `FacilitiesScreen` gains one optional parameter, `paneBuilder`, and `routes.dart`
(the app layer) passes the booking screens into it, so `features/catalogue` never imports
`features/booking`.

**Why**: One URL means the same thing at every width (004 R2), and the facilities list stays visible on
wide windows while booking.

**Alternatives**: a top-level `/book/...` route outside the shell (loses the list pane and the tab);
letting the catalogue screen import the booking screens directly (a cross-feature dependency).

## R2. The selection lives in the address (FR-012, FR-022, FR-031)

**Decision**: The day, unit, trainer and chosen time are query parameters of the schedule route and
are carried unchanged to `summary` and `checkout`:

`/facilities/<id>/schedule?day=2026-11-19&unit=u-pool-2&trainer=tr-1&start=1700&end=1800`

`day` is a Cairo calendar date; `start` and `end` are Cairo wall-clock `HHmm`; `end` is present only
for a chosen time. A pure value, `ScheduleSelection`, parses and writes them, and drops anything it
cannot parse. A second pure step, `SelectionResolver`, checks the parsed selection against the loaded
schedule and falls back to defaults with a notice when a day, unit, trainer or slot is no longer valid.

Changing the selection replaces the current location instead of adding a history entry, so back from
the schedule returns to the facility in one step however many slots were tapped. A router test fixes
this behaviour.

**Why**: A reload, a shared link, a return from sign-in, a resize and a fold all reopen the same state
with no extra storage, and the summary can be a real route.

**Alternatives**: a keep-alive provider holding the selection (lost on reload, and the summary could
not be deep-linked); `extra` on the route (lost on web refresh).

## R3. The account gate (FR-021 – FR-023)

**Decision**: Two entries, both from feature 003, unchanged:

1. Tapping "متابعة" as a guest calls `requireAccount(context, ref, reason)`. It pushes sign-in or
   sign-up on top of the schedule, so the schedule's state is kept. When it returns `true` the
   schedule re-reads the session, reloads availability, re-checks the selection (R6) and waits for a
   new tap.
2. `summary`, `checkout` and `done` are `GatedRoute`s with `requiresAccount`. A guest who opens one
   directly (a reload, a link) is redirected to `/sign-in?from=<the same location>` and returns to it.

**Why**: It is exactly the mechanism 003 built for this case (003 R6), and it needs no new code in the
auth feature.

## R4. Loading and refreshing availability (FR-002 – FR-011, SC-001)

**Decision**: One auto-dispose provider, `facilitySchedule(facilityId, trainerId)`, loads the whole
booking window in one pass and in parallel: the facility, its active units, each unit's resolved
`UnitSettings`, each unit's slots from today to the last day of the window, the prices, and (trainer
path) the trainers. A pure builder turns that into a `FacilitySchedule` view model: the days for the
strip, the units for the picker, and the slots per unit and day.

- The strip has as many days as the longest booking window among the facility's units; a unit with a
  shorter window simply has no slots on the later days (the repository already filters by the unit's
  own window).
- A day is **closed** when no active unit has any slot generated for it, and **has availability** when
  any unit has a bookable slot. A unit in the picker **has places** when it has a bookable slot on the
  selected day.
- The provider is invalidated: when the screen opens (auto-dispose), when the day, unit or trainer
  changes, on a manual refresh, when the app resumes, when the booking repository reports a change,
  when the session changes, and at the next slot boundary (a timer from the app clock, so "فات"
  appears without waiting for a tap). While it reloads the previous data stays on screen; skeletons
  show only on the first load.
- `BookingRepository` gains `Stream<void> get changes`, as the auth, identity and verification
  interfaces already have. The in-memory repository already has it through `ChangeSignal`.
- Manual refresh is pull-to-refresh on touch platforms and a refresh action in the app bar everywhere,
  so keyboard and desktop users have it too. The platform-specific pull indicator lives in a new
  `AdaptiveRefresh` in `lib/core/adaptive/`, the only place platform checks are allowed.

**Why**: The grid, the day marks and the unit marks need the same data, so one load avoids three. On
seed data it is instant; with a backend it becomes one query per facility.

**Alternatives**: loading one unit and one day at a time (the day marks and unit marks would need extra
calls and would flicker); adding a facility-level method to `AvailabilityRepository` now (worth doing
when the backend is chosen, not before: the per-unit method is enough and is already tested).

## R5. Few-left comes from the setting (BR-45, FR-006)

**Decision**: `InMemoryAvailabilityRepository` resolves `fewLeftThreshold` for the unit (unit →
facility → university) and passes it to `AvailabilityService`, so `Slot.state` is already right when it
reaches the screen. Today the service uses its constructor default of 2 and only the catalogue's
"today" summary reads the setting. The schedule view model also carries the resolved threshold per
unit, because `SlotChip` takes it as an input.

The domain `SlotState` (`available`, `fewLeft`, `full`, `past`, `closed`) maps one to one onto the
widget's states, plus `selected`. `closed` is never drawn: the service already omits slots inside a
closure, and inactive units are not listed.

**Why**: Constitution III. Without this a unit-level threshold would change the card on home but not
the schedule.

## R6. A quote before anything is created (FR-024 – FR-028, FR-032, FR-033)

**Decision**: `BookingRepository` gains

`Future<Result<BookingQuote>> quote(BookingRequest request)`

It runs exactly the checks `create` runs (permission, structure, the booker's own overlap, the cap,
places, price and tier) in the same serial queue and writes nothing. In the in-memory repository
`create` and `quote` share one private check, so they cannot drift. `BookingQuote` carries what the
summary shows: tier, amount, whether payment follows, the booking mode, `maxParticipants`,
`cancellationCutoffHours`, `refundPercent`, and the resolved unit and trainer.

It is called when the booker continues from the schedule, when the summary opens, and again when the
summary's main action is tapped. For a paid booking nothing else happens before the "قريبًا" screen.

Refusals gain optional detail so the message can name things (all additive, defaults keep today's
callers working):

| Failure | New optional field | Used for |
| --- | --- | --- |
| `OverlapsOwnBooking` | `bookingId` | naming the other booking's facility and time (BR-13) |
| `TooManyActiveBookings` | `max` | stating the cap (BR-14) |
| `RangeTooLong` | `maxHours` | stating the maximum (BR-08) |
| `SlotTaken`, `SlotFull`, `SlotPast`, `ClosedSlot` | `at` | naming the conflicting hour of a range (US-08) |

**Overlap at the tap (clarify Q2)**: for a signed-in booker the schedule also loads their upcoming
bookings once (`listForUser(upcoming: true)`), and a pure rule, `OwnOverlap.find`, built on the
existing `Booking.holdsPlace` and `Booking.overlaps`, answers at the tap with no round trip. `quote`
stays the authority and repeats the check.

**Why**: The paid path must re-check everything without creating a `PENDING_PAYMENT` booking, because
the Hold belongs to feature 6 (BR-12). Feature 6 will call the same `quote` and then `create`.

**Alternatives**: calling `create` and cancelling (leaves expired bookings and starts Holds this
feature must not start); re-implementing the checks in the screen (constitution IV).

## R7. Two rule gaps found in the Foundation

**7a. Capacity is summed over a range instead of checked per hour.** `ConflictChecker` adds the seats
of every booking that overlaps the request. For a three-hour range in a shared unit with capacity 2,
one booking in hour one and one in hour three count as 2 and the range is refused, although every hour
has a place. **Decision**: check each slot of the request separately (the request is already a run of
grid slots), and report the first slot that fails in `at`. The trainer capacity check gets the same
treatment. The seed's free halls are exclusive, so nothing visible changes today, but the spec's edge
case requires it and the backend must do the same.

**7b. Offers are applied when a booking is created.** `create` passes the seeded offers to
`PricingService`, so a pool booking on Thursday afternoon is priced 20% lower for the internal tier,
while offers are out of scope until feature 10 and the schedule shows the regular price. **Decision**:
the in-memory booking repository takes `applyOffers` (default `false`, set by the data layer); `quote`
and `create` both honour it. Feature 10 turns it on when it adds the offer display. The existing
pricing tests are untouched (they test `PricingService`), and the repository tests that cover offers
pass `applyOffers: true`.

Confirmed by Osman on 2026-11-17 and recorded in `docs/decisions.md`.

**Why**: Otherwise the summary would show a price the schedule never showed, and FR-026 would announce
a "price changed" that the user cannot explain.

**Alternative**: show the discounted price in the summary without a tag (silently different from the
schedule), or pull offer display into this feature (scope creep; BRD §11 still lists offers in P1 as
undecided).

## R8. The three paths (FR-013 – FR-019)

**Decision**: A pure `BookingPath.of(facility)`: `trainer` when the facility requires a trainer,
otherwise `range` when it is free, otherwise `slot`. This matches the rule already in
`AvailabilityService.checkRequest`. A free facility that requires a trainer therefore uses the trainer
path and confirms without payment; the seed has none and BR-10 treats the two as separate kinds, so no
extra screen is built for it.

- **Slot path**: `SlotSelection.tap` selects one bookable slot; tapping another moves it; tapping the
  selected one clears it.
- **Range path**: `RangeSelection.tap(current, tapped, daySlots, maxRangeHours)` is pure. First tap:
  a one-slot range. Second tap on another slot the same day: the range from the earlier to the later.
  A tap with a range already chosen: a new one-slot range from that slot. It refuses, naming the hour,
  when a slot inside is not bookable, and refuses, stating the maximum, when the range is too long.
  Chips between the ends use `SlotChip.rangeFill`.
- **Trainer path (clarify Q3)**: with no `trainer` in the address the screen shows the trainer step: a
  list of trainers (name, bio, "has sessions in the window" from their slots). With a trainer chosen
  it shows the trainer as a summary row with a "تغيير المدرب" action, the day strip, and **one grid**
  of that trainer's sessions across the units they work in, ordered by start time, with no unit
  picker. Each session keeps its unit. If two units offer the same start for one trainer, the first
  bookable one in catalogue order is kept (a trainer is in one place at a time; the seed has no such
  case).

**Why**: Small pure rules are easy to test for every edge case in the spec, and the screen only calls
them.

## R9. Summary, hand-off and the success screen (FR-024 – FR-031)

**Decision**:

- **Summary** is its own route at every width: `…/schedule/summary?<selection>&shown=<amount>`. It
  shows the quote and the catalogue names. `shown` is the amount the schedule displayed; when the
  quote's amount or tier differs, a notice says the price changed (FR-026). The cancellation policy
  line is built from the quote's cutoff hours and refund percent with plural-aware strings: one
  wording when the refund is 100%, one when it is partial, one when it is 0.
- **Paid**: "متابعة للدفع" quotes again, then goes to `…/schedule/checkout?<selection>`: a "قريبًا"
  screen with a way back to the summary. Nothing is written.
- **Free**: "تأكيد الحجز" calls `create` once. A notifier guards against a second call while the first
  is running, and the button shows its loading state. On success the app goes to
  `…/schedule/done/<bookingId>`; because `done` is a sibling of `summary`, back from it lands on the
  schedule, never on the summary. On a rule refusal the app returns to the schedule with the selection
  cleared and the refusal shown.
- **Success screen (clarify, specify Q2)**: a confirmation in words, a `StatusBadge`, the booking code
  inside an LTR isolate, facility, unit, date, time, and "الرجوع للرئيسية". No QR and no
  `BookingTicket`. It reads the booking with `BookingRepository.get` and shows not-found when the
  booking is not the signed-in user's.
- **Wide windows**: on expanded and large, the schedule shows the current selection (time, unit,
  price, main action) in a panel beside the grid instead of the bottom bar. The full summary stays a
  route. This is the reading of US7 scenario 3 this plan takes; a three-column layout (list, grid,
  summary) was rejected as too cramped at 840.

**Why**: A route per step gives feature 6 a place to return to on payment failure (FR-PAY-02: "back to
the same summary") without rework.

## R10. Prices and tier on screen (FR-026, FR-027, US-11)

**Decision**: The schedule shows one price line for the selected unit (or the selected session's
unit): both tiers with labels for a guest, the signed-in person's tier with "سعرك" otherwise, with the
basis word ("للمكان الواحد" / "للحجز كله"), or "مجاني". It reads the catalogue prices and the session
tier, and reuses feature 004's labels. The summary uses the quote only. An `EXTERNAL` booker sees a
line pointing to `/profile/verification`; when the session's verification is pending the line says it
is under review.

**Why**: The schedule's price is a display of catalogue data; the binding price is the quote's.

## R11. Messages and states (FR-010, FR-011, FR-032, SC-009)

**Decision**: Refusals and "your earlier choice is no longer available" show as an inline notice above
the grid (an icon, words, a dismiss action, announced as a live region), not only as a snackbar. One
function maps each `Failure` to its localised message. Empty states (no units, no trainers, nothing
left today) are words with a static icon and a way out. Errors that are not rule refusals show the
catalogue's error view with retry.

**Why**: An inline notice stays readable in a recorded video and for screen-reader users, and a
snackbar can be missed.

## R12. Seed data (FR-037)

**Decision**: A new additive file, `lib/core/seed/seed_booking_extras.dart`, wired in by one line, adds
only what is missing. Everything is relative to "now", as the existing seed is.

| Scenario | Existing seed | Addition |
| --- | --- | --- |
| Exclusive slot booked | pitch A, day +3, 7:00 م | none |
| Closure inside the window | pitch A, day +3 | none |
| Shared slot full | lane 2 (capacity 3), day +3, 10:00 ص | none |
| Shared slot few-left | none | lane 2, day +2: two bookings in one slot (1 place left) |
| Free facility with a taken hour | hall 1, day +4, 10:00 – 12:00 | none |
| Trainer at capacity, lane has places | trainer 1 (capacity 3) has one booking | two more bookings for the same session, in a room with capacity 6 |
| Overlap with own booking | internal booker has lane 1, day +3, 6:00 م | none |
| Tiers | internal, external, pending and expired users exist | none |

People who already have a saved demo snapshot use "إرجاع الداتا التجريبية" to get the additions.

## R13. Strings (FR-039)

**Decision**: New ARB keys are prefixed `booking` (none exists today; the slot chip's own strings are
`slot…`). About 90 keys in Arabic and English. Actions are verbal nouns ("متابعة", "متابعة للدفع",
"تأكيد الحجز", "تغيير المدرب", "تحديث المواعيد"). A `copy-review.md` is produced during implementation, as in
features 001 – 003.

## R14. Tests (SC-004 – SC-011)

**Decision**:

- **Unit**: each new pure rule (`BookingPath`, `ScheduleSelection`, `SelectionResolver`,
  `ScheduleBuilder`, `SlotSelection`, `RangeSelection`, `OwnOverlap`, the policy text inputs).
- **Repository**: `quote` against every refusal; `quote` writes nothing; per-slot capacity (R7a);
  `applyOffers` (R7b); threshold from settings (R5); two simultaneous `create` calls for the same
  exclusive slot and for the last shared place give exactly one booking (FR-034).
- **Widget**: schedule (each path, each state, notices, skeleton, error, empty), summary (paid, free,
  each tier, price-changed notice), success, checkout placeholder; at each size class, RTL and LTR,
  light and dark, 200% text, semantics, 48dp targets, keyboard, reduced motion.
- **Router**: selection in the address, replace-not-push, gated children, fallback for invalid
  parameters, back from `done`.
- **Acceptance** (`test/acceptance/`): `us01_slots_guest_return`, `us06_exclusive_to_summary`,
  `us07_shared_place`, `us08_free_range`, `us09_trainer`, `us11_tier_price`.
- **Guards**: the existing ones run over the new files. `catalogue_domain_pure_test` is the model for
  a new `booking_domain_pure_test`.

No pixel goldens, as before.

## R15. What changes outside the new folder

Additive edits only, listed so the review knows where to look: `routes.dart` (three child routes, the
schedule builder), `facilities_screen.dart` (`paneBuilder`), `booking_repository.dart` (`quote`,
`changes`), `in_memory_booking_repository.dart` (shared check, `applyOffers`), `conflict_checker.dart`
(per-slot capacity), `failure.dart` (optional fields), `in_memory_availability_repository.dart`
(threshold), `in_memory_data_layer.dart` (wiring), the seed wire-in, the two ARB files, and a new
`lib/core/adaptive/adaptive_refresh.dart`. No token and no design-system widget changes; under `docs/` only
`decisions.md` gains two rows. `CLAUDE.md` gets its "built" note after the merge.
