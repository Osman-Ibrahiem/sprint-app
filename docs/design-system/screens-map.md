# خريطة الشاشات حسب الـ User Story

ملف Figma: https://www.figma.com/design/xeuMQ0KyXsXVh4QldmkbDf. الأسماء بصيغة `<الشاشة> · <المقاس> · <Light | Dark>`. على Compact (390 × 844) المقاس مش بيتكتب في الاسم. كل شاشة ليها Light و Dark، بتبديل mode الـ Color.

**أماكن الشاشات:** صفحة **Compact** (أقسامها ذُكرت جنب كل شاشة)، وصفحة **Medium** (720 × 1000)، وصفحة **Expanded & Large** (1194 × 834 و 1440 × 900). المقاسات الواسعة موجودة للشاشات اللي جنبها "واسع". الشيتات (`AdaptiveSheet`) بتتحول لحوار أو popover من Medium، ومش مرسومة هناك (انظر `adaptive.md`).

## الضيف: اكتشاف ودخول

| US | الشاشات | ملاحظات |
| --- | --- | --- |
| US-01 تصفح من غير حساب (FR-CAT-01 إلى 04) | Home · guest · Facilities · Facilities · filter sheet · Facilities · loading · Facilities · no results · Search · suggestions · Search · results · Facility details · Facility details · free · Facility details · closed today · Facility details · loading · Facility · not found · Choose time · before selection · Choose time · loading · Choose time · no slots · Unit picker · Booking gate · facility details · Account gate · My bookings · Account · guest | واسع: Home · guest وSearch · results وFacility · not found وAccount · guest، وقايمة المنشآت وتفاصيلها في `Booking · list-detail` (Medium) و`Booking iPad 1194` (Expanded). مش واسع: الفلاتر واقتراحات البحث وحالات التحميل ومنشأة مجانية ومقفولة |
| US-02 تسجيل حساب | Sign up · Sign up · email taken · Confirm email · Confirm email · wrong code | واسع |
| US-03 الدخول | Sign in · Sign in · wrong details · Sign in · locked · Sign in · suspended · Forgot password · Reset password · No access | الدخول والتسجيل واسع، باقي الحالات Compact بس |
| US-04 طلب توثيق | Account · not verified · under review · verified · rejected · expired · Verification request · empty · errors · refused · Permission · ID photo | واسع (ما عدا إذن الكاميرا) |

## الحاجز: الحجز والدفع

| US | الشاشات | ملاحظات |
| --- | --- | --- |
| US-06 / US-07 حصري ومشترك | Choose time · Summary · external tier · Slot taken · Overlap with own booking · Unit picker | واسع في `Booking · list-detail` و`Slot taken` |
| US-08 منشأة مجانية | Free · choose range · range conflict · range too long · summary · confirmed | واسع |
| US-09 مع مدرب | Trainer picker · Trainer · no sessions | واسع |
| US-10 فشل الدفع والمهلة | Checkout · hold · last minute · leave payment dialog · gateway cancelled · Payment · gateway (sandbox) · processing · awaiting confirmation · Checkout · payment failed · Hold expired | قسم "Checkout & payment · Compact". واسع |
| US-11 / US-23 السعر حسب الشريحة | Summary · external tier · Home · not verified | واسع |
| US-12 التأكيد | Booking confirmed · Receipt · Free · confirmed · Push · booking confirmed | واسع (الـ push Compact بس) |

## الحاجز: بعد الحجز

| US | الشاشات | ملاحظات |
| --- | --- | --- |
| US-13 التذكير والإلغاء | Push · reminder · Notifications · reminder with cancel · Booking details · upcoming · cancel dialog · after cutoff · Booking cancelled · refund | حوار الإلغاء واسع |
| US-14 حجوزاتي وإشعاراتي وبروفايلي | My bookings · My bookings · past · My bookings · empty · Booking details · pending payment · attended · no-show · expired · Notifications · Notifications · empty · Account · Edit profile · Account · language sheet · appearance sheet · sign out dialog · Permission · notifications | حجوزاتي والتفاصيل والإشعارات والحساب وتعديل البيانات واسعة |

## حالات عامة

Home · loading · Facility details · loading · Account · loading · Offline · no connection (Compact بس، في قسم "States & permissions").

## مواقف في الأقسام (Compact)

`Home` و`Facilities` و`Facility details` و`Choose time` و`Checkout` و`Booking confirmed` و`My bookings` و`Sign in` و`Notifications` و`Account` على الصفحة مباشرة، والباقي في أقسام: Motion states · Auth & verification · Verification · Booking states · Checkout & payment · Guest & booking gate · Booker extras · Bookings & status · States & permissions · Pending, guest account, search.

## التنقل

`AppNavigation` للحاجز فيه `selected` بقيم `home` و`facilities` و`notifications` و`account`، و`default` = حجوزاتي (`bookings`)، على كل الأشكال (`tab-bar` و`rail` و`sidebar`) والمنصات.

## ناقص ومؤجل

النسخة الإنجليزي (LTR) وفريمات Android الخاصة، والشيتات كـ popover على الأحجام الواسعة، واختبار نص 200% الحقيقي على الـ Flutter (في `handoff.md` ملاحظات تقريبية).
