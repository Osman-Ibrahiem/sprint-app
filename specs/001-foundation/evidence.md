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
| SC-010 | After the merge of PR #1 (`52075b6`, 2026-11-11 12:36 UTC) the `Deploy` run on `develop` finished green (`build` then `deploy`) in about 3 minutes, and the site is live at https://osman-ibrahiem.github.io/sprint-app/. The failing-build half (a failing merge leaves the live build unchanged) is **not proved live**: it holds because the `deploy` job `needs: build`, and a live proof would need a deliberately failing push to `develop`, which branch protection forbids. See the section below |
| SC-011 | See below: not met on the web estimate |

## SC-011 numbers (T088)

**Web build, first load** (served build and the gstatic CDN, after the Cairo-only time zone
change in `40f7f9d`):

| Part | Size on the wire |
| --- | --- |
| `main.dart.js` | 3.3 MB raw, 0.94 MB gzip (was 4.1 MB / 1.04 MB) |
| 8 bundled fonts (Alexandria 2, Cairo 4, IBM Plex Mono 2) | 1.12 MB raw, 0.58 MB gzip |
| CanvasKit (`canvaskit.wasm`, from `gstatic.com`) | 1.56 MB brotli |
| CanvasKit JS, Roboto fallback (from `gstatic.com`), misc | about 0.15 MB |
| **Total** | **about 3.2 MB** |

Unthrottled on localhost the shell was drawn in about 1.1 s. **No DevTools throttled run
was possible from here**, so the 4G figure is arithmetic, not a measurement: about 2.9 s at
9 Mbps and about 16 s at 1.6 Mbps, against a 3 s target. **Status: open.** It sits on the
edge for fast 4G and is over for slow 4G.

What was tried and what remains:

- Done: bundle only Africa/Cairo time zone data (about 105 KB gzip saved).
- Tried and dropped: `--wasm` build, whose main module is about the same size (1.08 MB gzip).
- Where the rest is: the Flutter framework (1.37 MB raw of the JS), `flutter_localizations`
  (190 KB raw, all locales), CanvasKit, the fonts. Our own code is 95 KB raw.
- Not done, each needs Osman's decision: defer IBM Plex Mono (about 0.14 MB gzip, changes the
  font declaration rule in `contracts/tokens.md`); subset the font files (about 0.3 MB, changes
  the font files); self-host CanvasKit (removes the run-time `gstatic.com` dependency, likely
  slower).
- To close it: run Chrome DevTools "Fast 4G" and "Slow 4G" on the published Pages site after the
  merge and record the first-interactive time here.
- Open finding: CanvasKit and the Roboto fallback load from `gstatic.com` at run time, which
  conflicts with "no network access at runtime"; the build also ships a 36 MB local `canvaskit/`
  folder it does not use by default.

**Installed builds:**

| Build | Result |
| --- | --- |
| Android release APK (56.1 MB), arm64 emulator, `am start -W`, after warm-up | 2.28 to 2.53 s cold start (first runs right after boot: 5.8 to 10.3 s) |
| iOS | Not measured: a release build cannot run on the simulator and no device is attached. A debug launch is not representative |

The emulator is not a phone: 2.3 to 2.5 s is slightly above the 2 s target and needs a
real mid-range device to confirm.

## Live site check after the merge (T091)

Checked 2026-11-11 against https://osman-ibrahiem.github.io/sprint-app/:

| Check | Result |
| --- | --- |
| `/`, `/main.dart.js` (3.27 MB), `/flutter_bootstrap.js`, a bundled font | all HTTP 200; `<base href>` is `/sprint-app/` |
| Deep link `/#/facilities` opened directly in a fresh browser tab (FR-029) | Facilities screen inside the sidebar shell, Arabic RTL, Dark; the route is client-side (hash), so a refresh requests the same `index.html` |
| First paint | The page stayed blank for about 6 s on the first load in the browser pane; consistent with the SC-011 estimate and still to be measured with DevTools "Fast 4G" and "Slow 4G" |
| SC-010, failing build | Not proved by a live failing deploy (see the SC table). Structural reason: `deploy` runs only after a successful `build` |

## SC-011 measured on the published site (T099)

Measured 2026-11-15 on https://osman-ibrahiem.github.io/sprint-app/ (develop after PRs #2 and #3)
with `tool/measure_web_load.mjs`: headless Google Chrome driven over the DevTools protocol, a
390 x 844 phone viewport, **4x CPU slowdown** (a stand-in for a mid-range phone), cache disabled,
3 runs per profile. DevTools has no "4G" preset, so the profiles are: **Fast 4G** = 9 Mbps down,
170 ms round trip; **Slow 4G** = 1.6 Mbps down, 150 ms round trip (the Lighthouse "slow 4G"
numbers). "First content" is the first contentful paint, which for this app is the first drawn
frame of the shell.

| Profile | First content, 3 runs | Median | Target |
| --- | --- | --- | --- |
| No throttle (CPU 1x) | 2.5 s, 3.0 s, 3.5 s | 3.0 s | |
| Fast 4G, CPU 4x | 4.2 s, 4.4 s, 4.6 s | **4.4 s** | 3 s |
| Slow 4G, CPU 4x | 17.4 s, 17.5 s, 17.9 s | **17.5 s** | 3 s |

**Result: SC-011 is not met on the web** (about 1.5x the target on Fast 4G, about 6x on Slow 4G).

What it shows:

- Even with no throttling the first paint takes 2.5 to 3.5 s on this machine, so the cost is
  not only bytes: the browser must fetch and start the 3.3 MB app script and the CanvasKit
  engine (`canvaskit.wasm`, about 1.56 MB brotli) from `gstatic.com` before the first frame.
- On Fast 4G the wait is about 70% fixed start-up (script and engine), so shaving fonts barely
  moves it: deferring IBM Plex Mono (about 0.14 MB gzip) saves about 0.1 s on Fast 4G and about
  0.7 s on Slow 4G; subsetting the fonts (about 0.3 MB) saves about 0.2 s and about 1.5 s. Neither
  brings Slow 4G anywhere near 3 s.
- Limits of this measurement: headless Chrome with emulated throttling, not a real phone and not
  a real mobile network; the bytes counter undercounts (2.5 MB shown against about 3.2 MB on the
  wire); the profiles are chosen by me, not by DevTools presets.

Options for Osman, in order of effort (decision recorded in `docs/decisions.md` once taken):

1. **Re-word SC-011 for the web**: first screen visible in 3 s on Fast 4G thanks to a small
   HTML/CSS splash in `web/index.html` (shown at once, before the engine loads), interactive in
   5 s on Fast 4G; the 2 s target stays for installed builds.
2. **Keep 3 s as "interactive"** and accept that the web build misses it; the installed apps
   are the product and Pages is for review.
3. **Reduce the weight** (Plex Mono deferral, font subsets): small gain, changes the font rule;
   not recommended on its own.

