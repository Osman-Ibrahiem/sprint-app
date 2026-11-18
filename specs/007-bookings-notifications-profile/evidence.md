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

## Not tested yet

Everything below this line is filled in by the stage that ran it: Phase 1–2,
Phase 3, US1–US10, the copy review and the web build/walk.
