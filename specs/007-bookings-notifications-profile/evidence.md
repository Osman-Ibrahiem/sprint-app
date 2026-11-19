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

## Progress of the continuation (2026-11-19)

- Done and green (full `flutter test` 2121 passed at the end of Phase 3; booking, app, shell and catalogue folders green after US1 to US3): T028 to T054, T056, T047.
- Notes: the notifications destination is always a route (hidden from guests and from the compact tab bar by the shell), so signing in never rebuilds the router; `showSprintDialog` renders `WideDialog` from the medium class; the facilities list got a "كل المنشآت" title for the root header.
- Pending cancel (BR-48, T057 to T059) already works through the details actions and the repository, but has no dedicated tests yet. T055 (facility cancel display) is implemented in `StatusBanner` without its own test.
- Not started: T057 to T079 (tests for pending cancel and facility view, notifications centre and reminders, permission dialog, demo actions, account, edit profile, search, matrix and dead-end tests), T080, T084, T085. Placeholders `PendingScreen` still stand for `/notifications` and `/profile/edit`; `ProfilePlaceholder` still exists.

## Not tested yet

Everything below this line is filled in by the stage that ran it: Phase 1–2,
Phase 3, US1–US10, the copy review and the web build/walk.
