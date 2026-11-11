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

- Phase **P1**: build the **whole UI first, every screen, on realistic mock data**, then the backend (Supabase or Firebase, decided later). **Feature 001 Foundation is built** (PR #1): tokens generated from `tokens.json`, light/dark theme, ar/en l10n, router and adaptive shell, the five adaptive controls, the `/demo` screen, settings with inheritance, pure rule services, in-memory repositories on seed data behind interfaces, role-driven destinations, and CI plus a Pages deploy. Next is feature 2 (design-system widgets).
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

## Suggested feature order (UI first)

1. **Foundation:** theme from tokens (light/dark), motion tokens (`SprintMotion`), fonts as assets, l10n (ar default, en), router, window size classes, adaptive shell (tab bar / rail / sidebar), adaptive primitives (`AdaptiveAppBar`, `AdaptiveDialog`, `AdaptiveSheet`, `AdaptiveSwitch`, `AdaptiveLoader`), seed data and fake repositories.
2. **Design system widgets:** `SprintButton`, `SprintTextField`, `SlotChip`, `DayStrip`, `FacilityCard`, `StatusBadge`, `BookingTicket`, `AppNavigation`, `StatTile`, matching the component READMEs.
3. Auth and verification (US-01 – US-05).
4. Facility catalogue and details (FR-CAT).
5. Availability and booking: exclusive, shared, free range, with trainer (US-06 – US-09, US-11).
6. Checkout with hold and sandbox payment, confirmation ticket (US-10, US-12).
7. My bookings, cancellation, notifications, profile (US-13, US-14).
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
- **Fonts:** Alexandria for headings and buttons (`display`, `title-lg`, `title`, `headline`, `button`); Cairo for body text, labels and every number (`number-lg`, `number`, `body`, `body-strong`, `label`, `caption`, `micro`); IBM Plex Mono for booking codes. All bundled as static-weight assets. Every `TextStyle` sets `height` from the token (Cairo's built-in line height is about 1.87). Minimum size 12; never go below the token line heights; support text scaling to 200%.
- **Accessibility:** 48dp minimum targets, visible focus ring on keyboard platforms, every state carries a word or icon (never colour alone), meaningful screen-reader labels in Arabic.
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
