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
| SC-010, failing build | The merge gate is proved live (section below): a failing `build` blocks the PR. A failing push to `develop` is not shown, because branch protection forbids it; structurally `deploy` runs only after a successful `build` |

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

## Web splash and early connections, measured (SC-011)

Branch `perf/web-splash-preconnect-2`. A splash (logo and "سبرنت", plain HTML and CSS) is in
`web/index.html` and goes away at the first Flutter frame; `preconnect` links open the
connections to `www.gstatic.com` and `fonts.gstatic.com` early. Measured on local builds served
with gzip (`tool/serve_web.mjs`), 3 runs per case, 4x CPU slowdown, same profiles as above.

| Profile | Version | First paint | First Flutter frame |
| --- | --- | --- | --- |
| Fast 4G | before | the same as the first frame | 4.12 s, 4.14 s, 4.19 s |
| Fast 4G | after | **0.26 s, 0.29 s, 0.30 s** (splash) | 3.98 s, 4.03 s, 4.61 s |
| Slow 4G | before | the same as the first frame | 17.2 s, 17.2 s, 17.7 s |
| Slow 4G | after | **0.24 s, 0.25 s, 0.28 s** (splash) | 17.1 s, 17.1 s, 17.1 s |

What it shows:

- **The splash works**: something branded is on screen in about 0.3 s on both profiles, instead
  of a blank page for 4 s (Fast 4G) or 17 s (Slow 4G). It is checked in light and dark.
- **The time to the real first frame did not change**: the 0.1 s difference on Fast 4G is inside
  the run-to-run noise (3.98 s to 4.61 s). `preconnect` has no measurable effect here.
- **Why**: the request waterfall on Fast 4G shows `canvaskit.wasm` (1.5 MB) and `main.dart.js`
  (0.93 MB) already download in parallel from 0.6 s, and the fonts only start after the engine
  is up. The load is bandwidth-bound: about 3 MB at 9 Mbps is about 2.7 s of pure transfer.
  Opening connections earlier cannot fix that; only fewer bytes can.
- Honest limits: headless Chrome with emulation, 3 runs, a local server instead of GitHub Pages.
  The `preconnect` links were kept because they cost nothing and may help on a real network; the
  numbers do not prove it. Remove them if you prefer only what is proven.

SC-011 as written (interactive in 3 s on 4G) is still not met; see the options above. The splash
changes what the reviewer sees in the first second, not when the app responds.

## Cairo-only fonts, measured (SC-011)

Branch `design/fonts-cairo-only` (decisions.md, 2026-11-15): Alexandria and IBM Plex Mono removed,
four Cairo weights left. Same method and profiles as above, local gzip server, 3 runs.

| Profile | Splash and preconnect only | Cairo only |
| --- | --- | --- |
| Fast 4G, first Flutter frame | 3.98 s, 4.03 s, 4.61 s (median 4.03 s) | **3.65 s, 3.72 s, 3.84 s (median 3.72 s)** |
| Slow 4G, first Flutter frame | 17.1 s, 17.1 s, 17.1 s | **15.6 s, 15.6 s, 15.7 s** |
| First paint (splash) | 0.24 to 0.30 s | 0.25 to 0.31 s |

About 0.3 s faster on Fast 4G and 1.5 s on Slow 4G, as estimated from the font sizes (0.27 MB
gzip less). SC-011 as written (interactive in 3 s on 4G) is still not met on the web: 3.7 s on
Fast 4G, 15.6 s on Slow 4G.

## SC-011 after the decision of 2026-11-15

The web target changed (spec SC-011, `docs/decisions.md`): splash visible within 1 s and
interactive within 5 s on fast 4G; slow 4G splash within 1 s, interactive time recorded only.

| Check | Target | Measured | Status |
| --- | --- | --- | --- |
| Web, fast 4G, splash visible | 1 s | 0.25 to 0.31 s | met |
| Web, fast 4G, interactive | 5 s | 3.65 to 3.84 s | met |
| Web, slow 4G, splash visible | 1 s | 0.25 to 0.26 s | met |
| Web, slow 4G, interactive | recorded only | 15.6 to 15.7 s | recorded |
| Installed Android, cold start | 2 s | 2.3 to 2.5 s on an emulator | **open**: needs a real mid-range phone |
| Installed iOS, cold start | 2 s | not measured | **open**: needs a real device |

The two installed-build rows are the only part of SC-011 still open.

## Merge gate proved live (SC-010, FR-028)

Ported from the closed PR #4 (branch `001-closeout`, still on GitHub). That PR carried one commit
with a deliberately failing test (`test/zz_closeout_gate_test.dart`, `expect(1 + 1, 3)`), then a
revert commit; history was not rewritten.

| Moment | `build` check | PR state |
| --- | --- | --- |
| Head with the failing test (`24c0940`) | **failed** after 2 m 27 s: `Expected: <3> Actual: <2>` in the Test step ([run](https://github.com/Osman-Ibrahiem/sprint-app/actions/runs/43028482364)) | `mergeStateStatus: BLOCKED` while the PR was mergeable in content |
| Head after the revert (`c2f558f`) | passed ([run](https://github.com/Osman-Ibrahiem/sprint-app/actions/runs/43028984378)) | clean |

So a change whose tests fail cannot reach `develop`, and `deploy.yml` runs only on a push to
`develop`, after `build` succeeds. What is still not shown is a failing *push* to `develop`, which
branch protection forbids.

