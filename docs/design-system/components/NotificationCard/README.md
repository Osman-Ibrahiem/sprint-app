# NotificationCard

إشعار واحد في المركز (FR-NTF-02، BR-39، BR-41).

## اللي بيتبعت

`icon` و `tone` (success، warning، danger، primary)، `title`، `body`، `time`، `unread`، `onTap`، و `actions` اختياري (زي «إلغاء الحجز» في التذكير).

## الشكل

- `surface` بزوايا `radius-lg` وpadding `space-4`، مربع أيقونة 40 دايرة بدرجة النوع.
- غير المقروء: نقطة `primary` 8 قبل العنوان وخط أتقل. المقروء من غير نقطة.
- العنوان `headline`، النص `body` بلون `ink-muted`، الوقت `caption` («4:00 م»).
- الارتفاع 110 وبيكبر لو فيه أزرار.
