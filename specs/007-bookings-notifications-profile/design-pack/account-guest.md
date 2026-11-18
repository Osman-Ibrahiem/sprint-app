# Account · guest
Covers: US-14, FR-MYB-03
Node: Compact Light 263:7109, Dark 263:7406 · Medium Light 265:14919 (Dark 265:15172) · Expanded 265:31522 (Dark 265:31781) · Large 265:31952 (Dark 265:32211)
Screenshots: none. Medium Light 265:14919 and Expanded Light 265:31522 read in round 2 (design context); Large and Dark not read.
## Layout
### Compact
- No NotificationBell and no header row: plain title "حسابي" (`title-lg`, `ink`) at the end of the row. Content column gap `space-5`, padding top `space-2`, x `space-4`, bottom 120.
- Sign-in card: `surface`, 1px `line`, radius `radius-lg`, padding x `space-4` y `space-5`, gap `space-3`, column: title, body, primary Button "تسجيل الدخول" (full width 48), secondary Button "إنشاء حساب" (full width 48, 1px `control-border`).
- Settings card with 2 rows only: اللغة (value "العربية"), المظهر (value "حسب الجهاز"). No الإشعارات, no sign out, no personal data.
- Tab bar 4 tabs, حسابي selected (the guest still has the 4 tabs; the tab bar has no notifications tab anyway).
Round 3 note: the Home guest frame (243:5278) carries the same guest CTA copy; its Account counterpart was not re-read, so the Account guest values here stay as read in round 2. SettingsRow (278:35473, type=value) now backs the two settings rows.
## Text
- Title "أهلًا بيك في سبرنت": `title`, `ink`. Body "بحساب تقدر تحجز وتتابع حجوزاتك وتستلم إشعارات التأكيد والتذكير": `body`, `ink-muted`.
### Medium and Expanded (read)
Same card and settings as Compact, no header row and no bell. Rail 88 (Medium) / sidebar 280 (Expanded) with 4 items only: الرئيسية, المنشآت, حجوزاتي, حسابي (selected, `primary-soft`); no الإشعارات, no badge. Main column 560 (Medium, padding x `space-6`) / 720 (Expanded, padding x `space-4`), gap `space-5`. Buttons stay full width of the card (secondary "إنشاء حساب": 1px `control-border`).
## States
Single state. Wide: guest has no notifications destination in the rail/sidebar (app-navigation.md).
## Not in Figma
Sign-in/up targets follow feature 3 (`/sign-in?from=` gated links). Language and appearance rows use the same sheet/popover.
