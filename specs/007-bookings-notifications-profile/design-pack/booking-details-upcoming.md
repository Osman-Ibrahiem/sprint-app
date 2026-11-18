# Booking details · upcoming (confirmed)

Covers: US-13, US-14, FR-MYB-02, FR-PAY-04, BR-17, BR-30
Node: Compact Light `252:6018` · Compact Dark `252:6307` · Medium Light `253:12632` · Medium Dark `253:13350` · Expanded Light `253:27138` · Expanded Dark `253:27874` · Large 1440 Light `253:28059` · Large 1440 Dark `253:28795`
Figma sections: "Bookings & status · Compact" (compact), Medium / Expanded / Large frames have no section.
Read status: Compact Light read fully (design context + screenshot `images/booking-details-upcoming-compact-light.png`). Medium Light read (design context only, no screenshot: limit hit). Dark, Expanded, Large NOT read.

This file holds the shared "booking details shell" that the other booking-details files refer to.

## Layout (Compact, 390 x 844)
- Root: `bg`. Status bar 54 high (system, not built). 
- AdaptiveAppBar (44 high, y=54, `bg`): back "رجوع" (`body`, `primary`, caret-right icon 24, mirrored, gap `space-1`) at the start; title "تفاصيل الحجز" (`headline`, `ink`) centred (iOS pushed-screen form).
- Content (column, gap `space-3`, padding top `space-4`, bottom `space-6`, horizontal `space-4`; starts y=98; scrolls under the action bar):
  - Booking card: `surface`, radius `radius-lg`, padding `space-4`, column gap `space-2`, full width. Children in order:
    1. Header row (space-between): title at the start = facility name (`headline`, `ink`, 1 line); StatusBadge at the end (28 high, padding horizontal `space-3`, gap `space-1`, `radius-full`, `micro`). Upcoming = `confirmed`: bg `success-soft`, text and icon `success`, word "مؤكد", check-circle icon 16.
    2. Sub-line: unit and trainer, "حارة 3 · مع الكابتن أحمد سامي" (`caption`, `ink-muted`).
    3. When strip: full width, `volt` fill, text `on-volt`, radius `radius-sm`, padding horizontal `space-3` vertical `space-2`, gap `space-2`, content centred; clock icon 20 + "الأحد 8 نوفمبر · 5:00 – 6:00 م" (`label`). 1 line (no wrap rule in Figma; implementer must allow wrapping at 200% text).
    4. QR wrap: centred, QRCode 160 x 160 (`qr-ink` on `qr-ground`, always, both themes; 12 quiet zone is inside the 160).
    5. Code row (space-between, 24 high): code at the end side "SP-1042" (`code`: Cairo 500 17/24, letterSpacing 0.08em = 1.36px, `ink`, in an LTR isolate); label "رقم الحجز" at the start (`body`, `ink-muted`).
    6. Row "الشريحة" / "داخلي" (label at the start `body` `ink-muted`; value at the end `body-strong` `ink`). Row gap `space-3`.
    7. Row "المدفوع" / "80 ج.م" (same styles).
- Action bar (pinned bottom, y=750, `surface`, padding top `space-3`, horizontal `space-4`, bottom 34 = home-indicator safe area, no token): one danger SprintButton, full width, 48 high, radius `radius-md`, bg `danger`, label "إلغاء الحجز" (`button`, `on-danger`). Opens the cancel dialog (see `booking-details-cancel-dialog.md`).

## Medium (720 x 1000)  (read: design context)
- Row, RTL: AppNavigation rail (88 wide, `surface`, right edge with `line` border on its start side) on the physical right; Main fills the rest. No list pane in the upcoming frame (the cancel-dialog Medium frame DOES show a 260 list pane, see `booking-details-cancel-dialog.md`: the two are inconsistent).
- Main: column, centred, gap `space-4`, padding vertical `space-8`. Page title "تفاصيل الحجز" (`title` 20/30 600, `ink`) aligned to the start in a 520-wide column (no app bar). Content width 520, padding horizontal `space-6`. Card identical to compact (QR still 160). Cancel button is NOT in an action bar: a full-width 520 danger button below the card.
- Rail items: الرئيسية، المنشآت، حجوزاتي (selected, `primary-soft` indicator 56 x 32, label `on-primary-soft`, ticket-fill icon), الإشعارات (badge "2", `danger`), حسابي. Labels `micro`.
## Expanded / Large 1440
Not read (call limit). Only screenshots would be needed; frames exist: Expanded `253:27138`, Large `253:28059`.

## Text
- Title: `title`/`headline` tokens above; facility name `headline` `ink`.
- Exact copy: "تفاصيل الحجز", "رجوع", "مؤكد", "حمام السباحة الأوليمبي", "حارة 3 · مع الكابتن أحمد سامي", "الأحد 8 نوفمبر · 5:00 – 6:00 م", "رقم الحجز", "SP-1042", "الشريحة", "داخلي", "المدفوع", "80 ج.م", "إلغاء الحجز".

## States
Verified (fixed items): tier row shows "داخلي" only (no "(سعر داخلي)" suffix); code is SP-xxxx (SP-1042); paid amount "80 ج.م".
Other states: see `booking-details-pending-payment.md`, `-attended.md`, `-no-show.md`, `-expired.md`, `-after-cutoff.md`, `booking-details-cancel-dialog.md`, `booking-cancelled.md`.

## Dark theme
Not read. Node ids above. Remember QR stays dark-on-white.

## Not in Figma
- The date, time and amounts are example data. The cancel button shows only while now < start − `cancellationCutoffHours` (BR-30, default 2); after it, see `booking-details-after-cutoff.md`.
- "الشريحة" comes from the tier frozen on the booking (BR-17); "المدفوع" = amount paid.
- QR encodes the signed `qrToken`, never the code; raise screen brightness while shown (component description).
- Screen-reader: card as one group "حجز مؤكد، حمام السباحة الأوليمبي، الأحد 8 نوفمبر 5:00 م"; QR needs an Arabic label (not in Figma). Code is read digit by digit in LTR.
- Text scaling to 200%: header row must wrap (facility name beside the badge).

## Expanded (round 2, design context read, node 253:27138 Light)
- Frame 1194 x 834: sidebar 280 (rows 44 high, see my-bookings.md for the sidebar anatomy) + Main column: padding vertical `space-8`, gap `space-4`, heading "تفاصيل الحجز" 520 wide (`title`), Content 520 wide with padding top `space-4`, bottom `space-6`, horizontal `space-4` (card 488 wide), gap `space-3`.
- Card as Compact/Medium: StatusBadge "مؤكد", facility, notes, When chip `volt` "الأحد 8 نوفمبر · 5:00 – 6:00 م", QR 160 centred, code row SP-1042, rows "الشريحة" "داخلي" and "المدفوع" "80 ج.م".
- Danger button "إلغاء الحجز": 520 wide (the Main column width, wider than the 488 card), 48 high, `radius-md`, below the card.
- Dark, Large and the other Expanded statuses NOT read.
