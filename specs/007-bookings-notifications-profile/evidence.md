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

## Not tested yet

Everything below this line is filled in by the stage that ran it: Phase 1–2,
Phase 3, US1–US10, the copy review and the web build/walk.
