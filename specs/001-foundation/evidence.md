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
| SC-011 | Measured on the published site (T099): web first load is **not met** (about 3.3 s on Fast 4G, about 18 s on Slow 4G, against 3 s). See "SC-011 measured" below |

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

Measured 2026-11-11 by Osman in Chrome DevTools on https://osman-ibrahiem.github.io/sprint-app/
(deploy of PR #1, `52075b6`), Network tab, **Disable cache** on, hard reload at `/#/home`.
The times are read from the Time column of the screenshots, where the cells were cut off, so
they are good to about a tenth of a second.

| | Fast 4G | Slow 4G |
| --- | --- | --- |
| Requests | 20 | 20 |
| Transferred | 3.2 MB (10.2 MB of resources) | 3.2 MB |
| `main.dart.js` (955 KB) | about 2.1 s | about 11 s |
| `canvaskit.wasm` (1.5 MB, from `gstatic.com`) | about 3.3 s | about 18 s |
| Each bundled font | under 0.1 s | about 4 s |
| **Shell on screen (the last resource)** | **about 3.3 s** | **about 18 s** |

- The measured transfer (3.2 MB) matches the estimate above (3.2 MB), so the byte counts in
  "SC-011 numbers (T088)" hold.
- **Result: not met.** Fast 4G is about 10% over the 3 s target; Slow 4G is far over.
- The long pole is `canvaskit.wasm`, then `main.dart.js`; both are on the critical path. These
  runs had the cache off: a repeat visit is served by the service worker and is much faster, and
  SC-011 is about the first visit.
- Next step, as decided on 2026-11-11 (`docs/decisions.md`): defer IBM Plex Mono (about 0.14 MB
  gzip, 4% of the transfer), then, with Osman's OK, subset the font files (about 0.3 MB). Plex
  Mono alone is expected to leave Fast 4G at about 3.2 s, so both are likely needed.

