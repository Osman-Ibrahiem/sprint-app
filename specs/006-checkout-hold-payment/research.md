# Research: Checkout with Hold and Sandbox Payment, Confirmation Ticket

Decisions for [plan.md](plan.md). Each item: **Decision**, **Rationale**, **Alternatives considered**. Settled rules (BR-46, BR-47, on-device PDF receipt) are inputs here, not questions.

## R1. Cancel on the provider page: `PaymentStatus.cancelled` or delete the payment

**Decision**: Add `PaymentStatus.cancelled`. Every attempt keeps its `Payment` row: `pending` when the provider page opens, then `succeeded`, `failed` or `cancelled`. The provider reports `cancelled` through the same status stream as the other outcomes.

**Rationale**:
- BR-33 says every payment operation is recorded and attributed to the owning unit. Deleting a row erases an attempt the gateway did see (a real gateway keeps a cancelled session), so the audit trail and the later revenue reports (feature 10) would disagree with the provider's records.
- BR-47 says cancel is *not* a failure. A distinct status is the only way the payment screen can tell "الدفع اتلغى" (banner) from "الدفع ماتمّش" (failure state) after a refresh, from stored data alone (FR-024).
- Real gateways (and the P2 e-collection platform) return a cancel/abandon result to the callback, so the status maps one to one; deleting would need the repository to interpret the callback specially.
- "Is there a pending payment?" (BR-46) stays a plain query on `status == pending`; a cancelled row does not count, so cancelling never extends the Hold.

**Alternatives considered**: Deleting the pending row on cancel: simpler enum, but loses history, cannot be told apart from "never paid" after a reload, and diverges from what the gateway logs. Reusing `failed` with a reason field: contradicts BR-47 and would show the failure screen.

## R2. How the flow is split now that payment is not one call

**Decision**: Replace the Foundation's one-shot `BookingRepository.pay(id)` (which awaited the provider's last status and expired the booking on failure) with:

| Method | Does |
| --- | --- |
| `startPayment(bookingId, userId)` | Checks owner, status and Hold; calls `PaymentProvider.start`; writes a `pending` `Payment`; subscribes to `watch(session)`; returns the `PaymentSession` (with its `checkoutLocation`). |
| `refreshPayment(bookingId)` | Reads `PaymentProvider.status(session)` once and applies it (FR-015). Never confirms by itself: it applies what the provider says. |
| `leaveCheckout(bookingId, userId)` | BR-47: releases the Hold now, booking `EXPIRED`. |
| `watchBooking(bookingId)` | `Stream<BookingCheckoutState>` (booking + latest payment), emitted on every write. |
| `expireHolds()` (existing, extended) | BR-12 and BR-46 (R4). |

The repository, not the screen, listens to the provider and applies each outcome (`_applyOutcome`), the same way a backend webhook handler will later (BR-28). The screens only watch the booking.

**Rationale**: The old `pay` cannot express the provider page, processing, awaiting, cancel or late outcomes, and it expired on failure, which contradicts US-10 (retry while the Hold lasts). Keeping outcome handling in the repository keeps BR-28 out of the UI and makes the backend swap a repository swap (constitution IV).

**Alternatives considered**: The screen listens to `PaymentProvider.watch` and calls `confirm`/`fail` on the repository: puts BR-28 in presentation and breaks when the app is closed during processing.

## R3. `PaymentProvider` changes (kept minimal)

**Decision**: The interface keeps `start`, `watch`, `refund` and gains:
- `PaymentSession.checkoutLocation` — where to send the booker. For the fake, the in-app route `/pay/sandbox/<sessionId>`; for a real sandbox, the gateway URL.
- `watch` yields `PaymentUpdate { status, cardLast4? }` instead of a bare `PaymentStatus`, so the receipt's method line has the last four digits without the app ever handling the card (FR-009).
- `Future<PaymentUpdate> status(PaymentSession)` — the immediate read behind "تحديث الحالة".

**Rationale**: These are the three things every hosted-page gateway already provides (redirect URL, masked card in the result, status query). Booking code still never knows which provider answers (BR-29).

**Alternatives considered**: Keep `Stream<PaymentStatus>` and read last4 from the page: would route card data through the app. A separate "page" interface for the fake: the redirect location covers it.

## R4. The extended Hold (BR-46)

**Decision**:
- `Booking` gains `holdStartedAt` and `holdMaxExpiresAt` (= `holdStartedAt + holdMaxMinutes`, capped at `start`), both set at creation from the settings at that moment, so later settings changes do not touch a live Hold. If `holdMaxMinutes < holdMinutes`, the maximum equals the normal expiry.
- `HoldPolicy` gains `nextExpiry(booking, now, hasPendingPayment)`:
  - normal expiry not reached → unchanged;
  - reached and a `pending` payment exists and `now < holdMaxExpiresAt` → `holdExpiresAt = holdMaxExpiresAt` (one extension straight to the maximum; the countdown then shows time to the maximum);
  - otherwise → expire.
- `expireHolds()` applies it on every read/write of bookings and on a 1-second ticker owned by a keep-alive provider while any of the current user's bookings is `PENDING_PAYMENT` (FR-004).
- When the maximum passes with a payment still pending, the booking is `EXPIRED` and the payment stays `pending`. A later `succeeded` on a non-`PENDING_PAYMENT` booking (expired by maximum or by "ترك الدفع") always triggers `refund(payment, payment.amount)`, a `Refund` with reason `late_confirmation`, and an in-app record `payment.refunded_auto` (clarify 2026-11-17: never re-confirm).
- A `failed` outcome no longer expires the booking (US-10); the Hold keeps its expiry.

**Rationale**: Jumping straight to the maximum is equivalent to "extend until the provider answers, at most the maximum" and avoids repeated small extensions that make the countdown jump. Storing the maximum on the booking freezes it like the price (BR-17 spirit).

**Alternatives considered**: Extending in steps of `holdMinutes`: more writes, same outcome. Computing the maximum from settings at read time: a settings change would alter a live Hold.

## R5. The simulated provider page and the demo control

**Decision**:
- `FakePaymentProvider` gains a `FakeGatewayController` (fake-only, in `lib/features/payments/data/`) with `confirm(sessionId, cardLast4)` and `cancel(sessionId)`, and an outcome `FakeOutcome { succeed, fail, delay(Duration) }` (delay ends in success, clarify 2026-11-17). Sessions stay `pending` until the page confirms or cancels; after confirm, the fake waits its short base delay (600 ms) or the configured delay, then reports.
- The page `FakeGatewayScreen` lives at `/pay/sandbox/:sessionId`, outside the shell (no navigation bar), gated to the booking's owner. It validates format only (Luhn, MM/YY in the future, 3–4 digit CVC, a name) and accepts the published test numbers (`4242 4242 4242 4242` etc.). Only the last four digits leave the page, through the controller. Leaving the page by back = "إلغاء".
- The outcome is a demo setting kept in the demo snapshot and shown on `/demo` in a new "الدفع التجريبي" section (نجاح · فشل · تأخير + delay seconds with presets 5, 30, 90 and "بعد الحد الأقصى" = `holdMaxMinutes` + 1 minute). Reset demo data returns it to success. Hidden with the other demo tools when `HIDE_DEMO_TOOLS=true`.
- After a restart, pending fake sessions are not in memory: `status()` for an unknown session reports by the current outcome (re-simulates from the resume time). Documented as a demo-only limitation.

**Rationale**: FR-010 and SC-002: every branch recordable on purpose. Controller-on-the-fake keeps card handling out of `PaymentProvider` and out of booking code.

**Alternatives considered**: Outcome typed into the card (e.g. a "decline" test card): fragile on video and harder to discover; can be added later.

## R6. Routes

**Decision** (extends 005's `contracts/routes.md`):

| Screen | Route | Notes |
| --- | --- | --- |
| Payment (holding, last minute, failed, cancelled, expired) | `/facilities/:id/schedule/checkout/:bookingId` | Replaces 005's `checkout?<selection>`. The booking id is in the path because a booking now exists; the state comes from the booking and payment, not the route. |
| Processing / awaiting | same route | Sub-states of the same screen; no separate route, so refresh lands on the right state. |
| Provider page (fake) | `/pay/sandbox/:sessionId` | Top-level, outside the shell. |
| Confirmation (paid and free) | `/bookings/:bookingId/confirmed` | Replaces `done/:bookingId`; the old path redirects here. Under the "حجوزاتي" tab. |
| Receipt | `/bookings/:bookingId/receipt` | Not found unless a `succeeded` payment exists. |

"متابعة للدفع" on the summary calls `create` and replaces the location with the payment route. "ترك الدفع" returns to `summary?<selection>`, the selection being rebuilt from the booking.

**Rationale**: FR-024 (links survive refresh), US-12 (ticket under bookings), 005's convention that the facility pane hosts the booking flow on wide windows.

**Alternatives considered**: `/checkout?<selection>` as in the design pack: cannot address a specific booking after refresh; creating on every load would double-book.

## R7. Leaving and back handling (BR-47)

**Decision**: The payment screen wraps its content in `PopScope(canPop: false)` while the booking is `PENDING_PAYMENT` and no processing is shown; `onPopInvokedWithResult` opens `AdaptiveDialog` ("ترك الدفع؟"). The app-bar back calls the same handler. The iOS edge swipe is handled by the same pop interception (Cupertino route respects `PopScope`). Processing uses `PopScope(canPop: false)` with no dialog and no back button. Web browser back is intercepted by GoRouter's pop handling through the same `PopScope`.

**Rationale**: One handler for all ways of leaving (FR-019).

## R8. Countdown and accessibility

**Decision**: `holdCountdownProvider(bookingId)` derives `remaining = holdExpiresAt - clock.now()` from the watched booking with a 1-second ticker; it never stores its own start. Format: `m:ss` above 60 seconds, whole seconds below. Semantics: a hidden `liveRegion` text updated only on 30-second boundaries and once on entering the last minute (FR-031). When `remaining <= 0` the provider triggers `expireHolds()` instead of deciding expiry itself.

**Rationale**: SC-005 (≤1 s drift, survives background), NFR accessibility.

## R9. Receipt PDF and sharing

**Decision**: Add the `pdf` package (pure Dart, works on web and all platforms, supports RTL and Arabic shaping with an embedded TTF). Embed the bundled `assets/fonts/Cairo-Regular.ttf` and `Cairo-Bold.ttf`. Save and share through the existing `share_plus` (`XFile.fromData`, which downloads on web). If generation throws, fall back to `Share.share(text)` with a message. "مشاركة الإيصال" shares the text form; where share is unavailable, copy to clipboard with "اتنسخ". Receipt number: `RC-` + `yyMMdd` of `paidAt` (Cairo time) + `-` + a 4-digit sequence per day held in the payment repository. No `printing` package.

**Rationale**: FR-PAY-03 decided on-device PDF; `pdf` is the standard pure-Dart generator, and `share_plus` is already a dependency. Version is pinned at implement time to the latest stable that supports Dart 3.13.

**Alternatives considered**: `printing` (adds native plugins for a preview we don't need); HTML-to-PDF (needs a web view).

## R10. Confirmation ticket, QR and the free path

**Decision**: `BookingConfirmedScreen` replaces 005's `BookingDoneScreen` for paid and free bookings. It uses the 002 `BookingTicket` (state `today` or `upcoming` from the booking date in Cairo), the existing `qrToken`, a copy action with `SemanticsService.announce("اتنسخ")` and a snackbar, the reminder line from `reminderLeadMinutes` via an ICU plural helper (`formatLeadTime`: 60 → "ساعة", 90 → "ساعة ونص", 120 → "ساعتين", 180 → "3 ساعات"), and the cancellation line from `cancellationCutoffHours` (`start - cutoff`, formatted "الأحد 3:00 م", or "الإلغاء مش متاح" when passed). Success and failure illustrations are a small static `MomentPlaceholder` (icon and text) that feature 11 replaces with Lottie. No add-to-calendar and no brightness change.

## R11. Notifications

**Decision**: Reuse `_notify` with types `booking.confirmed` (paid and free, already used), `payment.refunded_auto` (new). Remove the old `payment.failed` record on failure (the booker is on the screen; failure is not a notification in the BRD). Push itself is out of scope.

## R12. Layout

**Decision**: Follow `design-pack/adaptive.md`: a `CheckoutLayout` that is one column with a bottom action bar below 600, and two columns (payment 372–374, summary the rest) from 600, inside the facility pane like 005; centred 480 column for provider page, processing, awaiting, receipt; confirmation one column through medium, two columns (358 + 48 + 358) from expanded. Widths come from `SprintExtras` constants added for these layout widths (decisions 2026-11-15 pattern), not literals. Hinge: reuse `lib/core/window/display_feature_layout.dart`.

## R13. Snapshot and seed

**Decision**: New fields (`Booking.holdStartedAt`, `holdMaxExpiresAt`, `Payment.cardLast4`, `PaymentStatus.cancelled`, receipt sequence, fake outcome) bump `InMemoryDataLayer.schemaVersion` from 1 to 2, so old snapshots restart from the seed (existing behaviour). Seed adds the sample bookings of the design pack: a `CONFIRMED` paid booking `SPR-4F7K2` with a `succeeded` payment and receipt `RC-261108-0482`, and a free `SPR-Q4N7A`. New bookings keep the existing code generator.

## R14. Settings

**Decision**: Add `SettingKeys.holdMaxMinutes` (BR-46), default 20, scopes university and facility (same as `holdMinutes`), range 1–120; `UnitSettings` reads it. No other new setting; the 20-second processing wait is a presentation constant (`CheckoutTimings.processingWait`), as the BRD does not define it.

## R15. Tests

**Decision**: Unit tests for `HoldPolicy.nextExpiry`, `formatLeadTime`, receipt numbering, card format validation; repository tests (fake async) for every outcome, cancel, leave, extension to the maximum, late success refund (both place taken and free), simultaneous create with a live Hold, restart with a pending payment; widget tests for each screen state across size classes, RTL/LTR, light/dark, 200% text, semantics and back handling; a router test for the new routes and the old `done` redirect; a guard test that no card number reaches storage or logs; acceptance tests named after the user stories.
