# البناء في Figma و Flutter

القاعدة: **اسم الـ token واحد في كل مكان.** `primary` في الـ tokens هو `primary` في Figma Variables وهو `primary` في Flutter. أي agent بيبني شاشة يستخدم الأسماء دي، وممنوع hex مكتوب باليد.

## Figma

### Variables

| Collection | Modes | المحتوى |
| --- | --- | --- |
| Color | Light, Dark | كل الـ color tokens بنفس الأسماء. `focus-ring` alias لـ `primary` في Light ولـ `volt` في Dark |
| Spacing | واحد | `space-1` لحد `space-16` كـ number |
| Radius | واحد | `radius-sm` لحد `radius-full` |
| Size | واحد | `control-height`، الأيقونات، `tabbar-height`، `rail-width`، `sidebar-width`، `content-max` |
| Motion | واحد | `duration-fast` لحد `duration-pulse` كـ number بالـ ms. الـ easing (`ease-*`) بيتوثق في صفحة Foundations لأن الـ Variables مبتشيلش curves |
| Copy | ar, en | نصوص الأزرار والحالات من جدول المحتوى في الـ README، عشان نفس الشاشة تتبدل لغتها بتغيير الـ mode |

- **Text styles** بنفس أسماء الـ type styles. كلها بخط Cairo: `display`، `title-lg`، `title`، `headline`، `button`، `number-lg`، `number`، `body`، `body-strong`، `label`، `caption`، `micro`، `code`.
- **Effect styles:** `shadow-card`، `shadow-sheet`، `shadow-popover`. في Dark الكارت من غير ظل.

### صفحات الملف

1. **Cover:** الغلاف 1920 × 960 حسب `components/Cover/preview.html`.
2. **Foundations:** الألوان في الثيمين، والخط، والمسافات، والزوايا، والأيقونات، والحركة.
3. **Components:** كل component بالـ variants بتاعته (الـ properties أسفل).
4. **Compact:** كل الشاشات على 390 × 844 (iPhone) و 412 × 915 (Android).
5. **Medium:** الشاشات الأساسية على عرض 720 (فولد مفتوح / تابلت صغير).
6. **Expanded و Large:** الشاشات على 1194 × 834 (iPad عرضي) و 1440 × 900 (ديسكتوب).
7. **Platform variants:** نسخ iOS و Android للعناصر اللي بتختلف (شريط العنوان، الـ dialogs، الـ sheets، الـ tab bar).
8. **Splash:** شاشة البداية (تفاصيلها تحت).
9. **App icon:** أيقونة التطبيق لـ iOS و Android (تفاصيلها تحت).

### الـ components

| Component | Properties |
| --- | --- |
| Button | `variant`: primary, secondary, tonal, ghost, danger · `size`: md, sm · `state`: default, hover, pressed, loading, disabled · `icon`: none, start, end |
| TextField | `state`: default, focused, error, disabled · `type`: text, password, search |
| SlotChip | `state`: available, selected, few-left, full, past |
| DayStrip | `selected`: 1–7 · `today`: true, false |
| FacilityCard | `type`: paid, free, with-trainer · `layout`: vertical, horizontal |
| StatusBadge | `status`: confirmed, pending-payment, cancelled, attended, no-show, expired |
| BookingTicket | `state`: upcoming, today, past |
| AppNavigation | `form`: tab-bar, rail, sidebar · `platform`: ios, android, web · `role`: booker, trainer, admin · `selected`: القسم المحدد (`default` للحاجز). متغيرات trainer و admin في Figma موجودة لـ `platform=ios` بس لحد دلوقتي |
| StatTile | `trend`: up, down, flat |
| Logo | `variant`: mark, tile-primary, tile-ink, lockup-ar, lockup-en. الأشكال من `logo/`، وألوانها ثابتة في الثيمين |

### قواعد البناء

- **Arabic first:** الـ frame الأساسي عربي و RTL، بترتيب العناصر من اليمين. النسخة الإنجليزي بتتعمل بتبديل الـ Copy mode وعكس الترتيب.
- Auto layout في كل حاجة، والمسافات والزوايا متربوطة بالـ variables.
- كل شاشة ليها Light و Dark بتبديل mode الـ Color collection، مش نسخة متلونة باليد.
- الداتا في الشاشات واقعية من الـ seed data: أسماء منشآت، أسعار بالجنيه، أوقات 12 ساعة.

### Splash

حركة واحدة مستمرة من الـ native للـ splash، بـ 3 keyframes بلون واحد ثابت (من غير نسخة Dark) على Compact (390 × 844) و Medium و Expanded و Large، وفريم Android 12 (412 × 915). الفريمات متوصلة بـ Smart Animate.

| المرحلة | المحتوى | التوقيت |
| --- | --- | --- |
| 1 · Native | البرق لوحده في النص: 88 بلون `volt`، من غير tile ولا دايرة | بيفضل لحد ما Flutter يجهز |
| 1 → 2 | البرق يطلع لفوق، وسبرنت تظهر بشفافية 40% | بعد 600 ms، `duration-slow` بـ `ease-enter` |
| 2 → 3 | سبرنت والشعار والـ loader وجامعة طنطا بـ fade | بعد 350 ms، `duration-base` |

- **الألوان:** خلفية `primary` ونص `on-primary` والبرق والممرات `volt`، في كل الأحوال. الـ native بيعرف شكل الجهاز بس ومبيعرفش ثيم التطبيق، فاللون الثابت بيمنع قفزة اللون. بعد الـ splash التطبيق بيفتح بثيمه بـ fade عادي.
- **الـ loader:** 3 ممرات 56 و36 و46 عرض × 6 ارتفاع، المسافة 8، بتتحرك بـ `duration-pulse` زي حبال الحارات.
- **Android 12:** لون خلفية الأيقونة نفس لون الشاشة فالدايرة تختفي والبرق بس هو اللي يبان. iOS: LaunchScreen بنفس الفريم الأول.
- **الويب والديسكتوب:** نفس التركيب متوسّط، والممرات وجامعة طنطا مثبتين تحت الشاشة على كل المقاسات. `#sprint-splash` في `web/index.html` هو الفريم الأول.
- **تقليل الحركة:** الانتقال مباشر للمرحلة 3.
- **النصوص:** "احجز من غير زحمة" و"جامعة طنطا" مقترحين ومش في `copy-review.md`.

### App icon

الصفحة فيها كل الأحجام والطبقات. البرق `volt` على `primary`، ونفس شكل الشعار `tile-primary` من غير الزوايا.

- **iOS:** 1024 × 1024 مربع كامل من غير زوايا ومن غير شفافية (النظام هو اللي بيقص). Light: خلفية `primary`. Dark (iOS 18): خلفية `bg`. الـ Tinted النظام بيولّده من نسخة Dark.
- **Android adaptive:** طبقة 108dp. خلفية `primary`، وطبقة أمامية بالبرق جوه المنطقة الآمنة (دايرة 66dp)، وطبقة monochrome للأيقونات الملونة بالثيم. معاينة بالدايرة والمربع المدور.
- **Android 12 splash icon:** لوحة 288dp بتتقص لدايرة 192dp. البرق من غير خلفية بنفس حجم برق الـ Flutter splash (60 × 66)، و`windowSplashScreenBackground` = `primary` فالدايرة تختفي.

### الدفع والـ Hold والتأكيد (US-10 وUS-12)

شاشات في Figma: Compact في قسم "Checkout & payment · Compact"، و Medium و Expanded & Large في الصفحات بتاعتهم (Light و Dark). كلها مبنية من مكونات موجودة (Button وTextField وStatusBadge وLottieMoment).

| الشاشة | المحتوى |
| --- | --- |
| Checkout · hold | ملخص الحجز وسياسة الإلغاء ووسيلة الدفع وبانر الـ Hold (BR-12). على Medium وأكبر: عمود الدفع والـ Hold على جنب والملخص في النص |
| Checkout · last minute | نفس الشاشة لما يفضل أقل من دقيقة: البانر `danger-soft` والنص بالثواني |
| Payment · gateway (sandbox) | صفحة المزوّد (خارج التطبيق): المبلغ وحقول البطاقة بالنص الإرشادي ووسم وضع الاختبار. بتتبدل بمنصة الجامعة في P2 من غير تغيير الفلو (BR-29) |
| Payment · processing | "بنأكد الدفع": مؤشر تحميل وكارت الحجز بشارة "في انتظار الدفع" من غير زرار رجوع، لأن التأكيد بييجي من المزوّد بس (BR-28) |
| Payment · awaiting confirmation | لو التأكيد اتأخر: "لسه مستنيين تأكيد الدفع" مع "تحديث الحالة"، والمكان متحجز لحد نهاية الـ Hold |
| Receipt | إيصال إلكتروني (FR-PAY-03): رقم الإيصال ورقم الحجز والتاريخ والوحدة والشريحة ووسيلة الدفع والإجمالي، وحفظ PDF ومشاركة |

الشاشات الموجودة قبل كده ومش اتكررت: Checkout · payment failed وHold expired وBooking confirmed (QR ورقم الحجز).

## Flutter

### الـ tokens في الكود

| الـ token | في Flutter |
| --- | --- |
| Color | `SprintColors extends ThemeExtension` بنسختين light و dark، وبيتقري بـ `context.colors.primary` |
| Type | `SprintText` بالـ 12 style + `code`. Cairo كـ asset بأوزان static (400 و 500 و 600 و 700)، وكل `TextStyle` فيه `height` صريح من الـ token |
| Spacing / Radius / Size | ثوابت في `SprintSpacing` و `SprintRadius` و `SprintSize` |
| Breakpoints | `WindowSize.of(context)` بيرجّع compact أو medium أو expanded أو large |
| Motion | `SprintMotion`: المدد كـ `Duration` والـ curves بنفس أسماء الـ tokens (`ease-standard` = `Easing.standard`، `ease-enter` = `Easing.emphasizedDecelerate`، `ease-exit` = `Easing.emphasizedAccelerate`)، و helper بيرجّع fade بـ `duration-fast` أو صفر لما `MediaQuery.disableAnimationsOf(context)` يبقى true |
| Lottie | باكدج `lottie`، الملفات في `assets/lottie/`، والألوان بـ `ValueDelegate.color` من `context.colors` على أسماء الـ layers. widget واحد `SprintLottie` بيشغّل مرة واحدة، ويعكس في RTL لو الملف اتجاهي، ويقف على آخر frame في تقليل الحركة |

- الـ `ThemeData` بيتبني من `SprintColors`، و `ColorScheme` بيتملا منه عشان أي widget من Flutter يطلع بألوان البراند.
- `tokens.json` هو المصدر. لو قيمة اتغيرت، بتتغير في الملف وبعدين في الكود، مش العكس.

### أسماء الـ widgets

`SprintButton`، `SprintTextField`، `SlotChip`، `DayStrip`، `FacilityCard`، `StatusBadge`، `BookingTicket`، `AppNavigation`، `StatTile`، `SprintLogo`، ومعاهم الـ adaptive: `AdaptiveAppBar`، `AdaptiveDialog`، `AdaptiveSheet`، `AdaptiveSwitch`، `AdaptiveLoader`.

كل widget بيعرض نفس الـ properties اللي في جدول Figma، فالـ Code Connect بين الاتنين يبقى مباشر.
