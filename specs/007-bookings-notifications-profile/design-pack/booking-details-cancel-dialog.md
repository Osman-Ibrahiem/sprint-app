# Booking details · cancel dialog (six cases)

Covers: US-13, FR-MYB-02, FR-PAY-04, BR-30, BR-31, BR-32, BR-40
Read status: Compact Light design context for full, partial, no-refund, free, pending. Medium Light design context (round 2) for full, partial `277:33800`, no refund `277:33873` and pending payment `277:35540`. Screenshot only for Compact full refund (`images/booking-details-cancel-dialog-full-refund-compact-light.png`). NOT read: Medium free (`277:33946`), all Dark, all Expanded and Large.

## Nodes
| Case | Compact Light | Compact Dark | Medium L / D | Expanded L / D | Large L / D |
| --- | --- | --- | --- | --- | --- |
| Full refund | `120:3381` | `120:3872` | `123:917` / `124:899` | `127:1252` / `128:961` | `129:1598` / `129:1868` |
| Partial refund | `276:7360` | `276:7390` | `277:33800` / `277:34031` | `277:34364` / `277:34610` | `277:34856` / `277:35102` |
| No refund | `276:7420` | `276:7450` | `277:33873` / `277:34104` | `277:34442` / `277:34688` | `277:34934` / `277:35180` |
| Free | `276:7480` | `276:7510` | `277:33946` / `277:34177` | `277:34520` / `277:34766` | `277:35012` / `277:35258` |
| Pending payment | `276:7772` | `276:7816` | `277:35540` / `277:35588` | `277:35712` / `277:35760` | `277:35808` / `277:35856` |
Sections: full refund "Booking states"; the rest "Cancellation & refund states · Compact". "After cutoff" is not a dialog: see `booking-details-after-cutoff.md`.

## Layout (Compact)
- Background: the upcoming screen (`booking-details-upcoming.md`) for full/partial/none; free has price row "السعر" = "مجاني"; pending has the pending screen behind it (hold Banner, ghost cancel, primary pay bar, dialog top y=355 not 354.5).
- Scrim: full 390 x 844, `scrim`.
- AdaptiveDialog (the platform alert; this is the iOS-style one): 270 wide, centred (left 60, top 354.5), `surface-raised`, radius `radius-lg` (16, not xl), clipped. Column:
  - Text block: padding vertical `space-5`, horizontal `space-4`, gap `space-1`, centred. Title "إلغاء الحجز؟" (`headline`, `ink`), message (`caption`, `ink`, wraps, full width).
  - Actions row: top border 1 `line`; two equal cells 135 x 44 (44, the Apple alert exception in docs/decisions.md 2026-11-11), vertical divider `line` between them. Cell at the physical left: "إلغاء الحجز" (`body-strong`, `danger`); cell at the physical right: "الرجوع" (`body`, `primary`).
- No icon in the dialog.

## Message copy per case (Egyptian dialect, exact)
- Full refund: "هترجع 80 ج.م كاملة على نفس وسيلة الدفع."
- Partial refund: "هيرجع 40 من 80 ج.م على نفس وسيلة الدفع."
- No refund: "الإلغاء دلوقتي من غير استرداد، ومفيش مبلغ هيرجع."
- Free: "الحجز مجاني، فمفيش مبلغ يرجع. المكان هيرجع متاح لغيرك."
- Pending payment: "هنلغي الحجز ومفيش فلوس اتسحبت."
Title and both action labels are identical in all five.

## Medium / Expanded / Large (WideDialog), round 2
Read for Medium partial, no refund and pending payment (full read in round 1). Uses **WideDialog** (see `components-wide-dialog.md`): 400 wide, left 160, top 406 in the 720 x 1000 frame (centred), fill `surface-raised` with 1 `line` border, radius `radius-xl`, padding `space-6`, gap `space-3`, `shadow-popover` (Figma effect list 0 8 24; code view 8/12 at 0.14: use the token). Scrim `scrim` over the whole 720 x 1000. Title "إلغاء الحجز؟" (`title` 20/30, `ink`), message (`body` 15/24, `ink-muted`), Actions row (padding top `space-3`, gap `space-2`) with two 120 x 48 buttons (padding h `space-5`, `radius-md`, `button` text): the danger filled "إلغاء الحجز" (`on-danger`) at the physical LEFT (end in RTL) and the ghost "الرجوع" (`primary` text) at the physical RIGHT (start in RTL). Resolved: this matches Compact (destructive at the physical left); the layer names read "1 · الرجوع (first in RTL reading, start)" and "2 · إلغاء الحجز (destructive, last, end)".
- Messages at Medium are the same strings as Compact (partial: "هيرجع 40 من 80 ج.م على نفس وسيلة الدفع."; no refund: "الإلغاء دلوقتي من غير استرداد، ومفيش مبلغ هيرجع."; pending: "هنلغي الحجز ومفيش فلوس اتسحبت."), in `body` instead of `caption`. The wide dialog frames carry the Figma annotation about computed refund text (BR-31, BR-32).
- Behind the dialog (partial and no refund, Medium): rail 88, detail pane (padding `space-6`, gap `space-5`, heading "تفاصيل الحجز" `title`), list pane 260 wide with a 1px `line` border at the detail side, padding `space-6`, gap `space-4`, title "حجوزاتي" `title-lg`. The detail card: header (StatusBadge "مؤكد" `success-soft`/`success` check-circle, facility `headline`), notes, When chip `volt` ("الأحد 8 نوفمبر · 5:00 – 6:00 م", `on-volt`), QR 140 centred (not 160), code row SP-1042, then the full-width danger button "إلغاء الحجز" 48 high. This card has NO tier or paid rows (differs from the Medium upcoming and from my-bookings.md, where the card has rows and QR 160). The list pane holds three compact list items (not BookingRow): selected item fill `primary-soft`, 2px `primary` border, `radius-md`, padding `space-3`, gap `space-1`, facility `body-strong` + date `caption`, both `on-primary-soft`; other items fill `surface`, 1px `line` border, `ink` / `ink-muted`; copy "النهارده · 5:00 – 6:00 م", "التلات 10 نوفمبر · 8:00 م", "الخميس 12 نوفمبر · 6:00 م". A second list item style; the implementer should use BookingRow as in my-bookings.md (the dialog frames are an approximation) unless Osman confirms.
- Behind the dialog (pending payment, Medium): rail 88 + Main (no list pane): hold Banner 72 high (title "المكان متحجز لك", sub "فاضل 6 دقايق للدفع، وبعدها المكان يرجع متاح", icon hourglass 24), card (badge "في انتظار الدفع", When chip `volt`, SP-1038, "داخلي", "المطلوب" "80 ج.م"), ghost button "إلغاء الحجز" inside the content, primary "إكمال الدفع · 80 ج.م" 520 wide below. Same as booking-details-pending-payment.md.
- Expanded/Large dialog frames and the Medium free case NOT read.

## States
Selection of case is derived, not chosen by the user. Verified fixed items: pending dialog says no money was taken; free says no amount returns.

## Example data the code computes (Figma annotation, all dialogs)
"مثال: نص الاسترداد بيتحسب": full or partial from `refundPercent` (BR-31, here 50% of 80 = 40 as an example), 0% variant, free variant; admin cancel is always 100% (BR-32); pending payment: nothing charged. Amounts 80 / 40 are examples. The cutoff decides which of full/partial/none applies (BR-30).

## Dark theme
Not read.

## Not in Figma
- Android and web alert variants (radius-xl, actions at the end; web Enter confirms, Esc closes) per component description; only the iOS form is drawn for compact.
- Order of actions: resolved in round 2: both compact and Medium put the destructive action at the physical left (end in RTL) and "الرجوع" at the physical right.
- After confirming: go to `booking-cancelled.md` states (refund line from the same case). Cancel call failing/offline is not designed.
- Screen-reader: announce title and message, focus on "الرجوع".
