# Booking cancelled (full, partial, no refund, free, by admin)

Covers: US-13, US-14, FR-MYB-02, FR-PAY-04, BR-31, BR-32, BR-17
Read status: round 1 Compact Light design context for all five; round 2: full refund `120:3494` re-read (design context + screenshot `images/booking-cancelled-full-refund-compact-light.png`); partial, no refund, free, by admin were NOT re-read, so the banner texts and rows below for those four are round-1 values and may be stale (they should now also have the "الفلوس بترجع على نفس وسيلة الدفع." line if the refund applies: NOT verified). Dark NOT read. No Medium/Expanded/Large frame exists for these in the file.

## Nodes
| Case | Compact Light | Compact Dark | Section |
| --- | --- | --- | --- |
| Full refund | `120:3494` | `120:3931` | Booking states |
| Partial refund | `276:7540` | `276:7569` | Cancellation & refund states · Compact |
| No refund | `276:7598` | `276:7627` | same |
| Free | `276:7656` | `276:7685` | same |
| By admin | `276:7714` | `276:7743` | same |

## Layout (Compact)
Same shell as `booking-details-upcoming.md`. Content column starts with a note banner, then the card; action bar below.
- Note banner: now a Banner instance (component, see components-banner.md; Figma annotation attached: refund = refundPercent x paid, BR-31; admin 100%, BR-32): height 48 (one line), radius `radius-md`, padding `space-3`, gap `space-2`, text `body` 15/24 fills the width, 20 icon at the end side. Tone per case in the table below.
- NEW (full refund, round 2): below the card, outside it, a line `caption` 13/20 `ink-muted`, start aligned, full width: "الفلوس بترجع على نفس وسيلة الدفع." (Content column gap `space-3`). It replaces the "على نفس وسيلة الدفع" phrase in the banner, which now reads only "الحجز اتلغى والـ 80 ج.م هترجع بالكامل.".
- Card: StatusBadge `cancelled` (bg `danger-soft`, text/icon `danger`, word "اتلغى", x-circle icon 16); no QR; When strip `surface-sunken` with `ink-muted` text (muted, not volt); rows tier "داخلي" then the refund row.
- Action bar: one primary button "الرجوع لحجوزاتي" (`primary`, `on-primary`), full width, 48.

## Per case (exact copy)
| Case | Banner tone | Banner text | Rows after tier |
| --- | --- | --- | --- |
| Full (re-read) | success (`success-soft` bg, `success` text, check-circle) | "الحجز اتلغى والـ 80 ج.م هترجع بالكامل." + caption line below the card "الفلوس بترجع على نفس وسيلة الدفع." | "المسترد" = "80 ج.م" |
| Partial | success | "الحجز اتلغى. هيرجع 40 من 80 ج.م على نفس وسيلة الدفع." | "المسترد" = "40 من 80 ج.م" |
| No refund | info (`surface-sunken` bg, `ink` text, info icon) | "الحجز اتلغى من غير استرداد، ومفيش مبلغ هيرجع." | "المسترد" = "0 ج.م" |
| Free | info | "الحجز اتلغى والمكان رجع متاح لغيرك." | "السعر" = "مجاني" |
| By admin | success | "إدارة المنشأة لغت الحجز. الـ 80 ج.م هترجع بالكامل على نفس وسيلة الدفع." | "السبب" = "لغته إدارة المنشأة"; "المسترد" = "80 ج.م · كامل" |

## Example data the code computes
Figma annotation: the refund amount = `refundPercent` x paid when cancelled before the cutoff (BR-31), and an admin cancel is always 100% (BR-32). 80 / 40 / 0 are examples, not fixed.

## Not in Figma
- When the refund will arrive (no timing line); refund status pending vs done. Do not invent; ask Osman.
- Banner `info` tone is now `primary-soft` and `neutral` is `surface-sunken`: the "No refund" and "Free" rows above were written when `info` meant `surface-sunken`; they are `neutral` now (verified for the free cancelled booking in my-bookings-past.md: neutral, `surface-sunken`, `ink`, info icon). Admin cancellation is probably tone `danger` (`danger-soft`, `danger` text) per the Banner description, NOT re-read.
- Admin cancel for a free booking, partial admin cancel (always 100%).
- Navigation: "الرجوع لحجوزاتي" goes to my-bookings (past or all).
- Dark not read.
