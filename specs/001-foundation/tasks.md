---

description: "Task list for the Foundation feature"
---

# Tasks: Foundation

**Input**: Design documents from `/specs/001-foundation/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Included. The plan's success criteria (SC-002 – SC-009) and the constitution's
mechanical guards require them, so test tasks come before the code they cover and MUST fail first.

**Organization**: Grouped by user story. US1 and US2 are the MVP slice; US3, US4 and US5 can
proceed in parallel once Phase 2 is done (US5 needs a runnable app from Phase 1 only).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: US1 shell · US2 look and language · US3 adaptive controls · US4 data and rules ·
  US5 CI and Pages
- Paths are relative to the repository root (single Flutter package, see plan.md)

## Rules for every task

- Tokens only, no raw colours or numeric style literals; direction-aware layout; strings only in
  `lib/l10n/*.arb` (constitution II, V). Settings are read through `SettingsRepository` (III).
- Commit messages and the PR description cite BRD IDs. Branch: `001-foundation`.
- Do not add or remove fonts. Do not edit `docs/design-system/tokens.json` in this feature.

---

## Phase 1: Setup

**Purpose**: A runnable, green-on-CI empty app.

- [X] T001 Create the Flutter project in place at the repository root with `flutter create --org eg.edu.tanta --project-name sprint --platforms=android,ios,web,macos,windows,linux .` keeping `docs/`, `assets/`, `specs/`, `CLAUDE.md` untouched (research R2)
- [X] T002 Add dependencies and declare fonts and assets in `pubspec.yaml`: runtime `flutter_riverpod`, `riverpod_annotation`, `go_router`, `intl`, `flutter_localizations`, `shared_preferences`, `timezone`, `clock`, `freezed_annotation`; dev `build_runner`, `riverpod_generator`, `freezed`, `riverpod_lint`, `flutter_lints`, `mocktail`; fonts Alexandria 600/700, Cairo 400/500/600/700, IBM Plex Mono 400/500 from `assets/fonts/`; `flutter: generate: true` (research R1, tokens.md rule 5)
- [X] T003 [P] Configure `analysis_options.yaml` with `flutter_lints`, the `riverpod_lint` plugin and strict analysis, no excluded `lib/` folders
- [X] T004 [P] Create `l10n.yaml` and starter `lib/l10n/app_ar.arb` (template) and `lib/l10n/app_en.arb` with the app name and four destination names
- [X] T005 [P] Create `.github/workflows/ci.yml` per `contracts/ci.md`: pull requests to `develop` and `main`; pinned Flutter 3.47.9; pub get, build_runner and token drift checks (`git diff --exit-code`), `flutter analyze --fatal-infos`, `flutter test`, `flutter build web --release --base-href /sprint-app/`; job named `build`; permissions `contents: read`
- [X] T006 Replace the generated counter app: minimal `lib/main.dart` (ProviderScope + empty `MaterialApp`) and `test/smoke_test.dart` that pumps it
- [X] T007 Run analyze, test and web build locally and confirm green; commit the generated platform folders; then, with Osman's OK, open the one Draft pull request `001-foundation` → `develop` so CI runs on every push to it

**Checkpoint**: Empty app builds on web and passes the same checks CI runs.

---

## Phase 2: Foundational (blocks every user story)

**Purpose**: Tokens, base theme, window size and app wiring that all stories use.

- [X] T008 Write `tool/gen_tokens.dart` reading `docs/design-system/tokens.json` and emitting `lib/core/tokens/sprint_colors.g.dart`, `sprint_spacing.g.dart`, `sprint_radius.g.dart`, `sprint_size.g.dart`, `sprint_motion.g.dart`, `sprint_text.g.dart` per `contracts/tokens.md` (explicit `height` on every text style; empty shadow list for dark card)
- [X] T009 [P] Write `test/core/tokens/tokens_drift_test.dart`: regenerate in memory and compare to committed files; assert every font weight used is declared in `pubspec.yaml`
- [X] T010 Run the generator and commit the generated token files under `lib/core/tokens/`
- [X] T011 [P] Hand-written token helpers: `lib/core/tokens/context_extensions.dart` (`context.colors`, `context.text`) and `lib/core/tokens/reduced_motion.dart` (fade at `duration-fast` or zero when `MediaQuery.disableAnimationsOf`)
- [X] T012 Build `lib/core/theme/sprint_theme.dart`: light and dark `ThemeData` from `SprintColors`, `ColorScheme` filled from it, text theme from `SprintText`, Cupertino override theme, no shadows in dark (FR-009, FR-011, FR-012); do NOT set `pageTransitionsTheme` so page, sheet and back-gesture timing stay the platform's (FR-018); the Volt lime appears only as a fill paired with its on-colour text (FR-012)
- [X] T013 [P] Write `test/core/window/window_size_test.dart` for the six boundary widths (599, 600, 839, 840, 1199, 1200) then implement `lib/core/window/window_size.dart` (`WindowSize.of(context)` from breakpoint tokens, FR-002)
- [X] T014 [P] `test/core/time/cairo_time_test.dart`: UTC ↔ Cairo conversion including a daylight-saving change day; slot boundaries do not shift by an hour (research R13)
- [X] T015 [P] `lib/core/time/cairo_time.dart` and `lib/core/time/clock_provider.dart` (`timezone` data initialised once, injected `Clock`)
- [X] T016 [P] Implement `lib/core/scroll/sprint_scroll_behavior.dart` (bounce on Apple, stretch on Android, visible scrollbar on web/desktop; `adaptive.md`)
- [X] T017 Wire `lib/app/app.dart` (`MaterialApp.router` placeholder, theme from T012, scroll behaviour, locales from `AppLocalizations`) and point `lib/main.dart` at it

**Checkpoint**: App renders with brand theme in light and dark; ready for stories.

---

## Phase 3: User Story 1 - Branded shell on any device (P1) 🎯 MVP

**Goal**: Arabic RTL shell whose navigation is tab bar, rail or sidebar by window width, keeping
state across resize and fold. (FR-001 – FR-008, SC-001 – SC-003)

**Independent Test**: Run on web and drag the window across 600, 840 and 1200 (quickstart, US1).

### Tests for US1 (write first, must fail)

- [X] T018 [P] [US1] `test/shell/shell_boundaries_test.dart`: at 320 and 1920 and the six boundary widths exactly one navigation form is visible (tab bar / rail / sidebar) and large content is capped at `content-max` (SC-002)
- [X] T019 [P] [US1] `test/shell/shell_state_test.dart`: select My Bookings, enter text and scroll, resize across each boundary; destination, text and scroll offset persist (FR-005, SC-003)
- [X] T020 [P] [US1] `test/shell/hinge_test.dart`: inject a `DisplayFeature` hinge and assert no text or control overlaps it in two-pane layouts (FR-006)
- [X] T021 [P] [US1] `test/shell/routing_test.dart`: `/` redirects to `/home`; unknown path shows not-found with a button to Home; guest on `/bookings` and `/profile` sees the sign-in placeholder without redirect (FR-004, FR-008, `contracts/routes.md`)
- [X] T022 [P] [US1] `test/shell/shell_a11y_test.dart`: every destination has a spoken label, 48dp targets, visible focus on keyboard platforms, labels survive 200% text scale at compact width (FR-017, SC-006)

### Implementation for US1

- [X] T023 [P] [US1] Route name constants and path table in `lib/app/router/routes.dart` (four destinations in order, `/demo`, route list built from data not per role, FR-007)
- [X] T024 [P] [US1] Placeholder screens in `lib/app/shell/placeholders/home_placeholder.dart`, `facilities_placeholder.dart`, `bookings_placeholder.dart`, `profile_placeholder.dart` and `not_found_screen.dart`, all strings from ARB; guest sign-in prompt on bookings and profile
- [X] T025 [P] [US1] Navigation widgets using tokens only: `lib/app/shell/nav/sprint_tab_bar.dart` (`tabbar-height`, blur on Apple), `sprint_nav_rail.dart` (`rail-width`), `sprint_sidebar.dart` (`sidebar-width`, wordmark "سبرنت"), each with semantic labels, hover and `focus-ring` on keyboard platforms
- [X] T026 [US1] `lib/app/shell/adaptive_shell.dart`: pick the nav form from `WindowSize`, keep the `navigationShell` under a `GlobalKey` so form changes re-parent instead of rebuild, centre content up to `content-max` on large (depends on T023 – T025)
- [X] T027 [US1] `lib/core/window/display_feature_layout.dart`: split two-pane content around hinges using `MediaQuery.displayFeatures` and `DisplayFeatureSubScreen`; use it in the shell for medium and larger (FR-006)
- [X] T028 [US1] `lib/app/router/app_router.dart`: `GoRouter` with `StatefulShellRoute.indexedStack` (four branches), `/` redirect, not-found `errorBuilder`, hash URL strategy; provider in `lib/app/router/router_provider.dart`
- [X] T029 [US1] Plug the router and shell into `lib/app/app.dart`; Arabic is the default locale; show the Sprint wordmark text (the SVG logo widget is feature 2)
- [X] T030 [US1] Run T018 – T022 and the quickstart US1 steps on web and macOS; also confirm page transitions are the platform defaults (FR-018); fix until green

**Checkpoint**: US1 works alone and is demonstrable (MVP, part 1).

---

## Phase 4: User Story 2 - Light/Dark and language follow the user (P1)

**Goal**: Persisted theme mode and language, Western digits, EGP and 12-hour formats, RTL/LTR flip,
text scaling and reduced motion. (FR-009 – FR-018, SC-004 – SC-006)

**Independent Test**: Toggle device theme, override in-app, switch language, relaunch (quickstart, US2).

### Tests for US2 (write first, must fail)

- [X] T031 [P] [US2] `test/core/l10n/sprint_format_test.dart`: with locale `ar` price is "120 ج.م", time "5:00 م", digits Western; with `en` "EGP 120" and "5:00 PM"; pin the intl output so an upgrade cannot change digits (research R5)
- [X] T032 [P] [US2] `test/core/theme/appearance_test.dart`: theme mode follows system by default, override persists via fake `SharedPreferences`, storage failure falls back to defaults (FR-010)
- [X] T033 [P] [US2] `test/core/l10n/locale_test.dart`: default `ar`, switching to `en` flips `Directionality`, choice persists
- [X] T034 [P] [US2] `test/guards/arb_parity_test.dart`: every key exists in both ARB files with non-empty text (SC-005)
- [X] T035 [P] [US2] `test/guards/source_scan_test.dart`: scan `lib/` (excluding `lib/core/tokens/` and `lib/core/seed/`) and fail on `Color(0x`, `Colors.` other than `Colors.transparent`, numeric `fontSize:` or `EdgeInsets.all(<number>)`, `Alignment.centerLeft|Right`, `EdgeInsets.only(left:|right:)`, string literals in `Text(`, and `volt` used as a text, icon or border colour (FR-012) (SC-004, SC-005, research R9)
- [X] T036 [P] [US2] `test/shell/text_scale_test.dart`: shell at 200% text scale and compact width shows no overflow; no text style below size 12 (SC-006)
- [X] T037 [P] [US2] `test/core/reduced_motion_test.dart`: with `disableAnimations` the fade helper returns zero or `duration-fast` (FR-018)

### Implementation for US2

- [X] T038 [P] [US2] `lib/core/l10n/sprint_format.dart`: price, 12-hour time, date, number formatting with plain `ar`/`en` locales (never `ar_EG`); Cairo time conversion call-site comes in US4
- [X] T039 [P] [US2] `lib/core/theme/theme_mode_notifier.dart` and `lib/core/l10n/locale_notifier.dart`: Riverpod notifiers persisted with `shared_preferences`, safe defaults on failure (generated code committed)
- [X] T040 [P] [US2] `lib/core/l10n/ltr_isolate.dart`: widget that keeps booking codes, phones and emails left-to-right inside Arabic text (FR-014)
- [X] T041 [US2] Profile placeholder entries for Appearance (system, light, dark) and Language, wired to T039; extend `lib/app/shell/placeholders/profile_placeholder.dart` and ARB files in both languages; add the entry that links to `/demo` here
- [X] T042 [US2] Skeleton primitive `lib/core/motion/skeleton.dart` (opacity pulse at `duration-pulse`, static under reduced motion) and use it for placeholder loading states (FR-018)
- [X] T043 [US2] Mirror only directional icons: `lib/core/l10n/directional_icon.dart` helper used by the nav widgets; audit nav and placeholders for `start`/`end` usage
- [X] T044 [US2] Review every Arabic string in `lib/l10n/app_ar.arb` against the copy rules (light Egyptian dialect, no imperative verbs, buttons as verbal nouns, FR-015) and check the English text matches the meaning; record the review in the PR
- [X] T045 [US2] Run T031 – T037 and the quickstart US2 steps (device theme, override, English, 200% text, reduced motion); fix until green

**Checkpoint**: US1 + US2 = MVP slice complete and reviewable.

---

## Phase 5: User Story 3 - Native-feeling controls (P2)

**Goal**: Five adaptive controls and the demo screen. (FR-019, FR-020, SC-007)

**Independent Test**: Open `/#/demo` on iOS, Android and web and compare with `contracts/adaptive-controls.md`.

### Tests for US3 (write first, must fail)

- [X] T046 [P] [US3] `test/core/adaptive/adaptive_app_bar_test.dart`: with `debugDefaultTargetPlatformOverride` iOS/macOS shows the Cupertino bar (large title when requested, chevron back); Android shows start title and arrow back
- [X] T047 [P] [US3] `test/core/adaptive/adaptive_dialog_test.dart`: Cupertino alert on Apple, Material dialog on Android, centred dialog on web/desktop with Enter confirming and Esc cancelling
- [X] T048 [P] [US3] `test/core/adaptive/adaptive_sheet_test.dart`: action sheet on Apple, bottom sheet on Android, anchored menu on web/desktop, Esc closes where a keyboard exists
- [X] T049 [P] [US3] `test/core/adaptive/adaptive_switch_loader_test.dart`: platform widget types and semantic labels
- [X] T050 [P] [US3] `test/guards/no_platform_checks_test.dart`: no `defaultTargetPlatform`, `Platform.is*` or `TargetPlatform` outside `lib/core/adaptive/` and `lib/core/scroll/` and the theme glue

### Implementation for US3

- [X] T051 [P] [US3] `lib/core/adaptive/adaptive_app_bar.dart`
- [X] T052 [P] [US3] `lib/core/adaptive/adaptive_dialog.dart` (`showSprintDialog`)
- [X] T053 [P] [US3] `lib/core/adaptive/adaptive_sheet.dart` (`showSprintSheet`)
- [X] T054 [P] [US3] `lib/core/adaptive/adaptive_switch.dart`
- [X] T055 [P] [US3] `lib/core/adaptive/adaptive_loader.dart`
- [X] T056 [US3] Demo screen `lib/features/demo/presentation/demo_screen.dart` at `/demo` (outside the shell, linked from Profile): token gallery (colours light/dark, type, spacing, radius), each adaptive control with a trigger, theme and language switchers; strings in ARB
- [X] T057 [US3] Widget test `test/features/demo/token_gallery_test.dart`: the token gallery renders in light, dark, Arabic and English with no overflow (no pixel goldens, research R12)
- [X] T058 [US3] Run T046 – T050 and the quickstart US3 steps on iOS, Android and web; fix until green

**Checkpoint**: US3 demonstrable on its own.

---

## Phase 6: User Story 4 - Realistic data and rules behind repositories (P2)

**Goal**: Domain entities, settings registry with inheritance, rule services, in-memory
repositories on seed data, permission checker, fake payment provider, demo user switcher and
settings inspector. (FR-021 – FR-026, FR-031, SC-008, SC-009)

**Independent Test**: `flutter test test/features` plus the demo-screen checks (quickstart, US4).

### Tests for US4 (write first, must fail)

- [X] T059 [P] [US4] `test/features/settings/settings_resolution_test.dart`: 8 defined/undefined combinations of unit, facility, university resolve closest-first, then default; BRD §4 defaults match the registry (SC-008)
- [X] T060 [P] [US4] `test/features/settings/settings_validation_test.dart`: out-of-range and out-of-scope values rejected with `InvalidSetting` and nothing changes; valid `set` writes an `AuditLog` entry
- [X] T061 [P] [US4] `test/features/booking/availability_service_test.dart`: table-driven cases for hours minus closures, window, lead time, past slots, exclusive vs capacity, free ranges with granularity and max range, trainer sessions with min capacity (BR-05 – BR-09)
- [X] T062 [P] [US4] `test/features/booking/conflict_checker_test.dart`: exclusive double booking, shared over capacity, same-user overlap across facilities, active holds count, max active bookings setting (BR-11 – BR-14, SC-009)
- [X] T063 [P] [US4] `test/features/booking/pricing_service_test.dart`: tier prices, free facility, frozen price and tier, best offer (BR-15 – BR-20)
- [X] T064 [P] [US4] `test/features/booking/cancellation_hold_test.dart`: hold expiry, cancel before/after cutoff, refund percent, admin cancel 100%, invalid state transitions rejected, no penalty on no-show (BR-12, BR-30 – BR-32, BR-37)
- [X] T065 [P] [US4] `test/features/identity/permission_checker_test.dart`: role × scope matrix from BRD §6, guest browse-only, `UNIVERSITY` covers all, `OWNING_UNIT` its facilities, `FACILITY` itself (SC-009)
- [X] T066 [P] [US4] `test/features/identity/destinations_test.dart`: the destination list is computed from role assignments (guest and booker give four, a trainer fixture adds role-specific ones) (FR-007, FR-031)
- [X] T067 [P] [US4] `test/features/booking/booking_repository_test.dart`: two concurrent `create` calls for the last place, exactly one wins; free facility confirms immediately; paid booking confirms only from a provider status (BR-19, BR-28)
- [X] T068 [P] [US4] `test/features/payments/fake_payment_provider_test.dart`: success, forced failure, refund; caller code cannot tell which provider answered (FR-025)

### Implementation for US4

- [X] T069 [P] [US4] Shared types `lib/core/result/result.dart` and `lib/core/result/failure.dart` (the `Failure` cases in `contracts/repositories.md`)
- [X] T070 [P] [US4] Settings: `lib/features/settings/domain/setting_definition.dart`, `setting_registry.dart` (all keys, defaults, allowed scopes, validators from `data-model.md`), `settings_repository.dart` (interface with `resolve`, `set`, `clear`, `watch`); `bookingMode`, `capacity` and `maxParticipants` live here only, never as entity fields
- [X] T071 [P] [US4] Catalogue entities (Freezed) in `lib/features/catalogue/domain/`: `owning_unit.dart`, `facility.dart`, `bookable_unit.dart` (id, facilityId, name, isActive only; mode and capacity come from settings), `operating_hours.dart`, `closure.dart`, `price.dart`, `offer.dart`, `trainer.dart`, `trainer_availability.dart`, `catalogue_repository.dart`
- [X] T072 [P] [US4] Identity entities in `lib/features/identity/domain/`: `user.dart`, `role_assignment.dart`, `verification.dart`, `permission_checker.dart`, `identity_repository.dart`; the current user is `null` for a guest
- [X] T073 [P] [US4] Booking entities and services in `lib/features/booking/domain/`: `booking.dart` (status machine), `availability_service.dart`, `conflict_checker.dart`, `pricing_service.dart`, `hold_policy.dart`, `cancellation_policy.dart`, `booking_repository.dart`, `availability_repository.dart`
- [X] T074 [P] [US4] Payments in `lib/features/payments/domain/`: `payment.dart`, `refund.dart`, `payment_provider.dart`, `payment_repository.dart`
- [X] T075 [P] [US4] Remaining entities and interfaces: `lib/features/attendance/domain/`, `lib/features/notifications/domain/`, `lib/features/assets/domain/` (asset and damage report), `lib/features/audit/domain/`
- [X] T076 [US4] Seed data in `lib/core/seed/` (`seed_units.dart`, `seed_facilities.dart`, `seed_users.dart`, `seed_bookings.dart`, `seed_misc.dart`) per the data-model seed table: Arabic names, EGP prices in both tiers, 12-hour-friendly hours, all statuses and roles (FR-022)
- [X] T077 [US4] In-memory implementations in each feature's `data/` folder for every repository in T070 – T075, with a serialised write section for atomic booking creation, all reading settings only through `SettingsRepository`; `FakePaymentProvider` in `lib/features/payments/data/fake_payment_provider.dart`; the launch state has no current user (guest)
- [X] T078 [US4] Riverpod providers wiring interfaces to the in-memory implementations in `lib/core/providers/data_providers.dart` (single place to swap for a real backend, FR-026)
- [X] T079 [US4] Role-driven navigation: compute shell destinations from the current user's role assignments in `lib/app/router/destinations_provider.dart`; guest and booker give the four destinations, a trainer fixture gives extra destinations in the test only (FR-007, FR-031)
- [X] T080 [US4] Demo screen additions in `lib/features/demo/presentation/`: reviewer-only user switcher (`demo_user_switcher.dart`, FR-031, easy to hide in release; switching changes the Profile placeholder between the guest sign-in prompt and the user's name, role and tier) and read-only settings inspector (`settings_inspector.dart`: for a chosen unit, each setting's value and the level it comes from, FR-020)
- [X] T081 [US4] Run T014 and T059 – T068 and the quickstart US4 steps; fix until green

**Checkpoint**: US4 works without any screen except the demo.

---

## Phase 7: User Story 5 - Every push to `develop` publishes the web build (P3)

**Goal**: Merge into `develop` checks and deploys to GitHub Pages; failures do not publish.
(FR-027 – FR-029, SC-010)

**Independent Test**: Merge a trivial change into `develop`, open the Pages link, repeat with a failing change.

- [X] T082 [US5] Create `.github/workflows/deploy.yml` per `contracts/ci.md`: trigger on push to `develop`; `build` job reuses the CI steps and uploads `build/web` with `actions/upload-pages-artifact`; `deploy` job (needs `build`, environment `github-pages`, `pages: write`, `id-token: write`) uses `actions/deploy-pages`
- [X] T083 [US5] Ask Osman before changing repository settings, then set the Pages source to "GitHub Actions" with `gh api` (outward-facing; record the result in the PR)
- [X] T084 [US5] After the first green run on the PR, ask Osman, then add the `build` check as a required status check on `develop` and `main`, keeping PR-required and no-force-push rules

**Checkpoint**: Pages link live and gated by CI.

---

## Phase 8: Polish and cross-cutting

- [X] T085 [P] Update `CLAUDE.md` "Current state" (the repo now has code; Foundation done) and add a dated row in `docs/decisions.md` for the application ID `eg.edu.tanta.sprint` (once Osman confirms it) and for hash URLs on Pages
- [X] T086 [P] Add `README.md` at the root: what Sprint is, prerequisites, how to run, test and build (from `quickstart.md`)
- [X] T087 Walk the whole `quickstart.md` manual table on web, macOS, one Android phone, one tablet (iPad or Android tablet), a foldable emulator for the hinge checks, and one iOS phone; tick SC-001 – SC-011 with evidence in the PR description (Windows and Linux are not run in this feature)
- [X] T088 Measure SC-011: web build size from the CI log and first-interactive on throttled 4G in Chrome DevTools; if over 3 s apply the Plex Mono deferral from research R10 and record numbers; also measure cold start of the installed Android and iOS builds against the 2 s target of SC-011
- [X] T089 Final sweep: `flutter analyze --fatal-infos`, `flutter test`, `flutter build web --release --base-href /sprint-app/`; check that no `TODO` without an owner remains and that the demo-only switcher is clearly marked
- [X] T090 Mark the single pull request `001-foundation` → `develop` (opened as a Draft after T008) ready for review, with BRD IDs in the description and the SC evidence; after T090 the whole feature is one PR

---

## Dependencies and execution order

- **Phase 1 → Phase 2 → stories.** US1 and US2 first (MVP slice). US3 needs the theme and tokens only. US4 needs Phase 1–2 and the shell only for T079/T080. US5 needs Phase 1 only for T082 but should land last so the Pages build already shows the shell.
- Within a story: tests, then entities and services, then wiring, then the run-and-fix task.
- US2's Profile entries (T041) depend on US1's Profile placeholder (T024). US4's T079 depends on US1's router (T028). T056 (demo screen) precedes T080.
- Generated code (`*.g.dart`, `*.freezed.dart`, l10n) is committed; re-run `dart run build_runner build --delete-conflicting-outputs` after changing annotated files.

## Parallel examples

- After T017: T018 – T022 (US1 tests) together; T023, T024, T025 together.
- After T017: US3 tests T046 – T050 and US4 tests T059 – T068 can be written by different people at the same time.
- US4 domain tasks T070 – T075 touch different features and run in parallel; T076 – T078 follow.

## Implementation strategy

1. **MVP**: Phases 1 – 4 (T001 – T045). Stop and review on web: shell, theme, language.
2. **Increment**: US3 (demo of native controls), then US4 (data and rules), reviewing each at its checkpoint.
3. **Ship**: US5 and Polish, then one PR into `develop` (constitution: one branch, one PR per feature).
4. Two steps need Osman's approval before running: T083 and T084 (repository settings), plus opening the Draft PR at the end of T008. The live-site verification (T091) runs after the merge.

---

## Phase 9: After the merge into `develop`

**Purpose**: Checks that only a merge can trigger, because `deploy.yml` runs on push to `develop`.

- [X] T091 [US5] Verify FR-029: open a deep link (`/#/facilities`) and refresh on the published site under `/sprint-app/`; verify a deliberately failing branch does not replace the live build (SC-010) and record the evidence. Done 2026-11-11: deep link verified live; the failing-build half is shown by the workflow structure, not by a live failing deploy (see `evidence.md`)

**Checkpoint**: SC-010 and FR-029 are closed with evidence; add the result to `docs/decisions.md` only if something changed.

---

## Phase 10: Hardening after the first implementation (added 2026-11-11)

**Purpose**: Close the gaps found when checking the build against the spec, so the code and the
contracts agree and the next features (and OpenCode) start from a clean reference.

- [X] T092 [US2] Generic fallback fonts from `tokens.json` in every generated text style, so a failed font load keeps the same line height; test in `test/shell/text_scale_test.dart` (spec edge case: fonts fail to load)
- [X] T093 [US2] Close an open dialog, sheet or menu when the language changes (`lib/app/app.dart`); tests in `test/core/l10n/locale_overlay_test.dart` (spec edge case: language changes while a dialog is open)
- [X] T094 [US3] Keyboard `focus-ring` on filled, outlined and text buttons, text fields and the Material switch in `SprintTheme`; test in `test/core/theme/focus_ring_theme_test.dart` (FR-017)
- [X] T095 [US3] Screen-reader phrase for each colour swatch in the token gallery (`demoSwatchLabel`); test in `test/features/demo/token_gallery_test.dart` (FR-017)
- [X] T096 [US1] Hinge tests for a tabletop posture, left-to-right, and folding and unfolding while typing (text and focus kept) in `test/shell/hinge_test.dart` (FR-005, FR-006)
- [X] T097 Update `contracts/` (adaptive controls, repositories, routes, tokens, ci), `data-model.md` ("As built"), `plan.md` and `quickstart.md` to match the code
- [X] T098 Decisions with Osman, 2026-11-11: Apple navigation bar keeps native 44pt (recorded in CLAUDE.md and constitution v1.1.0); CanvasKit stays on the Google CDN; SC-011 is measured first; `reminderLeadMinutes` default moved to 180 (BR-40). All in `docs/decisions.md`
- [ ] T099 Measure SC-011 on the published site with Chrome DevTools "Fast 4G" and "Slow 4G" and record first-interactive time in `specs/001-foundation/evidence.md`; if over 3 s on Fast 4G, defer IBM Plex Mono, then subset the fonts (needs Osman's OK before changing font rules)
