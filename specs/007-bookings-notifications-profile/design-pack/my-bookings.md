# My bookings (upcoming tab)

Covers: US-14, FR-MYB-02 (also entry to FR-MYB-03 on wide: selected booking details)
Node (Figma file xeuMQ0KyXsXVh4QldmkbDf): Compact Light 16:397 · Compact Dark 19:1244 · Medium Light 243:11152 · Medium Dark 243:11767 · Expanded Light 243:24508 · Expanded Dark 243:25135 · Large 1440 Light 243:25944 · Large 1440 Dark 243:26571
Images: images/my-bookings-<compact|medium|expanded|large>-<light|dark>.png
Read depth (round 2, 2026-11-18): Compact Light and Medium Light fully; Expanded Light design context (243:24508, round 2); Large Light screenshot only (images/my-bookings-large-light.png, re-downloaded, not described beyond widths); all Dark NOT re-read (round-1 screenshots only). Figma edited after round 1: the list is unchanged, but the wide selected-row detail pane is now documented per status in my-bookings-past.md.

## Layout

### Compact (390 x 844, mock status bar 54 and iOS home indicator 34 are mock chrome, not built)
- Screen: bg `bg`.
- Content (column, gap `space-5`, padding top `space-2`, horizontal `space-4` (start/end), bottom 140 so the tab bar never covers the last row; no token for 140), starts under the status bar:
  - Header (row, space-between, full width; in RTL the title is at the start/right, the bell at the end/left):
    - Title "حجوزاتي": `title-lg`, `ink`, one line.
    - NotificationBell: 48 circle, fill `surface`, icon/bell 24 (Phosphor Regular, never mirrored), unread badge top-end: fill `danger`, text `micro` `on-danger`, min width 18, padding 5, `radius-full`, count "2". Hidden when count is 0. Not for guests. Tap pushes Notifications with a back button.
  - SegmentedControl, full width, 48 high, selected = upcoming, label "الجاية (3)" (count = number of upcoming). See components-segmented-control.md.
  - List of BookingRow, full width, gap `space-5` (the column gap), not a card grid. See components-booking-row.md. Sample content, in order (soonest first):
    1. CONFIRMED, today chip (volt), facility "حمام السباحة الأوليمبي", notes "حارة 3 · مع الكابتن أحمد سامي", code SP-1042, action "عرض التذكرة". Height 154.
    2. PENDING_PAYMENT, chip "التلات 10 نوفمبر · 8:00 – 9:00 م", "ملعب كرة القدم الرئيسي", "الملعب كله · لحد 22 لاعب · فاضل 6 دقايق للدفع", SP-1038, action "إكمال الدفع". Height 190 (the header wrapped: chip is under the badge).
    3. CONFIRMED free, chip "الخميس 12 نوفمبر · 6:00 – 8:00 م", "ملعب الاستاد الخماسي", "ملعب 2 · مجاني", SP-1027, "عرض التذكرة". Height 190.
- Bottom: AppNavigation tab-bar (see Navigation), 64 high plus safe area, top border 1px `line`, fill `surface` with a 10 blur behind it.

### Medium (720 x 1000): master-detail, three columns, no bell
- Row (full width, RTL so first child is at the right): AppNavigation rail 88 wide (right/start), List pane 300 wide, Detail pane takes the rest (flex, about 332).
- List pane: padding top `space-6`, bottom `space-8`, horizontal `space-6`; column gap `space-4`; inner Content column gap `space-5`, top padding `space-2`: title "حجوزاتي" (`title-lg`), SegmentedControl (fills 252), BookingRows (fill 252). Rows are tall here because the date chip always wraps under the badge: 194 (today's row, incl. 2px border), 210 (pending, long notes line wraps/chip wraps), 190.
- First row is `selected=true` and is auto-selected on load, on every tab switch and whenever the list changes (open booking): 2px border `primary` instead of the plain card edge; see components-booking-row.md. Every tab (upcoming, past) selects its own first row; round-2 frames show this for upcoming (SP-1042), past (SP-1042 attended), and the no-show / cancelled variants where the selected row is the 2nd / 3rd row (Figma shows a manual selection, same 2px border).
- Detail pane (a state-driven pane: it shows the booking details of the selected row, see my-bookings-past.md for attended, no-show and cancelled; with no selection or an empty list it shows the "اختار حجز من القايمة" placeholder, see my-bookings-empty.md): padding top `space-6`, bottom `space-8`, horizontal `space-6`; column, gap `space-4`:
  - Heading "تفاصيل الحجز": `title`, `ink`, full width, start aligned.
  - Content column (gap `space-3`, top padding `space-4`, bottom `space-6`): one white card "Booking": fill `surface`, radius `radius-lg`, padding `space-4`, gap `space-2`, no shadow in Figma (bg is `bg`, card sits on it), containing:
    - Header row (space-between): StatusBadge (at the end/left) and facility name `headline` `ink` (at the start/right).
    - Notes: `caption` `ink-muted`, "حارة 3 · مع الكابتن أحمد سامي".
    - When: full width, fill `volt` when today (`surface-sunken` for other days, see past), radius `radius-sm`, padding h `space-3` v `space-2`, centred row gap `space-2`: icon/clock 20, text `label` `on-volt` "الأحد 8 نوفمبر · 5:00 – 6:00 م".
    - QR wrap: centred, QRCode 160 (dark modules on white, always, both themes; encodes the signed qrToken, never the raw code).
    - Code row (space-between): code `code` `ink` "SP-1042" (LTR isolate, start of row on the left visually), label "رقم الحجز" `body` `ink-muted`.
    - Row "الشريحة" / "داخلي" and Row "المدفوع" / "80 ج.م": value `body-strong` `ink`, label `body` `ink-muted`; gap `space-3`.
  - Button "إلغاء الحجز": danger, full width, 48 high, radius `radius-md`, label `button` `on-danger`, padding h `space-5`. (Destructive: spec must route through a confirm dialog.)

### Expanded (1194 x 834) and Large (1440 x 900): same three columns, AppNavigation becomes the sidebar
- Sidebar 280 wide at the right/start (see Navigation); list pane 360 (Expanded) / 400 (Large), content width 296 / 336 (padding 32 = `space-8`); detail pane takes the rest: 554 (Expanded), 760 (Large), content 490 / 696 wide, padding 32 (`space-8`), heading "تفاصيل الحجز" at y 32, card then the danger button 16 below the card.
- Order right to left: sidebar, list, detail (Figma layer order is the LTR canvas order: detail, list, nav, so the layer list reads backwards). Row heights Expanded 194 (selected, today, chip wraps) / 190 / 190; Large 158 / 190 / 190 (the "today" row fits one line at 336 wide; at 296 it wraps). Large not re-read in round 2.
- Expanded read (round 2): list pane 360 wide, padding `space-8`, header and rows as Medium (title `title-lg`, SegmentedControl, rows); detail pane padding `space-8` all round (Medium: `space-6` sides), heading "تفاصيل الحجز" `title`, card with QR 160, then the danger button full width below the card (same arrangement as Medium). Row 2 (pending) at 296 wide has the long notes line wrapped at 190. Row 3 date chip "الخميس 12 نوفمبر · 6:00 – 8:00 م", action "عرض التذكرة".
- Sidebar (Expanded, read in round 2): 280 wide, fill `surface`, 1px `line` border at the content-facing edge, padding top `space-4`, horizontal `space-3`, gap `space-1`, items aligned to the end/right. Brand lockup first: SprintLogo (tile 32 + "سبرنت" Cairo 700 `title` 20/30, `ink`, gap `space-3`), padding bottom `space-3`, horizontal `space-3`. Destination rows (الرئيسية, المنشآت, حجوزاتي, الإشعارات, حسابي): height 44 (below the 48 target: needs a recorded exception or a 48 hit area, not in decisions.md), radius `radius-md`, padding horizontal `space-3`, gap `space-3`, icon 24 at the start/right, label `label` 14/20 (`ink-muted`; active `on-primary-soft` on a `primary-soft` fill), spacer, then on الإشعارات the badge (`danger`, `on-danger` `micro`, min width 18) at the end/left. Active icon for حجوزاتي is the fill ticket.
- Detail card is the same as Medium; just wider (QR stays 160 centred, code row and rows stretch).
- Layout follows window width classes (compact < 600, medium 600-839, expanded 840-1199, large >= 1200); Medium has the 88 rail, Expanded and Large have the 280 sidebar.

## Navigation (the My bookings destination)
- Destination label "حجوزاتي", icon ticket (Phosphor): regular when inactive, **fill when active**. Do not mirror.
- Compact tab bar (4 destinations, visual order from the start/right): الرئيسية, المنشآت, حجوزاتي, حسابي. No notifications tab (the bell in the header carries it). Item: column, icon 24 above label `micro`, gap `space-1`, equal widths. Active = icon and label `primary`; inactive = `ink-muted`. No pill on compact.
- Rail (Medium, 88 wide): fill `surface`, 1px `line` border on the content-facing edge, top padding `space-4`, items gap `space-3`. Order top to bottom: الرئيسية, المنشآت, حجوزاتي, الإشعارات, حسابي. Item: Indicator pill 56 x 32 `radius-full` with icon 24, label `micro` under it, gap `space-1`. Active (حجوزاتي): indicator fill `primary-soft`, label `on-primary-soft`; inactive label `ink-muted`. الإشعارات shows the unread badge (count 2: `danger` fill, `on-danger` `micro`, min width 18) on the indicator's top edge.
- Sidebar (Expanded/Large, 280): the same five destinations as rows with logo "سبرنت" (bolt tile + wordmark) on top; active row full-width pill `primary-soft` with `on-primary-soft` text (Dark: a dark blue tinted pill, icon and text light), others `ink-muted`; الإشعارات row carries the count badge at the opposite end. Only a screenshot was read for the sidebar; row sizes were not read.
- The bell leaves the page header from Medium up.

## Text
- Title "حجوزاتي": `title-lg`, `ink`.
- Detail heading "تفاصيل الحجز": `title`, `ink`.
- Segment labels: `label`; selected `ink` on `surface`, unselected `ink-muted`.
- Row text: see components-booking-row.md.
- Rail/tab labels: `micro`.

## States
- Default list (this screen), selected row (wide), pending-payment row with live countdown text, free booking row.
- Past tab: my-bookings-past.md (now with no-show and cancelled selected variants). Empty (no bookings at all), upcoming empty, past empty: my-bookings-empty.md (all four window classes exist in Figma since round 2).
- Not drawn in Figma: loading skeleton, error, pull to refresh (see below).

## Dark theme
- Token swap only, with these visible notes: cards lose shadow and lift with `surface` over `bg` (shadow-card is `none` in dark); the volt date chip stays volt with `on-volt` text; selected row border is a lighter `primary` (dark value); sidebar active pill is `primary-soft` dark. QR stays dark on white.

## Not in Figma
- Settings read: `fewLeftThreshold` is not used here. The pending-payment countdown ("فاضل 6 دقايق للدفع") comes from the booking hold (`holdMaxMinutes`, hold expiry of feature 6); the text must update, and when the hold ends the booking moves to EXPIRED and the row to the past tab.
- Which bookings are upcoming: CONFIRMED and PENDING_PAYMENT whose end is in the future; sorted by start ascending. The tab count is that number.
- Tap behaviour: Compact, the whole row pushes the booking details screen (`/bookings/<id>`); Medium+, tapping a row only changes the selected row and detail pane, and the selection must live in the address and survive fold/unfold. The first row is selected by default.
- "النهارده" replaces the weekday and date when the booking is today (also "بكره" is not shown in Figma; implementer asks Osman). Note the Medium cancel-dialog frames show the list pane as compact items (title + "النهارده · 5:00 – 6:00 م", fill `primary-soft` + 2px `primary` border when selected, 260 pane): a second list-item style that is not BookingRow; see booking-details-cancel-dialog.md.
- Screen reader: row = one node, label order: status, date and time, facility, notes, code (spelled, LTR), action. Segmented control announces "تبويب، الجاية 3، مختار". Badge count read as "2 إشعارات غير مقروءة".
- Pull to refresh uses the adaptive refresh primitive; loading uses skeleton rows, never a spinner (CLAUDE.md).
- Guests: the account gate screen "Account gate · My bookings" (Figma 105:2023) is a separate screen (auth reader).
- Motion: segmented selection slide and row press follow `SprintMotion`; wide detail change is a cross-fade; honour reduced motion.
- Past dates in the sample use no year; the implementer shows the year only when it differs from the current year (assumption to confirm).
