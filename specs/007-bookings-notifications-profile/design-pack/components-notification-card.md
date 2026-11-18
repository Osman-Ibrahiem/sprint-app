# NotificationCard
Node: 278:35452 (unread default 278:35440)
Covers: FR-NTF-02, BR-39, BR-41, BR-32
- `surface`, radius `radius-lg`, padding `space-4`, gap `space-3`, height 110 (fixed in Figma, grows when it has actions), full width.
- Text column (gap `space-1`): top row (time `caption` `ink-muted` at the far side, unread dot 8 + title `headline` `ink`), body `body` `ink-muted`.
- Leading icon tile: 40 circle, icon 20, tint by kind: reminder `warning-soft` + hourglass, confirmed `success-soft` + check-circle, admin cancellation `danger-soft` + x-circle, verification `primary-soft` + shield-check, offer `volt` + tag.
- unread=true shows the primary dot; read has no dot.
- Reminder copy from `reminderLeadMinutes` (BR-39). Admin cancellation card states the reason and the 100% refund (BR-32, BR-41).
- Variant with actions ("عرض التذكرة" secondary + "إلغاء الحجز" ghost) in notifications-reminder-cancel.md. Time is 12-hour ("4:00 م").
- Round 3: variants by content only (kind: reminder, confirmed, admin cancellation, verification x3, offer); `unread` true/false is the only state prop (dot 8 before the title). In the verification frame: rejected (unread, `danger-soft`, x-circle), under review (unread, `warning-soft`, clock), approved (read, `success-soft`, check-circle). Layout identical for all kinds: card 110 high (hug when taller), no per-kind structure. Title `headline` 17/26, body `body` 15/24, time `caption` 13/20.
- Tap destinations (annotations): reminder after cutoff -> booking details; verification rejected -> verification request (reason shown); under review -> verification request status; approved -> Account. Others: related booking (not annotated). See notifications-verification.md.
- Not in Figma: pressed/hover states, swipe to dismiss, tap target to the related booking.
