# Booking details · pending payment

Covers: US-13, US-14, FR-MYB-02, FR-PAY-04, BR-17 (hold rules BR-12, BR-46 live in feature 6)
Node: Compact Light `263:7041` · Compact Dark `263:7372` · Medium Light `265:14797` · Medium Dark `265:15141` · Expanded Light `265:31397` · Expanded Dark `265:31750` · Large Light `265:31827` · Large Dark `265:32180`
Section: "Pending, guest account, search · Compact".
Read status: Compact Light and Medium Light design context only (screenshot NOT downloaded: limit hit). Dark, Expanded, Large NOT read.

## Layout (Compact)
Same shell as `booking-details-upcoming.md`. Differences:
- Content, first child: **Banner tone=hold** (see `components-banner.md`), full width, 72 high.
- Card: facility "ملعب كرة القدم الرئيسي", sub-line "الملعب كله · لحد 22 لاعب", StatusBadge `pending-payment` (bg `warning-soft`, text `warning`, hourglass icon, word "في انتظار الدفع"), When strip `volt` "التلات 10 نوفمبر · 8:00 – 9:00 م", **no QR**, code "SP-1038", tier "داخلي", amount row label "المطلوب" value "80 ج.م".
- After the card, inside Content: a ghost button "إلغاء الحجز" (48 high, no fill, `button` text in `primary`).
- Action bar: one primary SprintButton "إكمال الدفع · 80 ج.م" (`primary`, `on-primary`, price in the label).
## Medium
Rail + Main as in upcoming. Banner and card inside the 520 column; ghost cancel inside the content, the primary "إكمال الدفع · 80 ج.م" 520 wide below it (no action bar).

## Text
Banner title "المكان متحجز لك" (`label` 14/20 600, `warning`), sub "فاضل 6 دقايق للدفع، وبعدها المكان يرجع متاح" (`caption`, `warning`). Both centred vertically with a 24 hourglass icon at the start.

## States
- Verified: amount is 80 ج.م, label "المطلوب" (not the paid word).
- Countdown "6 دقايق" is an example: computed from the hold expiry (`holdMinutes`/BR-12, turns `danger` in the last minute, BR-12; extension to `holdMaxMinutes` BR-46). Not static.
- Medium cancel dialog read in round 2 (277:35540): hold Banner icon hourglass 24, ghost "إلغاء الحجز" 48 in the content, primary "إكمال الدفع · 80 ج.م" 520 wide; dialog as in booking-details-cancel-dialog.md.
- Cancel dialog for this state: `booking-details-cancel-dialog.md` (pending variant).

## Dark theme
Not read.

## Not in Figma
- Tapping the primary resumes feature-6 checkout for the same booking; if the hold already ended the screen becomes the expired state.
- Banner is a live region; the minutes figure should not be announced every second.
- Existing code to reuse: `lib/features/booking/presentation/checkout/hold_banner.dart` (check it against the Banner spec before duplicating).
