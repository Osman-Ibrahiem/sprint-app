# Booking details · after cutoff

Covers: US-13, FR-MYB-02, BR-30, BR-40, BR-17
Node: Compact Light `120:3445` · Compact Dark `120:3902`. No Medium/Expanded/Large frame exists.
Section: "Booking states". Read status: Compact Light design context only (no screenshot). Dark NOT read.

## Layout (Compact)
Same card as `booking-details-upcoming.md` (confirmed badge, volt When strip, QR 160, SP-1042, "داخلي", "المدفوع" "80 ج.م"), differences:
- **No action bar** and no cancel button (BR-30: button disappears).
- Note banner after the card (hand-built frame, `primary-soft`, `on-primary-soft` text `body`, radius `radius-md`, padding `space-3`, clock icon 20 at the end): "الإلغاء كان متاح لحد الأحد 3:00 م، وبعده زرار الإلغاء بيختفي."

## Not in Figma / example data
- The Figma annotation says this sentence is an EXAMPLE, not fixed text: the day and hour are computed as booking start minus `cancellationCutoffHours` (BR-30; default 2, so Sunday 5:00 م start gives 3:00 م). Use an l10n string with a formatted date/time placeholder.
- Wording is past tense ("كان متاح") even if the cutoff is still in the future when the screen shows it: Figma shows only the after-cutoff state; the before-cutoff upcoming state has no note.
- BR-40: the reminder notification shows its cancel action only before the cutoff (notifications pack).
