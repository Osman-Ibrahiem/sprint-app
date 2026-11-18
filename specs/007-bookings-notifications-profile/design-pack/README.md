# Design Pack: feature 007 (حجوزاتي، تفاصيل الحجز والإلغاء، الإشعارات، الحساب، البحث)

**Delete this folder before merging to develop.**

- Generated: 2026-11-18, after the design session's edits of the same day (Figma file `xeuMQ0KyXsXVh4QldmkbDf`). The Figma tools returned no last-modified value. If Figma changes after this date, re-run `/design-check 007`.
- Covers: US-13, US-14, US-01 (search), FR-MYB-02, FR-MYB-03, FR-NTF-01, FR-NTF-02, FR-PAY-04, BR-30, BR-31, BR-32, BR-40, BR-41, BR-17. Search is not in the BRD yet (FR-CAT-05 is added by this feature).
- Figma pages: Compact (5:18, sections "Booking states", "Cancellation & refund states · Compact", "States & permissions · Compact", "Pending, guest account, search · Compact", "Motion states", "Bookings & status · Compact", "Booker extras · Compact"), Medium (5:19), Expanded & Large (5:20).
- Screen files are named after the screen. `components-*.md` document the new components: BookingRow, SegmentedControl, WideDialog, Banner, NotificationBell, NotificationCard, SettingsRow, Avatar, Popover. `app-navigation.md` holds the navigation change.

## Decisions already taken (Osman, 2026-11-18)
- Booker Compact: 4 tabs (الرئيسية، المنشآت، حجوزاتي، حسابي) and a `NotificationBell` with an unread badge in the header of the four root screens. Medium and up: notifications is a rail/sidebar destination with the badge, no bell. Guest: neither.
- Cancel dialog text has four cases: full, partial, none, free. Amounts and dates in Figma are examples; the code computes them from `cancellationCutoffHours`, `refundPercent`, `reminderLeadMinutes`. Admin cancel: always full refund (BR-32).
- Pending-payment cancel: short dialog, no refund.
- Pending payment shows the frozen tier price (80 ج.م); expired shows "المبلغ" with "ما اتدفعش"; tier row says "داخلي" or "خارجي" only. Booking codes are `SP-xxxx`.
- Edit profile: name and photo editable; email and phone shown locked with a hint line.
- Search: name, type and owning unit; ordering by places available today; recents kept on the device.

## Not read from Figma (the MCP call limit ran out twice). Implementers must not guess these
- Search (round 2, 2026-11-18, Light only): read Compact empty/typing/results/no-results, Medium suggestions/empty-field/no-results; screenshots of Expanded suggestions/results/no-results, Large suggestions/results, Home and Facilities at Medium and Expanded. Still not read: all Dark except the older Compact/Medium screenshots (Medium Dark empty-field `287:44952`, no-results `282:40711`, results `265:15195`), Expanded and Large Dark, Large no-results `282:41093`, Expanded and Large empty-field `287:45239 287:45353`, Large Home, guest Home, and design-context numbers for Expanded/Large frames.
- Bookings: design context of past Medium Light `253:13093` (screenshot only); the component sets `278:35408` and `278:35421`.
- Booking details: all Dark; all Expanded and Large; at Medium only upcoming, pending and the full-refund dialog were read.
- Notifications and account (round 2 read Light only): read Home booker Compact `14:2`, Account loading `256:6496`, Notifications Compact `18:410`, Edit profile Compact `247:5742`, sign-out dialog `247:5937`, Medium Account `243:11423`, Edit profile `249:11726`, Account guest `265:14919`, appearance popover `266:7515`, Home booker `243:10530`, Home guest `243:10648`, Expanded Notifications `243:24641`, Account `243:24785`, Account guest `265:31522`, Edit profile `249:25050`, Home booker `243:23868`; Large screenshots only for Notifications, Account, Edit profile. Still not read: all Dark; Compact Home guest/not verified/loading, Compact Account `18:499` itself; Medium and Expanded Notifications refresh, Large Home, Large guest frames, all Home not verified wide frames, Expanded and Large popovers and dialogs.
- Screenshots are missing for most frames (see `images/`).

Where a file says "not read", follow the Compact and Medium rules and the spec, and ask Osman to re-run `/design-check 007` for the missing nodes before design QA.

## Round 2 update (2026-11-18)
Figma was edited again. Updated from the new nodes: my-bookings.md, my-bookings-past.md (no-show and cancelled selected), my-bookings-empty.md (three empty states, all window classes exist, Compact and Medium read), booking-details-attended/no-show/expired.md (Medium added), booking-details-upcoming.md (Expanded), booking-details-cancel-dialog.md (Medium partial, no refund, pending), booking-cancelled.md (full refund re-read; the other four cases not re-read), components-banner.md (five tones), components-booking-row.md, components-segmented-control.md. Not re-read in round 2 (still round-1 text, may be stale): all Dark frames, Large and Expanded except the ones named above, Medium free cancel dialog, booking-cancelled partial / no refund / free / by admin, search and account packs. Each file states its own read depth.
