# Account (booker)
Covers: US-14, FR-MYB-03, BR-40
Node: Compact Light 18:499, Dark 19:1454 · Medium Light 243:11423 (Dark 243:11864) · Expanded 243:24785 (Dark 243:25232) · Large 243:26221 (Dark 243:26668)
Screenshots: images/account-large-light.png (Large Light). Compact Light 18:499 itself not re-read; the Compact layout was cross-checked against the Account behind the sign-out dialog (247:5937) in round 2. Medium Light and Expanded Light read in round 2; Dark and the verification variants not read.

## Layout
### Compact (390 x 844, tab "حسابي" selected)
- Status bar 54. No AdaptiveAppBar (root tab). Content (column, gap `space-5`, padding top `space-2`, x `space-4`, bottom 120, from y=54, end-aligned):
  1. Header row (full width, space-between, height 48): NotificationBell 48 at one end (the end of the row in the frame), title "حسابي" at the other.
  2. Profile row (gap `space-4`, centred vertically): Avatar 64 + name/email column (end-aligned).
  3. Verification card (`surface`, radius `radius-lg`, padding `space-4`, gap `space-2`): header row (StatusBadge success "موثّق · سعر داخلي" + title "التوثيق"), line 1, line 2.
  4. Settings card (`surface`, radius `radius-lg`, clip): 5 SettingsRow 52 high, line dividers: البيانات الشخصية (navigation), اللغة (value "العربية"), المظهر (value "حسب الجهاز"), الإشعارات (value "مفعّلة"), تسجيل الخروج (destructive, no divider).
- Tab bar 4 tabs, "حسابي" in `primary` with the filled user icon.
### Medium (720 x 1000)
Rail 88 at the inline-start edge with 5 items (الإشعارات carries the badge, حسابي selected). Main column 560 centred. The header row loses the bell: only title "حسابي" (`title-lg`). Content padding `space-6`, gap `space-5`. Same cards.
### Expanded (1194, read) and Large (1440, screenshot only)
Same as Medium with a sidebar 280 (see app-navigation.md; حسابي selected with `primary-soft`, filled user icon, badge "2" on الإشعارات) and a centred main column 720 wide (content padding x `space-4`, gap `space-5`). Title "حسابي" alone, no bell. Large: sidebar 280, content column about 768 wide on the screenshot; nothing else differs.

## Text
- Title "حسابي": `title-lg`, `ink`.
- Name "سارة محمود": `title`, `ink`. Email "sara.mahmoud@tanta.edu.eg": `caption`, `ink-muted`, LTR isolate.
- "التوثيق": `headline`, `ink`. Badge label `micro`, `success`, icon check-circle 16.
- "طالب · كلية التربية الرياضية": `body`, `ink`. "صالح لحد 31 أغسطس 2027، وبعدها يتجدد": `caption`, `ink-muted`.
- Row labels `body` `ink`; row values `body` `ink-muted`; destructive label `body` `danger`.
- Avatar initials "سم" (`title`, `on-primary-soft` on `primary-soft`, 64): Avatar spec says first letters of the first two names of "سارة محمود", i.e. "سم"; matches (the earlier mismatch note is closed).
- Header bell on Compact shows the badge "2" (loading state hides it, see account-loading.md). Medium and Large header: no bell.

## States
- Verification variants (not verified, under review, verified, rejected, expired) exist on Medium and up (257:*), owned by feature 3; only "verified" is the default here. Not read.
- Language row opens the language sheet/popover, Appearance row the appearance sheet/popover, sign out opens the dialog (account-language-sheet.md, account-signout-dialog.md). Loading: account-loading.md. Guest: account-guest.md.

## Dark theme
Not read.

## Not in Figma
- Date format of the validity line and the row order beyond what is drawn: spec. BR-40 (profile editing limited to name and photo, see edit-profile.md).
- Navigation row opens Edit profile (edit-profile.md). Notification row value ("مفعّلة"/"متوقفة") and its target (system settings vs in-app toggle): not drawn; decide in the spec.
- Row hit area 52 (>= 48). Chevron is mirrored in RTL.
- Settings row order in all sizes: البيانات الشخصية (navigation), اللغة, المظهر, الإشعارات (values العربية, حسب الجهاز, مفعّلة), تسجيل الخروج. Medium rail/sidebar: الإشعارات carries the badge.
