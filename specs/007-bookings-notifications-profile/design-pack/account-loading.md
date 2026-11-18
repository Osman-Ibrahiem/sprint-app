# Account · loading
Covers: US-14, FR-MYB-03
Node: Compact Light 256:6496 (read, round 2), Dark 256:6868 (not read)
Screenshots: images/account-loading-compact-light.png
## Layout
### Compact
- Content (column, gap `space-5`, padding top `space-2`, x `space-4`, bottom 120, from y=54, end-aligned):
  1. Header row (space-between, height 48): NotificationBell 48 in the unread=false variant (bell only, no badge) at the physical left; title "حسابي" (`title-lg`, `ink`) at the right.
  2. Skeleton card, full width, 140 high (the Skeleton `list-row` component with a height override): `surface`, radius `radius-lg`, padding x `space-4` y `space-3`, gap `space-3`, items centred.
  3. Two Skeleton rows, full width, 72 high, same component (`surface`, radius `radius-lg`).
  Each Skeleton: trailing pill 64x24, spacer, text column (title bar 150x16, subtitle bar 110x12, gap `space-2`, radius `radius-sm`), avatar circle 40. Bars are `surface-sunken`.
- Tab bar visible, حسابي selected (`primary`, filled user icon).
## States
- All three blocks are drawn in phase=rest (full opacity). The dim phase (bars at 45% opacity) is not drawn in this frame. Component rule: rest and dim alternate with smart animate, 600ms each way, `duration-pulse` 1200ms, `ease-standard`; static (rest) when `MediaQuery.disableAnimationsOf`; swap to content with `duration-base`.
- The bell shows no badge while loading (changed from round 1, where it showed "2").
## Dark theme
Token swap only (not read).
## Not in Figma / findings
- The skeleton is a card (140) plus two rows (72), which is closer to the real Account (verification card, then settings rows) than round 1, but the inner shapes of the 140 card are still the list-row shapes, not the profile or verification layout, and the real Account has a profile row, a verification card and five settings rows. Decide whether to shape-match; the pack gives no layout for it.
