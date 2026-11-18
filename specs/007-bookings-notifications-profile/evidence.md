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

## Not tested yet

Everything below this line is filled in by the stage that ran it: Phase 1–2,
Phase 3, US1–US10, the copy review and the web build/walk.
