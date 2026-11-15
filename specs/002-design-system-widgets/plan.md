# Implementation Plan: Design System Widgets

**Branch**: `002-design-system-widgets` | **Date**: 2026-11-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-design-system-widgets/spec.md`

## Summary

Build the ten design-system components as presentation-only Flutter widgets in `lib/core/widgets/`:
`SprintButton`, `SprintTextField`, `SlotChip`, `DayStrip`, `FacilityCard`, `StatusBadge`,
`BookingTicket`, `AppNavigation`, `StatTile` and `SprintLogo`, each with the variants, states and
rules of its component README. Platform behaviour (press feedback, haptics, tab-bar surface, keyboard
shortcuts) comes from a few new primitives in `lib/core/adaptive/`, so no widget names a platform.
`AppNavigation` replaces the Foundation's plain tab bar, rail and sidebar and keeps the Foundation's
guarantees. `FacilityCard`, `BookingTicket` and `StatTile` get a loading form built from the existing
`Skeleton`. A component gallery in the demo area shows every state with two reviewer controls (text
size and platform look). One small data change rides along: the `fewLeftThreshold` setting (BRD §4
and the settings registry). Decisions and alternatives are in [research.md](research.md).

## Technical Context

**Language/Version**: Dart 3.13.7 / Flutter 3.47.9 stable (as the Foundation; CI is pinned to it).

**Primary Dependencies**: the Foundation's packages, plus three runtime packages added with
`flutter pub add`: `phosphor_flutter` (icons, R4), `flutter_svg` (logo, R7), `qr` (pure-Dart QR
matrix, painted by our own painter, R5). Dev only: `zxing2` and `image` (decode the rendered QR in a
test, R5). Exact constraints are fixed at implementation.

**Storage**: None. Widgets hold no data. The only persisted state stays the Foundation's (theme mode
and locale).

**Testing**: `flutter_test` widget tests per component (states, semantics, 48 targets, 200% text,
RTL and LTR, Light and Dark, reduced motion, platform look by overriding the target platform), the
Foundation's guard tests (which scan the new files automatically), two new guards (widgets are
presentation-only; the QR round trip), and the Foundation suite run unchanged in behaviour. No pixel
goldens (the Foundation's precedent); the visual check is the gallery against each `preview.html`.

**Target Platform**: as the Foundation: web, macOS, Android, iOS hand-checked; Windows and Linux
scaffolded, not run.

**Project Type**: Mobile + web + desktop app (single Flutter package, no backend).

**Performance Goals**: no new startup cost on the splash path (SC-011 of the Foundation is not
loosened): the gallery and the QR painter are not imported by the app's first route, and the three
packages are tree-shaken. Resizing across a size class does not rebuild the active branch
(Foundation FR-005 still holds through `AppNavigation`).

**Constraints**: tokens only; all strings in ARB; no platform checks outside `lib/core/adaptive/`
(and `scroll/`, `theme/`); widgets import no repository, no settings and no `features/` code;
`volt` only as a fill; 48dp targets; text to 200%; reduced motion honoured.

**Scale/Scope**: 10 widgets, 3 loading forms, 4 adaptive primitives, about 45 new ARB keys, one new
setting, one gallery screen, and the swap of three Foundation navigation widgets.

No "NEEDS CLARIFICATION" remains; see [research.md](research.md) R1 – R18.

## Constitution Check

*GATE: passed before Phase 0 and re-checked after Phase 1.*

| Principle | How this plan complies | Status |
| --- | --- | --- |
| I. Repository is the source of truth | The component READMEs and `tokens.json` stay the source; the one requirement change (`fewLeftThreshold`) lands in `docs/BRD.md` first, in the same PR, as its first commit; component dimensions the READMEs state but `tokens.json` lacks are named constants with a follow-up to promote them (R3) | Pass |
| II. Tokens only | Generated tokens plus `SprintExtras` named constants are the only source of values; the existing source-scan guard covers `lib/core/widgets/` with no change; `volt` appears only as a fill (the guard's volt rule) | Pass, one note in Complexity Tracking |
| III. Settings, not constants | `fewLeftThreshold` is added to the registry with its default in one place; widgets receive threshold, window days, cut-off and cancel-until as inputs (a guard forbids widgets importing settings); the gallery reads settings through the repository (FR-066) | Pass |
| IV. Repository boundaries | Widgets import no repository or `features/` code (a guard checks it); the shell and the gallery are the only places that read data and map it to plain widget values | Pass |
| V. Arabic first, adaptive, accessible | ARB parity guard covers the new keys; `EdgeInsetsDirectional` only; per-widget tests at 200% text and for 48 targets; platform behaviour only through `lib/core/adaptive/`; Apple 44pt exception stays limited to the title bar | Pass |
| Product constraints | Cairo only through the token text styles; no SMS, AI or cash; Cairo time through `SprintFormat` and `CairoTime`; Lottie not touched | Pass |
| Workflow | Spec Kit order followed; Out of scope present; one branch, one PR; BRD change cited | Pass |

Post-design re-check (after data-model, contracts, quickstart): no new violation. The deviations
worth reading are in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/002-design-system-widgets/
├── plan.md              # This file
├── research.md          # Phase 0: decisions and alternatives (R1 – R18)
├── data-model.md        # Phase 1: presentation value types, state rules, the new setting
├── quickstart.md        # Phase 1: how to run and validate, story by story
├── contracts/
│   ├── widgets.md       # Public API, states, semantics and copy of the ten widgets
│   └── adaptive-additions.md  # The four new adaptive primitives and the guard rules
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks, not created here)
```

### Source Code (repository root)

```text
pubspec.yaml                                # + phosphor_flutter, flutter_svg, qr; dev: zxing2, image
                                            #   + assets: docs/design-system/logo/ (the three SVGs, no copy)
docs/BRD.md                                 # §4.2: fewLeftThreshold (first commit of the PR)
lib/
├── core/
│   ├── adaptive/
│   │   ├── adaptive_traits.dart            # NEW: semantic booleans per style (R2)
│   │   ├── adaptive_pressable.dart         # NEW: press feedback, hover, focus ring (R2)
│   │   ├── adaptive_haptics.dart           # NEW: light selection haptic, no-op where none (R2)
│   │   └── adaptive_platform_override.dart # NEW: demo-only platform look, lives here for the guard (R16)
│   ├── tokens/sprint_extras.dart           # + component dimensions the READMEs state (R3)
│   ├── l10n/sprint_format.dart             # + timeRange, dayName, count cap helpers
│   └── widgets/
│       ├── option_group.dart               # existing
│       ├── design_system.dart              # barrel export
│       ├── sprint_button/                  # sprint_button.dart
│       ├── sprint_text_field/              # sprint_text_field.dart
│       ├── slot_chip/                      # slot_chip.dart, slot_state.dart
│       ├── day_strip/                      # day_strip.dart, day_strip_day.dart
│       ├── status_badge/                   # status_badge.dart, sprint_status.dart
│       ├── facility_card/                  # facility_card.dart, facility_card_data.dart
│       ├── booking_ticket/                 # booking_ticket.dart, qr_painter.dart
│       ├── app_navigation/                 # app_navigation.dart, nav_destination.dart,
│       │                                   #   sprint_tab_bar.dart, sprint_nav_rail.dart,
│       │                                   #   sprint_sidebar.dart (moved from lib/app/shell/nav/)
│       ├── stat_tile/                      # stat_tile.dart, stat_delta.dart
│       └── sprint_logo/                    # sprint_logo.dart
├── features/
│   ├── settings/domain/setting_registry.dart   # + fewLeftThreshold (BR from §4.2)
│   └── demo/presentation/component_gallery/    # NEW: gallery screen + one section file per component
├── app/
│   ├── router/                             # + /demo/components route (gated like /demo tools)
│   └── shell/adaptive_shell.dart           # uses AppNavigation; maps ShellDestination → NavDestination
└── l10n/app_ar.arb, app_en.arb             # + keys listed in contracts/widgets.md
test/
├── core/widgets/        # one test file per widget
├── core/adaptive/       # traits, pressable, haptics, override
├── guards/              # + widgets_presentation_only_test.dart
├── shell/               # existing tests, import paths updated only (R6)
└── features/demo/       # gallery smoke test, platform override, text scale control
```

**Structure Decision**: widgets are shared design-system code, so they live under `lib/core/widgets/`
next to `option_group.dart`, one folder per component, not inside any feature (every later feature
imports them). `core/` must not depend on `app/` or `features/`, so `AppNavigation` takes its own
plain `NavDestination`; the shell maps the Foundation's `ShellDestination` onto it (R6). The gallery
is demo code, so it lives in `features/demo/` and is the only new place that reads settings and seed
data.

## Complexity Tracking

| Deviation | Why needed | Simpler alternative rejected because |
| --- | --- | --- |
| Component dimensions (chip 56 × 100, day pill 64, badge 28, ticket 340, photo 112, QR margin 12, QR notch size) are named constants in `SprintExtras`, not entries in `tokens.json` | The READMEs state them but `tokens.json` does not carry them, and Principle II says no magic numbers; the Foundation already uses `SprintExtras` for exactly this (R3) | Adding them to `tokens.json` now changes the token contract, Figma Variables and the generator in a feature that is about widgets; it is queued as a follow-up docs-first change instead |
| Three Foundation widgets (`SprintTabBar`, `SprintNavRail`, `SprintSidebar`) move to `lib/core/widgets/app_navigation/` with their class names kept, and the Foundation navigation tests get import-path edits | The spec requires the Foundation suite to pass with its assertions unchanged (SC-006); keeping the class names means only imports change (R6) | Renaming the classes forces every Foundation navigation assertion to change, which would hide a real regression behind an edit |
| `BRD.md` is edited by this feature | `fewLeftThreshold` is a new setting and Principle I says requirements change in the repository first (clarify, 2026-11-15) | Leaving it out of the BRD would put a setting in code that no document names |
