# Push · reminder
Covers: US-13, FR-NTF-01, BR-39
Node: Compact Light 247:6010, Dark 247:6419 (screenshot of Dark not taken, limit)
Screenshot: images/push-reminder-compact-light.png
## Layout
Lock-screen mock, 390 x 844, background `primary` (Dark: not read). Not an app screen: it documents the push payload.
- Date "الأحد 8 نوفمبر": `headline`, `on-primary`, centred, y=96. Time "9:41": `display` (32/44, 700), `on-primary`, centred, y=126.
- Notification card at y=300, x=16, width 358, `surface`, radius `radius-xl`:
  - Top (padding x `space-4`, y 14, gap `space-3`): text column (gap `space-1`) + SprintLogo tile-primary 40 at the end.
  - Divider 1px `line`, then actions row (padding x `space-4`, y `space-3`): "عرض التذكرة" in `primary`, "إلغاء الحجز" in `danger`, both `button`.
## Text
- App/time line "سبرنت · دلوقتي": `caption`, `ink-muted`.
- Title "فاضل 3 ساعات على ميعادك": `headline`, `ink`. Annotation: duration is written from `reminderLeadMinutes` (default 180, BR-39).
- Body "حمام السباحة الأوليمبي · الأحد 5:00 م. الإلغاء متاح لحد 3:00 م": `body`, `ink-muted`. Annotation: computed from start minus `cancellationCutoffHours` (BR-30).
- Booking code "SP-1051": `code` style (17/24, 500, letterSpacing 0.08em = 1.36px), `ink-muted`, LTR isolate.
## States
One state. Variant "booking confirmed" exists (247:5998), not read.
## Dark theme
Not read.
## Not in Figma
- Push is rendered by the OS, so only title/body/actions copy and deep links matter. Deep link: ticket for the booking; "إلغاء الحجز" opens the cancel flow after sign-in check.
- Notification permission is requested by the sheet/dialog in permission-notifications.md.
