# Search · no results with an active filter
Covers: US-01, FR-CAT-01 (FR-CAT-05)
Node: Compact Light 282:38821 (frame named "Facilities · no results · filters on") · Dark 282:38874 · Medium Light 282:40583 · Dark 282:40711 · Expanded Light 282:40839 · Dark 282:40966 · Large 1440 Light 282:41093 · Dark 282:41220
Images: images/search-no-results-compact-{light,dark}.png · search-no-results-medium-light.png · search-no-results-expanded-light.png
Read again 2026-11-18 (round 2, Light): Compact and Medium by design context, Expanded screenshot. Not read: all Dark except the round 1 Compact screenshots, Large.

## Layout
Compact (390): header (NotificationBell 48 with badge "2" at the start, title "المنشآت" at the end), field (state=filled, value "سكواش", clear 48 x 48 with 20 icon at the start, no focus border), filter row as search-results.md with the "مجاني" chip selected (fill `primary`, text `on-primary`) and "الكل" unselected. **The count line is removed**: after the filter row comes directly:
- Results (column, gap `space-3`): Spacer 24 high, LottieMoment empty-search (300 wide, centred, gap `space-4`: 160 art, title, message), then Button "مسح الفلاتر": secondary (fill `surface`, 1px `control-border`, radius `radius-md`, 48 high, full width, `button` label in `ink`).
- Art "Final frame" (160): `surface-sunken` disc, `line` ring 136 inset 12, `ink-muted` glass glyph 64 at (48,48). Plays once, final frame under reduced motion.
Medium (720): single pane (no detail pane), list pane flex with content 560 wide centred (padding `space-6`, top `space-6`), title "المنشآت" (no bell), field, chips wrapping (funnel button first, then بمدرب · مجاني (selected) · كرة قدم · سباحة · الكل), then the same results stack, the button full width of the 560 column. Rail 88 at the end with Notifications badge 2.
Expanded (1194, screenshot): sidebar 280 at the end, a single centred column about 640 wide (field, chips in one row, art, text, button about 320 wide). No detail pane. Large: not read.

## Text
- No count line in any size (removed in Figma; the earlier `0 نتايج لـ ...` copy is obsolete).
- Title: title 20/30 (Cairo SemiBold), `ink`, centred: "مفيش نتايج للبحث ده"
- Message: body 15/24, `ink-muted`, centred: "ممكن البحث باسم رياضة أو منشأة تانية"
- Button: "مسح الفلاتر"
- Copy note: the message suggests another query and does not mention the active filter; "مسح الفلاتر" is the recovery.

## States
Active filter + no results. "مسح الفلاتر" resets the chips to "الكل" and keeps the query (assumed). No-results without a filter (query only): no frame; the button is absent (assumption). Loading/failure: not drawn.
Since the count line is gone, the screen-reader announcement must come from the title ("مفيش نتايج للبحث ده"), as a live region.

## Dark theme
Compact: token swap (round 1 screenshot). Medium and wide: not read; art layers follow tokens (`surface-sunken`, `line`, `ink-muted`).

## Not in Figma
- Lottie tinted from tokens at runtime; art excluded from screen readers; the text states the state (component description).
- Chip border token is `control-border`.
