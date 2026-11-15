# Data Model: Design System Widgets

This feature adds no business entity and no repository. It adds **presentation value types** (what a
widget takes in) and one **setting**. All types live in `lib/core/widgets/<component>/` and are plain
Dart: no Flutter state, no `features/` imports, nothing read from a repository. Later features map
their domain entities onto them.

## The new setting

| Key | Type | Default | Scopes | Validation | Source |
| --- | --- | --- | --- | --- | --- |
| `fewLeftThreshold` | int | 2 | university, facility, unit (inheritance as the other settings) | at least 1 | BRD §4.2, new BR-45 (clarify 2026-11-15); `SlotChip` README |

Added to `SettingKeys` and `settingRegistry` (the only place the default 2 is written), to BRD §4.2 and
to the settings inspector (it lists the registry, so no inspector code changes). Meaning: a shared slot
whose remaining places are at or below the threshold is shown as "few left".

## Value types by widget

### SprintButton

| Type | Values / fields |
| --- | --- |
| `SprintButtonVariant` | `primary`, `secondary`, `tonal`, `ghost`, `danger` |
| `SprintButtonSize` | `md`, `sm` |
| `SprintButtonIcon` | `icon` (`IconData`), `position` (`start`, `end`), `mirrorInRtl` |

Inputs: `label`, `variant`, `size`, `icon?`, `loading`, `loadingLabel?`, `onPressed?` (null = disabled).

### SprintTextField

| Type | Values |
| --- | --- |
| `SprintTextFieldType` | `text`, `password`, `search`, `phone`, `email`, `nationalId` |

Inputs: `label` (required), `placeholder?`, `helper?`, `error?`, `type`, `controller?`, `enabled`,
`onChanged?`, `onLeave?` (the user left the field: when the caller validates), `onSubmitted?`.
`type` fixes the keyboard type, autofill hints and whether the text is left-to-right.

### SlotChip

| Type | Values / fields |
| --- | --- |
| `SlotState` | `available`, `selected`, `fewLeft`, `full`, `past` |

Inputs: `start` (Cairo-local `DateTime`), `state` (or the inputs for `resolveSlotState`: `remaining?`,
`fewLeftThreshold`, `isPast`, `isSelected`), `price?` (spoken only), `onSelected?`.

State rule (research R11), highest first: `past` → `full` (`remaining == 0` or explicit full) →
`selected` → `fewLeft` (`remaining` present and ≤ threshold) → `available`. A `full` or `past` chip
ignores presses. Words: available = "N أماكن" on a shared unit and none on an exclusive one; selected =
"مختار"; fewLeft = "فاضل N"; full = "مكتمل"; past = "فات".

### DayStrip

| Type | Fields |
| --- | --- |
| `DayStripDay` | `date` (Cairo-local, date only), `hasAvailability`, `isClosed` |

Inputs: `days` (the caller reads `bookingWindowDays`), `today`, `selected?`, `onSelected`.
`DayStrip.defaultSelection(days)` returns the first day with room, else the first open day. Rules the
caller must meet and the widget asserts in debug builds: days are consecutive, the first is `today`,
none is before `today`.

### StatusBadge

| Type | Values |
| --- | --- |
| `SprintStatus` | booking: `confirmed`, `pendingPayment`, `cancelled`, `attended`, `noShow`, `expired` · verification: `underReview`, `verified`, `rejected` · damage report: `open`, `inProgress`, `resolved` |

Each value is bound to exactly one word, one icon and one colour pair (contracts/widgets.md). Mapping a
domain status (for example `BookingStatus.CONFIRMED`) to `SprintStatus` is done by the feature that
shows it, not here, because `core/` cannot import `features/`.

### FacilityCard

| Type | Fields |
| --- | --- |
| `FacilityKind` | `paid`, `free`, `withTrainer` |
| `FacilityCardLayout` | `vertical`, `horizontal` |
| `AvailabilityLevel` | `plenty`, `few`, `none` (decided by the caller, spec Assumptions) |
| `FacilityPrice` | `amount?` (the one price shown), `audienceLabel?`, `externalAmount?` (guest sees both), `offerLabel?`, `oldAmount?` (struck through); `free` kinds carry none |
| `FacilityTag` | `label`, `kind` (`sport`, `trainer`, `free`, `offer`); at most three |

Inputs: `kind`, `layout`, `name`, `owningUnit`, `unitCount`, `tags`, `availability` (level + count),
`price`, `photo?` (an `ImageProvider`; null = the "صورة المنشأة" placeholder), `heroTag?`, `onTap`.

### BookingTicket

| Type | Fields |
| --- | --- |
| `BookingTicketState` | `upcoming`, `today`, `past` |

Inputs: `state`, `status` (`SprintStatus`), `facilityName`, `unitName`, `trainerName?`, `start`, `end`
(Cairo-local), `qrToken?`, `code`, `paid` (a display string from `SprintFormat.price`), `cancelUntil?`
(Cairo-local; null = "الإلغاء مش متاح"; the caller applies the cut-off setting), `onCodeCopied?`.
The QR is shown only when `state != past`, the status is not cancelled, and `qrToken` is non-empty.

### AppNavigation

| Type | Fields |
| --- | --- |
| `NavDestination` | `label`, `icon`, `selectedIcon`, `mirrorInRtl`, `badgeCount?` |
| `NavForm` | `tabBar`, `rail`, `sidebar` (derived from `WindowSize`; forced only by the gallery) |

Inputs: `destinations`, `selected`, `onSelected`, `form?`. The shell builds `NavDestination`s from the
Foundation's `ShellDestination` plus the localized label. Rules: at least two destinations (debug
assert); on the tab bar more than five collapse to four plus "المزيد".

### StatTile

| Type | Fields |
| --- | --- |
| `StatTrend` | `up`, `down`, `flat` |
| `StatDelta` | `trend`, `text` (for example "12%"), `comparison` (for example "عن الأسبوع اللي فات"), `higherIsBetter` |

Inputs: `label`, `period`, `value` (display string), `unit?`, `delta?` (null = "مفيش مقارنة"),
`onTap?`. The good/bad colour is derived: `up` with `higherIsBetter` or `down` without it is good
(`success`); the opposite is bad (`danger`); `flat` is neutral.

### SprintLogo

| Type | Values |
| --- | --- |
| `LogoVariant` | `mark`, `tilePrimary`, `tileInk`, `lockupAr`, `lockupEn` |

Inputs: `variant`, `size` (clamped to at least 16), `backgroundColor?` (decides whether a bare `mark` is
allowed; research R7).

## State transitions

Widgets are stateless in the data sense; their only transient state is interaction (hover, focus,
pressed, copied-feedback, password revealed). The one cross-state rule is the slot state precedence
above, which is a pure function and is table-tested. A state change while on screen (chip becomes full,
badge status changes, count changes) swaps colour, icon and word together with `AnimatedSwitcher` at
`duration-base` (`duration-fast` fade under reduced motion).

## Gallery sample content

Drawn from the Foundation's seed data and the settings repository (spec FR-066): facility names and
prices from the seed facilities, booking times from seed bookings, `bookingWindowDays` and
`fewLeftThreshold` from the settings repository. It is labelled "بيانات تجريبية" on screen.
