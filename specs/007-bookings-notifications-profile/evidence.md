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

**Findings (open):**
1. Account's verification card shows the masked national ID ("الرقم القومي: 0011*********") from feature 3's `VerificationSlot`; spec FR-023 and SC-008 say no national ID on the account screen (NFR-06 allows masked elsewhere). Decision needed: hide it here, or relax FR-023 to "never unmasked".
2. In the wide details pane the "تفاصيل الحجز" title is drawn over the scrolled content (not clipped).
3. The cancel dialog measures about 320 css px wide where `WideDialog` is specified at 400.
4. The facility master-detail placeholder "اختار منشأة تشوف تفاصيلها" is an imperative (feature 4, left for the Figma refactor).

**Not walked:** typing in the search field (the browser tool's key events do not reach the Flutter text input; covered by `test/acceptance/us01_search_test.dart`), English, desktop 1440, light on wide, sign out, language and appearance popovers, resize and fold, keyboard-only, iOS simulator, `/demo` reminder and facility-cancel actions, pending-payment cancel, no screenshots saved to the repo (the tool returns images only).
