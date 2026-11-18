# Search · empty (focused, no query)
Covers: US-01, FR-CAT-01 (FR-CAT-05 to be added for search)
Node: Compact Light 282:38683 · Dark 282:38719 (screenshot only, round 1) · Medium "Search · suggestions · empty field" Light 287:44897 · Dark 287:44952 (not read) · Expanded Light 287:45239 · Dark 287:45296 (not read) · Large 1440 Light 287:45353 · Dark 287:45410 (not read)
Images: images/search-empty-compact-{light,dark}.png · images/search-suggestions-empty-medium-light.png (Expanded/Large: not read)
Read again 2026-11-18 (round 2, Light).

## Layout
Compact (390 wide, full-screen pushed screen, no header/bell, tab bar still visible at bottom):
- Content (column, gap `space-6`, padding-x `space-4`, padding-bottom 120, top 54 under status bar, align end)
  - Search bar (row, gap `space-2`, centre, full width)
    - TextField type=search, state=focused (flex 1, 48 high, radius `radius-full`, fill `surface-sunken`, border 2 `primary`), placeholder, no clear button, magnifying-glass 20 at the end side
    - Button "إلغاء": text button, 120 x 48, padding-x `space-5`, radius `radius-md`, label `button` in `primary`; at the start (left in RTL)
  - Section label "الأكتر حجزًا" (`label`, `ink-muted`, full width)
  - Suggestion row x2 (row, gap `space-3`, 56 high, padding-y `space-3`): text column (gap `space-1`) with title + subtitle, sport icon 24 at the end (soccer-ball / swimming-pool)
  - Recent header (row, space-between, full width): Button "مسح الكل" at the start (120 x 48, padding-x `space-5`, radius `radius-md`, label `button` in `primary`, no fill) and label "بحثك الأخير" (`label`, `ink-muted`) at the end
  - Recent rows x4 shown (ملعب خماسي، سباحة، تنس، جيم): plain text `body`, `ink`, full width, no icon, no delete control. Rows have no fixed height (text line 24, spaced by the 24 content gap)
- Tab bar: AppNavigation form=tab-bar, selected المنشآت (stays selected even if opened from Home).
Medium (list-detail 720, rail 88): same popover idea as the typing state, no separate screen. The field sits in the list pane (300 wide). Popover: absolute left 288 / top 140, width 320, fill `surface`, border 1 `line`, radius `radius-lg`, `shadow-popover`, padding `space-4` x `space-3`, gap `space-2`, items aligned end. Content, top to bottom:
  - label "الأكتر حجزًا" (`label`, `ink-muted`, full width)
  - Suggestion x2 (56 high): "ملعب كرة القدم الرئيسي" (كرة قدم · إدارة استاد الجامعة) with soccer-ball, "مسبح استاد الجامعة" (سباحة · إدارة استاد الجامعة) with swimming-pool
  - Recent header (full width): "مسح الكل" button 120 x 48 at the start, "بحثك الأخير" label at the end (62 wide)
  - Recent rows x5, each 48 high, `body` `ink`, aligned end, width 286: ملعب خماسي، سباحة، تنس، جيم، كرة سلة
  The field in this frame shows the placeholder "البحث عن منشأة أو رياضة" and no clear button. The detail pane behind keeps the last facility. The focus border of the field was not checked.
Expanded/Large: not read (Expanded popover of the typing state is at left 556 / top 148 / width 326 under a 326 wide field in a 390 list pane; the empty-field popover is assumed the same).

## Text
- Placeholder: body 15/24, `ink-muted`, "البحث عن منشأة أو رياضة"
- "إلغاء", "مسح الكل": button 14/20 (Cairo SemiBold), `primary`
- "الأكتر حجزًا", "بحثك الأخير": label 14/20 SemiBold, `ink-muted`
- Suggestion title: body-strong 15/24, `ink`, 1 line; subtitle: caption 13/20, `ink-muted`, 1 line, "<sport> · <owning unit>"
- Recent: body 15/24 Regular, `ink`
- Tab labels micro 12/16 (selected `primary`, others `ink-muted`)

## States
- Focused + empty. Default (unfocused) is the entry field on Home/Facilities (search-entry-points.md).
- Up to 2 most-booked rows; recents: 4 drawn at Compact, 5 at Medium, so the cap is 5 (matches the brief; Figma does not state it).
- "مسح الكل" appears only when recents exist (assumed; the empty-recents state is not drawn).
- Loading/failure: not in Figma.

## Dark theme
Compact: token swap only (round 1 screenshot). Medium and wide: not read.

## Not in Figma
- "الأكتر حجزًا" source: not defined; use seed booking counts or fixed seed order, per spec. Stored on device: recents (max 5); tap a recent re-runs the query; "مسح الكل" empties the list.
- "إلغاء" closes search and returns to the previous screen (Compact only).
- Screen-reader: field label "البحث عن منشأة أو رياضة"; icons decorative; each suggestion read as "title، subtitle"; "مسح الكل" read as is.
- Targets: "إلغاء" and "مسح الكل" are 48 high. Compact recent rows have no height set (text 24 + gap): make the tap area at least 48 in code (Medium rows are 48).
