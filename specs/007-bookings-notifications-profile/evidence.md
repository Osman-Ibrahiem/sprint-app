# Evidence: feature 007

What was run, on which commit, and what it showed. Updated after each stage; the
final section covers T080, T084 and T085.

## Baseline (T001, 2026-11-18)

- Branch `claude/007-bookings-notifications-profile-7c3ba5`, before any change.
- `flutter pub get`: OK.
- `dart run build_runner build --delete-conflicting-outputs`: OK, 105 outputs.
- `flutter analyze`: **No issues found** (30.8 s).
- `flutter test`: **2003 tests passed** (2 min 51 s).

The worktrees branch and the worktree folder (`007-bookings-notifications-profile-7c3ba5`)
match the spec directory (`007-bookings-notifications-profile`).

## Review of OpenCode work (T001 to T027, 2026-11-18)

Checked: git log against the boxes (T001 to T003 were done but unchecked; fixed),
`build_runner` (OK), `flutter analyze` (no issues), full `flutter test`
(2074 passed, 2 failed before the fix below).

- Spot-checked against `contracts/repositories.md` and `data-model.md`:
  `CancelPreview` and `CancellationPolicy.preview` (full, partial, none, free,
  closed, notAllowed; facility cancel always full; BR-48 pending cancel only
  while holding and with no payment pending), `ReminderPolicy.due`,
  `NotificationKind`, notification `changes` and `markAllRead`, receipt
  relaxation, housekeeping `markNoShows`. They match the task text.
- **Fixed**: `holdHousekeeping` (T016) could leave a stray 74-hour timer when
  two `arm()` calls overlapped (the first timer was never cancelled), which
  failed `checkout_screen_awaiting_test` and `checkout_screen_expiry_test`.
  The cancel now happens after the await. All of `test/features/booking` passes.

## Final run (2026-11-19, T084)

- `flutter analyze`: no issues. `flutter test`: **2274 passed**. `flutter build web --release --base-href /sprint-app/`: built.
- T001 to T080 and T084 done. Not done: T081 to T083, T086, T087 (for Claude with Osman) and **T085** (the quickstart walk on web and the iOS simulator, with screenshots and SC-001 to SC-009): not run, so SC-001 to SC-009 are covered by tests only.
- Decisions to confirm: the notifications destination is always a route (the shell hides it from guests and from the compact tab bar) so signing in never rebuilds the router; the Facilities list got a "كل المنشآت" title; Home and Facilities suggestions show inline under the field (not a popover) from the medium class; the account card shows masked phone and email (as before) instead of the full email.
- The pack's "not read" frames (all Dark, Expanded and Large of several screens) were implemented from the Compact and Medium rules and the spec; design QA (T086) must compare them.

## Quickstart walk (T085, partial, 2026-11-19)

Web release build served locally, 390 wide, Arabic, dark (system), driven through the browser pane.

- **Seen working**: guest on `/notifications` is sent to `/sign-in?from=/notifications`; as the demo booker "حجوزاتي" shows "الجاية (6)" with the bell badge (3), rows with status words and the today chip, and the tab bar with four items; the notifications centre shows reminder, confirmed, facility cancel, refund, verification and self-cancel records with unread dots and "تعليم الكل كمقروء".
- **Bug found and fixed**: the permission dialog (Apple-style alert on web) drew Arabic as boxes because the Cupertino alert used its own font. Fixed by setting the Cairo styles explicitly in `showSprintDialog` (commit "fix(adaptive): Cairo text in the Cupertino dialog"); the rebuilt page was not re-checked by eye.
- **Not walked**: desktop 1440, English, light theme, details and cancel on the page, pending payment, `/demo` reminder and facility cancel, account and edit profile, search, resize and fold, keyboard-only, iOS simulator. The browser session lost the demo user on reload, so these are covered by the widget and acceptance tests only. No screenshots were saved to the repo.

## Reminders follow-up (T063, T064, T068)

- Card: the reminder body now carries the lead in words from `reminderLeadMinutes` (`notifReminderBodyLead` with `leadTimeText`), and the screen re-reads the clock every `detailsRefreshPeriod` so the cancel action disappears when the cutoff passes.
- `test/features/notifications/presentation/reminder_card_test.dart` (moving clock: cancel before the cutoff opens the dialog; after it the action goes, a line shows and the card opens the booking; cancelled booking keeps the card without the action; lead words follow the setting; one record however often the checker runs) and `test/acceptance/us13_reminder_test.dart` (scenarios 1, 2, 4, 5; scenario 3 is in the card test).
- Test note: a repository write made inside `runAsync` reaches the card only after the details are re-read, so the cancelled-booking test invalidates and reads them explicitly.

## Code review findings (10), 2026-11-19

1. **Fixed**: edit-profile name check counts runes; test with an emoji.
2. **Fixed**: `?q=` read at start, written with replace, kept on `/facilities/<id>?q=`; test in `us01_search_test.dart`. Demo reset clears the device recents but does not refresh the live recents list until the next restart.
3. **Fixed**: the reminder sentence gives the real start time ("بيبدأ الساعة …" or date and time), not the lead setting; tests updated. `us13_reminder_test` scenario 5 assumes the seeded reminder booking starts today (Cairo), so it could flake in the last hour before Cairo midnight.
4. **Fixed**: `bookedCounts(since, until)`; the suggestions pass the injected clock as `until`; the seed got two more past pool bookings so "most booked" stays strict; test for a future booking.
5. **Fixed**: `recentSearchesProvider` notifier; test for add and clear.
6. **Fixed**: the clock tick invalidates only the details of displayed reminders. No dedicated test (behaviour is "fewer rebuilds").
7. **Fixed**: the last tab is remembered in `initState` and `didUpdateWidget`, home is the default; test for a direct `/notifications` load.
8. **Fixed**: one `_MarkAllButton` (ghost, one key) in both headers.
9. **Fixed**: details use `PaymentRepository.latestPayment`.
10. **Fixed**: `PhotoSource`, `PhotoSourcePicker` and `photoSourceProvider` live in `lib/core/adaptive/photo_source.dart`. `lib/features/account/` still imports `VerificationSlot` and `VerificationNotice` from feature 3 (the verification area is reused on purpose); only the picker types were decoupled.

## Design QA 2026-11-19

Fixed (one commit each, with tests): **H1** disabled `SprintButton` in every variant (surface-sunken fill, ink-disabled text; loading unchanged); **H2** `ContentColumn` with `SprintExtras` constants (notifications 800, account 560, edit profile 440) from the expanded class; **H3** BookingRow: date at the start, badge at the end (kept at the end when wrapped), README updated; **M3** one status badge on past tickets; **M4** "المسترد" row, "الفلوس بترجع على نفس وسيلة الدفع" line and banners without a final dot; **M5** facility cancel is a success banner with reason and full refund, no "informed" phrase; **M6** verification titles as designed (the approved one, "تمت الموافقة", is MSA wording, as in the design); **M7** edit details title "البيانات الشخصية", name-phone-email, avatar beside the photo buttons; **M9** no label above the search field, placeholder "البحث عن منشأة أو رياضة"; **M10** mark-all measured at 48; **small** no lone "م" (no-break space before the last word).

Deferred to the Figma refactor (not touched): M1 (tab bar in details), M2 (details structure), M8 (account), the compact search popover (M9 part).

Known unrelated flake: two tests in `booking_routes_test.dart` fail after about 18:00 real time because they book "today at 18:00"; they also fail on the commit before these fixes.

## Not tested yet

Everything below this line is filled in by the stage that ran it: Phase 1–2,
Phase 3, US1–US10, the copy review and the web build/walk.

## Walk of the web build, 2026-11-19 (T085, Claude, in-app browser)

Build: `flutter build web --release --base-href /sprint-app/` served by `tool/serve_web.mjs` on port 8093 (a stray server from 2026-11-15 owns port 8081 and serves an old build; ignore it). Verified by me: `flutter analyze` no issues; `flutter test` 2283 passed.

**Walked (dark, 1024 wide = expanded rail layout, Arabic):**
- Demo switcher to the booker, then "حجوزاتي": master-detail with the first booking selected, four rail items plus "الإشعارات" with badge 3, "الجاية (6)", status chips, "عرض التذكرة", booking within the cutoff shows "الإلغاء مش متاح"; a later booking shows the cancel button and "الإلغاء متاح لحد الأحد 22 نوفمبر 6:00 ص".
- Cancel: dialog "إلغاء الحجز؟ هترجع 20 ج.م كاملة على نفس وسيلة الدفع."; confirming opens `/bookings/bk-19/cancelled` with "الحجز اتلغى. الـ 20 ج.م هترجع على نفس وسيلة الدفع." and "العودة للحجوزات"; the badge stayed 3 (the self-cancel record is already read).
- Notifications: simulated permission dialog "تفعيل الإشعارات؟" appeared once on the first visit; centre lists the self-cancel, reminder, confirmed, facility cancel, refund and verification records with unread dots; "تعليم الكل كمقروء" at the inline end.
- Account: card with masked phone and email, verification card, rows (البيانات الشخصية, اللغة, المظهر, الإشعارات "مفعّلة", شاشة العرض للمراجعين, تسجيل الخروج); Edit profile with name editable and email and phone locked with the helper line.
- Facilities: search field with "إلغاء" and the suggestions popover "الأكتر حجزًا" (two facilities).
- Compact 375 wide, light: four tabs, bell with badge 3 in the header, list with "الجاية (5)" after the cancel.

**Findings (status after the fixes):**
1. **Fixed**: `VerificationSlot` has `showNationalId` (default true for the old account card and review screens); `AccountScreen` passes false; test `account_screen_test.dart`. Original: account's verification card shows the masked national ID ("الرقم القومي: 0011*********") from feature 3's `VerificationSlot`; spec FR-023 and SC-008 say no national ID on the account screen (NFR-06 allows masked elsewhere). Decision needed: hide it here, or relax FR-023 to "never unmasked".
2. **Fixed (defensive)**: heading on an opaque `bg` above a `ClipRect`ed scroll area; the widget test (`details_pane_scroll_test.dart`) already passed before the change, so the overlap could not be reproduced in tests, only seen on the web build; re-check by eye. Original: in the wide details pane the "تفاصيل الحجز" title is drawn over the scrolled content (not clipped).
3. **Fixed**: `WideDialog` used `maxWidth: 400`, so it hugged its text; it is now exactly 400 (tests at 720 and 1024). Original: the cancel dialog measures about 320 css px wide where `WideDialog` is specified at 400.
4. The facility master-detail placeholder "اختار منشأة تشوف تفاصيلها" is an imperative (feature 4, left for the Figma refactor).

**Not walked:** typing in the search field (the browser tool's key events do not reach the Flutter text input; covered by `test/acceptance/us01_search_test.dart`), English, desktop 1440, light on wide, sign out, language and appearance popovers, resize and fold, keyboard-only, iOS simulator, `/demo` reminder and facility-cancel actions, pending-payment cancel, no screenshots saved to the repo (the tool returns images only).

## Final checks, 2026-11-19 (Claude)

- `flutter analyze`: no issues. `flutter test`: 2323 passed. `flutter build web --release --base-href /sprint-app/`: built. Two route tests had a fixed day (2026-11-19, 18:00) and failed once the real clock passed it; they now pick a day relative to the clock (`adf27b7`).
- Design QA against Figma by the design session (report: `design-qa.md`, commit `4d53b57`): flow, bell and badge, master-detail and Dark match; fixes for H1, H2, M3, M4, M5, M6, M7, M9, M10 and H3 are committed (see the "Design QA" section above); M1 (tab bar in details), M2 (details structure), M8 (account layout) and the Compact search popover are deferred to the Figma refactor of features 001–007.
- Final spot check of the web build (dark, 1024 wide): guest "حجوزاتي" shows the sign-in and sign-up card with no stale text; booker list and details are as before, the details title no longer overlaps scrolled content, the booking row now has the date at the start and the badge at the end. Open nit: in the 300 px list column of the medium class, the "النهارده · 10:16 – 11:16 م" pill wraps to three lines next to the badge (Figma keeps one line); left for the refactor.
- Not walked by eye (covered by tests): English, desktop 1440 light, sign out, the language and appearance popovers, `/demo` reminder and facility-cancel actions, pending-payment cancel, search typing, keyboard-only, iOS simulator.
- The design pack (`design-pack/`) was deleted in this PR as required (CI fails while it exists).
