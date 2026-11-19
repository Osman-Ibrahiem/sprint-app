# Data Model: Feature 007

Only what changes. Everything else is as in `specs/001-foundation/data-model.md` and later features.

## Booking (changed)

| Field | Change | Notes |
| --- | --- | --- |
| `cancelledAt` | new, `DateTime?` (UTC) | set with `cancelledBy`; null for every other status |
| `cancelledBy` | existing `CancelledBy {owner, admin}` | `owner` now also set from `PENDING_PAYMENT` (BR-48) |
| `cancelReason` | existing | facility cancel reason shown on the details |

**Transitions** (additions in bold):

```text
PENDING_PAYMENT → CONFIRMED  (provider success)
PENDING_PAYMENT → EXPIRED    (Hold ended, BR-12 / BR-46 / BR-47)
PENDING_PAYMENT → CANCELLED  **(owner, while holding and no payment pending; no refund; BR-48)**
CONFIRMED → CANCELLED        (owner before the cutoff, BR-30; admin any time before end, BR-32)
CONFIRMED → ATTENDED | NO_SHOW
```

**Rules**: `cancel(by, reason, at)` from `confirmed` (owner, admin) or `pendingPayment` (owner). The repository, not the model, checks the cutoff, the pending payment and the Hold.

## CancelPreview (new, derived, pure)

| Field | Type | Meaning |
| --- | --- | --- |
| `kind` | `full` / `partial` / `none` / `free` / `closed` / `notAllowed` | what the dialog and the result say |
| `paidAmount` | int | sum of succeeded payments (0 for free or pending) |
| `refundAmount` | int | `paidAmount * refundPercent ~/ 100`; 0 for `none`, `free`, pending |
| `refundPercent` | int | the resolved setting |
| `cancelUntil` | `DateTime` | `start - cancellationCutoffHours` |

`free` when `priceAtBooking == 0`; `none` when paid and the percent is 0; `partial` when the percent is between 1 and 99; `full` at 100; `closed` after the cutoff; `notAllowed` for any other status or a payment being processed. A facility cancel always yields `full` (BR-32).

## Notification (changed)

| Field | Change |
| --- | --- |
| `type` | stays a string on the wire; read through `NotificationKind.fromWire` |
| `payload` | `bookingId` added next to `code` for booking kinds; `verificationId` and `reason` for verification kinds; `amount` for refund kinds |
| `readAt` | the "cancelled by me" record is written with `readAt = sentAt` |

**NotificationKind** (closed set): `bookingConfirmed` (`booking.confirmed`), `bookingReminder` (`booking.reminder`), `bookingCancelledByAdmin` (`booking.cancelled_by_admin`), `bookingCancelledByOwner` (`booking.cancelled_by_owner`, new), `paymentRefundedAuto` (`payment.refunded_auto`, from 006), `verificationPending`, `verificationApproved`, `verificationRejected`. Any other wire value maps to `unknown`, shown as a plain card without an action.

**Reminder record**: a `bookingReminder` notification with the deterministic id `rem-<bookingId>`; the id is its own idempotence key. No separate entity.

**Unread**: `readAt == null` for the signed-in user. The "cancelled by me" kind never counts.

## User (changed)

| Field | Change | Notes |
| --- | --- | --- |
| `avatarId` | new, `String?` | key in the photo store (`avatar-<userId>`); null shows the initial |
| `name` | editable here | at least 2 characters after trimming |
| `email`, `phone` | read-only here | still unique and validated by the auth repository |

## Device state (new, not in the snapshot)

| Key | Where | Shape |
| --- | --- | --- |
| `recentSearches` | `shared_preferences` | JSON list of up to 5 raw terms, newest first, deduplicated by normalised form |
| `notifPermission` | `shared_preferences` | `granted` / `denied` / absent (never asked) |

Both are cleared by the demo reset together with the data layer (not by sign out).

## Search (derived, pure)

- `FacilitySearch.filter(List<FacilitySummary>, String query)`: normalised substring match on name, type label and owning unit name; order: open today by `today.count` descending, then closed today, ties by normalised name.
- `SearchSuggestions`: `mostBooked` (two facility ids from `bookedCounts`, ties by name) and `recents`.

## Settings (no new keys)

`cancellationCutoffHours`, `refundPercent`, `reminderLeadMinutes`, `fewLeftThreshold` are read through `UnitSettings.resolve` or `SettingsRepository.resolve`. Presentation constants (not settings): reminder checker period 60 s, most-booked window 30 days, five recents, badge cap 99.

## Seed additions

- At least three confirmed bookings of the demo booker: one beyond the cutoff-plus-lead (cancellable with a reminder available on demand), one inside the cutoff (cancel closed), one paid with `refundPercent` demonstrable, and one free; plus past ones in each final status so every details variant is reachable.
- Confirmed and attended bookings across facilities in the last 30 days of the seed clock so "most booked" is not a tie.
- Notifications of every kind for the demo booker, some unread; the "cancelled by me" and refund kinds included.
