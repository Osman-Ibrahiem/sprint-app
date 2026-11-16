# Evidence: Facility Catalogue and Details

Recorded checks for feature 004 (`004-facility-catalogue`). Each section notes the date and what was
run, so later regressions are visible.

## Baseline

- **Date**: 2026-11-16
- **Branch**: `004-facility-catalogue`
- `flutter pub get`: OK
- `dart run build_runner build --delete-conflicting-outputs`: OK (no stale generated files)
- `flutter analyze`: OK
- `flutter test`: **694 tests passed**

## Setup and Phase 2 (foundational)

- **Date**: 2026-11-16
- `flutter pub add share_plus` added `share_plus: ^13.3.1` (one line in `pubspec.yaml`); `flutter analyze`
  stayed clean. The platform plugin registrants changed as the package requires.
- New guard `test/guards/catalogue_domain_pure_test.dart`: `lib/features/catalogue/domain/` imports
  nothing from Flutter, Riverpod or `data/`; `presentation/` never imports an in-memory class. Green.
- **Seed extras (T009)**: the lane-6 evening hours broke two Foundation booking tests
  (`booking_repository_test.dart` books `u-pool-6` at 09:00). Per T009/R6 the live seed now carries
  only the upcoming tennis facility closure, and the lane-6 evening hours live in
  `test/features/catalogue/fixtures/catalogue_fixtures.dart` (used by the details tests and the
  fixture seed). No Foundation test was edited for this.
- **Shell tests**: replacing the facilities placeholder with the real screen (and later the home
  placeholder) removed the placeholder's text field and screen type the Foundation's shell tests used
  as a vehicle. Their intent was kept, not weakened:
  - `test/shell/shell_state_test.dart`: scroll offset and destination still survive every resize, now
    over the home page.
  - `test/shell/hinge_test.dart`: the fold test now checks that the open facility and its route
    survive a fold and unfold (there is no text input in the shell any more).
  - `test/core/theme/focus_ring_theme_test.dart`: the Facilities-search widget case was removed; the
    same focus-ring property stays covered by the theme-level test in the same file. The placeholder
    screen it exercised no longer exists.
- `flutter analyze`: clean. `flutter test`: **760 tests passed** at the Phase 2 checkpoint.

## User Story 1 (guest home discovery)

- **Date**: 2026-11-16
- New pure `HomeContent` view model plus `homeContent`: the seeded facility types in enum order, and
  up to six featured summaries sorted by today's availability count then name (T023).
- Home screen: title, guest hint, horizontally scrolling type chips with icons and a selected check,
  a one-to-three column card grid, skeleton cards while loading, `CatalogueErrorView` with retry, and
  the "عرض كل المنشآت" action. A chip sets the filter and opens `/facilities`; a card opens
  `/facilities/<id>` (T024).
- The home destination now builds `HomeScreen`; the placeholder file stays for the Foundation's
  remaining tests (T025).
- `test/shell/hinge_test.dart` now measures each element's **visible** rect (its box cut by every
  ancestor clip) before checking the hinge. A horizontally scrolled row lays its offscreen chips out
  beside the pane, but they are clipped and never painted on the hinge; the check now matches what a
  person sees instead of failing on invisible boxes. No case was removed.
- `test/smoke_test.dart`, `test/core/l10n/locale_test.dart` and `test/core/theme/appearance_test.dart`
  used the old `homeTitle` string as their anchor for "the app shell is on screen". They now anchor on
  `catalogueHomeTitle`, the real home title; the direction, locale and theme assertions are unchanged.
- `flutter analyze`: clean. `flutter test test/shell test/features/catalogue/presentation`:
  **75 tests passed**; the home test file is 6/6. The whole suite is **768 tests passed**.


## US2 to US6 and final gate (T061)

- **Date**: 2026-11-16
- `flutter analyze --fatal-infos`: no issues.
- `flutter test`: **864 tests passed** (all Foundation guards included: tokens, direction, strings,
  ARB parity, fonts, no platform checks, presentation-only, catalogue domain purity).
- `flutter build web --release --base-href /sprint-app/ --dart-define=SPRINT_WEB_BASE=...`: built.
- Matrix test (T056): 4 widths x ar/en x light/dark x text scale 1.0/2.0 over home, list and two
  details pages: no overflow; every pressable at least 48dp (render size, since semantics rects are
  clipped by scroll viewports).
- Found and fixed while testing: a price-row overflow in `FacilityCard` at 200% text, and an
  hours-row overflow in a narrow pane.
- Known issue (fixed later the same day, see "Digits fix" below): `SprintFormat.time/date/localTime` printed
  Arabic-Indic digits under the app's localisation delegates.
- Hinge: the shell splits the window at a hinge and gives each side its own width class, so a facility
  screen may show one pane there; nothing overlaps the hinge (T059).

## T063 web cost and load time (SC-009, NFR-01)

Same method as feature 002: `tool/measure_web_load.mjs` (headless Chrome, 390 x 844, CPU 4x, Fast 4G
9 Mbps / 170 ms, cache disabled), both builds served by `tool/serve_web.mjs` under `/sprint-app/`.
develop is `8d426f1`. The two builds were measured alternately on the same machine on the same day.

| | develop | this branch | change |
| --- | --- | --- | --- |
| `main.dart.js` | 3,620,507 B (gzip 1,046,302 B) | 3,724,915 B (gzip 1,075,702 B) | +104,408 B (gzip +29,400 B) |

First Flutter frame on Fast 4G, 6 runs each, alternating:

| | Runs | Median |
| --- | --- | --- |
| develop, home | 4.87, 4.87, 4.88, 4.80, 4.89, 5.01 s | 4.88 s |
| this branch, home | 5.04, 5.15, 5.07, 5.20, 5.18, 5.13 s | 5.14 s |

Per route on this branch (3 runs each): home 5.15 / 5.09 / 5.22 s, list 5.22 / 5.58 / 5.64 s, details
5.08 / 5.10 / 5.09 s. First paint (the HTML splash) stays about 0.27 to 0.32 s on every route.

**Result.** The feature adds about 0.26 s on Fast 4G (about 5%) and 29 KB gzip to the bundle. The
absolute number is **not** under the Foundation's 5 s target today: develop itself measured 4.88 s on
this machine, against 3.67 s when 002 was measured on 2026-11-15, so the machine or the CDN is slower
today. The absolute check against SC-011 needs re-running on the 2026-11-15 setup or on a faster
machine; the relative cost is what this pass shows. Limits: headless Chrome with emulated throttling,
CanvasKit from the CDN, first Flutter frame standing in for "interactive".

### Filter change (SC-002)

In the browser pane at 800 x 600 on the release build: a click on the "مجاني" chip with the swimming
filter on, then a screenshot showing the new state (the empty state, the two active chips and the
"مفيش منشآت مطابقة" text), took 51 ms for the click and the screenshot together. This bounds the
change well under the 1 s limit. It is a coarse bound, not a frame-accurate measurement.

## T062 manual walk (SC-001 to SC-008, SC-010)

Done on web, release build served at `/sprint-app/`, in the browser pane.

| Scenario | Checked | Result |
| --- | --- | --- |
| 1 Guest discovery | Home signed out, Arabic dark, 800 wide: types, featured facilities with both prices, "متاح النهارده", "أماكن قليلة", no sign-in prompt. Tapped the swimming type: the list opened filtered. | Pass |
| 2 List and filters | Type + free together gives the empty state with both chips and "مسح الفلاتر"; filters stay after opening a facility. | Pass (owning unit filter and the back-with-scroll case not walked) |
| 3 Details | Pool (Arabic, 800 wide), futsal (Arabic, compact: pinned app bar, hours, closure line, prices "للحجز كله", units), free hall (English, wide). "عرض المواعيد" opens "قريبًا" and back returns. | Pass (academy and the pool's lane 6 hours line not walked) |
| 5 Share and links | `/#/facilities/does-not-exist` shows "المنشأة مش موجودة" with a back button; the deep link `/#/facilities/f-pool` opens the details. | Pass (the share action itself not triggered) |
| 6 Sizes, language, theme | Compact 375, medium 800, wide 1280; Arabic and English; dark and light. | Pass |

**Not walked** (covered by widget tests only): scenario 4 (signed-in home with a booking, with none,
and after sign-out); 200% text; reduce-motion; keyboard tab order; the share action and clipboard;
iOS and Android devices or simulators; tablet and foldable hinge layouts.

### Things noticed while walking (not fixed here)

- The type chip "Swimming" shows as selected on the home screen after the list filter was used,
  because the kept filter is shared. Home is for discovery, so a pre-selected type there may confuse.
  A decision for the spec owner.
- At 800 wide the list and detail panes sit beside the 220 px sidebar, so each pane is about 270 px
  and the filter chips wrap to many rows. Within the medium window class, but tight.
- In English the facility card line mixes an Arabic unit name with "units" and the bidi order looks
  odd ("6 · كلية التربية الرياضية units"). Seed names are Arabic only; not checked on a real device.
- In English the details app bar back arrow could not be confirmed as pointing left at this
  resolution; worth a look on a larger capture.

## Digits fix

- **Date**: 2026-11-16
- Reproduced under `MaterialApp` with the app's own delegates: `SprintFormat.date/time/dateTimeLine`
  gave "الخميس ١٩ نوفمبر" and "٤:٠٠ م" (a plain test that only calls `initializeDateFormatting` hid it).
- Fix in `lib/core/l10n/sprint_format.dart`: every `intl` output goes through one `_western` step that
  maps U+0660 to U+0669 to 0 to 9. New test `test/core/l10n/sprint_format_digits_test.dart` runs every
  method in ar and en under the app delegates.
- `flutter analyze`: clean. `flutter test`: **866 passed**. The closure line on the futsal details
  was the place it showed in the browser; not re-checked in the browser after the fix.

## Review fixes check

- **Date**: 2026-11-16
- Release web build in the browser pane, compact 375 wide, after the review fixes: the closure date
  reads "19" and "20" with Western digits; the home type chips are not pre-selected, and tapping a type
  with "free" on opens the list with only that type; the back chevron points left in English and right
  in Arabic, and the "عرض المواعيد" arrow points left in Arabic.
- Found while checking: Phosphor glyphs set `matchTextDirection`, so `DirectionalIcon` flipped twice in
  RTL (no net flip). `DirectionalIcon` now fixes the icon's own direction, so it is the only place
  that flips. A plain `Icon` of a Phosphor glyph still mirrors itself in RTL, including icons that
  should not mirror (a Foundation-wide point, not changed here).
- `flutter analyze`: clean. `flutter test`: **873 passed**.

## Not done yet

- T062 is partly done (see the table above; the "Not walked" list is what remains).
- T064 waits for feature 003 to merge into `develop` (it has not).
- T065 (open the PR) is left for Osman.
