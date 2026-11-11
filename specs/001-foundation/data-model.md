# Data Model: Foundation

**Feature**: 001-foundation | **Spec**: [spec.md](spec.md) | **BRD**: §4, §5, §6

Business-level model, not a final schema. Entities follow BRD §5; this document adds the
validation rules, state transitions and the settings registry that the in-memory layer enforces.
All instants are UTC `DateTime`; "calendar day", "slot start" and display use `Africa/Cairo`.
Ids are opaque strings. Entities are immutable (Freezed) and live in each feature's `domain/`.

## Entities and relationships

```text
OwningUnit 1─* Facility 1─* BookableUnit 1─* OperatingHours
                  │              │  └─* Closure, Price, Setting(unit scope)
                  │              └─* Booking *─1 User
                  ├─* Trainer *─* Facility      Trainer 1─* TrainerAvailability
                  ├─* Asset 1─* DamageReport
                  └─* Closure, Setting(facility scope), Offer
User 1─* RoleAssignment(role, scopeType, scopeId)      User 1─? Verification
Booking 1─* Payment 1─* Refund                         Booking 1─? Attendance
User 1─* Notification                                  Setting(university scope) = global
AuditLog records every administrative change
```

| Entity | Fields (beyond BRD §5 names) | Validation and rules |
| --- | --- | --- |
| `OwningUnit` | `id`, `name`, `type` (`FACULTY`/`CENTRAL`) | name required |
| `Facility` | `id`, `owningUnitId`, `name`, `type`, `description`, `photos`, `location`, `isFree`, `requiresTrainer`, `isPublished` | `isFree` and `requiresTrainer` define the three paths (BR-08, BR-09, BR-10); a free facility has no `Price`; unpublished facilities are hidden from guests |
| `BookableUnit` | `id`, `facilityId`, `name`, `isActive` | `bookingMode`, `capacity` and `maxParticipants` are NOT fields: they are unit-scoped settings (registry below) and are always read through `SettingsRepository.resolve`. Changing `bookingMode` or cutting `capacity` is refused when future bookings exceed the new value (BR-04) |
| `OperatingHours` | `ownerId` (unit or facility), `dayOfWeek`, `openTime`, `closeTime` | `openTime` < `closeTime`; times are Cairo wall-clock; no overlap within a day |
| `Closure` | `scope` (facility/unit), `scopeId`, `from`, `to`, `reason` | `from` < `to`; removes slots in range (BR-05) |
| `Price` | `unitId`, `tier`, `amount`, `currency` (`EGP`) | amount ≥ 0; one row per unit × tier; free facilities have none (BR-16, BR-19) |
| `Offer` | `scope`, `discountPercent`, `days`, `timeRange`, `tier?`, `validFrom`, `validTo` | 0 < discount ≤ 100 (BR-20) |
| `Trainer` / `TrainerAvailability` | per BRD | `trainerCapacity` ≥ 1; availability windows do not overlap (BR-09) |
| `User` | `id`, `name`, `phone`, `email`, `photo`, `nationalId?`, `tier`, `status` | The current user is `null` for a guest (the launch state); the demo switcher can select any seeded user. `tier` is derived from `Verification` and its expiry; default `EXTERNAL` (BR-21, BR-25); national id unique (BR-27) and shown masked |
| `Verification` | per BRD | `expiresAt` from `verificationExpiry`; rejected status requires `reason` (BR-26) |
| `RoleAssignment` | `userId`, `role`, `scopeType`, `scopeId?` | `UNIVERSITY` has no `scopeId`; others require it; a user may hold several |
| `Booking` | `id`, `code`, `userId`, `unitId`, `trainerId?`, `start`, `end`, `seats`, `tierAtBooking`, `priceAtBooking`, `status`, `qrToken`, `holdExpiresAt?`, `cancelledBy?`, `cancelReason?` | tier and price frozen at creation (BR-17); `seats` = 1 for `SHARED` and 1 for `EXCLUSIVE`; not transferable (BR-38) |
| `Payment` / `Refund` | per BRD, plus `owningUnitId` on payment | `amount` ≥ 0; refund ≤ paid amount (BR-31, BR-33) |
| `Attendance` | per BRD | method `QR`/`MANUAL`/`AUTO`; manual is flagged (BR-34) |
| `Notification` | `channel` = `PUSH` only in P1 | read/unread via `readAt` |
| `Asset` / `DamageReport` | per BRD | status sets per BR-42, BR-43 |
| `Setting` | `key`, `value`, `scopeType`, `scopeId?` | see registry below |
| `AuditLog` | `actorId`, `action`, `entity`, `entityId`, `before`, `after`, `at` | written on every administrative change |

`qrToken` is an opaque signed-looking string in the fake layer (NFR-07 is satisfied for real by
the backend later); it is never the raw booking code.

## Booking state machine (BRD §5)

```text
[create paid]  → PENDING_PAYMENT ─ pay ok ───────→ CONFIRMED
[create free]  ──────────────────────────────────→ CONFIRMED
PENDING_PAYMENT ─ pay failed or hold elapsed ────→ EXPIRED   (terminal)
CONFIRMED ─ check-in window + scan or manual ────→ ATTENDED  (terminal)
CONFIRMED ─ slot end with no attendance ─────────→ NO_SHOW   (terminal)
CONFIRMED ─ owner before cutoff, or admin ───────→ CANCELLED (terminal, refund)
```

Any other transition is rejected with a typed error. Refund happens only on `CANCELLED`:
owner cancel before `cancellationCutoffHours` pays `refundPercent`; admin cancel pays 100%
(BR-30 – BR-32). No penalty is ever applied for `NO_SHOW` (BR-37).

## Rule services (pure Dart, `domain/`)

| Service | Input → Output | Rules enforced |
| --- | --- | --- |
| `AvailabilityService` | unit, date range, bookings, hours, closures, settings → list of slots with state (`available`, `fewLeft`, `full`, `past`, `closed`) and remaining places | BR-05, BR-06 (window), BR-07 (past, lead time), BR-02/BR-03 (exclusive vs capacity), BR-08 (free ranges, `slotGranularityMinutes`, `maxRangeHours`), BR-09 (`sessionMinutes`, capacity = min(unit, trainer)) |
| `ConflictChecker` | proposed booking + existing bookings → ok or typed refusal | BR-11 (atomic check at creation), BR-13 (same user overlap, across facilities), BR-14 (`maxActiveBookingsPerUser`), BR-12 (active holds count as taken) |
| `PricingService` | unit, slot, user tier, offers → price and tier | BR-15 – BR-18, BR-19 (free = 0, no payment), BR-20 (best applicable offer) |
| `HoldPolicy` | now, booking → expired or not | BR-12 (`holdMinutes`) |
| `CancellationPolicy` | booking, now, actor → allowed + refund amount | BR-30 – BR-32, BR-40 flag (cancel offered only before cutoff) |
| `PermissionChecker` | user assignments, action, target scope → allow/deny | BRD §6 matrix (role × scope); `UNIVERSITY` covers all, `OWNING_UNIT` covers its facilities, `FACILITY` covers itself; guests only browse |

Services take `now` from the injected `Clock`; none reads the system time directly.

## Settings registry (BRD §4)

Setting keys are the only home of `bookingMode`, `capacity` and `maxParticipants`, so there is one source for each (constitution III).

Resolution: unit → facility → university → registry default. A value outside its allowed scopes
or failing validation is rejected by `SettingsRepository.set` with a typed error (spec edge case).
Changes apply to new bookings only; existing bookings keep their frozen values (BRD §4 intro).

| Key | Type | Default | Allowed scopes | Validation | BRD |
| --- | --- | --- | --- | --- | --- |
| `bookingMode` | enum `EXCLUSIVE`/`SHARED` | `SHARED` for lanes, `EXCLUSIVE` otherwise (seed sets per unit) | unit | change rule BR-04 | BR-01, §4.1 |
| `capacity` | int | none (seed) | unit | ≥ 1 | BR-03 |
| `maxParticipants` | int | none (seed) | unit | ≥ 1 | BR-02 |
| `bookingWindowDays` | int | 7 | university, facility, unit | 1 – 60 | BR-06 |
| `minLeadMinutes` | int | 0 | university, facility, unit | ≥ 0 | BR-07 |
| `slotGranularityMinutes` | int | 60 | university, facility | 15 – 240 | BR-08 |
| `maxRangeHours` | int | 3 | university, facility | 1 – 12 | BR-08 |
| `sessionMinutes` | int | 60 | university, facility | 15 – 240 | BR-09 |
| `holdMinutes` | int | 10 | university, facility | 1 – 60 | BR-12 |
| `maxActiveBookingsPerUser` | int? | null (no limit) | university | null or ≥ 1 | BR-14 |
| `cancellationCutoffHours` | int | 2 | university, facility, unit | ≥ 0 | BR-30 |
| `refundPercent` | int | 100 | university, facility, unit | 0 – 100 | BR-31 |
| `verificationExpiry` | month/day | 31 August | university | valid date | BR-25 |
| `checkInOpensMinutes` | int | 15 | university, facility | ≥ 0 | BR-35 |
| `reminderLeadMinutes` | int | 180 | university | ≥ 0 | BR-39 |
| `paymentProvider` | enum `FAKE`/`SANDBOX` | `FAKE` | university | known value | BR-29 |

Decided 2026-11-11: `reminderLeadMinutes` defaults to 180 so that, with `cancellationCutoffHours = 2`,
the reminder arrives before the cutoff and can offer cancel (BR-40).

## Seed data (placeholder until Dr. Sara's data arrives)

| Set | Content |
| --- | --- |
| Owning units (3) | كلية التربية الرياضية (faculty), كلية الهندسة (faculty), إدارة الأنشطة الرياضية (central) |
| Facilities (6) | حمام السباحة الأولمبي (paid, lanes `SHARED`); ملعب كرة القدم الخماسي (paid, `EXCLUSIVE`); صالة اللياقة البدنية (paid, `SHARED`); ملعب التنس (paid, `EXCLUSIVE`); الصالة المغطاة متعددة الأغراض (free, hour ranges); أكاديمية التدريب (with trainer) |
| Units (~15) | 6 lanes, 2 pitches, 1 gym floor, 2 courts, 2 halls, 2 trainer rooms |
| Prices | `INTERNAL` roughly 40–50% of `EXTERNAL`, in EGP, whole numbers |
| Hours | 8:00 ص – 10:00 م daily, hall closed on one weekday, one future closure |
| Trainers (3) | each with capacity and weekly availability |
| Users (10) | guest-ready sample plus one per role: booker internal, booker external, trainer, facility manager, verifier, unit admin, super admin, viewer, one unverified, one expired verification |
| Bookings (~20) | spread over every status, past and future, mixed tiers, one conflicting-capacity case at "full" |
| Other | 5 notifications, 4 assets with 1 damage report, 2 offers, a short audit log |

All names, phones and emails are fictional; no real person's data is used.

## As built (2026-11-11): choices the model left open

These are what the code does today. Where one is a judgement and not a BRD rule, it says so.

| Topic | As built |
| --- | --- |
| Slot length | `slotGranularityMinutes` (default 60) for normal and free facilities; `sessionMinutes` for trainer facilities. A last slot that would pass closing time is dropped |
| Hours | A unit's own hours replace its facility's hours for that unit. Times are Cairo wall-clock minutes; a day with no row is closed (the seed hall is closed on Fridays) |
| Booking window | `bookingWindowDays` counts today as day one: 7 means today and the next 6 days. Slots from the start of the day after that are not offered |
| Past and lead time | A slot is past when it starts at or before `now + minLeadMinutes` |
| "Few left" | A shared slot with capacity above 1 and 2 or fewer places left. A display hint held as a constant in `AvailabilityService`, **not a BRD setting** (judgement) |
| Closures | A closure removes every slot it overlaps; an inactive unit's slots come back as `closed` |
| What holds a place | `CONFIRMED`, `ATTENDED`, `NO_SHOW`, and `PENDING_PAYMENT` while its hold is live. Cancelled and expired bookings never do |
| Exclusive seats | A booking in an exclusive unit always takes 1 seat; shared bookings take the seats asked for |
| Trainer sessions | Remaining places are the smaller of the unit's and the trainer's, counting that trainer's own bookings |
| Active bookings (BR-14) | `CONFIRMED`, or pending with a live hold, and not yet ended |
| Price | Exclusive: the unit's price for the tier. Shared: price × seats. Best applicable offer by day, time-of-day of the slot start, tier and validity; the amount is rounded half up to whole pounds. An amount of 0 skips payment |
| Tier | `INTERNAL` only with an approved, unexpired verification, else `EXTERNAL`; read at booking time and frozen |
| Refund | Owner, before the cutoff: `paid × refundPercent ÷ 100`, rounded down. Admin: 100%, any time before the slot ends |
| BR-40 | With the defaults (reminder 180 minutes, cutoff 2 hours) a reminder arrives before the cutoff and offers cancel. Decided 2026-11-11 |
| BR-04 guard | Changing a unit's `bookingMode`, or cutting its `capacity` below the seats already booked in any future slot, is refused with `Conflict` |
| `paymentProvider` | `fake` and `sandbox` both resolve to the fake provider until a gateway is chosen |
| `capacity` default | 1, and `maxParticipants` empty, when a unit has no value (the seed sets real ones) |
| Seed | 3 owning units, 6 facilities, 15 units, 12 users (three trainers need accounts), 21 bookings in every status, 5 notifications, 4 assets with 1 damage report, 2 offers, 3 audit entries. Units `u-futsal-2`, `u-tennis-2`, `u-hall-2`, `u-room-2`, `u-pool-6` have no seeded bookings, so tests and demos can book them |
| Navigation sections | `AppSection` (home, facilities, bookings, profile, then trainer sessions, facility operations, verification, administration, reports) is computed from roles; only sections with a registered screen appear (today the first four) |
