# Edit profile
Covers: US-14, FR-MYB-03
Node: Compact Light 247:5742 (re-read round 3), Dark 247:6213 (not read) · round 3 new Compact Light frames: no changes 299:44267 (screenshot only), photo set 299:44315, name error 299:44378 (Dark: 299:44433 / 299:44481 / 299:44542, not read) · Medium and Expanded counterparts of the three new frames: ids not found, NOT read · Medium Light 249:11726 (read) / Dark 249:11835 (not read) · Expanded Light 249:25050 (read) / Dark 249:25162 (not read) · Large Light 249:25275 (screenshot only) / Dark 249:25387 (not read)
Screenshots: images/edit-profile-compact-light.png (round 2, old), images/edit-profile-no-changes-compact-light.png, images/edit-profile-photo-set-compact-light.png, images/edit-profile-name-error-compact-light.png, images/edit-profile-large-light.png
## Layout
### Compact (pushed screen; the tab bar stays visible with "حسابي" selected, changed in round 2)
- Status bar 54, AdaptiveAppBar 44 at top 54: back "رجوع" + caret at the start in `primary`, centred title "البيانات الشخصية".
- Content (column, gap `space-4`, padding top `space-4`, x `space-4`, bottom `space-6`, from y=98):
  1. Avatar row (flex, wrap, centred vertically, gap `space-4` across, `space-2` between wrapped lines): Avatar 64 + ghost Button "تغيير الصورة" (`button`, `primary`, 48 high, padding x `space-5`, `radius-md`; it now hugs). With a photo set (photo=true) a ghost danger Button "حذف الصورة" (`button`, `danger`, 48 high, hugs) is added after it, and the row wraps if the three do not fit (frame 299:44315).
  2. TextField "الاسم بالكامل": editable, value "سارة محمود", border `control-border`, fill `surface`, radius `radius-sm`, height 48, helper line 20 high (empty).
  3. TextField "رقم الموبايل": type=text, state=locked (see components-textfield-locked.md): fill `surface-sunken`, 1 `line` border, label `ink-disabled`, value `ink-muted`, lock icon 20 at the end, helper "مربوط بتسجيل الدخول ومش بيتعدل من هنا" (`caption`, `ink-disabled`).
  4. TextField "الإيميل": same locked state and the same helper.
  5. Primary Button "حفظ التعديلات", full width 48 (no more hint line: it was replaced by the per-field helpers, round 3).
- Tab bar (64 + 34 indicator) at y=746, 4 tabs, "حسابي" selected (`primary`, filled user icon). The content frame is 746 high from y=98, so the bar overlaps its bottom 98: keep the save button above the bar (content scrolls over it).
## Text
- Labels `label` (`ink`; `ink-disabled` when locked). Values `body` (`ink`; `ink-muted` when locked, readable). Helpers `caption` 13/20 (`ink-disabled` for the locked reason, `danger` for the error).
- Locked helper copy (both fields): "مربوط بتسجيل الدخول ومش بيتعدل من هنا". The old 2-line hint under the fields no longer exists.
- Error copy: "الاسم لازم يكون حرفين على الأقل" (`caption`, `danger`) with a warning-circle icon 16 beside it.
## States
Round 3 frames (Compact Light):
- Default (247:5742): name editable, save drawn ENABLED (`primary` fill, `on-primary`). Conflicts with the three frames below, where save is disabled when nothing changed: treat 247:5742 as the "changed" state, or ask Osman to redraw it.
- No changes (299:44267): same layout; Save disabled: fill `surface-sunken`, label `ink-disabled`, still 48 high full width. Enabled only once the name or photo differs from the saved one and the name is valid.
- Photo set (299:44315): Avatar shows a photo placeholder (32 icon on `primary-soft`; real app: image fill, `radius-full`), "حذف الصورة" appears; Save drawn disabled (the photo was just loaded: should arguably be enabled, to confirm).
- Name error (299:44378): value "س"; field fill `danger-soft`, 2px `danger` border, helper in `danger` with warning-circle icon; Save disabled. Validate on blur or submit, not per keystroke (TextField rule); the minimum is 2 characters.
- Locked phone and email: never editable, selectable, not focusable for editing.
### Medium (720, read) and Expanded (1194, read)
- No AdaptiveAppBar and no back button. Rail 88 (Medium) / sidebar 280 (Expanded) with حسابي selected (`primary-soft`, `on-primary-soft`, filled user icon) and the badge "2" on الإشعارات. Rail/sidebar details as in notifications.md.
- Main (padding y `space-8`, gap `space-4`, centred): title "البيانات الشخصية" (`title`, `ink`, 1 line, at the start edge of a 440 column), then a 440-wide Content column (padding top `space-4`, bottom `space-6`, x `space-6` on Medium / `space-4` on Expanded, gap `space-4`) holding the same blocks as Compact: avatar row, name field, phone, email, hint, save button full width of the column.
### Large (1440, screenshot only)
Same as Expanded with sidebar 280; form column about 408 wide, title "البيانات الشخصية" appears centred over the column here (at the start edge in Medium/Expanded): a difference to confirm. Hint wraps to 2 lines.
## Dark theme
Not read.
## Not in Figma / findings
- Fixed in round 2: the hint text now uses `caption` (Cairo). No open font mismatch.
- Round 3: "تغيير الصورة" now hugs (fixed in Compact; Medium, Expanded and Large not re-read, so check that they no longer draw 358 wide).
- Photo picker source (camera/gallery), cropping and delete confirm are not drawn; "حذف الصورة" returns to initials with no confirm drawn.
- Locked label and helper use `ink-disabled` (a6adbd-range), which is low contrast on `bg`/`surface-sunken`; value uses `ink-muted`. Flag for the accessibility pass (the text must still read).
- Round 3 Medium/Expanded/Large new frames (no changes, photo set, name error): not read; ids not found without a whole-page metadata call.
- Locked fields should be exposed to screen readers as read-only with the reason; phone and email typed LTR.
- Photo picker source (camera/gallery) and photo cropping: not drawn. Avatar spec: initials fallback, photo fills the circle.
