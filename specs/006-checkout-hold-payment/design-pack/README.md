# Design Pack · Feature 006 — الدفع مع الـ Hold وشاشة التأكيد

> مرجع التصميم لـ `/speckit-specify` و`/speckit-plan` الخاصة بـ feature 006. ده مش spec ومش plan: ملخص للتصميم في Figma ومقارنته بالـ BRD، عشان الـ spec تتبني على أرض واضحة.

- **Branch:** `006-checkout-hold-payment` (من `develop`)
- **القراءة الرابعة:** 2026-11-17، بعد commit `05184b2` على [PR #22](https://github.com/Osman-Ibrahiem/sprint-app/pull/22) (docs بس، لسه مفتوح ومش مدموج).
- **Figma:** https://www.figma.com/design/xeuMQ0KyXsXVh4QldmkbDf (Compact · Medium · Expanded & Large · Components)
- **الـ BRD:** US-10، US-12 (أساسي) · US-06 (المدفوع) · US-11 (الشريحة المتثبتة) · FR-BKG-04، FR-BKG-05 · FR-PAY-01، FR-PAY-02، FR-PAY-03 (S) · FR-MYB-01 · FR-NTF-01 (إشعار التأكيد) · BR-12، BR-16، BR-17، BR-28، BR-29، BR-33، BR-39
- **اللي قبل:** feature 005 بتسيب الحجز المدفوع عند `CheckoutComingSoonScreen` (لا حجز ولا Hold). 006 بتستبدلها.

## الملفات

| الملف | فيه إيه |
| --- | --- |
| [figma-vs-brd-report.md](figma-vs-brd-report.md) | **تقرير الفروقات** مع توصية لكل فرق (نعدل Figma / نعدل BRD / نكمل بملاحظة) وأسئلة Osman |
| [screens.md](screens.md) | 8 شاشات: رقم الـ frame، التركيب، الـ components والـ tokens، الحالات، الـ accessibility |
| [flow-and-states.md](flow-and-states.md) | الفلو وحالات الحجز والدفع والـ Hold وعلاقتها بالـ `PaymentProvider` |
| [adaptive.md](adaptive.md) | الشاشة على كل window class وفروق المنصات |
| [copy.md](copy.md) | كل النصوص عربي وإنجليزي مع الـ ARB keys المقترحة |

## قراءة سريعة

- **Figma بيغطي الفلو كله على الأربع أحجام (Light وDark) من غير خانة ناقصة:** الدفع، آخر دقيقة، صفحة المزوّد، جاري التأكيد، لسه مستنيين، الفشل، انتهاء المهلة، الإيصال، والتأكيد (مدفوع ومجاني).
- **فروق النص والعينات (تذكير 3 ساعات، 80 ج.م، رقم الحجز، أفعال الأمر) اتصلحت كلها** في `75d3c9c`.
- **اتقفل في Figma بعد `05184b2`:** حوار "ترك الدفع؟" (الأربع أحجام)، "إلغاء" من صفحة المزوّد بيرجع للدفع ببانر "الدفع اتلغى" والـ Hold شغّال (Compact بس)، وعدّاد الـ Hold في "جاري التأكيد" بقى "فاضل 9:12 دقيقة".
- **قرارات Osman (اتوافق عليها 2026-11-17 واتسجلت في الـ BRD كـ BR-46 وBR-47 وFR-PAY-02/03 وفي `decisions.md`):** (1) قاعدة الـ Hold الممتد والاسترداد التلقائي جنب BR-12، حد أقصى ضعف `holdMinutes` (20). (2) الرجوع أثناء `holding` يلغي الـ Hold بحوار. (3) "إلغاء" في المزوّد = إلغاء مش فشل. (4) الإيصال PDF على الجهاز في P1 مع مشاركة نص كبديل. الـ pack مبني عليهم.
- **لسه ماتعملش:** frames Android، اختبار نص 200% على Medium، مراجعة بصرية لتصليح قص النص، و"الدفع اتلغى" على Medium وأكبر.
- الـ BRD ماتغيّرش. التوصيات في التقرير مستنية قرار Osman.

## قواعد من الـ repo بتحكم الـ pack

- **Tokens فقط**، أسماء من `docs/design-system/tokens.json` (`bg`، `surface`، `ink`، `ink-muted`، `line`، `warning-soft`، `danger-soft`، `primary`، `primary-soft`، `danger`).
- **كل رقم هو setting:** `holdMinutes`، `cancellationCutoffHours`، `refundPercent`، `reminderLeadMinutes` من `Settings` بالوراثة. أي رقم ظاهر في Figma (10 دقايق، ساعتين، 100%، ساعة) عينة بس.
- **صفحة المزوّد في P1 محاكاة جوه التطبيق** (الـ fake). بيانات البطاقة ما بتتخزنش ولا بتتبعت، والـ `PaymentProvider` ما بيتعاملش معاها.

## Out of scope لـ 006 (يتحط في الـ spec)

backend حقيقي · gateway حقيقي (P1 = fake/sandbox) · SMS · الإلغاء والاسترداد وشاشاتهم (feature 7) · حجوزاتي والإشعارات (feature 7) · العروض على السعر (feature 10) · Lottie الحقيقية (feature 11، هنا placeholder ثابت).
