# NotificationCard
Node: 278:35452 (unread default 278:35440)
Covers: FR-NTF-02, BR-39, BR-41, BR-32
- `surface`, radius `radius-lg`, padding `space-4`, gap `space-3`, height 110 (fixed in Figma, grows when it has actions), full width.
- Text column (gap `space-1`): top row (time `caption` `ink-muted` at the far side, unread dot 8 + title `headline` `ink`), body `body` `ink-muted`.
- Leading icon tile: 40 circle, icon 20, tint by kind: reminder `warning-soft` + hourglass, confirmed `success-soft` + check-circle, admin cancellation `danger-soft` + x-circle, verification `primary-soft` + shield-check, offer `volt` + tag.
- unread=true shows the primary dot; read has no dot.
- Reminder copy from `reminderLeadMinutes` (BR-39). Admin cancellation card states the reason and the 100% refund (BR-32, BR-41).
- Variant with actions ("عرض التذكرة" secondary + "إلغاء الحجز" ghost) in notifications-reminder-cancel.md. Time is 12-hour ("4:00 م").
- Not in Figma: pressed/hover states, swipe to dismiss, tap target to the related booking.
