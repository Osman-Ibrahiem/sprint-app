# Data Model: Checkout with Hold and Sandbox Payment

Changes to existing entities from `specs/001-foundation/` and `lib/features/{booking,payments,settings}/domain/`. All instants are UTC; display is Africa/Cairo.

## Booking (changed)

| Field | Type | Change | Rule |
| --- | --- | --- | --- |
| `holdExpiresAt` | `DateTime?` | now mutable by the repository | Set to `holdStartedAt + holdMinutes` at creation (BR-12); moved once to `holdMaxExpiresAt` when it is reached with a `pending` payment (BR-46); cleared on confirm. |
| `holdStartedAt` | `DateTime?` | **new** | Entry into payment = creation time of a paid booking. Null for free bookings. |
| `holdMaxExpiresAt` | `DateTime?` | **new** | `min(holdStartedAt + max(holdMaxMinutes, holdMinutes), start)`, frozen at creation (R4). |

Normal expiry is also capped at `start` (edge case "very late booking").

### State transitions

```
            create (paid)                     create (free, BR-19)
                 │                                   │
                 ▼                                   ▼
        PENDING_PAYMENT ── provider succeeded ──▶ CONFIRMED ──▶ ATTENDED / NO_SHOW / CANCELLED (features 7–8)
          │   │   ▲
          │   │   └─ provider failed / cancelled: stays PENDING_PAYMENT, Hold unchanged (US-10, BR-47),
          │   │      unless the Hold was extended and its normal expiry has passed → EXPIRED (BR-46, analyze H1)
          │   └── Hold reached, payment pending, before max: holdExpiresAt := holdMaxExpiresAt (BR-46)
          ▼
        EXPIRED  ◀── Hold reached with no pending payment (BR-12)
                 ◀── holdMaxExpiresAt reached with payment still pending (BR-46)
                 ◀── leaveCheckout ("ترك الدفع", BR-47)
```

`EXPIRED` is terminal. A provider `succeeded` arriving for an `EXPIRED` booking never confirms it: it refunds (R4).

`holdsPlace(now)` is unchanged in meaning: a `PENDING_PAYMENT` booking holds its place while `holdExpiresAt > now` (now including the extension).

## Payment (changed)

| Field | Type | Change | Rule |
| --- | --- | --- | --- |
| `id` | `String` | — | `pay-<sessionId>`; one row per attempt. |
| `bookingId`, `provider`, `providerRef`, `amount`, `owningUnitId` | — | — | `amount` = `Booking.priceAtBooking`; `owningUnitId` from the facility (BR-33). |
| `status` | `PaymentStatus` | **+ `cancelled`** | `pending` → `succeeded` \| `failed` \| `cancelled`. Only the provider moves it (BR-28). |
| `startedAt` | `DateTime` | **new** | When the provider page was opened. |
| `paidAt` | `DateTime?` | — | Set on `succeeded`. |
| `cardLast4` | `String?` | **new** | Reported by the provider with `succeeded`; the only card data ever stored (FR-009). |
| `receiptNumber` | `String?` | **new** | `RC-yyMMdd-NNNN` assigned on `succeeded` (FR-025). |

Invariants: at most one `pending` payment per booking (a new `startPayment` while one is pending returns the existing session); at most one `succeeded` payment per booking that stays `CONFIRMED`; any `succeeded` payment on a non-confirmed booking has exactly one `Refund` (SC-004).

## Refund (unchanged shape)

New reason value `late_confirmation` for BR-46 automatic refunds; amount = payment amount (100%).

## PaymentUpdate (new, provider value)

`{ status: PaymentStatus, cardLast4: String? }` — what `PaymentProvider.watch` and `status` yield.

## PaymentSession (changed)

`{ id, bookingId, checkoutLocation: Uri }` — `checkoutLocation` is `/pay/sandbox/<id>` for the fake.

## BookingCheckoutState (new, read model)

`{ booking: Booking, latestPayment: Payment?, refund: Refund? }` emitted by `BookingRepository.watchBooking`. The screen state is derived (pure function `checkoutViewOf(state, now, processingStartedAt)`):

| Booking | Latest payment | Derived view |
| --- | --- | --- |
| `PENDING_PAYMENT` | none | `holding` (or `lastMinute` when < 60 s) |
| `PENDING_PAYMENT` | `pending` | `processing` until the processing wait, then `awaiting` |
| `PENDING_PAYMENT` | `failed` | `failed` |
| `PENDING_PAYMENT` | `cancelled` | `cancelled` (banner) |
| `CONFIRMED` | `succeeded` | → confirmation route |
| `EXPIRED` | any | `expired` |
| other | — | not found |

## Receipt (derived, not stored)

`{ number, bookingCode, paidAt, facilityName, unitName, tier, methodLabel(cardLast4, isTest), amount }` from a `succeeded` payment and its booking. Rendered as PDF and as text.

## In-app notification (unchanged shape)

Types used: `booking.confirmed` (payload `code`), `payment.refunded_auto` (payload `code`, `amount`).

## Settings (one new key)

| Key | Default | Scopes | Range | Rule |
| --- | --- | --- | --- | --- |
| `holdMaxMinutes` | 20 | university, facility | 1–120 | BR-46 |

Read alongside the existing `holdMinutes`, `cancellationCutoffHours`, `refundPercent`, `reminderLeadMinutes`, `paymentProvider`.

## Demo state (fake only)

`FakeOutcome = succeed | fail | delay(Duration)`, default `succeed`, saved in the demo snapshot, reset with demo data. Snapshot `schemaVersion` 1 → 2.
