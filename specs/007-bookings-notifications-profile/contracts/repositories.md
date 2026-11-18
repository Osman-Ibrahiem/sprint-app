# Contracts: repositories and pure services (feature 007)

Additive changes only; existing methods keep their meaning. Signatures are Dart sketches, not final code.

## BookingRepository (changed)

```dart
// existing: create, quote, get, listForUser, listForFacility, startPayment, refreshPayment,
//           leaveCheckout, watchBooking, cancel, markAttendance, expireHolds, markNoShows, changes
Future<Result<Booking>> cancel(String id, String actorUserId, {String? reason});
//   now also: owner + PENDING_PAYMENT (BR-48). Idempotent: a second call returns Ok(booking) already cancelled.
//   Owner cancel writes Notification(kind: bookingCancelledByOwner, readAt: now) in all cases.
//   Errors: NotFound, NotPermitted, CancellationClosed, InvalidTransition (e.g. payment being processed).

Future<Map<String, int>> bookedCounts({required DateTime since});
//   facilityId -> count of CONFIRMED and ATTENDED bookings with start >= since, all users.

Future<CancelPreview> previewCancel(String id, String actorUserId);
//   Same arguments as cancel() resolves; never mutates. The dialog calls it on open and cancel() re-checks.
```

## CancellationPolicy (changed, pure)

```dart
CancelPreview preview({required Booking booking, required DateTime now, required CancelledBy by,
    required int cutoffHours, required int refundPercent, required int paidAmount,
    required bool paymentPending});
Result<CancellationDecision> decide(...);   // calls preview(); unchanged signature plus paymentPending
bool canOfferCancel(Booking b, DateTime at, {required int cutoffHours});  // single "button shown" check
```

## NotificationRepository (changed)

```dart
Stream<void> get changes;
Future<List<Notification>> list(String userId);           // newest first (unchanged)
Future<void> markRead(String id, DateTime at);            // unchanged
Future<void> markAllRead(String userId, DateTime at);     // new
Future<void> push(Notification n);                        // now an upsert by id (reminders idempotent)
```

Unread count is derived: `list(userId).where(readAt == null).length` through a provider.

## ReminderPolicy and scheduler

```dart
// pure
List<Booking> ReminderPolicy.due({required List<Booking> bookings, required Set<String> existingReminderIds,
    required DateTime now, required int Function(Booking) leadMinutesFor});
// provider (keepAlive): runs on build, every 60 s, on resume; writes via NotificationRepository.push
Future<void> ReminderScheduler.forceReminder(String bookingId);   // /demo action: same record, no window check
```

## IdentityRepository (changed)

```dart
Future<Result<User>> updateProfile(String userId, {required String name, String? avatarId, bool clearAvatar = false});
//   name trimmed, >= 2 characters else Err(InvalidName); never touches email, phone, nationalId.
```

## Profile photo

```dart
Future<Result<String>> ProfilePhotoStore.save(String userId, Uint8List jpeg);  // returns avatarId; StorageFull on failure
Future<Uint8List?> ProfilePhotoStore.load(String avatarId);
Future<void> ProfilePhotoStore.delete(String avatarId);
```

## Search (pure) and device stores

```dart
List<FacilitySummary> FacilitySearch.filter(List<FacilitySummary> all, String query);
String ArabicNormalizer.normalize(String s);
RecentSearchesStore: List<String> read(); Future<void> add(String term); Future<void> clear();   // max 5
NotificationPermissionStore: Permission? read(); Future<void> write(Permission p);
```

## Errors

`Result<T>` and the existing `Failure` types are reused: `NotFound`, `NotPermitted`, `CancellationClosed`, `InvalidTransition`, `StorageFull`; new `InvalidName`.
