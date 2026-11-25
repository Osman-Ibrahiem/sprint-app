# AppNavigation

التنقل الأساسي في التطبيق، بيتحول بين tab bar و rail و sidebar حسب عرض الشاشة، والعناصر واحدة في الثلاثة.

## اللي بيتبعت للـ component

- `destinations`: بتتبني من أدوار المستخدم.
    - حاجز: الرئيسية، المنشآت، حجوزاتي، الإشعارات، حسابي في الـ rail والـ sidebar (بالإنجليزي Home، Facilities، My bookings، Alerts، Account). في الـ tab bar على Compact أربعة بس (من غير الإشعارات)، والإشعارات بتتفتح من جرس `NotificationBell` في header الشاشات الرئيسية الأربع، والتبويب المظلل وقتها هو اللي جاي منه الحاجز (قرار 2026-11-18). الضيف مالوش الإشعارات.
    - مدرب: حصصي، مسح QR، الإشعارات، حسابي.
    - إدارة: لوحة المتابعة، الحجوزات، المنشآت، التوثيق، العهدة، التقارير، الإعدادات، الأدوار والصلاحيات (اللي يظهر حسب الصلاحية والنطاق). العروض وسجل التعديلات تابات جوه الإعدادات مش أقسام لوحدهم.
- `selected` و `onSelected`.
- `badges`: عدد غير مقروء على الإشعارات (`danger` بنص `on-danger`).
- **تسمية الإشعارات بالإنجليزي "Alerts"** في الـ tab bar والـ rail والـ sidebar بس، عشان "Notifications" ما بتكفّيش في `rail-width` (88) حتى بالخط العادي. عنوان شاشة الإشعارات فاضل "Notifications"، والعربي "الإشعارات" في الحالتين (refactor 000، قرار N1).

## الأشكال

| الفئة | الشكل | الحالة النشطة |
| --- | --- | --- |
| Compact | Tab bar تحت، ارتفاع `tabbar-height` + الـ safe area، أقصى 5 عناصر | أيقونة Fill ونص بلون `primary` |
| Medium | Rail بعرض `rail-width` على جنب الـ start | pill `primary-soft` ورا الأيقونة، ونص `on-primary-soft` |
| Expanded و Large | Sidebar بعرض `sidebar-width`، فيه اسم "سبرنت" فوق | صف `primary-soft` ونص `on-primary-soft` |

## في Figma

الـ component set فيه محورين زيادة على `form` و `platform`:

- `role`: `booker` (الافتراضي) أو `trainer` أو `admin`. كل دور بعناصره: الحاجز 5 عناصر في الـ rail والـ sidebar و4 في الـ tab bar، المدرب 4 (حصصي، مسح QR، الإشعارات، حسابي)، والإدارة 8 في الـ rail والـ sidebar و5 في الـ tab bar (الخامس "المزيد").
- `selected`: القسم المحدد جوه الـ variant (مثلًا `bookings` أو `scan`). الحاجز: `default` ومعناه حجوزاتي، و `home` و `facilities` و `notifications` و `account`. الإدارة كمان `more`.

الـ rail بيستخدم أسماء مختصرة (المتابعة، الأدوار…) عشان تتسع في `rail-width`. متغيرات المدرب والإدارة معمولة لـ `platform=ios` بس.

## حسب المنصة

- iOS: الـ tab bar شفاف بـ blur فوق المحتوى، من غير pill ورا الأيقونة.
- Android: الـ tab bar `surface`، والنشط ممكن ياخد pill `primary-soft` زي الـ rail. الـ pill على العنصر المحدد بس: عمر ما عنصرين يبانوا متحددين (refactor 000، قرار U5).
- Web و Desktop: hover بـ `surface-sunken`، و `focus-ring` مع الكيبورد، واختصارات أرقام (1–5) للتنقل.

## قواعد

- مكان الـ rail والـ sidebar على الـ start: يمين في العربي وشمال في الإنجليزي.
- الإدارة على compact أكتر من 5 عناصر: الخامس "المزيد" وبيفتح قايمة.
- الشاشة اللي اتفتحت من تاب بتحافظ على مكانها لما المستخدم يرجع للتاب.
- لا تخبي الـ tab bar وقت التمرير على compact.
- التسميات ظاهرة في كل أحجام النص، وتكبيرها واقف عند `navLabelMaxTextScale` (1.3) والأيقونات مقاسها ثابت. مفيش وضع أيقونات من غير كلام (refactor 000، قرار T2).
