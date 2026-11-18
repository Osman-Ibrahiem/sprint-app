# SegmentedControl (new component)

Covers: US-14, FR-MYB-02
Node: component set 278:35421 (instances 278:35414 upcoming selected, 278:35420 past selected).
Read depth (round 2): component set 278:35421 design context read: property `selected` = upcoming | past, props `upcomingLabel` (default "الجاية (3)") and `pastLabel` (default "اللي فاتت"); node ids upcoming 278:35414 (segments 278:35410 past, 278:35412 upcoming), past 278:35420 (278:35416, 278:35418). Verified visual: selected segment fill `surface` + `ink` label, other segment no fill + `ink-muted` label, all `label` 14/20 600.

## Purpose
Switch between "الجاية" and "اللي فاتت" in My bookings. Two segments only in this design (could take more later).

## Anatomy
- Track: fill `surface-sunken`, radius `radius-md`, height 48 (`control-height`), padding `space-1` all around, gap `space-1` between segments, full width of its container (358 Compact, 252 Medium list pane, 296 Expanded, 336 Large), overflow clipped.
- Segment: equal width (flex 1), centred label, radius `radius-sm`, height 40 (track minus the padding).
- Selected segment: fill `surface` (white in light, a lifted surface in dark), label `ink`. Unselected: no fill, label `ink-muted`.
- Label: `label` (14/20 SemiBold), one line, centred, never wraps.
- Order in RTL: "الجاية" at the start/right, "اللي فاتت" at the end/left (screenshots show الجاية on the right).

## Variants
- `selected` = upcoming | past.
- Upcoming label shows its count: "الجاية (3)" (Western digits, the count of upcoming bookings). **When upcoming is empty it shows no count: "الجاية"** (empty and upcoming-empty states). The past-empty state still shows "الجاية (3)" because upcoming exist. The past label never has a count: "اللي فاتت". The segment order in the Figma layers is past first, upcoming second (visual canvas order), which is upcoming at the start/right in RTL.
- Counts are part of the label text, not a separate badge.

## Hit area
- Segments draw at 40 inside the 48 track but the **whole 48 row is the hit area** (recorded exception; each segment takes the full 48 height for touch). Keyboard focus ring wraps the segment.

## Tokens used
`surface-sunken`, `surface`, `ink`, `ink-muted`, `radius-md`, `radius-sm`, `space-1`, `control-height`, text style `label`.

## Behaviour and a11y (not in Figma)
- Selection moves with a short slide of the thumb timed by `SprintMotion`; reduced motion switches instantly. Arrow keys move between segments on keyboard platforms (focus ring visible).
- Semantics: tab group; each segment announced "الجاية، 3 حجوزات، مختار". Native feel follows the platform only for motion/haptics; the look is the brand look on every platform.
- On wide windows the control sits in the list pane under the title and selected tab is kept in the address.
