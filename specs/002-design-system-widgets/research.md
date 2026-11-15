# Research: Design System Widgets

Decisions taken in the plan step. Each has the reason and what was rejected. Items are numbered so the
plan, contracts and tasks can cite them. Facts about the existing code were read from the Foundation
(`lib/core/`, `lib/app/`, `test/`) on 2026-11-15.

## R1. Where the widgets live

**Decision**: `lib/core/widgets/<component>/`, one folder per component, plus a barrel file
`design_system.dart`. The gallery is in `lib/features/demo/presentation/component_gallery/`.

**Why**: the widgets are shared by every later feature, and `lib/core/widgets/` already exists
(`option_group.dart`). The Foundation scan guard and the platform guard already scan all of `lib/`, so
no guard needs a new path.

**Rejected**: a new top-level `lib/design_system/` (a second place for shared UI, and it would need
guard changes); putting each widget in its first consumer's feature (later features would import
sideways).

## R2. How widgets get platform behaviour without checking the platform

**Fact**: `test/guards/no_platform_checks_test.dart` allows `TargetPlatform`, `kIsWeb`,
`defaultTargetPlatform` and `adaptiveStyleOf` only in `lib/core/adaptive/`, `lib/core/scroll/` and
`lib/core/theme/`. So a widget cannot call `adaptiveStyleOf` itself.

**Decision**: four small primitives in `lib/core/adaptive/` (contract in
[contracts/adaptive-additions.md](contracts/adaptive-additions.md)):

- `AdaptiveTraits.of(context)`: semantic answers instead of a style name: `pressFeedback`
  (`fade`, `ripple`, `hover`), `hapticsOnSelect`, `tabBarPill`, `numberShortcuts`,
  `keyboardFocusRing`. Widgets ask "what feedback?", never "which platform?".
- `AdaptivePressable`: one pressable wrapper that gives iOS the 70% fade with no ripple, Android the
  `primary-pressed` ripple, and desktop and web the hover colour, pointer cursor and `focus-ring`. It
  builds on the Foundation's `FocusableTap` and `SprintFocusRing` so keyboard behaviour is shared.
- `AdaptiveHaptics.selection(context)`: light haptic on `apple` and `android` styles, nothing on
  `desktop`.
- `AdaptivePlatformOverride(style:, child:)`: wraps a subtree in a `Theme` with a different target
  platform, so the gallery can show Apple, Android and desktop behaviour on one device (R16). It lives
  here because it has to name `TargetPlatform`.

**Why**: one decision point (the Foundation's design), widgets stay testable by overriding the theme
platform, and the guard keeps working unchanged.

**Rejected**: passing a `platform` argument into each widget (screens would then name a platform);
loosening the guard to allow `lib/core/widgets/` (the whole point of the guard is one place).

## R3. Component dimensions that `tokens.json` does not carry

**Fact**: `tokens.json` has `control-height` 48, `control-height-sm` 36, icon sizes, `tabbar-height`
64, `rail-width` 88, `sidebar-width` 280, `content-max`. The READMEs also state: chip 56 high and 100
wide, day pill 64 high, badge 28 high, ticket 340 wide, facility photo 112 wide in the horizontal
layout, QR quiet margin 12. The Foundation's source-scan guard rejects numeric `width:`, `height:` and
similar literals in `lib/`.

**Decision**: add them as named constants to `SprintExtras` (`lib/core/tokens/sprint_extras.dart`,
already the home for "stated in prose, not a token" values), each with a comment naming its README.
Open a follow-up, docs first, to promote them to `tokens.json`, Figma Variables and the generator.

**Why**: it follows the Foundation's own precedent, keeps the guard green without exemptions, and does
not widen this feature into a token-contract change.

**Rejected**: promoting them to `tokens.json` now (changes the generator, the drift test and the
Figma handoff inside a widgets feature); exempting widget files from the guard (defeats Principle II).

## R4. Icons

**Decision** (clarify Q4): `phosphor_flutter`. Its icons are `IconData`, so they plug into the
Foundation's `ShellDestination.icon` and `selectedIcon` unchanged, and the widgets accept `IconData`.
Regular weight everywhere; the Fill weight only for the active navigation item and for nothing else.
The Foundation's four Material icons in `baseDestinations` are replaced by Phosphor equivalents in this
feature (the Foundation comment says they wait for feature 2).

**Status icons** (word always shown, icon distinguishes success from danger): confirmed = check circle,
pending payment = clock, cancelled = x circle, attended = user check, no-show = user minus (neutral),
expired = hourglass (neutral). Verification: under review = clock, verified = seal check, rejected =
x circle. Damage report: open = warning circle, in progress = wrench, resolved = check circle.

**Mirroring**: only chevrons, arrows and send icons mirror, through the Foundation's `DirectionalIcon`
(`mirror: true`); clocks, ticks, QR and the logo never do (README § الأيقونات).

**Rejected**: staying on Material icons (does not match the design); `PhosphorIcon` widget wrappers
(extra widget layer; plain `IconData` is enough and keeps `DirectionalIcon` usable).

## R5. QR rendering and the "decodes back" test

**Decision**: use the pure-Dart `qr` package to get the module matrix from the token, and paint it with
our own `CustomPainter` in `qr-ink` on `qr-ground` with the 12 quiet margin. In tests, render the
painter to an image and decode it with dev-only `zxing2` (+ `image`) to prove SC-007 (the QR decodes
back to exactly the token), in Light and Dark.

**Why**: colours and the margin come from tokens (a ready-made QR widget would need its colour and
margin options audited), the painter is small, and the matrix can be asserted directly as a fallback if
image decoding is flaky on CI.

**Rejected**: `qr_flutter` (works, but hides the matrix and ties the look to its options); a platform
scanner plugin in tests (needs a device).

**Edge**: an empty token shows the "QR غير متاح" state; a very long token is rejected by `qr` and shows
the same state instead of throwing.

## R6. `AppNavigation` replaces the Foundation navigation

**Fact**: `lib/app/shell/nav/` holds `SprintTabBar`, `SprintNavRail`, `SprintSidebar` and `NavData`;
`AdaptiveShell` picks one by `WindowSize` and keeps the body under a `GlobalKey` so a form change
re-parents instead of rebuilding. The tests find the three forms by class name
(`test/shell/shell_boundaries_test.dart`, `shell_a11y_test.dart`).

**Decision**:

- `AppNavigation` is a core widget taking `destinations` (`NavDestination`: label string, icon,
  selected icon, `mirrorInRtl`, optional badge count), `selected`, `onSelected`, and a `form` chosen
  from `WindowSize` unless the caller forces one (the gallery forces it to show each form).
- `core/` must not import `app/`, so the shell maps `ShellDestination` to `NavDestination` using l10n,
  and `AdaptiveShell` keeps its `GlobalKey` body, its hinge layout and its `goBranch` logic, swapping
  only the three navigation widgets for `AppNavigation`.
- The three form widgets move into `lib/core/widgets/app_navigation/` **with their class names kept**,
  so the Foundation tests change only in their import path and the behaviour they assert is untouched
  (SC-006). The old files in `lib/app/shell/nav/` are deleted (FR-057).
- New behaviour added on top of the Foundation's: active styling per the README, the Android pill, the
  Apple blur (already `AdaptiveBarSurface`), badges, the "المزيد" overflow through `showSprintSheet`,
  the number-key shortcuts (`AdaptiveTraits.numberShortcuts`), the lockup in the sidebar.

**Why**: one navigation implementation, the Foundation guarantees proved by the Foundation's own tests,
and the dependency direction stays core ← app.

**Rejected**: `AppNavigation` reading `ShellDestination` (core would depend on app); renaming the three
forms (hides regressions behind test edits).

## R7. `SprintLogo`

**Decision**: `flutter_svg` drawing the three existing files, declared as assets straight from
`docs/design-system/logo/` (no copy, so the repository stays the single source). The lockup is the tile
plus a `Text` in the `title` style (Cairo 700, 20/30) in `ink`, gap `space-3`, tile on the start side;
the tile never mirrors, only its side follows the reading direction. Minimum size 16 is enforced by
clamping. A bare `mark` is drawn only when its background contrasts with `volt` by at least 3:1;
otherwise it falls back to `tile-primary` (spec Assumption). The background is a parameter that
defaults to the surface the widget sits on.

**Why**: the SVG files are the reference ("don't redraw the bolt"); the logo has no states.

**Rejected**: re-drawing the bolt as a Dart path (the README forbids redrawing); copying the SVGs into
`assets/` (a second copy).

## R8. Press, hover, focus and the pressed colour

**Decision**: every pressable widget (`SprintButton`, `SlotChip`, `DayStrip` day, `FacilityCard`,
`StatTile`, navigation items, `StatusBadge` is not pressable) uses `AdaptivePressable` (R2). It shows
one coherent state at a time (pressed beats hovered beats focused), which covers the spec's "press and
focus together" edge case. Tested by overriding the theme platform.

## R9. The few-left threshold

**Decision** (clarify Q1): add `fewLeftThreshold` (int, default 2, at least 1, allowed at university,
facility and unit scope) to `SettingKeys` and `settingRegistry`, plus one line in BRD §4.2 next to
BR-06 and BR-07 using the next free business-rule number (BR-45; the BRD ends at BR-44). The BRD edit is
the first commit of the PR. `SlotChip` receives `fewLeftThreshold` as an input; only the gallery and
later screens read the setting. The settings inspector (Foundation FR-020) shows it automatically
because it lists the registry.

## R10. `DayStrip` data and defaults

**Decision**: the caller passes a list of `DayStripDay` (date, `hasAvailability`, `isClosed`) and the
`today` date; the widget never reads a clock or a setting. The first-with-room default is a static
`DayStrip.defaultSelection(days)` used by the widget when `selected` is null and by callers that need
the same value, so nothing fires during build. Day count comes from the list length (the caller reads
`bookingWindowDays`). Compact scrolls horizontally and keeps the selected day in view; medium and
larger spread across the width (decided by `WindowSize` of the strip's own constraints, so a hinge pane
behaves). Arrow keys move focus between days on keyboard platforms (`AdaptiveTraits.keyboardFocusRing`).

## R11. `SlotChip` state resolution

**Decision**: a pure function `SlotState resolveSlotState({...})` in `slot_state.dart`, with the
precedence `past` > `full` > `selected` > `fewLeft` > `available`, where `full` is
`remaining == 0` (or an explicit full flag for exclusive units) and `fewLeft` is
`remaining != null && remaining <= threshold`. The caller may pass an explicit state; the helper exists
so every screen derives it the same way. Table-driven unit tests cover every boundary (0, threshold,
threshold + 1, exclusive, past while selected).

## R12. Haptics and clipboard

**Decision**: haptics through `AdaptiveHaptics.selection` (R2) wrapping `HapticFeedback.selectionClick`.
Copying the booking code uses `Clipboard.setData`, then shows a short "اتنسخ" label in place of the copy
hint and announces it with a live-region semantic so a screen reader says it. No snackbar (it would
need a Scaffold in every host).

## R13. Number formats and the ticket date line

**Decision**: extend `SprintFormat` (the Foundation's formatter, Western digits, Cairo time) with
`timeRange(start, end)` ("5:00 – 6:00 م", the period shown once when both ends share it, otherwise on
both), `dateTimeLine` ("التلات 10 نوفمبر · 5:00 – 6:00 م"), `dayName` (short and full), `compactCount`
(cap at 99 and show "99+"), and `percent`. Money keeps using `price`. All take Cairo-local
`DateTime`s (the caller converts with `CairoTime`).

## R14. Copy and plurals

**Decision**: slot words are ICU plurals in the ARB files so Arabic dual and plural are right: for the
few-left word, 1 → "فاضل 1", 2 → "فاضل مكانين", other → "فاضل {n}" (README table), with a separate
spoken form ("فاضل مكان واحد"). English: "1 place left", "2 places left". A copy review in the
Foundation's style (`copy-review.md`) lists every new string for Osman before the PR is merged.

## R15. Loading forms

**Decision**: named constructors `FacilityCard.loading({layout})`, `BookingTicket.loading()` and
`StatTile.loading()` assemble `Skeleton` blocks with the loaded widget's outer shape and radius. The
`Skeleton` primitive is not edited. Each loading form is silent to a screen reader (the primitive already
excludes itself from semantics), as the spec requires (FR-064); no loading label is added.

## R16. The gallery and its reviewer controls

**Decision**: a screen at `/demo/components`, linked from the demo screen, gated by the same
`demoToolsEnabled` flag, one section file per component, built lazily (a `ListView` with section
builders) so the screen opens fast with ten components of many states. Reviewer controls at the top:

- Text size: 100%, 130%, 150%, 200% (a `MediaQuery` text scaler override).
- Reduced motion: a toggle (a `MediaQuery` `disableAnimations` override).
- Platform look: Apple, Android, Desktop/Web, through `AdaptivePlatformOverride` (R2).

Theme and language use the Foundation's existing switchers. Sample content comes from the seed data and
the settings repository (FR-066): the window length, the few-left threshold and the cancellation cut-off
are read through the repository, never typed into the gallery. The reviewer controls are not product
settings and are not persisted.

## R17. Tests and guards

**Decision**:

- One widget test file per component (variants and states from its README, semantics labels,
  48-point targets, 200% text, RTL and LTR, Light and Dark, reduced motion, per-style behaviour by
  overriding the platform).
- A new guard `widgets_presentation_only_test.dart` fails if any file in `lib/core/widgets/` imports
  `package:sprint/features/`, a settings provider or a repository (FR-010).
- `no_platform_checks_test.dart` and `source_scan_test.dart` need no change; they already scan
  `lib/core/widgets/`.
- `arb_parity_test.dart` covers the new keys.
- QR round trip (R5) and the navigation boundary and state tests (Foundation, import paths updated).
- A grayscale check is manual (quickstart), since colour-blind simulation is not a unit test.

## R18. Delivery order and what the PR contains

**Decision**: one PR, commits in this order so each stays green: (1) BRD and the `fewLeftThreshold`
setting with its tests, (2) the adaptive primitives and `SprintExtras` constants, (3) the leaf widgets
(`SprintLogo`, `StatusBadge`, `SprintButton`, `SprintTextField`), (4) the booking vocabulary
(`SlotChip`, `DayStrip`), (5) the cards (`FacilityCard`, `BookingTicket`, `StatTile`) with loading
forms, (6) `AppNavigation` and the shell swap with Foundation tests green, (7) the gallery, ARB copy
review and docs. CI is unchanged (analysis, tests; the web build runs on `develop`).
