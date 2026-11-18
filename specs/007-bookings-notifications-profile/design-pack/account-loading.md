# Account · loading
Covers: US-14, FR-MYB-03
Node: Compact Light 256:6496 (re-read round 3), Dark 256:6868 (not read). Skeleton shapes: profile-card 290:42579, settings-row 290:42587 (component Skeleton 69:482)
Screenshots: images/account-loading-compact-light.png (round 3)
## Layout
### Compact
- Content (column, gap `space-5`, padding top `space-2`, x `space-4`, bottom 120, from y=54, end-aligned):
  1. Header row (space-between, height 48): NotificationBell 48 in the unread=false variant (bell only, no badge) at the physical left; title "حسابي" (`title-lg`, `ink`) at the right.
  2. Skeleton shape=profile-card, full width, 140 high: `surface`, radius `radius-lg`, padding x `space-4` y 16 (no token; `space-4`), column gap `space-3`, items start. Row (gap 12, centred, full width): Text column (flex, end-aligned, gap `space-2`: Title bar 150x16 and Subtitle bar 110x12, radius `radius-sm`) then Avatar circle 64 (`radius-full`) at the end. Below the row, a "Verification badge" pill 120x24 (`radius-full`). So: avatar + two text lines, then a badge pill, mirroring the real profile card.
  3. Two Skeletons shape=settings-row, full width, 52 high each: `surface`, radius `radius-lg`, padding x `space-4`, gap `space-3`, items centred: Icon circle 20 (at the end), Text column holding one Title bar 150x16 (`radius-sm`), Spacer (flex), then a "Value or switch" pill 40x24 (`radius-full`) at the start. Gap between blocks `space-5`.
  All bars and circles are `surface-sunken`.
- Tab bar visible, حسابي selected (`primary`, filled user icon).
## States
- All three blocks are drawn in phase=rest (full opacity). The dim phase (bars at 45% opacity) is not drawn in this frame. Component rule: rest and dim alternate with smart animate, 600ms each way, `duration-pulse` 1200ms, `ease-standard`; static (rest) when `MediaQuery.disableAnimationsOf`; swap to content with `duration-base`.
- The bell shows no badge while loading (changed from round 1, where it showed "2").
## Dark theme
Token swap only (not read).
## Not in Figma / findings
- Round 3 resolved the shape-match question for the profile card (avatar, two lines, badge) and for a settings row (icon, one line, value or switch). Only two settings rows are drawn (the real Account has five): repeat the settings-row shape for the missing rows, or keep two, implementer's call.
- The 52 row height has no token (settings rows in components-settings-row.md should be checked against it); the profile-card padding y is drawn as 16 (equals `space-4`).
- Skeleton description: swap to content with `duration-base`; pulse rest/dim 600ms each way (`duration-pulse` 1200ms), static under reduced motion.
- Dark not read.
