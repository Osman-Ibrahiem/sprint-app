# Account · language and appearance sheet / popover
Covers: US-14, FR-MYB-03
Node: Compact sheets Light: language 247:5800, appearance 247:5867 (Dark 247:6228, 247:6290) · Medium popovers Light: language 266:7458, appearance 266:7515 (Dark 266:7798, 266:7889) · Expanded 267:16901 / 267:16958 · Large 267:17730 / 267:17787 (Dark 267:17246, 267:17342, 267:18073, 267:18169)
Screenshots: none. Medium appearance popover 266:7515 read in round 2 (design context); language popover, Expanded, Large, Dark and the Compact sheets not re-read.
## Layout
### Compact: bottom sheet over Account (booker) + scrim
- Sheet: full width, `surface`, radius top 24, padding top `space-3`, x `space-4`, bottom 28, gap `space-4`, start-aligned. Language sheet top 574; appearance sheet top 510 (3 options).
- Grabber 40x4 `line`. Title. Option rows (height 48, padding-y `space-3`, label at the start, 22px radio at the end). Primary Button "تأكيد" full width 48.
### Medium and up: popover, no confirm button
- Popover 260 wide, `surface`, 1px `line`, radius `radius-lg`, padding `space-4`, gap `space-3`, shadow `shadow-popover`. Anchored beside the row (language popover at x=52, y=432 in the 720 frame, i.e. at the inline-start side of the settings card, near its row).
- Options only (no title, no button): Medium appearance popover (read, round 2): 3 option rows, each 48 high (fixed, was 44 in round 1), label `body` `ink` at the start edge ("حسب الجهاز", "فاتح", "داكن"), 22 radio at the end (filled ring for the selected one, "حسب الجهاز"). Popover absolutely placed at x=52, y=484 of the 720 frame (beside the المظهر row, on the chevron side), over Account with the settings card showing value "حسب الجهاز". Selecting applies immediately and closes.
- Language popover rows were 44 in round 1 and were not re-read: assume 48 like the appearance popover, but verify.
## Text
- Sheet titles "اللغة" / "المظهر": `title`, `ink`. Options `body`, `ink`: "العربية", "English"; "حسب الجهاز", "فاتح", "داكن". Button "تأكيد": `button`, `on-primary`.
## States
- Selected radio: filled ring (asset), unselected: empty ring. Pre-selected: العربية / حسب الجهاز.
- The Account behind shows the booker view, which proves the guest account uses the same sheet (not drawn for guest).
## Dark theme
Not read.
## Not in Figma
- Switching language flips RTL/LTR live; keep state across the switch. Appearance follows the system by default (BR/NFR in the design system README). The component name in Figma is Popover (components-popover.md).
