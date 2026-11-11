# Sprint (سبرنت)

Flutter app for booking and paying for Tanta University's sports facilities, with no cash. Android, iOS, tablets, foldables, web and desktop. Arabic first (RTL), English second, light and dark.

It is also the third research tool in Dr. Sara El-Hag's PhD thesis (Sports Management and Recreation, Faculty of Physical Education, Tanta University), shown as a working system to the expert reviewers and at the defense.

**Status:** phase P1, UI first, on placeholder seed data. No backend, no real payments, no SMS. See [`CLAUDE.md`](CLAUDE.md) and [`docs/`](docs/) for scope and decisions.

Live build (after `develop` deploys): <https://osman-ibrahiem.github.io/sprint-app/>

## Prerequisites

- Flutter **3.47.9** (stable) on `PATH`; run `flutter doctor` for the platforms you use.
- Chrome for web, Xcode and a simulator for iOS/macOS, an Android emulator or device for Android.

## Run

```bash
flutter pub get
```

```bash
flutter run -d chrome
```

Use `flutter run -d macos`, or `flutter run -d <device-id>` for a phone or emulator. The app starts as a guest. Open **Profile → Reviewer demo screen** (`/#/demo`) to switch theme, language and user, to try the five adaptive controls, and to see which level each setting resolves from.

## Generated code

Tokens, Riverpod, Freezed and l10n output are committed. Regenerate after changing their sources:

```bash
dart run tool/gen_tokens.dart
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter gen-l10n
```

`docs/design-system/tokens.json` is the source of truth for tokens; change it first, then regenerate.

## Check

```bash
flutter analyze --fatal-infos
```

```bash
flutter test
```

```bash
flutter build web --release --base-href /sprint-app/
```

CI runs the same three checks on every pull request into `develop` and `main`, and `develop` is deployed to GitHub Pages when they pass.

## Layout

| Path | What |
| --- | --- |
| `lib/app/` | App, router, adaptive shell, placeholders |
| `lib/core/` | Tokens, theme, l10n, adaptive controls, time, seed data, providers |
| `lib/features/` | Feature-first domain, data and presentation (settings, catalogue, identity, booking, payments, ...) |
| `docs/` | BRD, decisions, design system |
| `specs/` | Spec Kit specs, plans and tasks |

## Hiding reviewer tools

The user switcher and settings inspector are for reviewers. Build with `--dart-define=HIDE_DEMO_TOOLS=true` to remove them.
