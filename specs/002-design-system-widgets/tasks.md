---

description: "Task list for the Design System Widgets feature"
---

# Tasks: Design System Widgets

**Input**: Design documents from `/specs/002-design-system-widgets/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Included. The spec's success criteria (SC-001 – SC-011) and the constitution's mechanical
guards require them, so each story lists its tests first, and they MUST fail before the code they
cover exists.

**Organization**: Grouped by user story. The phases follow dependency order, not strict priority:
`SprintLogo` (US7, P3) comes before `AppNavigation` (US4, P1) because the sidebar shows the lockup;
the other P2 and P3 stories can run in parallel once Phase 2 is done.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: US1 gallery · US2 availability vocabulary (`SlotChip`, `DayStrip`, `StatusBadge`) ·
  US3 actions and input (`SprintButton`, `SprintTextField`) · US4 `AppNavigation` · US5 cards
  (`FacilityCard`, `BookingTicket`, `StatTile`) · US6 developer guarantees · US7 `SprintLogo`
- Paths are relative to the repository root (single Flutter package, see plan.md)

## Rules for every task

- Tokens only, no raw colours or numeric style literals (named constants in `SprintExtras` for README
  dimensions, research R3); direction-aware layout; strings only in `lib/l10n/*.arb`, in Arabic and
  English together (constitution II, V). Settings are read through `SettingsRepository`, never typed
  into a widget (III).
- Nothing under `lib/core/widgets/` imports `features/`, `app/`, a provider or a repository, and
  nothing there names a platform; platform behaviour comes only from `lib/core/adaptive/`.
- Commit messages and the PR description cite BRD IDs. Branch: `002-design-system-widgets`. No
  force-push, no history rewrite.
- Do not touch Figma, `docs/design-system/tokens.json` or the fonts in this feature.

---

## Phase 1: Setup

**Purpose**: The requirement change first, then dependencies, so every later commit is green.

- [x] T001 Add `fewLeftThreshold` to `docs/BRD.md` §4.2 as BR-45, next to BR-06 and BR-07: "a shared slot with remaining places at or below `fewLeftThreshold` (default **2**, university → facility → unit) is shown as few left"; also cite it from the SlotChip row in `docs/design-system/components/SlotChip/README.md`. This MUST be the first commit of the PR (constitution I, clarify Q1)
- [x] T002 Add runtime dependencies `phosphor_flutter`, `flutter_svg`, `qr` and dev dependencies `zxing2`, `image` with `flutter pub add`, and declare the three logo SVGs as assets straight from `docs/design-system/logo/` in `pubspec.yaml` (no copy; research R4, R5, R7)
- [x] T003 [P] Record two entries in `docs/decisions.md` with today's date and reason: Phosphor adopted as the icon set (clarify Q4), and README component dimensions kept as `SprintExtras` constants with a follow-up to promote them to `tokens.json` (research R3)

---

## Phase 2: Foundational (blocks every story)

**Purpose**: The setting, the adaptive primitives, shared constants and formatters, and the test
harness that all widgets use.

### Setting

- [x] T004 [P] Write the failing registry test in `test/features/settings/few_left_threshold_test.dart`: default is 2; a facility value beats the university value and a unit value beats both; a value below 1 is rejected ("must be at least 1"); the key appears in the registry listing
- [x] T005 Add `fewLeftThreshold` to `SettingKeys` and `settingRegistry` in `lib/features/settings/domain/setting_registry.dart`: `SettingKey<int>('fewLeftThreshold')`, `defaultValue: 2`, allowed scopes university, facility and unit, validation `_atLeast(1)`, comment "BR-45"; confirm the settings inspector in `lib/features/demo/presentation/settings_inspector.dart` lists it without code change (data-model.md "The new setting")

### Shared constants and formatting

- [x] T006 [P] Add the README dimensions as named constants with a comment naming each README to `lib/core/tokens/sprint_extras.dart`: slot chip min height 56 and min width 100, day pill height 64, status badge height 28, booking ticket width 340, facility photo width 112 (horizontal layout), QR quiet margin 12, ticket notch radius, logo minimum size 16, logo mark contrast threshold 3, navigation badge cap 99, facility photo aspect 16:9 (research R3, R7)
- [x] T007 [P] Write failing formatter tests in `test/core/l10n/sprint_format_additions_test.dart`: `timeRange` gives "5:00 – 6:00 م" when both ends share the period and "11:00 ص – 1:00 م" when they differ; `dateTimeLine` gives "التلات 10 نوفمبر · 5:00 – 6:00 م" in Arabic and "Tue 10 Nov · 5:00 – 6:00 PM" in English; `compactCount` returns "99" and "99+"; `percent(73.4)` returns "73%"; Western digits in both languages
- [x] T008 Add `timeRange`, `dateTimeLine`, `dayName` (short and full), `compactCount` and `percent` to `lib/core/l10n/sprint_format.dart`, taking Cairo-local `DateTime`s, using only existing ARB date/time patterns plus the new keys they need (research R13); makes T007 pass

### Adaptive primitives (contract: contracts/adaptive-additions.md)

- [x] T009 [P] Write failing tests in `test/core/adaptive/adaptive_traits_test.dart` for every trait value per style (overriding the theme platform to iOS, Android, Windows), per the contract table
- [x] T010 [P] Write failing tests in `test/core/adaptive/adaptive_pressable_test.dart`: Apple fades to `applePressedOpacity` with no ripple; Android shows an ink ripple in the given pressed colour; desktop changes colour on hover and uses the click cursor; all show the focus ring on keyboard focus and activate on Enter and Space; hit area at least 48; `onTap == null` is skipped by focus and exposes the disabled semantic; pressed beats hovered beats focused
- [x] T011 [P] Write failing tests in `test/core/adaptive/adaptive_haptics_test.dart` (a selection haptic is requested on Apple and Android, none on desktop, no throw when the channel is unhandled) and `test/core/adaptive/adaptive_platform_override_test.dart` (`apple`, `android`, `desktop` each make `adaptiveStyleOf` return that style inside, and leave it unchanged outside)
- [x] T012 Implement `lib/core/adaptive/adaptive_traits.dart` (`AdaptiveTraits.of(context)`: `pressFeedback`, `hapticsOnSelect`, `tabBarPill`, `numberShortcuts`, `keyboardFocusRing`) from `adaptiveStyleOf`; makes T009 pass
- [x] T013 Implement `lib/core/adaptive/adaptive_pressable.dart` building on `lib/core/a11y/focusable_tap.dart` and `lib/core/a11y/sprint_focus_ring.dart` (fade, ripple, hover, one coherent state, 48 hit area, `Semantics(button: true, selected, label)`); makes T010 pass
- [x] T014 [P] Implement `lib/core/adaptive/adaptive_haptics.dart` and `lib/core/adaptive/adaptive_platform_override.dart` (`apple` → iOS, `android` → Android, `desktop` → Windows); makes T011 pass

### Test harness, barrel and guard

- [x] T015 [P] Add `test/helpers/widget_harness.dart`: `pumpWidgetUnder(tester, child, {locale, dark, textScale, reduceMotion, style})` building a themed `MaterialApp` with `SprintTheme`, the Arabic default locale, `Directionality`, and an optional `AdaptivePlatformOverride`; reuse `setWindow` from `test/helpers/pump_app.dart` for size and text scale (used by every widget test)
- [x] T016 [P] Create the empty barrel `lib/core/widgets/design_system.dart` (exports are added as each widget lands) and write the failing guard `test/guards/widgets_presentation_only_test.dart`: no file under `lib/core/widgets/` imports `package:sprint/features/`, `package:sprint/app/`, a `*_provider.dart` file or a repository (FR-010); also asserts the scan finds at least the existing `option_group.dart` so it cannot pass on an empty folder

**Checkpoint**: setting resolves, primitives and harness exist, guards run. Stories can start.

---

## Phase 3: User Story 1 - Gallery of every widget in every state (Priority: P1)

**Goal**: A reviewer opens `/demo/components` and sees every component section, with reviewer
controls for text size, reduced motion and platform look, hidden by the demo switch. The component
sections themselves are filled by the later stories; this phase delivers the screen, the controls, the
route and the empty section scaffolding.

**Independent Test**: Open the gallery; sections for all ten components are listed; switch text size,
reduced motion and platform look and see the page react; with `HIDE_DEMO_TOOLS=true` the route and the
link are gone (spec US1 scenarios 1, 4, 5, 6; SC-008).

### Tests for US1

- [x] T017 [P] [US1] Write failing tests in `test/features/demo/component_gallery_test.dart`: the screen lists ten section headings in Arabic and English; the text size control sets the text scaler to 1.0, 1.3, 1.5 and 2.0 for the subtree; the reduced-motion toggle sets `disableAnimations` for the subtree; the platform look control wraps the sections in `AdaptivePlatformOverride`; the sample-content note is visible; the sections are built lazily (only the first screenful exists in the widget tree at 400 × 800)
- [x] T018 [P] [US1] Write failing tests in `test/features/demo/component_gallery_gate_test.dart`: with `demoToolsEnabled` false the route is not registered and the link on the demo screen is absent; with it true the link opens the gallery (FR-065, clarify Q2)

### Implementation for US1

- [x] T019 [P] [US1] Add the gallery ARB keys (`galleryTitle`, `gallerySampleNote`, `galleryTextSize`, `galleryReducedMotion`, `galleryPlatformLook`, `galleryPlatformApple`, `galleryPlatformAndroid`, `galleryPlatformDesktop`, `galleryOpenFromDemo`, and one section title per component) to `lib/l10n/app_ar.arb` (template) and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`
- [x] T020 [US1] Create `lib/features/demo/presentation/component_gallery/component_gallery_screen.dart`: a `ListView` of lazily built section builders under an `AdaptiveAppBar`, the three reviewer controls at the top using `OptionGroup` from `lib/core/widgets/option_group.dart`, text scale and reduced motion applied through `MediaQuery`, platform look through `AdaptivePlatformOverride`, the sample-content note ("بيانات تجريبية"); sections are registered in one list so each later story adds one entry
- [x] T021 [P] [US1] Create `lib/features/demo/presentation/component_gallery/gallery_section.dart`: a shared section frame (title, optional caption, a responsive wrap for variants, a labelled row per state) so every component section looks the same
- [x] T022 [US1] Register the route `/demo/components` (name `demoComponents`) in `lib/app/router/routes.dart` and `lib/app/router/app_router.dart`, outside the shell like `/demo`, and add a link "معرض المكونات" to `lib/features/demo/presentation/demo_screen.dart`, both gated by `demoToolsEnabled` from `lib/features/demo/demo_flags.dart`
- [x] T023 [US1] Add `/demo/components` to the route map in `specs/001-foundation/contracts/routes.md`'s successor note by creating `specs/002-design-system-widgets/contracts/routes-delta.md` (one table row: path, name, gate), so the route contract has a written source

**Checkpoint**: the gallery opens with empty sections and working controls; T017 and T018 pass.

---

## Phase 4: User Story 3 - Actions and input with one identity (Priority: P1)

**Goal**: `SprintButton` and `SprintTextField` in all variants and states.

**Independent Test**: In the gallery, press each button variant under each platform look, tab to each
with a keyboard, type an email in Arabic, trigger an error, show the password (spec US3 scenarios 1–9).

### Tests for US3

- [x] T024 [P] [US3] Write failing tests in `test/core/widgets/sprint_button_test.dart`: five variants use the token colours of the Button README table; `md` is `control-height` and `sm` is `control-height-sm` with a 48 hit area; start and end icon, directional icon mirrors in RTL; loading shows `AdaptiveLoader`, the loading label, and ignores presses; disabled keeps the label and announces "<label>، غير متاح"; a label with a price renders in full with Western digits; press feedback per style (fade on iOS, ripple on Android, hover and pointer on desktop); focus ring on keyboard focus; no `volt` fill in any variant; 200% text grows the button instead of clipping
- [x] T025 [P] [US3] Write failing tests in `test/core/widgets/sprint_text_field_test.dart`: label always above and never floating; placeholder is separate from the label; helper shown; error replaces the helper with a `danger` icon and message and 2px `danger` border on `danger-soft`, and the message is in the semantics; focused border 2px `primary`; disabled uses `surface-sunken` and `ink-disabled`; `email`, `phone`, `nationalId` and `password` type left-to-right and start-aligned in Arabic; keyboard type and autofill hints per type (contract table); password show and hide control with 48 target and the labels "إظهار" and "إخفاء"; `search` is a pill on `surface-sunken` with a search icon; `onLeave` fires when focus leaves and nothing validates on each character; 200% text keeps label and helper readable

### Implementation for US3

- [x] T026 [P] [US3] Add ARB keys `buttonDisabledSuffix`, `buttonBusy`, `fieldShowPassword`, `fieldHidePassword`, `fieldSearchHint` to `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb`; run `flutter gen-l10n`
- [x] T027 [US3] Implement `lib/core/widgets/sprint_button/sprint_button.dart` with `SprintButtonVariant`, `SprintButtonSize` and an icon spec, built on `AdaptivePressable`, `AdaptiveLoader` and `DirectionalIcon`, colours from `context.colors`, radius `SprintRadius.md`, text style `button`; makes T024 pass (FR-013 – FR-017)
- [x] T028 [US3] Implement `lib/core/widgets/sprint_text_field/sprint_text_field.dart` with `SprintTextFieldType` and the per-type keyboard, autofill, direction and alignment from contracts/widgets.md, the focus state, error state and password reveal, using `LtrIsolate`-style direction for LTR types; makes T025 pass (FR-018 – FR-022)
- [x] T029 [US3] Export both from `lib/core/widgets/design_system.dart`
- [x] T030 [P] [US3] Add the Button and TextField gallery sections in `lib/features/demo/presentation/component_gallery/sections/button_section.dart` and `text_field_section.dart` showing every variant × size × (default, loading, disabled), icon positions, and every field type × (default, focused, error, disabled); register them in `component_gallery_screen.dart`; include the usage rules a widget cannot enforce (one `primary` per screen, `danger` only after a confirmation dialog) as captions (FR-017)

**Checkpoint**: US3 complete and demonstrable in the gallery.

---

## Phase 5: User Story 2 - Read availability in one second (Priority: P1)

**Goal**: `SlotChip`, `DayStrip` and `StatusBadge`.

**Independent Test**: In the gallery, set chips and the day strip to each state; read them with a
screen reader and view them in grayscale (spec US2 scenarios 1–8; SC-003).

### Tests for US2

- [x] T031 [P] [US2] Write failing table-driven tests in `test/core/widgets/slot_state_test.dart` for `resolveSlotState` (data-model.md): precedence `past` > `full` > `selected` > `fewLeft` > `available`; boundaries `remaining` 0, threshold, threshold + 1; exclusive unit (null remaining); a selected chip that becomes full; past while selected
- [x] T032 [P] [US2] Write failing tests in `test/core/widgets/slot_chip_test.dart`: five states with the README colours and words; "5 أماكن" on a shared unit and no number on an exclusive one; "فاضل 1", "فاضل مكانين" and "فاضل N" plural forms in Arabic and the English forms; at least 56 × 100; `full` and `past` ignore presses and say why; spoken sentence "الساعة 6 مساءً، فاضل مكان واحد" (and with a price); range fill tints `primary-soft`; selection calls the haptic on Apple and Android and not on desktop; a state change animates colour and word together within `duration-base` (and a short fade under reduced motion) and a screen reader is told of the new state (live-region announcement); never relies on `volt` alone (the word is present); 200% text grows the chip
- [x] T033 [P] [US2] Write failing tests in `test/core/widgets/day_strip_test.dart`: exactly the supplied days, today first and named "النهارده", in reading order (today at the right in Arabic, left in English); selected day `primary`/`on-primary`; `success` dot (never `volt`) with the spoken "فيه أماكن"; closed day `ink-disabled`, not pressable, spoken "مقفول"; `defaultSelection` returns the first day with room, else the first open day; compact scrolls horizontally and keeps the selected day visible; medium and larger spread across the width; arrow keys move focus on desktop; debug assert on non-consecutive days; window of 1 day and of 30 days
- [x] T034 [P] [US2] Write failing tests in `test/core/widgets/status_badge_test.dart`: all twelve `SprintStatus` values show their word and icon always, with the contract colours; `noShow` and `expired` are neutral; height 28, `radius-full`; not pressable; spoken "الحالة: مؤكد"; changing the status swaps icon, word and colour together and a screen reader is told of the new status (live-region announcement); `success` and `danger` badges have different icons (so they differ without colour)

### Implementation for US2

- [x] T035 [P] [US2] Add ARB keys for the slot, day and status groups of contracts/widgets.md ("New ARB keys") to `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` with ICU plurals for the Arabic dual and plural forms (`slotAvailablePlaces`, `slotFewLeft`, `slotFewLeftSpoken`), run `flutter gen-l10n`; the arb parity guard must pass
- [x] T036 [P] [US2] Implement `lib/core/widgets/slot_chip/slot_state.dart` (`SlotState` and `resolveSlotState`) with the precedence rule quoted from data-model.md; makes T031 pass
- [x] T037 [US2] Implement `lib/core/widgets/slot_chip/slot_chip.dart` on `AdaptivePressable` and `AdaptiveHaptics`, `AnimatedSwitcher` at `SprintMotion.durationBase` timed through `ReducedMotion.fade`, size from `SprintExtras`; makes T032 pass (FR-023 – FR-027)
- [x] T038 [P] [US2] Implement `lib/core/widgets/day_strip/day_strip_day.dart` and `lib/core/widgets/day_strip/day_strip.dart` (`DayStripDay`, `DayStrip.defaultSelection`, scroll or spread by `WindowSize`, arrow-key focus movement, haptic on selection); makes T033 pass (FR-028 – FR-031)
- [x] T039 [P] [US2] Implement `lib/core/widgets/status_badge/sprint_status.dart` (the enum, its word, icon and colour pair table from contracts/widgets.md) and `lib/core/widgets/status_badge/status_badge.dart`; makes T034 pass (FR-032 – FR-034)
- [x] T040 [US2] Export the three from `lib/core/widgets/design_system.dart`
- [x] T041 [P] [US2] Add the SlotChip, DayStrip and StatusBadge gallery sections in `lib/features/demo/presentation/component_gallery/sections/slot_chip_section.dart`, `day_strip_section.dart`, `status_badge_section.dart`: a chip grid for each state (shared and exclusive), a free-facility range example, a day strip whose length and the chips' threshold are read through `SettingsRepository` (`bookingWindowDays`, `fewLeftThreshold`) and labelled as sample, a closed day, and all twelve statuses; register them (FR-066)

**Checkpoint**: US2 complete and demonstrable.

---

## Phase 6: User Story 7 - The Sprint logo (Priority: P3, built before navigation)

**Goal**: `SprintLogo` in five variants; required by the `AppNavigation` sidebar.

**Independent Test**: View every variant on light and dark surfaces in both languages (spec US7).

### Tests for US7

- [x] T042 [P] [US7] Write failing tests in `test/core/widgets/sprint_logo_test.dart`: each `LogoVariant` renders the matching SVG asset; the lockup has the tile on the start side, the name in the `title` style (Cairo 700) in `ink`, gap `space-3`, in Arabic ("سبرنت") and English ("Sprint"); tile colours are identical in Light and Dark; a bare `mark` on a light background falls back to the primary tile and on a dark one renders the mark; the mark is never mirrored in RTL; a requested size below 16 is raised to 16; no shadow, border or recolour is applied

### Implementation for US7

- [x] T043 [P] [US7] Add ARB key `logoLabel` to both ARB files; run `flutter gen-l10n`
- [x] T044 [US7] Implement `lib/core/widgets/sprint_logo/sprint_logo.dart` with `LogoVariant`, `flutter_svg` drawing from the asset paths declared in T002, the contrast rule against `volt` from `SprintExtras` (3:1) for the bare mark, size clamping, and lockup layout; makes T042 pass (FR-062, FR-063)
- [x] T045 [US7] Export it from `lib/core/widgets/design_system.dart` and add the gallery section `lib/features/demo/presentation/component_gallery/sections/logo_section.dart` (all variants on `bg`, `surface`, `ink` and a dark box); register it

**Checkpoint**: US7 complete; the sidebar can use it.

---

## Phase 7: User Story 4 - AppNavigation (Priority: P1)

**Goal**: One component, three forms, replacing the Foundation's plain navigation with every
Foundation guarantee kept.

**Independent Test**: Run the Foundation navigation tests (import paths updated), then the gallery at
the six boundary widths (spec US4 scenarios 1–10; SC-005, SC-006).

### Tests for US4

- [x] T046 [P] [US4] Write failing tests in `test/core/widgets/app_navigation_test.dart`: the active styling per form (Fill icon and `primary` label; `primary-soft` pill with `on-primary-soft`; `primary-soft` row with `on-primary-soft`); Apple tab bar translucent with no pill, Android solid `surface` with the pill allowed; badge in `danger` with `on-danger`, hidden at 0, "99+" above 99, spoken with the destination ("الإشعارات، 3 غير مقروءة"); six destinations on compact give four plus "المزيد" opening the sheet with the rest; desktop hover shows `surface-sunken`, focus ring, and number keys 1 to 5 select; rail and sidebar on the start edge in both languages; the sidebar shows `SprintLogo`; text at 200% drops labels in the tab bar but keeps the spoken label; every item at least 48; selecting the selected item reports it; a changed badge count is announced to a screen reader
- [x] T047 [P] [US4] Update the Foundation tests only in their imports and finders: `test/shell/shell_boundaries_test.dart`, `test/shell/shell_a11y_test.dart`, `test/shell/shell_state_test.dart`, `test/shell/hinge_test.dart`, `test/shell/text_scale_test.dart` (class names `SprintTabBar`, `SprintNavRail`, `SprintSidebar` stay; assertions unchanged); confirm with `git diff` that no assertion text changed (SC-006, research R6)

### Implementation for US4

- [x] T048 [P] [US4] Add ARB keys `navMore`, `navBadgeSpoken` (plural) to both ARB files; run `flutter gen-l10n`
- [x] T049 [US4] Implement `lib/core/widgets/app_navigation/nav_destination.dart` (`NavDestination`: label, icon, selectedIcon, `mirrorInRtl`, `badgeCount?`) and `lib/core/widgets/app_navigation/app_navigation.dart` (`AppNavigation`, form from `WindowSize`, optional forced form, debug assert for fewer than two destinations)
- [x] T050 [US4] Move `lib/app/shell/nav/sprint_tab_bar.dart`, `sprint_nav_rail.dart` and `sprint_sidebar.dart` to `lib/core/widgets/app_navigation/` with `git mv`, keeping the class names, and rebuild them on `NavDestination`, `AdaptivePressable`, `AdaptiveTraits` and `AdaptiveBarSurface`: README active styling, badges, the "المزيد" overflow through `showSprintSheet`, number-key shortcuts through `CallbackShortcuts` when `numberShortcuts`, `SprintLogo` lockup at the top of the sidebar, label dropping above `SprintExtras.navLabelMaxTextScale`; makes T046 pass (FR-048 – FR-056). T050 and T051 MUST land in one commit: after the move, the shell still imports the old paths until T051 rewires it
- [x] T051 [US4] Update `lib/app/shell/adaptive_shell.dart` to build `AppNavigation` instead of the three Foundation widgets: map `ShellDestination` plus the localized label to `NavDestination` in one function, keep the `GlobalKey` body, `DisplayFeatureLayout`, `goBranch` and the large-window `contentMax` centring, delete `lib/app/shell/nav/nav_destinations_view.dart` and the now-empty folder, and replace the four Material icons in `lib/app/router/routes.dart` `baseDestinations` with Phosphor equivalents (Regular, and Fill for `selectedIcon`) (FR-056, FR-057, research R4, R6)
- [x] T052 [US4] Run the full Foundation suite (`flutter test test/shell test/core`) and fix regressions in the new code, never in the assertions; record the result in `specs/002-design-system-widgets/evidence.md` under "SC-005, SC-006"
- [x] T053 [US4] Measure the web cost of the new packages (Foundation SC-011): run `flutter build web --release` before (on `develop`) and after the change, record the build size and the splash and interactive times on a fast 4G profile in `specs/002-design-system-widgets/evidence.md`; confirm every Phosphor icon is a `const` `IconData` so icon-font tree-shaking stays on; if the web target (splash 1 s, interactive 5 s) is missed, stop and report to Osman before continuing (research R4, R5, R7)
- [x] T054 [US4] Export `AppNavigation` and `NavDestination` from `lib/core/widgets/design_system.dart` and add the gallery section `lib/features/demo/presentation/component_gallery/sections/app_navigation_section.dart` showing each form forced (inside a fixed-size box), sample destinations for guest, booker and trainer, a notifications badge, six destinations; register it

**Checkpoint**: US4 complete; the app shell runs on `AppNavigation` and the Foundation suite is green.

---

## Phase 8: User Story 5 - Cards (Priority: P2)

**Goal**: `FacilityCard`, `BookingTicket` and `StatTile`, each with a loading form.

**Independent Test**: In the gallery, render each card in every state with long Arabic names, in both
themes, both languages, at 200% text and in its loading form (spec US5 scenarios 1–14; SC-007).

### Tests for US5

- [x] T055 [P] [US5] Write failing tests in `test/core/widgets/facility_card_test.dart`: three kinds; vertical and horizontal layouts (photo 112 wide on the start side); at most three tags and a debug assert above that; offer tag `volt` with `on-volt` and the old price struck through in `ink-muted`; the "صورة المنشأة" placeholder when no photo; availability plenty, few and none each with icon and word; internal price with its audience label, guest sees both prices, free shows "مجاني" and no price; whole card is one pressable target with no button inside; `shadow-card` in Light and none in Dark; long Arabic name wraps; spoken sentence; `heroTag` is applied to the photo; loading form has the same outer size and is excluded from semantics
- [x] T056 [P] [US5] Write failing tests in `test/core/widgets/booking_ticket_test.dart`: upcoming and today show the `volt` time band with `on-volt` text and past shows `surface-sunken` with `ink-muted`; the date line "التلات 10 نوفمبر · 5:00 – 6:00 م"; dashed divider with two notches in `bg`; QR in `qr-ink` on `qr-ground` with margin 12 in Light and Dark; past or cancelled hides the QR and shows the status; empty token and over-long token show "QR غير متاح" without throwing; code is left-to-right in the `code` style and copying puts it on the clipboard, shows "اتنسخ" and announces it; "الإلغاء مش متاح" when `cancelUntil` is null; no offer or ad slot; 340 wide on compact, centred on larger; loading form shape
- [x] T057 [P] [US5] Write the failing QR round-trip test in `test/core/widgets/qr_roundtrip_test.dart`: for a set of tokens (including `qrTokenFor` outputs from `lib/features/booking/domain/qr_token.dart`), render the QR painter to an image in Light and Dark and decode it with `zxing2`; the decoded text equals the token in 100% of cases (SC-007); fall back to asserting the module matrix against `qr` if image decoding is unavailable on CI
- [x] T058 [P] [US5] Write failing tests in `test/core/widgets/stat_tile_test.dart`: label and period, `number-lg` value with a smaller `ink-muted` unit; delta arrow for direction, `success` for good and `danger` for bad from `higherIsBetter`, neutral for flat, and the sentence says both ("زيادة 12% عن الأسبوع اللي فات"); no delta shows "مفيش مقارنة"; "1,250,000 ج.م" and "73%" formatting; tappable only with `onTap`; no chart; flexible width; loading form

### Implementation for US5

- [x] T059 [P] [US5] Add the facility, ticket and stat ARB groups of contracts/widgets.md to both ARB files with plurals where listed (`facilityUnitCount`); run `flutter gen-l10n`
- [x] T060 [P] [US5] Implement `lib/core/widgets/facility_card/facility_card_data.dart` (`FacilityKind`, `FacilityCardLayout`, `AvailabilityLevel`, `FacilityPrice`, `FacilityTag` with data-model.md's fields and the three-tag limit) and `lib/core/widgets/facility_card/facility_card.dart` including `FacilityCard.loading` from `lib/core/motion/skeleton.dart` (without editing `Skeleton`); makes T055 pass (FR-035 – FR-040, FR-064)
- [x] T061 [P] [US5] Implement `lib/core/widgets/booking_ticket/qr_painter.dart` (a `CustomPainter` over the `qr` module matrix in `qr-ink` on `qr-ground`, margin from `SprintExtras`, safe on empty or oversized input) and make T057 pass
- [x] T062 [US5] Implement `lib/core/widgets/booking_ticket/booking_ticket.dart` including `BookingTicket.loading`, the notch painter, copy-with-announcement via `Clipboard` and a live-region semantic, and the reveal at `SprintMotion.durationSlow` with `SprintMotion.easeEnter` through `ReducedMotion.fade`; uses `StatusBadge` and `SprintFormat.dateTimeLine`; makes T056 pass (FR-041 – FR-047, FR-064)
- [x] T063 [P] [US5] Implement `lib/core/widgets/stat_tile/stat_delta.dart` and `lib/core/widgets/stat_tile/stat_tile.dart` including `StatTile.loading`; makes T058 pass (FR-058 – FR-061, FR-064)
- [x] T064 [US5] Export the three from `lib/core/widgets/design_system.dart`
- [x] T065 [P] [US5] Add the FacilityCard, BookingTicket and StatTile gallery sections in `lib/features/demo/presentation/component_gallery/sections/facility_card_section.dart`, `booking_ticket_section.dart`, `stat_tile_section.dart`: cards built from the Foundation's seed facilities, bookings and prices through the repositories (both price tiers, guest view, offer, free, with trainer, no photo, long Arabic names), the three ticket states and a cancelled one using a seed `qrTokenFor` token, tiles for up, down, flat and no comparison with money and rate values, and every loading form; register them (FR-066)

**Checkpoint**: US5 complete and demonstrable.

---

## Phase 9: User Story 6 - Developers build from the widgets (Priority: P2)

**Goal**: The guarantees that keep later features from drifting.

**Independent Test**: The guards pass; a sample screen is built from widget properties only (spec US6; SC-002, SC-011).

- [x] T066 [P] [US6] Add `test/core/widgets/property_names_test.dart`: each widget's public constructor exposes the property names of the `handoff.md` component table (`variant`, `size`, `state`, `status`, `layout`, `form`, `trend`, `type`, `selected`) by reflecting on a constructed widget through a small table of expected names; fails on a rename (FR-011)
- [x] T067 [P] [US6] Add `test/core/widgets/plain_values_test.dart`: every widget builds inside the harness of T015 with plain values and no `ProviderScope`, no repository and no settings (FR-010, US6 scenario 2)
- [x] T068 [P] [US6] Add `test/core/widgets/sample_screen_test.dart` and `test/core/widgets/sample_screen.dart`: a throwaway screen with a `DayStrip`, a grid of `SlotChip`s, a `FacilityCard` and a `SprintButton` built from widget properties and tokens only, which then passes the same source-scan rules (SC-011)
- [x] T069 [US6] Run `flutter test test/guards` and fix any hit by changing the widget, never the guard; confirm `source_scan_test.dart`, `no_platform_checks_test.dart`, `arb_parity_test.dart` and `widgets_presentation_only_test.dart` all scan the new files (SC-002, SC-009)

**Checkpoint**: all stories complete.

---

## Phase 10: Polish and cross-cutting

- [x] T070 [P] Write `specs/002-design-system-widgets/copy-review.md` in the style of `specs/001-foundation/copy-review.md`: every new Arabic and English string, its key, where it shows, with plural forms spelled out, for Osman's review before merge
- [x] T071 [P] Add per-component widget tests for the cross-cutting rules not yet covered, in `test/core/widgets/cross_cutting_test.dart`: every widget in Dark has no shadow and uses surface lift; every widget at 200% text on a 400-wide window has no overflow; every interactive widget is at least 48; every widget in English mirrors direction and flips only directional icons; under reduced motion no widget animation exceeds `duration-fast` (SC-004, SC-009, SC-010)
- [ ] T072 Perform the quickstart manual checks on web, macOS, one Android and one iOS target (story table, grayscale, QR scan with a phone, resize across the six boundary widths, the platform look switch) and record results with dates in `specs/002-design-system-widgets/evidence.md` (SC-001, SC-003, SC-005, SC-007, SC-008)
- [ ] T073 Compare each gallery section with the matching `docs/design-system/components/<Name>/preview.html` side by side and list any intended difference in `evidence.md` (SC-001)
- [ ] T074 [P] Update `CLAUDE.md` "Current state" (feature 002 built, next is feature 3) and the "Suggested feature order" note only after the PR is merged; update the Foundation comment in `lib/app/router/routes.dart` that says Phosphor "arrives with the design-system widgets"
- [x] T075 Run `flutter analyze --fatal-infos`, `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n` and `flutter test` from a clean checkout and confirm `git diff --exit-code` shows no stale generated files (CI parity)
- [ ] T076 Open the PR into `develop` titled "feat(002): design system widgets", description citing NFR-02, NFR-10, FR-AVL-01, FR-BKG-01 – FR-BKG-03, FR-CAT-01 – FR-CAT-03, FR-MYB-01, FR-MYB-02, FR-RPT-01, BR-06, BR-45 and US-06 – US-14, US-21, listing the BRD change and the Foundation test import-path edits

---

## Dependencies and execution order

- **Phase 1** first. T001 is the first commit of the PR; T002 before any widget task.
- **Phase 2** blocks every story. Inside it: T004 → T005; T007 → T008; T009 → T012; T010 → T013; T011 → T014; T015 and T016 any time after T002. T013 needs T012.
- **US1 (Phase 3)** needs Phase 2. It delivers the screen the other stories' section tasks register into.
- **US3, US2, US7** need Phase 2 only and are independent of each other: they can run in parallel.
- **US4** needs US7 (the sidebar lockup) and Phase 2. T050 needs T049; T051 needs T050; T052 needs T051.
- **US5** needs Phase 2 and US2's `StatusBadge` (the ticket shows it). `FacilityCard`, `StatTile` and the QR painter do not depend on each other.
- **US6** needs the widgets it checks (after US2, US3, US5, US7, and US4 for the guard run).
- **Polish** last; T072 and T073 need every gallery section.
- Within a story: tests first and failing, then ARB keys, then the widget, then the barrel export, then
  the gallery section. A gallery section task is the only task per story that edits
  `component_gallery_screen.dart`, so those registrations are done one story at a time to avoid
  conflicts.

## Parallel examples

```text
After Phase 2:
  Agent A: T024, T025 → T026 → T027, T028 → T029 → T030        (US3)
  Agent B: T031, T032, T033, T034 → T035 → T036, T038, T039 → T037 → T040 → T041   (US2)
  Agent C: T042 → T043 → T044 → T045                            (US7), then US4 (T046 – T054)

Inside US5 (all different files):
  T055, T056, T057, T058 together; then T060, T061, T063 together; T062 after T061.
```

## Implementation strategy

- **MVP**: Phase 1, Phase 2, US1 (gallery shell), US3 and US2. That gives a reviewable gallery with
  the booking vocabulary, buttons and fields, and every guard in place.
- **Then**: US7 and US4 (navigation swap, the one regression-risk piece, with the Foundation suite as
  the safety net), then US5, then US6 and Polish.
- **Order of commits** (research R18): BRD and setting (T001, T004, T005), primitives and constants
  (T006 – T016), US3, US2 and US7, US4, US5, gallery shell and sections, docs and copy review.
- Stop at any checkpoint to demo: each story is independently visible in the gallery.
- Do not start the PR (T076) until T075 is clean and Osman has reviewed `copy-review.md`.
