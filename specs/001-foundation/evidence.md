# Evidence for the success criteria (T087, T088)

Collected 2026-11-11 on branch `001-foundation`. Automated checks at that point:
`flutter analyze --fatal-infos` clean, `flutter test` 449 passed,
`flutter build web --release --base-href /sprint-app/` built, CI `build` green.

## Devices walked (T087)

| Target | How | Result |
| --- | --- | --- |
| Web | Chrome pane, debug-free release build served locally | Shell, theme, language, demo, dialog (Enter/Esc), anchored menu, hash deep link OK |
| macOS | `flutter build macos --debug`, launched | Shell with rail and dark theme (system) shown |
| iOS phone | iPhone 17 Pro simulator, debug | Tab bar, RTL, Cupertino alert, switch, indicator, back chevron OK |
| iPad (tablet) | iPad Pro 11" simulator, portrait 834 pt | Rail form (medium), content beside it OK |
| Android + foldable | Pixel 10 Pro Fold emulator, release APK | Unfolded inner display with a flat fold: sidebar, no split; Profile, demo, arrow back, Material switch OK |
| Windows, Linux | not run (need their own hosts) | scaffolded only, as planned |

A split-screen hinge was exercised in tests (`test/shell/hinge_test.dart`), not on a
device posture. A tabletop (horizontal hinge) posture is not tested.

## Success criteria

| SC | Evidence |
| --- | --- |
| SC-001 | Started and showed the shell on web, macOS, iOS, Android and an iPad (table above) |
| SC-002 | `test/shell/shell_boundaries_test.dart`: exactly one nav form at 320, 599, 600, 839, 840, 1199, 1200, 1920 |
| SC-003 | `test/shell/shell_state_test.dart` (destination, typed text, scroll across every boundary), `hinge_test.dart` |
| SC-004 | `test/guards/source_scan_test.dart` (raw colours, numeric style literals, volt misuse) |
| SC-005 | `test/guards/arb_parity_test.dart`, `test/core/l10n/locale_test.dart` |
| SC-006 | `test/shell/text_scale_test.dart`, `shell_a11y_test.dart` at 200% |
| SC-007 | `test/core/adaptive/*` on Apple, Android, desktop; seen by hand on web, iOS, Android. A reviewer's own judgement is still Osman's |
| SC-008 | `test/features/settings/*` (8 inheritance combinations, validation, audit) |
| SC-009 | `conflict_checker_test`, `booking_repository_test`, `permission_checker_test` |
| SC-010 | Not yet provable: needs a merge into `develop` (T091). `deploy.yml` is written, Pages source is "GitHub Actions", `build` is a required check |
| SC-011 | See below: not met on the web estimate |

## SC-011 numbers (T088)

**Web build, first load** (from the served build and the gstatic CDN):

| Part | Size on the wire |
| --- | --- |
| `main.dart.js` | 4.1 MB raw, 1.04 MB gzip |
| 8 bundled fonts (Alexandria 2, Cairo 4, IBM Plex Mono 2) | 1.12 MB raw, 0.58 MB gzip |
| CanvasKit (`canvaskit.wasm`, from `gstatic.com`) | 1.56 MB brotli |
| CanvasKit JS, Roboto fallback (from `gstatic.com`), misc | about 0.15 MB |
| **Total** | **about 3.3 MB** |

Unthrottled on localhost the shell was drawn in about 1.1 s. **No DevTools throttled run
was possible from here**, so the 4G figure is arithmetic, not a measurement: about 3 s at
9 Mbps and about 17 s at 1.6 Mbps, against a 3 s target. Deferring IBM Plex Mono
(research R10) would save about 0.14 MB gzip, which does not change that.
Two findings: CanvasKit and the Roboto fallback load from `gstatic.com` at run time
(the build also ships a 36 MB local `canvaskit/` folder it does not use by default),
which conflicts with "no network access at runtime".

**Installed builds:**

| Build | Result |
| --- | --- |
| Android release APK (56.1 MB), arm64 emulator, `am start -W`, after warm-up | 2.28 to 2.53 s cold start (first runs right after boot: 5.8 to 10.3 s) |
| iOS | Not measured: a release build cannot run on the simulator and no device is attached. A debug launch is not representative |

The emulator is not a phone: 2.3 to 2.5 s is slightly above the 2 s target and needs a
real mid-range device to confirm.
