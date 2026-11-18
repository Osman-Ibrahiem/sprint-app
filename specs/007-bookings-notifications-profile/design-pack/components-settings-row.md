# SettingsRow
Node: 278:35473 (value 278:35470, navigation 278:35471, destructive 278:35472)
Covers: FR-MYB-03, US-14
- Height 52 (>= control-height), padding x `space-4`, gap `space-3`, 1px `line` bottom divider (none on the last/destructive row).
- Layout at the start: icon 20 (user, translate, moon, bell), label `body` `ink`; value `body` `ink-muted` at the other side; mirrored caret-left 20 at the end (directional). Destructive: label `body` `danger` + sign-out icon (mirrored in RTL), no chevron.
- Types: value (اللغة: العربية, المظهر: حسب الجهاز, الإشعارات: مفعّلة), navigation (البيانات الشخصية), destructive (تسجيل الخروج).
- Rows sit in a `surface` card, radius `radius-lg`, clip.
- Note: the Figma component default shows label/value swapped in layer order ("العربية" before "اللغة" in the source); trust the Account frames. Pressed/hover states not drawn.
