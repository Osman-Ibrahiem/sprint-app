# AppNavigation

التنقل الأساسي في التطبيق، بيتحول بين tab bar و rail و sidebar حسب عرض الشاشة، والعناصر واحدة في الثلاثة.

## اللي بيتبعت للـ component

- `destinations`: بتتبني من أدوار المستخدم.
    - حاجز: الرئيسية، المنشآت، حجوزاتي، الإشعارات، حسابي.
    - مدرب: حصصي، مسح QR، الإشعارات، حسابي.
    - إدارة: لوحة المتابعة، الحجوزات، المنشآت، التوثيق، العهدة، التقارير، الإعدادات (اللي يظهر حسب الصلاحية والنطاق).
- `selected` و `onSelected`.
- `badges`: عدد غير مقروء على الإشعارات (`danger` بنص `on-danger`).

## الأشكال

| الفئة | الشكل | الحالة النشطة |
| --- | --- | --- |
| Compact | Tab bar تحت، ارتفاع `tabbar-height` + الـ safe area، أقصى 5 عناصر | أيقونة Fill ونص بلون `primary` |
| Medium | Rail بعرض `rail-width` على جنب الـ start | pill `primary-soft` ورا الأيقونة، ونص `on-primary-soft` |
| Expanded و Large | Sidebar بعرض `sidebar-width`، فيه اسم "سبرنت" فوق | صف `primary-soft` ونص `on-primary-soft` |

## حسب المنصة

- iOS: الـ tab bar شفاف بـ blur فوق المحتوى، من غير pill ورا الأيقونة.
- Android: الـ tab bar `surface`، والنشط ممكن ياخد pill `primary-soft` زي الـ rail.
- Web و Desktop: hover بـ `surface-sunken`، و `focus-ring` مع الكيبورد، واختصارات أرقام (1–5) للتنقل.

## قواعد

- مكان الـ rail والـ sidebar على الـ start: يمين في العربي وشمال في الإنجليزي.
- الإدارة على compact أكتر من 5 عناصر: الخامس "المزيد" وبيفتح قايمة.
- الشاشة اللي اتفتحت من تاب بتحافظ على مكانها لما المستخدم يرجع للتاب.
- لا تخبي الـ tab bar وقت التمرير على compact.
