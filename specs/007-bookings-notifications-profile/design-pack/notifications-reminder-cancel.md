# Notifications · reminder with cancel
Covers: US-13, US-14, FR-NTF-02, BR-39, BR-30
Node: Compact Light 256:6743, Dark 256:6982 (screenshots not taken, limit)
## Layout
### Compact
Same as notifications.md, but the first card (reminder, unread) is taller (hug, not 110) and carries an action row under the body:
- Card: `surface`, radius `radius-lg`, padding `space-4`, gap `space-3`, column.
- Text column gap `space-1`: time + title row, body, then actions row (gap `space-2`).
- Actions: Button secondary "عرض التذكرة" (120 x 48, 1px `control-border`, `surface` fill, `button` in `ink`) and ghost Button "إلغاء الحجز" (120 x 48, `button` in `primary`). Not the danger variant: the cancel here only opens the cancel flow (the confirm dialog carries the danger action).
- Other cards unchanged (110 high).
## Text
- Title "تذكير بحجزك" `headline`; time "4:00 م" `caption` `ink-muted`.
- Body (`body`, `ink-muted`): "حمام السباحة الأوليمبي النهارده 5:00 م · الإلغاء متاح لحد 3:00 م". Figma annotation: example only, the day/time are computed from booking start minus `cancellationCutoffHours` (BR-30).
## States
- This is the variant while cancellation is still allowed. After the cutoff the card is the plain 110-high card with "الإلغاء مش متاح دلوقتي" and no actions (notifications.md card 1).
## Dark theme
Not read beyond the node id.
## Not in Figma
- "إلغاء الحجز" must go through AdaptiveDialog (booking-details cancel dialog) and the refund rule (BR-31); not drawn here.
- Actions row on Medium+ not read.
