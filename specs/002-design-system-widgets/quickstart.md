# Quickstart: Design System Widgets

How to run the feature and check each story. Commands run from the repository root.

## Prerequisites

Flutter 3.47.9 stable (as CI), the Foundation merged into `develop`, this branch checked out.

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter gen-l10n
```

## Automated checks (all must pass)

```bash
flutter analyze --fatal-infos
```

```bash
flutter test
```

What these cover: every widget's states, semantics, 48 targets, 200% text, RTL and LTR, Light and
Dark, reduced motion and per-platform behaviour (SC-001 – SC-004, SC-009, SC-010); the source-scan and
platform guards over `lib/core/widgets/` (SC-002); the presentation-only guard (FR-010); the QR round
trip (SC-007); the Foundation navigation tests with import paths updated (SC-005, SC-006); the
`fewLeftThreshold` setting and its inheritance.

## Run the app

```bash
flutter run -d chrome
```

Open the demo screen from Profile, then "معرض المكونات" to reach `/demo/components`. Other targets:
`-d macos`, an Android emulator, an iOS simulator.

## Story checks (manual, on the gallery)

| Story | Do | Expect |
| --- | --- | --- |
| 1. Gallery | Scroll every section; compare each state with the component's `preview.html` | Every variant and state in the README is shown (SC-001) |
| 1. Controls | Switch theme, language; set text size to 200%; turn on reduced motion | Nothing clips; layout mirrors; motion becomes a short fade (SC-004, SC-009, SC-010) |
| 1. Platform look | Switch Apple, Android, Desktop/Web | Button press and the navigation change as in `adaptive.md`; brand look is identical (SC-008) |
| 2. Availability | Chips: change remaining to 5, 2, 1, 0; day strip: pick a closed day | Words change with colour; `full` and `past` do not select; closed day does not select |
| 2. Grayscale | Put the OS or browser in grayscale | Every state is still told apart by word or icon (SC-003) |
| 3. Actions and input | Tab to each button; type an email with the language on Arabic; trigger an error; show the password | Focus ring on keyboard platforms; email stays left-to-right; error shows icon and message |
| 4. Navigation | Resize the browser across 599/600, 839/840, 1199/1200; select the third item then resize | One form at every width; same item and scroll kept (SC-005). Press keys 1 to 5 on desktop |
| 4. Badges and overflow | Gallery sample with a badge and six destinations | Badge count shown and spoken; "المزيد" opens the rest |
| 5. Cards | Long Arabic names; Dark; the loading form of each card | Names wrap, never overflow; no shadow in Dark; skeleton has the card's shape and holds still under reduced motion |
| 5. QR | Scan the ticket QR with a phone camera in Light and Dark | It decodes to the token shown in the sample (SC-007) |
| 7. Logo | View every variant on light and dark surfaces | Bare mark never appears on a light surface; the tile colours do not change in Dark |

## Developer check (story 6)

Build a throwaway screen with a `DayStrip`, a slot grid of `SlotChip`s, a `FacilityCard` and a
`SprintButton`, passing only widget properties and tokens (SC-011). Then run the guards:

```bash
flutter test test/guards
```

They fail on a raw colour, an unnamed number, a platform check, a string literal in `Text(`, or a
`features/` import inside `lib/core/widgets/`.

## Before opening the PR

- `docs/BRD.md` §4.2 has the `fewLeftThreshold` line (BR-45), and it is the first commit.
- `copy-review.md` lists every new string; Osman has reviewed it.
- The Foundation test files changed only in import paths (`git diff` on `test/shell/`).
- `docs/decisions.md` has an entry for the `SprintExtras` dimensions follow-up and for Phosphor.
