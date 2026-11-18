# Search · typing
Covers: US-01, FR-CAT-01 (FR-CAT-05)
Node: Compact Light 263:7208 · Dark 263:7435 (screenshot only, round 1) · Medium "Search · suggestions" Light 282:39499 · Dark 282:39615 · Expanded Light 282:39859 · Dark 282:39979 · Large 1440 Light 282:40099 · Dark 282:40219
Images: images/search-typing-compact-{light,dark}.png · images/search-suggestions-medium-{light,dark}.png · search-suggestions-expanded-light.png · search-suggestions-large-light.png
Read again 2026-11-18 (round 2, Light): Compact and Medium by design context, Expanded design context (popover numbers only), Expanded/Large screenshots.

## Layout
Compact: same shell as search-empty.md (Search bar with "إلغاء", Content gap `space-6`), with differences:
- TextField type=search, state=focused with Show clear: 2px `primary` border, value "سباحة" in `ink` (body 15/24). Clear button is now 48 x 48 (named "Clear (48 hit area)") with an x-circle icon 20, at the start (left in RTL) inside the 48 high field; magnifying-glass 20 stays at the end. The field's end padding is `space-4`.
- Label "اقتراحات" (label 14/20, `ink-muted`) replaces both section labels and the recent header.
- 2 Suggestion rows (56 high): "حمام السباحة الأوليمبي" (سباحة · كلية التربية الرياضية), "مسبح استاد الجامعة" (سباحة · إدارة استاد الجامعة), swimming-pool icon 24.
- No recents, no filters while typing.
Medium (720): popover under the field, absolute left 288 / top 140, width 320, fill `surface`, border 1 `line`, radius `radius-lg`, `shadow-popover`, padding `space-4` x `space-3`, gap `space-2`. Label "اقتراحات" + the same 2 rows. Field shows "سبا" with the 48 clear button. Rail 88 at the end; no bell.
Expanded (1194): sidebar 280 at the end, list pane 390 (padding `space-8`, gap `space-4`), detail pane flex. Popover left 556 / top 148 / width 326, same content (`shadow-popover`). Field has the 2px `primary` border (screenshot). Large 1440 (screenshot): same structure, popover aligned under the field, sidebar wider; numbers not read.
At Medium and up the popover shows the typing state "اقتراحات" with no recents (recents and "الأكتر حجزًا" belong to the empty-field popover, search-empty.md).

## Text
As search-empty.md. Typed text is `ink` (not `ink-muted`), same in every frame, per component description.

## States
Typing = focused + filled + clear whenever there is text. Two suggestions drawn that match the text (matching rule not in Figma, see search-results.md). Pressing the search key opens results; tapping a suggestion opens that facility (assumption, not drawn).

## Dark theme
Compact and Medium: token swap only (screenshots). Wide: not read.

## Not in Figma
- Suggestion matching, debounce, highlight of matched characters (none), max rows.
- Clear tap empties the text and shows the empty state (component description); keeps focus.
- Screen reader for clear: "مسح البحث" (suggested; no label in Figma).
- Component text in Figma still says the clear hit area is "the 40px button inside the 48 field"; the frames now draw 48 x 48. Treat 48 as correct (48dp rule) and ask Osman to fix the description.
