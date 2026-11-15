# Evidence (feature 002)

Recorded 2026-11-15.

## Package note

The Phosphor package in `pubspec.yaml` is `phosphor_icons`, not `phosphor_flutter` as the plan
named it: `phosphor_flutter` 2.1.0 extends `IconData`, which became a `final class` in the current
Flutter. The choice is in `docs/decisions.md` (2026-11-15). Icons are used as `const` `IconData`.

## SC-005, SC-006 (Foundation suite stays green)

`flutter test test/shell test/core` and the whole suite after the widgets landed:
`flutter analyze --fatal-infos` clean, `flutter test` 694 passing, 0 failing. The only Foundation
test edits are the import paths of the three navigation widgets that moved to
`lib/core/widgets/app_navigation/` (T047); no assertion changed.

## T053 web cost (Foundation SC-011)

`flutter build web --release`, develop at `154e42e` versus this branch:

| | develop | this branch | change |
| --- | --- | --- | --- |
| `build/web` total | 42,336 KB | 45,400 KB | +3,064 KB |
| `main.dart.js` | 3,272,963 B (gzip 940,826 B) | 3,620,507 B (gzip 1,046,302 B) | +347,544 B (gzip +105,476 B) |

Icon tree-shaking is on for every font. The cost is mostly the Phosphor fonts: all six weights are
bundled by `phosphor_icons` and tree-shaking only trims 2–14% of each (Fill 386 KB, Bold 432 KB,
Regular 441 KB, Light 471 KB, Thin 472 KB, Duotone 556 KB), about 2.7 MB raw; only Regular and Fill
are used. Splash and interactive times on a fast-4G profile were **not measured** here (no browser
profile run); they need a pass in Chrome before the PR. Suggested mitigation if the 5 s target is
missed: vendor only `Phosphor.ttf` and `Phosphor-Fill.ttf` as font assets.

## Not done in this pass

T072 (manual device checks, QR scan with a phone), T073 (preview.html comparison), T076 (PR), and
the `CLAUDE.md` "Current state" update in T074 (after merge) are left for Osman.
