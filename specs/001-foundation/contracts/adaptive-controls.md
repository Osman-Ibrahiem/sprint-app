# Contract: Adaptive controls

**Spec**: FR-019, FR-020, User Story 3 | **Source**: `docs/design-system/adaptive.md`
**Status**: matches the code as built (checked 2026-11-11).

Public widgets and functions in `lib/core/adaptive/`. Screens call them and never inspect the
platform. The decision lives in one place, `platform.dart`.

## Which style applies

`adaptiveStyleOf(context)` returns one of three styles from the theme platform:

| Style | When |
| --- | --- |
| `apple` | iOS, iPadOS, and native macOS |
| `android` | Android |
| `desktop` | Windows, Linux, Fuchsia, and any desktop browser (the web on macOS included) |

On the web, a phone browser (iOS or Android) keeps its phone style; a desktop browser gets
`desktop`. Platform checks (`TargetPlatform`, `kIsWeb`, `defaultTargetPlatform`,
`adaptiveStyleOf`) are allowed only in `lib/core/adaptive/`, `lib/core/scroll/` and
`lib/core/theme/`; `test/guards/no_platform_checks_test.dart` enforces it.

## Controls

| API | Key inputs | Apple | Android | Desktop (web, Windows, Linux) |
| --- | --- | --- | --- | --- |
| `AdaptiveAppBar` (a `PreferredSizeWidget`, for `Scaffold.appBar`) | `title`, `leading?`, `actions` | `CupertinoNavigationBar`: centred title, chevron back | `AppBar`: start-aligned title, arrow back | Same as Android |
| `AdaptiveSliverAppBar` (inside a `CustomScrollView`) | `title`, `largeTitle`, `leading?`, `actions` | `CupertinoSliverNavigationBar` with a large title when `largeTitle`, else the box bar pinned | Pinned `SliverAppBar`, start-aligned title (`largeTitle` has no effect) | Same as Android |
| `showSprintDialog<T>` | `title`, `message?`, `actions` of `SprintDialogAction(label, value?, isDestructive, isDefault)` | `CupertinoAlertDialog` | Material `AlertDialog` (theme gives `radius-xl`), actions at the end | The same dialog, centred; Enter confirms the default action, Esc cancels |
| `showSprintSheet<T>` | `title?`, `actions` of `SprintSheetAction(label, value?, isDestructive)`, or `builder`, `cancelLabel?`, `anchor?` | `CupertinoActionSheet` from the bottom, with a cancel button | Modal bottom sheet (scrolls when long); Esc closes | `showMenu` anchored to `anchor` (or the calling context); Esc closes. With `builder`, a dialog |
| `AdaptiveSwitch` | `value`, `onChanged`, `semanticLabel` | `CupertinoSwitch`, `primary` track | Material `Switch` with a check in the thumb | Same as Android |
| `AdaptiveLoader` | `semanticLabel`, `size?` | `CupertinoActivityIndicator` | `CircularProgressIndicator` | Same as Android |
| `AdaptiveBarSurface` | `child`, `border?` | Translucent `surface` with a blur | Solid `surface` | Solid `surface` |

The dialog and sheet functions return the chosen action's `value`, or `null` when dismissed.
Why the names differ from `showAdaptiveDialog`: that name already exists in Flutter.
Why two app bars: a large title only works inside a sliver, so it has its own widget.

## Shared rules

- Colours, radius, spacing and text styles come from tokens. The Volt lime is never used as a
  line or icon on a light surface.
- Every control exposes a semantic label from l10n; state is conveyed by text or icon, not
  colour only (the Material switch shows a check; the chosen option shows a check and a word).
- Touch targets are at least 48 logical pixels (switch and loader wrap to 48). The one exception
  is the Apple navigation bar and its back button, which keep the native 44 height (Osman,
  2026-11-11; recorded in `docs/decisions.md` and the plan's complexity table).
- A visible keyboard focus: `FocusableTap` and the buttons, text fields and switch in
  `SprintTheme` draw the `focus-ring` line (2 px, `focus-ring` colour); a test checks it.
- Destructive actions use `danger` plus a word, never colour alone.
- Reduced motion: the loader stops spinning and shows a fixed three-quarter ring; skeletons stop
  pulsing. Page, sheet and dialog transitions keep the platform's own timing.
- An open dialog, sheet or menu is closed when the language changes, so it never stays open in the
  old language and the new direction (`SprintApp` listens to the locale).
- Tests override the target platform and assert which concrete widget appears, so the table
  above is verified, not just documented.
