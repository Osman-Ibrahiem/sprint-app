# Contract: Repositories and Provider

Interfaces the presentation layer and the future backend rely on. Signatures are Dart-shaped for clarity; `Result<T>` is the project's `Ok`/`Err`.

## PaymentProvider (`lib/features/payments/domain/payment_provider.dart`)

```dart
abstract interface class PaymentProvider {
  /// Opens a payment for [request]. The booker is sent to session.checkoutLocation.
  Future<PaymentSession> start(PaymentRequest request);

  /// pending, then exactly one of succeeded | failed | cancelled.
  Stream<PaymentUpdate> watch(PaymentSession session);

  /// Immediate read ("تحديث الحالة"). Never changes the payment.
  Future<PaymentUpdate> status(PaymentSession session);

  Future<RefundResult> refund(Payment payment, int amount);
}

class PaymentSession { String id; String bookingId; Uri checkoutLocation; }
class PaymentUpdate  { PaymentStatus status; String? cardLast4; }
enum PaymentStatus   { pending, succeeded, failed, cancelled }
```

`PaymentRequest` is unchanged (amount, bookingId, owningUnitId). No card data crosses this interface except `cardLast4` in a `succeeded` update.

## FakeGatewayController (fake only, `lib/features/payments/data/`)

```dart
class FakeGatewayController {
  FakeOutcome outcome;                  // succeed | fail | delay(Duration)
  void confirm(String sessionId, {required String cardLast4});
  void cancel(String sessionId);
  PaymentSessionView? session(String sessionId); // amount, bookingId, facility label for the page
}
```

Used only by `FakeGatewayScreen` and the `/demo` section. Booking code never imports it.

## BookingRepository (changed methods)

```dart
/// Paid: PENDING_PAYMENT with holdStartedAt, holdExpiresAt, holdMaxExpiresAt (BR-12, BR-46).
/// Free: CONFIRMED + booking.confirmed record (BR-19). Unchanged checks (BR-11, BR-13).
Future<Result<Booking>> create(BookingRequest request);

/// Owner only; booking PENDING_PAYMENT with a live Hold. If a pending payment exists,
/// returns its session instead of starting another.
/// Errors: NotFound, NotPermitted, InvalidTransition, HoldExpired, PaymentUnavailable.
Future<Result<PaymentSession>> startPayment(String bookingId, String userId);

/// Applies provider.status() for the latest pending payment. Errors: NotFound, NoPendingPayment.
Future<Result<BookingCheckoutState>> refreshPayment(String bookingId);

/// BR-47 "ترك الدفع": PENDING_PAYMENT → EXPIRED now. Owner only.
Future<Result<Booking>> leaveCheckout(String bookingId, String userId);

/// Booking + latest payment + refund, emitted on subscribe and after every write.
Stream<BookingCheckoutState> watchBooking(String bookingId);

/// BR-12 + BR-46: extend to holdMaxExpiresAt when a payment is pending, otherwise expire.
Future<int> expireHolds();
```

Removed: `pay(String id)` (one-shot, expired on failure). Its callers in tests move to `startPayment` + the fake controller.

Outcome handling (internal, `_applyOutcome`, the future webhook):

| Booking now | Update | Effect |
| --- | --- | --- |
| `PENDING_PAYMENT` | `succeeded` | payment succeeded (+ `paidAt`, `cardLast4`, `receiptNumber`); booking `CONFIRMED`; `booking.confirmed` record |
| `PENDING_PAYMENT` | `failed` | payment failed; booking unchanged |
| `PENDING_PAYMENT` | `cancelled` | payment cancelled; booking unchanged |
| not pending | `succeeded` | payment succeeded; `refund(payment, amount)`; `Refund(reason: late_confirmation)`; `payment.refunded_auto` record |
| not pending | `failed` / `cancelled` | payment updated; nothing else |

All writes go through the existing serial queue, so a concurrent `create` for the same place sees a live or extended Hold.

## PaymentRepository (additions)

```dart
Future<Payment?> latestPayment(String bookingId);
Future<String> nextReceiptNumber(DateTime paidAtCairo); // RC-yyMMdd-NNNN
```

## Riverpod providers (presentation)

| Provider | Kind | Gives |
| --- | --- | --- |
| `bookingCheckoutProvider(bookingId)` | stream | `BookingCheckoutState` from `watchBooking` |
| `checkoutViewProvider(bookingId)` | derived | `CheckoutView` (holding, lastMinute, processing, awaiting, failed, cancelled, expired, confirmed, notFound) |
| `holdCountdownProvider(bookingId)` | stream, 1 s | remaining `Duration` from `holdExpiresAt`; calls `expireHolds()` at zero |
| `checkoutSettingsProvider(bookingId)` | future | cutoff hours, refund percent, reminder lead, provider kind (test tag) |
| `receiptProvider(bookingId)` | future | `Receipt?` |
| `fakeGatewayProvider` | keep-alive | the `FakeGatewayController` (demo and fake page only) |
| `holdHousekeepingProvider` | keep-alive | 1 s ticker calling `expireHolds()` while the user has a pending booking |
