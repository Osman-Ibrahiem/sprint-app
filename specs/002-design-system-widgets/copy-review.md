# Copy review (T070)

Every Arabic and English string added by feature 002, for Osman's review before merge. Checked against `docs/design-system/README.md` § المحتوى والصوت: light Egyptian dialect, no imperative verbs, verbal-noun buttons, gender-neutral wording, Western digits, English in sentence case. Plural forms are shown in ICU syntax as stored.

| Key | Arabic | English | Shown in |
| --- | --- | --- | --- |
| `dayShortSaturday` | السبت | Sat | DayStrip |
| `dayShortSunday` | الحد | Sun | DayStrip |
| `dayShortMonday` | الاتنين | Mon | DayStrip |
| `dayShortTuesday` | التلات | Tue | DayStrip |
| `dayShortWednesday` | الأربع | Wed | DayStrip |
| `dayShortThursday` | الخميس | Thu | DayStrip |
| `dayShortFriday` | الجمعة | Fri | DayStrip |
| `dayFullSaturday` | السبت | Saturday | DayStrip |
| `dayFullSunday` | الأحد | Sunday | DayStrip |
| `dayFullMonday` | الاثنين | Monday | DayStrip |
| `dayFullTuesday` | الثلاثاء | Tuesday | DayStrip |
| `dayFullWednesday` | الأربعاء | Wednesday | DayStrip |
| `dayFullThursday` | الخميس | Thursday | DayStrip |
| `dayFullFriday` | الجمعة | Friday | DayStrip |
| `buttonDisabledSuffix` | ، غير متاح | , unavailable | SprintButton |
| `buttonBusy` | جاري التنفيذ… | Working… | SprintButton |
| `fieldShowPassword` | إظهار | Show | SprintTextField |
| `fieldHidePassword` | إخفاء | Hide | SprintTextField |
| `fieldSearchHint` | البحث | Search | SprintTextField |
| `slotAvailablePlaces` | {count, plural, =1{مكان واحد} =2{مكانين} other{{count} أماكن}} | {count, plural, =1{1 place} other{{count} places}} | SlotChip |
| `slotSelected` | مختار | Selected | SlotChip |
| `slotFewLeft` | {count, plural, =1{فاضل 1} =2{فاضل مكانين} other{فاضل {count}}} | {count, plural, =1{1 place left} other{{count} places left}} | SlotChip |
| `slotFewLeftSpoken` | {count, plural, =1{فاضل مكان واحد} =2{فاضل مكانين} other{فاضل {count} أماكن}} | {count, plural, =1{one place left} other{{count} places left}} | SlotChip |
| `slotFull` | مكتمل | Full | SlotChip |
| `slotPast` | فات | Past | SlotChip |
| `slotSpoken` | الساعة {time}، {state} | At {time}, {state} | SlotChip |
| `slotSpokenWithPrice` | الساعة {time}، {state}، {price} | At {time}, {state}, {price} | SlotChip |
| `dayToday` | النهارده | Today | DayStrip |
| `dayHasRoom` | فيه أماكن | Places available | DayStrip |
| `dayClosed` | مقفول | Closed | DayStrip |
| `daySpoken` | يوم {day}، {state} | Day {day}, {state} | DayStrip |
| `statusSpoken` | الحالة: {status} | Status: {status} | StatusBadge |
| `statusConfirmed` | مؤكد | Confirmed | StatusBadge |
| `statusPendingPayment` | في انتظار الدفع | Awaiting payment | StatusBadge |
| `statusCancelled` | اتلغى | Cancelled | StatusBadge |
| `statusAttended` | حضر | Attended | StatusBadge |
| `statusNoShow` | غاب | No-show | StatusBadge |
| `statusExpired` | انتهت المهلة | Expired | StatusBadge |
| `statusUnderReview` | قيد المراجعة | Under review | StatusBadge |
| `statusVerified` | موثّق | Verified | StatusBadge |
| `statusRejected` | مرفوض | Rejected | StatusBadge |
| `statusOpen` | مفتوح | Open | StatusBadge |
| `statusInProgress` | جاري | In progress | StatusBadge |
| `statusResolved` | اتحل | Resolved | StatusBadge |
| `facilityPhotoPlaceholder` | صورة المنشأة | Facility photo | FacilityCard |
| `facilityTrainerTag` | بمدرب | With trainer | FacilityCard |
| `facilityFreeTag` | مجاني | Free | FacilityCard |
| `facilityUnitCount` | {count, plural, =1{وحدة واحدة} =2{وحدتين} other{{count} وحدات}} | {count, plural, =1{1 unit} other{{count} units}} | FacilityCard |
| `facilityAvailabilityPlenty` | متاح النهارده | Available today | FacilityCard |
| `facilityAvailabilityFew` | أماكن قليلة | Few places left | FacilityCard |
| `facilityAvailabilityNone` | مفيش مواعيد النهارده | No slots today | FacilityCard |
| `facilityPriceInternalLabel` | سعر الطلاب والعاملين | Student and staff price | FacilityCard |
| `facilityPriceExternalLabel` | السعر الكامل | Full price | FacilityCard |
| `facilityFree` | مجاني | Free | FacilityCard |
| `facilitySpoken` | منشأة {name}، {unit}، {availability}، {price} | Facility {name}, {unit}, {availability}, {price} | FacilityCard |
| `ticketCodeLabel` | كود الحجز | Booking code | BookingTicket |
| `ticketCopied` | اتنسخ | Copied | BookingTicket |
| `ticketPaid` | المدفوع | Paid | BookingTicket |
| `ticketCancelUntil` | إلغاء مجاني لحد {date} | Free cancellation until {date} | BookingTicket |
| `ticketCancelUnavailable` | الإلغاء مش متاح | Cancellation unavailable | BookingTicket |
| `ticketQrUnavailable` | QR غير متاح | QR unavailable | BookingTicket |
| `ticketSpoken` | تذكرة {facility}، {dateTime}، {status}، {code} | Ticket {facility}, {dateTime}, {status}, {code} | BookingTicket |
| `navMore` | المزيد | More | AppNavigation |
| `navBadgeSpoken` | {count, plural, =1{غير مقروء واحد} other{{count} غير مقروء}} | {count, plural, =1{1 unread} other{{count} unread}} | AppNavigation |
| `statDeltaUp` | زيادة {value} | Up {value} | StatTile |
| `statDeltaDown` | نقص {value} | Down {value} | StatTile |
| `statDeltaFlat` | مفيش تغيير | No change | StatTile |
| `statNoComparison` | مفيش مقارنة | No comparison | StatTile |
| `logoLabel` | سبرنت | Sprint | SprintLogo |
| `galleryTitle` | معرض المكونات | Component gallery | Component gallery (reviewers only) |
| `gallerySampleNote` | بيانات تجريبية | Sample data | Component gallery (reviewers only) |
| `galleryTextSize` | حجم النص | Text size | Component gallery (reviewers only) |
| `galleryReducedMotion` | تقليل الحركة | Reduced motion | Component gallery (reviewers only) |
| `galleryPlatformLook` | شكل المنصة | Platform look | Component gallery (reviewers only) |
| `galleryPlatformApple` | آبل | Apple | Component gallery (reviewers only) |
| `galleryPlatformAndroid` | أندرويد | Android | Component gallery (reviewers only) |
| `galleryPlatformDesktop` | ديسكتوب | Desktop | Component gallery (reviewers only) |
| `galleryOpenFromDemo` | معرض المكونات | Component gallery | Component gallery (reviewers only) |
| `galleryButtonSection` | الأزرار | Buttons | Component gallery (reviewers only) |
| `galleryTextFieldSection` | حقول الإدخال | Text fields | Component gallery (reviewers only) |
| `gallerySlotChipSection` | مواعيد الحجز | Slot chips | Component gallery (reviewers only) |
| `galleryDayStripSection` | شريط الأيام | Day strip | Component gallery (reviewers only) |
| `galleryStatusBadgeSection` | شارات الحالة | Status badges | Component gallery (reviewers only) |
| `galleryFacilityCardSection` | كروت المنشآت | Facility cards | Component gallery (reviewers only) |
| `galleryBookingTicketSection` | تذاكر الحجز | Booking tickets | Component gallery (reviewers only) |
| `galleryNavigationSection` | التنقل | Navigation | Component gallery (reviewers only) |
| `galleryStatTileSection` | المؤشرات | Stat tiles | Component gallery (reviewers only) |
| `galleryLogoSection` | اللوجو | Logo | Component gallery (reviewers only) |
| `timeAm` | صباحًا | AM | Shared |
| `timePm` | مساءً | PM | Shared |
| `slotAvailableWord` | متاح | Available | SlotChip |

Notes for review: `slotFewLeft` for 2 reads "فاضل مكانين" (dual) and the spoken form adds "مكان"; `facilityPriceInternalLabel` is "سعر الطلاب والعاملين" per the component README; the gallery's stat sample labels are inline reviewer-only sample content, not production copy.
