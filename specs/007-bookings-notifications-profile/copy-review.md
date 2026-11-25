# Copy review: feature 007

> **2026-11-24, refactor 000 decision N1 (Osman):** the English navigation label for notifications (`navNotifications`) is "Alerts" in the tab bar, rail and sidebar, because "Notifications" does not fit the 88-wide rail. The notifications screen title stays "Notifications", and Arabic stays "الإشعارات" in both places. Same trail as decision 13 (notes in `specs/001`, `002`, `006` `copy-review.md`). See `docs/decisions.md` 2026-11-24.

Checked every new key (`bookings*`, `bookingDetails*`, `cancel*`, `notif*`, `notifications*`, `permission*`, `account*`, `editProfile*`, `search*`, `demo007*`, `gallery007*`) in `app_ar.arb` and `app_en.arb` against the copy rules.

- **No imperative verbs in buttons**: all actions are verbal nouns ("إلغاء الحجز", "تعليم الكل كمقروء", "حفظ", "تغيير الصورة", "حذف الصورة", "مسح الكل"). Fixed while writing: the failure lines say what happened ("الإلغاء ماتمش والحجز زي ما هو") instead of telling the person to retry; the retry button is the noun "إعادة المحاولة".
- **Egyptian wording**: "حسابك اتوثّق" (not the MSA form of the pack), "اتلغى", "هترجع", "فاضل N دقايق". Two pack phrases kept as drawn: "تم تسجيل حضورك. شكرًا لاستخدامك سبرنت" and "تم إلغاء حجزك" (they read acceptably in Egyptian too); Osman may soften them.
- **Digits, time and money**: all amounts go through `SprintFormat.price`, times through `SprintFormat.time` or `localTime` (12-hour), booking codes through `LtrIsolate`; no digit is typed into a string.
- **Parameters, not samples**: the refund amounts, the cutoff time, the hold minutes and the reminder text come from the booking and the settings.
- **Not checked**: English strings were read for meaning only; no native review.
