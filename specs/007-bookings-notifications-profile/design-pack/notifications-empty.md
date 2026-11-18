# Notifications · empty
Covers: US-13, FR-NTF-02
Node: Compact Light 71:1688, Dark 71:2285
Screenshots: images/notifications-empty-compact-light.png, images/notifications-empty-compact-dark.png

## Layout
### Compact
Same chrome as notifications.md (AdaptiveAppBar "الإشعارات", tab bar with 4 tabs). Content column (gap `space-3`, padding-top `space-2`, bottom 120, x `space-4`):
- Spacer 48 high (stands in for the hidden mark-all row, so the art does not jump).
- LottieMoment `empty-notifications`, full width, column, gap `space-4`, centred: art 160x160 (circle `surface-sunken`, inner ring 136 `line`, bell 64 `ink-muted` at offset 48), title, body.
Medium and up: not read.

## Text
- Title "مفيش إشعارات لسه": `title`, `ink`, centred.
- Body "هنبلّغك هنا بتأكيد الحجز والتذكير": `body`, `ink-muted`, centred.
- No button.

## States
This is the empty state. Mark-all button is hidden (spacer only).

## Dark theme
Token swap only (layers named after tokens: surface-sunken, line, ink-muted).

## Not in Figma
- LottieMoment: plays once, never loops, final frame shown under reduced motion, art excluded from screen readers, recoloured at runtime via ValueDelegate.color. Lottie asset (<=100KB) is polish (feature 11); until then use the static final frame.
- Text under the art states the state, so no extra screen-reader label needed.
