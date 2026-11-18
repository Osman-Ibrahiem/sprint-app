# My bookings, past tab

Covers: US-14, FR-MYB-02
Node: Compact Light 252:6195 · Compact Dark 252:6422 · Medium Light 253:13093 · Medium Dark 253:13456 · Expanded Light 253:27611 · Expanded Dark 253:27980 · Large 1440 Light 253:28532 · Large 1440 Dark 253:28901
Round 2 variants (selected row changes the detail pane): no-show selected Medium Light 287:40343 (Dark 287:40503), Expanded Light 287:41503, Large Light 287:41823; cancelled selected Medium Light 287:40375 (Dark 287:40535), Expanded Light 287:41535, Large Light 287:41855. Past empty: see my-bookings-empty.md.
Images: images/my-bookings-past-<compact|medium|expanded|large>-<light|dark>.png; my-bookings-past-no-show-selected-medium-light.png; my-bookings-past-cancelled-selected-medium-light.png.
Read depth (round 2): Compact Light fully (round 1). Medium Light past 253:13093, no-show selected 287:40343 and cancelled selected 287:40375: design context read. Expanded, Large, all Dark: not re-read (round-1 screenshots only; Expanded/Large no-show and cancelled frames NOT read).

## Layout

### Compact (390 x 844)
Same as my-bookings.md except:
- SegmentedControl: selected = past (the "اللي فاتت" segment gets the white `surface` thumb with `ink` text; "الجاية (3)" is `ink-muted`). Past has no count.
- BookingRows (all 154 high, single-line header, action "التفاصيل"):
  1. ATTENDED: badge "حضر" (`on-primary-soft` on `primary-soft`, check icon), chip "الأحد 1 نوفمبر · 5:00 – 6:00 م", "حمام السباحة الأوليمبي", "حارة 3 · مع الكابتن أحمد سامي", SP-1042.
  2. NO_SHOW: badge "غاب" (`ink-muted` on `surface-sunken`, user-minus icon), chip "الجمعة 30 أكتوبر · 8:00 – 9:00 م", "ملعب كرة القدم الرئيسي", "الملعب كله · لحد 22 لاعب", SP-1038.
  3. CANCELLED: badge "اتلغى" (`danger` on `danger-soft`, x-circle icon), chip "الخميس 29 أكتوبر · 6:00 – 7:00 م", "ملعب الاستاد الخماسي", "ملعب 2 · مجاني", SP-1027.
- Date chips are all `surface-sunken` with `ink` text (never volt in the past).
- Order: newest first (descending). Row action for every past status is "التفاصيل" (primary, `label`).
- Bell, header, tab bar as in my-bookings.md; navigation destination stays حجوزاتي.

### Medium (720 x 1000), read in round 2
- Three columns right to left: rail 88, list pane 300 (padding top `space-6`, bottom `space-8`, horizontal `space-6`), detail pane flex (padding top `space-6`, bottom `space-8`, horizontal `space-6`; heading "تفاصيل الحجز" `title`, then Content column gap `space-3`, top padding `space-4`, bottom `space-6`).
- List pane rows (BookingRow, 252 wide): attended 194 when selected (2px `primary` border) else 190; no-show 190 (194 when selected); cancelled 190 (194 when selected). Exactly one row is selected; the selected row decides the detail pane. First row is selected by default.
- Detail card (all three statuses): fill `surface`, `radius-lg`, padding `space-4`, gap `space-2`, no shadow: header (StatusBadge at the end, facility `headline` at the start), notes `caption` `ink-muted`, When chip (`surface-sunken`, `radius-sm`, padding h `space-3` v `space-2`, icon clock 20, text `label` `ink`; never volt in the past), code row (`code` `ink` LTR / "رقم الحجز" `body` `ink-muted`), then rows (value `body-strong` `ink`, label `body` `ink-muted`, gap `space-3`). No QR and no action button for past statuses.
- Banner below the card (the Banner component, see components-banner.md), full width, radius `radius-md`, padding `space-3`, gap `space-2`, height 72 at Medium (text wraps to two lines at 472 wide), text `body`, icon 20 at the end/left:
  | Selected row | Badge | Card content | Rows | Banner tone, icon, copy |
  | --- | --- | --- | --- | --- |
  | Attended (253:13093) | "حضر" `primary-soft` / `on-primary-soft`, check | "حمام السباحة الأوليمبي", "حارة 3 · مع الكابتن أحمد سامي", "الأحد 1 نوفمبر · 5:00 – 6:00 م", SP-1042 | "الشريحة" "داخلي"; "المدفوع" "80 ج.م" | info (`primary-soft`, `on-primary-soft`), check, "تم تسجيل حضورك. شكرًا لاستخدامك سبرنت" |
  | No-show (287:40343) | "غاب" `surface-sunken` / `ink-muted`, user-minus | "ملعب كرة القدم الرئيسي", "الملعب كله · لحد 22 لاعب", "الجمعة 30 أكتوبر · 8:00 – 9:00 م", SP-1038 | "الشريحة" "داخلي"; "المدفوع" "300 ج.م" | info, user-minus, "الحجز ده عدّى من غير حضور. مفيش أي رسوم أو عقوبة." (with a final period) |
  | Cancelled (287:40375) | "اتلغى" `danger-soft` / `danger`, x-circle | "ملعب الاستاد الخماسي", "ملعب 2 · مجاني", "الخميس 29 أكتوبر · 6:00 – 7:00 م", SP-1027 | "الشريحة" "داخلي"; "السعر" "مجاني" | neutral (`surface-sunken` fill, text `ink`), info icon, "الحجز اتلغى والمكان رجع متاح لغيرك. الحجز كان مجاني فمفيش مبلغ يرجع." |
- Cancelled paid or by-admin selected states (refund line) are not drawn in these frames: only the free cancelled booking. Use booking-cancelled.md for the refund copy.
- Placeholder price: the no-show row says 300 ج.م paid while the sample booking SP-1038 pending payment elsewhere is 80 ج.م (same code SP-1038, different amount: see contradictions in the report).

### Expanded and Large
- Same three columns as my-bookings.md (list pane 360 / 400, detail flex, sidebar 280). The attended frames (253:27611, 253:28532) were round-1 screenshots only; the no-show and cancelled selected frames (Expanded 287:41503 / 287:41535, Large 287:41823 / 287:41855) exist but were NOT read: assume the same detail card and banner as Medium with wider content.

## Text
- Same styles as my-bookings.md. Only copy that differs: badge words حضر, غاب, اتلغى; action "التفاصيل"; banners per the table above.

## States
- Past tab with items (this screen). Past tab empty: my-bookings-empty.md (drawn since round 2).
- Detail pane per selected status: attended, no-show, cancelled (free). EXPIRED has a Booking details screen (booking-details-expired.md) but no past row or selected variant in My bookings; EXPIRED rows should behave the same (detail pane = expired card + info banner).
- Row status variants present: ATTENDED, NO_SHOW, CANCELLED. EXPIRED (انتهت المهلة, `ink-muted` on `surface-sunken`) is part of the status set but no past row shows it.

## Dark theme
- Token swap only. Notes: "حضر" badge reads as light blue text on a dark blue pill; the banner is a dark blue fill with light text; date chips are near-black (`surface-sunken`); the selected-row border is a pale periwinkle (`primary` dark).

## Not in Figma
- Past = ATTENDED, NO_SHOW, CANCELLED, EXPIRED and CONFIRMED whose end passed without an attendance record (treated as upcoming until the trainer records it: spec decision). Cancelled upcoming bookings appear here immediately.
- "No penalties": NO_SHOW stays neutral (no red, no warning wording).
- Tab switch keeps window position and the selected booking in the address (`?tab=past`).
- Screen reader for a past row adds the status word first (حضر / غاب / اتلغى).
- Pagination/lazy loading of long history is not drawn; implementer uses a simple list in P1.
