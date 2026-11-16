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

