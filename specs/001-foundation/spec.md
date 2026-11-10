# Feature Specification: Foundation

**Feature Branch**: `001-foundation`

**Created**: 2026-11-10

**Status**: Draft

**Input**: User description: "Foundation: theme from tokens (light/dark), motion tokens (`SprintMotion`), fonts as assets, l10n (ar default, en), router, window size classes, adaptive shell (tab bar / rail / sidebar), adaptive primitives (`AdaptiveAppBar`, `AdaptiveDialog`, `AdaptiveSheet`, `AdaptiveSwitch`, `AdaptiveLoader`), seed data and fake repositories." (CLAUDE.md, suggested feature order, step 1), plus the CI that deploys `develop` to GitHub Pages.

**BRD coverage**: NFR-01, NFR-02, NFR-03, NFR-04, NFR-10, NFR-11, NFR-13, NFR-14, NFR-15; BR-01 – BR-03, BR-06 – BR-09, BR-12, BR-14, BR-30, BR-31, BR-35, BR-39 (settings and their defaults, §4); BR-15 – BR-16 (price tiers, seed data); BR-29 (`PaymentProvider` boundary); FR-AUTH-04 (shell is built on roles and scopes, with no real sign-in yet). Domain model: BRD §5. Design rules: `docs/design-system/README.md`, `adaptive.md`, `handoff.md`.

## User Scenarios & Testing *(mandatory)*

Foundation has no business feature of its own. It is the base that every later feature stands on, so its "users" are the person who opens the running app (Osman, Dr. Sara, the expert reviewers) and the developers and agents who build the next features. Each story below can be checked on its own.

### User Story 1 - Open a running, branded app shell on any device (Priority: P1)

Someone opens Sprint on a phone, a tablet, a foldable, a browser or a desktop window and lands on a branded app shell in Arabic, right-to-left. The shell shows the main navigation and a placeholder screen for each top-level destination. The navigation reshapes to fit the window: a bottom tab bar on narrow windows, a rail on medium windows, a sidebar on wide windows. Resizing the window, or folding and unfolding a foldable, switches the form live without losing the current destination or the scroll position.

**Why this priority**: Without a shell that runs on every target platform, no screen of any later feature can be built or shown. This is the smallest slice that is already demonstrable.

**Independent Test**: Run the app on each target platform and at each window size class. Confirm the right navigation form appears, destinations are reachable, and resizing keeps the current destination.

**Acceptance Scenarios**:

1. **Given** the app is launched with the system language set to anything, **When** the first screen appears, **Then** it is in Arabic, right-to-left, with the Sprint brand shown.
2. **Given** a window narrower than 600, **When** the shell renders, **Then** navigation is a bottom tab bar and content is a single column.
3. **Given** a window of 600 to 839, **When** the shell renders, **Then** navigation is a rail.
4. **Given** a window of 840 or wider, **When** the shell renders, **Then** navigation is a sidebar, and on 1200 or wider the content is centered up to the maximum content width.
5. **Given** the user is on the second destination of the shell, **When** the window is resized across a size-class boundary (or a foldable is folded or unfolded), **Then** the same destination stays selected and its scroll position is kept.
6. **Given** a foldable with a hinge or fold that splits the screen, **When** the shell shows a two-pane layout, **Then** no text or control sits on the hinge.
7. **Given** a destination that does not exist (a wrong deep link), **When** it is opened, **Then** the user sees a clear "not found" screen with a way back to the home destination.

---

### User Story 2 - Light and Dark look and language that follow the user (Priority: P1)

The app looks like the Sprint "Volt" brand in Light and in Dark. It follows the device setting by default, and the user can override it by hand. Arabic is the default language and English is available; switching language flips the layout direction and text. Colours, type, spacing, radius, sizes and motion durations all come from the design-system tokens. No screen defines its own colour or magic number.

**Why this priority**: Every later screen inherits this look. Getting the tokens wrong here means rework on every screen.

**Independent Test**: Toggle the device between Light and Dark, then override inside the app; switch language. Check a sample "token gallery" screen against `docs/design-system/tokens.json` and the previews.

**Acceptance Scenarios**:

1. **Given** the user has made no choice, **When** the device theme changes between Light and Dark, **Then** the app follows it at once.
2. **Given** the user picks Light, Dark or "follow device" in the appearance setting, **When** they relaunch the app, **Then** the choice is remembered.
3. **Given** Dark theme, **When** surfaces are shown, **Then** depth comes from lifted surface colours (`bg` → `surface` → `surface-raised`) and not from shadows.
4. **Given** the user switches to English, **When** the screen refreshes, **Then** all shell text is English, the layout direction is left-to-right, and only directional icons are mirrored.
5. **Given** any text in the shell, **When** the system text size is raised up to 200%, **Then** nothing is cut off or overlaps, and no text is smaller than 12.
6. **Given** a booking code, a phone number or an email in Arabic text, **When** it is shown, **Then** it keeps left-to-right order.
7. **Given** a price, a time and a number, **Then** they use Western digits (0–9) in both languages, 12-hour time ("5:00 م" / "5:00 PM") and currency as "120 ج.م" / "EGP 120".
8. **Given** the operating system asks to reduce motion, **When** any shell animation would run, **Then** it is skipped or reduced to a short fade.

---

### User Story 3 - Native-feeling controls on every platform (Priority: P2)

Navigation bars, dialogs, sheets, switches and loaders behave like the user's own platform (iOS-style on Apple devices, Material-style on Android, desktop-style on web and desktop) while brand elements look identical everywhere. A demo screen shows each adaptive control so the behaviour can be seen and tested.

**Why this priority**: It is a stated non-negotiable of the product ("don't make iOS look Material"), and later features use these controls constantly. It ranks below the shell and the look because the app is already usable without them.

**Independent Test**: Open the adaptive-controls demo screen on iOS, Android and web. Compare each control with the table in `adaptive.md`.

**Acceptance Scenarios**:

1. **Given** an Apple device, **When** an app bar is shown on a main screen, **Then** the title is centred, a large title is used on top-level screens and back is a chevron with edge-swipe.
2. **Given** an Android device, **When** an app bar is shown, **Then** the title is at the start and a back arrow is shown.
3. **Given** a confirmation is needed, **When** a dialog opens, **Then** it is an iOS-style alert on Apple devices, a Material dialog on Android, and a centred dialog on web and desktop where Enter confirms and Esc cancels.
4. **Given** a list of actions is needed, **When** the sheet opens, **Then** it is an action sheet on Apple devices, a bottom sheet on Android, and a menu on web and desktop, and Esc closes it on keyboard platforms.
5. **Given** a switch and a loader, **When** they are shown, **Then** each uses the platform's own look.
6. **Given** a screen that uses these controls, **Then** the screen code never names a platform; only the controls decide.

---

### User Story 4 - Realistic data and rules behind a swappable data layer (Priority: P2)

The app comes with realistic Egyptian placeholder data: Arabic facility names, EGP prices in both tiers, bookable units with capacities, opening hours, trainers, a few users with different roles, and sample bookings in each status. The app reads it through the same data boundaries a real backend will fill later. The behaviours the BRD calls settings (booking window, hold minutes, cancellation cutoff, refund percent, reminder lead time, booking mode and others) are read from settings with university → facility → unit inheritance, never hard-coded. The in-memory data layer enforces the same availability, conflict, pricing and permission rules the backend will, so later screens behave correctly.

**Why this priority**: Every later feature needs data and rules to show anything real, and it must be possible to replace the data source without touching screens. It ranks after the shell and the look because it can be developed in parallel.

**Independent Test**: With the app running, ask each data boundary for its data and check the values against the seed definitions. Change a setting at facility level and check that units without their own value pick it up while units with their own value keep it.

**Acceptance Scenarios**:

1. **Given** the seed data, **When** facilities are listed, **Then** they include paid, free and with-trainer types, owned by faculties and by a central unit, each with at least one bookable unit.
2. **Given** a setting defined at university level only, **When** it is read for a unit, **Then** the university value is returned; **Given** it is also defined at facility level, **Then** the facility value wins; **Given** it is also defined at unit level, **Then** the unit value wins.
3. **Given** the default settings, **When** they are read, **Then** they match BRD §4 (booking window 7 days, hold 10 minutes, cancellation cutoff 2 hours, refund 100%, reminder lead time 60 minutes, check-in opens 15 minutes before, and so on).
4. **Given** a unit whose booking mode is exclusive and a slot already booked, **When** a second booking is attempted for the same slot, **Then** it is refused.
5. **Given** a shared unit with capacity N, **When** N places are taken, **Then** the slot reports full and the next attempt is refused.
6. **Given** an internal-tier and an external-tier user, **When** the price of the same slot is requested, **Then** each gets its own tier price.
7. **Given** a payment is requested, **When** it goes through the payment boundary, **Then** the caller cannot tell whether a sandbox gateway or a fake answered.
8. **Given** a user without the role needed for an action, **When** the action is tried, **Then** the permission check refuses it, using the role × scope rules of BRD §6.

---

### User Story 5 - Every push to `develop` publishes the web build (Priority: P3)

When a change is merged into `develop`, an automatic job checks the project and publishes the web build to GitHub Pages, so Osman and Dr. Sara can open the latest version from a link. A change that fails the checks is not published.

**Why this priority**: It is what lets the owner and the supervisor review progress without a developer machine. It is the last piece because it needs the shell to exist.

**Independent Test**: Merge a small change into `develop` and open the Pages link. Then merge a deliberately failing change and confirm the previous build stays published.

**Acceptance Scenarios**:

1. **Given** a merge into `develop`, **When** the job finishes successfully, **Then** the Pages link shows the new build.
2. **Given** a merge whose checks fail, **When** the job runs, **Then** nothing new is published and the failure is visible on the pull request or commit.
3. **Given** the published site, **When** a deep link or a page refresh opens a non-root path, **Then** the app still loads correctly and shows the right destination.
4. **Given** a pull request into `develop` or `main`, **When** it is opened, **Then** the same checks run on it before merge.

---

### Edge Cases

- Window width changes by a pixel across 599/600, 839/840 or 1199/1200: exactly one navigation form shows, never two or none, and no flicker.
- A foldable is folded or unfolded in the middle of a text field entry: the typed text and the focus stay.
- Text scale 200% in a compact window: the tab bar labels stay readable and reachable (they may wrap or reduce to icons plus accessible names, but never overlap).
- Screen-reader is on: every shell destination and control has an Arabic (or English) spoken label; state is never carried by colour alone.
- A setting is missing at all three levels: the app falls back to the BRD default and does not crash.
- An invalid setting value (negative minutes, refund over 100%): it is rejected with a clear message at the data boundary.
- Fonts fail to load on first paint on the web: text appears in a fallback with the same line height, and swaps without shifting the layout noticeably.
- A deep link is opened on the web Pages build under a sub-path: it resolves under that sub-path.
- The user changes language while a dialog or sheet is open: it closes or re-renders in the new language without a mixed-direction state.

## Requirements *(mandatory)*

### Functional Requirements

**Shell and navigation** (NFR-01, FR-AUTH-04)

- **FR-001**: The app MUST run from one codebase on Android, iOS (phone and iPad), foldables, web and desktop.
- **FR-002**: The app MUST choose its layout from the window width only, using four size classes: compact below 600, medium 600–839, expanded 840–1199, large 1200 and above. It MUST NOT depend on device names or models.
- **FR-003**: The shell MUST show a bottom tab bar in compact, a rail in medium, and a sidebar in expanded and large; content in large MUST be centred and limited to the maximum content width token.
- **FR-004**: The shell MUST provide placeholder destinations for the top-level areas a guest and a booker will use (see Assumptions), each reachable by URL, so later features replace placeholders without changing navigation.
- **FR-005**: The shell MUST keep the selected destination, the in-progress input and the scroll position when the size class changes or a foldable folds or unfolds.
- **FR-006**: On a foldable with a hinge or fold that splits the screen, two-pane layouts MUST avoid placing text or controls on the hinge.
- **FR-007**: Navigation MUST be built from the user's roles and scopes (a guest has none), so later role-specific destinations appear by data rather than by new navigation code.
- **FR-008**: An unknown route MUST show a "not found" screen with a way back.

**Look, language and accessibility** (NFR-02, NFR-04, NFR-10)

- **FR-009**: All colours, type styles, spacing, radius, sizes, shadows and motion durations and curves MUST come from the design tokens, named exactly as in `docs/design-system/tokens.json`. Screens MUST NOT use raw colour values or unnamed numbers.
- **FR-010**: The app MUST provide Light and Dark themes that follow the device setting and can be overridden by hand, and the override MUST persist between launches.
- **FR-011**: In Dark, depth MUST come from surface lift (`bg`, `surface`, `surface-raised`) and not from shadows.
- **FR-012**: The "Volt" lime MUST be used only as a fill with its on-colour text, never as text, a line or an icon on a light surface; QR modules MUST always be dark on white in both themes.
- **FR-013**: Arabic (right-to-left) MUST be the default language and English (left-to-right) the second; every user-facing string MUST live in translation files, with none written in the screens.
- **FR-014**: Layout MUST use direction-aware spacing and alignment; only directional icons MUST mirror; booking codes, phone numbers and emails MUST keep left-to-right order inside Arabic text.
- **FR-015**: Copy MUST follow the product rules: light Egyptian dialect, no imperative verbs in UI (buttons are verbal nouns), Western digits in both languages, 12-hour time, "120 ج.م" / "EGP 120". Dates and times MUST be shown in Cairo time (NFR-03).
- **FR-016**: Text MUST use the fonts and styles in the token list: Alexandria for headings and buttons; Cairo for body, labels and every number; IBM Plex Mono for booking codes. Fonts MUST ship inside the app. Every style MUST carry its explicit line height. The minimum size MUST be 12 and text MUST scale up to 200%.
- **FR-017**: Every interactive element MUST have a touch target of at least 48 and a visible keyboard focus on keyboard platforms; every state MUST carry a word or an icon in addition to colour; every shell control MUST have a meaningful screen-reader label in the current language.
- **FR-018**: Motion MUST be timed by the motion tokens, MUST respect the platform's page, sheet and back-gesture timing, and MUST be skipped or reduced to a short fade when the system asks to reduce motion. Content loading MUST be shown with skeletons rather than spinners.

**Adaptive controls** (NFR-01, `adaptive.md`)

- **FR-019**: The app MUST provide one adaptive version each of app bar, dialog, sheet, switch and loader, whose behaviour follows the platform as defined in `adaptive.md`, and screens MUST use them without checking the platform.
- **FR-020**: A demo screen MUST show each adaptive control and each theme and language, so reviewers can check them on a real device.

**Data layer and settings** (NFR-11, NFR-13, BRD §4, §5)

- **FR-021**: Every data source MUST sit behind a boundary (repository interface); this feature MUST deliver in-memory implementations filled from seed data for: owning units, facilities, bookable units, operating hours and closures, prices, trainers and their availability, users and role assignments, verification state, bookings, payments, refunds, attendance, notifications, assets and damage reports, offers, settings and the audit log.
- **FR-022**: Seed data MUST be realistic: Arabic facility and unit names, prices in EGP for both tiers, 12-hour times, capacities, at least one facility of each type (paid, free, with trainer), at least two owning units (a faculty and a central unit), users covering every role, and bookings covering every status in BRD §5.
- **FR-023**: Every value the BRD marks as a setting MUST be read through a settings boundary with university → facility → unit inheritance, with the BRD default as the final fallback. No such value may be written in a screen or in other logic.
- **FR-024**: The in-memory data layer MUST enforce the booking, availability, conflict, hold, pricing-tier, cancellation and refund rules of BRD §4, and the permission rules (role × scope) of BRD §6, so screens that call it behave as the real backend will.
- **FR-025**: Payment MUST go through a payment boundary with a sandbox or fake implementation; the booking code MUST NOT know which one answers (BR-29).
- **FR-026**: Replacing the in-memory data layer with a real backend MUST NOT require changes to any screen or to the app's presentation code.

**Delivery** (NFR-14, NFR-15)

- **FR-027**: A change merged into `develop` MUST be checked automatically and, if the checks pass, published to GitHub Pages; a failing change MUST NOT be published.
- **FR-028**: Pull requests into `develop` and `main` MUST run the same checks before merge.
- **FR-029**: The published web app MUST work when opened on a deep link or refreshed on any route.
- **FR-030**: The project MUST contain a written project constitution in `.specify/memory/constitution.md`, derived from CLAUDE.md, before the plan step.

### Key Entities

Foundation implements the shapes of BRD §5; it does not add new business concepts. The ones that matter most to it:

- **OwningUnit, Facility, BookableUnit**: the hierarchy that seed data fills and settings inherit along (BRD §5, BR-01 – BR-03).
- **Setting**: a key, a value and a scope (university, facility or unit); resolves from the closest scope outward to the BRD default.
- **User, RoleAssignment**: who is using the app and with which role at which scope; drives which destinations the shell shows.
- **Booking, Payment, Refund**: seeded in every status so later screens have real states to show.
- **Token set**: the named design values (colour in two themes, type, spacing, radius, size, shadow, breakpoint, motion) that every screen draws from.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The app starts and shows the shell on all five target families (Android, iOS, web, macOS or Windows desktop, and a tablet) with no manual step beyond installing or opening it.
- **SC-002**: At every width from 320 to 1920, exactly one navigation form is visible, and it is the one defined for that width in 100% of tested widths, including the six boundary widths (599, 600, 839, 840, 1199, 1200).
- **SC-003**: Resizing across a boundary, or folding and unfolding, keeps the destination and scroll position in 100% of tested transitions.
- **SC-004**: 100% of colours, spacing, radius, size and motion values used by shell and demo screens trace to a named token; a repository search for raw colour values or numeric style literals in screen code finds none.
- **SC-005**: Every user-facing string in the shell and demo screens exists in both Arabic and English; switching language changes 100% of them and flips direction with no leftover mirrored or unmirrored element.
- **SC-006**: At 200% text size, no text is clipped or overlapping on the shell and demo screens at compact width.
- **SC-007**: A reviewer can tell Apple and Android behaviour apart on each adaptive control and finds it matches `adaptive.md` for all five controls.
- **SC-008**: Changing a setting at university, facility or unit level changes the value read at the unit in the expected order in 100% of tested inheritance cases, with no setting value found outside the settings boundary.
- **SC-009**: A conflicting booking is refused in 100% of tested cases (exclusive double booking, shared over capacity, same user overlapping bookings), and a user without the right role is refused in 100% of tested permission cases.
- **SC-010**: After a passing merge into `develop`, the new web build is live within 10 minutes; a failing merge leaves the live build unchanged.
- **SC-011**: The first screen is interactive within 3 seconds on a mid-range phone on 4G for the web build and within 2 seconds on a typical device for the installed builds.

## Out of scope

Foundation is UI-only and prepares the ground. These are explicitly not part of it:

- **Backend**: no Supabase, no Firebase, no server, no real database, no real push, no real file upload. All data is in memory and resets on restart.
- **Real payments**: no gateway account or call; only the payment boundary and a fake or sandbox answer. The university's e-collection platform is P2.
- **SMS and any paid service**: not used; email and push are only represented as in-app seed notifications.
- **Real sign-in, registration, email confirmation and password reset** (US-01 – US-05): the shell supports roles in data, and a demo user switcher MAY exist for reviewers, but no real authentication.
- **Design-system widgets** (`SprintButton`, `SprintTextField`, `SlotChip`, `DayStrip`, `FacilityCard`, `StatusBadge`, `BookingTicket`, `AppNavigation` as a styled component, `StatTile`): feature 2. Foundation delivers only the navigation shell and the five adaptive controls, using plain tokens.
- **Any business screen**: catalogue, availability, booking, checkout, my bookings, profile, trainer, admin, reports, assets, offers. They stay placeholders.
- **Lottie moments and the final animation polish**: feature 11. Only the motion tokens and code-timed motion are here.
- **Real facility, price and trainer data from Dr. Sara**: seed data is a placeholder until it arrives.
- **Figma sync**: the repository is the source of truth; the Figma file follows later.
- **Store release, signing and publishing** to Google Play, the App Store or any store.
- **Anything from P2**: university system integration, SMS, e-collection payment.

## Assumptions

- Foundation depends on the design system documents already in `docs/design-system/` and on the bundled fonts in `assets/fonts` (Alexandria 600/700, Cairo 400–700, IBM Plex Mono). No font is added or removed by this feature.
- The technology stack and architecture are those fixed in `CLAUDE.md` (Flutter, Riverpod with codegen, Freezed, GoRouter, feature-first Clean Architecture, repository interfaces). This spec states outcomes; the how belongs to the plan.
- **Top-level destinations** in the shell, from BRD FR-CAT-03, FR-MYB-02 and FR-MYB-03: Home, Facilities, My Bookings, Profile. Role-specific destinations (trainer, admin) appear later by role data. If Osman prefers different names or a different count, the clarify step decides.
- **Seed data size**: about 6 facilities (for example a swimming pool, a football pitch, a gym, a tennis court, a free multi-purpose hall, and a training course), across 3 owning units (two faculties and one central unit), about 15 bookable units, 10 users (every role at least once, both tiers), and 20 bookings spread across all statuses. Names and prices are placeholders.
- **Persistence**: the only things saved across launches are the theme choice and the language. Seed data resets on every start.
- **Demo role switcher**: a small reviewer-only control to view the app as another seeded user is allowed as a way to see role-based navigation; whether it stays in the defense build is decided later.
- The GitHub Pages site is served from the public repository `sprint-app` (a public repo needs no paid plan). The published address is under a sub-path, so routing must work under it.
- Checks that gate publishing are the project's static analysis and automated tests; the specific tools are a plan decision.
- Time handling uses Cairo time for display and UTC for storage (NFR-03), even though the data is in memory.
- Windows and Linux desktop builds are supported by the code but only macOS and web are checked on a developer machine in this feature; the others are checked by building, not by hand.
