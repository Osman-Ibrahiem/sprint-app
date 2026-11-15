# Contract: Widgets

**Spec**: FR-001 – FR-066 | **Sources**: `docs/design-system/components/<Name>/README.md`, `handoff.md` (property names)
**Types**: [data-model.md](../data-model.md) | **Platform behaviour**: [adaptive-additions.md](adaptive-additions.md)

Public API in `lib/core/widgets/` (barrel `design_system.dart`). Property names match the Figma
component table in `handoff.md`. Every widget: tokens only, strings from l10n, direction-aware, 48
targets, text to 200%, reduced motion, no platform check, no data access. Signatures below are the
shape, not final code.

## Shared rules

- **Semantics**: each interactive widget exposes one `Semantics` node with a sentence label, the state,
  and the reason when it cannot be used. State is never colour only.
- **Focus**: keyboard focus draws the Foundation's `focus-ring`; hover and pressed come from
  `AdaptivePressable`.
- **Loading forms** exist only for `FacilityCard`, `BookingTicket`, `StatTile` (R15).
- **Debug asserts** (never user-visible): fewer than two navigation destinations, more than three
  facility tags, non-consecutive day strip days.

## SprintButton

```text
SprintButton({label, variant = primary, size = md, icon?, loading = false,
              loadingLabel?, onPressed?})
```

| Variant | Fill | Text | Border |
| --- | --- | --- | --- |
| `primary` | `primary` | `on-primary` | none |
| `secondary` | `surface` | `ink` | 1px `control-border` |
| `tonal` | `primary-soft` | `on-primary-soft` | none |
| `ghost` | transparent | `primary` | none |
| `danger` | `danger` | `on-danger` | none |

`md` = `control-height`; `sm` = `control-height-sm` visually with a 48 hit area. Radius `radius-md`;
type style `button`. Loading replaces the icon with `AdaptiveLoader`, shows `loadingLabel`, ignores
presses, and is announced as busy. Disabled (`onPressed == null`) keeps the label readable and is
announced as unavailable (spoken: "<label>، غير متاح"). Never a `volt` fill.

## SprintTextField

```text
SprintTextField({label, placeholder?, helper?, error?, type = text, controller?,
                 enabled = true, onChanged?, onLeave?, onSubmitted?})
```

Label above (style `label`, `ink`); field `control-height`, `radius-sm`, `surface`, 1px
`control-border`; focused 2px `primary`; error 2px `danger` on `danger-soft` with an icon and the
message in place of the helper; disabled `surface-sunken`, `ink-disabled`. Types:

| Type | Keyboard | Autofill | Direction |
| --- | --- | --- | --- |
| `text` | text | none | follows locale |
| `password` | visible password off | password | LTR, show/hide control ("إظهار" / "إخفاء", 48) |
| `search` | text, search action | none | follows locale; pill on `surface-sunken`, search icon |
| `phone` | phone | telephone number | LTR, start-aligned |
| `email` | email | email | LTR, start-aligned |
| `nationalId` | number | none | LTR, start-aligned |

`onLeave` fires when focus leaves the field; the widget never validates. The error text is read by a
screen reader as part of the field's semantics.

## SlotChip

```text
SlotChip({start, state, remaining?, fewLeftThreshold, price?, onSelected?, rangeFill = false})
// or SlotChip.resolved({... isPast, isSelected, remaining, fewLeftThreshold}) using resolveSlotState
```

| State | Look | Word (ar / en) |
| --- | --- | --- |
| `available` | `surface`, 1px `control-border`, `ink` | "N أماكن" / "N places" (shared); none (exclusive) |
| `selected` | `primary`, `on-primary` | "مختار" / "Selected" |
| `fewLeft` | `volt`, `on-volt` | "فاضل N" ("فاضل مكانين" for 2) / "N places left" |
| `full` | `surface-sunken`, `ink-muted` | "مكتمل" / "Full" |
| `past` | transparent, 1px `line`, `ink-disabled` | "فات" / "Past" |

Size at least 56 × 100; time in `number`, word in `micro`. `rangeFill` tints the chip `primary-soft`
(chips between the first and last of a free-facility range). `full` and `past` ignore presses.
Spoken: "الساعة 6 مساءً، فاضل مكان واحد" (plus ", 120 جنيه" when `price` is given); for `full`:
"الساعة 6 مساءً، مكتمل". A selection calls `AdaptiveHaptics.selection`. A state change animates colour
and word together at `duration-base`.

## DayStrip

```text
DayStrip({days, today, selected?, onSelected})
static DayStripDay? defaultSelection(List<DayStripDay> days)
```

Pill 64 high, `radius-full`: day name (`micro`, `ink-muted`) over number (`number`, `ink`). Today shows
"النهارده" / "Today" in `primary`. Selected: `primary`, `on-primary`. Room: `success` dot (never
`volt`), spoken "فيه أماكن". Closed: `ink-disabled`, not pressable, spoken "مقفول". Order follows the
reading direction (today first). Compact scrolls and keeps the selected day visible; medium and up
spread across the width. Arrow keys move focus on keyboard platforms. Selecting calls the haptic.

## StatusBadge

```text
StatusBadge({status})
```

| `SprintStatus` | Word (ar / en) | Icon | Colours |
| --- | --- | --- | --- |
| `confirmed` | مؤكد / Confirmed | check circle | `success` on `success-soft` |
| `pendingPayment` | في انتظار الدفع / Awaiting payment | clock | `warning` on `warning-soft` |
| `cancelled` | اتلغى / Cancelled | x circle | `danger` on `danger-soft` |
| `attended` | حضر / Attended | user check | `on-primary-soft` on `primary-soft` |
| `noShow` | غاب / No-show | user minus | `ink-muted` on `surface-sunken` |
| `expired` | انتهت المهلة / Expired | hourglass | `ink-muted` on `surface-sunken` |
| `underReview` | قيد المراجعة / Under review | clock | `warning` on `warning-soft` |
| `verified` | موثّق / Verified | seal check | `success` on `success-soft` |
| `rejected` | مرفوض / Rejected | x circle | `danger` on `danger-soft` |
| `open` | مفتوح / Open | warning circle | `warning` on `warning-soft` |
| `inProgress` | جاري / In progress | wrench | `primary-soft` background, `on-primary-soft` |
| `resolved` | اتحل / Resolved | check circle | `success` on `success-soft` |

Pill 28 high, `radius-full`, horizontal `space-3`, icon `icon-sm` plus word in `micro`. Not pressable.
Spoken: "الحالة: مؤكد". A status change swaps icon, word and colour together.

## FacilityCard

```text
FacilityCard({kind, layout = vertical, name, owningUnit, unitCount, tags, availability,
              price, photo?, heroTag?, onTap})
FacilityCard.loading({layout = vertical})
```

`surface`, `radius-lg`, `shadow-card` in Light only, padding `space-4`, a `line` divider above the
price. Vertical: photo (about 16:9) on top. Horizontal: photo on the start side, width from
`SprintExtras`. No photo → `surface-sunken` with "صورة المنشأة". Tags: `primary-soft` for "بمدرب" and
"مجاني", sport tag neutral, offer tag `volt` with `on-volt`. Availability: plenty = `success` + check,
few = `warning` + clock, none = `ink-muted` + "مفيش مواعيد النهارده". Price: the one amount the user
pays and whom it is for ("سعر الطلاب والعاملين" / "السعر الكامل"); a guest sees both; free shows
"مجاني"; an offer shows the old amount struck through in `ink-muted`. The whole card is one
`AdaptivePressable`; no buttons inside. The photo takes `heroTag` for the shared-element transition
(timed by the catalogue feature with `duration-slow`, `ease-enter`). Spoken: name, owning unit,
availability, price in one sentence.

## BookingTicket

```text
BookingTicket({state, status, facilityName, unitName, trainerName?, start, end, qrToken?,
               code, paid, cancelUntil?})
BookingTicket.loading()
```

`surface`, `radius-lg`, 340 wide on compact (width from `SprintExtras`), centred on larger windows.
Top: `StatusBadge`, facility, unit, trainer. Time band: `volt` with `on-volt` for `upcoming` and
`today`; `surface-sunken` with `ink-muted` for `past`; text from `SprintFormat.dateTimeLine`. Divider:
dashed `line` with two half-circle notches in `bg`. QR: `qr-ink` on `qr-ground`, margin 12, painted
from the token (R5), shown only for a non-past, non-cancelled booking with a token; otherwise the
status takes its place; an empty token shows "QR غير متاح". Code: `code` style inside `LtrIsolate`,
press to copy then a short "اتنسخ" notice, announced. Rows: paid, and "إلغاء مجاني لحد ..." from
`cancelUntil` or "الإلغاء مش متاح". No offers or ads. Reveal: `duration-slow`, `ease-enter` (fade under
reduced motion). Spoken: facility, date and time, status, code read digit by digit.

## AppNavigation

```text
AppNavigation({destinations, selected, onSelected, form?})
// forms: SprintTabBar (compact), SprintNavRail (medium), SprintSidebar (expanded, large)
```

Form from `WindowSize` of the available width (so a hinge pane follows its own width). Active styling:
tab bar = Fill icon + `primary` label; rail = `primary-soft` pill, `on-primary-soft`; sidebar =
`primary-soft` row, `on-primary-soft`. Tab bar: height `tabbar-height` plus the safe area, extends
behind it, never hides on scroll, Apple translucent with blur and no pill, Android solid `surface`
with the pill allowed; labels drop to icon + spoken label above the Foundation's text-scale threshold;
at most five items, a sixth onward becomes four plus "المزيد" opening `showSprintSheet` with the rest.
Rail and sidebar on the start edge; the sidebar tops with `SprintLogo` lockup. Badges: `danger` with
`on-danger`, hidden at 0, "99+" above 99, spoken with the destination ("الإشعارات، 3 غير مقروءة").
Desktop and web: hover `surface-sunken`, focus ring, number keys 1 to 5. Selecting the already
selected item reports it so the shell returns to that tab's start (Foundation behaviour kept).
Foundation guarantees retained: one form per width, state kept on resize and fold (the shell body
stays under its `GlobalKey`), 48 targets, Arabic labels.

## StatTile

```text
StatTile({label, period, value, unit?, delta?, onTap?})
StatTile.loading()
```

`surface`, `radius-lg`, `shadow-card` in Light only, padding `space-4`. Label and period `caption`
`ink-muted`; value `number-lg` `ink` with a smaller `ink-muted` unit; delta row: arrow (direction), a
colour for good or bad, and a sentence ("زيادة 12% عن الأسبوع اللي فات"); flat: "مفيش تغيير"; no delta:
"مفيش مقارنة". Pressable only when `onTap` is given. No chart. Width is flexible (two per row on
compact, three or four on expanded and larger, decided by the screen).

## SprintLogo

```text
SprintLogo({variant, size?, backgroundColor?})
```

Draws `docs/design-system/logo/*.svg` with fixed colours in both themes; lockups add the name in
`title` style, gap `space-3`, tile on the start side; never mirrors the mark; size clamped to at least
16; a bare `mark` on a background with under 3:1 contrast against `volt` falls back to the primary
tile. Spoken: "سبرنت" (decorative inside a lockup that already has the name).

## New ARB keys

All in `app_ar.arb` (template) and `app_en.arb`, grouped by prefix; the final text is reviewed in
`copy-review.md` before merge.

| Group | Keys |
| --- | --- |
| Button | `buttonDisabledSuffix`, `buttonBusy` |
| Text field | `fieldShowPassword`, `fieldHidePassword`, `fieldSearchHint` |
| Slot | `slotAvailablePlaces` (plural), `slotSelected`, `slotFewLeft` (plural), `slotFewLeftSpoken` (plural), `slotFull`, `slotPast`, `slotSpoken`, `slotSpokenWithPrice` |
| Day strip | `dayToday`, `dayHasRoom`, `dayClosed`, `daySpoken` |
| Status | `status` + the twelve status names, `statusSpoken` |
| Facility card | `facilityPhotoPlaceholder`, `facilityTrainerTag`, `facilityFreeTag`, `facilityUnitCount` (plural), `facilityAvailabilityPlenty`, `facilityAvailabilityFew`, `facilityAvailabilityNone`, `facilityPriceInternalLabel`, `facilityPriceExternalLabel`, `facilityFree`, `facilitySpoken` |
| Ticket | `ticketCodeLabel`, `ticketCopied`, `ticketPaid`, `ticketCancelUntil`, `ticketCancelUnavailable`, `ticketQrUnavailable`, `ticketSpoken` |
| Navigation | `navMore`, `navBadgeSpoken` (plural) |
| Stat tile | `statDeltaUp`, `statDeltaDown`, `statDeltaFlat`, `statNoComparison` |
| Logo | `logoLabel` |
| Gallery | `galleryTitle`, `gallerySampleNote`, `galleryTextSize`, `galleryReducedMotion`, `galleryPlatformLook`, `galleryPlatformApple`, `galleryPlatformAndroid`, `galleryPlatformDesktop`, and one title per component section |
