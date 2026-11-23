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
| Motion | واحد | `duration-fast` لحد `duration-pulse` كـ number بالـ ms، و `ease-standard` و `ease-enter` و `ease-exit` كـ string بنفس قيم الـ `cubic-bezier` في `tokens.json` |
| Breakpoint | واحد | `bp-medium` و `bp-expanded` و `bp-large` كـ number |
| Typography | واحد | `font-heading` و `font-text` و `font-code`، والتلاتة Cairo دلوقتي (أدوار ممكن تتفصل لخطوط مختلفة بعدين) |
| Copy | ar, en | مرجع الصياغة: نصوص الأزرار والحالات والرسايل بالعربي والإنجليزي، وكل feature بتاخد نصوصها منه حرف بحرف (قرار 15). النصوص في الشاشات مش مربوطة بيه، فتبديل الـ mode مش بيطلّع شاشة إنجليزي |

- **Text styles** بنفس أسماء الـ type styles. كلها بخط Cairo: `display`، `title-lg`، `title`، `headline`، `button`، `number-lg`، `number`، `body`، `body-strong`، `label`، `caption`، `micro`، `code`.
- **Effect styles:** `shadow-card`، `shadow-sheet`، `shadow-popover`. لون كل ظل متربوط بـ variable في Color collection ليه قيمة Light وقيمة Dark، فنفس الـ effect style بيشتغل في الـ mode الاتنين ومفيش styles منفصلة بـ `-dark`. في Dark لون ظل الكارت شفاف (الكارت من غير ظل)، والـ sheet والـ popover بقيم الـ `-dark` بتاعتهم من `tokens.json` (refactor 000، قرار D1).

### صفحات الملف

1. **Cover:** الغلاف 1920 × 960 حسب `components/Cover/preview.html`.
2. **Foundations:** الألوان في الثيمين، والخط، والمسافات، والزوايا، والحركة.
3. **Components:** كل component بالـ variants بتاعته (الـ properties أسفل)، والأيقونات في frame `Icons` (71 icon component).
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
| TextField | `type`: text, password, search · `state`: default, focused, filled, error, locked, disabled (الـ 6 لكل شكل، و `search` مالوش `error`: "مفيش نتايج" empty state مش خطأ، قرار U2). الموبايل والإيميل والرقم القومي إعدادات كيبورد وتحقق على `text` مش أشكال |
| SlotChip | `state`: available, selected, few-left, full, past, in-range |
| DayStrip | `selected`: 1–7 · `today`: true, false |
| FacilityCard | `type`: paid, free, with-trainer · `layout`: vertical, horizontal · `audience`: guest, internal, external (السعر حسب اللي بيشوف، زي `facility_card_mapper.dart`: الضيف السعرين، والموثّق سعر الطلاب والعاملين، والخارجي السعر الكامل) |
| StatusBadge | `status`: confirmed, pending-payment, cancelled, attended, no-show, expired |
| BookingTicket | `state`: upcoming, today, past |
| AppNavigation | `form`: tab-bar, rail, sidebar · `platform`: ios, android, web · `role`: booker, trainer, admin · `selected`: الحاجز `default` (معناه حجوزاتي) و `home` و `facilities` و `notifications` و `account`، والإدارة كمان `more`. متغيرات trainer و admin في Figma موجودة لـ `platform=ios` بس لحد دلوقتي |
| StatTile | `trend`: up, down, flat (اتجاه الرقم) · `tone`: good, bad, neutral (كويس ولا وحش للمؤشر ده). في الكود `StatDelta` بـ `trend` و `higherIsBetter` |
| Logo | `variant`: mark, tile-primary, tile-ink, lockup-ar, lockup-en. الأشكال من `logo/`، وألوانها ثابتة في الثيمين |

### قواعد البناء

- **Arabic first:** الشاشات في Figma عربي و RTL بس، بترتيب العناصر من اليمين. الإنجليزي بيتراجع في التطبيق وهو شغال: كل feature بعد ما تتبني بتاخد screenshots إنجليزي لشاشاتها (compact ومقاس عريض واحد، Light و Dark) في خطوة الـ design QA، فوق مصفوفات الاختبار ar و en. الـ Copy collection فاضل مرجع الصياغة (refactor 000، قرار E1).
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

- **ترك الدفع؟:** حوار (`AdaptiveDialog`) على الـ Checkout لما المستخدم يرجع أثناء الـ Hold: "ترك الدفع" (بيلغي الـ Hold) و"إكمال الدفع". على كل الأحجام.
- **Checkout · gateway cancelled:** لو المستخدم لغى من صفحة المزوّد بيرجع للملخص ببانر "الدفع اتلغى" والـ Hold شغال، مش كفشل دفع.
- **عدّاد الـ Hold:** في شاشة المعالجة "فاضل 9:12 دقيقة" مش وقت ثابت، عشان يتحدث لما الـ Hold يتمدد.
- **مدخل الإيصال:** صف "إيصال الدفع" تحت التذكرة في شاشة التأكيد (المدفوع بس، مش المجاني).
- **الأحجام الواسعة:** كل الحالات (فشل الدفع، آخر دقيقة، انتهاء المهلة، تأكيد المجاني) على Medium وExpanded وLarge. على Medium عمود الدفع ضيق فاختبار نص 200% لازم يتراجع.
- **النصوص:** التذكير "بثلاث ساعات" (BR-39)، والمبلغ في التأكيد والإيصال 80 ج.م ورقم الحجز واحد (SPR-4F7K2). مفيش أفعال أمر في الشاشات دي.

الشاشات الموجودة قبل كده ومش اتكررت: Checkout · payment failed وHold expired وBooking confirmed (QR ورقم الحجز).

### فلو الضيف والحاجز للـ demo

- **Home · guest (FR-CAT-03):** الضيف يشوف اكتشاف بدون حجوزات: ترحيب، وزرار "تسجيل الدخول" في الهيدر، وكارت "ابدأ تحجز" بزرار "إنشاء حساب"، ثم "فيه أماكن النهارده".
- **Booking gate:** لما الضيف يدوس على الحجز من صفحة المنشأة، `AccountGatePrompt` بنص "تسجيل الدخول أو إنشاء حساب عشان تحجز المنشأة دي". بعد الدخول يرجع لنفس الحجز (`/sign-in?from=`).
- **الأحجام الواسعة (Medium وExpanded وLarge):** الهوم (حاجز وضيف)، الدخول والتسجيل وتأكيد الإيميل واسترجاع الباسورد (من غير تنقل، في نص الشاشة بعرض 440)، وحجوزاتي والإشعارات والحساب وطلب التوثيق (عمود واحد بعرض 560 إلى 800 جنب التنقل). دي تحويلات للتخطيط الواسع من نسخ Compact، ومش إعادة تصميم لكل شاشة.
- **قسم "Booker extras · Compact":**
  - **فلاتر المنشآت (FR-CAT-01):** شيت بالنوع والجهة والسعر (مجاني/مدفوع) وزرار "عرض النتائج · N منشآت" و"مسح الفلاتر".
  - **صفحة منشأة بحالتين:** مجانية (من غير أسعار ومدربين، "مجاني. الحجز بالساعة من غير دفع")، ومقفولة النهارده (بانر إغلاق).
  - **المنشأة مش موجودة (FR-CAT-04):** لو رابط المشاركة غلط، بـ"تصفح المنشآت".
  - **الحساب (FR-MYB-03):** تعديل البيانات الشخصية، وشيت اللغة (العربية وEnglish) وشيت المظهر (حسب الجهاز وفاتح وداكن)، وحوار "تسجيل الخروج؟".
  - **إشعارات push (BR-39، BR-40):** تأكيد الحجز، وتذكير "فاضل 3 ساعات على ميعادك" بإجراءين: "عرض التذكرة" و"إلغاء الحجز" (بيظهر قبل الـ cutoff بس).
  - على Medium وأكبر: المنشأة مش موجودة وتعديل البيانات اتحولوا للتخطيط الواسع. الشيتات بتتحول لحوار أو popover من Medium وأكبر حسب `adaptive.md`، ومش مرسومة هناك.
- **قسم "Bookings & status · Compact":**
  - **تفاصيل الحجز القادم:** QR ورقم الحجز والشريحة والمبلغ وزرار "إلغاء الحجز".
  - **تفاصيل الحجز الفايت:** حضر وغاب وانتهى، من غير QR ومن غير زرار إلغاء، وبانر "مفيش أي رسوم أو عقوبة" للغياب (BR-37).
  - **حجوزاتي · اللي فاتت:** تاب "اللي فاتت" بحالات حضر وغاب وتلغى.
  - **هوم لحساب مش موثّق (BR-21):** بانر "السعر الكامل دلوقتي" بدعوة للتوثيق.
  - كلهم متحولين للأحجام الواسعة.
- **قسم "States & permissions · Compact":**
  - **التحميل:** هوم وصفحة منشأة وحساب بـ `Skeleton` (من غير spinner).
  - **مفيش اتصال:** شاشة "مفيش اتصال بالنت" بـ "إعادة المحاولة"، والشاشة بتتحدّث لوحدها لما الاتصال يرجع.
  - **الأذونات:** شيت تمهيدي لإذن الإشعارات قبل طلب النظام ("السماح بالإشعارات" و"مش دلوقتي")، وشيت لصورة الكارنيه ("فتح الكاميرا" و"اختيار من المعرض").
  - **قايمة الإشعارات:** تذكير الحجز بزرارين "عرض التذكرة" و"إلغاء الحجز" لما الإلغاء لسه متاح (BR-40).
  - حالات التوثيق (مش موثّق، قيد المراجعة، موثّق، مرفوض، منتهي) وطلب التوثيق متحولين للأحجام الواسعة.
- **اختبار نص 200% (قسم "Text scale 200% · Compact"):** نسخ من الدفع واختيار الميعاد والتأكيد والتسجيل بالنص مكبّر مرتين، كتقريب سريع (الشاشات نفسها مش متصممة للتكبير). اللي ظهر:
  - شرايط العنوان ذات الارتفاع الثابت بتقص العنوان.
  - الأسطر اللي من سطر واحد بتطلع برا الكارت (بانر الـ Hold، وسطر "الحصة ساعة"، وأسطر الألوان، وتحت عنوان التأكيد).
  - شريط الملخص السفلي بارتفاع ثابت بيتداخل مع المحتوى.
  - شبكة الـ slots بـ 3 أعمدة مش بتتسع للوقت وعدد الأماكن.
  - الكارت والتسجيل اتحملوا كويس.
  - القاعدة للتنفيذ: كل نص بيلف مش بيتقص، ومفيش ارتفاعات ثابتة للأشرطة، والشبكة تقلّ أعمدتها لما النص يكبر (من 3 لـ 2 أو 1)، مع الحفاظ على 48dp للأهداف. التقييم تقريبي، ولازم يتأكد على الـ Flutter نفسه بـ `TextScaler` 2.0.
- **خريطة الشاشات حسب الـ US:** [`screens-map.md`](screens-map.md).
- **حساب الضيف، تفاصيل حجز في انتظار الدفع، البحث (اقتراحات ونتايج):** اتضافوا في قسم "Pending, guest account, search · Compact" وواسعين.
- **التنقل:** في الشاشات الواسعة التبويب المتحدد بيتغير حسب الشاشة (الهوم، المنشآت، حجوزاتي، الإشعارات، حسابي)، وعدّاد الإشعارات مخفي عند الضيف. الـ variants بتاعة كل تبويب في سطر AppNavigation فوق.

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
