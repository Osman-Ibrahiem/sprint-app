# Research: Foundation

**Feature**: 001-foundation | **Date**: 2026-11-10 | **Spec**: [spec.md](spec.md)

Every "NEEDS CLARIFICATION" in the plan's Technical Context is resolved here. Package versions
were read from pub.dev on 2026-11-10 and the full set was dry-run resolved together in a
scratch Flutter 3.47.9 project (no conflicts). The resolver still picks the final constraints
with `flutter pub add` at implementation time.

## R1. Toolchain and packages

- **Decision**: Flutter 3.47.9 stable / Dart 3.13.7 (what is installed on the owner's machine).
  Packages: `flutter_riverpod` 3.5 + `riverpod_annotation` 4.0 + `riverpod_generator` 4.0,
  `freezed` 4.0 + `freezed_annotation` 3.1, `go_router` 18.1, `intl` 0.20, `shared_preferences`
  2.5, `timezone` 0.11, `clock` 1.1; dev: `build_runner` 2.17, `flutter_lints` 6.0,
  `riverpod_lint` 3.2, `mocktail` 1.0.
- **Rationale**: CLAUDE.md fixes Riverpod (codegen), Freezed and GoRouter. `timezone` is needed
  because Egypt observes daylight saving time again, so a fixed `+02:00` offset would be wrong
  (NFR-03). `clock` lets tests control "now" for hold, cutoff and window rules.
- **Alternatives**: `intl` date formatting alone (no tz database, rejected). `very_good_analysis`
  (stricter lints; rejected for now, `flutter_lints` plus the custom guard tests in R9 are enough).
  `json_serializable` is NOT added: the in-memory layer has no JSON boundary in this feature.

## R2. Project layout

- **Decision**: One Flutter package at the repository root (`lib/`, `test/`, `assets/`, platform
  folders), created with `flutter create` for android, ios, web, macos, windows and linux. Source
  is feature-first with Clean Architecture layers inside each feature (see plan.md).
  A shared `core/` holds tokens, theme, l10n, window size, motion, adaptive controls, time.
- **Rationale**: `assets/` and `docs/` already live at the root; one package keeps `develop`
  deployment simple. A melos workspace is more structure than a UI-first thesis app needs.
- **Alternatives**: Multi-package workspace (rejected: overhead, no second consumer).
- **Open for Osman**: application ID / bundle ID. Default `eg.edu.tanta.sprint`; it is only
  used by the platform folders and is cheap to change before any store release.

## R3. Design tokens in code

- **Decision**: `docs/design-system/tokens.json` is the source. A committed Dart script
  `tool/gen_tokens.dart` reads it and writes generated files under `lib/core/tokens/`
  (`sprint_colors.g.dart`, `sprint_spacing.g.dart`, `sprint_radius.g.dart`,
  `sprint_size.g.dart`, `sprint_motion.g.dart`, `sprint_text.g.dart`). Hand-written code only
  wraps them (`ThemeExtension` plumbing, `context.colors`). A test regenerates into memory and
  fails if the committed files differ from `tokens.json`.
- **Rationale**: Satisfies "names identical to `tokens.json`" and "the file is the source"
  (handoff.md), and makes SC-004 checkable. Hand-typing ~40 colours twice would drift.
- **Alternatives**: Hand-written constants (drift risk). `build_runner` builder for tokens
  (heavier than a 150-line script; build_runner is already used for Riverpod/Freezed and gets
  slow with more builders).

## R4. Theme, locale and persistence

- **Decision**: `ThemeData` is built from `SprintColors`; `ColorScheme` is filled from it so stock
  widgets inherit brand colours. Theme mode (system / light / dark) and locale (ar / en) are
  Riverpod notifiers persisted with `shared_preferences`; default is system theme and Arabic.
  Reading fails safe: if storage throws, defaults apply.
- **Rationale**: FR-010, FR-013. Only these two values persist across launches; all seed data
  resets (spec Assumptions).
- **Alternatives**: `hive`/`isar` (overkill for two keys).

## R5. Localisation

- **Decision**: Flutter `gen-l10n` with ARB files `lib/l10n/app_ar.arb` (template) and
  `app_en.arb`. Western digits in both languages: formatters pass `NumberFormat` /
  `DateFormat` with the plain `ar` locale, which prints Latin digits. Checked on 2026-11-10 with
  intl 0.20.3: `ar` gives "5:00 م" and "1,234", while `ar_EG` would give Arabic-Indic digits
  ("٥:٠٠ م"), so `ar_EG` MUST NOT be used for formatting. A `SprintFormat` helper owns price ("120 ج.م" / "EGP 120"), 12-hour time
  ("5:00 م" / "5:00 PM"), and date; screens never call `intl` directly.
- **Rationale**: FR-013 – FR-015. One helper is the only place that can get digits or currency
  wrong, and it is unit-testable. An ARB-completeness test fails if a key exists in one language
  only (SC-005).
- **Verified**: the plain `ar` locale prints "م" / "ص" markers as the brief wants. A unit test
  pins the output so a future intl upgrade cannot change digits silently.

## R6. Window size classes, shell and state preservation

- **Decision**: `WindowSize.of(context)` reads `MediaQuery.sizeOf(context).width` and compares
  with the generated breakpoint tokens (600 / 840 / 1200). The router is a single `GoRouter`
  with `StatefulShellRoute.indexedStack`: four branches (Home, Facilities, My Bookings, Profile).
  One `AdaptiveShell` widget builds tab bar, rail or sidebar around the same `navigationShell`.
  The `navigationShell` body is kept under a `GlobalKey` so changing form (resize, fold, unfold)
  re-parents it instead of recreating it, which keeps selected branch, text input and scroll
  positions (FR-005, SC-003). Branch scroll positions are kept by `PageStorageKey` per scroll
  view and by the indexed stack.
- **Rationale**: this is the supported way in go_router to keep per-tab navigation state.
  Navigation form is chosen from width only (FR-002).
- **Foldables**: `DisplayFeatureSubScreen` / `MediaQuery.displayFeatures` splits two-pane
  layouts so nothing sits on a hinge (FR-006). Foldable behaviour cannot be exercised in unit
  tests, so tests inject a fake `MediaQueryData` with a hinge, and a real device check is listed
  in quickstart.
- **Alternatives**: `flutter_adaptive_scaffold` (discontinued by the Flutter team; also would
  impose Material look on iOS, against the design rules). `AutoRoute`/Beamer (not in the fixed
  stack).

## R7. Adaptive controls (platform-native behaviour)

- **Decision**: Five widgets in `core/adaptive/`, each reading `Theme.of(context).platform`:
  - `AdaptiveAppBar`: `CupertinoSliverNavigationBar` (large title on root screens) on iOS and
    macOS; Material-style bar elsewhere; chevron back vs arrow back.
  - `AdaptiveDialog`: `CupertinoAlertDialog` on iOS/macOS; Material `AlertDialog` (radius-xl) on
    Android; centred dialog with Enter and Esc shortcuts on web/desktop.
  - `AdaptiveSheet`: `CupertinoActionSheet` via `showCupertinoModalPopup` on Apple; modal
    bottom sheet on Android; anchored menu on web/desktop; Esc closes where a keyboard exists.
  - `AdaptiveSwitch`: `Switch.adaptive` themed with `primary`.
  - `AdaptiveLoader`: `CircularProgressIndicator.adaptive`.
  Apple vs Android is decided only inside these widgets; screens never branch on platform.
- **Rationale**: FR-019, `adaptive.md`. Widget tests set `debugDefaultTargetPlatformOverride`
  to render each platform and assert the widget type that appears.
- **Alternatives**: `adaptive_dialog` or similar packages (extra dependency for five small
  widgets; the table in `adaptive.md` is specific, so owning the code is simpler).
- **Note**: press feedback, pull-to-refresh, scroll physics and haptics from `adaptive.md` are
  consumed by feature 2 and later; here only the scroll behaviour (bounce / stretch /
  scrollbar) is set globally via a `ScrollBehavior`.

## R8. Data layer, rules and settings

- **Decision**: Pure-Dart `domain/` per feature (entities as Freezed classes, repository
  interfaces, rule services) with no Flutter imports. In-memory `data/` implementations hold
  state in Riverpod-owned objects seeded from `lib/core/seed/`. Rules live in domain services
  so the future backend can mirror them: `AvailabilityService` (slots from hours minus closures,
  window, lead time, capacity), `ConflictChecker` (exclusive double booking, shared capacity,
  same-user overlap, BR-13), `PricingService` (tier, offers, frozen price), `HoldPolicy`,
  `CancellationPolicy` (cutoff, refund percent, admin cancel 100%), `PermissionChecker`
  (role x scope). Settings use a `SettingDefinition` registry (key, type, default, allowed
  scopes, validator) and a `SettingsRepository.resolve(key, {unitId})` that walks
  unit → facility → university → default.
- **Rationale**: FR-021 – FR-026, constitution III and IV. Rules in pure functions are the
  easiest thing to test exhaustively (SC-008, SC-009) and to port to a backend.
- **Concurrency**: the in-memory layer serialises writes (single isolate, synchronous critical
  section) so two "simultaneous" booking attempts in tests cannot both win.
- **BR-40, decided 2026-11-11**: the reminder shows a cancel button only before the cutoff, so
  the reminder default moved from 60 to 180 minutes (cutoff stays 2 h). Recorded in
  `docs/decisions.md` and `docs/BRD.md`.

## R9. Guard tests (SC-004, SC-005)

- **Decision**: Plain `flutter_test` tests that scan `lib/` (excluding `lib/core/tokens/` and
  `lib/core/seed/`) and fail on: `Color(0x`, `Colors.` other than `Colors.transparent`, numeric `fontSize:`
  or `EdgeInsets.all(<number>)` literals, `Alignment.centerLeft/Right` and `EdgeInsets.only(left:|right:)`
  (RTL), and string literals passed to `Text(`. A second test compares ARB keys across
  languages.
- **Rationale**: Cheap, runs in CI, and enforces the constitution's "tokens only" and "all
  strings in l10n" mechanically. A custom analyzer plugin is far more work for the same effect.
- **Alternatives**: `custom_lint` rules (heavier; `riverpod_lint` is still enabled for Riverpod
  mistakes).

## R10. Web build, routing and GitHub Pages

- **Decision**: Hash URL strategy (Flutter's web default). `flutter build web --release
  --base-href /sprint-app/` produces the site; it is published with the official GitHub
  Pages Actions flow (`actions/upload-pages-artifact` + `actions/deploy-pages`), not by pushing
  to a `gh-pages` branch. The repository's Pages source MUST be set to "GitHub Actions" once
  (a repo setting, done with `gh api` after the workflow lands; needs Osman's go-ahead because
  it is an outward-facing change).
- **Rationale**: Hash routing needs no server rewrite, so deep links and refreshes work under
  the sub-path (FR-029) without a `404.html` trick. Share links for facilities (FR-CAT-04) will
  look like `.../sprint-app/#/facilities/123`, acceptable for P1; a custom domain with path
  URLs can come later.
- **Alternatives**: Path URLs + copied `404.html` (works but serves HTTP 404 for deep links);
  `gh-pages` branch (extra branch to protect and manage).
- **Performance (SC-011)**: CanvasKit download plus Arabic fonts is the main cost. Fonts are
  already static-weight subsets of what is needed; the plan only declares weights the tokens use
  (Alexandria 600/700, Cairo 400/500/600/700, IBM Plex Mono 400/500). First paint measured in
  the CI build log (bundle size) and by hand on a throttled 4G profile; if over budget the
  fallback is deferring Plex Mono until a booking code is shown.

## R11. CI

- **Decision**: Two workflows in `.github/workflows/`:
  - `ci.yml` on pull requests to `develop` and `main`: `flutter pub get`, code generation
    (fail if generated files are stale), tokens check, `flutter analyze --fatal-infos`,
    `flutter test`, `flutter build web --release`.
  - `deploy.yml` on push to `develop`: the same three checks, then the Pages deploy job
    (environment `github-pages`, `pages: write`, `id-token: write`) only if they pass.
  Flutter is pinned (via `subosito/flutter-action`, exact version) to the version used locally.
- **Rationale**: FR-027, FR-028, clarified 2026-11-10 (analysis, tests, web build only).
  Android and iOS builds are verified by hand.
- **Branch protection**: after the first green run, add the CI job as a required status check
  on `develop` and `main` (today they require a PR but no checks). Done with `gh api` and Osman's
  approval.
- **Alternatives**: Merge both workflows into one with conditional deploy (harder to read,
  and pull request runs would need access to Pages permissions).

## R12. Testing strategy

- **Decision**: `flutter_test` for unit and widget tests, `mocktail` where a fake is needed.
  Unit tests: settings resolution and validation, each rule service (table-driven), permission
  matrix against BRD §6, formatters, token generator drift, guard tests (R9). Widget tests:
  shell at the six boundary widths (599/600/839/840/1199/1200), state kept across a size change,
  each adaptive control on iOS, Android and web/desktop overrides, 200% text scale on compact,
  Arabic and English direction. A widget test renders the token gallery in light, dark, Arabic and English and asserts no
  overflow. Pixel goldens are NOT used: they only match on the machine that made them (fonts
  render differently on macOS and the Linux CI runner), and the token drift test already catches
  accidental token changes.
- **Rationale**: Covers SC-002 – SC-009. `integration_test` is not used in this feature; a
  manual device checklist in quickstart covers the foldable and the native-look checks that
  automation cannot judge.

## R13. Cairo time

- **Decision**: Domain stores `DateTime` in UTC. `CairoTime` (using `timezone`, zone
  `Africa/Cairo`) converts for display and to compute "today", slot boundaries and the
  booking window. A `Clock` is injected everywhere "now" is needed.
- **Rationale**: NFR-03, and slot generation across a daylight saving change must not shift
  by an hour. Tests cover a day with a DST change.
- **Alternatives**: Local device time (wrong for visitors abroad and for web).
