# Data Model: Facility Catalogue and Details

No new stored entity. The Foundation's domain classes (`Facility`, `OwningUnit`, `BookableUnit`,
`Price`, `OperatingHours`, `Closure`, `Trainer`, `Booking`, `Slot`, `Session`) are used as they are.
This feature adds view models and pure rules, all Freezed or plain immutable classes in
`lib/features/catalogue/domain/`, with no Flutter, Riverpod or repository imports.

## FacilityFilter

| Field | Type | Rule |
| --- | --- | --- |
| `type` | `FacilityType?` | null = all types |
| `owningUnitId` | `String?` | null = all owning units |
| `free` | `bool?` | null = all, true = free only, false = paid only |

- `isActive` is true when any field is set; `count` of set fields drives the "clear all" action.
- Maps one to one onto `CatalogueRepository.listFacilities(type:, owningUnitId:, free:)`; filters
  combine with AND and `includeUnpublished` is never passed (FR-007, FR-008).

## FacilitySummary (a list or card row)

| Field | Source |
| --- | --- |
| `facility` | `Facility` |
| `owningUnitName` | `OwningUnit.name` |
| `activeUnitCount` | units where `isActive` |
| `today` | `TodayAvailability` |
| `priceInternal`, `priceExternal` | a `TierPriceRange { min, max }` of `Price.amount` per `PriceTier` over active units (`isSingle` when min equals max), or null for a free facility or when no active unit has a price yet |
| `kind` | `FacilityKind.free` if `isFree`, `withTrainer` if `requiresTrainer`, else `paid` (the 002 enum) |

## TodayAvailability

| Field | Type | Rule |
| --- | --- | --- |
| `level` | `AvailabilityLevel` (002 enum) | `none` if `count == 0`, `few` if `count <= fewLeftThreshold`, else `plenty` (BR-45) |
| `count` | `int` | sum of `remaining` over slots that are bookable and not past |
| `closedToday` | `bool` | the facility or all its units have no operating slot today |

- Built by `TodayAvailability.fromSlots(List<Slot>, {required int fewLeftThreshold})`; pure, "now" is
  already applied by the availability repository (slots in the past arrive as `past`).

## FacilityDetails (the page)

| Field | Content |
| --- | --- |
| `facility`, `owningUnitName` | as above |
| `hours` | `HoursView` |
| `closures` | current and upcoming closures of the facility and its units, each with scope, dates, reason |
| `priceGroups` | `List<PriceGroup>`; empty for a free facility |
| `trainers` | `List<TrainerView>`; only when `requiresTrainer` |
| `units` | active units, each with an optional `ownHours` line (FR-021) |
| `today` | `TodayAvailability` |
| `facts` | resolved settings to display: `bookingWindowDays`, and `maxRangeHours` (free) or `sessionMinutes` (trainer) |

### HoursView

| Field | Type | Rule |
| --- | --- | --- |
| `days` | 7 × `{dayOfWeek, openMinutes?, closeMinutes?}` | closed day = null times, shown "مقفول" |
| `todayDayOfWeek` | `int` | Cairo day, marks today |
| `closedNow` | `bool` | inside a closure or outside hours now (FR-016) |
| `unitOverrides` | `Map<unitId, List<day times>>` | only units whose weekly hours differ from the facility's; equal hours produce no entry |

### PriceGroup

| Field | Type | Rule |
| --- | --- | --- |
| `unitIds`, `unitNames` | lists | the units sharing this price and mode |
| `coversAllUnits` | `bool` | UI shows "كل الوحدات" |
| `mode` | `BookingMode` | `exclusive` = "للحجز كله", `shared` = "للمكان الواحد" (BR-16) |
| `internal`, `external` | `int?` | whole EGP; null = no price set yet |

### TrainerView

`trainerId`, `name` (from `IdentityRepository.getUser(trainer.userId)`, a neutral label when missing),
`bio`, `capacity`.

## HomeContent

| Field | Rule |
| --- | --- |
| `types` | facility types that have at least one published facility, in a fixed order |
| `featured` | up to 6 `FacilitySummary` (R4) |
| `upcoming` | for a signed-in user: upcoming `CONFIRMED` bookings, soonest first, with facility name; empty for a guest |
| `suggestions` | for a user with history: up to 4 `Suggestion`; otherwise empty (featured shows instead) |

### Suggestion

`facility: FacilitySummary`, `reason: SuggestionReason` (`bookedTypeBefore(FacilityType)` or `other`).
The reason is a value, and the UI turns it into the Arabic or English sentence from ARB.

## FacilityLink

`path(id)` → `/facilities/<id>`; `parse(String location)` → `String?` id. Pure, no platform code. The
full-URL base is the share provider's job (R7).

## Validation and state rules

- A facility is shown only when `isPublished`; a link to a missing or unpublished id resolves to the
  not-found screen (FR-026).
- No state transitions: nothing here changes a booking, a price or a setting.
- The filter and scroll offset are the only mutable state, in keep-alive providers (R5).
