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

## By hand on web (T066)

The release bundle of this branch (after the review fixes and the merge of `develop`) was served locally
and driven in the app's browser pane, mostly at 400 wide, on the real date (Tue 2026-11-17), with the
data saved on the device between steps.

| Quickstart scenario | What was done | Result |
| --- | --- | --- |
| 1 Guest schedule | pool schedule at 400 and at 1300; both tier prices; no prompt while browsing | as expected |
| 2 Closed day | hall: Friday disabled; tennis: the closure day disabled | as expected |
| 3 Guest returns | tapped 6:00 م, "متابعة" → gate sheet → sign in as Karim (external) → back on the same lane, day and time, price line now only "سعرك · السعر العادي 40 ج.م", bar shows 40 ج.م → summary → "متابعة للدفع" → "الدفع قريبًا" with a way back | as expected |
| 4 Summary | facility, unit, day, time, length, one place, tier, 40 ج.م للمكان الواحد, 4-hour cutoff with full refund, verification hint with "طلب توثيق" | as expected |
| 5 Own overlap | signed in as Mona (internal, 55 ج.م for tennis), tapped tennis 6:00 م on the day she holds a lane: notice names "حمام السباحة الأولمبي, Fri, 20 Nov · 6:00 PM – 7:00 PM", slot not selected | as expected |
| 7 Free range | hall, قاعة 2, 4:00 م then 6:00 م: ends selected, middle filled, "الوقت 4:00 م – 7:00 م، المدة 3 ساعات", "مجاني" → summary free, no tier or price rows → "تأكيد الحجز" → success "SP-1106" with details and no QR → "الرجوع للرئيسية": the booking is first under "حجوزاتك الجاية" | as expected |
| 8 Trainer | trainer step with three trainers; chose هشام: "المدرب: الكابتن هشام فؤاد", "تغيير المدرب", Thu and Fri disabled, one grid with "3 أماكن" (trainer capacity, not the room's 6); Wed 11:00 م "مكتمل" while the room has places; full page reload with trainer, day and time in the address restored all three and the price | as expected |
| 11 Adaptive | English and light theme at 400 (LTR days with Today at the left, "Your price · Standard price EGP 40 Per place", "3 places"); dark at 400 and 1300; 1300 side panel with the selection | as expected |

Not walked by hand: scenario 6 (two accounts for one hour), 9 with a pending-request account, 10 (settings
inspector), sign-up, keyboard-only use, the medium (600 – 839) width, and iOS and Android (no simulator
booted). Scenarios 6, 9 and 10 and the keyboard are covered by the automated tests above.

Seen while walking, not bugs of this feature: unit and facility names are Arabic seed data, so they stay
Arabic in the English UI; the day strip shows the browser's thin horizontal scrollbar on web.

## Size and speed (T067)

| Measure | `develop` | this branch | Change |
| --- | --- | --- | --- |
| `main.dart.js` | 4,403,242 B (gzip 1,271,905 B) | 4,509,592 B (gzip 1,300,626 B) | +106,350 B (gzip +28,721 B, +2.3%) |

The gzip growth is about the same as feature 004's (+29 KB).

**Whole-window load on seed data**, around the provider with a stopwatch (10 runs per facility, in a
test, no network): median 7 ms for the pool (6 lanes), 2 ms for the pitch and the hall, 3 ms for the
academy, worst 44 ms.

**Tap to slots in the browser** (release bundle, localhost, accessibility tree on, 400 wide): from setting
the address of a facility page to the schedule to the first slot label appearing in the accessibility
tree, 1.0 s for the gym, 1.65 s for the pool, 1.7 s for the pitch and 1.7 s for the hall. This counts the
page transition and the wait for the accessibility tree to update, so it is an upper bound; it is under
the 2 s of SC-001 and NFR-09, with little room to spare, and there is no network in it because the data
is in memory.

**First load** (SC-009): unthrottled and with a cached bundle the load event fired at 177 ms. That says
nothing about Fast 4G. The browser pane has no network throttling, so the DevTools Fast 4G and Slow 4G
numbers that feature 002's evidence recorded were not taken; they remain to do on a browser with
DevTools. The bundle growth above is the best available proxy: +28.7 KB gzip is about 0.02 s at the
9 Mbps of Fast 4G.
