# Booking details · no-show

Covers: US-14, FR-MYB-02, BR-17 (no penalties, CLAUDE.md)
Node: Compact Light `252:6117` · Compact Dark `252:6364` · Medium Light `253:12863` · Medium Dark `253:13402` · Expanded Light `253:27375` · Expanded Dark `253:27926` · Large Light `253:28296` · Large Dark `253:28847`
Read status: Compact Light and (round 2) Medium Light 253:12863 design context. Expanded, Large, Dark NOT read. Copy note: this frame has no final period, while the same banner in My bookings (287:40343) ends with a period; pick one (see my-bookings-past.md).

## Layout (Compact)
Same as `booking-details-attended.md`, differences only:
- StatusBadge `no-show`: bg `surface-sunken`, text and icon `ink-muted` (neutral, never danger: no penalties), word "غاب", user-minus icon 16.
- Banner text (`primary-soft` hand-built frame): "الحجز ده عدّى من غير حضور. مفيش أي رسوم أو عقوبة".
- Everything else identical: date "الأحد 1 نوفمبر · 5:00 – 6:00 م", SP-1042, "داخلي", "المدفوع" "80 ج.م".

## Not in Figma
No refund for no-show (BR-31 applies only to CANCELLED). Dark not read.

## Medium (round 2, design context read) 
- Frame 720 x 1000: rail 88 plus a Main column (fills the rest, centred): padding vertical `space-8`, gap `space-4`. Heading "تفاصيل الحجز" (`title`, `ink`, start aligned) 520 wide; Content column 520 wide, padding top `space-4`, bottom `space-6`, horizontal `space-6` (so the card is 472), gap `space-3`. (Expanded: Content padding horizontal `space-4`, card 488; Expanded no-show frame NOT read, only the upcoming Expanded was.)
- Card as at Compact (fill `surface`, `radius-lg`, padding `space-4`, gap `space-2`); When chip `surface-sunken` with `ink` text.
- Banner (component Banner, tone info, `primary-soft` fill, `on-primary-soft` text): height 48 (one line fits at 472), padding `space-3`, gap `space-2`, radius `radius-md`, text `body`, icon icon/user-minus 20 at the end/left. Copy: "الحجز ده عدّى من غير حضور. مفيش أي رسوم أو عقوبة".
