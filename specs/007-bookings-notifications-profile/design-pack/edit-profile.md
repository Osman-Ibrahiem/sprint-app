# Edit profile
Covers: US-14, FR-MYB-03, BR-40
Node: Compact Light 247:5742 (re-read round 2), Dark 247:6213 (not read) · Medium Light 249:11726 (read) / Dark 249:11835 (not read) · Expanded Light 249:25050 (read) / Dark 249:25162 (not read) · Large Light 249:25275 (screenshot only) / Dark 249:25387 (not read)
Screenshots: images/edit-profile-compact-light.png, images/edit-profile-large-light.png
## Layout
### Compact (pushed screen; the tab bar stays visible with "حسابي" selected, changed in round 2)
- Status bar 54, AdaptiveAppBar 44 at top 54: back "رجوع" + caret at the start in `primary`, centred title "البيانات الشخصية".
- Content (column, gap `space-4`, padding top `space-4`, x `space-4`, bottom `space-6`, from y=98):
  1. Avatar row (gap `space-4`, centred): Avatar 64 + ghost Button "تغيير الصورة" (`button` in `primary`; Figma width 358, should hug).
  2. TextField "الاسم بالكامل": editable, value "سارة محمود", border `control-border`, fill `surface`, radius `radius-sm`, height 48, helper line 20 high (empty).
  3. TextField "رقم الموبايل": locked, value "01012345678", fill `surface-sunken`, border `line`, label and value `ink-disabled`.
  4. TextField "الإيميل": locked, value "sara.mahmoud@tanta.edu.eg", same locked style.
  5. Hint line (12px): explanation text.
  6. Primary Button "حفظ التعديلات", full width 48.
- Tab bar (64 + 34 indicator) at y=746, 4 tabs, "حسابي" selected (`primary`, filled user icon). The content frame is 746 high from y=98, so the bar overlaps its bottom 98: keep the save button above the bar (content scrolls over it).
## Text
- Labels `label` (`ink`; `ink-disabled` for locked). Values `body` (`ink`; `ink-disabled` when locked).
- Hint copy: "الإيميل ورقم الموبايل مربوطين بتسجيل الدخول ومش بيتعدلوا من هنا. الاسم والصورة بس اللي بيتعدلوا." Style `caption` (13/20, 400, Cairo), colour `ink-muted`, full width, wraps to 2 lines (fixed in round 2: it was Inter 12 with no token).
## States
Editable: name, photo. Locked: phone, email (BR-40). Error/filled/focused states of the name field: not drawn (TextField component supports error: 2px `danger` border, `danger-soft` fill, icon + message). Save disabled until changed: not drawn.
### Medium (720, read) and Expanded (1194, read)
- No AdaptiveAppBar and no back button. Rail 88 (Medium) / sidebar 280 (Expanded) with حسابي selected (`primary-soft`, `on-primary-soft`, filled user icon) and the badge "2" on الإشعارات. Rail/sidebar details as in notifications.md.
- Main (padding y `space-8`, gap `space-4`, centred): title "البيانات الشخصية" (`title`, `ink`, 1 line, at the start edge of a 440 column), then a 440-wide Content column (padding top `space-4`, bottom `space-6`, x `space-6` on Medium / `space-4` on Expanded, gap `space-4`) holding the same blocks as Compact: avatar row, name field, phone, email, hint, save button full width of the column.
### Large (1440, screenshot only)
Same as Expanded with sidebar 280; form column about 408 wide, title "البيانات الشخصية" appears centred over the column here (at the start edge in Medium/Expanded): a difference to confirm. Hint wraps to 2 lines.
## Dark theme
Not read.
## Not in Figma / findings
- Fixed in round 2: the hint text now uses `caption` (Cairo). No open font mismatch.
- "تغيير الصورة" ghost Button is drawn 358 wide in every size (in the 440 column it leaves no room next to the avatar); it must hug its label (min 48 high).
- Locked fields should be exposed to screen readers as read-only with the reason; phone and email typed LTR.
- Photo picker source (camera/gallery) and photo cropping: not drawn. Avatar spec: initials fallback, photo fills the circle.
