# Evidence: Availability and Booking

Recorded checks for feature 005 (`005-availability-booking`). Each section notes the date and what was
run, so later regressions are visible.

## Baseline

- **Date**: 2026-11-17
- **Branch**: `005-availability-booking`
- `flutter pub get`: OK
- `dart run build_runner build --delete-conflicting-outputs`: OK (no stale generated files)
- `flutter analyze`: OK (no issues)
- `flutter test`: **1417 tests passed**

## Phase 2: repository and rules (T003 – T023)

- **Date**: 2026-11-17
- `BookingRepository.quote` shares one private check with `create`; `quote` writes nothing and signals
  nothing (test: `test/features/booking/data/booking_quote_test.dart`).
- `ConflictChecker` checks places slot by slot. A range with one booking in the first hour and one in the
  last is accepted by a shared unit of capacity 2 (it was refused when seats were summed). Only a
  range names the failing hour in `at`; a single slot is refused plainly.
- `fewLeftThreshold` is read for the unit (unit, facility, university) by the availability repository
  (`availability_threshold_test.dart`).
- Offers are off in the in-memory repository (`applyOffers: false`), so `quote` and `create` price the
  regular tier (decisions.md 2026-11-17).
- Guards: `test/guards/booking_domain_pure_test.dart`; the existing ARB parity guard caught three
  placeholder-only strings, which were given words.

## Differences from the plan

Recorded so the review does not look for what is not there.

| Plan | What was built | Why |
| --- | --- | --- |
| `scheduleController` notifier and `confirmBooking` notifier | the schedule screen's own state holds the notice, the in-flight flag and the tap and continue logic; the summary screen's state holds its busy flag. `bookingSummary` and `bookingDone` are providers. | One screen owns each flow, so a notifier added a layer with nothing else reading it. A busy flag set before the first await gives the same "one booking however often it is tapped" (FR-029). |
| `bookingById` provider | `bookingDone(bookingId)`, returning the booking with its facility and unit names, or null when it is not the signed-in person's | the success screen needs the names too |
| Unit picker with `OptionGroup` | its own choice chips (`unit_picker.dart`) | `OptionGroup` is a vertical list; six lanes would push the grid off the screen. The chips are horizontal and carry an icon and words for "has places". |
| `ScheduleNotice` in `data-model.md` | `lib/features/booking/domain/schedule_notice.dart` (with `OverlapInfo`) | as planned, named here |
| Selection panel width 240 | 200, in `SprintExtras` with the minimum pane width 480 and the text scale (1.3) at which the bar stacks | at 240 the grid beside it got one chip column in a 500 px pane; at 200 it keeps two |
| Sign-out on the summary closes it | the router's redirect sends the person to sign-in and back to the summary; the summary only waits meanwhile | one rule for `summary`, `checkout` and `done`; spec edge case and contract updated |
| `SlotChip` in a `Wrap` | each chip in a box sized to its column | `SlotChip` centres itself in all the width it is given, so in a plain `Wrap` every chip took a full row |

## Matrix findings fixed (US7)

- `SlotChip` took a whole row each (above).
- The booking bar overflowed at 200% text: it now stacks its text above its action from text scale 1.3.
- The trainer row overflowed in a 240 px pane (the "has sessions" line, and the name beside "تغيير
  المدرب"): the line is `Flexible`, the name and action are in a `Wrap`.
- The trainer step lost the chosen day, so changing trainer did not keep it (FR-019): fixed in
  `SelectionResolver`.

## Tests

- `flutter analyze`: no issues.
- `flutter test`: **1744 tests passed** (1417 at the baseline, so 327 new).
- Acceptance tests named after the stories: `us01_slots_guest_return`, `us06_exclusive_to_summary`,
  `us07_shared_place`, `us08_free_range`, `us09_trainer`, `us11_tier_price`.
- Matrix: 32 combinations (4 widths, ar and en, light and dark, text 1 and 2) over 8 booking screens,
  no overflow and every target at least 48 dp.
- `flutter build web --release --base-href /sprint-app/`: built.

## By hand on web (T066, partly)

Built release bundle served locally and opened in the app's browser pane, as a guest, on the real date.

- **1300 wide, pool schedule**: seven days, six lanes, both tier prices, slots in two columns; tapping
  12:00 selected it, wrote `day`, `unit`, `start`, `end` into the address, and filled the side panel
  ("حارة 1", "الوقت 12:00 م – 1:00 م، المدة ساعة واحدة"); "متابعة" opened the account gate with
  "عشان تحجز".
- **400 wide, free hall schedule**: Friday shown as closed, two units, the range explanation, slots in
  three columns with past hours marked "فات", bottom navigation intact.

Not done by hand: the sign-in and sign-up returns, the summary and success screens, the trainer path,
English and light theme, and iOS and Android (no simulator was booted). Those are covered by the
automated tests above; a hand walk of `quickstart.md` scenarios 3 – 11 is still to do before the defense
recording.

## Size and speed (T067, partly)

| Measure | `develop` | this branch | Change |
| --- | --- | --- | --- |
| `main.dart.js` | 4,403,242 B (gzip 1,271,905 B) | 4,509,592 B (gzip 1,300,626 B) | +106,350 B (gzip +28,721 B, +2.3%) |

The gzip growth is about the same as feature 004's (+29 KB). The schedule's whole-window load on seed
data, measured around the provider with a stopwatch (10 runs per facility, in a test, no network):
median 7 ms for the pool (6 lanes), 2 ms for the pitch and the hall, 3 ms for the academy, worst 44 ms.
Not measured: time from the tap to slots on screen in the browser, and first load under DevTools
throttling as 002's evidence did; both are still to do for SC-001 and SC-009.
