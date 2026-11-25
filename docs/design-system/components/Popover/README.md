# Popover

قايمة مثبّتة جنب الزرار اللي فتحها من medium وأكبر (اللغة، المظهر، اقتراحات البحث). عرضها 260، `surface-raised`، حد `line`، صفوف 48، من غير scrim. Escape أو لمسة برّه بتقفلها والتركيز بيرجع للزرار. على compact بيتفتح sheet بدلها.

- في الكود `SprintPopover` (الصفوف `PopoverOption`: كلام وعلامة صح للمختار) و `showSprintPopover` اللي بيثبّتها تحت الزرار وبيرجّع القيمة المختارة، في `lib/core/widgets/popover/`. الـ widget نفسه مش بيعرف المنصة: الشاشة هي اللي بتختار popover ولا sheet حسب العرض (`adaptive.md`).
