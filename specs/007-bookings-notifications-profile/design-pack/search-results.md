# Search · results
Covers: US-01, FR-CAT-01 (FR-CAT-05)
Node: Compact Light 263:7268 · Dark 263:7460 · Medium Light 265:15031 · Dark 265:15195 · Expanded Light 265:31637 · Dark 265:31804 · Large 1440 Light 265:32067 · Dark 265:32234
Images: images/search-results-compact-{light,dark}.png · search-results-medium-light.png

## Layout
Compact: it is the Facilities screen with the field filled (header and tab bar kept).
- Content (column, gap `space-6`, padding-x `space-4`, top 54)
  - Header (row, space-between, 48): NotificationBell (48, badge count "2") at start; title "المنشآت" at end (title-lg 26/36 Bold, `ink`)
  - TextField type=search, state=filled + Show clear (NOT focused: no 2px border; fill `surface-sunken`, radius `radius-full`, 48 high), value "سباحة", clear button 48x48 (icon 20) at start, magnifier at end (re-read 2026-11-18: layout otherwise unchanged)
  - Filters row (row, gap `space-2`, justify end, height 40; a single scrolling row): More-filters funnel button 40x40 round, then chips بمدرب · مجاني · كرة قدم · سباحة · الكل (the Home/Facilities order; "الكل" is last = first in RTL). Chip: height 40, padding-x `space-4`, radius `radius-full`, label `label` 14/20. Unselected: fill `surface`, 1px border `control-border`, text `ink`. Selected ("الكل"): fill `primary`, text `on-primary`, no border. Funnel button: fill `surface`, 1px `control-border`.
  - Result count line: caption 13/20, `ink-muted`: `منشأتين لـ "سباحة" · مرتبين بالمتاح النهارده`
  - Results (column, gap `space-3`): FacilityCard variant horizontal (compact search list): radius `radius-lg`, fill `surface`, `shadow-card`; body at start with padding `space-4` x `space-3`, photo 112 wide at the end side (placeholder "صورة", `surface-sunken`, caption `ink-muted`); no tags in this variant. Body: name headline 17/26 SemiBold `ink`; "<owning unit> · <n> حارات" caption `ink-muted`; availability row (caption; icon 16 after the text) in `success` with check, or `warning` with clock; divider 1px `line`; row "سعر الطلاب والعاملين" (caption, `ink-muted`) + price body-strong "80 ج.م".
Medium (list-detail 720, rail 88 at the end): list pane 300 wide (padding `space-6` x, top `space-6`, bottom `space-8`, gap `space-4`) holds: title "المنشآت" (no bell: rail carries the badge), field with clear, wrapped filter chips (flex-wrap, gap `space-2`), count line, vertical FacilityCard (photo 136 high on top with up to 2 tags at top-end: "بمدرب" on `primary-soft`/`on-primary-soft`, sport tag on `surface`/`ink`; body padding `space-4`). The selected card has a 2px `primary` border. Detail pane (flex 1, padding `space-6`, gap `space-5`) shows the selected facility: photos 140, name title 20/30, price line caption, DayStrip, slot grid, sticky Summary card with "تأكيد الحجز · 80 ج.م" (`shadow-sheet`). In results mode the first result is auto-selected.
Expanded (1194, round 2, screenshot): sidebar 280 at the end (logo, 5 items, Notifications badge 2), list pane 390 (padding `space-8`: title, field with clear, chips wrapping to 2 rows with the funnel first, count line, 2 horizontal cards (same as Compact: photo about 112 at the end side, no tags; unlike Medium's vertical cards)), detail pane flex with the first result selected (2px `primary` border): photos, name, DayStrip, slot grid, summary card with "تأكيد الحجز · 80 ج.م". Large 1440 (screenshot): same structure with a wider sidebar and detail pane. Numbers for Expanded/Large not read by design context.

## Text
- Count line: `منشأتين لـ "سباحة" · مرتبين بالمتاح النهارده` (caption 13/20, `ink-muted`)
- Card 1: "حمام السباحة الأوليمبي" · "كلية التربية الرياضية · 8 حارات" · "14 مكان فاضي النهارده" (success) · "سعر الطلاب والعاملين" · "80 ج.م"
- Card 2: "مسبح استاد الجامعة" · "إدارة استاد الجامعة · 4 حارات" · "9 أماكن فاضية النهارده" (warning) · "60 ج.م"
- Chips: "بمدرب", "مجاني", "كرة قدم", "سباحة", "الكل"
- Plural forms Figma shows: 2 = "منشأتين". Zero: the no-results frames no longer show a count line (removed in Figma), so no zero form is needed. Other forms (1, 3 to 10, 11+) are not drawn; the existing `catalogueResultCount` gives =1 "منشأة واحدة", few "N منشآت", other "N منشأة". Spec must pick one set (zero needs no count text, see search-no-results.md).

## States
Results, no-result (search-no-results.md), loading and failure not drawn for search. Cards are whole-tap targets, no buttons inside.

## Dark theme
Token swap only (Compact dark screenshot checked: same layout). Cards: `surface-raised`/no shadow per tokens (`shadow-card` is none in dark).

## Not in Figma
- What is searchable: Figma shows facility name and sport (query "سباحة" matches both facilities by sport and name "مسبح/السباحة"). Owning unit appears in subtitles so it is implied; unit names, descriptions and trainers are not shown. Spec decides; recommended: facility name, sport/type label, owning unit name, normalised Arabic (tashkeel, alef forms, ta marbuta).
- Ordering: "مرتبين بالمتاح النهارده" = descending by places free today (14 before 9); tie-break not drawn (suggest name).
- Facilities filter chips and the search query combine with AND; chip filters stay (kept across navigation, feature 4).
- Share link and details behaviour as feature 4.
- Medium+: card tap changes the detail pane without leaving search (query stays).

- Round 2 (2026-11-18): Medium Light and Compact Light results re-checked only for the clear button size; images/search-results-compact-light.png refreshed; search-results-{expanded,large}-light.png added. Medium Dark and Expanded/Large Dark: not read.
