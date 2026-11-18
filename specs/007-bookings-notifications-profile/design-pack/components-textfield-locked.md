# TextField · state=locked (type=text)

Node: component set TextField 10:123 (state=locked variant, inner ids like 299:900-905). Seen in Edit profile 247:5742, 299:44267, 299:44315, 299:44378. Covers: US-14, FR-MYB-03, BR-40.
Screenshots: images/edit-profile-no-changes-compact-light.png

## Anatomy (Compact, width 358)
- Column, gap `space-2`: label, Field, Helper.
- Label: `label` 14/20 600, colour `ink-disabled`.
- Field: height 48, padding x `space-4`, gap `space-2`, fill `surface-sunken`, 1px `line` border, `radius-sm`. Value `body` 15/24, colour `ink-muted`, takes the free width (typed LTR for email and phone). Lock icon 20 (Phosphor `lock`, not mirrored in RTL) at the end of the field.
- Helper (20 high, gap `space-1`): `caption` 13/20, `ink-disabled`, copy "مربوط بتسجيل الدخول ومش بيتعدل من هنا" in Edit profile.

## Behaviour (component description)
- Read-only value that is still readable; use it for email and phone in Edit profile INSTEAD of state=disabled (which means "not available right now").
- Not focusable for editing; text selectable. The helper always says why.

## Not in Figma / findings
- Screen-reader text: expose as read-only plus the helper as the reason; no focus ring needed for editing, but the field may still be reachable by the reader.
- `ink-disabled` on label and helper is low contrast: confirm with the accessibility pass.
- Other locked uses (BRD): none yet; decision 2026-11-18 locks phone and email.
