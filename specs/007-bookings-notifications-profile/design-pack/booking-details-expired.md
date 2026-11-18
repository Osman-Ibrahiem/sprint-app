# Booking details · expired

Covers: US-13, US-14, FR-MYB-02, BR-17
Node: Compact Light `252:6156` · Compact Dark `252:6393` · Medium Light `253:12978` · Medium Dark `253:13429` · Expanded Light `253:27493` · Expanded Dark `253:27953` · Large Light `253:28414` · Large Dark `253:28874`
Read status: Compact Light and (round 2) Medium Light 253:12978 design context. Expanded, Large, Dark NOT read. Medium amount row confirmed: label "المبلغ", "80 ج.م" over "ما اتدفعش" (`caption`, `ink-muted`).

## Layout (Compact)
Same as `booking-details-attended.md`, differences:
- StatusBadge `expired`: bg `surface-sunken`, text/icon `ink-muted`, word "انتهت المهلة", clock icon.
- Amount row is two lines and top-aligned: label at the start "المبلغ" (`body`, `ink-muted`); at the end a column: "80 ج.م" (`body-strong`, `ink`) over "ما اتدفعش" (`caption`, `ink-muted`).
- Banner (`primary-soft` frame): "المهلة خلصت من غير دفع، والمكان رجع متاح".
- Facility is the pool sample ("حمام السباحة الأوليمبي", "حارة 3 · مع الكابتن أحمد سامي", SP-1042, date "الأحد 1 نوفمبر · 5:00 – 6:00 م").

## States
Verified fixed item: label is "المبلغ" with sub-line "ما اتدفعش" (not "المدفوع").

## Not in Figma
No money was taken, so no refund row. A booking EXPIRED by BR-46 late success is auto-refunded and is a different story (not designed here).

## Medium (round 2, design context read) 
- Frame 720 x 1000: rail 88 plus a Main column (fills the rest, centred): padding vertical `space-8`, gap `space-4`. Heading "تفاصيل الحجز" (`title`, `ink`, start aligned) 520 wide; Content column 520 wide, padding top `space-4`, bottom `space-6`, horizontal `space-6` (so the card is 472), gap `space-3`. (Expanded: Content padding horizontal `space-4`, card 488; Expanded expired frame NOT read, only the upcoming Expanded was.)
- Card as at Compact (fill `surface`, `radius-lg`, padding `space-4`, gap `space-2`); When chip `surface-sunken` with `ink` text.
- Banner (component Banner, tone info, `primary-soft` fill, `on-primary-soft` text): height 48 (one line fits at 472), padding `space-3`, gap `space-2`, radius `radius-md`, text `body`, icon icon/hourglass 20 at the end/left. Copy: "المهلة خلصت من غير دفع، والمكان رجع متاح".
