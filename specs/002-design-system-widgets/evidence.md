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
are used. Mitigation if ever needed: vendor only `Phosphor.ttf` and `Phosphor-Fill.ttf` as font assets.

### T053 load times (Foundation SC-011, web target of 2026-11-15)

Measured 2026-11-15 with `tool/measure_web_load.mjs` (headless Google Chrome over the DevTools
protocol, 390 x 844 phone viewport, 4x CPU slowdown except "No throttle", cache disabled, 3 runs per
profile), both builds served by `tool/serve_web.mjs` under `/sprint-app/` with gzip, built with
`flutter build web --release --base-href /sprint-app/`. CanvasKit loads from the Google CDN as in
the Foundation. "Splash" is the first contentful paint (the HTML splash in `web/index.html`).
"Interactive" is the first Flutter frame (the `flutter-first-frame` event), the same measure the
Foundation used. develop is `154e42e`.

| Profile | | Splash (3 runs) | Interactive (3 runs) | Median interactive |
| --- | --- | --- | --- | --- |
| Fast 4G (9 Mbps, 170 ms), CPU 4x | develop | 272, 264, 268 ms | 3.65 s, 3.67 s, 3.68 s | **3.67 s** |
| | this branch | 316, 276, 260 ms | 4.12 s, 4.05 s, 4.05 s | **4.05 s** |
| Slow 4G (1.6 Mbps, 150 ms), CPU 4x | develop | 280, 252, 244 ms | 15.70 s, 15.73 s, 15.70 s | 15.70 s |
| | this branch | 288, 256, 248 ms | 17.13 s, 17.14 s, 17.11 s | 17.13 s |
| No throttle, CPU 1x | develop | 48, 32, 40 ms | 1.12 s, 1.13 s, 0.91 s | 1.12 s |
| | this branch | 40, 48, 40 ms | 1.41 s, 1.10 s, 0.91 s | 1.10 s |

**Result against SC-011 (web: splash within 1 s, interactive within 5 s on Fast 4G):** met on Fast
4G. Splash about 0.28 s (limit 1 s) and interactive 4.05 s (limit 5 s). The feature adds about
0.4 s on Fast 4G and about 1.4 s on Slow 4G (measured, no limit), and nothing measurable without
throttling. Bytes on the wire rose from about 2.7 MB to about 3.0 MB. Limits of the measurement:
headless Chrome with emulated throttling, not a real phone or network; the profiles are the ones
the Foundation chose; the first Flutter frame stands in for "interactive". No mitigation is needed
for the 5 s target; the Phosphor font option above stays available if the margin shrinks.

## Not done in this pass

T072 (manual device checks, QR scan with a phone), T073 (preview.html comparison) and the
`CLAUDE.md` "Current state" update in T074 (after merge) are left for Osman. The PR is open (#11).
