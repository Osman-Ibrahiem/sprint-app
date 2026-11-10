# StatusBadge

شارة حالة صغيرة بأيقونة وكلمة، لحالات الحجز والتوثيق والبلاغات.

## اللي بيتبعت للـ component

- `status`، وكل واحدة ليها لون وأيقونة وكلمة ثابتين:

| الحالة | الكلمة | الألوان |
| --- | --- | --- |
| `CONFIRMED` | مؤكد | `success` على `success-soft` |
| `PENDING_PAYMENT` | في انتظار الدفع | `warning` على `warning-soft` |
| `CANCELLED` | اتلغى | `danger` على `danger-soft` |
| `ATTENDED` | حضر | `on-primary-soft` على `primary-soft` |
| `NO_SHOW` | غاب | `ink-muted` على `surface-sunken` |
| `EXPIRED` | انتهت المهلة | `ink-muted` على `surface-sunken` |

- نفس الـ component للتوثيق (قيد المراجعة = warning، موثّق = success، مرفوض = danger) وبلاغات التلف (مفتوح = warning، جاري = primary-soft، اتحل = success).

## الشكل

- pill بزوايا `radius-full`، ارتفاع 28، padding أفقي `space-3`.
- أيقونة `icon-sm` + كلمة بخط `micro`.

## قواعد

- الكلمة والأيقونة إجباريين؛ اللون لوحده مش كفاية، و `success` و `danger` مش متفرقين غير بالدرجة.
- الحالة "غاب" محايدة (`ink-muted`) لأن مفيش عقوبة على الغياب.
- لا تستخدم الـ badge كزرار.
