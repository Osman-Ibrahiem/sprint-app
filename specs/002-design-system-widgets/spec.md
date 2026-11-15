# Feature Specification: Design System Widgets

**Feature Branch**: `claude/002-design-system-widgets-2bd161` (spec directory `002-design-system-widgets`)

**Created**: 2026-11-15

**Status**: Draft

**Input**: User description: "Design system widgets: `SprintButton`, `SprintTextField`, `SlotChip`, `DayStrip`, `FacilityCard`, `StatusBadge`, `BookingTicket`, `AppNavigation`, `StatTile`, matching each component README (props, states, variants, rules)." (CLAUDE.md, suggested feature order, step 2). `AppNavigation` replaces the Foundation's plain tab bar, rail and sidebar. The spec also decides whether `SprintLogo` and `Skeleton` belong here (see Scope decisions).

**BRD coverage**: NFR-02 (language, Light and Dark, no hard-coded text), NFR-10 (contrast, 48dp targets, screen reader); NFR-01 (one codebase, every platform); NFR-03 (Cairo time and 12-hour display, used by the day and time widgets). The widgets are the building blocks for the stories that use them later, and each is shaped by how that story needs it: `SlotChip` and `DayStrip` (FR-AVL-01, FR-BKG-01 – FR-BKG-03, US-06 – US-09), `StatusBadge` (BR statuses in BRD §5, FR-MYB-02, US-14), `FacilityCard` (FR-CAT-01, FR-CAT-02, FR-CAT-03, US-01, US-11), `BookingTicket` (FR-MYB-01, FR-MYB-02, US-12, US-13), `SprintButton` and `SprintTextField` (FR-AUTH-01 – FR-AUTH-04, FR-BKG-04, FR-PAY-01, US-10), `AppNavigation` (FR-AUTH-04, FR-CAT-03; roles in BRD §6), `StatTile` (FR-RPT-01, FR-RPT-02, US-21). Business rules the widgets only display and never decide: BR-06 (booking window), BR-12 (hold), BR-15 – BR-17 (price tiers), BR-39 (cancellation cutoff). Design rules: `docs/design-system/README.md`, `adaptive.md`, `handoff.md`, and `docs/design-system/components/<Name>/README.md` with `preview.html`. Foundation: `specs/001-foundation/`.

## Scope decisions

These were decided in this specification so that the plan does not have to guess.

- **`SprintLogo`: in scope.** `handoff.md` lists it as a Flutter widget with the Figma `Logo` variants, the three SVG files already exist in `docs/design-system/logo/`, and `AppNavigation`'s sidebar must show the "سبرنت" lockup at its top, which the Foundation drew as plain text with a comment that the logo widget is feature 2. It is small (five fixed variants, no states) and it is a design-system component, so it does not belong in a business feature.
- **`Skeleton`: not a new widget.** The Foundation already delivers the skeleton primitive (a block on `surface-sunken` that pulses once per `duration-pulse` and holds still under reduced motion). This feature does not rebuild or redesign it. It adds what the primitive lacked: a loading form for the three content widgets whose loading shape is part of their design (`FacilityCard`, `BookingTicket`, `StatTile`), each built from the existing primitive so the placeholder has the shape of the content that will replace it. `SlotChip`, `DayStrip`, `StatusBadge`, `SprintButton` and `SprintTextField` need no skeleton form (a button shows its own loading state; the others are small enough that a list of them is the consumer's skeleton).
- **Presentation only.** Every widget takes plain values (text, numbers, times, enums, callbacks). None reads a repository, a setting or the current user; the screens of later features read those and pass the values in. This keeps the widgets reusable and testable alone and keeps Principles III and IV intact.

## Clarifications

### Session 2026-11-15

- Q: Is the few-left threshold a new setting added in this feature? → A: Yes. `fewLeftThreshold` (default 2, university → facility → unit inheritance) is added to BRD §4 and to the settings registry here, and the gallery reads it from settings.

- Q: Does the component gallery stay in the defense build? → A: Yes. It stays reachable in the defense build behind the same release switch as the Foundation's demo screen, so it can still be removed from a store release later.

- Q: Is the ticket's screen-brightness boost built here or later? → A: Later. `BookingTicket` only exposes the `today` state; feature 7 (My bookings), which owns the screen and its lifecycle, raises and restores the brightness.
- Q: Are Phosphor icons adopted in the widgets now? → A: Yes. Regular weight everywhere, Fill for the active navigation item only; icons are passed in as data so a later swap is easy.

All four guesses that needed Osman's decision are now settled; the remaining Assumptions are low-impact defaults.

## User Scenarios & Testing *(mandatory)*

This feature has no business flow. Its "users" are the reviewers who see the widgets (Osman, Dr. Sara, the expert reviewers at the defense) and the developers and agents who build the screens of features 3 to 11 from them. Each story below can be checked on its own.

### User Story 1 - See every widget, in every state, on one reviewable screen (Priority: P1)

A reviewer opens the app's demo area and finds a component gallery. For each of the ten components (`SprintButton`, `SprintTextField`, `SlotChip`, `DayStrip`, `FacilityCard`, `StatusBadge`, `BookingTicket`, `AppNavigation`, `StatTile`, `SprintLogo`) it shows every variant, size and state named in the component's README, with realistic Egyptian sample content (Arabic facility names, EGP prices, 12-hour times). The reviewer can flip Light and Dark, Arabic and English, raise the text size to 200%, turn on reduced motion, and view the platform look (Apple, Android, desktop or web) of the widgets that differ, all without leaving the screen or owning three devices.

**Why this priority**: Nothing in this feature is visible any other way, because no business screen uses the widgets yet. The gallery is how Osman checks the work against the design system, how Dr. Sara sees the product taking shape, and how every later regression is caught. It is the smallest slice that proves the feature.

**Independent Test**: Open the gallery on a phone-width window and a desktop-width window. For each component, compare each shown state with its README and `preview.html`. Switch theme, language, text size, reduced motion and platform look and confirm nothing breaks.

**Acceptance Scenarios**:

1. **Given** the gallery, **When** it opens, **Then** every component has a section showing every variant and state its README names, and no state is missing.
2. **Given** any widget in the gallery, **When** the theme switches between Light and Dark, **Then** its colours change to the other theme's token values, with depth from surface lift in Dark and no shadow on cards.
3. **Given** the gallery in Arabic, **When** the language switches to English, **Then** all visible text is English, the layout mirrors, and only directional icons flip.
4. **Given** the gallery, **When** the text size is raised to 200%, **Then** no widget clips or overlaps its text, and every touch target is still at least 48.
5. **Given** the gallery, **When** the platform look is switched among Apple, Android and desktop or web, **Then** `SprintButton` press feedback and `AppNavigation` form change to that platform's behaviour while the brand look stays the same.
6. **Given** the gallery, **Then** it is reached the same way as the Foundation's demo screen and is hidden by the same release switch, so it can be removed from a release build without touching a widget.

---

### User Story 2 - Read availability in one second (Priority: P1)

`DayStrip`, `SlotChip` and `StatusBadge` are the booking vocabulary. A booker must see "is there room, and when?" without reading detail (design principle 1). The day strip shows the days the booking window allows, today first, with a green dot on days that have room. Each slot chip shows its time and, under it, a word for its state: available (with the remaining places on a shared unit), selected, few left, full, past. A status badge shows a booking's state with an icon and a word. None of them depends on colour alone.

**Why this priority**: These are the most used and most judged components (the thesis problem is availability and fairness), and later features 5 and 7 cannot start without them.

**Independent Test**: In the gallery, set a day strip and a grid of chips to each state. Read each one aloud with a screen reader and look at each one in grayscale; every state must still be distinguishable.

**Acceptance Scenarios**:

1. **Given** a day strip with the booking window of 7 days, **When** it renders, **Then** it shows exactly 7 days starting today, in reading order (today at the start: right in Arabic, left in English), with today labelled "النهارده" in `primary` and no past day and no day beyond the window.
2. **Given** a day with room, **When** it renders, **Then** it shows a `success` dot under the number and tells a screen reader "فيه أماكن"; **Given** a closed day, **Then** it is shown in `ink-disabled`, cannot be pressed, and a screen reader says "مقفول".
3. **Given** no selected day is supplied, **When** the strip renders, **Then** the first day with room is selected.
4. **Given** a shared unit with 5 places left and a threshold of 2, **When** the chip renders, **Then** it is `available` and says "5 أماكن"; **Given** 2 or fewer left, **Then** it is `fewLeft`, filled `volt` with `on-volt` text, and says "فاضل 2" or the matching Arabic wording; **Given** an exclusive unit, **Then** it shows no number.
5. **Given** a `full` or `past` chip, **When** a user presses it, **Then** nothing happens, and a screen reader says why ("مكتمل" or "فات").
6. **Given** a chip is pressed on iOS or Android, **When** it becomes selected, **Then** a light haptic fires; on web and desktop none fires.
7. **Given** a selected chip, **When** its state changes to `full` while on screen, **Then** the colour and the word change together within `duration-base` (or a short fade under reduced motion).
8. **Given** each of the six booking statuses (and the verification and damage-report statuses), **When** a badge renders, **Then** it carries both its icon and its word, and `NO_SHOW` and `EXPIRED` are neutral (`ink-muted` on `surface-sunken`).

---

### User Story 3 - Actions and input with one identity everywhere (Priority: P1)

`SprintButton` and `SprintTextField` are used on every form and every flow (sign-in, payment, cancel, search). A button has five variants and two sizes, shows a loading state, and gives platform-correct press feedback. A text field has its label always above it, a helper or an error below, and types for email, phone, national ID, password and search that keep their characters left-to-right inside the Arabic layout.

**Why this priority**: Every later screen needs them, and they carry the most rules (one primary per screen, no volt as an action fill, error wording, LTR isolation).

**Independent Test**: In the gallery, tap each button variant on each platform look; focus each with a keyboard; type an email in an Arabic layout; trigger an error.

**Acceptance Scenarios**:

1. **Given** a button with a label, a variant (`primary`, `secondary`, `tonal`, `ghost`, `danger`) and a size (`md`, `sm`), **When** it renders, **Then** it uses that variant's colours from the tokens, `md` is `control-height` tall, and `sm` is `control-height-sm` tall with a touch area of 48.
2. **Given** `loading` is on, **When** it renders, **Then** the icon is replaced by the platform loader, the label becomes the in-progress wording supplied by the caller, and pressing it does nothing.
3. **Given** a label that carries a price ("تأكيد الحجز · 120 ج.م"), **When** it renders, **Then** it shows in full, with the number in Western digits and the code or price kept left-to-right.
4. **Given** iOS, **When** a button is pressed, **Then** its fill fades to 70% with no ripple; **Given** Android, **Then** a ripple in `primary-pressed` shows; **Given** web or desktop, **Then** hover shows `primary-hover`, a keyboard focus shows the focus ring, and the pointer is a hand.
5. **Given** a field with a label, **When** it renders, **Then** the label is always above it (never floating) and the placeholder is only an example of valid input.
6. **Given** a field in the error state, **When** it renders, **Then** it shows a 2px `danger` border on `danger-soft`, an icon and the message below in place of the helper, and a screen reader reads the message.
7. **Given** the `email`, `phone`, `nationalId` or `password` type in Arabic, **When** the user types, **Then** the characters run left-to-right and the text aligns to the start of the Arabic line.
8. **Given** the `password` type, **When** the user presses "إظهار", **Then** the password shows and the control says "إخفاء" and changes back on press, with a 48 touch target.
9. **Given** the `search` type, **When** it renders, **Then** it is a pill on `surface-sunken` with a search icon.

---

### User Story 4 - One navigation component that keeps every Foundation guarantee (Priority: P1)

`AppNavigation` replaces the Foundation's plain tab bar, rail and sidebar with the designed component. It is one component with three forms: tab bar below 600, rail from 600 to 839, sidebar from 840 up, with the sidebar topped by the Sprint lockup. The active destination, the badges and the platform look follow the component README. Everything the Foundation promised still holds.

**Why this priority**: Navigation is on every screen. It is also the one widget that replaces working code, so it carries regression risk, and the Foundation's guarantees (one form per width, state kept across resize and fold, 48dp targets, Arabic labels) must survive the swap.

**Independent Test**: Run the Foundation's navigation tests unchanged against the new component, then run the gallery at the six boundary widths.

**Acceptance Scenarios**:

1. **Given** any width from 320 to 1920, **When** the shell renders, **Then** exactly one navigation form shows and it is the one defined for that width, including at 599, 600, 839, 840, 1199 and 1200.
2. **Given** the user is on the third destination, **When** the window crosses a size boundary or a foldable folds or unfolds, **Then** the same destination stays selected and its scroll position and typed text are kept.
3. **Given** the compact form, **When** it renders, **Then** the active item shows a Fill icon and its label in `primary`; **Given** the rail, **Then** the active item sits in a `primary-soft` pill with `on-primary-soft` text; **Given** the sidebar, **Then** the active row is `primary-soft` with `on-primary-soft` text and the lockup is at the top.
4. **Given** iOS, **When** the tab bar renders, **Then** it is translucent with a blur over the content and has no pill behind the icon; **Given** Android, **Then** it is solid `surface`.
5. **Given** a destination with a badge count, **When** it renders, **Then** the count shows in `danger` with `on-danger` text and a screen reader says the number with the destination ("الإشعارات، 3 غير مقروءة").
6. **Given** more than five destinations in the compact form, **When** it renders, **Then** four show and a fifth, "المزيد", opens a menu with the rest.
7. **Given** a keyboard platform, **When** the user presses a number key 1 to 5, **Then** that destination opens; **Given** a hover or a keyboard focus, **Then** hover shows `surface-sunken` and focus shows the focus ring.
8. **Given** text at 200%, **When** the tab bar renders, **Then** labels may drop to icon plus spoken label as the Foundation already does, but nothing overlaps and every item stays 48 or taller.
9. **Given** the language switches between Arabic and English, **When** the rail or sidebar renders, **Then** it sits on the start edge (right in Arabic, left in English).
10. **Given** the guest, booker and trainer destination lists the Foundation supports, **When** each is passed in, **Then** each renders without any change to navigation code.

---

### User Story 5 - Cards that show a facility, a booking and a number at a glance (Priority: P2)

`FacilityCard` shows a facility in discovery and search; `BookingTicket` shows a confirmed booking with its QR and code; `StatTile` shows a KPI in the admin dashboard. Each is the whole visual unit its later screen is built around, and each has a loading form shaped like itself.

**Why this priority**: They are the most visible components in the defense, and features 4, 6, 7 and 10 depend on them, but they are heavier than the booking vocabulary and rank after it.

**Independent Test**: In the gallery, render each card in every state with long Arabic names, in both themes, both languages, at 200% text, and in its loading form.

**Acceptance Scenarios**:

1. **Given** a facility of each type (paid, free, with trainer), **When** `FacilityCard` renders in the vertical layout, **Then** it shows the photo area, up to three tags, the name, the owning unit and unit count, today's availability and the price, and the whole card is one pressable target with no button inside.
2. **Given** no photo has arrived, **When** the card renders, **Then** the photo area is `surface-sunken` with the words "صورة المنشأة", not a stock image.
3. **Given** today's availability is plenty, few or none, **When** the card renders, **Then** it shows a `success` check, a `warning` clock, or `ink-muted` "مفيش مواعيد النهارده", each with its word.
4. **Given** an internal-tier user, **When** the card renders, **Then** it shows the one price that user will pay and whom it is for ("سعر الطلاب والعاملين"); **Given** a guest, **Then** it shows both prices; **Given** a free facility, **Then** it shows "مجاني" and no price.
5. **Given** an offer is on, **When** the card renders, **Then** a `volt` tag with `on-volt` text shows and the old price is struck through in `ink-muted`.
6. **Given** the compact search list, **When** the horizontal layout renders, **Then** the photo is on the start side at a width of 112.
7. **Given** an upcoming booking, **When** `BookingTicket` renders, **Then** it shows the status badge, facility, unit, trainer (if any), a date and time such as "التلات 10 نوفمبر · 5:00 – 6:00 م", a time band in `volt` with `on-volt` text, a dashed divider with two half-circle notches, the QR, the booking code, and the paid and cancel-until rows.
8. **Given** the booking code, **When** the ticket renders, **Then** the code is left-to-right, in the `code` style, and a press copies it and tells the user it was copied.
9. **Given** the QR, **When** it renders in Light or Dark, **Then** it is dark modules on white (`qr-ink` on `qr-ground`) with a quiet margin, and it encodes the signed token passed in, never the raw booking number.
10. **Given** a past or cancelled booking, **When** the ticket renders, **Then** the QR is hidden and the status shows in its place, and the time band is `surface-sunken` with `ink-muted` text.
11. **Given** cancellation is not available, **When** the ticket renders, **Then** the row says "الإلغاء مش متاح".
12. **Given** a KPI, **When** `StatTile` renders, **Then** it shows the label and period, the value in `number-lg` with a smaller unit, and the change with an arrow for direction, a colour for good or bad (decided by whether higher is better), and a sentence saying both ("زيادة 12% عن الأسبوع اللي فات").
13. **Given** a value of 1250000 EGP and a rate of 73.4%, **When** the tile renders, **Then** it shows "1,250,000 ج.م" and "73%", with no fractions on rates.
14. **Given** the loading form of each card, **When** it renders, **Then** it has the same outer shape as the loaded card, pulses at `duration-pulse`, is silent to a screen reader, and holds still under reduced motion.

---

### User Story 6 - Developers build screens from the widgets without re-deciding design (Priority: P2)

A developer or agent building feature 3 to 11 imports a widget, passes plain values, and gets the correct look, states, accessibility and platform behaviour. The property names match the table in `handoff.md` so Figma and code line up. Nothing in a widget names a platform, reads data, or holds a raw colour or number.

**Why this priority**: It protects every later feature from drift, but it has no visible outcome of its own, so it ranks below the visible stories.

**Independent Test**: A repository search of widget code for raw colour values, unnamed numeric style literals, platform checks and user-facing string literals finds none; each widget builds with plain values and no data layer in a test.

**Acceptance Scenarios**:

1. **Given** the property table in `handoff.md`, **When** a widget is inspected, **Then** it exposes the same properties under the same names (for example `variant`, `size`, `state`, `status`, `layout`, `form`, `trend`).
2. **Given** a widget, **When** it is built in a test with plain values and no repository, no settings and no user, **Then** it renders correctly.
3. **Given** a screen that uses a widget, **Then** the screen never names a platform; only the widget (through the adaptive layer) decides platform behaviour.
4. **Given** the existing Foundation tests, **When** this feature is complete, **Then** they all still pass.

---

### User Story 7 - The Sprint logo, correct everywhere (Priority: P3)

`SprintLogo` shows the brand in five fixed variants (the mark, the primary tile, the ink tile, and the Arabic and English lockups) from the existing SVG files, with fixed colours in both themes and no way to misuse it.

**Why this priority**: It is small, but the sidebar needs it and it is the first thing a reviewer sees.

**Independent Test**: In the gallery, view every variant in Light and Dark on every surface, and in Arabic and English.

**Acceptance Scenarios**:

1. **Given** each variant, **When** it renders, **Then** it matches the files in `docs/design-system/logo/` and the lockup rules (tile, then "سبرنت" or "Sprint" in Cairo 700 at the `title` style, gap `space-3`, tile on the start side).
2. **Given** Dark, **When** the tile renders, **Then** its colours are unchanged from Light (they are fixed and do not follow `primary`).
3. **Given** the bare mark on a light surface, **When** a screen asks for it, **Then** the widget does not render it as a bare `volt` bolt on the light surface (it falls back to the primary tile).
4. **Given** the Arabic layout, **When** the mark renders, **Then** it is never mirrored; **Given** the lockup, **Then** only the tile's side flips with the reading direction.
5. **Given** any size below 16, **When** requested, **Then** it is raised to 16.

---

### Edge Cases

- **Text scale 200%**: every widget grows or wraps; none clips or overlaps. `SlotChip` and `DayStrip` grow taller; the tab bar drops labels as the Foundation does; `StatTile` and `FacilityCard` wrap; minimum text stays 12.
- **Long Arabic names** (a facility name or an owning unit that is two lines or more, a trainer with a long name): wrap within the card or ticket, never ellipsis a name that identifies the booking, never overflow into a neighbour.
- **RTL and LTR**: every widget uses direction-aware spacing; directional icons only flip; the code, phone, email and national ID keep left-to-right order inside Arabic text.
- **Dark**: cards lift by surface colour and carry no shadow; `volt` stays a fill; the QR stays dark on white; the ticket notches match the page background in both themes.
- **Reduced motion**: selection, state change, ticket reveal and skeleton pulse reduce to a short fade or hold still, all timed from the motion tokens.
- **Platform differences**: press feedback, tab bar surface, haptics and shortcuts differ per platform as in `adaptive.md`; an unknown platform behaves as web or desktop.
- **Data edge values**: zero remaining places, remaining equal to the threshold, a window of 1 day or of 30 days, a facility with no unit, no trainer, no photo, no offer, a delta of exactly zero or no previous period, a badge count of 0 (hidden) or above 99.
- **State change while on screen**: a selected chip that becomes `full`, a booking that changes status, a count that changes: the new state replaces the old with colour and word together, and a screen reader is told.
- **Press and focus together**: a pressed, hovered and focused widget shows one coherent state, never two overlapping highlights.
- **Missing or failed pieces**: a QR token that is empty shows a clear "QR غير متاح" state rather than a blank or wrong code; an icon or font that has not loaded falls back without changing the layout noticeably.
- **A disabled control that a user might expect to work**: a disabled button still announces its label and that it is unavailable, and the caller may keep it enabled and explain the reason instead (README guidance).
- **Overflowing destinations**: more than five destinations on compact (admin) use the "المزيد" menu; fewer than two destinations are a developer error shown in debug builds only.

## Requirements *(mandatory)*

### Functional Requirements

**Cross-cutting rules for every widget** (NFR-01, NFR-02, NFR-10, Constitution II and V)

- **FR-001**: Every widget MUST take its colours, type, spacing, radius, size, shadow and motion from the design tokens by their `tokens.json` names. No widget MAY contain a raw colour value or an unnamed numeric style value.
- **FR-002**: Every user-facing string, including the words under chips, status words, "إظهار" / "إخفاء", "المزيد", "صورة المنشأة", the "copied" notice and every screen-reader label, MUST exist in the Arabic and English translation files and none in a widget. Copy MUST follow the product rules: light Egyptian dialect, no imperative verbs, Western digits, 12-hour time, "120 ج.م" / "EGP 120", Cairo time (NFR-03).
- **FR-003**: Every widget MUST render correctly in Light and Dark. In Dark, depth MUST come from surface lift and not from shadow. `volt` MUST be used only as a fill with `on-volt` text.
- **FR-004**: Every widget MUST use direction-aware spacing and alignment, flip only directional icons, and keep codes, phone numbers, emails and national IDs left-to-right inside Arabic text.
- **FR-005**: Every interactive element MUST have a touch target of at least 48 and, on keyboard platforms, a visible focus ring and a hover state; every state MUST carry a word or an icon in addition to colour.
- **FR-006**: Every widget MUST give a screen reader a meaningful label in the current language that reads the widget as a sentence ("الساعة 6 مساءً، فاضل مكان واحد") and says its state and why it cannot be used when it cannot.
- **FR-007**: Every widget MUST support text scaling to 200% without clipping or overlap, with no text under 12, and every text style MUST carry its token line height.
- **FR-008**: Every animation MUST be timed by the motion tokens and MUST be skipped or reduced to a short fade when the system asks to reduce motion.
- **FR-009**: Widgets MUST NOT check the platform. Platform-specific behaviour (press feedback, haptics, navigation surface) MUST come from the adaptive layer only.
- **FR-010**: Widgets MUST be presentation-only: they take plain values and callbacks, and MUST NOT read a repository, a setting or the current user. Values that the BRD marks as settings (`bookingWindowDays`, the few-left threshold, the cancellation cutoff, the reminder lead time) MUST reach a widget as inputs and MUST NOT be defaulted inside it (Constitution III).
- **FR-011**: Each widget MUST expose the properties named for it in the component table of `handoff.md`, under those names, so a Code Connect mapping to Figma is direct.
- **FR-012**: Icons MUST follow the design system (Phosphor, Regular weight, Fill for the active navigation item only, sizes `icon-sm`, `icon-md`, `icon-lg`), and MUST NOT be `volt` on a light surface.

**SprintButton** (FR-AUTH-01, FR-BKG-04, FR-PAY-01, US-10)

- **FR-013**: `SprintButton` MUST support the variants `primary`, `secondary`, `tonal`, `ghost` and `danger` with the colours defined in the Button README, and the sizes `md` (`control-height`) and `sm` (`control-height-sm`, with a 48 touch area).
- **FR-014**: It MUST support an optional icon at the start or the end; directional icons mirror in RTL.
- **FR-015**: It MUST support a `loading` state that replaces the icon with the platform loader, shows the caller's in-progress label, and ignores presses, and a `disabled` state that stays readable and announces itself as unavailable.
- **FR-016**: Press feedback MUST follow the platform: fill fades to 70% with no ripple on Apple, a `primary-pressed` ripple on Android, `primary-hover` hover, focus ring and pointer cursor on web and desktop.
- **FR-017**: It MUST NOT use `volt` as a background, and the gallery MUST state the usage rules that a widget cannot enforce (one `primary` per screen, `danger` only after a confirmation dialog).

**SprintTextField** (FR-AUTH-01 – FR-AUTH-03)

- **FR-018**: `SprintTextField` MUST show its label above the field always, show a placeholder that is an example of valid input, and show an optional helper below.
- **FR-019**: It MUST support the types `text`, `password` (with show and hide), `search` (a pill on `surface-sunken`), `phone`, `email` and `nationalId`, with the keyboard type and autofill hints each type needs.
- **FR-020**: It MUST support the states default, focused (2px `primary` border), error (2px `danger` border, `danger-soft` fill, an icon and the message replacing the helper) and disabled (`surface-sunken`, `ink-disabled`), and on keyboard platforms the focus ring.
- **FR-021**: `phone`, `email`, `nationalId` and `password` MUST be entered and displayed left-to-right and aligned to the start of the line, in Arabic as well as English.
- **FR-022**: It MUST NOT validate by itself. It MUST tell the caller when the user leaves the field so the caller can validate then (not on every character), and MUST show the error the caller gives.

**SlotChip** (FR-AVL-01, FR-BKG-01 – FR-BKG-03, US-06 – US-09)

- **FR-023**: `SlotChip` MUST show the start time in 12-hour form and, under it, a word for its state, for the states `available`, `selected`, `fewLeft`, `full` and `past`, with the look defined in the SlotChip README.
- **FR-024**: It MUST derive `fewLeft` from the remaining places and the threshold supplied by the caller; on an exclusive unit it MUST show no number. The threshold is the setting `fewLeftThreshold` (default 2, university → facility → unit inheritance), which this feature adds to BRD §4 and to the settings registry and shows in the settings inspector.
- **FR-025**: A chip MUST be at least 56 tall and 100 wide and MUST be laid out in a grid with `space-2` gaps ordered with the reading direction. `full` and `past` MUST NOT be pressable and MUST tell a screen reader why.
- **FR-026**: It MUST support range selection for free facilities: the first and last chips selected, the chips between them tinted `primary-soft`.
- **FR-027**: A selection MUST give a light haptic on Apple and Android platforms only, through the adaptive layer; a state change while on screen MUST change colour and word together within `duration-base`.

**DayStrip** (FR-AVL-01, BR-06)

- **FR-028**: `DayStrip` MUST show the number of days the caller supplies (from `bookingWindowDays`), the first being today in Cairo time, none past and none beyond the window.
- **FR-029**: Each day MUST be a pill (`radius-full`, 64 tall) with the day name (`micro`, `ink-muted`) and the number (`number`, `ink`); today is named "النهارده" in `primary`; the selected day is `primary` with `on-primary`.
- **FR-030**: A day with room MUST show a `success` dot (never `volt`) and tell a screen reader "فيه أماكن"; a closed day MUST be `ink-disabled`, not pressable, and tell a screen reader "مقفول".
- **FR-031**: When no day is selected, the first day with room MUST be selected. Order follows the reading direction. In compact it MUST scroll horizontally when the days do not fit and keep the selected day in view; from medium it MUST spread across the width. On keyboard platforms the arrow keys MUST move between days.

**StatusBadge** (BRD §5 statuses, FR-MYB-02, US-14)

- **FR-032**: `StatusBadge` MUST show the six booking statuses (`CONFIRMED`, `PENDING_PAYMENT`, `CANCELLED`, `ATTENDED`, `NO_SHOW`, `EXPIRED`) with the fixed words, icons and colours of the README, and MUST also serve verification (under review, verified, rejected) and damage-report (open, in progress, resolved) statuses.
- **FR-033**: It MUST be a pill 28 tall with an icon (`icon-sm`) and a word (`micro`); the icon and the word MUST both always show; it MUST NOT be pressable; `NO_SHOW` and `EXPIRED` MUST be neutral.
- **FR-034**: A status change while on screen MUST change colour, icon and word together within `duration-base`.

**FacilityCard** (FR-CAT-01 – FR-CAT-03, US-01, US-11)

- **FR-035**: `FacilityCard` MUST show the photo area, up to three tags (sport, "بمدرب", "مجاني", or an offer), the name (`headline`), the owning unit and the unit count, today's availability and the price, in a `surface` card with `radius-lg`, `shadow-card` in Light only, `space-4` padding and a `line` divider above the price.
- **FR-036**: It MUST support the layouts `vertical` and `horizontal` (photo 112 wide on the start side) and the types paid, free and with trainer.
- **FR-037**: Until a real photo is supplied, the photo area MUST be `surface-sunken` with the words "صورة المنشأة". The photo MUST be able to take part in a shared-element transition to the facility details (`duration-slow`, `ease-enter`); the transition itself belongs to the catalogue feature.
- **FR-038**: Availability MUST show as plenty (`success` and a check), few (`warning` and a clock) or none (`ink-muted`, "مفيش مواعيد النهارده"), each with its word, as given by the caller.
- **FR-039**: The price MUST be the one the user will actually pay, with whom it is for; a guest MUST see both prices; a free facility MUST show "مجاني". It MUST NOT show a misleading "from" price. An offer MUST show a `volt` tag with `on-volt` text and the old price struck through in `ink-muted`.
- **FR-040**: The whole card MUST be one pressable target, MUST NOT contain buttons, and MUST support hover, pressed and keyboard focus states per platform.

**BookingTicket** (FR-MYB-01, FR-MYB-02, US-12, US-13)

- **FR-041**: `BookingTicket` MUST show the status (as a `StatusBadge`), facility, unit, trainer (if any), start and end ("التلات 10 نوفمبر · 5:00 – 6:00 م"), the QR, the booking code, and the paid and cancel-until rows, in a `surface` card with `radius-lg`, 340 wide on compact and centred on larger windows.
- **FR-042**: It MUST support the states `upcoming`, `today` and `past`: upcoming and today show the time band in `volt` with `on-volt` text; past shows `surface-sunken` with `ink-muted`.
- **FR-043**: It MUST have a dashed `line` divider between the upper part and the QR with two half-circle notches in the `bg` colour at both ends.
- **FR-044**: The QR MUST be `qr-ink` on `qr-ground` in both themes with a quiet margin of 12 around it, MUST encode exactly the signed token passed in, and MUST scan back to that token.
- **FR-045**: For a past or cancelled booking the QR MUST be hidden and the status shown in its place. With no token, a "QR غير متاح" state MUST show instead of a blank code.
- **FR-046**: The booking code MUST be left-to-right in the `code` style, MUST be copyable, and MUST confirm the copy to the user and to a screen reader.
- **FR-047**: When cancellation is not available the row MUST read "الإلغاء مش متاح". The ticket MUST NOT contain offers or advertising. Its reveal MUST use `duration-slow` and `ease-enter` (a fade under reduced motion).

**AppNavigation** (FR-AUTH-04, FR-CAT-03, BRD §6; Foundation FR-002 – FR-007, FR-017)

- **FR-048**: `AppNavigation` MUST be one component with three forms chosen only by window width: tab bar in compact, rail in medium, sidebar in expanded and large. Exactly one form MUST show at every width, including the six boundary widths.
- **FR-049**: It MUST take `destinations` as data (built by the caller from the user's roles and scopes), `selected`, `onSelected` and `badges`, so a new role-specific destination appears by data and not by new navigation code.
- **FR-050**: The active destination MUST show as the README defines for each form: Fill icon and `primary` label in the tab bar; a `primary-soft` pill with `on-primary-soft` text in the rail; a `primary-soft` row with `on-primary-soft` text in the sidebar.
- **FR-051**: The Apple tab bar MUST be translucent with a blur over the content and with no pill; the Android tab bar MUST be solid `surface` and MAY use the pill; the tab bar MUST extend behind the safe area with its items inside it and MUST NOT hide while scrolling. The rail and the sidebar MUST sit on the start edge.
- **FR-052**: The sidebar MUST show the Sprint lockup (`SprintLogo`) at the top.
- **FR-053**: A badge MUST show the unread count in `danger` with `on-danger` text, MUST be hidden at zero, MUST be announced with its destination to a screen reader, and MUST cap its displayed number.
- **FR-054**: On compact with more than five destinations the fifth MUST be "المزيد" and MUST open a menu of the rest through the adaptive sheet.
- **FR-055**: On keyboard platforms, hover MUST show `surface-sunken`, focus MUST show the focus ring, and the number keys 1 to 5 MUST open the matching destination.
- **FR-056**: It MUST keep every Foundation guarantee: the selected destination, typed input and scroll position survive a resize across a size boundary and a fold or unfold; every item is at least 48 (the 44 exception applies only to the Apple title bar, not to navigation); labels have Arabic and English spoken names; at large text sizes the tab bar may drop visible labels but keeps the spoken label; selecting the already selected destination returns to its start.
- **FR-057**: The Foundation's plain tab bar, rail and sidebar MUST be removed once `AppNavigation` replaces them, so there is one navigation implementation, and the Foundation's navigation tests MUST still pass.

**StatTile** (FR-RPT-01, FR-RPT-02, US-21)

- **FR-058**: `StatTile` MUST show the label and period (`caption`, `ink-muted`), the value (`number-lg`, `ink`) with a smaller unit in `ink-muted`, and the change and what it is compared with, in a `surface` card with `radius-lg`, `shadow-card` in Light only and `space-4` padding.
- **FR-059**: The change MUST show an arrow for direction, a colour for good (`success`) or bad (`danger`) decided from `higherIsBetter`, and a sentence that says both in words; a flat or missing change MUST show neutrally and say so ("مفيش تغيير" or "مفيش مقارنة").
- **FR-060**: Rates MUST be shown without fractions and money with a thousands separator, in Western digits.
- **FR-061**: A tile MUST be tappable only if the caller gives an action. It MUST NOT contain a chart or sparkline, and it MUST fit two to a row on compact and three or four to a row on expanded and larger without fixed widths.

**SprintLogo**

- **FR-062**: `SprintLogo` MUST offer the variants `mark`, `tile-primary`, `tile-ink`, `lockup-ar` and `lockup-en` from the files in `docs/design-system/logo/`, with the colours fixed in both themes.
- **FR-063**: It MUST NOT render the bare mark on a light surface, mirror the mark, recolour, stretch, rotate, shadow or border it, or draw it below 16.

**Loading forms** (README § الحركة)

- **FR-064**: `FacilityCard`, `BookingTicket` and `StatTile` MUST each provide a loading form built from the Foundation's skeleton primitive with the outer shape of the loaded widget; it MUST be silent to a screen reader, pulse at `duration-pulse`, and hold still under reduced motion. The primitive itself MUST NOT be changed.

**Gallery** (supports every story)

- **FR-065**: The demo area MUST have a component gallery showing every variant, size and state of every component with realistic Egyptian sample content, plus reviewer controls for text size (up to 200%), reduced motion and platform look (Apple, Android, desktop or web), alongside the Foundation's theme and language switches. It MUST be hidden by the same release switch as the Foundation's demo screen.
- **FR-066**: Sample values in the gallery (such as how many places are left or how many days to show) MUST be labelled as sample content, and any that are BRD settings MUST be read from the settings repository rather than written into the gallery as constants.

### Key Entities

This feature adds no business entity. It adds presentation vocabulary that later features map their entities onto.

- **Component variant and state**: the named variants, sizes and states of each widget (for example button variant, slot state, ticket state), identical in the README, in Figma and in code.
- **Destination**: one item of `AppNavigation` (label, icon, filled icon, whether its icon mirrors in RTL, optional badge); the Foundation's destination model is reused.
- **Availability level**: plenty, few or none, shown on a `FacilityCard`.
- **Status**: the booking, verification and damage-report statuses a `StatusBadge` shows, mapped to a word, an icon and a colour pair.
- **Price display**: the amount, the currency, whom it is for, and the struck-through old price of an offer.
- **Sample content**: demo-only values in the gallery, drawn from the Foundation's seed data.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every component in the table above has a gallery section that shows 100% of the variants, sizes and states named in its README, and a reviewer can confirm each against `preview.html` without a developer.
- **SC-002**: 100% of colours, spacing, radius, size, shadow and motion values in widget code trace to a named token; a repository search of widget code for raw colour values, unnamed numeric style literals, platform checks and user-facing string literals finds none.
- **SC-003**: Every widget state is distinguishable without colour in 100% of cases: viewed in grayscale, each of the five chip states, six booking statuses, three availability levels and the change direction of a tile can be told apart by its word or icon alone.
- **SC-004**: At 200% text size, no widget in the gallery clips or overlaps its text at compact width, in both languages, and every touch target in the gallery is at least 48.
- **SC-005**: At every width from 320 to 1920, exactly one navigation form shows and it is the correct one in 100% of tested widths, including 599, 600, 839, 840, 1199 and 1200, and the selected destination and scroll position survive 100% of tested resizes, folds and unfolds.
- **SC-006**: The whole Foundation test suite passes unchanged after `AppNavigation` replaces the plain navigation, and the Foundation's navigation behaviours (destination list from roles, one form per width, 48 targets) still hold.
- **SC-007**: A booking QR rendered by `BookingTicket` decodes back to exactly the token it was given in 100% of tested tokens, in Light and Dark.
- **SC-008**: A reviewer can see an Apple, an Android and a desktop or web version of a button press and of the navigation on one device in the gallery, and the differences match `adaptive.md` in 100% of the rows that concern these widgets.
- **SC-009**: Every user-facing string in the widgets and the gallery exists in Arabic and English; switching language changes 100% of them and mirrors the layout with no directional icon left unmirrored and no non-directional icon mirrored.
- **SC-010**: Under reduced motion, no widget animation in the gallery runs longer than the short fade (`duration-fast`) and the skeleton holds still, in 100% of the animated states listed in the READMEs.
- **SC-011**: A developer can build a sample screen that shows a day strip, a slot grid, a facility card and a button using only widget properties and tokens, with no platform check, raw colour or string literal, and a reviewer finds it matches the design system, with no custom styling added.

## Out of scope

This feature is UI-only and delivers the widgets, not the screens that use them. These are explicitly not part of it:

- **Backend**: no Supabase, no Firebase, no server, no real database, no real push, no real file upload. The widgets take plain values; nothing is fetched or stored.
- **Real payments**: no gateway call and no payment screen. `SprintButton` can carry a price in its label, but checkout, the sandbox gateway use and the confirmation flow are feature 6.
- **SMS and any paid service**: not used.
- **Any business screen**: catalogue and facility details, availability and booking flows, checkout, my bookings and cancellation, notifications and profile, trainer dashboard and QR scan, admin operations, reports and KPIs screens, assets and offers screens. The widgets are shown only in the gallery and in the navigation, never wired into a business flow. Real sign-in screens (US-01 – US-05) are feature 3.
- **Lottie moments** (booking and payment success, payment failure, empty states): feature 11. This feature adds code-timed motion only.
- **Camera QR scanning** by the trainer (US-15): the ticket only shows a QR.
- **Screen-brightness boost on the ticket**: needs a platform plugin and the screen's lifecycle, so it belongs to the feature that shows the ticket (see Assumptions).
- **Apple Wallet and Google Wallet buttons** on the ticket: the README already puts them after P1.
- **Real facility photos, prices and trainer names**: the widgets take them as input; the data from Dr. Sara arrives later.
- **Figma sync and Code Connect mapping**: the repository is the source of truth; Figma follows later. The widget property names match `handoff.md` so the mapping is direct when it comes.
- **A chart, a sparkline, a table or any other admin component** beyond the nine listed and `SprintLogo`.
- **Anything from P2**: university system integration, SMS, e-collection payment.

## Assumptions

The four guesses that needed Osman's decision were settled in `/speckit-clarify` (2026-11-15) and are marked as settled below. The rest are low-impact defaults.

- **The few-left threshold is a new setting (settled in clarify, 2026-11-15).** The SlotChip README says the threshold comes from settings with a default of 2, but BRD §4 did not list it. This feature adds `fewLeftThreshold` (default 2, university → facility → unit inheritance) to BRD §4 and to the settings registry, because Principle III forbids hard-coding it. The BRD change lands in this feature's pull request, docs first.
- **The gallery stays in the defense build (settled in clarify, 2026-11-15).** It is reachable behind the Foundation's demo switch, so showing the design system is part of the defense and it can still be removed from a store release without touching a widget.
- **Screen-brightness boost is deferred to feature 7 (settled in clarify, 2026-11-15).** The ticket only exposes the `today` state, because the boost needs a platform plugin and a screen lifecycle to restore the brightness, and the widget stays presentation-only.
- **Phosphor is adopted as the icon set (settled in clarify, 2026-11-15).** The README marks it as temporary ("بديل مؤقت") and the Foundation used built-in icons; the widgets adopt Phosphor (Regular, plus Fill for the active navigation item) and icons are passed in as data, so swapping later is easy.
- **Availability level is decided by the caller.** The FacilityCard README does not say what counts as "plenty" or "few". I assume the widget shows the level it is given (with the count) and the catalogue feature decides the level, since no BRD setting defines it.
- **Skeleton and logo decisions** are those in Scope decisions above (logo in; skeleton not new, loading forms added for three cards).
- **The platform look switch in the gallery is demo-only.** It changes the platform the widgets see, through the same theme platform value the adaptive layer already reads, so a reviewer on one device can see Apple and Android behaviour. It is not a setting of the product.
- **A bare mark on a light surface falls back to the primary tile**, instead of drawing it or throwing an error. The README forbids the combination; falling back is the safest way to enforce it.
- **Badge counts cap at 99** and show "99+" above that. No document fixes the cap.
- **Closed days, free ranges and the "المزيد" menu** are shown from data the caller supplies; the widgets do not decide them.
- **Keyboard behaviour beyond the READMEs** (arrow keys in the day strip, Enter and Space to activate) follows common keyboard practice and the Foundation's existing focusable control.
- **The notifications tab is still not shown by default.** The decision of 2026-11-10 holds: the Foundation shows four destinations and the fifth (notifications) arrives with its feature. `AppNavigation` supports it and its badge, and the gallery shows them with sample destinations.
- **Sample content** in the gallery uses the Foundation's seed data (facility names, prices in both tiers, units and bookings). Names and prices are placeholders until Dr. Sara's data arrives.
- **The stack and architecture** are those fixed in `CLAUDE.md` and the constitution (Flutter, Riverpod, GoRouter, tokens as generated code, adaptive layer in `lib/core/adaptive/`). This spec states outcomes; where the widgets live and how they are built belongs to the plan.
- **Platforms checked**: web, macOS, Android and iOS, as in the Foundation. Windows and Linux are scaffolded but not built or run.
