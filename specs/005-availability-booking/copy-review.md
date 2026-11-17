# Copy review: Availability and Booking

Every string this feature added, in Arabic and English, checked on 2026-11-17 against the project's
copy rules (CLAUDE.md, constitution V, FR-039). All keys carry the `booking` prefix.

## Rules checked

| Rule | Result |
| --- | --- |
| Light Egyptian dialect | Pass. "مفيش", "فاضلة", "اتحجز لسه", "عندك حجز" and similar throughout. |
| No imperative verbs (actions are verbal nouns) | Pass. Actions: متابعة، متابعة للدفع، تأكيد الحجز، تحديث المواعيد، تغيير المدرب، إعادة المحاولة، إغلاق الرسالة، الرجوع للمنشأة / للملخص / للرئيسية، طلب توثيق. |
| Western digits | Pass. Numbers come from `SprintFormat` and ICU placeholders, never typed in a string. |
| 12-hour time, "120 ج.م" / "EGP 120" | Pass. Times and prices are placeholders formatted by `SprintFormat` (`7:00 م`, `20 ج.م`). |
| Plurals | Pass. Hours, participants, active bookings and range hints use ICU plurals with the dual form in Arabic (ساعتين، حجزين). |
| Says what happened and what to do next | Pass for every refusal in `bookingFail*` (see the table in contracts/providers.md). |
| No technical text | Pass. `bookingFailGeneric` is the fallback; the test `failure_message_test.dart` checks every refusal. |
| Arabic and English in parity | Pass. `arb_parity_test.dart`. |

## Notes

- Three keys written during implementation were never used and were removed:
  `bookingPriceWithBasis`, `bookingConfirming`, `bookingSessionIn`.
- `bookingFailSlotTakenAt`, `bookingFailSlotFullAt` and `bookingFailClosedAt` name the hour that broke
  a range, so they read "...فالنطاق ده مش متاح". A single slot uses the plain wording without the hour
  (clarify, 2026-11-16).
- Price labels and the price basis ("للمكان الواحد", "للحجز كله") reuse the catalogue's keys
  (`cataloguePrice*`) so the schedule, summary and facility page never word a price two ways.
- English is the second language and was written to match the Arabic meaning, not word for word.

## Strings

| Key | Arabic | English |
| --- | --- | --- |
| `bookingScheduleHeading` | المواعيد | Times |
| `bookingRefreshAction` | تحديث المواعيد | Refresh times |
| `bookingContinue` | متابعة | Continue |
| `bookingUnitLabel` | الوحدة | Unit |
| `bookingUnitHasPlaces` | {unit}، فيه أماكن | {unit}, places available |
| `bookingUnitNoPlaces` | {unit}، مفيش أماكن في اليوم ده | {unit}, no places that day |
| `bookingNothingLeftDay` | مفيش مواعيد فاضلة في اليوم ده، وفيه أيام تانية متاحة. | Nothing is left on this day. Other days have places. |
| `bookingNothingLeftWindow` | مفيش مواعيد فاضلة في الأيام الجاية. | Nothing is left in the coming days. |
| `bookingNoUnitsTitle` | مفيش مواعيد للحجز | No times to book |
| `bookingNoUnitsBody` | المنشأة دي ملهاش مواعيد متاحة للحجز دلوقتي. | This facility has no bookable times right now. |
| `bookingBackToFacility` | الرجوع للمنشأة | Back to the facility |
| `bookingErrorTitle` | المواعيد متحمّلتش | The times did not load |
| `bookingErrorBody` | ممكن تكون مشكلة مؤقتة. | This may be a temporary problem. |
| `bookingRetry` | إعادة المحاولة | Retry |
| `bookingChoiceGone` | الاختيار اللي فات مبقاش متاح، فدي أقرب مواعيد متاحة. | The earlier choice is no longer available. These are the nearest times. |
| `bookingNoticeDismiss` | إغلاق الرسالة | Dismiss message |
| `bookingRangeHint` | {hours, plural, =1{الحجز هنا ساعة واحدة في المرة} =2{الحجز بأول ساعة وآخر ساعة، لحد ساعتين متتاليتين} other{الحجز بأول ساعة وآخر ساعة، لحد {hours} ساعات متتالية}} | {hours, plural, =1{One hour per booking here} other{Pick the first and last hour, up to {hours} hours in a row}} |
| `bookingLengthHours` | {hours, plural, =1{ساعة واحدة} =2{ساعتين} other{{hours} ساعات}} | {hours, plural, =1{1 hour} other{{hours} hours}} |
| `bookingLengthMinutes` | {minutes} دقيقة | {minutes} minutes |
| `bookingTimeWithLength` | الوقت {time}، المدة {length} | Time {time}, length {length} |
| `bookingFree` | مجاني | Free |
| `bookingPanelTitle` | اختيارك | Your choice |
| `bookingSelectionPrompt` | لسه مفيش ميعاد مختار | No time chosen yet |
| `bookingGateReason` | عشان تحجز | to book |
| `bookingFailSlotTaken` | الميعاد ده اتحجز لسه. فيه مواعيد تانية متاحة. | This time was just booked. Other times are available. |
| `bookingFailSlotTakenAt` | الساعة {time} اتحجزت لسه، فالنطاق ده مش متاح. | {time} was just booked, so this range is not available. |
| `bookingFailSlotFull` | الميعاد ده اكتمل لسه. فيه مواعيد تانية متاحة. | This time is now full. Other times are available. |
| `bookingFailSlotFullAt` | الساعة {time} مكتملة، فالنطاق ده مش متاح. | {time} is full, so this range is not available. |
| `bookingFailSlotPast` | وقت الميعاد ده فات. | This time has passed. |
| `bookingFailOutsideWindow` | الحجز متاح للأيام القريبة بس. | Booking is open for the coming days only. |
| `bookingFailClosed` | الميعاد ده مش متاح. | This time is not available. |
| `bookingFailClosedAt` | الساعة {time} مش متاحة، فالنطاق ده مش متاح. | {time} is not available, so this range is not available. |
| `bookingFailRangeTooLong` | {hours, plural, =1{أقصى مدة للحجز ساعة واحدة.} =2{أقصى مدة للحجز ساعتين.} other{أقصى مدة للحجز {hours} ساعات.}} | {hours, plural, =1{The longest booking is 1 hour.} other{The longest booking is {hours} hours.}} |
| `bookingFailRangeTooLongGeneric` | النطاق أطول من المسموح. | The range is longer than allowed. |
| `bookingFailOverlap` | عندك حجز في نفس الوقت: {facility}، {when}. | You already have a booking then: {facility}, {when}. |
| `bookingFailOverlapGeneric` | عندك حجز تاني في نفس الوقت. | You already have another booking at that time. |
| `bookingFailTooMany` | {count, plural, =1{وصلت للحد الأقصى: حجز نشط واحد.} =2{وصلت للحد الأقصى: حجزين نشطين.} other{وصلت للحد الأقصى: {count} حجوزات نشطة.}} | {count, plural, =1{You have reached the limit of 1 active booking.} other{You have reached the limit of {count} active bookings.}} |
| `bookingFailTooManyGeneric` | وصلت للحد الأقصى للحجوزات النشطة. | You have reached the limit of active bookings. |
| `bookingFailNotPermitted` | الحساب ده مش مسموحله يحجز. | This account cannot book. |
| `bookingFailNotFound` | المنشأة أو الميعاد مش متاحين دلوقتي. | The facility or the time is not available right now. |
| `bookingFailGeneric` | الحجز متمّش. المحاولة تاني ممكنة. | The booking did not go through. You can try again. |
| `bookingSummaryTitle` | ملخص الحجز | Booking summary |
| `bookingRowFacility` | المنشأة | Facility |
| `bookingRowUnit` | الوحدة | Unit |
| `bookingRowDate` | اليوم | Day |
| `bookingRowTime` | الوقت | Time |
| `bookingRowLength` | المدة | Length |
| `bookingRowCoverage` | الحجز يشمل | The booking covers |
| `bookingRowTrainer` | المدرب | Trainer |
| `bookingRowTier` | الشريحة | Price tier |
| `bookingRowPrice` | السعر | Price |
| `bookingRowPolicy` | سياسة الإلغاء | Cancellation policy |
| `bookingCoverageWhole` | الوحدة كلها | The whole unit |
| `bookingCoverageWholeMax` | {count, plural, =1{الوحدة كلها، لمشارك واحد} =2{الوحدة كلها، لحد مشاركين} other{الوحدة كلها، لحد {count} مشارك}} | {count, plural, =1{The whole unit, for 1 participant} other{The whole unit, up to {count} participants}} |
| `bookingCoverageOnePlace` | مكان واحد | One place |
| `bookingSessionLength` | حصة {minutes} دقيقة | {minutes}-minute session |
| `bookingPolicyCutoff` | {hours, plural, =0{الإلغاء متاح لحد وقت الميعاد.} =1{الإلغاء متاح لحد ساعة قبل الميعاد.} =2{الإلغاء متاح لحد ساعتين قبل الميعاد.} other{الإلغاء متاح لحد {hours} ساعات قبل الميعاد.}} | {hours, plural, =0{You can cancel until the start time.} =1{You can cancel up to 1 hour before the start.} other{You can cancel up to {hours} hours before the start.}} |
| `bookingPolicyRefundFull` | المبلغ بيرجع كامل. | The full amount is refunded. |
| `bookingPolicyRefundPartial` | بيرجع {percent}% من المبلغ. | {percent}% of the amount is refunded. |
| `bookingPolicyRefundNone` | المبلغ مش بيرجع. | The amount is not refunded. |
| `bookingVerifyHint` | توثيق الحساب بيدّي سعر الطلاب والعاملين. | A verified account gets the student and staff price. |
| `bookingVerifyAction` | طلب توثيق | Verification request |
| `bookingVerifyPending` | طلب التوثيق قيد المراجعة. السعر الداخلي بيسري على الحجوزات الجديدة بعد الموافقة. | Your verification request is under review. The internal price applies to new bookings after approval. |
| `bookingPriceChanged` | السعر اتغيّر عن اللي ظهر في المواعيد. ده السعر الحالي. | The price changed from what the schedule showed. This is the current price. |
| `bookingPayAction` | متابعة للدفع | Continue to payment |
| `bookingConfirmAction` | تأكيد الحجز | Confirm booking |
| `bookingFreeNoPayment` | الحجز مجاني ومفيش خطوة دفع. | This booking is free and has no payment step. |
| `bookingCheckoutSoonTitle` | الدفع قريبًا | Payment is coming soon |
| `bookingCheckoutSoonBody` | خطوة الدفع هتتضاف قريب. اختيارك محفوظ في الملخص. | The payment step arrives soon. Your choice is kept in the summary. |
| `bookingBackToSummary` | الرجوع للملخص | Back to the summary |
| `bookingDoneTitle` | الحجز اتأكد | Booking confirmed |
| `bookingDoneBody` | الحجز متسجل على حسابك، وهيظهر في الرئيسية. | The booking is on your account and shows on home. |
| `bookingDoneCode` | رقم الحجز | Booking code |
| `bookingDoneHome` | الرجوع للرئيسية | Back to home |
| `bookingDoneNotFoundTitle` | الحجز مش موجود | Booking not found |
| `bookingDoneNotFoundBody` | ممكن يكون اللينك غلط أو الحجز تبع حساب تاني. | The link may be wrong, or the booking belongs to another account. |
| `bookingTrainerStepTitle` | اختيار المدرب | Choosing a trainer |
| `bookingTrainerStepBody` | المواعيد بتظهر بعد اختيار المدرب. | Times show after a trainer is chosen. |
| `bookingTrainerHasSessions` | عنده حصص في الأيام الجاية | Has sessions in the coming days |
| `bookingTrainerNoSessions` | مفيش حصص في الأيام الجاية | No sessions in the coming days |
| `bookingTrainerNoName` | مدرب | Trainer |
| `bookingTrainerChange` | تغيير المدرب | Change trainer |
| `bookingTrainerChosen` | المدرب: {name} | Trainer: {name} |
| `bookingNoTrainersTitle` | مفيش مدربين متاحين | No trainers available |
| `bookingNoTrainersBody` | المنشأة دي لسه ملهاش مدربين للحجز. | This facility has no trainers to book yet. |
| `bookingTrainerNoSessionsBody` | المدرب ده ملوش حصص في الأيام الجاية. | This trainer has no sessions in the coming days. |
