# WideDialog

نافذة التأكيد من medium وأكبر بدل نافذة المنصة (`showSprintDialog` بيختارها لوحده): في النص، 400 عرض، `surface-raised`، `radius-xl`، padding `space-6`.

- أزرار حقيقية ارتفاعها 48. الآمن ("الرجوع"، ghost) أول واحد في ترتيب القراءة، والمدمّر (`danger` مليان) الأخير: في العربي "الرجوع" يمين والزرار الأحمر شمال (refactor 000، قرار P1).
- Enter بيأكد الافتراضي، Escape بيقفل، والتركيز محبوس جواها.
- في الكود `WideDialog` و `WideDialogAction` (`destructive` = زرار `danger` مليان وبيتحط الأخير) في `lib/core/widgets/wide_dialog/`. الترتيب بيتعمل جوه الـ widget مهما كان ترتيب الشاشة، زي `AdaptiveDialog`.
