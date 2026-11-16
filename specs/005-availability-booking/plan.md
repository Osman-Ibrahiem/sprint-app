# Implementation Plan: Availability and Booking

**Branch**: `005-availability-booking` | **Date**: 2026-11-17 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/005-availability-booking/spec.md`

## Summary

Replace feature 004's "قريبًا" screen with the real booking flow, up to the hand-off to payment. The
**schedule** shows the days of the booking window (`DayStrip`), a unit picker, and the selected unit's
slots (`SlotChip`) with their states from the availability repository. Three paths follow from the
facility: **one slot** in a paid facility (`EXCLUSIVE` or `SHARED`), a **range of hours** in a free
facility, and **trainer first, then one grid of that trainer's sessions**. A guest browses freely and
meets feature 003's account gate only on "متابعة", returning to the same selection. The **summary**
shows facility, unit, time, coverage, tier, price and the cancellation policy from a repository
**quote**. A paid booking stops there at a "قريبًا" checkout screen (the Hold and payment are feature
6); a free booking is created as `CONFIRMED` and ends on a simple success screen.

The Foundation already has the slot, conflict, pricing and booking rules and their in-memory
repositories. This plan adds the presentation layer on them, one new repository method (`quote`), a
few pure selection rules, and three corrections to existing rules found while planning (few-left from
the setting, per-hour capacity for ranges, offers not applied until feature 10). The selection lives in
the address, so reload, sign-in, resize and fold keep it. Decisions and alternatives are in
[research.md](research.md).

## Technical Context

**Language/Version**: Dart 3.13.7 / Flutter 3.47.9 stable (as earlier features; CI is pinned to it).

**Primary Dependencies**: the existing packages only (Riverpod codegen, Freezed, GoRouter, Phosphor,
`clock`, the 002 widgets, the 003 account gate). No new package.

**Storage**: none new. Free bookings are written through `BookingRepository.create` and are saved with
the rest of the demo data by the existing snapshot (decisions.md 2026-11-16). The selection is kept in
the route's query parameters, not in storage (R2).

**Testing**: `flutter_test`: unit tests for each pure rule; repository tests for `quote`, per-slot
capacity, the offers switch, the threshold and simultaneous creates; widget tests for the schedule,
summary, success and checkout screens across size classes, directions, themes, 200% text, semantics
and keyboard; a router test; six acceptance tests named after the user stories; the existing guard
tests plus a `booking_domain_pure_test`. No pixel goldens (R14).

**Target Platform**: web, macOS, Android and iOS hand-checked; Windows and Linux scaffolded, not run.

**Project Type**: mobile + web + desktop app (one Flutter package, no backend).

**Performance Goals**: the schedule shows the selected day's slots in under 2 seconds on seed data
(SC-001, NFR-09) from one parallel load of the whole window (R4); selecting a day, unit or slot
responds within one frame because the window is already loaded; conflicting bookings are prevented in
100% of attempts (SC-005).

**Constraints**: tokens only; all strings in ARB with a `booking` prefix; every setting read through
`SettingsRepository`; screens import repository interfaces through providers, never `in_memory_*`;
pure rules import no Flutter, Riverpod or `data/`; no platform checks outside `lib/core/adaptive/`;
no change to the design-system widgets, tokens or the requirement and design documents; `volt` only as the few-left fill; one
primary action per screen; 48dp targets; text to 200%; reduced motion honoured; no Hold, payment or
`PENDING_PAYMENT` booking is created.

**Scale/Scope**: 4 screens (schedule with its trainer step, summary, checkout placeholder, success),
about 9 new pure domain files, 1 providers file, 1 new adaptive primitive, 3 new child routes, about
90 new ARB keys in Arabic and English, 1 new seed file, edits to 9 existing files (R15), and the
removal of feature 004's coming-soon screen.

No "NEEDS CLARIFICATION" remains; see [research.md](research.md) R1 – R15.

## Constitution Check

*GATE: passed before Phase 0 and re-checked after Phase 1.*

| Principle / rule | How this plan complies |
| --- | --- |
| I. Repo is the source of truth; cite BRD IDs | The spec cites FR-AVL-01, FR-AVL-02, FR-BKG-01 – 04, US-01, US-06 – US-09, US-11, US-23 and BR-01 – BR-03, BR-05 – BR-11, BR-13 – BR-19, BR-21, BR-30, BR-31, BR-45. No requirement, token or component document changes. Two project-level decisions are recorded in `docs/decisions.md`: the defense is a recorded video of the working system (clarify, 2026-11-16), and offers are not applied to prices until feature 10 (R7b, confirmed by Osman 2026-11-17). |
| II. Tokens only | Screens use `SprintColors`, `SprintSpacing`, `SprintRadius`, `SprintSize`, `SprintMotion`, `SprintExtras` and the text styles. No new token and no change to `SlotChip`, `DayStrip`, `StatusBadge` or `SprintButton`. `volt` appears only inside `SlotChip`'s few-left state. |
| III. Settings, not constants | All twelve settings in FR-036 come from `SettingsRepository` with inheritance. R5 removes an existing constant: the few-left threshold the availability service used by default. |
| IV. Every data source behind a repository | Providers read the interfaces only. Re-checks go through the new `BookingRepository.quote`, which shares one check with `create`, so the fake enforces what the backend will. The tap-time overlap hint reuses domain methods and never replaces the repository's answer. `PaymentProvider` is not touched. |
| V. Arabic first, adaptive, accessible | RTL via directional layout; size classes and `DisplayFeatureLayout` for the pane; the platform's pull-to-refresh through a new adaptive primitive plus an app-bar action for keyboards; Arabic semantics on every chip, unit and notice; notices as live regions; Western digits, 12-hour Cairo time, "120 ج.م"; 48dp; 200% text; reduced motion; skeletons, not spinners. |
| Product constraints | No payment, no SMS, no AI, no cash. Cairo display, UTC storage. No Lottie yet (feature 11). |
| Out-of-scope section | Present in the spec (backend, real payments, checkout and Hold, ticket, my bookings, SMS, offers, admin and trainer tools, P2). |
| Workflow | Specify → clarify → plan in order; one branch and one PR; no history rewrite; commits cite BRD IDs. |

**Post-design re-check**: no violation. Three points are recorded so the review sees them:

1. **Spec wording vs design (US7 scenario 3)**: on expanded and large windows the selection and its
   main action sit beside the grid; the full summary stays a route (R9). The spec says the summary
   "can" sit beside the grid, so this is within it.
2. **Foundation rules are corrected, not bypassed** (R5, R7a, R7b). Each has its own tests, and each
   is something the backend must also do.
3. **A free facility that requires a trainer** takes the trainer path and confirms without payment
   (R8). It was the one item left open after clarify; the seed has no such facility.

## Project Structure

### Documentation (this feature)

```text
specs/005-availability-booking/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1 – R15
├── data-model.md        # Phase 1: view models, pure rules, changed contracts
├── quickstart.md        # Phase 1: how to run and check the feature
├── contracts/
│   ├── routes.md        # routes, query parameters, navigation behaviour
│   └── providers.md     # repository changes, providers, pure rules, UI contracts, messages
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks, not created here)
```

### Source Code (repository root)

```text
lib/
├── app/router/
│   └── routes.dart                      # schedule builder → booking screens; + summary, checkout,
│                                        #   done child routes (gated); + AppPaths / AppRouteNames
├── core/
│   ├── adaptive/
│   │   └── adaptive_refresh.dart        # NEW: platform pull-to-refresh (R4)
│   ├── result/failure.dart              # + optional fields on seven refusals (R6)
│   ├── data/in_memory_data_layer.dart   # wiring: applyOffers off, threshold resolver
│   └── seed/
│       └── seed_booking_extras.dart     # NEW: few-left slot, trainer at capacity (R12)
├── features/booking/
│   ├── domain/
│   │   ├── booking_repository.dart      # + quote, + changes
│   │   ├── booking_quote.dart           # NEW
│   │   ├── conflict_checker.dart        # per-slot places (R7a)
│   │   ├── booking_path.dart            # NEW
│   │   ├── schedule_selection.dart      # NEW: address state
│   │   ├── facility_schedule.dart       # NEW: view model + ScheduleBuilder
│   │   ├── selection_resolver.dart      # NEW
│   │   ├── slot_selection.dart          # NEW
│   │   ├── range_selection.dart         # NEW
│   │   ├── own_overlap.dart             # NEW
│   │   └── booking_summary_view.dart    # NEW
│   ├── data/
│   │   ├── in_memory_booking_repository.dart      # shared check for quote and create; applyOffers
│   │   └── in_memory_availability_repository.dart # fewLeftThreshold from settings (R5)
│   └── presentation/                    # NEW
│       ├── providers/booking_providers.dart        # (+ .g.dart)
│       ├── schedule/
│       │   ├── schedule_screen.dart         # app bar, layout per size class, refresh
│       │   ├── schedule_day_section.dart    # DayStrip mapping
│       │   ├── unit_picker.dart
│       │   ├── slot_grid.dart
│       │   ├── price_line.dart
│       │   ├── trainer_step.dart            # trainer list and chosen-trainer row
│       │   ├── selection_bar.dart           # bottom bar (compact, medium)
│       │   ├── selection_panel.dart         # side panel (expanded, large)
│       │   └── schedule_notice.dart         # inline notice (live region)
│       ├── summary/
│       │   ├── booking_summary_screen.dart
│       │   ├── summary_rows.dart
│       │   └── cancellation_policy_text.dart
│       ├── checkout/checkout_coming_soon_screen.dart
│       ├── done/booking_done_screen.dart
│       └── widgets/
│           ├── failure_message.dart         # Failure → localised message (one place)
│           └── booking_error_view.dart
└── features/catalogue/presentation/
    ├── facilities/facilities_screen.dart    # + optional paneBuilder (R1)
    └── details/schedule_coming_soon_screen.dart   # DELETED

lib/l10n/app_ar.arb, app_en.arb          # + ~90 keys prefixed `booking`; − 3 coming-soon keys

test/
├── features/booking/
│   ├── domain/                          # one file per new pure rule; conflict_checker additions
│   ├── data/                            # quote, offers switch, threshold, simultaneous creates
│   └── presentation/                    # schedule, summary, done, checkout, router
├── acceptance/                          # us01_slots…, us06…, us07…, us08…, us09…, us11…
└── guards/booking_domain_pure_test.dart # NEW
```

**Structure Decision**: feature-first Clean Architecture inside the existing `lib/features/booking/`,
which already has `domain` and `data`; this adds `presentation`. Pure rules stay in `domain/` and
import nothing from Flutter, Riverpod or `data/`. Providers glue the repositories to the rules, and the
address holds the selection. The booking screens are handed to the catalogue's `FacilitiesScreen`
through a builder from `routes.dart`, so neither feature imports the other's presentation. Nothing is
added to `lib/core/widgets/`; the one new core file is the adaptive refresh primitive.

**Suggested build order** (for `/speckit-tasks`): (1) repository and rule changes with their tests
(`quote`, `changes`, failure details, per-slot capacity, offers switch, threshold, seed); (2) pure
selection rules and the schedule view model; (3) routes and `ScheduleSelection` in the address;
(4) the schedule for the slot path (US1, US2) and the guest gate (US3); (5) summary, checkout
placeholder and tier display (US2, US6); (6) the range path, `create` and the success screen (US4);
(7) the trainer path (US5); (8) adaptive, accessibility and copy passes (US7); (9) acceptance tests
and evidence.

## Complexity Tracking

No constitution violations to justify. Costs accepted on purpose:

| Cost | Why it is needed | Simpler alternative rejected because |
| --- | --- | --- |
| A new interface method, `BookingRepository.quote` | The paid path must re-check availability, conflicts and price without creating a booking or a Hold (BR-12 is feature 6) | Calling `create` would start Holds and leave expired bookings; checking in the screen breaks constitution IV |
| Edits to Foundation rules (R5, R7a, R7b) | Each is a real mismatch with the BRD or the spec, found while planning | Leaving them would show a wrong few-left state, refuse valid ranges, and show prices the schedule never showed |
| The selection in query parameters | Reload, shared links, sign-in return, resize and fold all need the same state (FR-012, FR-022, FR-042) | A provider would lose the selection on reload and could not back a gated summary route |
