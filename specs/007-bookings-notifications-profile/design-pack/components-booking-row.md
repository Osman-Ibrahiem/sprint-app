# BookingRow (new component)

Covers: US-14, FR-MYB-02
Node: component set 278:35408 (default instance 278:35395); used on the My bookings screens (see my-bookings.md, my-bookings-past.md).
Read depth (round 2): component set 278:35408 design context read (default instance only: pending payment, selected=false, with the selected variant ids `278:35407` / layer ids `278:35397..35406` exposed); Compact/Medium/Expanded instances read in earlier calls. The component exposes exactly one property: `selected` (boolean). Status, date chip variant and action text are overrides on instances, not variant properties (so a Flutter widget takes them as data).

## Purpose
One booking in the My bookings list. The whole row is the touch target (>= 48 high, it is far taller). Not a card with inner buttons: the action text on the row is a label, the row itself navigates.

## Anatomy (column, gap `space-2`, padding `space-4`, fill `surface`, radius `radius-lg`, shadow `shadow-card` light only; in dark no shadow)
1. Header (row, wrap, gap `space-2`, items centred, justified to the end): the nested StatusBadge, then the date chip. When the two do not fit the width the chip wraps under the badge instead of overflowing (a long date chip drops to the next line and the row grows: 154 -> 190; at 252 wide the chip always wraps).
2. Facility name: `headline` `ink`, full width, start aligned.
3. Unit/notes line: `caption` `ink-muted`, full width. Content: unit, trainer, or "مجاني", plus extras, joined with " · " ("الملعب كله · لحد 22 لاعب · فاضل 6 دقايق للدفع").
4. Footer (row, space-between, full width): booking code and the action.
   - Code: `code` (Cairo Medium 17, line height 24, letter spacing 0.08em), colour `ink-muted`, always an LTR isolate, at the left visually.
   - Action text: `label` `primary`, "عرض التذكرة" (CONFIRMED), "إكمال الدفع" (PENDING_PAYMENT), "التفاصيل" (every past status).

## Date chip (not a separate component, a frame in the row)
- Row, gap `space-2`, padding h `space-3` v `space-1`, radius `radius-sm`; text `label`, icon clock 16 (`icon-sm`) at the end (after the text in RTL, i.e. on the left).
- Variants: **today**: fill `volt`, text and icon `on-volt` (volt is a fill only; text always `on-volt`), copy "النهارده · 5:00 – 6:00 م". **other day**: fill `surface-sunken`, text `ink`, copy "الخميس 12 نوفمبر · 6:00 – 8:00 م" (weekday day month · from – to, 12 hour, Western digits).
- Wrapping: the chip does not shrink its text; the whole chip moves under the badge when too wide.

## Variants
- `selected` = false (default) / true (the only Figma variant property). True is used only in master-detail (Medium and up): adds a 2px solid `primary` border around the row (in dark the lighter `primary`); size grows by the border (194 vs 190). Round 2: the selected row now follows the user's choice (no-show / cancelled selected frames in my-bookings-past.md); the first row is auto-selected by default. No token exists for the 2px border width (record "no token"; suggest a `border-selected` or reuse the focus ring width).
- Status (via nested StatusBadge): CONFIRMED مؤكد, PENDING_PAYMENT في انتظار الدفع, ATTENDED حضر, NO_SHOW غاب, CANCELLED اتلغى. Date chip variant: today vs other day. Action text by status as above.

## Sizes
- Width: fills its container: 358 at Compact (390 - 2 x `space-4`), 252 (Medium list pane 300), 296 (Expanded), 336 (Large).
- Height: not fixed, hugs content: 154 (one header line), 190 (header wrapped), 194 / 210 (wide with selected border or a wrapped notes line).

## Tokens used
`surface`, `surface-sunken`, `volt`, `on-volt`, `ink`, `ink-muted`, `primary`, `primary-soft` (selected? no), status colours via StatusBadge, `radius-lg`, `radius-sm`, `space-1/2/3/4`, `shadow-card`, text styles `headline`, `caption`, `label`, `code`, `micro` (badge), `icon-sm`.

## Behaviour and a11y (not in Figma)
- One semantic node; label reads: status, date and time, facility, notes, code letter by letter, then the action. No colour-only status (the badge always carries icon and word).
- Pressed state follows the platform (iOS 70% opacity, Android ripple, web hover + focus ring).
- A pending-payment row shows a live "فاضل N دقايق للدفع" part in the notes line and updates every minute; when it ends the row switches to EXPIRED.
- Do not mirror icons except directional ones (none here).
