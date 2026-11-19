# BookingRow

حجز واحد في قايمة «حجوزاتي» (US-14، FR-MYB-02). الصف كله هو هدف اللمس.

## اللي بيتبعت

`status`، `facilityName`، `notes` (الوحدة · المدرب · مجاني)، `dateLabel`، `isToday`، `code` (بيتعرض في LTR isolate)، `action` («عرض التذكرة» أو «إكمال الدفع» أو «التفاصيل»)، `selected`.

## الشكل

- `surface`، `radius-lg`، `shadow-card` في الـ light. الهيدر: شريحة التاريخ على الـ start والـ StatusBadge على الـ end؛ لو مش واسعين الشارة تفضل على الـ end في سطر لوحدها والشريحة تنزل تحتها على الـ start بدل ما تفيض. التاريخ ما بينكسرش بحيث حرف الفترة («م») يفضل لوحده.
- اليوم: شريحة `volt` بنص `on-volt`. غير كده: `surface-sunken`.
- `selected` (master-detail من medium): حد 2 `primary` من جوه، فالارتفاع مبيتغيرش.
