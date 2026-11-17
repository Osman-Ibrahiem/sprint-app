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

## Manual walk (T056): NOT DONE

Not run in this session (no device, and no interactive browser walk of the release build). What stands in
for each quickstart row is automated:

| Row | Covered by |
| --- | --- |
| 1 pay, ticket, receipt, PDF | `us06_paid_confirm_test`, `us12_confirmation_test`, `receipt_screen_test`, `receipt_pdf_test` |
| 2 failure and retry | `us10_payment_failed_test`, `checkout_screen_failed_test` |
| 3 cancel on the provider page | `leave_checkout_test` |
| 4 leave (button, system back) on iOS and Android targets | `leave_checkout_test` (browser back through the same `PopScope`, not checked in a real browser) |
| 5 one-minute Hold | `us10_hold_expired_test`, `checkout_screen_expiry_test` |
| 6, 7 slow confirmation, past the maximum, refund | `checkout_screen_awaiting_test`, `checkout_flow_test` |
| 8 free booking | `us08_free_range_test`, `booking_confirmed_screen_test` |
| 9 two accounts | `checkout_flow_test` (k), `us06_paid_confirm_test` |
| 10 sizes, languages, themes, 200% | `checkout_matrix_test` |
| 11 browser refresh | `router` tests for the unknown session; the state is derived from stored data (FR-024) |

Still to do by hand: SC-001 (time to ticket), SC-005 (countdown drift after real backgrounding), browser back
on the web (spec Story 5, scenario 1), the iOS and Android native back gestures, the PDF save/share sheet on a
device, and a look at the screens against Figma.

## Pull request description (T057), not opened

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

**Not verified**: the manual device and browser walk above.

Evidence: `specs/006-checkout-hold-payment/evidence.md`. CLAUDE.md "Current state" is updated in a separate docs PR after the merge.
