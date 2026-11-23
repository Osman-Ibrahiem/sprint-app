# Banner

شريط جملة وأيقونة بدرجة من خمسة (US-13، US-14، BR-12، BR-31، BR-32): `hold` (`warning-soft`)، `neutral` (`surface-sunken`)، `success` (`success-soft`)، `info` (`primary-soft`)، `danger` (`danger-soft`).

- كل درجة ليها أيقونتها، فالدرجة بتتفهم من غير اللون (refactor 000، قرار U4):

| الدرجة | الخلفية | الأيقونة | جملة مثال |
| --- | --- | --- | --- |
| `hold` | `warning-soft` | ساعة رملية (hourglass) | المكان متحجز لك لحد ما المهلة تخلص |
| `neutral` | `surface-sunken` | info | مفيش أي رسوم أو عقوبة على الغياب |
| `success` | `success-soft` | دايرة فيها صح (check-circle) | الدفع اتأكد |
| `info` | `primary-soft` | info | التوثيق بيدّيك سعر الطلاب |
| `danger` | `danger-soft` | دايرة فيها X (x-circle) | الحجز اتلغى من الإدارة |

- أقل ارتفاع 48 وبيكبر مع النص. الأيقونة دايمًا معاها كلام: اللون لوحده مش كفاية.
- بيتعلن كـ live region. `trailing` اختياري (زر إغلاق) وبيفضل قابل للوصول.
- حلّ مكان `InfoBanner` في تدفق الحجز.
