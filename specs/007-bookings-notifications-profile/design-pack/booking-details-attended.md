# Booking details · attended

Covers: US-14, FR-MYB-02, BR-17
Node: Compact Light `252:6078` · Compact Dark `252:6335` · Medium Light `253:12748` · Medium Dark `253:13375` · Expanded Light `253:27257` · Expanded Dark `253:27899` · Large Light `253:28178` · Large Dark `253:28820`
Section: "Bookings & status · Compact". Read status: Compact Light and (round 2) Medium Light 253:12748 design context. Expanded, Large, Dark NOT read; no screenshot saved.

## Layout (Compact)
Same shell as `booking-details-upcoming.md`. Differences:
- StatusBadge `attended`: bg `primary-soft`, text and icon `on-primary-soft`, word "حضر", check icon 16.
- When strip is `surface-sunken` with `ink` text (not volt): "الأحد 1 نوفمبر · 5:00 – 6:00 م".
- No QR, no action bar. Rows: "الشريحة" "داخلي", "المدفوع" "80 ج.م". Code "SP-1042".
- A note banner after the card (hand-built frame, NOT the Banner component): bg `primary-soft`, radius `radius-md`, padding `space-3`, gap `space-2`, text `body` `on-primary-soft` filling the width, icon 20 at the end side in the layer is named "icon/clock" (the Compact layer is named icon/clock but the Medium frame and the component list use icon/check: use check).
- Text: "تم تسجيل حضورك. شكرًا لاستخدامك سبرنت".

## States / Dark
Final state. Dark not read.

## Not in Figma
Past booking: no cancel, no QR. Possible "احجز تاني" shortcut is not designed (do not add). The Banner component now has an info tone = `primary-soft` (components-banner.md), so this is the Banner instance at Medium (Compact frame may still be hand-built: check).

## Medium (round 2, design context read) 
- Frame 720 x 1000: rail 88 plus a Main column (fills the rest, centred): padding vertical `space-8`, gap `space-4`. Heading "تفاصيل الحجز" (`title`, `ink`, start aligned) 520 wide; Content column 520 wide, padding top `space-4`, bottom `space-6`, horizontal `space-6` (so the card is 472), gap `space-3`. (Expanded: Content padding horizontal `space-4`, card 488; Expanded attended frame NOT read, only the upcoming Expanded was.)
- Card as at Compact (fill `surface`, `radius-lg`, padding `space-4`, gap `space-2`); When chip `surface-sunken` with `ink` text.
- Banner (component Banner, tone info, `primary-soft` fill, `on-primary-soft` text): height 48 (one line fits at 472), padding `space-3`, gap `space-2`, radius `radius-md`, text `body`, icon icon/check 20 at the end/left. Copy: "تم تسجيل حضورك. شكرًا لاستخدامك سبرنت".
