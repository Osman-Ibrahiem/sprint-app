# Contract: Repositories, rule services and PaymentProvider

**Spec**: FR-021 – FR-026 | **Plan**: [../plan.md](../plan.md)

These are the boundaries presentation code may use. Signatures are Dart-style sketches; the
final names are set in implementation but the shape and rules are the contract. All methods are
`Future`-returning (the real backend is asynchronous), take no platform types, and return
typed failures instead of throwing for expected business refusals.

## Result and failure types

```dart
sealed class Result<T> { Ok<T>(value) | Err<T>(Failure failure) }

sealed class Failure {
  SlotTaken, SlotFull, SlotPast, OutsideWindow, ClosedSlot, RangeTooLong,
  OverlapsOwnBooking, TooManyActiveBookings, HoldExpired,
  InvalidTransition, CancellationClosed, NotPermitted,
  InvalidSetting(key, reason), NotFound, Conflict(details)
}
```

## Repositories

| Interface | Operations | Notes |
| --- | --- | --- |
| `SettingsRepository` | `resolve<T>(SettingKey<T>, {unitId?, facilityId?})`, `set<T>(key, value, scope)`, `clear(key, scope)`, `watch(key, scope)` | `resolve` walks unit → facility → university → default. `set` validates type, range, allowed scopes (data-model registry) and writes an `AuditLog` entry |
| `CatalogueRepository` | `listOwningUnits`, `listFacilities({type?, owningUnitId?, free?})`, `getFacility`, `listUnits(facilityId)`, `hours(ownerId)`, `closures(scope)`, `prices(unitId)`, `trainers(facilityId)`, `offers(scope)` | Unpublished facilities are hidden unless the caller has a manager role |
| `AvailabilityRepository` | `slots(unitId, from, to, {trainerId?})` → slots with state and remaining places | Backed by `AvailabilityService`; includes active holds |
| `BookingRepository` | `create(request)`, `get(id)`, `listForUser(userId, {upcoming?})`, `listForFacility(facilityId, range)`, `cancel(id, actor, reason?)`, `markAttendance(id, method, actor)`, `expireHolds()` | `create` is atomic: availability + conflict + pricing + hold in one step (BR-11). Free facilities confirm immediately (BR-19) |
| `PaymentRepository` | `payments(bookingId)`, `refunds(paymentId)` | Written by the booking flow through `PaymentProvider`, read by screens |
| `IdentityRepository` | `currentUser()`, `users()`, `setCurrentUser(id)` (demo only), `roleAssignments(userId)`, `verification(userId)` | No passwords or sessions in this feature |
| `NotificationRepository` | `list(userId)`, `markRead(id)`, `push(notification)` | Channel is `PUSH` only |
| `AttendanceRepository`, `AssetRepository`, `AuditLogRepository` | list/create/update per BRD §5 | In-memory only |

Every repository has: an interface in `domain/`, an in-memory implementation in `data/`, and a
Riverpod provider that screens read. Swapping the provider's implementation is the only change
needed for a real backend (FR-026).

## Rule services (pure functions, no I/O)

`AvailabilityService`, `ConflictChecker`, `PricingService`, `HoldPolicy`, `CancellationPolicy`,
`PermissionChecker`: inputs and rules are in [../data-model.md](../data-model.md). Contract: same
input always gives same output; "now" is a parameter or an injected `Clock`; they import no
Flutter, Riverpod or storage code.

`PermissionChecker.can(user, Action, Scope)` is the single permission entry point. Screens and
repositories both call it; screens use it to hide or disable, repositories to refuse.

## PaymentProvider

```dart
abstract interface class PaymentProvider {
  Future<PaymentSession> start(PaymentRequest request);   // amount, bookingId, owningUnitId
  Stream<PaymentStatus> watch(PaymentSession session);    // pending -> succeeded | failed
  Future<RefundResult> refund(Payment payment, Money amount);
}
```

- `FakePaymentProvider`: succeeds after a short delay; a test hook can force failure.
- The provider is chosen by the `paymentProvider` setting (`FAKE` now, `SANDBOX` when a gateway
  is picked, `UNIVERSITY` in P2). Booking code depends only on the interface (BR-29, FR-025).
- The booking only becomes `CONFIRMED` from a provider status, never from the UI (BR-28).
- No card data is ever handled in this app (NFR-08).

## Behavioural guarantees checked by tests

1. Two concurrent `create` calls for the last place: exactly one succeeds.
2. `set` with an out-of-range or out-of-scope value is rejected and changes nothing.
3. `resolve` returns the closest scope's value for 8 combinations of defined/undefined scopes.
4. A guest can browse catalogue and availability; any write returns `NotPermitted`.
5. Booking `priceAtBooking` and `tierAtBooking` do not change when prices or verification change.
