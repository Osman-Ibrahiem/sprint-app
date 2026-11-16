# Implementation Plan: Facility Catalogue and Details

**Branch**: `004-facility-catalogue` | **Date**: 2026-11-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/004-facility-catalogue/spec.md`

## Summary

Replace the Foundation's `home` and `facilities` placeholders with the real catalogue screens and add
the facility details screen: a discovery **home** (guest: facility types and featured facilities;
signed-in: upcoming confirmed bookings first, then four explainable suggestions), a **facility list**
with type / owning-unit / free-or-paid filters and a master-detail layout from the medium size class
up, and a **facility details** page (photos or placeholder, hours with per-unit differences, closures,
both price tiers per unit group, trainers, units, availability summary for today, and an enabled
"عرض المواعيد" action that opens a "قريبًا" screen). A **share link** (`/facilities/<id>`) opens the
same page on the web and in the app. Everything is read-only, goes through the existing catalogue,
availability, booking, identity and settings interfaces, and is composed from the 002 widgets
(`FacilityCard`, `StatusBadge`, skeletons). New rules are pure domain services (today's availability
summary, suggestion rule, price grouping, hours view, link building). Decisions and alternatives are in
[research.md](research.md).

## Technical Context

**Language/Version**: Dart 3.13.7 / Flutter 3.47.9 stable (as the Foundation; CI is pinned to it).

**Primary Dependencies**: the Foundation's packages (Riverpod codegen, Freezed, GoRouter, Phosphor,
the 002 widgets). One new runtime package, `share_plus`, for the platform share sheet (R7); copy-link
uses Flutter's built-in clipboard. Exact constraint is fixed at implementation with `flutter pub add`.

**Storage**: None. Reads go through the existing repository interfaces on seed data. The only state
this feature keeps is in-memory and survives navigation, not restarts: the facility filter and the
list scroll offset (R5).

**Testing**: `flutter_test`: unit tests for each new pure rule; widget tests for home, list, details
and the share/not-found/coming-soon screens (states, filters, master-detail at each size class,
semantics, 48dp targets, 200% text, RTL and LTR, light and dark, reduced motion); a router test for the
new routes; the Foundation's guard tests (tokens, direction, strings, ARB parity, no platform checks,
fonts) run over the new files unchanged. No pixel goldens (the Foundation's precedent); the visual
check is the running app against the component previews.

**Target Platform**: as the Foundation: web, macOS, Android, iOS hand-checked; Windows and Linux
scaffolded, not run.

**Project Type**: Mobile + web + desktop app (single Flutter package, no backend).

**Performance Goals**: home, list and details are usable within the Foundation's recorded web load
budget (NFR-01, SC-009); filter changes show results in under 1 second on seed data (SC-002); the
list builds cards lazily so a long list never builds off-screen cards.

**Constraints**: tokens only; all strings in ARB with a `catalogue` key prefix; no hard-coded setting
values; screens import only repository interfaces through providers, never `in_memory_*` classes; no
platform checks outside `lib/core/adaptive/`; `volt` only as a fill; 48dp targets; text to 200%;
reduced motion honoured; no edit to `CLAUDE.md`; changes to shared files (router, ARB, seed, pubspec)
are additive only, to keep the merge with feature 003 clean (R9).

**Scale/Scope**: 3 screens plus 2 small ones (not-found facility, coming-soon), about 8 new pure
domain classes, one providers file, about 70 new ARB keys (Arabic and English), 1 new seed file, 1 new
package, 2 new routes under the facilities branch.

No "NEEDS CLARIFICATION" remains; see [research.md](research.md) R1 – R10.

## Constitution Check

*GATE: passed before Phase 0 and re-checked after Phase 1.*

| Principle / rule | How this plan complies |
| --- | --- |
| I. Repo is the source of truth; cite BRD IDs | The spec cites FR-CAT-01 – 04, US-01, US-11, BR-05, BR-09, BR-10, BR-15 – 17, BR-19, BR-45. No requirement, token or component changes; nothing needs a docs PR. Decisions that need recording in `docs/decisions.md`: none (all are feature-level, in research.md). |
| II. Tokens only | Screens use `SprintColors`, `SprintSpacing`, `SprintRadius`, `SprintSize`, `SprintMotion` and the text styles; the existing guard scans the new files. No new token. |
| III. Settings, not constants | Booking window days, few-left threshold, free-range max hours, session minutes and booking mode are resolved through `SettingsRepository` per facility / unit and passed into pure services. The suggestion cap (4) and featured count are display choices of this feature, not BRD settings, and are named constants in one place (R4). |
| IV. Every data source behind a repository | Providers read `CatalogueRepository`, `AvailabilityRepository`, `BookingRepository`, `IdentityRepository`, `SettingsRepository` only. No screen touches `InMemoryDataLayer`. The new rules are pure and take plain values. |
| V. Arabic first, adaptive, accessible | RTL via directional spacing, `WindowSize` classes and `DisplayFeatureLayout` for the master-detail pane, Arabic semantics labels, Western digits, 12-hour Cairo time, 48dp targets, 200% text, reduced motion, skeletons not spinners. |
| Out-of-scope section | Present in the spec (backend, real payments, SMS, slot browsing and booking, auth, offers, maps, native app links, P2). |
| Workflow | Specify → clarify → plan done in order; one branch and one PR; no history rewrite; commit messages cite BRD IDs. |

**Post-design re-check**: no violation. One tension is recorded and resolved: FR-029 asked for a seed
facility with several photos, but no real images exist and stock images are forbidden; the carousel is
tested with injected images and FR-029 is amended (R6).

## Project Structure

### Documentation (this feature)

```text
specs/004-facility-catalogue/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1 – R10
├── data-model.md        # Phase 1: view models and pure rules
├── quickstart.md        # Phase 1: how to run and check the feature
├── contracts/
│   ├── routes.md        # new routes and navigation rules
│   └── providers.md     # provider and pure-service contracts
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks, not created here)
```

### Source Code (repository root)

```text
lib/
├── app/
│   └── router/
│       ├── routes.dart              # + AppPaths/AppRouteNames for details and coming-soon;
│       │                            #   ShellDestination gains `subRoutes`; home and facilities
│       │                            #   builders point at the new screens (additive edits)
│       └── app_router.dart          # + passes d.subRoutes into the branch GoRoute
├── core/
│   └── seed/
│       └── seed_catalogue_extras.dart   # NEW: extra cases only (R6); wired in by one line
└── features/catalogue/
    ├── domain/                      # NEW pure files beside the existing entities
    │   ├── facility_filter.dart         # type / owningUnitId / free? (Freezed)
    │   ├── today_availability.dart      # slots -> level + count (BR-45), pure
    │   ├── suggestion_rule.dart         # up to 4 suggestions + reason, pure (FR-004)
    │   ├── price_groups.dart            # units + prices + modes -> price rows (BR-15, BR-16)
    │   ├── hours_view.dart              # weekly hours + per-unit differences + closed today (FR-015, FR-021)
    │   └── facility_link.dart           # build and parse /facilities/<id> (FR-024, FR-025)
    └── presentation/
        ├── providers/
        │   ├── catalogue_providers.dart     # filter, list, details, home, scroll offset (+ .g.dart)
        │   └── share_provider.dart          # share action seam, overridable in tests
        ├── home/
        │   ├── home_screen.dart
        │   ├── upcoming_bookings_section.dart
        │   └── suggestions_section.dart
        ├── facilities/
        │   ├── facilities_screen.dart       # list, filters, master-detail layout
        │   ├── facility_filter_bar.dart
        │   ├── facility_list_view.dart
        │   └── facility_not_found.dart      # friendly not-found (FR-026)
        ├── details/
        │   ├── facility_details_view.dart   # the page body, used full-screen and in the pane
        │   ├── photo_carousel.dart
        │   ├── hours_section.dart
        │   ├── price_section.dart
        │   ├── trainers_section.dart
        │   ├── units_section.dart
        │   ├── availability_section.dart
        │   └── schedule_coming_soon_screen.dart
        └── widgets/
            └── section_card.dart            # shared titled section container

lib/l10n/app_ar.arb, app_en.arb      # + ~70 keys, all prefixed `catalogue`

test/features/catalogue/
├── domain/                          # one test file per new pure rule
└── presentation/                    # home, facilities, details, router, semantics tests
test/guards/                         # unchanged; scans the new files
```

**Structure Decision**: feature-first Clean Architecture inside the existing `lib/features/catalogue/`
(`domain` already exists; this adds `presentation`). Pure rules live in `domain/` and never import
Flutter, Riverpod or a repository. Providers glue repositories to rules. The 002 widgets are used as
they are; nothing is added to `lib/core/widgets/` because the new pieces need `features/` data and the
presentation-only guard forbids that there. Shared-file edits are limited to `routes.dart`,
`app_router.dart`, the two ARB files, one seed wire-in line and `pubspec.yaml`, all additive.

## Complexity Tracking

No constitution violations to justify. Two costs are accepted on purpose: a new package (`share_plus`)
for a real native share sheet, and a small seed file for the cases the Foundation's seed lacks.
