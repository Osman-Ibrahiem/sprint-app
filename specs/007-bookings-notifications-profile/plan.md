# Implementation Plan: My Bookings, Cancellation, Notifications, Account and Search

**Branch**: `007-bookings-notifications-profile` (worktree branch `claude/007-bookings-notifications-profile-7c3ba5`) | **Date**: 2026-11-18 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/007-bookings-notifications-profile/spec.md`, design pack in [design-pack/](design-pack/README.md) (temporary, deleted before merge)

## Summary

Replace `BookingsPlaceholder` and `ProfilePlaceholder` with the real booker experience and add the notifications centre and catalogue search, all on the in-memory repositories.

- **My bookings and details**: a list with "الجاية / السابقة" and a booking details screen for every status; master-detail from the medium window class up (same pattern as the facility list). Home's upcoming rows and "كل حجوزاتي" lead there.
- **Cancellation**: one pure `CancelPreview` (in the cancellation rules) tells the UI which of four cases applies (full, partial, none, free) or why it is closed; the same rule feeds `decide()`. A new transition `PENDING_PAYMENT → CANCELLED` (BR-48) works only while holding. Every self-cancel records a "تم إلغاء حجزك" notification, already read.
- **Notifications**: the repository gains a change signal and `markAllRead`; `Notification.type` becomes a typed `NotificationKind`. A bell (compact) or a destination with badge (medium and up) shows the unread count. A `ReminderScheduler` writes one reminder per confirmed booking when it enters the `reminderLeadMinutes` window; the cancel action inside a reminder is decided at display time.
- **Account**: real account screen, settings rows, language and appearance (sheet or popover), sign out, guest state, and edit profile (name and photo; email and phone locked). `User` gains `avatarId`; `IdentityRepository` gains `updateProfile`.
- **Search**: a pure `FacilitySearch` (Arabic normalisation, ordering by places available today) over the summaries the catalogue already builds; suggestions from a new "most booked" count and device-only recents.

Key decisions asked for in the brief are in [research.md](research.md): R1 (how the bell and the hidden tab share one shell), R4 (BR-48 and the pending-cancel rule), R5 (typed notification kinds without a schema bump), R6 (reminders without a backend), R8 (search as a query of the Facilities screen).

## Technical Context

**Language/Version**: Dart 3.13.7 / Flutter 3.47.9 stable (CI pinned, as earlier features).

**Primary Dependencies**: existing (Riverpod codegen, Freezed, GoRouter, Phosphor, `clock`, `image_picker`, `shared_preferences`, 002 widgets, 003 account gate and verification, 004 catalogue, 005 and 006 booking and payments). **No new package.**

**Storage**: the existing demo snapshot (schemaVersion stays 2: all new fields are nullable or tolerant, R5 and R12); device-only state in `shared_preferences` (recent searches, notification permission answer); the profile photo in the existing photo store (`photo/<id>`). No card data, no national ID shown.

**Testing**: `flutter_test` with `fake_async` and `clock` for every timing rule (cutoff, reminder window, 60-second checker); domain and repository tests first; widget tests across size classes, RTL/LTR, light/dark, 200% text, semantics, keyboard; acceptance tests per user story; guard tests (arb parity, no raw icons, privacy: no national ID on new screens).

**Target Platform**: Android, iOS, web (iPhone Safari and desktop are the demo targets), macOS/Windows/Linux, tablets and foldables.

**Project Type**: Flutter app, feature-first Clean Architecture.

**Performance Goals**: search results under 1 second (SC-006); lists smooth with up to 100 bookings and 100 notifications; unread count always equals the unread records (SC-005).

**Constraints**: every number from Settings (constitution III); tokens only; no Lottie (static art); no backend; refunds only through `PaymentProvider.refund`; targets at least 48.

**Scale/Scope**: 9 screens (my bookings, booking details, cancel dialog, cancel result, notifications, account, edit profile, search suggestions, search results), 9 new shared widgets, 1 shell change, 2 `/demo` actions, about 130 strings, changes in `booking`, `notifications`, `identity`, `catalogue`, `settings`, `demo`, router, shell, seed.

## Constitution Check

| Principle | Check | Status |
| --- | --- | --- |
| I. Repository is the source of truth | Spec cites BRD IDs; the BRD gains FR-CAT-05, BR-48, FR-MYB-03 edit rule, verification notification kinds and the US-13/US-14 additions in this PR; the design pack is the layout reference and wins only where `docs/design-system` is silent | ✅ |
| II. Tokens only, one identity | New widgets use `SprintColors`, `SprintSpacing`, `SprintRadius`, `SprintSize`, `SprintMotion`; layout constants without a token (rail 88, panes 260/300/360/400, 2px selected border, bottom padding) are named constants in `SprintExtras` (R13); `control-border` for chips | ✅ |
| III. Settings, not constants | `cancellationCutoffHours`, `refundPercent`, `reminderLeadMinutes`, `fewLeftThreshold` read with inheritance; all cancel and reminder wording computed; the 60-second checker period and the 30-day "most booked" window and the five recents are presentation constants (justified below) | ✅ |
| IV. Every data source behind a repository | Cancel, refund, reminder writes, profile update and most-booked count are repository methods; screens read providers; `PaymentProvider.refund` unchanged | ✅ |
| V. Arabic first, adaptive, accessible | Window-class layouts per `adaptive.md`; native dialogs and sheets, `WideDialog` and popovers from medium up; Egyptian copy, no imperative verbs; 48 targets; word plus icon for every status; 200% text tests | ✅ |
| Product constraints | In-app records only, no SMS, no real push; Cairo only; no Lottie | ✅ |
| Workflow | Out of scope section present; one branch and PR; no history rewrite; design pack deleted before the PR | ✅ |

Post-design re-check (after data model and contracts): no new violations. Two deviations are in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/007-bookings-notifications-profile/
├── design-pack/          # input, temporary (deleted before merge)
├── spec.md
├── plan.md               # this file
├── research.md           # R1–R14
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── repositories.md
│   └── routes.md
├── checklists/requirements.md
└── tasks.md              # /speckit-tasks
```

### Source Code (repository root)

```text
lib/
├── app/
│   ├── router/{routes,destinations,destinations_provider,app_router}.dart  # contracts/routes.md
│   └── shell/
│       ├── adaptive_shell.dart            # badge on the notifications destination, hide it on compact, keep the origin tab highlighted (R1)
│       └── placeholders/{bookings,profile}_placeholder.dart                # deleted
├── core/
│   ├── seed/{seed_bookings,seed_misc}.dart    # reminder-ready and cancel-ready samples, more confirmed bookings for "most booked"
│   ├── tokens/sprint_extras.dart              # new layout constants (R13)
│   ├── adaptive/{sprint_dialog,popover}.dart  # WideDialog surface from medium up; anchored popover
│   └── widgets/
│       ├── notification_bell/ notification_card/ booking_row/ segmented_control/
│       ├── settings_row/ avatar/ banner/ popover/ wide_dialog/   # one folder each, as 002
│       ├── sprint_text_field/                 # + locked state, search clear and filled
│       └── design_system.dart                 # exports
├── features/
│   ├── booking/
│   │   ├── domain/{booking,cancellation_policy,cancel_preview}.dart   # cancelledAt, BR-48, CancelPreview
│   │   ├── domain/booking_repository.dart     # + bookedCounts
│   │   ├── data/in_memory_booking_repository.dart  # owner-cancel notification, pending cancel, housekeeping markNoShows
│   │   └── presentation/
│   │       ├── bookings/{my_bookings_screen,bookings_list,bookings_master_detail,booking_row_data}.dart
│   │       ├── details/{booking_details_screen,details_actions,status_banner,receipt_link}.dart
│   │       ├── cancel/{cancel_dialog,cancel_result_screen,cancel_wording}.dart
│   │       └── providers/{my_bookings_providers,cancel_providers}.dart
│   ├── notifications/
│   │   ├── domain/{notification,notification_kind,notification_repository,reminder_policy}.dart
│   │   ├── data/{in_memory_notification_repository,reminder_scheduler}.dart
│   │   └── presentation/
│   │       ├── notifications_screen.dart  notification_card_data.dart  permission_dialog.dart
│   │       └── providers/{notification_providers,reminder_providers,permission_provider}.dart
│   ├── identity/
│   │   ├── domain/{user,identity_repository}.dart      # avatarId, updateProfile
│   │   └── presentation/{profile_photo_provider,avatar_encoder}.dart
│   ├── account/                           # new feature folder: the account screen and edit profile
│   │   └── presentation/{account_screen,account_guest_card,edit_profile_screen,language_picker,appearance_picker,sign_out_flow}.dart
│   ├── catalogue/
│   │   ├── domain/{facility_search,arabic_normalizer,search_suggestions}.dart  # pure
│   │   ├── data/recent_searches_store.dart
│   │   └── presentation/search/{search_field,search_suggestions_view,search_results_header,search_providers}.dart
│   ├── demo/presentation/demo_screen.dart # "إظهار تذكير حجزي الجاي" and "إلغاء من الإدارة"
│   └── payments/presentation/receipt/...  # receipt provider relaxed to any status with a succeeded payment (R10)
└── l10n/app_ar.arb, app_en.arb            # keys from design-pack copy, parity enforced

test/   # mirrors lib/ + acceptance/us13, us14, us01_search + guards (privacy, arb parity)
```

**Structure Decision**: Stay feature-first. Booking screens live in `booking/presentation`; notifications get their own presentation folder; the account screen gets a small new `account` feature (it spans `auth`, `identity`, `verification` and settings and would otherwise grow `auth`). Pure search and cancel rules live in `domain` and import no Flutter (guards already enforce this for booking and catalogue).

## Phases (for /speckit-tasks)

1. **Domain and data** (no UI), tests first: `Booking.cancelledAt`; `CancelPreview` and BR-48 in `CancellationPolicy`; owner-cancel notification (already read) and pending cancel in the repository; `NotificationKind`, repository `changes` and `markAllRead`; `ReminderPolicy` and scheduler; `bookedCounts`; `User.avatarId` and `updateProfile`; `FacilitySearch` and normaliser; receipt provider relaxation; `markNoShows` in housekeeping; seed.
2. **Shared widgets and l10n**: the nine components and `TextField` states with previews in the component gallery; strings in both ARB files.
3. **Navigation**: `AppSection.notifications`, routes, shell badge and compact hiding with origin-tab highlight, the shared root header with the bell, Home's links.
4. **My bookings and details (US1, US2)**.
5. **Cancel (US3, US4)**: dialog, result, pending cancel, facility cancel display.
6. **Notifications and reminders (US5, US6)**: centre, bell, permission dialog, scheduler wiring, `/demo` actions.
7. **Account and edit profile (US7, US8)**.
8. **Search (US9)**: field, suggestions, results, recents, no-results.
9. **Adaptive, accessibility, dead-end walk, polish (US10)**; evidence; BRD, decisions, tokens sample and `CLAUDE.md` updates; delete `design-pack/` before the PR.

## Complexity Tracking

| Deviation | Why needed | Simpler alternative rejected because |
| --- | --- | --- |
| `NotificationRepository` and `IdentityRepository` interfaces grow (`changes`, `markAllRead`, `updateProfile`) | A bell needs a change signal and the centre needs bulk read; edit profile needs a write path that the interface never had | Reading the concrete class from the UI breaks constitution IV |
| One shell branch (`notifications`) that is a tab from the medium class and hidden on compact | Figma shows a bell on compact and a destination on wide with the same route and state | Two separate routes duplicate the screen and lose state when the window changes (spec FR-018, edge case) |
| Presentation constants: checker period 60 s, "most booked" window 30 days, five recents | The BRD has no such settings; they are display and demo behaviour, not business rules | New admin settings would add knobs nobody asked for (recorded in spec Assumptions) |
