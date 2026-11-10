# TextField

حقل إدخال بعنوان فوقه ونص مساعد أو رسالة خطأ تحته، وفيه نوع للبحث.

## اللي بيتبعت للـ component

- `label` فوق الحقل دايمًا (مش floating label)، بخط `label` ولون `ink`.
- `placeholder`: مثال حقيقي على الإدخال الصح، بلون `ink-muted`، مش تكرار للـ label.
- `helper` اختياري تحت الحقل بخط `caption` ولون `ink-muted`.
- `error`: لو موجود بيبدّل الـ helper، بلون `danger` ومعاه أيقونة. الرسالة بتقول إيه اللي غلط وإزاي يتصلح.
- `type`: `text` | `password` (فيه "إظهار") | `search` (pill على `surface-sunken`) | `phone` و `email` و `nationalId` (بيتكتبوا LTR).
- `keyboardType` و `autofillHints` حسب النوع.

## الحالات

- **عادي:** `surface` وحد 1px `control-border`، ارتفاع `control-height`، زوايا `radius-sm`.
- **Focus:** حد 2px `primary`. على الويب والديسكتوب بيظهر `focus-ring` كمان مع الكيبورد.
- **خطأ:** حد 2px `danger` وخلفية `danger-soft` والرسالة تحت.
- **معطّل:** `surface-sunken` ونص `ink-disabled`.

## قواعد

- الإيميل والموبايل والرقم القومي وكلمة السر بيتكتبوا LTR حتى في الواجهة العربي، ومتحاذيين مع بداية السطر العربي.
- التحقق بيحصل لما المستخدم يخرج من الحقل أو يضغط الزرار، مش مع كل حرف.
- على iOS الحقل بنفس شكل البراند، بس الكيبورد وشريط الـ autofill بتوع النظام. على Android نفس الكلام.
- لا تستخدم الـ placeholder كبديل للـ label.
