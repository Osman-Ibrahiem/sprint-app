# Search entry points (Home and Facilities) and the SprintTextField search variant
Covers: US-01, FR-CAT-01 (FR-CAT-05)
Node: Home booker Compact Light 14:2 (field instance 14:48) · Facilities Compact Light 14:124 (field 14:159) · TextField component 10:123 (search variants: default 10:91 children, focused 10:97/10:99, filled 282:38210, Show clear 282:38224)
Round 2 (2026-11-18) screenshots read: Home booker Medium Light 243:10530, Expanded Light 243:23868, Facilities Medium Light (filters popover frame) 266:7386, Expanded Light 267:16829. Not read: Large 243:25304/243:26472 and all Dark; Home guest 243:5278/243:5432, 243:10648/243:11699, 243:23989/243:25067, 243:25425/243:26503; Facilities Compact Dark 19:726/19:833; Facilities list-detail Medium 20:2/20:166 · Expanded 22:128/22:313.
Images: images/home-booker-{medium,expanded}-light.png · facilities-search-field-{medium,expanded}-light.png.

## Layout
Compact Home (390x844): Content column; Header (358 x 64: bell at start, greeting at end); TextField at y 88 (16 from sides), 358 x 48; then "حجزك الجاي" section. Compact Facilities: Header 48 (bell + title "المنشآت"), TextField at y 72, 358 x 48, 24 below header; Filters row at y 144; count line at y 208; results from y 252.
Entry field = SprintTextField type=search, state=default: fill `surface-sunken`, radius `radius-full`, 48 high, no border, padding-x `space-4`, gap `space-2`; placeholder at the start side in `ink-muted`, magnifying-glass 20 at the end (not mirrored).
Behaviour: tapping the field opens the search screen at Compact (field focused, "إلغاء" shown); at Medium+ the field is in the list pane and the popover opens in place.

## Wide entry points (round 2, from screenshots only; no design context, numbers approximate)
- Home booker Medium (720, rail 88 at the end, no bell, no logo): greeting "أهلًا يا سارة" with the subtitle, then the search field full width of the content column (about 512 x 48, x 60 to 572, y 120), then "حجزك الجاي" and "فيه أماكن النهارده". Field is state=default (placeholder, magnifier at the end, no border).
- Home booker Expanded (1194, sidebar 280): the field sits in the same position under the greeting (screenshot; width not measured).
- Facilities Medium: title "المنشآت" at top, then the field (512 wide) with the value "سباحة" and the clear button, filter chips, count line, cards. The frame shows the filters popover (funnel) open; it is a filter popover, not a search surface.
- Facilities Expanded: field at the top of the 390 list pane, same chip rows.
- Where tapping leads at Medium+: Figma draws no separate screen. In the Facilities list-detail the popover opens under the field (search-typing.md, search-empty.md). For the Home field the destination is NOT drawn (assumption: navigate to Facilities with the field focused and the popover open). Ask Osman if the Home field should open the popover in place instead.

## Text
- Placeholder: body 15/24 Regular, `ink-muted`: "البحث عن منشأة أو رياضة" (same on Home and Facilities)

## SprintTextField search variant (from get_design_context, node 10:123 family)
- default: placeholder `ink-muted`, no border.
- focused: 2px `primary` border; value or placeholder.
- filled: typed text `ink` (same colour in every frame), 1px none border.
- Show clear: 48x48 hit area (frames, round 2) holding x-circle 20 at the start side, whenever text exists. The component description still says 40; use 48.
- Compact search screen adds a "إلغاء" text button next to the field.
Compared with docs/design-system/components/TextField/README.md: it lists `search` as a pill on `surface-sunken` but does not list the clear button, "filled" colour rule, or "إلغاء"; update the README (the repo wins, ask Osman whether the Figma description is adopted).

## Not in Figma
- Not read: Large Home and Facilities, guest Home at every size, dark, and design context (numbers) for the wide entry frames. Metadata says the Home field is 358 wide at Compact, and Facilities Compact field is 358 wide.
- Guests: component description says the bell is hidden for guests; search entry unchanged (assumption; verify in Home guest frame 243:5278).
- Keyboard: search key submits; Escape closes popover on keyboard platforms; `/` focus shortcut (web) not drawn.
