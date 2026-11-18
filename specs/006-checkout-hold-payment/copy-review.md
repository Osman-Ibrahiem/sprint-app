# Copy review: Checkout with Hold and Sandbox Payment, Confirmation Ticket

Every string this feature added, in Arabic and English, checked on 2026-11-18 against the project's
copy rules (CLAUDE.md, constitution V) and `design-pack/copy.md`, which wins over Figma. Keys carry the
`checkout`, `gateway`, `processing`, `awaiting`, `holdExpired`, `receipt`, `confirmed`, `lead` and
`demoPayment` prefixes, plus `ticketQrLabel`.

## Rules checked

| Rule | Result |
| --- | --- |
| Light Egyptian dialect | Pass. "المكان متحجز لك", "فاضل", "لسه", "ماتمّش", "بنأكد", "اتلغى", "الفلوس بترجع". |
| No imperative verbs (actions are verbal nouns) | Pass. Actions: الدفع، إعادة المحاولة، ترك الدفع، إكمال الدفع، تأكيد الدفع، إلغاء، تحديث الحالة، الرجوع للحجوزات / للرئيسية، اختيار ميعاد تاني، حفظ الإيصال PDF، مشاركة الإيصال. The one imperative in the task list ("اعرضه للمدرب" for the QR label) was replaced by "رمز الحضور، بيتعرض للمدرب عند الدخول". |
| Western digits | Pass. Numbers come from `SprintFormat`, `countdownText` (m:ss) and ICU placeholders. |
| 12-hour time, "80 ج.م" / "EGP 80" | Pass. Amounts and times go through `SprintFormat`; the countdown is m:ss. |
| Plurals | Pass. Seconds, hours and minutes in the lead and the last minute use ICU plurals with the dual form in Arabic (ثانيتين، ساعتين). |
| Numbers from settings, not typed | Pass. `{hours}`, `{percent}`, `{until}` and `{lead}` come from `cancellationCutoffHours`, `refundPercent` and `reminderLeadMinutes`; 3 ساعات and 80 ج.م in Figma are samples only. |
| Errors do not expose provider or card details | Pass. `checkoutStartError` and `gatewayErr*` say what to fix, never why the provider refused. |
| Arabic and English in parity | Pass. `arb_parity_test.dart`. |

## Notes

- Existing keys reused instead of duplicated: `backToHome`, `statusExpired`, `statusConfirmed`,
  `statusPendingPayment`, `bookingSummaryTitle` (copy.md `checkoutSummaryTitle`), `bookingFree`
  (`priceFree`), `ticketCopied` (`codeCopied`), `ticketPaid`, `ticketCancelUnavailable`,
  `bookingRowPrice`, `bookingDoneNotFound*`.
- `ticketCancelUntil` (the 002 ticket's line) now reads "الإلغاء متاح لحد {date}" as copy.md says; it was
  "إلغاء مجاني لحد", which would be wrong whenever `refundPercent` is under 100.
- `checkoutTierInternal` / `checkoutTierExternal` are the copy.md wording ("داخلي · موثّق"); the schedule
  and summary keep their own price labels (`cataloguePrice*Label`).
- `confirmedAddToCalendar` from copy.md is not added (no add to calendar, clarify 2026-11-17).
- Keys written during implementation and never used were removed: `receiptCopied`, `confirmedCancelUntil`.

## Strings

| Key | Arabic | English |
| --- | --- | --- |
| `checkoutTitle` | الدفع | Payment |
| `checkoutHoldTitle` | المكان متحجز لك لحد ما الدفع يخلص | Your place is held until payment completes |
| `checkoutHoldRemaining` | فاضل {time} دقيقة، وبعدها المكان يرجع متاح | {time} minutes left, then the place is released |
| `checkoutLastMinuteTitle` | المهلة على وشك تخلص | Time is almost up |
| `checkoutLastMinuteBody` | {seconds, plural, =1{فاضل ثانية واحدة، وبعدها المكان يرجع متاح} =2{فاضل ثانيتين، وبعدها المكان يرجع متاح} other{فاضل {seconds} ثانية، وبعدها المكان يرجع متاح}} | {seconds, plural, =1{1 second left, then the place is released} other{{seconds} seconds left, then the place is released}} |
| `checkoutTierInternal` | داخلي · موثّق | Internal · verified |
| `checkoutTierExternal` | خارجي · السعر الكامل | External · full price |
| `checkoutPolicyTitle` | سياسة الإلغاء | Cancellation policy |
| `checkoutPolicyBody` | الإلغاء متاح لحد {until} ({hours} قبل الميعاد) والفلوس بترجع {percent}% على نفس وسيلة الدفع. بعد كده زرار الإلغاء بيختفي. | Cancellation is available until {until} ({hours} before the start) and {percent}% is refunded to the same payment method. After that the cancel button is hidden. |
| `checkoutMethodTitle` | الدفع الإلكتروني | Online payment |
| `checkoutMethodSubtitle` | بطاقة بنكية أو محفظة موبايل · صفحة المزوّد الآمنة | Bank card or mobile wallet · provider's secure page |
| `checkoutSandboxTag` | وضع الاختبار · مفيش فلوس حقيقية بتتخصم | Test mode · no real money is charged |
| `checkoutPay` | الدفع · {amount} | Pay · {amount} |
| `checkoutPaySpoken` | الدفع، {amount} جنيه | Pay, {amount} Egyptian pounds |
| `checkoutStartError` | بدء الدفع ماتمّش. المكان لسه متحجز لك، وممكن تحاول تاني. | Payment couldn't start. Your place is still held, and you can try again. |
| `checkoutFailedTitle` | الدفع ماتمّش. ممكن تحاول تاني | Payment didn't go through. You can try again |
| `checkoutFailedBody` | المكان لسه متحجز لك لحد ما المهلة تخلص. | Your place is still held until the time runs out. |
| `checkoutRetry` | إعادة المحاولة · {amount} | Try again · {amount} |
| `holdExpiredTitle` | المهلة خلصت | Time ran out |
| `holdExpiredBody` | المكان رجع متاح للناس. ممكن تختار الميعاد من جديد. | The place is available to others again. You can pick a time again. |
| `holdExpiredPickAnother` | اختيار ميعاد تاني | Pick another time |
| `checkoutLeaveTitle` | ترك الدفع؟ | Leave payment? |
| `checkoutLeaveBody` | لو سبت الصفحة دلوقتي، المكان بيرجع متاح للناس. | If you leave the page now, the place is released to others. |
| `checkoutLeaveConfirm` | ترك الدفع | Leave payment |
| `checkoutLeaveStay` | إكمال الدفع | Continue paying |
| `checkoutCancelledTitle` | الدفع اتلغى | Payment cancelled |
| `checkoutCancelledBody` | المكان لسه متحجز لك، وممكن تحاول تاني | Your place is still held, and you can try again |
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
| `gatewayErrCardNumber` | رقم البطاقة مش صحيح | The card number isn't valid |
| `gatewayErrExpiry` | تاريخ الانتهاء مش صحيح أو فات | The expiry date isn't valid or has passed |
| `gatewayErrCvc` | رمز الأمان لازم يكون 3 أو 4 أرقام | The security code must be 3 or 4 digits |
| `gatewayErrName` | اسم حامل البطاقة مطلوب | The cardholder name is required |
| `gatewayExpiryHint` | شهر/سنة | MM/YY |
| `processingTitle` | بنأكد الدفع | Confirming your payment |
| `processingBody` | التأكيد بييجي من مزوّد الدفع وممكن ياخد لحظات، والأحسن إن الشاشة تفضل مفتوحة | Confirmation comes from the payment provider and may take a moment, and it's best to keep this screen open |
| `processingHeld` | المكان متحجز لك، فاضل {time} دقيقة | Your place is held, {time} minutes left |
| `awaitingTitle` | لسه مستنيين تأكيد الدفع | Still waiting for payment confirmation |
| `awaitingBody` | لو الخصم حصل ومتأكدش الحجز، الفلوس بترجع لوحدها. المكان متحجز لك لحد ما التأكيد يوصل | If you were charged and the booking isn't confirmed, the money is returned automatically. Your place is held until the confirmation arrives |
| `awaitingRefresh` | تحديث الحالة | Refresh status |
| `awaitingRefreshing` | جاري تحديث الحالة | Refreshing status |
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
| `receiptPdfFailed` | الـ PDF ماتعملش. اتشاركت نسخة نصية بدله | The PDF couldn't be made. A text copy was shared instead |
| `receiptNotFoundTitle` | الإيصال مش موجود | Receipt not found |
| `receiptNotFoundBody` | مفيش إيصال للحجز ده. الإيصال بيظهر بعد دفع ناجح. | There is no receipt for this booking. A receipt appears after a successful payment. |
| `confirmedTitle` | حجزك اتأكد | Your booking is confirmed |
| `confirmedSubtitle` | وصلك إشعار بالتفاصيل، وهنفكرك قبل الميعاد بـ{lead}. | You got a notification with the details, and we'll remind you {lead} before. |
| `confirmedReceiptRow` | إيصال الدفع | Payment receipt |
| `leadHours` | {hours, plural, =1{ساعة} =2{ساعتين} other{{hours} ساعات}} | {hours, plural, =1{1 hour} other{{hours} hours}} |
| `leadHoursHalf` | {hours, plural, =0{نص ساعة} =1{ساعة ونص} =2{ساعتين ونص} other{{hours} ساعات ونص}} | {hours, plural, =0{30 minutes} =1{1.5 hours} other{{hours}.5 hours}} |
| `leadMinutes` | {minutes, plural, =1{دقيقة} =2{دقيقتين} other{{minutes} دقيقة}} | {minutes, plural, =1{1 minute} other{{minutes} minutes}} |
| `demoPaymentTitle` | الدفع التجريبي | Demo payment |
| `demoPaymentNote` | بيحدد اللي هيحصل لما صفحة المزوّد تأكد الدفع. للعرض بس. | Sets what happens when the provider page confirms payment. For the demo only. |
| `demoPaymentSuccess` | نجاح | Success |
| `demoPaymentFail` | فشل | Failure |
| `demoPaymentDelay` | تأخير | Delay |
| `demoPaymentDelayPreset` | {seconds} ثانية | {seconds} s |
| `demoPaymentDelayAfterMax` | بعد الحد الأقصى | Past the maximum |
| `demoPaymentCurrent` | الاختيار الحالي: {value} | Current choice: {value} |
| `demoPaymentDelayCurrent` | تأخير {seconds} ثانية، وبعدها نجاح | Delay of {seconds} seconds, then success |
| `ticketQrLabel` | رمز الحضور، بيتعرض للمدرب عند الدخول | Attendance code, shown to the trainer at the entrance |
