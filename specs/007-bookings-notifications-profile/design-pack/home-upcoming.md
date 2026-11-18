# Home booker (bell and upcoming section)
Covers: US-14, FR-NTF-02, FR-MYB-01 (upcoming section)
Node: Compact Light 14:2 (read directly, round 2), Dark 19:726 (not read) · Medium Light 243:10530 (read) · Expanded Light 243:23868 (read), Dark 243:25036 (not read) · Large 243:25304 / Dark 243:26472 (not read) · Home guest Compact 243:5278, Medium 243:10648 (read), Expanded 243:23989, Large 243:25425 (guest Compact, Expanded, Large not read) · Home not verified 252:6257 (Medium 253:13225, Expanded 253:27746, Large 253:28667, not read)
Screenshots: images/home-booker-compact-light.png
## Layout
### Compact (390 x 844)
- Status bar 54. Content (column, gap `space-6`, padding top 0 (header has its own `space-2`), x `space-4`, bottom 120, from y=54, end-aligned):
  1. Header row (space-between, padding-top `space-2`): NotificationBell 48 at the physical left (inline-end in RTL), shown with the badge "2" (`danger` / `on-danger`, `micro`); greeting column at the physical right (inline-start): "أهلًا يا سارة" (`title-lg`, `ink`) over "بالسعر الداخلي · موثّق لحد 31 أغسطس" (`caption`, `ink-muted`).
  2. Search TextField type=search, state default: pill `radius-full`, `surface-sunken`, 48 high, placeholder "البحث عن منشأة أو رياضة" (`body`, `ink-muted`), magnifier 20 at the start, padding `space-4`.
  3. "Next booking" section (column, gap `space-3`):
     - Section header row (space-between): "حجزك الجاي" (`title`, `ink`) at the start (physical right); link "كل حجوزاتي" (`label`, `primary`, plain text 20 high) at the end (physical left).
     - Upcoming card: `surface`, radius `radius-lg`, padding `space-4`, gap `space-2`, `shadow-card`, column: row (StatusBadge confirmed "مؤكد" with check icon 16 at the physical left; volt "When" chip at the right: `volt` fill, radius `radius-sm`, padding x `space-3` y `space-2`, text "النهارده · 5:00 – 6:00 م" `label` in `on-volt`, clock icon 20); facility name "حمام السباحة الأوليمبي" (`headline`, `ink`); line "حارة 3 · مع الكابتن أحمد سامي" (`caption`, `ink-muted`); tonal Button "عرض التذكرة" (full width 48, `primary-soft` fill, `on-primary-soft` text `button`, radius `radius-md`).
  4. "Available today" section: header "فيه أماكن النهارده" (`title`) + link "الكل" (`label`, `primary`); horizontal scrolling row of FacilityCards (width 300, gap `space-4`): card 1 "ملعب الاستاد الخماسي" (tags مجاني + كرة قدم; "ميعادين بس فاضيين النهارده" warning; "للطلاب بس" / "مجاني"), card 2 "حمام السباحة الأوليمبي" (tags بمدرب + سباحة; "14 مكان فاضي النهارده" success; "سعر الطلاب والعاملين" / "80 ج.م").
- Tab bar (64 + 34 indicator): 4 tabs الرئيسية (selected, `primary`, filled house), المنشآت, حجوزاتي, حسابي.
### Medium (720 x 1000, rail 88 at the inline-start edge, read)
- No bell in the header: only the greeting column. Main column 560 centred, padding y `space-8`, content padding x `space-6`, gap `space-6`, bottom `space-6`.
- Rail 5 items: الرئيسية (selected, `primary-soft` indicator, `on-primary-soft` label, filled house), المنشآت, حجوزاتي, الإشعارات (badge "2"), حسابي.
- Search field, "حجزك الجاي" section (link "كل حجوزاتي"), Upcoming card and "فيه أماكن النهارده" row identical to Compact (FacilityCards stay 300 wide).
### Expanded (read)
- Same as Medium but main column 720 (content padding x `space-4`) and a sidebar 280 (padding x `space-3`, gap `space-1`, brand lockup, 5 items 44 high radius-md; الرئيسية selected `primary-soft`, `on-primary-soft` text `label`, badge `danger` on الإشعارات at the inline-end side of the label). No bell. Large: not read.
## Text
Copy as above. The link "كل حجوزاتي" matches the brief (the earlier note about "عرض الكل" is closed).
## States
- Upcoming card is shown only when a future booking exists (only the present state is drawn). Home guest (Medium read): no bell, no upcoming section; the header carries a secondary Button "تسجيل الدخول" at the end and the title "أهلًا بيك في سبرنت" over "استعراض المنشآت من غير حساب"; a card "ابدأ تحجز" (section title `title`) with "احجز ملعبك في دقايق" (`headline`), "دفع إلكتروني آمن من غير كاش. ولو حسابك موثّق بتحجز بالسعر الداخلي" (`caption`, `ink-muted`) and a tonal Button "إنشاء حساب"; then the same "فيه أماكن النهارده" row. Rail has 4 items (no الإشعارات). Guest Compact/Expanded/Large and Home not verified: not read.
- Home loading 256:6332: see its own frame (not read this round).
## Dark theme
Not read.
## Not in Figma / findings
- The links "كل حجوزاتي" and "الكل" are 20 high plain text (`label`): below the 48dp target; give them a 48 hit area (padding) without changing the look.
- Card tap target (whole card vs button), which booking is "next" when there are several, and the destination of "كل حجوزاتي" (My bookings): spec.
- Volt chip is a fill with `on-volt` text (rule respected). The "Upcoming card" layer name is reused for the guest CTA card on Home guest (layer naming only).
- The badge count on the bell and its cap/label: spec.
