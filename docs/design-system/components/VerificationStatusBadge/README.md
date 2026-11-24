# VerificationStatusBadge

حالة توثيق الحساب ككلمة وأيقونة بنفس شكل `StatusBadge` (FR-029). في الكود `VerificationStatusBadge` في `lib/features/verification/presentation/`.

## اللي بيتبعت للـ component

- `state`: `none` | `underReview` | `approved` | `rejected` | `expired`.

## الحالات

| الحالة | الألوان | الأيقونة |
| --- | --- | --- |
| `none` (مش موثّق) | `ink-muted` على `surface-sunken` | دايرة متقطعة |
| `underReview` (قيد المراجعة) | `warning` على `warning-soft` | ساعة |
| `approved` (موثّق) | `success` على `success-soft` | ختم فيه صح (seal-check) |
| `rejected` (مرفوض) | `danger` على `danger-soft` | دايرة فيها X |
| `expired` (منتهي) | `ink-muted` على `surface-sunken` | ساعة رملية |

الألوان والأيقونات من نفس أزواج `StatusBadge` (`SprintStatus`)، فالشارتين شبه بعض في التطبيق كله.

## الشكل والقواعد

- pill بزوايا `radius-full`، ارتفاع 28 على الأقل، padding أفقي `space-3`، أيقونة `icon-sm` والكلمة بخط `micro`.
- الكلمة دايمًا ظاهرة مع الأيقونة: الحالة مش باللون لوحده.
- بتتعلن كـ live region، وقارئ الشاشة بيقول "الحالة: {الكلمة}".
