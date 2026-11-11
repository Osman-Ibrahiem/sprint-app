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
  InvalidTransition, CancellationClosed, CheckInClosed, NotPermitted,
  InvalidSetting(key, reason), NotFound(what?), Conflict(details)
}
```

## Repositories

| Interface | Operations | Notes |
| --- | --- | --- |
| `SettingsRepository` | `resolve<T>(SettingKey<T>, {unitId?, facilityId?})`, `resolveWithSource` (value plus the level it came from), `set<T>(key, value, scope, {actorId})`, `clear(key, scope, {actorId})`, `watch(key, {unitId?, facilityId?})` | `resolve` walks unit → facility → university → default. `set` validates type, range, allowed scopes (data-model registry), asks an optional change guard (BR-04) and writes an `AuditLog` entry. Rule services take a resolved snapshot, `UnitSettings`, built by `UnitSettings.resolve(repo, unitId, facilityId)` |
| `CatalogueRepository` | `listOwningUnits`, `listFacilities({type?, owningUnitId?, free?, includeUnpublished})`, `getFacility`, `listUnits(facilityId)`, `getUnit`, `hours(ownerId)`, `closures({facilityId?, unitId?})`, `prices(unitId)`, `trainers(facilityId)`, `trainerAvailability(trainerId, {unitId?})`, `offers({facilityId?, unitId?})` | Unpublished facilities are hidden unless `includeUnpublished` is set. Unit hours replace facility hours for that unit |
| `AvailabilityRepository` | `slots(unitId, from, to, {trainerId?})` → slots with state and remaining places | Backed by `AvailabilityService`; includes active holds. From the Cairo day of `from` to the Cairo day of `to`. A trainer facility returns nothing until a trainer is chosen |
| `BookingRepository` | `create(BookingRequest)`, `get(id)`, `listForUser(userId, {upcoming})`, `listForFacility(facilityId, {from?, to?})`, `pay(id)`, `cancel(id, actorUserId, {reason?})`, `markAttendance(id, method, actorUserId)`, `expireHolds()`, `markNoShows()` | `create` is atomic (all writes go through one serial queue): permission, availability, conflict, pricing and hold in one step (BR-11); a guest (`userId` null) gets `NotPermitted`. A free booking, or one that comes to 0, confirms at once (BR-19); a paid one is `PENDING_PAYMENT` with a hold until `pay`. `pay` runs `PaymentProvider` and only its answer confirms (BR-28); a failure expires the booking and still returns `Ok`. `cancel` by the owner follows the cutoff and refund percent, by an admin always 100% and notifies the owner (BR-32, BR-41). `markAttendance` needs `scanAttendance` and the window of BR-35 |
| `PaymentRepository` | `payments(bookingId)`, `refunds(paymentId)`, `savePayment`, `saveRefund` | Written by the booking flow through `PaymentProvider`, read by screens. Each payment carries its `owningUnitId` (BR-33) |
| `IdentityRepository` | `currentUser()`, `users()`, `getUser(id)`, `setCurrentUser(id?)` (demo only), `roleAssignments(userId)`, `verification(userId)` | No passwords or sessions in this feature. The app reads the current person through `sessionProvider` (user, roles, tier) |
| `NotificationRepository` | `list(userId)` (newest first), `markRead(id, at)`, `push(notification)` | Channel is `PUSH` only; `type` is a string such as `booking.confirmed` |
| `AttendanceRepository` (`forBooking`, `list`, `save`), `AssetRepository` (`assets(facilityId)`, `damageReports`, `saveAsset`, `saveDamageReport`), `AuditLogRepository` (`append`, `list`) | per BRD §5 | In-memory only |

Every repository has: an interface in `domain/`, an in-memory implementation in `data/`, and a
Riverpod provider that screens read. Swapping the provider's implementation is the only change
needed for a real backend (FR-026).

## Rule services (pure functions, no I/O)

`AvailabilityService`, `ConflictChecker`, `PricingService`, `HoldPolicy`, `CancellationPolicy`,
`PermissionChecker`: inputs and rules are in [../data-model.md](../data-model.md). Contract: same
input always gives same output; "now" is a parameter or an injected `Clock`; they import no
Flutter, Riverpod or storage code.

`PermissionChecker.can(PermissionSubject, AppAction, PermissionTarget)` is the single permission
entry point. The subject is a user id plus role assignments (`PermissionSubject.guest` has none);
the target names the owning unit, the facility and, for trainer sessions, the trainer's user id.
Screens and repositories both call it; screens use it to hide or disable, repositories to refuse.
Any signed-in user may `book` and `requestVerification`; trainers reach `scanAttendance`,
`viewFacilityBookings` and `viewReports` only for their own sessions.

## PaymentProvider

```dart
abstract interface class PaymentProvider {
  Future<PaymentSession> start(PaymentRequest request);   // amount (whole EGP), bookingId, owningUnitId
  Stream<PaymentStatus> watch(PaymentSession session);    // pending -> succeeded | failed
  Future<RefundResult> refund(Payment payment, int amount); // succeeded is false above the paid amount
}
```

- `FakePaymentProvider`: succeeds after a short delay (600 ms by default); `failNext` forces the next payment to fail once.
- The provider is chosen by the `paymentProvider` setting (`fake` now; `sandbox` resolves to the
  same fake until a gateway is picked; the university platform is P2). Booking code depends only on the interface (BR-29, FR-025).
- The booking only becomes `CONFIRMED` from a provider status, never from the UI (BR-28).
- No card data is ever handled in this app (NFR-08).

## Behavioural guarantees checked by tests

1. Two concurrent `create` calls for the last place: exactly one succeeds.
2. `set` with an out-of-range or out-of-scope value is rejected and changes nothing.
3. `resolve` returns the closest scope's value for 8 combinations of defined/undefined scopes.
4. A guest can browse catalogue and availability; any write returns `NotPermitted`.
5. Booking `priceAtBooking` and `tierAtBooking` do not change when prices or verification change.
