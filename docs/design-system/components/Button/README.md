# Button

زرار الإجراءات في سبرنت بخمس تنويعات: primary و secondary و tonal و ghost و danger، بمقاسين.

## اللي بيتبعت للـ component

- `label`: مصدر مش فعل أمر ("تأكيد الحجز"، "إلغاء الحجز") عشان يبقى محايد للجنسين. بخط `button` (Cairo 600).
- `variant`: `primary` | `secondary` | `tonal` | `ghost` | `danger`.
- `size`: `md` (ارتفاع `control-height`، الافتراضي، زوايا `radius-md` و padding أفقي `space-5`) | `sm` (`control-height-sm`، زوايا `radius-sm` و padding أفقي `space-3`، في جداول الإدارة بس، ومنطقة اللمس حواليه 48) (refactor 000، قرار 12).
- `icon` اختياري في البداية أو النهاية، مقاس `icon-md`. الأسهم بتنعكس في RTL.
- `loading`: بيبدّل الأيقونة بـ spinner ويغيّر النص لحالة جارية ("جاري الدفع…") وما بيتضغطش تاني.
- `onPressed`. لو مش متاح، الأفضل يفضل شغال ويقول السبب، والـ disabled للحالات اللي مالهاش معنى غير كده.

## إمتى تستخدم أنهي

- **`primary`** واحد بس في الشاشة: الإجراء اللي الشاشة معمولة عشانه (تأكيد الحجز، الدفع، الدخول). `primary` على `on-primary`.
- **`secondary`** للإجراءات المساوية في الأهمية جنب الأساسي (تغيير الميعاد). `surface` وحد `control-border`.
- **`tonal`** للإجراء المفيد اللي مش أساسي (عرض التذكرة، إضافة للتقويم). `primary-soft` على `on-primary-soft`.
- **`ghost`** للروابط والإجراءات الهادية (التفاصيل، تخطي). نص `primary`.
- **`danger`** للإجراءات اللي ما بترجعش (إلغاء الحجز، حذف عهدة)، ودايمًا بعد تأكيد في dialog.

## الحالات حسب المنصة

- iOS: الضغط بيخفت الـ fill لـ 70%، مفيش ripple. الشكل بزوايا continuous.
- Android: ripple بـ `primary-pressed`.
- Web و Desktop: hover بـ `primary-hover`، و focus بـ `focus-ring` (2px بمسافة 2px)، والمؤشر pointer.
- كل variant بيتغير في الـ hover والضغط بلون من عيلته، والنص فاضل مقروء: `primary` بـ `primary-hover` و `primary-pressed`، و `secondary` و `ghost` بـ `surface-sunken`، و `tonal` بدرجة أغمق من `primary-soft`، و `danger` بدرجة أغمق من `danger`. درجات tonal و danger tokens بتتضاف لـ `tokens.json` بقيم Light و Dark (refactor 000، قرار U1).

## افعل ولا تفعل

- افعل: حط السعر في زرار الدفع ("تأكيد الحجز · 120 ج.م") عشان المستخدم يعرف هيدفع كام قبل ما يضغط.
- افعل: في الشاشات الضيقة، الزرار الأساسي بعرض الشاشة في شريط ثابت تحت (`shadow-sheet`).
- لا تحط زرارين `primary` جنب بعض.
- لا تستخدم `volt` كخلفية زرار؛ `volt` للإبراز مش للإجراءات.
