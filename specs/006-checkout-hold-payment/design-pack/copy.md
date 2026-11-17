# النصوص · Feature 006

قواعد (CLAUDE.md): لهجة مصرية خفيفة، **من غير أفعال أمر**، الأزرار مصادر ("تأكيد"، "إعادة المحاولة")، أرقام Western، وقت 12 ساعة ("5:00 م")، "80 ج.م" / "EGP 80"، كل النصوص في ملفات الـ l10n. اللي بين `{ }` متغيّر. **الـ ARB keys** مقترحة ويثبتها الـ plan، بادئتها `checkout…` و`confirmed…`.

> النصوص من Figma بعد commit `75d3c9c` (A1 إلى A4 اتصلحوا فيه). **★** = مش مرسوم في Figma (مشتق من الـ pack): حوار الخروج وصف الإيصال في ملف الـ ARB ومفاتيح التذكرة اللي بتتولّد من إعدادات.

## الدفع

| الـ key المقترح | عربي | English |
| --- | --- | --- |
| `checkoutTitle` | الدفع | Payment |
| `checkoutHoldTitle` | المكان متحجز لك لحد ما الدفع يخلص | Your place is held until payment completes |
| `checkoutHoldRemaining` | فاضل {time} دقيقة، وبعدها المكان يرجع متاح | {time} minutes left, then the place is released |
| `checkoutLastMinuteTitle` | المهلة على وشك تخلص | Time is almost up |
| `checkoutLastMinuteBody` | فاضل {seconds} ثانية، وبعدها المكان يرجع متاح | {seconds} seconds left, then the place is released |
| `checkoutRowUnit` / `Trainer` / `Time` / `Tier` / `Total` | الوحدة · المدرب · الميعاد · الشريحة · الإجمالي | Unit · Trainer · Time · Tier · Total |
| `tierInternal` | داخلي · موثّق | Internal · verified |
| `tierExternal` | خارجي · السعر الكامل | External · full price |
| `checkoutPolicyTitle` | سياسة الإلغاء | Cancellation policy |
| `checkoutPolicyBody` | الإلغاء متاح لحد {until} ({hours} قبل الميعاد) والفلوس بترجع {percent}% على نفس وسيلة الدفع. بعد كده زرار الإلغاء بيختفي. | Cancellation is available until {until} ({hours} before the start) and {percent}% is refunded to the same payment method. After that the cancel button is hidden. |
| `checkoutMethodTitle` | الدفع الإلكتروني | Online payment |
| `checkoutMethodSubtitle` | بطاقة بنكية أو محفظة موبايل · صفحة المزوّد الآمنة | Bank card or mobile wallet · provider's secure page |
| `checkoutSandboxTag` | وضع الاختبار · مفيش فلوس حقيقية بتتخصم | Test mode · no real money is charged |
| `checkoutPay` | الدفع · {amount} | Pay · {amount} |

## فشل الدفع

| الـ key | عربي | English |
| --- | --- | --- |
| `checkoutFailedTitle` | الدفع ماتمّش. ممكن تحاول تاني | Payment didn't go through. You can try again |
| `checkoutFailedBody` | المكان لسه متحجز لك لحد ما المهلة تخلص. | Your place is still held until the time runs out. |
| `checkoutSummaryTitle` | ملخص الحجز | Booking summary |
| `checkoutRetry` | إعادة المحاولة · {amount} | Try again · {amount} |

## انتهاء المهلة

| الـ key | عربي | English |
| --- | --- | --- |
| `holdExpiredTitle` | المهلة خلصت | Time ran out |
| `holdExpiredBody` | المكان رجع متاح للناس. ممكن تختار الميعاد من جديد. | The place is available to others again. You can pick a time again. |
| `statusExpired` | انتهت المهلة | Expired |
| `holdExpiredPickAnother` | اختيار ميعاد تاني | Pick another time |
| `backToHome` | الرجوع للرئيسية | Back to home |

## الخروج من الدفع وإلغاء صفحة المزوّد (من Figma `05184b2`)

| الـ key | عربي | English |
| --- | --- | --- |
| `checkoutLeaveTitle` | ترك الدفع؟ | Leave payment? |
| `checkoutLeaveBody` | لو سبت الصفحة دلوقتي، المكان بيرجع متاح للناس. | If you leave the page now, the place is released to others. |
| `checkoutLeaveConfirm` | ترك الدفع | Leave payment |
| `checkoutLeaveStay` | إكمال الدفع | Continue paying |
| `checkoutCancelledTitle` | الدفع اتلغى | Payment cancelled |
| `checkoutCancelledBody` | المكان لسه متحجز لك، وممكن تحاول تاني | Your place is still held, and you can try again |

## صفحة المزوّد · المعالجة · الانتظار · الإيصال (من Figma بعد PR #22)

النصوص دي زي ما هي في Figma.

| الـ key | عربي | English |
| --- | --- | --- |
| `gatewayTitle` | الدفع الآمن | Secure payment |
| `gatewayHoldTitle` | المكان متحجز لك | Your place is held |
| `gatewayHoldBody` | فاضل {time} دقيقة لإكمال الدفع | {time} minutes left to complete payment |
| `gatewayAmountLabel` | المبلغ المطلوب | Amount due |
| `gatewayMerchant` | سبرنت · {facility} | Sprint · {facility} |
| `gatewayCardNumber` | رقم البطاقة | Card number |
| `gatewayCardExpiry` | تاريخ الانتهاء | Expiry date |
| `gatewayCardCvc` | رمز الأمان | Security code |
| `gatewayCardName` | اسم حامل البطاقة | Cardholder name |
| `gatewayCardNameHint` | الاسم زي ما هو على البطاقة | Name as shown on the card |
| `gatewayNotice` | الصفحة دي بتاعة مزوّد الدفع. بعد التأكيد بنرجعلك للتطبيق | This page belongs to the payment provider. After confirming, we bring you back to the app |
| `gatewayConfirm` | تأكيد الدفع · {amount} | Confirm payment · {amount} |
| `gatewayCancel` | إلغاء | Cancel |
| `processingTitle` | بنأكد الدفع | Confirming your payment |
| `processingBody` | التأكيد بييجي من مزوّد الدفع وممكن ياخد لحظات، والأحسن إن الشاشة تفضل مفتوحة | Confirmation comes from the payment provider and may take a moment, and it's best to keep this screen open |
| `processingHeld` | المكان متحجز لك، فاضل {time} دقيقة | Your place is held, {time} minutes left |
| `statusPendingPayment` | في انتظار الدفع | Awaiting payment |
| `awaitingTitle` | لسه مستنيين تأكيد الدفع | Still waiting for payment confirmation |
| `awaitingBody` | لو الخصم حصل ومتأكدش الحجز، الفلوس بترجع لوحدها. المكان متحجز لك لحد ما التأكيد يوصل | If you were charged and the booking isn't confirmed, the money is returned automatically. Your place is held until the confirmation arrives |
| `awaitingRefresh` | تحديث الحالة | Refresh status |
| `awaitingBackToBookings` | الرجوع للحجوزات | Back to my bookings |
| `receiptTitle` | إيصال دفع | Payment receipt |
| `receiptNumber` | رقم الإيصال | Receipt number |
| `receiptBookingCode` | رقم الحجز | Booking code |
| `receiptDate` | التاريخ | Date |
| `receiptUnit` | الوحدة | Unit |
| `receiptTier` | الشريحة | Tier |
| `receiptMethod` | وسيلة الدفع | Payment method |
| `receiptMethodCard` | بطاقة تنتهي بـ {last4} · اختبار | Card ending in {last4} · test |
| `receiptTotalPaid` | الإجمالي المدفوع | Total paid |
| `receiptSave` | حفظ الإيصال PDF | Save receipt as PDF |
| `receiptShare` | مشاركة الإيصال | Share receipt |
| `receiptNavTitle` | الإيصال | Receipt |

## تأكيد الحجز

| الـ key | عربي | English |
| --- | --- | --- |
| `confirmedTitle` | حجزك اتأكد | Your booking is confirmed |
| `confirmedSubtitle` | وصلك إشعار بالتفاصيل، وهنفكرك قبل الميعاد بـ{lead}. (Figma: "بثلاث ساعات") | You got a notification with the details, and we'll remind you {lead} before. |
| `statusConfirmed` | مؤكد | Confirmed |
| `ticketCode` | رقم الحجز | Booking code |
| `ticketShowTrainer` | الكود بيتعرض للمدرب عند الدخول · السطوع العالي أوضح | The code is shown to the trainer at the entrance · high brightness is clearer |
| `ticketPaid` | المدفوع | Paid |
| `ticketPrice` | السعر | Price |
| `priceFree` | مجاني | Free |
| `ticketCancelUntil` | الإلغاء متاح لحد {until} | Cancellation available until {until} |
| `ticketCancelUnavailable` | الإلغاء مش متاح | Cancellation isn't available |
| `confirmedAddToCalendar` | إضافة للتقويم | Add to calendar |
| `backToHome` | الرجوع للرئيسية | Back to home |
| `receiptRow` | إيصال الدفع | Payment receipt |
| ★ `codeCopied` | اتنسخ | Copied |

## قواعد التوليد

- `{lead}` من `reminderLeadMinutes`: 180 → "3 ساعات"، 60 → "ساعة"، 90 → "ساعة ونص". استخدم plurals في الـ ARB، لا تكتب "3" ثابتة.
- `{hours}` من `cancellationCutoffHours`، `{percent}` من `refundPercent`، `{until}` = البداية ناقص الـ cutoff مكتوبة "الأحد 3:00 م".
- **ممنوع** في الشاشات دي: "وريه"، "كمّل"، "متقفلش"، "اختار"، "دوس"، وأي فعل أمر (اتشالوا من Figma في `75d3c9c`، لو ظهروا تاني تتصلح). الأمثلة المقبولة: "اختيار ميعاد تاني"، "ترك الدفع"، "إعادة المحاولة".
- **أرقام الدفع والكود** في LTR isolate. الكود `SPR-4F7K2` بخط الـ `code` (Cairo).
- رسائل الخطأ **ما بتكشفش** تفاصيل المزوّد أو الكارت.
