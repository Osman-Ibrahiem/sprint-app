# Evidence for the success criteria (T085, T086, T087)

## Automated checks (T087)

Run 2026-11-16 on a clean checkout of `003-auth-verification` (detached worktree at `37f828e`):
`dart run build_runner build --delete-conflicting-outputs` and `flutter gen-l10n` left no
changed files, `flutter analyze --fatal-infos` no issues, `flutter test` 1223 passed,
`flutter build web --release --base-href /sprint-app/` built.

## Devices walked (T085, partial)

| Target | How | Result |
| --- | --- | --- |
| Web | Release build served locally, in-app browser pane at 800 px (medium width, dark, Arabic) | See the web checks below |
| macOS | `flutter build macos --debug`, launched | Starts on Home with the rail, dark theme, Arabic. Not walked further: no way to drive the window from here |
| Android, iOS | Run by Osman on his devices, reported 2026-11-16 | Camera capture and the quickstart checks OK |

### Web checks, 2026-11-16

| Story | Check | Result |
| --- | --- | --- |
| US1 sign up | Guest → Profile → create account → code from the demo notice → signed in, tier external, booker role | OK |
| FR-013a | Reload after sign up: still signed in | OK |
| US2 sign in | Wrong password: "بيانات الدخول مش صحيحة"; Enter submits | OK |
| US2 lockout | Fifth wrong password on one email: wait message with 5 minutes | OK |
| US2 by phone | Seed verifier by phone: Verification section appears in the navigation | OK |
| US3 gate | Guest opens `/#/verification` → `/sign-in?from=/verification`; signing in as a booker shows the no-access screen | OK |
| US6 review | Verifier (PE) queue lists only دينا محمود (Engineering request hidden); approve → "موثّق" and the queue empties | OK |
| US5 request | Form validation (photo required) shows the error | OK |
| US5 photo, US6 sheet upload | Need the browser's file chooser | Not checked here; covered by Osman's device run |
| Sign out | Confirm dialog, back to guest | OK |
| US4 reset, FR-013b reset, US7 freeze | not walked (covered by tests) | Not checked by hand |

### Problems seen and fixed

1. Every `SprintTextField` drew a second, inner border and a second focus ring. Cause: `InputDecoration.collapsed` clears only `border`, so the theme's `enabledBorder` and `focusedBorder` (`inputDecorationTheme` in `lib/core/theme/sprint_theme.dart`) still applied. The bug was already on `develop` (Foundation). Fixed by clearing every border of the inner field; a test guards it. Checked again on the web: one border, one focus ring.
2. On Profile and My Bookings as a guest, "تسجيل الدخول" and "إنشاء حساب" opened the account dialog, which asked the same choice again. `requireAccount` now takes the choice already made, so both buttons go straight to their screen (tests updated). Checked again on the web.

## Web load (T086)

Not measured yet: needs the deployed build.

## Copy review (T083)

`copy-review.md` reviewed and accepted by Osman on 2026-11-16.
