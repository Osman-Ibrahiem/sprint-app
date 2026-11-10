# Implementation Plan: Foundation

**Branch**: `001-foundation` | **Date**: 2026-11-10 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-foundation/spec.md`

## Summary

Build the base every later feature stands on: a Flutter app on all six targets with a branded,
RTL-first, light/dark shell whose navigation reshapes by window width (tab bar, rail, sidebar)
without losing state; design tokens generated from `tokens.json` into Dart; five platform-adaptive
controls; and an in-memory data layer (seed data, settings with inheritance, and pure-Dart rule
services for availability, conflicts, pricing, cancellation and permissions) behind repository
interfaces. CI checks every pull request (analysis, tests, web build) and publishes `develop` to
GitHub Pages. Approach and package choices are in [research.md](research.md).

## Technical Context

**Language/Version**: Dart 3.13.7 / Flutter 3.47.9 stable (pinned in CI to the same version)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`,
`freezed` + `freezed_annotation`, `go_router`, `intl` + `flutter_localizations`,
`shared_preferences`, `timezone`, `clock`. Dev: `build_runner`, `flutter_lints`,
`riverpod_lint`, `mocktail`. Exact constraints are fixed at implementation by `flutter pub add`.

**Storage**: In-memory seed data (resets on every start). Only theme mode and locale persist,
through `shared_preferences`.

**Testing**: `flutter_test` (unit and widget tests, no pixel goldens) and `mocktail`. Guard tests
scan source for raw colours, numeric style literals, left/right-specific layout and hard-coded
strings. A manual device checklist covers foldable and native-look checks (see quickstart).

**Target Platform**: Android, iOS (phone and iPad), web, macOS, Windows, Linux. Foldables are
covered by width classes and `MediaQuery.displayFeatures`. Hand-checked in this feature: web,
macOS, one Android and one iOS target. Windows and Linux are scaffolded but not built or run
here (they need their own host machines); they are verified when first needed.

**Project Type**: Mobile + web + desktop app (single Flutter package, no backend).

**Performance Goals**: First screen interactive in 3 s for the web build on 4G and 2 s for
installed builds (SC-011). Shell resize must not drop frames visibly (no rebuild of the active
branch on a size-class change).

**Constraints**: Tokens only; all strings in ARB files; no platform checks in screens; domain
layer has no Flutter imports; no network access at runtime; sandbox/fake payment only.

**Scale/Scope**: 4 shell destinations (placeholders), 1 demo screen, ~21 BRD entities, ~15
settings keys, ~6 facilities / ~15 units / 10 users / ~20 bookings of seed data.

No "NEEDS CLARIFICATION" remains; see [research.md](research.md) R1 – R13.

## Constitution Check

*GATE: passed before Phase 0 and re-checked after Phase 1.*

| Principle | How this plan complies | Status |
| --- | --- | --- |
| I. Repository is the source of truth | Tokens generated from `tokens.json` (R3); a test fails on drift; decisions go to `docs/decisions.md`; the plan changes no requirement | Pass |
| II. Tokens only | Generated token files are the only place raw values exist; guard tests (R9) fail on raw colours or numeric style literals | Pass |
| III. Settings, not constants | `SettingDefinition` registry + inheritance resolver (R8); defaults are defined only in the registry and every consumer reads through `resolve` (checked in review and by repository tests) | Pass |
| IV. Repository boundaries | Pure-Dart domain, repository interfaces, in-memory implementations, rules in domain services; `PaymentProvider` interface with fake implementation | Pass |
| V. Arabic first, adaptive, accessible | `gen-l10n` ar default; directional layout; width classes from tokens; adaptive controls only in `core/adaptive`; 48dp and 200% text tests | Pass |
| Product constraints | Fonts bundled as static weights; no SMS/AI/cash; times in Cairo, stored UTC (R13) | Pass |
| Workflow | Spec Kit order followed; Out of scope section present; one branch/PR; CI per clarified scope | Pass |

Post-design re-check (after data-model, contracts, quickstart): no new violations. Complexity
Tracking is empty.

## Project Structure

### Documentation (this feature)

```text
specs/001-foundation/
├── plan.md              # This file
├── research.md          # Phase 0: decisions and alternatives (R1 – R13)
├── data-model.md        # Phase 1: entities, rules, settings registry, seed data
├── quickstart.md        # Phase 1: how to run and validate
├── contracts/
│   ├── repositories.md  # Repository, rule-service and PaymentProvider interfaces
│   ├── routes.md        # Route map and deep links
│   ├── adaptive-controls.md  # Public API and per-platform behaviour of the five controls
│   ├── tokens.md        # tokens.json → Dart generation contract
│   └── ci.md            # Workflow triggers, checks, permissions
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks, not created here)
```

### Source Code (repository root)

```text
pubspec.yaml
analysis_options.yaml
l10n.yaml
build.yaml                         # only if build_runner needs options
tool/
└── gen_tokens.dart                # tokens.json -> lib/core/tokens/*.g.dart
android/  ios/  web/  macos/  windows/  linux/      # created by flutter create
assets/
└── fonts/                         # already in repo
.github/workflows/
├── ci.yml                         # pull requests
└── deploy.yml                     # push to develop -> GitHub Pages
lib/
├── main.dart
├── app/
│   ├── app.dart                   # MaterialApp.router, theme, locale, scroll behaviour
│   ├── router/                    # GoRouter, StatefulShellRoute, route names
│   └── shell/                     # AdaptiveShell, tab bar / rail / sidebar, placeholders
├── core/
│   ├── tokens/                    # *.g.dart generated + sprint_text.dart, context extensions
│   ├── theme/                     # ThemeData from SprintColors, theme mode notifier
│   ├── l10n/                      # SprintFormat (digits, price, time, date), locale notifier
│   ├── window/                    # WindowSize, hinge / display-feature helpers
│   ├── motion/                    # SprintMotion, reduced-motion helper, skeleton primitive
│   ├── adaptive/                  # AdaptiveAppBar, AdaptiveDialog, AdaptiveSheet,
│   │                              #   AdaptiveSwitch, AdaptiveLoader
│   ├── time/                      # CairoTime, Clock provider
│   └── seed/                      # seed data (Arabic names, EGP prices)
├── features/
│   ├── settings/                  # SettingDefinition registry, SettingsRepository (+ resolve)
│   ├── identity/                  # User, RoleAssignment, Verification, PermissionChecker
│   ├── catalogue/                 # OwningUnit, Facility, BookableUnit, hours, closures,
│   │                              #   prices, trainers, offers
│   ├── booking/                   # Booking, AvailabilityService, ConflictChecker,
│   │                              #   PricingService, HoldPolicy, CancellationPolicy
│   ├── payments/                  # PaymentProvider, Payment, Refund, FakePaymentProvider
│   ├── attendance/  notifications/  assets/  audit/   # entities + in-memory repos
│   └── demo/                      # demo screen: tokens gallery, adaptive controls,
│                                  #   theme/language/user switchers
│   (each feature: domain/  data/  presentation/ as needed)
└── l10n/
    ├── app_ar.arb  (template)
    └── app_en.arb
test/
├── core/            # tokens drift, formatters, window size, time, adaptive controls
├── features/        # rule services (table-driven), settings, permissions, repositories
├── shell/           # six boundary widths, state kept on resize, a11y, text scale
├── guards/          # raw-value scan, RTL scan, ARB parity
```

**Structure Decision**: A single Flutter package at the repository root, feature-first with
domain/data/presentation inside each feature, plus a shared `core/`. The five adaptive controls,
tokens, window sizes and time live in `core/` because every feature uses them. Rule services sit
in the `domain/` of the feature that owns the data, with no Flutter imports, so the backend can
later mirror them. Placeholders for My Bookings and Profile live under `app/shell/` until their
own features arrive.

## Complexity Tracking

No constitution violations. Nothing to justify.

## Planned order of work (input to /speckit-tasks)

1. Project skeleton: `flutter create`, pubspec (fonts, assets, l10n), analysis options, CI
   scaffolding that is green on an empty app.
2. Token generator, generated files, theme, theme and locale notifiers, `SprintFormat`.
3. `WindowSize`, router with the four branches, `AdaptiveShell` with the three navigation
   forms, hinge handling, placeholders, not-found screen.
4. Adaptive controls and the demo screen.
5. Domain entities, settings registry, rule services, in-memory repositories, seed data,
   `PaymentProvider` fake, permission checker.
6. Guard tests, accessibility and boundary tests.
7. Pages deploy workflow, one-time Pages setting, required status checks on the protected
   branches.

User stories map: US1 → 3, US2 → 2 (+ 3 for direction), US3 → 4, US4 → 5, US5 → 1 and 7.
Stories 1 and 2 are the MVP slice; 3, 4 and 5 can proceed in parallel after step 3.
