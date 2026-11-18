# Notifications (list)
Covers: US-13, FR-NTF-02, FR-NTF-01, BR-39, BR-41
Node: Compact Light 18:410 (re-read round 2), Dark 19:1367 · Medium Light 243:11282 (Dark 243:11810 not read) · Expanded Light 243:24641 (read, round 2) / Dark 243:25178 (not read) · Large Light 243:26077 (screenshot only) / Dark 243:26614 (not read)
Screenshots: images/notifications-compact-light.png (refreshed round 2), images/notifications-compact-dark.png, images/notifications-large-light.png

## Layout
### Compact (390 x 844)
- Screen bg `bg`. Status bar 54. AdaptiveAppBar 44 at top 54 (pushed screen: back "رجوع" + caret at the start in `primary`, centred title "الإشعارات").
- Content (column, gap `space-3`, padding top `space-2`, bottom 120, horizontal `space-4`, from y=98, cross-axis end):
  - Actions row (full width, height 48): ghost Button "تعليم الكل كمقروء", 120 wide, radius `radius-md`, text `button` in `primary`. Sits at the physical left of the row, which is the inline-end in RTL (round 1 said inline-start: corrected).
  - NotificationCard x N (full width, height 110, `surface`, radius `radius-lg`, padding `space-4`, gap `space-3`).
- Tab bar (AppNavigation tab-bar, 64 + home indicator) stays visible on this pushed screen: 4 tabs only (الرئيسية, المنشآت, حجوزاتي, حسابي). No notifications tab. The frame is named "pushed from Home" and highlights "الرئيسية" (`primary`, label `micro`), i.e. the tab of the screen that opened it. Highlight when opened from the bell of other tabs (Facilities, My bookings, Account): not drawn; the name suggests the origin tab stays selected, confirm with Osman.
### Medium (720 x 1000)
- AppNavigation rail 88 wide at the inline-start edge, `surface`, 1px `line` divider, padding top `space-4`, gap `space-3`. Items: الرئيسية, المنشآت, حجوزاتي, الإشعارات (selected, `primary-soft` indicator 56x32 radius-full, bell fill, label `on-primary-soft`, badge), حسابي.
- Badge on rail item: `danger` fill, `on-danger` text `micro`, min width 18, padding-x 5, radius-full, top 0 / start offset 6 of the indicator.
- Main: centred column 560 wide, padding-y `space-8`, content padding `space-6` (x) / `space-2` top / `space-6` bottom, gap `space-3`.
- Header row replaces the app bar: title "الإشعارات" `title-lg` at the start, "تعليم الكل كمقروء" ghost button at the end. No back button, no bell.
### Expanded (1194, read)
- AppNavigation sidebar 280 wide at the inline-start edge: `surface`, 1px `line` divider, padding top `space-4`, padding x `space-3`, gap `space-1`, items end-aligned. Brand lockup first (SprintLogo: tile 32 + "سبرنت" `title` Cairo 700, gap `space-3`, padding-bottom `space-3`). Then 5 items, each 44 high, radius `radius-md`, padding x `space-3`, gap `space-3`: icon 24 at the start edge, label `label` (14/20, 600); الإشعارات selected: fill `primary-soft`, label `on-primary-soft`, bell-fill icon, badge "2" (`danger`, `on-danger`, `micro`, min width 18) at the inline-end of the row; the others `ink-muted`.
- Main: centred column 720 wide (content padding x `space-4`, top `space-2`, bottom `space-6`, gap `space-3`), main padding y `space-8`. Header row: title "الإشعارات" (`title-lg`, `ink`) at the start, ghost Button "تعليم الكل كمقروء" (120 x 48) at the end. No back button, no bell. Same 5 cards, 110 high.
### Large (1440, screenshot only)
Same as Expanded: sidebar 280, header row title + mark-all, cards in a centred column about 768 wide (measured on the screenshot; the Expanded value is 720). No other difference seen.

## NotificationCard (see components-notification-card.md)
Four kinds in this frame: reminder (unread, `warning-soft`, hourglass), booking confirmed (unread, `success-soft`, check-circle), admin cancellation (read, `danger-soft`, x-circle), verification (read, `primary-soft`, shield-check), offer (read, `volt`, tag). Order newest first.

## Text
- Title "الإشعارات": Compact `headline` in `ink` (app bar); Medium `title-lg` in `ink`.
- Mark-all: `button`, `primary`, 1 line, "تعليم الكل كمقروء".
- Card time: `caption`, `ink-muted`, "4:00 م" / "3:12 م" / "أمس" / "الخميس" / "الأربعاء".
- Card title: `headline`, `ink`, 1 line. Card body: `body`, `ink-muted`, max 2 lines (card is fixed 110 high in Figma).
- Copy (verbatim):
  1. تذكير بحجزك / حمام السباحة الأوليمبي النهارده 5:00 م · الإلغاء مش متاح دلوقتي
  2. حجزك اتأكد / حارة 3 · الأحد 8 نوفمبر · SP-1042
  3. إلغاء من الإدارة / لغته إدارة المنشأة: ملاعب التنس اتقفلت للصيانة. فلوسك هترجع بالكامل (100 ج.م).
  4. حسابك اتوثّق / الأسعار الداخلية بقت سارية على الحجوزات الجديدة
  5. خصم 30% مسائي / على الحارات من 8:00 لـ 10:00 م طول الأسبوع ده

## States
- Unread: 8px primary dot before the title + count in the bell. Read: no dot.
- Empty: see notifications-empty.md. Reminder with cancel button: see notifications-reminder-cancel.md.
- Mark-all-read: pressing the ghost button clears every dot and sets the badge to 0 (behaviour not drawn).

## Dark theme
Only the token swap (`bg`, `surface`, `ink`, `ink-muted`, soft tints). Screenshot read, no structural difference found.

## Not in Figma
- Reminder copy is built from `reminderLeadMinutes` (BR-39, default 180) and the cancel window from `cancellationCutoffHours` (BR-30). Card 1 shows the post-cutoff variant ("الإلغاء مش متاح دلوقتي"); the other variant is in notifications-reminder-cancel.md.
- Admin cancellation card must state the reason and the full refund (BR-32, BR-41).
- Tapping a card navigates to the related booking/ticket; Figma shows no tap target spec. Cards are 110 high with no 48 conflict.
- Screen-reader text, unread announcement ("غير مقروء") and the badge's count label: not in Figma, take from the spec. Pull-to-refresh and pagination: not drawn.
- Compact is reached only from the bell in the header of Home / Facilities / My bookings / Account (not guests).
- Findings (round 2): the card is a fixed 110 high with the time at the physical left and a 2-line body: long Arabic bodies and 200% text scale must make it grow (hug), not clip. The sidebar rows are 44 high (below 48dp; the sidebar is a web/desktop pointer surface, confirm against `docs/decisions.md`).
