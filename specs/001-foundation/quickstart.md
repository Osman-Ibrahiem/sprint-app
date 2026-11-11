# Quickstart: validating Foundation

**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

How to run the finished feature and prove each user story. Rule details live in
[data-model.md](data-model.md) and [contracts/](contracts/); this file does not repeat them.

## Prerequisites

- Flutter 3.47.9 (stable) on `PATH`; `flutter doctor` clean for the targets you check.
- Chrome for web; Xcode and a simulator for iOS; an Android emulator or device for Android.
- For the foldable check: a foldable emulator (Android Studio "Pixel Fold" or "Galaxy Z Fold")
  or a physical foldable.

## Setup

```bash
flutter pub get
```

```bash
dart run tool/gen_tokens.dart
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter gen-l10n
```

The Cairo-only time zone data is regenerated with `dart run tool/gen_cairo_tzdata.dart` (a test
fails if it drifts). To hide the reviewer tools in a build, add `--dart-define=HIDE_DEMO_TOOLS=true`.

## Automated checks (same as CI)

```bash
flutter analyze --fatal-infos
```

```bash
flutter test
```

```bash
flutter build web --release --base-href /sprint-app/
```

Expected: no analyzer findings, all tests green (tokens drift, ARB parity, guard scans, rule
services, settings inheritance, permission matrix, shell at the six boundary widths, adaptive
controls per platform, 200% text), and a successful web build.

## Run

```bash
flutter run -d chrome
```

```bash
flutter run -d macos
```

Use `flutter run -d <device-id>` for Android and iOS devices.

## Manual validation by user story

| Story | Steps | Expected |
| --- | --- | --- |
| US1 shell | Open the app, drag the window across 600, 840 and 1200 | Arabic RTL; tab bar → rail → sidebar; same destination and scroll position kept; large window caps content width |
| US1 hinge | Run on a foldable emulator, fold and unfold, set a vertical hinge posture | Navigation changes form; destination and typed text kept; nothing under the hinge |
| US1 not found | Open `/#/nothing` | Not-found screen with a button back to Home |
| US2 theme | Switch device between light and dark; then pick light/dark/system in Profile → Appearance; relaunch | Follows device; manual choice remembered; dark has no shadows |
| US2 language | Switch to English | All shell text English, layout LTR, only directional icons mirrored; codes, phones, emails stay LTR in Arabic |
| US2 text | Set system text size to the maximum (200%) on a compact window | No clipped or overlapping text |
| US2 motion | Turn on "reduce motion" in the system | Shell animations skipped or short fade |
| US3 adaptive | Open `/#/demo` on iOS, Android and web; trigger the dialog, sheet, switch, loader and app bar | Each matches [contracts/adaptive-controls.md](contracts/adaptive-controls.md) |
| US4 data | On the demo screen, switch from guest to a seeded internal booker and back; open the settings inspector | Profile placeholder changes between the sign-in prompt and the user's name, role and tier; the inspector shows where each setting resolves from (unit, facility, university or default). Role-specific destinations are proved by `flutter test test/features/identity` |
| US4 rules | Run `flutter test test/features` | Conflict, capacity, pricing, cancellation, hold and permission cases pass |
| US5 deploy | Merge a trivial change into `develop`; open the Pages link | New build live in under 10 minutes; deep link and refresh work; a deliberately failing change leaves the old build live |

## Done means

All automated checks green on CI for the pull request, the manual table above checked on at
least web, macOS, one Android target and one iOS target (Windows and Linux are not run in this feature), and the
spec's success criteria SC-001 – SC-011 each ticked with the evidence noted in the pull request.
