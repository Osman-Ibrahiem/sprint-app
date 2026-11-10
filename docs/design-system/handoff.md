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

- **Text styles** بنفس أسماء الـ type styles. بخط Alexandria: `display`، `title-lg`، `title`، `headline`، `button`. بخط Cairo: `number-lg`، `number`، `body`، `body-strong`، `label`، `caption`، `micro`. بخط IBM Plex Mono: `code`.
- **Effect styles:** `shadow-card`، `shadow-sheet`، `shadow-popover`. في Dark الكارت من غير ظل.

### صفحات الملف

1. **Cover**
2. **Foundations:** الألوان في الثيمين، والخط، والمسافات، والزوايا، والأيقونات، والحركة.
3. **Components:** كل component بالـ variants بتاعته (الـ properties أسفل).
4. **Compact:** كل الشاشات على 390 × 844 (iPhone) و 412 × 915 (Android).
5. **Medium:** الشاشات الأساسية على عرض 720 (فولد مفتوح / تابلت صغير).
6. **Expanded و Large:** الشاشات على 1194 × 834 (iPad عرضي) و 1440 × 900 (ديسكتوب).
7. **Platform variants:** نسخ iOS و Android للعناصر اللي بتختلف (شريط العنوان، الـ dialogs، الـ sheets، الـ tab bar).

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
| AppNavigation | `form`: tab-bar, rail, sidebar · `platform`: ios, android, web |
| StatTile | `trend`: up, down, flat |
| Logo | `variant`: mark, tile-primary, tile-ink, lockup-ar, lockup-en. الأشكال من `logo/`، وألوانها ثابتة في الثيمين |

### قواعد البناء

- **Arabic first:** الـ frame الأساسي عربي و RTL، بترتيب العناصر من اليمين. النسخة الإنجليزي بتتعمل بتبديل الـ Copy mode وعكس الترتيب.
- Auto layout في كل حاجة، والمسافات والزوايا متربوطة بالـ variables.
- كل شاشة ليها Light و Dark بتبديل mode الـ Color collection، مش نسخة متلونة باليد.
- الداتا في الشاشات واقعية من الـ seed data: أسماء منشآت، أسعار بالجنيه، أوقات 12 ساعة.

## Flutter

### الـ tokens في الكود

| الـ token | في Flutter |
| --- | --- |
| Color | `SprintColors extends ThemeExtension` بنسختين light و dark، وبيتقري بـ `context.colors.primary` |
| Type | `SprintText` بالـ 12 style + `code`. Alexandria و Cairo و IBM Plex Mono كـ assets بأوزان static، وكل `TextStyle` فيه `height` صريح من الـ token |
| Spacing / Radius / Size | ثوابت في `SprintSpacing` و `SprintRadius` و `SprintSize` |
| Breakpoints | `WindowSize.of(context)` بيرجّع compact أو medium أو expanded أو large |
| Motion | `SprintMotion`: المدد كـ `Duration` والـ curves بنفس أسماء الـ tokens (`ease-standard` = `Easing.standard`، `ease-enter` = `Easing.emphasizedDecelerate`، `ease-exit` = `Easing.emphasizedAccelerate`)، و helper بيرجّع fade بـ `duration-fast` أو صفر لما `MediaQuery.disableAnimationsOf(context)` يبقى true |
| Lottie | باكدج `lottie`، الملفات في `assets/lottie/`، والألوان بـ `ValueDelegate.color` من `context.colors` على أسماء الـ layers. widget واحد `SprintLottie` بيشغّل مرة واحدة، ويعكس في RTL لو الملف اتجاهي، ويقف على آخر frame في تقليل الحركة |

- الـ `ThemeData` بيتبني من `SprintColors`، و `ColorScheme` بيتملا منه عشان أي widget من Flutter يطلع بألوان البراند.
- `tokens.json` هو المصدر. لو قيمة اتغيرت، بتتغير في الملف وبعدين في الكود، مش العكس.

### أسماء الـ widgets

`SprintButton`، `SprintTextField`، `SlotChip`، `DayStrip`، `FacilityCard`، `StatusBadge`، `BookingTicket`، `AppNavigation`، `StatTile`، `SprintLogo`، ومعاهم الـ adaptive: `AdaptiveAppBar`، `AdaptiveDialog`، `AdaptiveSheet`، `AdaptiveSwitch`، `AdaptiveLoader`.

كل widget بيعرض نفس الـ properties اللي في جدول Figma، فالـ Code Connect بين الاتنين يبقى مباشر.
