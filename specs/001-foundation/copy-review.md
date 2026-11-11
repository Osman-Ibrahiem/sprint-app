# Copy review (T044, FR-015)

Reviewed on 2026-11-11 against `docs/design-system/README.md` § المحتوى والصوت: light Egyptian
dialect, no imperative verbs, buttons as verbal nouns, gender-neutral wording, Western digits,
English in sentence case with no "please" or "successfully". Scope: every string in
`lib/l10n/app_ar.arb` and `app_en.arb` at the end of US2.

| Key | Arabic | English | Result |
| --- | --- | --- | --- |
| `appName` | سبرنت | Sprint | OK |
| `navHome` / `navFacilities` / `navBookings` / `navProfile` | الرئيسية / المنشآت / حجوزاتي / حسابي | Home / Facilities / My bookings / Profile | OK, nouns |
| `navMainLabel` | التنقل الرئيسي | Main navigation | OK |
| `homeTitle` | أهلًا في سبرنت | Welcome to Sprint | **Changed**: "أهلًا بيك" is masculine; "أهلًا في" is neutral |
| `homeIntro`, `facilitiesIntro`, `placeholderNote` | dialect, future tense, no commands | matches | OK |
| `facilitiesTitle`, `facilitiesSearchHint` | منشآت الجامعة / البحث عن منشأة | University facilities / Search facilities | OK, verbal noun for the hint |
| `signInPromptTitle` | تسجيل الدخول مطلوب | Sign-in needed | **Changed**: "محتاج" is masculine; the noun phrase is neutral |
| `signInPromptBody` | حجوزاتك وبيانات حسابك هتظهر هنا بعد تسجيل الدخول… | matches | OK, neutral possessive |
| `notFoundTitle`, `notFoundBody`, `backToHome` | الصفحة دي مش موجودة / … / الرجوع للرئيسية | This page doesn't exist / … / Back to home | OK, verbal noun button |
| `appearanceTitle`, `appearanceSystem/Light/Dark` | المظهر / حسب الجهاز / فاتح / غامق | Appearance / Match device / Light / Dark | OK |
| `languageTitle`, `languageAr`, `languageEn` | اللغة / العربية / English | Language / العربية / English | OK, each language in its own script |
| `demoEntry`, `optionSelected` | شاشة العرض للمراجعين / مختار | Reviewer demo screen / Selected | OK |
| `priceEgp` | {amount} ج.م | EGP {amount} | OK, Western digits |

English meanings match the Arabic for every key. Wording is placeholder-level; Osman or Dr. Sara
may still adjust tone in review.
