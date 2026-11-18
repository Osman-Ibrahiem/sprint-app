# Contract: Routes

Extends `specs/005-availability-booking/contracts/routes.md`. All are hash URLs on web (decisions 2026-11-11). All need an account; a guest goes to `/sign-in?from=<location>`. A booking that belongs to someone else shows `NoAccessScreen`.

| Name | Path | Screen | Notes |
| --- | --- | --- | --- |
| `bookingCheckout` | `/facilities/:id/schedule/checkout/:bookingId` | `CheckoutScreen` | State from the booking and payment (data-model `CheckoutView`). Inside the facility pane like 005. Replaces 005's `checkout?<selection>`; the old form redirects to `summary?<selection>`. |
| `fakeGateway` | `/pay/sandbox/:sessionId` | `FakeGatewayScreen` | Top-level, outside the shell. Unknown or finished session → back to the booking's checkout or confirmation. Back = cancel. Exists only when `paymentProvider` is `fake`. |
| `bookingConfirmed` | `/bookings/:bookingId/confirmed` | `BookingConfirmedScreen` | Under the "حجوزاتي" destination. A non-confirmed booking redirects to its checkout route (pending/expired) or not found. |
| `bookingReceipt` | `/bookings/:bookingId/receipt` | `ReceiptScreen` | Not found unless a `succeeded` payment exists and the booking is confirmed. |
| `bookingDone` (005) | `/facilities/:id/schedule/done/:bookingId` | — | Redirects to `bookingConfirmed`. |

Navigation:

- Summary "متابعة للدفع" (paid) → `create` → `go(bookingCheckout)`; free → `create` → `go(bookingConfirmed)`.
- Checkout "الدفع" / "إعادة المحاولة" → `startPayment` → `push(session.checkoutLocation)`.
- Fake page confirm/cancel → `pop()` back to checkout (state from the booking).
- Confirmed outcome on checkout → `go(bookingConfirmed)` (replaces; no back to payment).
- "ترك الدفع" → `leaveCheckout` → `go(summary?<selection from booking>)`.
- Expired "اختيار ميعاد تاني" → `go(/facilities/:id/schedule)` without selection; "الرجوع للرئيسية" → `go(/)`.
- Awaiting "الرجوع للحجوزات" → `go(/bookings)`.
- Confirmed "إيصال الدفع" → `push(bookingReceipt)`.
