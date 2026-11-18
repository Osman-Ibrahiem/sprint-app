- `pdf` 3.13.1. It pulls `barcode`, which needs `qr` ^3, while the app used `qr` 4. A `dependency_overrides` entry did not compile (barcode calls the qr 3 API), so the app moved to `qr` ^3.0.2 instead: `SprintQrPainter` and the round-trip test now call `QrCode.fromData(data:, errorCorrectLevel: QrErrorCorrectLevel.M)`. The module matrix is the same (qr tests pass). Needs a mention in the PR.
- `flutter build web --release --base-href /sprint-app/` passes with the package added.

## Differences from the plan

Recorded so the review does not look for what is not there.

| Plan | What was built | Why |
| --- | --- | --- |
| `expiresOnAnswer(booking, now)` from `holdStartedAt`, `holdMinutes` and `holdMaxExpiresAt` | `Booking.holdExtendedAt` (new, nullable): the extension stores the normal expiry it replaced; `expiresOnAnswer` is "extended and `now` is at or after that instant" | The booking does not carry `holdMinutes` (settings are frozen by the two stored instants), so a Hold with `holdMaxMinutes` below `holdMinutes` could not be told from an extended one. One extra stored field, no setting read |
| `PaymentProvider` gains `status()`, `PaymentUpdate`, `checkoutLocation` | also `PaymentSession sessionFor(Payment)` | A payment still pending after a restart (snapshot restore) must be watched again without the repository knowing the fake's URL scheme (FR-024) |
| Checkout "inside the facility pane like 005" (contracts/routes.md, plan R12) | Checkout fills the content area; `/facilities/:id/schedule/checkout/:bookingId` is a sibling of the schedule route, not its child | Two columns of 372 + 260 cannot fit beside the facility list from 600 (design-pack adaptive.md shows them beside the rail only), and as a child route the schedule stayed alive beneath checkout and rewrote the address when its own Hold made the place look taken. Compact is unchanged (full screen either way) |
| `FakeGatewayController.session(id)` view with a facility label | amount, booking id and "settled" only | The page reads the facility name from the booking (`checkoutSummary`), so the fake never knows catalogue data |
| `holdHousekeepingProvider` as a 1 s ticker | one timer armed for the earliest Hold of the signed-in person, re-armed after every change | Same effect (Holds expire and extend on time, off the checkout screen too) without polling; no timer exists when nothing is pending |
| Receipt "Cairo regular and bold embedded in the PDF" | done; the PDF also needed named print metrics (`SprintExtras.receiptPdf*`) | The source-scan guard bans numeric sizes in `lib/` |
| `pdf` added alone | `qr` moved from 4.x to 3.0.2 | `pdf` pulls `barcode`, which needs `qr` ^3 (and a `dependency_overrides` entry does not compile). `QrCode.fromData(data:, errorCorrectLevel: M)` replaces the 4.x constructor in `SprintQrPainter` and its test; the module matrix is unchanged |
| `ticketCancelUntil` unchanged | text now "الإلغاء متاح لحد {date}" (copy.md) | "إلغاء مجاني" was wrong whenever `refundPercent` is under 100 |
| QR label "رمز الحضور، اعرضه للمدرب" (T051) | "رمز الحضور، بيتعرض للمدرب عند الدخول" (`ticketQrLabel`) | The task's wording is an imperative; copy rules forbid imperatives |
| `BookingTicket` reused "as is" | two additive parameters/changes: optional `priceLabel` ("السعر" with "مجاني" for a free booking) and a labelled QR node | US-8 shows "السعر · مجاني" and T051 needs the QR to be reachable by a reader |
| Seed: a paid and a free confirmed booking | both are the internal booker's, a week out (day +6), with `SP-10xx` codes; every seeded succeeded payment now has a receipt number | They must not overlap a booking made while trying the schedule (BR-13); receipts need numbers |

## Matrix findings fixed (US9)

- The booking card on the processing, awaiting and expired states overflowed at 200% text: name and badge
  now sit in a `Wrap`.
- The two confirmation columns (358 + 48 + 358) overflowed in the pane that a sidebar leaves (about 720 at
  a 1000 window): they now need a pane of at least 812 (`SprintExtras.confirmationTwoColumnsMinWidth`) and
  otherwise stack in the centred column.
- The Hold banner's live region was a zero-size node, which screen readers can drop: the banner itself is the
  live region now, with its words hidden and one spoken sentence that changes every 30 seconds and once in the
  last minute.
- Found while writing the tests: a countdown that asked the repository to apply the Hold rule on every
  rebuild could loop if the two clocks disagreed; it now asks once per expiry instant.

## Final checks (T055)

- Date: 2026-11-18. `flutter analyze`: no issues. `flutter test`: **1992 tests passed** (1750 at the baseline, 242 new).
  `flutter build web --release --base-href /sprint-app/`: built.
- Guards green: payments domain pure, no booking import of the fake, only the provider page and `/demo` read
  `fakeGatewayProvider`, no card data (`no_card_data_test.dart`), source scan, raw icon, ARB parity.
- Matrix (`checkout_matrix_test.dart`): 4 widths x ar light / en dark x text 1 and 2, over checkout (holding,
  cancelled, failed, expired), provider page, processing, awaiting, paid and free ticket, receipt: no overflow.
- The receipt PDF was rendered once with `pdftoppm` to look at it: Arabic shaped and right to left, rows and
  total in place.

## Manual walk (T056): web, partly done, 5 defects found and fixed

2026-11-18, web release build (`flutter build web --release`, hash routes) served locally, in the in-app
browser at 1024 px (expanded, sidebar) and 375 px (compact), Arabic, dark, signed in as the seeded internal
booker. No iOS or Android device.

| Row | Result |
| --- | --- |
| 1 pay, ticket, receipt | Passes, except D1 (wrong time on the ticket) and D2 (see row 11). Receipt rows correct (RC number, code, paid time, last four, test tag); PDF save not pressed (it downloads a file; the session rendered it with `pdftoppm`) |
| 2 failure and retry | Passes: "الدفع ماتمّش. ممكن تحاول تاني", Hold keeps counting, retry opens the provider page |
| 3 cancel on the provider page | Passes: "الدفع اتلغى", same countdown |
| 4 leave by the app bar back | Passes on 1024 and 375: "ترك الدفع؟", "ترك الدفع" goes to the summary. Once (failed, retried, cancelled, reloaded) the back button showed its tooltip and opened nothing; not reproduced in three later tries. Browser back not confirmed (the history step stayed on the same address) |
| 5 one-minute Hold | Not walked (needs the settings inspector); automated only |
| 6 slow confirmation (30 s) | Passes: "بنأكد الدفع", "لسه مستنيين تأكيد الدفع" after 20 s, then the ticket |
| 7 past the maximum, refund | Not walked; automated only |
| 8 free booking | Same confirmation screen, "السعر · مجاني", no receipt; D1 and D4 |
| 9 two accounts | Not walked; automated only |
| 10 sizes | Compact (375) and expanded (1024) checkout and ticket laid out correctly; English, light, medium, large and 200% text not walked by hand |
| 11 refresh | Payment screen (holding, cancelled) keeps its state and countdown. Refresh on the provider page: D2 |

### Defects

- **D1 (high, 006): the ticket shows UTC times.** Booked 11:00, 7:00 م and 2:00 م; the tickets show 9:00, 5:00 and
  12:00. `booking_confirmed_screen.dart` passes the stored UTC `b.start`/`b.end` to `BookingTicket`, whose
  `SprintFormat.dateTimeLine`/`timeRange` expect Cairo wall times (the schedule passes `CairoTime.toCairo`). The
  day name and date can also be wrong near midnight. Tests did not catch it.
- **D2 (high, 006): a refresh confirms an unconfirmed payment.** Opened the provider page, left the card fields
  empty, refreshed: the booking became `CONFIRMED` with a receipt and last four `4242`.
  `FakeGatewayController._ensure` answers an unknown session (after restart) with the current demo outcome and a
  made-up card. Expected: the session comes back pending and the provider page asks for the card again.
- **D3 (medium, 006): amounts read backwards.** "20 ج.م" is wrapped in `LtrIsolate` on the provider page and on
  the receipt total, so it shows "ج.م 20". Isolates are for codes, phone numbers and emails only.
- **D4 (medium, 006): a free ticket says "الإلغاء مش متاح".** The free summary says cancellation is available up to
  the cutoff, but the confirmation passes `cancelUntil: null` for every free booking.
- **D5 (medium, spec gap): the payment screen's cancellation policy can name a past time.** Booking at 10:38 for
  11:00 shows "الإلغاء متاح لحد ... 7:00 ص". The ticket handles a passed cutoff; the policy card does not.

### Fixes (2026-11-18), checked again on the web build

| Defect | Fix | Test (fails on the old code) | Re-walk |
| --- | --- | --- | --- |
| D1 | `BookingConfirmedScreen` passes `CairoTime.toCairo(start/end)` to `BookingTicket` | `booking_confirmed_screen_test`: Cairo time, not UTC | 1:00 م booking shows 1:00 – 2:00 م; free 4:00 م shows 4:00 – 5:00 م |
| D2 | `FakeGatewayController` keeps the sessions the page confirmed (id and last four) in the demo snapshot (`gatewayConfirmed`). After a restart a confirmed session is answered by the outcome; an unknown, unconfirmed one is a cancel (BR-47) | `checkout_flow_test` (q), (r); `fake_payment_provider_test` (two cases) | Refresh on the provider page with empty fields: "الدفع اتلغى", Hold running, no receipt. Refresh while confirming a 30 s delay: still "بنأكد الدفع", then confirmed |
| D3 | No `LtrIsolate` around the amount on the provider page or the receipt total | `fake_gateway_screen_test`, `receipt_screen_test` | "20 ج.م" on both |
| D4 | The free ticket names the cancellation time like a paid one | `booking_confirmed_screen_test`: free before the cutoff | "الإلغاء متاح لحد الخميس 19 نوفمبر 2:00 م" |
| D5 | `CheckoutPolicyCard` takes `now` and says "الإلغاء مش متاح" once the cutoff has passed (Osman's choice; spec edge case updated) | `shared_pieces_test`: policy before and after the cutoff | Booking at 11:01 for 1:00 م: "الإلغاء مش متاح" |

`flutter analyze`: no issues. `flutter test`: 1997 passed. `flutter build web --release`: built.

### Older than 006 (not part of this PR)

- `web/index.html` sets `dir="rtl"` on `<html>`. With Flutter's semantics on, every semantics node sits one
  viewport width to the right (x ≈ 2400 in a 1024 window), so a screen reader on web focuses nodes off screen
  and text fields do not take input. Since 2026-11-15 (`fa5154f`).
- "حجوزاتي" (feature 7 placeholder) says "تسجيل الدخول مطلوب" to a signed-in person.

### Notes

- The failed state titles both the app bar and the column "ملخص الحجز" instead of "الدفع" (copy question, not a defect).
- `/demo` repeats "الدفع التجريبي" as the section title and the group label.
- The provider page does not change the address (`/pay/sandbox/:sessionId` never shows).

Still not checked: iOS and Android (native back, PDF share sheet), SC-001 and SC-005 by hand, rows 5, 7 and 9,
English, light, 200% text, browser back.

## Pull request description (T057)

**Title**: feat(006): checkout with Hold, sandbox payment, confirmation ticket

Replaces 005's "قريبًا" checkout. "متابعة للدفع" creates the booking `PENDING_PAYMENT` with a Hold; the booker
pays on a simulated provider page owned by the fake provider; only the provider's status confirms (BR-28).

**Covers**: FR-BKG-04, FR-BKG-05, FR-PAY-01 – FR-PAY-03, FR-MYB-01, FR-NTF-01; US-06 paid, US-07 paid, US-10,
US-11, US-12; BR-11 – BR-13, BR-16, BR-17, BR-19, BR-28 – BR-31, BR-33, BR-39, BR-46, BR-47.

**What it does**
- Checkout screen with every state derived from the booking and its latest payment: holding, last minute,
  processing, awaiting, failed, cancelled, expired. Leaving asks first (BR-47); a cancel on the provider page
  is not a failure.
- Hold extension to `holdMaxMinutes` (new setting, default 20) while a payment is pending; a late success on a
  booking that is no longer pending is refunded 100% automatically and never re-confirms (BR-46).
- Confirmation ticket for paid and free bookings, receipt screen with an on-device PDF (Cairo, Arabic shaping)
  and a text fallback.
- `/demo` "الدفع التجريبي": success, failure or delay on demand, saved in the snapshot (schema version 2).

**Decisions and changes to review**
- `PaymentStatus.cancelled` (research R1): every attempt keeps its row.
- `PaymentProvider`: `status()`, `PaymentUpdate`, `checkoutLocation`, `sessionFor(Payment)`; `BookingRepository.pay()`
  removed in favour of `startPayment`, `refreshPayment`, `leaveCheckout`, `watchBooking`.
- New package `pdf` 3.13.1; `qr` 4.x to 3.0.2 because of it (see Differences).
- `Booking.holdExtendedAt`, `ticketCancelUntil` wording, `BookingTicket.priceLabel` and a labelled QR.
- Checkout fills the content area instead of the facility pane (see Differences).

**Out of scope**: backend, real payments, SMS, push, Lottie moments and add to calendar (feature 11), P2.

**Hand walk on web (T056, partly)**: rows 1–4, 6, 8, 11 walked at 1024 and 375 px in Arabic; five defects found and fixed with a test each (D1 UTC times on the ticket, D2 a refresh confirmed a payment the page never confirmed, D3 amounts read backwards, D4 free ticket cancel line, D5 a passed cutoff on the policy card), then re-walked.

**Not verified**: iOS and Android (native back, PDF share sheet); on web rows 5, 7, 9, English, light, 200% text and browser back.

**Older than 006, not changed here**: `dir="rtl"` on `<html>` in `web/index.html` moves Flutter's semantics tree off screen (screen readers on web); the "حجوزاتي" placeholder tells a signed-in person to sign in.

Evidence: `specs/006-checkout-hold-payment/evidence.md`. CLAUDE.md "Current state" is updated in a separate docs PR after the merge.
