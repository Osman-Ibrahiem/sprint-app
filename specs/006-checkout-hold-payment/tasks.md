---

description: "Task list for feature 006 — checkout with hold and sandbox payment, confirmation ticket"
---

# Tasks: Checkout with Hold and Sandbox Payment, Confirmation Ticket

**Input**: Design documents from `/specs/006-checkout-hold-payment/` (spec.md, plan.md, research.md R1–R15, data-model.md, contracts/repositories.md, contracts/routes.md, quickstart.md, design-pack/)

**Prerequisites**: plan.md, spec.md (clarified 2026-11-17)

**Tests**: Included. The constitution requires all automated tests to pass for a PR, and every rule here (BR-12, BR-28, BR-46, BR-47) is timing-sensitive, so rule tests come before the code they cover.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: US1 pay and get the ticket · US2 failure and retry · US3 Hold runs out · US4 slow confirmation and late refund · US5 leave and provider cancel · US6 receipt · US7 demo control · US8 free bookings get the ticket · US9 every size, language and theme
- Paths are relative to the worktree root (single Flutter package, see plan.md)

## Rules for every task

- Tokens only, no raw colours or numeric style literals (layout widths the tokens lack go to `lib/core/tokens/sprint_extras.dart` as named constants); direction-aware layout; strings only in `lib/l10n/*.arb`, Arabic and English together, with the keys and wording of `specs/006-checkout-hold-payment/design-pack/copy.md` (copy.md wins over Figma). No imperative verbs; Western digits; 12-hour time; amounts through `SprintFormat` ("80 ج.م" / "EGP 80"); codes, amounts and card digits in LTR isolates.
- Every number the BRD calls a setting (`holdMinutes`, `holdMaxMinutes`, `cancellationCutoffHours`, `refundPercent`, `reminderLeadMinutes`, `paymentProvider`) is read through `SettingsRepository` / `UnitSettings.resolve`, never typed into a screen or rule. Sample numbers in Figma (9:42, 80, 3 ساعات) are samples only.
- Only the provider's reported status changes a booking (BR-28). Screens never call anything that confirms; they watch `BookingRepository.watchBooking`.
- Card number, expiry, CVC and name never leave `FakeGatewayScreen` except `cardLast4` through `FakeGatewayController.confirm`. Never log them.
- `lib/features/booking/domain/` and `lib/features/payments/domain/` import nothing from Flutter, Riverpod or `data/` (existing guard). Presentation reads repository interfaces through `lib/core/providers/data_providers.dart`; only `FakeGatewayScreen` and the `/demo` section may read `fakeGatewayProvider`.
- No platform checks outside `lib/core/adaptive/`; dialogs through `AdaptiveDialog`, loaders through `AdaptiveLoader`, app bars through `AdaptiveAppBar`. Reuse 002 widgets (`BookingTicket`, `StatusBadge`, `SprintButton`, `SprintTextField`) as they are. Icons through `SprintIcon` / `DirectionalIcon`.
- One primary `SprintButton` per screen. Every state carries a word or an icon. Targets ≥ 48dp. Motion respects `MediaQuery.disableAnimationsOf`. No Lottie and no "إضافة للتقويم" (feature 11).
- Do not edit `CLAUDE.md`, tokens, or anything under `docs/`. The "built" line for feature 6 goes in a separate docs PR after the merge.
- Commit messages cite BRD IDs. Branch `006-checkout-hold-payment`. No force-push, no rebase, no push unless Osman says so.
- After editing an ARB file run `flutter gen-l10n`; after editing a Riverpod or Freezed file run `dart run build_runner build --delete-conflicting-outputs`.

---

## Phase 1: Setup

**Purpose**: a known-green baseline and the one new package.

- [X] T001 Run `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze` and `flutter test` on the clean branch; all must pass. Create `specs/006-checkout-hold-payment/evidence.md` with a "Baseline" section (date, passing test count).
- [X] T002 Add the `pdf` package to `pubspec.yaml` (latest stable compatible with Dart 3.13.7; record the version in evidence.md), run `flutter pub get`, and confirm `flutter build web --release --base-href /sprint-app/` still passes (research R9).
- [X] T003 [P] Add `test/guards/payments_domain_pure_test.dart` modelled on `test/guards/booking_domain_pure_test.dart`: files in `lib/features/payments/domain/` may not import Flutter, Riverpod or `data/`; no file under `lib/features/booking/` may import `fake_gateway_controller.dart` or `fake_payment_provider.dart`.

---

## Phase 2: Foundational (blocks every user story)

**Purpose**: the settings key, the data model, the provider interface, the fake provider and controller, the Hold rule, the repository split and outcome handling, the snapshot, seed, routes skeleton, providers and strings. No story starts before this phase is done.

### Settings and data model (data-model.md)

- [X] T004 Add `SettingKeys.holdMaxMinutes` with a `SettingDefinition<int>` "default 20, scopes university and facility (`_uniFacility`), range 1–120" and the comment `// BR-46` in `lib/features/settings/domain/setting_registry.dart`; read it into `UnitSettings` beside `holdMinutes` in `lib/features/booking/domain/unit_settings.dart`. Extend the settings inspector list if it enumerates keys. Test in `test/features/settings/` that the default resolves to 20 and a facility override wins.
- [X] T005 [P] In `lib/features/payments/domain/payment.dart`: `enum PaymentStatus { pending, succeeded, failed, cancelled }` (R1); add `required DateTime startedAt`, `String? cardLast4` ("the only card data ever stored", 4 digits), `String? receiptNumber` ("`RC-yyMMdd-NNNN` assigned on `succeeded`"). Update `lib/core/data/json_converters.dart` if it maps the enum.
- [X] T006 [P] In `lib/features/booking/domain/booking.dart` add `DateTime? holdStartedAt` and `DateTime? holdMaxExpiresAt` with doc comments from data-model.md. `confirm()` clears `holdExpiresAt` (unchanged); `expire()` unchanged; add `Result<Booking> extendHoldTo(DateTime at)` allowed only from `pendingPayment` and only when `at` ≤ `holdMaxExpiresAt`.
- [X] T007 In `lib/features/payments/domain/payment_provider.dart`: add `Uri checkoutLocation` to `PaymentSession`; add `class PaymentUpdate { PaymentStatus status; String? cardLast4; }`; change `watch` to `Stream<PaymentUpdate>`; add `Future<PaymentUpdate> status(PaymentSession session)`; doc: "pending, then exactly one of succeeded | failed | cancelled" (contracts/repositories.md).
- [X] T008 [P] Create `lib/features/payments/domain/receipt.dart`: an immutable `Receipt { number, bookingCode, paidAt, facilityName, unitName, tier, cardLast4, isTest, amount }` and a pure `Receipt.fromPayment(Payment, Booking, facility, unit)` (no strings, no l10n: the domain imports no Flutter). The localized text form is built in presentation by T045. Unit test in `test/features/payments/domain/receipt_test.dart` (fields, `cardLast4` is exactly 4 digits).
- [X] T009 Extend `PaymentRepository` in `lib/features/payments/domain/payment_repository.dart` with `Future<Payment?> latestPayment(String bookingId)` and `Future<String> nextReceiptNumber(DateTime paidAtCairo)` ("`RC-` + `yyMMdd` + `-` + 4-digit per-day sequence starting at 0001"); implement in the in-memory payment repository under `lib/features/payments/data/` and test numbering across two days.

### Hold rule (R4)

- [X] T010 Write `test/features/booking/domain/hold_policy_test.dart` first: creation sets `holdExpiresAt = min(now + holdMinutes, start)` and `holdMaxExpiresAt = min(now + max(holdMaxMinutes, holdMinutes), start)`; `nextExpiry` returns unchanged before expiry, `holdMaxExpiresAt` at expiry with a pending payment before the maximum, and "expire" at expiry with no pending payment or at/after the maximum; `holdMaxMinutes < holdMinutes` gives no extension; `expiresOnAnswer(booking, now)` is true when `holdExpiresAt == holdMaxExpiresAt` (extended) and `now` ≥ `holdStartedAt + holdMinutes` capped at `start` (BR-46, analyze H1).
- [X] T011 Implement `HoldPolicy.expiryFrom`/`maxExpiryFrom` (both capped at `start`) `HoldDecision nextExpiry(Booking b, DateTime now, {required bool hasPendingPayment})` and `bool expiresOnAnswer(Booking b, DateTime now)` in `lib/features/booking/domain/hold_policy.dart` until T010 passes.

### Fake provider and controller (R5)

- [X] T012 Rewrite the existing `test/features/payments/fake_payment_provider_test.dart` first (keep its path; drop the `failNext` case) with `fake_async`: `start` returns a session whose `checkoutLocation` is `/pay/sandbox/<id>`; `watch` yields `pending` and nothing else until the controller acts; `confirm` + outcome succeed → `succeeded` with `cardLast4` after the base delay (600 ms); outcome fail → `failed`; outcome `delay(d)` → `succeeded` after `d`; `cancel` → `cancelled`; `status()` returns the latest update; `status()` for an unknown session (after restart) re-simulates by the current outcome; `refund` unchanged.
- [X] T013 Implement `FakeOutcome` (`succeed | fail | delay(Duration)`) and `FakeGatewayController` (`outcome`, `confirm(sessionId, {cardLast4})`, `cancel(sessionId)`, `session(sessionId)` view with amount, bookingId and facility label) in `lib/features/payments/data/fake_gateway_controller.dart`, and rework `lib/features/payments/data/fake_payment_provider.dart` (remove `failNext`) until T012 passes. Update every existing test that used `failNext`.

### Repository split and outcomes (R2, contracts/repositories.md)

- [X] T014 Write `test/features/booking/data/checkout_flow_test.dart` first (fake async, in-memory layer, fake provider): (a) paid `create` sets status, hold fields and no payment; (b) `startPayment` writes a `pending` payment with `startedAt` and owning unit, and a second call returns the same session; (c) succeeded → `CONFIRMED`, payment `succeeded` with `paidAt`, `cardLast4`, `receiptNumber`, one `booking.confirmed` record; (d) failed → still `PENDING_PAYMENT`, same `holdExpiresAt`, payment `failed`, no notification; (e) cancelled → same, payment `cancelled`; (f) retry after failure creates a second payment; (g) Hold reached with no payment → `EXPIRED`, place free; (h) Hold reached with a pending payment → `holdExpiresAt == holdMaxExpiresAt`, place still held; (i) maximum reached while pending → `EXPIRED`; then late success → payment `succeeded`, one `Refund(amount: full, reason: late_confirmation)`, one `payment.refunded_auto`, booking stays `EXPIRED` whether or not another booking took the place; (j) `leaveCheckout` → `EXPIRED` at once, and a late success refunds; (k) another account's `create` for the last place is refused while a Hold or extended Hold is live; (l) `startPayment` by another user → `NotPermitted`, on an expired Hold → `HoldExpired`; (m) `refreshPayment` applies `status()` and never confirms without `succeeded`; (n) `watchBooking` emits after every write; (o) a Hold extended to the maximum followed by a `failed` or a `cancelled` answer after `holdStartedAt + holdMinutes` → `EXPIRED` at once, place released; the same answer before that time → still `PENDING_PAYMENT` with the normal expiry (analyze H1); (p) changing `holdMinutes` and `holdMaxMinutes` in settings while a Hold is live leaves that booking's `holdExpiresAt` and `holdMaxExpiresAt` unchanged and applies to the next booking (spec edge case); (q) snapshot save → restore with a `pending` payment re-attaches the subscription, a later outcome is applied, and no second payment is started (FR-024).
- [X] T015 Update `lib/features/booking/domain/booking_repository.dart`: remove `pay`; add `startPayment`, `refreshPayment`, `leaveCheckout`, `watchBooking`, and `class BookingCheckoutState { Booking booking; Payment? latestPayment; Refund? refund; }`; add failures `PaymentUnavailable` and `NoPendingPayment` to `lib/core/result/failure.dart` if missing. Doc comments from contracts/repositories.md.
- [X] T016 Implement T015 in `lib/features/booking/data/in_memory_booking_repository.dart` until T014 passes: hold fields at creation from `UnitSettings` (T004, T011); `startPayment` through the serial queue; one subscription per pending session feeding `_applyOutcome` (table in contracts/repositories.md); `expireHolds` using `HoldPolicy.nextExpiry` and `latestPayment`; late-success refund through `paymentProvider.refund` and `payments.saveRefund`; `payment.refunded_auto` via `_notify` with `amount` in the payload; drop the old `payment.failed` record (R11); `watchBooking` from the existing `changes` stream. On data-layer restore, re-attach subscriptions for `pending` payments (R5). Apply `HoldPolicy.expiresOnAnswer` to `failed` and `cancelled` answers (analyze H1). Move every old `pay()` caller in `test/features/booking/booking_repository_test.dart` (lines that call `bookings.pay` and `paymentProvider.failNext`) to `startPayment` + `FakeGatewayController`.
- [X] T017 Bump `InMemoryDataLayer.schemaVersion` to 2 in `lib/core/data/in_memory_data_layer.dart`, include the new fields and the fake outcome in the snapshot codec (`lib/core/data/snapshot_codec.dart`), and make "إرجاع الداتا التجريبية" reset the outcome to `succeed`. Test round-trip in `test/core/data/`.
- [X] T018 [P] Seed in `lib/core/seed/seed_bookings.dart` (and payments seed): a `CONFIRMED` paid booking "حمام السباحة الأوليمبي · حارة 3 · الكابتن أحمد سامي · 5:00 – 6:00 م · داخلي 80 ج.م" with a `succeeded` payment (`cardLast4` 4242, receipt `RC-261108-0482`), and a free `CONFIRMED` booking, both with codes from the existing `SP-1xxx` generator (never `SPR-…`, analyze H2), dated relative to the seed clock like the existing seed. Update seed count tests.

### Presentation scaffolding

- [X] T019 Add every key of `design-pack/copy.md` to `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` (prefixes `checkout…`, `gateway…`, `processing…`, `awaiting…`, `holdExpired…`, `receipt…`, `confirmed…`, `ticket…`), with ICU plurals for minutes/seconds and a `{lead}` placeholder; reuse the existing keys `backToHome`, `statusExpired`, `statusConfirmed` and `statusPendingPayment` (check their wording matches copy.md; do not duplicate them). Add `demoPayment…` keys for the demo section (نجاح · فشل · تأخير). Run `flutter gen-l10n`; ARB parity guard passes.
- [X] T020 [P] Create `lib/features/booking/domain/lead_time.dart` with pure `LeadTime describeLead(int minutes)` returning hours and half-hour parts, and the ARB plural message that renders it (60 → "ساعة", 90 → "ساعة ونص", 120 → "ساعتين", 180 → "3 ساعات"); test in `test/features/booking/domain/lead_time_test.dart` in both languages.
- [X] T021 [P] Create pure `lib/features/booking/domain/checkout_view.dart`: `enum CheckoutView { holding, lastMinute, processing, awaiting, failed, cancelled, expired, confirmed, notFound }` and `CheckoutView checkoutViewOf(BookingCheckoutState s, DateTime now, {DateTime? processingSince, Duration processingWait})` per the table in data-model.md (lastMinute when remaining < 60 s; awaiting after `processingWait`); table-driven test in `test/features/booking/domain/checkout_view_test.dart`.
- [X] T022 Create `lib/features/booking/presentation/providers/checkout_providers.dart` (Riverpod codegen): `bookingCheckoutProvider`, `checkoutViewProvider`, `holdCountdownProvider` (1 s ticker from `holdExpiresAt`, calls `expireHolds()` at zero, never stores its own start, R8), `checkoutSettingsProvider`, `receiptProvider`, `holdHousekeepingProvider` (keep-alive ticker while the signed-in user has a `PENDING_PAYMENT` booking), and `CheckoutTimings.processingWait = Duration(seconds: 20)`; add `fakeGatewayProvider` in `lib/core/providers/data_providers.dart` wired to the same fake instance the data layer uses. Provider tests with `ProviderContainer` and fake async.
- [X] T023 Routes in `lib/app/router/routes.dart` per contracts/routes.md: `bookingCheckout` `/facilities/:id/schedule/checkout/:bookingId` (gated), old `checkout?<selection>` → redirect to `summary?<selection>`, top-level `fakeGateway` `/pay/sandbox/:sessionId` (gated, outside the shell), `bookingConfirmed` `/bookings/:bookingId/confirmed` and `bookingReceipt` `/bookings/:bookingId/receipt` under the bookings destination, `done/:bookingId` → redirect to `bookingConfirmed`. Placeholder builders for now. Router test in `test/app/router/` for each path, the redirects, guest → `/sign-in?from=`, another user's booking → `NoAccessScreen`; `/pay/sandbox/<unknown id>` (e.g. after a restart) → the booking's checkout route if the session's booking is known, otherwise home, and no payment is started (FR-024).
- [X] T024 [P] Add layout constants to `lib/core/tokens/sprint_extras.dart`: `checkoutPaymentColumn` 372, `checkoutSummaryColumnMin` 260, `centredColumn` 480, `confirmationColumn` 358, `confirmationGap` 48 (design-pack/adaptive.md), each with a comment naming the Figma frame and a `TODO(tokens)` note, joining the follow-up from decisions.md 2026-11-15 to promote `SprintExtras` sizes to tokens.
- [ ] T025 [P] Create shared pieces in `lib/features/booking/presentation/checkout/`: `hold_banner.dart` (`warning-soft` normal / `danger-soft` last minute, clock icon, title + remaining line, hidden live region updated on 30 s boundaries and once on entering the last minute), `moment_placeholder.dart` (static icon + title + body, success and failure variants, no animation), `payment_method_card.dart` (method title/subtitle + `primary-soft` test-mode tag shown only for `fake`/`sandbox`), `checkout_layout.dart` (compact: one column + fixed bottom bar; ≥ 600: two columns payment/summary inside the facility pane, action at the end of the payment column; hinge via `lib/core/window/display_feature_layout.dart`). Widget tests for the banner's two styles and announcements.

**Checkpoint**: domain, data and scaffolding are green; `flutter test` passes.

---

## Phase 3: User Story 1 - Pay for a held place and get a confirmed ticket (Priority: P1) 🎯 MVP

**Goal**: summary → Hold → payment → provider page → processing → "حجزك اتأكد" with ticket.

**Independent Test**: with outcome نجاح, book a paid lane and a paid pitch from seed data end to end; booking `CONFIRMED`, payment for the owning unit, `booking.confirmed` record, place taken for another account.

### Tests for User Story 1

- [ ] T026 [P] [US1] `test/features/booking/presentation/checkout/checkout_screen_holding_test.dart`: order of sections (banner, summary rows reused from 005, policy text from `cancellationCutoffHours`/`refundPercent`, method card, single primary "الدفع · 80 ج.م"), countdown from `holdExpiresAt`, test tag present for `fake` and absent when the setting is overridden in the test to a non-test kind (stub).
- [ ] T027 [P] [US1] `test/features/payments/presentation/fake_gateway_screen_test.dart`: amount, merchant line, four fields with LTR digits and numeric keyboard, Luhn/expiry/CVC validation messages with icon and words, confirm sends only `cardLast4`, Hold countdown visible.
- [ ] T028 [P] [US1] `test/features/booking/presentation/confirmed/booking_confirmed_screen_test.dart`: no back to payment, placeholder, "حجزك اتأكد", lead line from `reminderLeadMinutes` (180 and 60), `BookingTicket` with code, QR, "مؤكد", "المدفوع 80 ج.م", cancellation line before and after the cutoff, "إيصال الدفع" entry, copy → "اتنسخ" shown and announced.
- [ ] T029 [P] [US1] `test/acceptance/us06_paid_confirm_test.dart` and `test/acceptance/us12_confirmation_test.dart`: from the facility page through the summary, payment, fake page and processing to the ticket; a second account then sees the slot taken.

### Implementation for User Story 1

- [ ] T030 [US1] Summary hand-off in `lib/features/booking/presentation/summary/booking_summary_screen.dart`: "متابعة للدفع" for a paid quote calls `create` and `go`es to `bookingCheckout`; refusals keep the existing 005 messages (FR-002). Delete `lib/features/booking/presentation/checkout/checkout_coming_soon_screen.dart` and its tests.
- [ ] T031 [US1] `lib/features/booking/presentation/checkout/checkout_screen.dart`: watches `checkoutViewProvider`; `holding`/`lastMinute` layout with `HoldBanner`, 005 `summary_rows.dart`, `cancellation_policy_text.dart`, `PaymentMethodCard`, primary "الدفع · {amount}" with full semantic label ("الدفع، 80 جنيه"); "الدفع" calls `startPayment` and pushes `session.checkoutLocation`; a start error shows a message in words with the Hold unchanged. Title "الدفع".
- [ ] T032 [US1] `lib/features/payments/presentation/card_format.dart` (pure Luhn, MM/YY not in the past, 3–4 digit CVC, non-empty name, accepts published test numbers) with unit tests, then `lib/features/payments/presentation/fake_gateway_screen.dart`: "الدفع الآمن", gateway Hold banner, amount, "سبرنت · {facility}", four `SprintTextField`s with `autofillHints` and LTR digits, test tag, notice, "تأكيد الدفع · {amount}" and "إلغاء"; confirm → `FakeGatewayController.confirm(sessionId, cardLast4)` then pop. Field values live only in local widget state and are cleared on dispose.
- [ ] T033 [US1] `processing_view.dart` in `lib/features/booking/presentation/checkout/`: `AdaptiveAppBar` titled "الدفع" with no back, `PopScope(canPop: false)`, `AdaptiveLoader`, "بنأكد الدفع" and body, booking card with `StatusBadge` pending-payment and "المكان متحجز لك، فاضل {time} دقيقة" from the live countdown. Shown while the latest payment is `pending` and within `processingWait`.
- [ ] T034 [US1] `lib/features/booking/presentation/confirmed/booking_confirmed_screen.dart` replacing `lib/features/booking/presentation/done/booking_done_screen.dart` (delete it and its tests): success `MomentPlaceholder`, "حجزك اتأكد", lead line (T020), `BookingTicket` (state `today`/`upcoming` from the Cairo date, `qrToken`, price row, cancellation line from `cancellationCutoffHours`), "إيصال الدفع" row (paid only), "الرجوع للرئيسية" ghost. Copy uses `Clipboard` + `SemanticsService.announce` + snackbar "اتنسخ". `CheckoutScreen` `go`es here when the view becomes `confirmed`. Wire T023's builders.

**Checkpoint**: US1 is demoable end to end with outcome نجاح.

---

## Phase 4: User Story 2 - Payment fails and I try again while the place is held (Priority: P1)

**Goal**: failure returns to the same summary with retry; the Hold keeps running.

**Independent Test**: outcome فشل → failure state, Hold unchanged; outcome نجاح → retry → confirmed, two payment rows.

- [ ] T035 [P] [US2] `test/features/booking/presentation/checkout/checkout_screen_failed_test.dart` and `test/acceptance/us10_payment_failed_test.dart`: failure placeholder with "الدفع ماتمّش. ممكن تحاول تاني" (announced once), title "ملخص الحجز", banner with the same expiry, policy and method cards still shown, "إعادة المحاولة · 80 ج.م", retry succeeds; on-screen expiry turns into the expired state; a failure answer arriving after an extended Hold's normal expiry shows the expired state, not the failure state (analyze H1).
- [ ] T036 [US2] `failed_header.dart` in `lib/features/booking/presentation/checkout/` and the `failed` branch of `checkout_screen.dart` (title "ملخص الحجز", failure `MomentPlaceholder` with `danger` icon and words, primary "إعادة المحاولة · {amount}" calling `startPayment`).

---

## Phase 5: User Story 3 - The Hold runs out (Priority: P1)

**Goal**: last-minute banner, then "المهلة خلصت" with the place released.

**Independent Test**: `holdMinutes` = 1 in the settings inspector; enter payment and wait; booking `EXPIRED`, slot free for another account.

- [ ] T037 [P] [US3] `test/features/booking/presentation/checkout/checkout_screen_expiry_test.dart` and `test/acceptance/us10_hold_expired_test.dart` (fake async): last-minute style and seconds wording below 60 s (announced once), expired view from holding, failed and cancelled states, "اختيار ميعاد تاني" opens the schedule without selection, "الرجوع للرئيسية" goes home; app resumed after expiry shows expired; resize, theme and locale change keep the same expiry.
- [ ] T038 [US3] `expired_view.dart` in `lib/features/booking/presentation/checkout/`: `AdaptiveAppBar` "ملخص الحجز", hourglass icon in a `warning-soft` circle (decorative), "المهلة خلصت" (assertive live region, focus moves to it), body, booking card with `StatusBadge` expired "انتهت المهلة", primary "اختيار ميعاد تاني" and ghost "الرجوع للرئيسية". Wire the `expired` branch; make sure `holdHousekeepingProvider` is watched by the app shell so expiry also happens off-screen.

---

## Phase 6: User Story 5 - Leave payment, or cancel on the provider page (Priority: P1)

**Goal**: BR-47 on every platform.

**Independent Test**: back by button, gesture and browser on payment; each dialog choice; cancel on the provider page.

- [ ] T039 [P] [US5] `test/features/booking/presentation/checkout/leave_checkout_test.dart`: app-bar back and `Navigator.maybePop` open "ترك الدفع؟" in holding, failed and cancelled states; "ترك الدفع" → booking `EXPIRED`, location `summary?<selection>` with the same selection; "إكمال الدفع" → unchanged; processing absorbs back with no dialog; fake page back and "إلغاء" → payment `cancelled`, banner "الدفع اتلغى · المكان لسه متحجز لك، وممكن تحاول تاني", same countdown, "الدفع" starts a new payment. Run under iOS and Android target platforms.
- [ ] T040 [US5] `leave_checkout_dialog.dart` (via `AdaptiveDialog`, destructive "ترك الدفع", default "إكمال الدفع") and `PopScope` + app-bar back wiring in `checkout_screen.dart` (R7); `leaveCheckout` then `go` to the summary built from the booking (`ScheduleSelection` from booking unit/time/trainer). Fake page back and "إلغاء" call `FakeGatewayController.cancel` then pop; `cancelled` branch shows the info banner above the holding layout.

---

## Phase 7: User Story 4 - Confirmation is slow, and the Hold waits for the provider (Priority: P1)

**Goal**: processing → awaiting, extended Hold, late outcome or automatic refund.

**Independent Test**: outcome تأخير 30 s and "بعد الحد الأقصى" with `holdMinutes` 1 / `holdMaxMinutes` 2.

- [ ] T041 [P] [US4] `test/features/booking/presentation/checkout/checkout_screen_awaiting_test.dart` and `test/acceptance/us10_slow_confirmation_test.dart` (fake async): awaiting after 20 s; countdown jumps to `holdMaxExpiresAt` when the normal Hold is reached; "تحديث الحالة" calls `refreshPayment`; success within the maximum confirms; past the maximum → expired view, then late success → refund row and `payment.refunded_auto` record; "الرجوع للحجوزات" → `/bookings` and the outcome still applies in the background.
- [ ] T042 [US4] `awaiting_view.dart` in `lib/features/booking/presentation/checkout/`: "لسه مستنيين تأكيد الدفع", body, booking card with pending badge, primary "تحديث الحالة" (`refreshPayment`, shows a short loading state on the button), ghost "الرجوع للحجوزات"; back allowed (to bookings). Wire the `awaiting` branch using `processingSince` from the latest payment's `startedAt` (or the moment the page returned, whichever is later).

---

## Phase 8: User Story 6 - Keep a receipt (Priority: P2)

**Goal**: receipt screen, on-device PDF, text share fallback.

**Independent Test**: confirmed paid booking → receipt → PDF save/share; forced generation failure → text share.

- [ ] T043 [P] [US6] `test/features/payments/presentation/receipt_screen_test.dart` and `test/features/payments/presentation/receipt_pdf_test.dart`: every row, LTR codes, test tag; free booking or no `succeeded` payment → not found; PDF bytes non-empty with Arabic text; injected generator failure → text share called with a message; share text has no more than four card digits.
- [ ] T044 [US6] `lib/features/payments/presentation/receipt/receipt_pdf.dart`: build the PDF with the `pdf` package, RTL, embedded `assets/fonts/Cairo-Regular.ttf` and `Cairo-Bold.ttf` (Arabic shaping), same rows as the screen; generator behind a small injectable function for tests.
- [ ] T045 [US6] `lib/features/payments/presentation/receipt/receipt_screen.dart`: `AdaptiveAppBar` "الإيصال" with back to confirmation, "إيصال دفع" and rows (method "بطاقة تنتهي بـ {last4} · اختبار"), primary "حفظ الإيصال PDF" (`share_plus` `XFile.fromData`, download on web; fallback text share + message), ghost "مشاركة الإيصال" (text share, or copy + "اتنسخ" where share is unavailable). Build the localized receipt text here (`receipt_text.dart` in the same folder) from `Receipt` and the ARB keys; it contains at most the last four card digits. Wire the route from T023.

---

## Phase 9: User Story 7 - The demo can show success, failure and delay on demand (Priority: P2)

**Goal**: every branch recordable from `/demo`.

**Independent Test**: each outcome on `/demo` drives the matching screen; reset returns to success.

- [ ] T046 [P] [US7] `test/features/demo/demo_payment_section_test.dart`: section visible with demo tools, hidden with `HIDE_DEMO_TOOLS`; choosing نجاح/فشل/تأخير and a delay preset (5 s, 30 s, 90 s, "بعد الحد الأقصى" = resolved `holdMaxMinutes` + 1 min) updates `FakeGatewayController.outcome` and persists in the snapshot; reset → نجاح.
- [ ] T047 [US7] "الدفع التجريبي" section in `lib/features/demo/presentation/demo_screen.dart` (segmented choice through the existing `OptionGroup`, delay presets, current choice shown in words), reading and writing `fakeGatewayProvider`; shown only when `paymentProvider` is `fake`.

---

## Phase 10: User Story 8 - Free bookings get the same ticket (Priority: P2)

**Goal**: BR-19 bookings land on the confirmation ticket.

**Independent Test**: book a free range; ticket with QR, "السعر · مجاني", no receipt entry, `booking.confirmed` record.

- [ ] T048 [P] [US8] Update `test/acceptance/us08_free_range_test.dart` to end on `BookingConfirmedScreen` with "مجاني" and no receipt row; add a widget case in `booking_confirmed_screen_test.dart`.
- [ ] T049 [US8] Point the free path in `booking_summary_screen.dart` to `bookingConfirmed`, and the price row in `booking_confirmed_screen.dart` to "السعر · مجاني" when `priceAtBooking == 0`.

---

## Phase 11: User Story 9 - It works on every screen, language and theme (Priority: P2)

**Goal**: adaptive layouts, platform behaviour, accessibility.

**Independent Test**: the quickstart walk on every window class, both languages and themes, text 200%, keyboard-only, a screen reader.

- [ ] T050 [P] [US9] `test/features/booking/presentation/checkout/checkout_matrix_test.dart`: checkout (holding, failed, cancelled, expired, processing, awaiting), fake page, confirmation (paid, free) and receipt at 390, 700, 1000 and 1440 widths × ar/en × light/dark: column structure per `design-pack/adaptive.md` (bottom bar on compact only, two columns from 600 for checkout, centred 480 for page/processing/awaiting/receipt, two confirmation columns from 840), no overflow at `textScaler` 2.0 (including the 260 summary column), QR dark on white in both themes.
- [ ] T051 [P] [US9] `test/features/booking/presentation/checkout/checkout_semantics_test.dart`: countdown announcements every 30 s and once at the last minute (not every second), failure and expiry titles announced once, pay button label with the full amount, booking code read character by character, QR label "رمز الحضور، اعرضه للمدرب", focus order and visible focus ring with keyboard on web; reduced motion → no animation, numbers still update.
- [ ] T052 [US9] Fix whatever T050 and T051 find in the checkout, gateway, confirmation and receipt widgets (wrapping with `Flexible`, never clipping; hinge split).
- [ ] T053 [P] [US9] `test/guards/no_card_data_test.dart`: after a full fake payment with a test card, the serialized snapshot, every `Payment`, every notification payload and captured `debugPrint` output contain no 12+ digit run, no expiry and no CVC (SC-006).

---

## Phase 12: Polish and release

- [ ] T054 [P] `specs/006-checkout-hold-payment/copy-review.md` like 005's: every new string, Arabic and English, checked against the copy rules and `design-pack/copy.md`; fix the ARB files where a string fails.
- [ ] T055 Run `flutter analyze`, `flutter test` (all guards) and `flutter build web --release --base-href /sprint-app/`; all must pass.
- [ ] T056 Walk `quickstart.md` rows 1–11 on web (compact, medium, wide; ar/en) and rows 1, 2, 4, 6 on one iOS and one Android target where available; record SC-001 (time to ticket), SC-002 (every branch), SC-005 (countdown drift after background) and what was not checked in `evidence.md`. Browser back on web (spec Story 5, scenario 1) is checked by hand here only; record it explicitly.
- [ ] T057 Prepare the pull request description against `develop` (do not push or open it until Osman says so): BRD IDs (FR-BKG-04, FR-BKG-05, FR-PAY-01 – FR-PAY-03, FR-MYB-01, FR-NTF-01; US-06 paid, US-07 paid, US-10, US-11, US-12; BR-11 – BR-13, BR-16, BR-17, BR-19, BR-28 – BR-31, BR-33, BR-39, BR-46, BR-47), the out-of-scope list, the decision `PaymentStatus.cancelled` (R1), the `PaymentProvider` additions and the removed `pay()` (plan Complexity Tracking), the new `pdf` package, and the evidence file.

---

## Dependencies and execution order

- **Phase 1** first. **Phase 2** blocks every story. Inside it: T004 – T009 data model before T010 – T016; T010 → T011; T012 → T013; T014 → T015 → T016 (needs T004, T005, T006, T007, T009, T011, T013); T017 after T016; T019 before any screen; T021 needs T015; T022 needs T016 and T021; T023 needs T022; T025 needs T019 and T024.
- **US1** needs Phase 2. **US2**, **US3**, **US5** each need US1's `checkout_screen.dart` (T031) and the fake page (T032). **US4** needs US1 (T033). **US6** needs US1 (T034). **US7** needs T013 and T017 only, so it can start right after Phase 2. **US8** needs T034. **US9** needs US1 – US6 and US8.
- US2, US3 and US5 all edit `checkout_screen.dart`, so their implementation tasks go one after another even with several people; their test tasks can be written in parallel.
- **Phase 12** is last.

### Parallel examples

- Phase 2: T005, T006, T008, T018, T020, T024 together; T010 and T012 (tests) together.
- US1: T026 – T029 (tests) together; then T032 and T034 side by side while T030 → T031 → T033 go in order.
- After US1: US7 (T046, T047) and US6 (T043 – T045) can run beside US2/US3/US5.
- US9: T050, T051 and T053 together, then T052.

## Implementation strategy

- **MVP**: Phase 1, Phase 2 and US1: a paid booking from the summary to the ticket with the fake provider succeeding, replacing "قريبًا". Add US7 early (small) so every later branch can be shown on demand.
- **P1 completion**: US2 (failure), US3 (expiry), US5 (leave/cancel), US4 (slow confirmation and refund). After these, every branch of BR-12, BR-28, BR-46 and BR-47 is recordable, which is what the defense video needs (decisions 2026-11-16).
- **Then**: US8 (free ticket), US6 (receipt), US9 (matrix and accessibility), Phase 12.
- Keep each commit small and green: one task, one commit, BRD IDs in the message. No push without Osman.
