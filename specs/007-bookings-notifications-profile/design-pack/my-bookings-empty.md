# My bookings, empty states (no bookings at all, upcoming empty, past empty)

Covers: US-14, FR-MYB-02
Round 2 (2026-11-18). New section in Figma: "My bookings empty states · Compact" plus wide frames.
Node, Compact Light: empty `71:1620` · upcoming empty `287:40031` · past empty `287:40049`. Compact Dark: `71:2233` · `287:40067` · `287:40085`.
Node, Medium Light: empty `287:40247` · upcoming empty `287:40279` · past empty `287:40311` (Dark `287:40407` / `287:40439` / `287:40471`). Expanded Light `287:41407` / `287:41439` / `287:41471`, Large 1440 Light `287:41727` / `287:41759` / `287:41791` (Dark: `287:41567`, `287:41599`, `287:41631`, `287:41887`, `287:41919`, `287:41951`).
Images: images/my-bookings-empty-compact-<light|dark>.png (round 1), my-bookings-upcoming-empty-compact-light.png, my-bookings-past-empty-compact-light.png, my-bookings-empty-medium-light.png, my-bookings-upcoming-empty-medium-light.png, my-bookings-past-empty-medium-light.png.
Read depth: Compact empty (71:1620) design context (round 1); Compact upcoming empty 287:40031 design context; Compact past empty screenshot only; Medium empty 287:40247 design context; Medium upcoming empty and past empty screenshots only (shown in the pack images). Expanded, Large and all Dark: NOT read (frames exist).

## Which state when
| State | Condition | Tab selected | Segment labels |
| --- | --- | --- | --- |
| Empty (no bookings at all) | user has zero bookings | upcoming | "الجاية" (no count), "اللي فاتت" |
| Upcoming empty | no upcoming, at least one past | upcoming | "الجاية" (no count), "اللي فاتت" |
| Past empty | no past, at least one upcoming | past | "الجاية (3)" (count still shown), "اللي فاتت" |
Drawn for the sample, so the Past empty frames show "الجاية (3)" because upcoming exist.

## Layout

### Compact (390 x 844)
- Same header (title "حجوزاتي" `title-lg`, NotificationBell with badge 2) and tab bar as my-bookings.md. Content column gap `space-5`, padding top `space-2`, horizontal `space-4`, bottom 140 (no token).
- SegmentedControl (see components-segmented-control.md) as per the table.
- Spacer 32 (no token; about `space-8`): present in empty and upcoming empty; in past empty the art starts at the same y (art top about y 250 in the render).
- LottieMoment `empty-bookings`, full width, column, centred, gap `space-4`: art 160 x 160 (circle `surface-sunken`, dashed ring `line` inset 12, ticket icon `ink-muted` 64 at inset 48), then the text:
  - Empty: title "لسه مفيش حجوزات." (`title`, `ink`), body "المنشآت مستنياك" (`body`, `ink-muted`), then primary button "استعراض المنشآت" (full width, 48, `radius-md`, padding h `space-5`, `button`, `on-primary`) to the facility list.
  - Upcoming empty: title "مفيش حجوزات جاية" (`title`, `ink`), body "حجوزاتك القديمة موجودة في \"اللي فاتت\"." (`body`, `ink-muted`, with the straight double quotes as drawn), same primary button "استعراض المنشآت".
  - Past empty: title "مفيش حجوزات سابقة" (`title`, `ink`) only: no body and no button (from the screenshot; node not read in text, so the exact copy comes from the image).
- The art is static final frame: plays once, never loops, excluded from screen readers; reduced motion shows the final frame.

### Medium (720 x 1000)
- Empty (no bookings at all): there is NO detail pane. One list pane fills the width next to the 88 rail: padding top `space-6`, bottom `space-8`, horizontal `space-6`; inner content 560 wide, column gap `space-5`, top padding `space-2`, items aligned to the start (right): title "حجوزاتي", SegmentedControl (560), LottieMoment (art 160 then title "لسه مفيش حجوزات." and body "المنشآت مستنياك"), button "استعراض المنشآت" 560 wide. No bell (rail carries it).
- Upcoming empty and past empty: master-detail columns as in my-bookings.md (rail 88, list pane 300, detail pane flex). List pane holds the title, SegmentedControl 252 and the same LottieMoment text as at Compact (the body wraps to two lines at 252: "حجوزاتك القديمة موجودة في \"اللي / فاتت\"."), upcoming empty also the full-width button "استعراض المنشآت"; past empty has neither body nor button. Detail pane: a centred placeholder: ticket icon (about 28, `ink-muted`) over the text "اختار حجز من القايمة" (`body`, `ink-muted`, centred). Icon size and text style are read from the image only.
- Expanded and Large: frames exist, NOT read (same structure assumed).

## Text
- Title `title` / `ink`; body `body` / `ink-muted`; button `button` / `on-primary`; segment labels `label`; detail placeholder `body` / `ink-muted` (image).

## States
- Three empty states above. No loading skeleton or error is drawn.

## Dark theme
- Token swap only (circle and ring darker, ticket in `ink-muted`, button dark `primary`). Round-2 Dark frames NOT read.

## Not in Figma
- Whether the detail placeholder is announced to screen readers and whether it appears on Compact (it does not: Compact has no detail pane).
- Empty state animation: Lottie moment `empty-bookings`, tinted from tokens at runtime, <= 100KB; the ticket is not directional.
- Guests do not reach these screens (account gate).

## Copy-rule note
"اختار حجز من القايمة" uses an imperative verb ("اختار"), which breaks the no-imperative rule in CLAUDE.md. Suggested verbal noun: "اختيار حجز من القايمة" or a noun phrase such as "التفاصيل هتظهر هنا". Osman decides.
