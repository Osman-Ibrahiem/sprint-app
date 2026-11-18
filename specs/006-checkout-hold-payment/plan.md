# Implementation Plan: Checkout with Hold and Sandbox Payment, Confirmation Ticket

**Branch**: `006-checkout-hold-payment` | **Date**: 2026-11-17 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/006-checkout-hold-payment/spec.md`, design pack in [design-pack/](design-pack/README.md)

## Summary

Replace 005's "قريبًا" checkout with the real paid flow. "متابعة للدفع" creates the booking `PENDING_PAYMENT` with a Hold (BR-12) and opens one **checkout screen** whose state comes from the booking and its latest payment: holding, last minute, processing, awaiting, failed, cancelled, expired. "الدفع" starts a payment through `PaymentProvider` and sends the booker to the provider page, which in P1 is a **simulated page inside the app** owned by the fake provider. The **repository**, not the screen, listens to the provider and applies each outcome (BR-28): success confirms and records the payment for the owning unit (BR-33), failure and cancel keep the Hold (US-10, BR-47), a pending payment extends the Hold once to `holdMaxMinutes` (BR-46), and any late success on a booking that is no longer pending is refunded 100% automatically. Leaving payment asks "ترك الدفع؟" and expires the booking (BR-47). Success lands on a **confirmation ticket** (code, QR, cancellation line, reminder lead) shared with free bookings, and a **receipt** that saves as an on-device PDF with text sharing as fallback (FR-PAY-03). The fake provider's outcome (success, failure, delay) is set from `/demo`.

Key decision asked for in the brief: **cancel on the provider page is a new `PaymentStatus.cancelled`**, not a deleted payment ([research R1](research.md#r1-cancel-on-the-provider-page-paymentstatuscancelled-or-delete-the-payment)).

## Technical Context

**Language/Version**: Dart 3.13.7 / Flutter 3.47.9 stable (CI pinned, as earlier features).

**Primary Dependencies**: existing (Riverpod codegen, Freezed, GoRouter, Phosphor, `clock`, `qr`, `share_plus`, 002 widgets, 003 account gate, 005 summary and layouts). **One new package: `pdf`** (pure Dart; receipt PDF on every platform including web, R9). No `printing`, no calendar plugin, no brightness plugin.

**Storage**: the existing demo snapshot in `shared_preferences` (decisions 2026-11-16). New fields bump `schemaVersion` 1 → 2 (R13). No card data stored except `cardLast4`.

**Testing**: `flutter_test` with `fake_async` and `clock` for every timing rule; widget tests across size classes, RTL/LTR, light/dark, 200% text, semantics, keyboard and back handling; acceptance tests per user story; guard tests (raw icons, card data).

**Target Platform**: Android, iOS, web, macOS/Windows/Linux, tablets and foldables (unchanged).

**Project Type**: Flutter app, feature-first Clean Architecture.

**Performance Goals**: countdown drift ≤ 1 s (SC-005); paid flow summary → ticket < 60 s with the fake (SC-001).

**Constraints**: only the provider confirms (BR-28); all numbers from Settings (constitution III); tokens only; no card data beyond last four (FR-009); no Lottie, no calendar (clarify 2026-11-17).

**Scale/Scope**: 5 screens (checkout with 7 states, provider page, confirmation, receipt, leave dialog), 1 demo section, ~70 strings, changes in `booking`, `payments`, `settings`, `demo`, router, seed.

## Constitution Check

| Principle | Check | Status |
| --- | --- | --- |
| I. Repository is the source of truth | Spec cites BRD IDs; BR-46/BR-47/FR-PAY-03 taken as settled from `decisions.md` 2026-11-17; `copy.md` is the string source over Figma | ✅ |
| II. Tokens only, one identity | Banner colours `warning-soft`/`danger-soft`, `primary-soft` tag; QR dark on white; new layout widths go to `SprintExtras` as named constants (R12) | ✅ |
| III. Settings, not constants | `holdMinutes`, new `holdMaxMinutes`, `cancellationCutoffHours`, `refundPercent`, `reminderLeadMinutes`, `paymentProvider` read with inheritance. The 20 s processing wait is a presentation constant because the BRD has no such setting (justified below) | ✅ |
| IV. Every data source behind a repository | Outcomes applied in `BookingRepository` (webhook analogue); screens never see the provider; fake controller only used by the fake page and `/demo` | ✅ |
| V. Arabic first, adaptive, accessible | Layout by window class per `adaptive.md`; native dialogs/back; live regions throttled; 200% text tests; no imperative copy | ✅ |
| Product constraints | Sandbox/fake only; no SMS; Cairo in the PDF; no Lottie (feature 11) | ✅ |
| Workflow | Out of scope section present; one branch/PR; no history rewrite | ✅ |

Post-design re-check (after data model and contracts): no new violations. The `PaymentProvider` interface grows by one method and two fields (R3); this is additive and keeps BR-29.

## Project Structure

### Documentation (this feature)

```text
specs/006-checkout-hold-payment/
├── design-pack/          # input (Figma vs BRD, screens, flow, adaptive, copy)
├── spec.md
├── plan.md               # this file
├── research.md           # R1–R15
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
├── app/router/routes.dart                         # new routes, 005 redirects (contracts/routes.md)
├── core/
│   ├── data/in_memory_data_layer.dart             # schemaVersion 2, fake outcome in snapshot
│   ├── seed/seed_bookings.dart                    # SPR-4F7K2 (paid + receipt), SPR-Q4N7A (free)
│   └── tokens/sprint_extras.dart                  # checkout/gateway/confirmation column widths
├── features/
│   ├── settings/domain/setting_registry.dart      # holdMaxMinutes (BR-46)
│   ├── payments/
│   │   ├── domain/payment.dart                    # + cancelled, startedAt, cardLast4, receiptNumber
│   │   ├── domain/payment_provider.dart           # PaymentUpdate, status(), checkoutLocation
│   │   ├── domain/payment_repository.dart         # latestPayment, nextReceiptNumber
│   │   ├── domain/receipt.dart                    # derived Receipt + text form
│   │   ├── data/fake_payment_provider.dart        # sessions wait for the page; FakeOutcome
│   │   ├── data/fake_gateway_controller.dart
│   │   └── presentation/
│   │       ├── fake_gateway_screen.dart           # simulated provider page
│   │       ├── card_format.dart                   # Luhn, expiry, CVC (pure)
│   │       └── receipt/{receipt_screen,receipt_pdf}.dart
│   ├── booking/
│   │   ├── domain/booking.dart                    # holdStartedAt, holdMaxExpiresAt
│   │   ├── domain/hold_policy.dart                # nextExpiry (BR-46)
│   │   ├── domain/checkout_view.dart              # pure CheckoutView derivation
│   │   ├── domain/booking_repository.dart         # startPayment, refreshPayment, leaveCheckout, watchBooking
│   │   ├── data/in_memory_booking_repository.dart # _applyOutcome, extension, late refund; pay() removed
│   │   └── presentation/
│   │       ├── checkout/                          # replaces checkout_coming_soon_screen.dart
│   │       │   ├── checkout_screen.dart
│   │       │   ├── checkout_layout.dart
│   │       │   ├── hold_banner.dart
│   │       │   ├── payment_method_card.dart
│   │       │   ├── leave_checkout_dialog.dart
│   │       │   ├── processing_view.dart / awaiting_view.dart
│   │       │   ├── failed_header.dart / expired_view.dart
│   │       │   └── moment_placeholder.dart        # static until feature 11
│   │       ├── confirmed/booking_confirmed_screen.dart  # replaces done/booking_done_screen.dart
│   │       ├── providers/checkout_providers.dart
│   │       └── summary/booking_summary_screen.dart # hand-off now creates the booking
│   └── demo/presentation/demo_screen.dart          # "الدفع التجريبي" section
└── l10n/app_ar.arb, app_en.arb                     # keys from design-pack/copy.md

test/   # mirrors lib/ + acceptance/us06_paid, us10, us12 + guards/no_card_data_test.dart
```

**Structure Decision**: Stay feature-first. Payment-page and receipt UI live in `payments/presentation` (they are about the payment); the checkout and confirmation screens live in `booking/presentation` (they are about the booking). The fake gateway controller sits in `payments/data` beside the fake provider so nothing in `booking` can import it.

## Phases (for /speckit-tasks)

1. **Domain and data** (no UI): settings key, booking and payment fields, `PaymentProvider` additions, fake provider and controller, `HoldPolicy.nextExpiry`, repository split and `_applyOutcome`, receipt numbering, snapshot v2, seed. Tests first for BR-12/28/46/47 rules.
2. **Checkout screen (US1–US3, US5)**: states, banner, countdown, leave dialog, provider page, processing/awaiting.
3. **Slow confirmation and late refund (US4)**.
4. **Confirmation ticket (US1, US8)** for paid and free; replace 005 done screen; route redirects.
5. **Receipt (US6)**: screen, PDF, share fallback.
6. **Demo control (US7)**.
7. **Adaptive, accessibility, polish (US9)**; evidence. (`CLAUDE.md` "Current state" is updated in a separate docs PR after the merge, as in 005.)

## Complexity Tracking

| Deviation | Why needed | Simpler alternative rejected because |
| --- | --- | --- |
| `PaymentProvider` grows (`status()`, `PaymentUpdate`, `checkoutLocation`) although the design pack says it "doesn't change" | Refresh status (FR-015), last four for the receipt without handling the card (FR-009), and where to send the booker (provider page) | Reading the card in the app breaks FR-009; no redirect location means booking code must know the fake page |
| `BookingRepository.pay()` removed | One-shot pay expired on failure (contradicts US-10) and cannot express processing/cancel/late outcomes | Keeping it beside the new methods leaves two inconsistent paths |
| Processing wait (20 s) is a constant, not a setting | BRD defines no such number; it is a presentation timing, not a business rule | A setting would add an admin knob the BRD never asked for; recorded in spec Assumptions |
| New package `pdf` | FR-PAY-03 (on-device PDF) | Text-only receipt contradicts the settled decision |
