# Sprint (سبرنت)

Flutter app (Android, iOS, tablets, iPad, foldables, Web, Desktop) for booking and paying for Tanta University's sports facilities, with no cash at all. It is also the third research tool in Dr. Sara El-Hag's PhD thesis (Sports Management and Recreation, Faculty of Physical Education, Tanta University). It will be shown as a complete working system to the expert reviewers and at the defense, and stays that way until the university adopts it.

Owner: Osman (decides, reviews). Claude Code plans and reviews; OpenCode implements.

## Read before doing anything

| What | Where | Why |
| --- | --- | --- |
| Business requirements | `docs/BRD.md` | Scope, phases, business rules (`BR-xx`), domain model, roles × scope matrix, functional requirements (`FR-xx`), user stories with acceptance criteria (`US-xx`), NFRs, open questions |
| Decisions so far | `docs/decisions.md` | What's settled and why; don't reopen these without Osman |
| Design system | `docs/design-system/README.md` | Brand book: colour, type, copy rules, icons, motion, accessibility |
| Platforms and layout | `docs/design-system/adaptive.md` | iOS vs Android vs Web behaviour, window size classes, foldables, RTL |
| Figma and Flutter handoff | `docs/design-system/handoff.md` | Token names in Figma Variables and Flutter, widget names, component variants |
| Tokens | `docs/design-system/tokens.json` (source) · `tokens.css` (generated, for previews) | Every colour, size, radius, shadow and type style |
| Components | `docs/design-system/components/<Name>/README.md` + `preview.html` | Props, states, rules; open the preview in a browser to see it |
| Original brief | `docs/product-brief.md` | Osman's first description of the product |
| Research context | `docs/research/` | Thesis plan PDF and the revised intro and problem pages. Read for the "why", not for requirements |

**This repo is the source of truth.** `docs/` and `docs/design-system/tokens.json` win over Figma and over the claude.ai artifacts. Any change to requirements, tokens or components lands here first (in a PR), then Figma and Flutter follow. The claude.ai artifacts (BRD https://claude.ai/artifact/PbJrsCE5ACdTipXCaJ6KWx · design system https://claude.ai/artifact/X4xVNYL5DobUxxZQDj9eft) are frozen snapshots from 2026-11-08 for viewing only.

## Current state

- Phase **P1**: build the **whole UI first, every screen, on realistic mock data**, then the backend (Supabase or Firebase, decided later). **Feature 001 Foundation is built** (PR #1): tokens generated from `tokens.json`, light/dark theme, ar/en l10n, router and adaptive shell, the five adaptive controls, the `/demo` screen, settings with inheritance, pure rule services, in-memory repositories on seed data behind interfaces, role-driven destinations, and CI plus a Pages deploy. **Feature 002 Design system widgets is built** (PR #11): `SprintButton`, `SprintTextField`, `SlotChip`, `DayStrip`, `StatusBadge`, `FacilityCard`, `BookingTicket`, `AppNavigation` (replaces the plain tab bar, rail and sidebar), `StatTile` and `SprintLogo` in `lib/core/widgets/`, platform behaviour through new primitives in `lib/core/adaptive/`, the `fewLeftThreshold` setting (BR-45), Phosphor icons, and a component gallery at `/demo/components`. **Feature 004 Facility catalogue and details is built** (PR #13): guest and signed-in home, the facility list with type, owning-unit and free/paid filters (kept across navigation), facility details (today's availability, hours and closures, price groups per tier, units, trainers), a share link `/facilities/<id>`, a not-found screen and a "قريبًا" screen behind "عرض المواعيد" until feature 5, master-detail from the medium window class up, all in `lib/features/catalogue/`. **Feature 003 Auth and verification is built** (PR #14): sign up with an emailed 6-digit code, sign in by email or phone with a 5-minute lockout, password reset, the account gate and gated deep links (`requireAccount`, `/sign-in?from=`, `NoAccessScreen`), verification requests with an ID card photo, automatic approval from uploaded CSV sheets, verifier review scoped by owning unit, expiry from the `verificationExpiry` setting and `tierFor`, a simulated mailbox at `/demo/mailbox`, and demo data saved on the device with a reset action (`docs/decisions.md` 2026-11-16). **Feature 005 Availability and booking is built** (PR #18): the schedule at `/facilities/<id>/schedule` (day strip, unit picker, slot grid, few-left, free range, trainer step; the selection lives in the address), the booking summary with a quote, free bookings created `CONFIRMED` with a simple success screen, a "قريبًا" checkout hand-off for paid bookings, and the side panel or bottom bar by window width, all in `lib/features/booking/` (offers are not applied to prices until feature 10, `docs/decisions.md` 2026-11-17). **Feature 006 Checkout, hold and sandbox payment is built** (PR #23): "متابعة للدفع" creates the booking `PENDING_PAYMENT` with a hold, the booker pays on a simulated provider page and only the provider's status confirms (BR-28), a checkout screen whose states (holding, last minute, processing, awaiting, failed, cancelled, expired) come from the booking and its latest payment, a leave-checkout confirmation (BR-47), hold extension up to the `holdMaxMinutes` setting while a payment is pending, an automatic full refund for a late success (BR-46), the confirmation ticket for paid and free bookings, a receipt with an on-device PDF, and success, failure or delay on demand from "الدفع التجريبي" in `/demo`, all in `lib/features/payments/` and `lib/features/booking/`. **Feature 007 My bookings, cancellation, notifications, account and search is built** (PR pending): the real "حجوزاتي" (upcoming and past, empty states, master-detail from the medium class) and booking details for every status in `lib/features/booking/presentation/`, cancellation with a computed confirmation (full, partial, none, free, and by the facility) through one pure `CancelPreview` and the new `PENDING_PAYMENT → CANCELLED` transition (BR-48), the notifications centre with the bell on compact and a destination with a badge from medium up in `lib/features/notifications/`, reminders written by an in-app checker whose cancel action is decided when shown (BR-40), the account screen and edit profile (name and photo; email and phone locked) in `lib/features/account/`, catalogue search with suggestions, recents and the no-results state in `lib/features/catalogue/presentation/search/`, new shared components (`NotificationBell`, `NotificationCard`, `BookingRow`, `SegmentedControl`, `SettingsRow`, `Avatar`, `Banner`, `WideDialog`, `Popover`), and `/demo` actions for a reminder and a facility cancellation (`docs/decisions.md` 2026-11-18). Dr. Sara's demo is a web link (guest and booker flows) and a larger refactor reconciling features 001–007 with Figma follows it. Next is feature 8 (trainer); run `/design-check` for it first.
- Real facility data from Dr. Sara is coming later. Until then use realistic placeholder seed data (Arabic facility names, EGP prices, 12-hour times) behind the same repositories.
- Payments run in **sandbox/test mode** only. **No SMS and no paid service in P1**: notifications are push and in-app; account confirmation and password reset go by email.

## Stack and architecture

- Flutter + Riverpod (codegen) + Freezed + GoRouter + Clean Architecture, feature-first.
- Every data source sits behind a repository interface. P1 ships fake/in-memory implementations with seed data; the real backend replaces them without touching presentation code.
- `PaymentProvider` is an interface: P1 = sandbox gateway (or a fake), P2 = the university's e-collection platform. Booking flow code never knows which.
- Every number or behaviour the BRD marks as a setting (booking window, capacity, booking mode, hold minutes, cancellation cutoff, refund percent, reminder lead time…) is read from a `Settings` repository with university → facility → unit inheritance. Never hard-code them.
- Server-side truth later: availability, conflicts, pricing, refunds and permissions are validated by the backend. In P1 the fake repositories enforce the same rules so the UI behaves correctly.

## Workflow

- **Spec Kit, strictly in order:** specify → clarify → plan → tasks → implement. Every spec cites the BRD IDs it covers (`US-06`, `FR-BKG-01`, `BR-12`).
- **Every UI-only feature spec has a mandatory "Out of scope" section** (backend, real payments, SMS, anything from P2).
- One branch and one PR per feature. Never rewrite git history (no force-push, no rebase of shared branches).
- `develop` deploys to GitHub Pages via CI.
- Commit messages and PR descriptions reference BRD IDs.

## Design source (feature 006 onward)

Figma is the live source for screens, with every variant: compact, medium, expanded, large, light and dark. File: https://www.figma.com/design/xeuMQ0KyXsXVh4QldmkbDf (key `xeuMQ0KyXsXVh4QldmkbDf`). Another session updates it as the product grows, so **nothing in this repo describes screens or where components sit**. Tokens, rules and components still live here and win over Figma (`docs/design-system/`). Features 001–005 predate this; they are reconciled with Figma in the planned refactor.

- **Only the session with the Figma MCP reads Figma.** Other Claude sessions and OpenCode have no access and must not guess a screen.
- **Before specify of any feature, run `/design-check <feature>` in the Figma session.** It reads the screens live, compares them with the BRD, and reports gaps. Osman decides on any gap: fix Figma, change the BRD, or continue with a note.
- **The result is a Design Pack** in `specs/<feature>/design-pack/` on the feature branch: per-screen layout from Figma numbers, token names, components, per-window-class differences and screenshots. It is how the Figma session hands the design to whoever implements (Claude on another account, or OpenCode).
- **The spec holds only a pointer** (Figma page or section name), never a description of a screen.
- **The pack is delete-before-merge.** It must not reach `develop`; CI fails the PR while `design-pack/` exists.
- **Implementers:** read the pack first. If it is missing, or Figma changed after its generation date, stop and ask Osman to re-run `/design-check`. After implementing, the Figma session compares the result with Figma (design QA) before the PR is opened.
- If the Figma session implements the feature itself, it reads Figma directly and needs no pack.

## Suggested feature order (UI first)

1. **Foundation:** theme from tokens (light/dark), motion tokens (`SprintMotion`), fonts as assets, l10n (ar default, en), router, window size classes, adaptive shell (tab bar / rail / sidebar), adaptive primitives (`AdaptiveAppBar`, `AdaptiveDialog`, `AdaptiveSheet`, `AdaptiveSwitch`, `AdaptiveLoader`), seed data and fake repositories.
2. **Design system widgets (built):** `SprintButton`, `SprintTextField`, `SlotChip`, `DayStrip`, `FacilityCard`, `StatusBadge`, `BookingTicket`, `AppNavigation`, `StatTile`, matching the component READMEs.
3. **Auth and verification (built):** sign up, sign in, reset, account gate, verification requests and review (US-01 – US-05).
4. **Facility catalogue and details (built):** FR-CAT.
5. **Availability and booking (built):** exclusive, shared, free range, with trainer (US-06 – US-09, US-11).
6. **Checkout with hold and sandbox payment, confirmation ticket (built):** US-10, US-12.
7. **My bookings, cancellation, notifications, account and search (built):** US-13, US-14, US-01 search.
8. Trainer: dashboard, QR scan, manual fallback (US-15 – US-17).
9. Admin operations: bookings, hours and closures, prices and settings, roles (US-18 – US-20).
10. Reports and KPIs (US-21), assets and damage reports (US-22), offers (US-24).
11. Polish before the defense: Lottie moments (booking/payment success, payment failure, empty states).

## Design rules (non-negotiable)

- **Tokens only.** No hex, no magic numbers in widgets. Colours come from a `SprintColors` `ThemeExtension` with light and dark instances; spacing, radius and sizes from `SprintSpacing`, `SprintRadius`, `SprintSize`; durations and curves from `SprintMotion`. Token names are identical to `tokens.json`.
- **Palette "Volt":** `primary` electric blue for the single main action per screen; `volt` lime is a fill only, always with `on-volt` text, never text, a line or an icon on a light surface.
- **Light and Dark** follow the system setting with a manual override. Dark lifts surfaces (`bg` → `surface` → `surface-raised`) instead of using shadows.
- **Native behaviour per platform, one identity.** Brand components look the same everywhere; navigation bars, back gestures, dialogs, sheets, switches, loaders and scroll physics follow the platform (`adaptive.md`). Don't make iOS look Material.
- **Layout follows window width, never device names:** compact < 600, medium 600–839, expanded 840–1199, large ≥ 1200. Foldables: respect hinges via `MediaQuery.displayFeatures`; keep state when folding/unfolding.
- **Arabic first, RTL.** Use `EdgeInsetsDirectional` / `AlignmentDirectional`, mirror directional icons only, wrap booking codes, phone numbers and emails in LTR isolates.
- **Copy:** light Egyptian dialect; no imperative verbs in UI (they're gendered): buttons are verbal nouns ("تأكيد الحجز"). Western digits (0–9) in both languages, 12-hour time ("5:00 م"), "120 ج.م" / "EGP 120". All strings in l10n files.
- **Fonts:** Cairo only, for headings, buttons, body text, labels, every number and booking codes (all the type token styles; hierarchy comes from size and weight, 400/500/600/700). Bundled as static-weight assets. Alexandria and IBM Plex Mono were removed on 2026-11-15 (`docs/decisions.md`). Every `TextStyle` sets `height` from the token (Cairo's built-in line height is about 1.87). Minimum size 12; never go below the token line heights; support text scaling to 200%.
- **Accessibility:** 48dp minimum targets (one exception: the native Apple navigation bar and its back button keep 44pt, see `docs/decisions.md` 2026-11-11), visible focus ring on keyboard platforms, every state carries a word or icon (never colour alone), meaningful screen-reader labels in Arabic.
- **Motion** (README § الحركة): mostly code, timed by `SprintMotion`; page transitions, sheets and back gestures keep the platform's timing. Skeletons instead of spinners for content. Lottie only for booking/payment success, payment failure and empty states: plays once, tinted from tokens at runtime, ≤ 100KB, mirrored in RTL when directional. No GIF or video in the UI. Respect `MediaQuery.disableAnimationsOf` everywhere.
- **QR** is always dark modules on white, in both themes.

## Domain essentials (details in the BRD)

- Hierarchy: `OwningUnit` (faculty or central admin) → `Facility` → `BookableUnit` (lane, pitch, hall).
- `BookingMode`: `EXCLUSIVE` (whole unit, one booker) or `SHARED` (capacity, one place per booking). Lanes start `SHARED`; it's a setting.
- Price tiers: `INTERNAL` (student/staff/faculty, one price) and `EXTERNAL` (full price). Tier comes from verification status at booking time and is frozen on the booking.
- Booking statuses: `PENDING_PAYMENT` → `CONFIRMED` → `ATTENDED` / `NO_SHOW` / `CANCELLED`, or `PENDING_PAYMENT` → `EXPIRED`.
- Permissions = role × scope (`UNIVERSITY` / `OWNING_UNIT` / `FACILITY`). Roles: `GUEST`, `BOOKER`, `TRAINER`, `FACILITY_MANAGER`, `VERIFIER`, `UNIT_ADMIN`, `SUPER_ADMIN`, optional `VIEWER`.
- No AI, no cash, no no-show penalties.

## When unsure

Check `docs/BRD.md` §11 (open questions) and `docs/decisions.md`. If it isn't settled there, ask Osman instead of guessing, and note the assumption in the spec's clarify step.
