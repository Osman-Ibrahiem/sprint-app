# Feature Specification: Facility Catalogue and Details

**Feature Branch**: `004-facility-catalogue` (spec directory `004-facility-catalogue`)

**Created**: 2026-11-16

**Status**: Draft

**Input**: User description: "Feature 004 — Facility catalogue and details (FR-CAT, UI-only on mock data, per CLAUDE.md suggested feature order #4). Guests must be able to browse."

**BRD coverage**: FR-CAT-01 (facility list with filters by type, owning unit and free / paid), FR-CAT-02 (facility page: photos, description, hours, prices for both tiers, trainers, location), FR-CAT-03 (home: guest sees discovery, signed-in user sees upcoming bookings and suggestions), FR-CAT-04 (share link per facility, Should). User stories: **US-01** (guest browses without an account), the catalogue half only; **US-11** (price by tier), display only. Business rules displayed and never decided here: BR-15 – BR-17 (price tiers), BR-16 (price per slot in `EXCLUSIVE`, per place in `SHARED`), BR-19 (free facility has no payment step), BR-09 and BR-10 (trainer facilities and free facilities are separate paths), BR-05 (hours and closures), BR-06 (7-day window, shown as a fact, not enforced here), BR-45 (few-left threshold). NFRs: NFR-01, NFR-02, NFR-03, NFR-10. Foundation: `specs/001-foundation/` (catalogue domain, repositories, seed data, shell, settings). Widgets: `specs/002-design-system-widgets/` (`FacilityCard`, `StatusBadge`, `StatTile`, `BookingTicket`, `DayStrip`, `SlotChip`).

## Scope decisions

These were decided in this specification so the plan does not have to guess.

- **Catalogue only, not slot browsing.** US-01 also promises "the slots for 7 days" and "tapping an available slot asks a guest to sign in, then returns to the same slot". That half is availability (FR-AVL-01) and the booking entry (FR-BKG-01) and belongs to feature 5. This feature gives the facility page an availability section with today's summary and a "عرض المواعيد" action that opens a "قريبًا" screen, and shows today's availability summary on the cards. It does not build the day strip with slots or the sign-in-and-return behaviour.
- **Home, list and details are all built here.** The Foundation left `/home` and `/facilities` as placeholders (`home_placeholder`, `facilities_placeholder`). This feature replaces them with the real screens and adds the facility details screen.
- **Read-only.** Nothing in this feature creates or changes a booking, a price, a facility or a setting. Admin editing of facilities, hours, closures and prices is feature 9.
- **Presentation reads, never decides.** Screens read facilities, units, hours, closures, prices and trainers through the existing catalogue repository interface, and today's availability through the existing availability service on seed data. They never compute a price tier or an availability rule themselves.

## Clarifications

### Session 2026-11-16

- Q: Until feature 5 exists, should the facility page show a disabled "عرض المواعيد" button, hide it, or keep it enabled? → A: Keep it enabled. It opens a simple "قريبًا" screen that says the 7-day slots arrive soon and offers a way back to the facility.
- Q: What does the share link of a facility look like? → A: `/facilities/<id>`, using the facility's stable internal id (not a readable slug), so a renamed facility keeps working links.
- Q: How many suggestions does home show for a signed-in user, and in what order? → A: Four. First facilities of the sport types the user booked before (reason in words), then the rest in a fixed order, never repeating a facility the user already has an upcoming booking in.
- Q: When a unit's hours differ from its facility's, how does the page show it? → A: The page shows the facility's weekly hours, and under the name of each unit whose hours differ it shows a short line with that unit's own hours. Units with the same hours show nothing extra.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A guest opens the app and discovers facilities (Priority: P1)

Someone opens Sprint for the first time with no account. The home screen shows them what the university offers: the facility types, a handful of facilities with today's availability and the price, and an obvious way to see all of them. They never hit a sign-in wall.

**Why this priority**: US-01 and FR-CAT-03. For the defense, the first thirty seconds must show a working, attractive product without logging in. Everything else in the catalogue hangs off this screen.

**Independent Test**: Open the app signed out on seed data. The home screen shows discovery content, opens a facility, and goes to the full list, without any sign-in prompt.

**Acceptance Scenarios**:

1. **Given** a guest, **When** the app opens, **Then** the home screen shows discovery: facility types to jump into, and a section of facilities as cards (type, name, owning unit, today's availability, price).
2. **Given** a guest on home, **When** they tap a type, **Then** the facilities list opens already filtered to that type.
3. **Given** a guest on home, **When** they tap a facility card, **Then** the facility details screen opens, with no sign-in required.
4. **Given** a guest, **When** home is loading, **Then** card-shaped skeletons show instead of a spinner, and they match the final layout.
5. **Given** a guest, **When** they see a price on a card, **Then** it shows both tiers ("سعر الطلاب والعاملين" and "السعر الكامل"), never a single misleading "from" price (BR-15, FacilityCard README).

---

### User Story 2 - Browse and filter the facility list (Priority: P1)

Anyone can see every published facility in a list or grid and narrow it by sport type, owning unit (faculty or central admin) and free / paid. The filters are visible, easy to clear and say how many results they give.

**Why this priority**: FR-CAT-01. It is the second half of discovery and the only way to find a specific facility.

**Independent Test**: Open `/facilities` on seed data, apply each filter alone and in combination, and confirm the results, the count, the empty state and the clear action.

**Acceptance Scenarios**:

1. **Given** the list screen, **When** it opens, **Then** all published facilities show, and unpublished ones never show.
2. **Given** the list, **When** the user picks a type, an owning unit, or free / paid, **Then** only matching facilities show, filters combine with AND, and the active filters are visible as chips with a one-tap clear for each and for all.
3. **Given** filters that match nothing, **When** results are empty, **Then** an empty state says so in words, names the active filters, and offers clearing them (the Lottie empty-state illustration is feature 11; a static icon and text for now).
4. **Given** a compact screen, **When** the list shows, **Then** it uses the horizontal `FacilityCard` layout in a single column; on medium and larger it uses a grid with the vertical layout (adaptive.md).
5. **Given** a medium or larger window, **When** the user taps a card, **Then** the facility shows in a details pane beside the list (master-detail); on compact it opens as its own screen, and rotating or folding keeps the selected facility and the active filters.
6. **Given** a facility that is free (`isFree`) or needs a trainer (`requiresTrainer`), **When** its card shows, **Then** the matching tags show ("مجاني", "بمدرب") with a word, not only a colour.

---

### User Story 3 - See everything about a facility before booking (Priority: P1)

On a facility page, the user sees photos, a description, where it is, the weekly operating hours and any closure, the price for both tiers per unit type, the trainers (for trainer facilities), and which units it has. Signed-in users also see which price applies to them. It is clear what the next step will be, even though booking itself arrives in feature 5.

**Why this priority**: FR-CAT-02 and US-01 ("sees its details and prices for both tiers"). This is the screen a reviewer opens to judge whether the catalogue is complete.

**Independent Test**: Open one facility of each kind on seed data (shared lanes, exclusive pitch, free facility, trainer facility) and check each section against the seed values.

**Acceptance Scenarios**:

1. **Given** any facility, **When** its page opens, **Then** it shows photos (or the "صورة المنشأة" placeholder, never a stock image), name, type, owning unit, description and location.
2. **Given** a facility with weekly hours, **When** the page shows them, **Then** each day shows its opening and closing time in 12-hour format ("5:00 م"), closed days say "مقفول", and today is marked.
3. **Given** a facility with a current or upcoming closure, **When** the page shows, **Then** the closure and its dates are visible in words (BR-05), and a facility closed right now says so near the top.
4. **Given** a guest, **When** the page shows prices, **Then** both tiers show with their labels, per unit type, and each says what it is for: "للمكان الواحد" for `SHARED`, "للحجز كله" for `EXCLUSIVE` (BR-16). Amounts show as "120 ج.م" (EGP 120 in English).
5. **Given** a signed-in user, **When** the page shows prices, **Then** their own tier is highlighted with a word ("سعرك") and the other tier is still visible, so a not-yet-verified user can see what verification would give them (US-11). Verification itself is feature 3.
6. **Given** a free facility, **When** the page shows, **Then** it shows "مجاني" and no price, and says no payment step is needed (BR-19).
7. **Given** a facility with `requiresTrainer`, **When** the page shows, **Then** it lists its trainers with name, short bio and their capacity, and says booking goes through choosing a trainer first (BR-09). A facility with no trainers says so instead of an empty block.
8. **Given** a facility with several units (lanes, pitches), **When** the page shows, **Then** it lists the active units by name and does not show inactive ones.
9. **Given** the page, **When** the availability section is reached, **Then** today's availability summary shows with an enabled primary "عرض المواعيد" action. **When** the user taps it, **Then** a simple "قريبًا" screen opens, saying the 7-day slots arrive soon, with a way back to the facility. Feature 5 replaces that screen with the real day strip. This feature adds no fake booking path: the screen has no slots and no booking action.
10. **Given** a compact screen, **When** the user scrolls, **Then** the page keeps a sticky header or action area, and system back or the back gesture returns to the list or home with scroll position and filters kept.

---

### User Story 4 - A signed-in user sees their upcoming bookings and suggestions on home (Priority: P2)

A signed-in booker opens the app and home first shows their next confirmed bookings (soonest first), then suggested facilities, instead of only the guest discovery. A user with no bookings sees discovery plus a short invitation to book.

**Why this priority**: FR-CAT-03 ("registered sees upcoming bookings and suggestions"). It is lower than the guest path because the guest path is the first impression, but it is what the defense shows after signing in.

**Independent Test**: Switch between guest and a signed-in seeded user (with and without confirmed bookings, using the Foundation's identity on seed data) and compare the home content.

**Acceptance Scenarios**:

1. **Given** a signed-in user with confirmed upcoming bookings, **When** home shows, **Then** the next bookings appear first as tickets or compact booking rows (status, facility, date, time), soonest first, with a "عرض الكل" link into My bookings.
2. **Given** a signed-in user with no upcoming bookings, **When** home shows, **Then** discovery shows with a short note that they have no upcoming bookings, not an empty box.
3. **Given** a signed-in user, **When** the suggestions section shows, **Then** it lists facilities by a simple, explainable rule (facility types they booked before first, then others), shows the reason in words ("لأنك حجزت سباحة قبل كده"), and never uses AI (CLAUDE.md).
4. **Given** the user signs out, **When** home refreshes, **Then** it returns to the guest discovery with no leftover personal content.
5. **Given** a user whose bookings are `PENDING_PAYMENT`, `CANCELLED`, `EXPIRED`, `ATTENDED` or `NO_SHOW`, **When** home shows, **Then** only upcoming `CONFIRMED` bookings appear; the rest belong to My bookings (feature 7).

---

### User Story 5 - Share a facility with a link (Priority: P3)

A user can share a facility's link. Anyone who opens the link lands on that facility's page, on the web or in the app, with no sign-in needed.

**Why this priority**: FR-CAT-04 is Should, and it supports the research problem of marketing and reaching target groups (BRD §10), but nothing else depends on it.

**Independent Test**: Use the share action on a facility, then open the produced link in a new web tab and in the app route, and check it lands on the same facility; then try a link to a missing facility.

**Acceptance Scenarios**:

1. **Given** a facility page, **When** the user taps share, **Then** the platform's share sheet or a copy-link action gives a link that identifies the facility.
2. **Given** a facility link, **When** it is opened signed out on the web, **Then** the facility page opens directly.
3. **Given** a link to a facility that does not exist or is unpublished, **When** it is opened, **Then** a friendly "المنشأة مش موجودة أو مش متاحة" screen shows with a way to the list, not a blank screen or a crash.
4. **Given** the facilities list on web, **When** the user reloads the page on a facility URL, **Then** it reopens the same facility (the address reflects the screen).

---

### User Story 6 - It works on every screen, language and theme (Priority: P2)

The same screens work in Arabic RTL and English, in light and dark, with large text, on phones, tablets, foldables, the web and desktop, and they say what is happening while loading, empty or failing.

**Why this priority**: These are non-negotiable project rules (constitution V), and the catalogue is the most-seen part of the app.

**Independent Test**: Walk home, list and details in Arabic and English, in both themes, at 200% text, at each window size class, and with the seed repository forced to fail once.

**Acceptance Scenarios**:

1. **Given** Arabic, **When** any catalogue screen shows, **Then** it is RTL, with directional spacing and only directional icons mirrored, and numbers in Western digits.
2. **Given** a screen reader, **When** a card or a section is focused, **Then** it reads a meaningful Arabic label (name, type, owning unit, availability, price and whose price), not "button".
3. **Given** text scale 200%, **When** any screen shows, **Then** nothing is clipped or overlapped and every target is at least 48dp.
4. **Given** the repository fails to load, **When** a screen shows, **Then** it shows a clear error with a retry action, and retry reloads without leaving the screen.
5. **Given** a keyboard platform, **When** the user tabs through cards, filters and sections, **Then** a focus ring is visible and Enter or Space activates.

---

### Edge Cases

- A facility name or description is very long: it wraps or truncates with a clear rule, and the card never grows unevenly in a grid.
- A facility has no photos: the "صورة المنشأة" placeholder shows. One photo: no carousel controls. Several: swipeable with a position indicator, each with an Arabic description for screen readers.
- A facility's units all have no price: the page says the price is not set yet instead of showing 0.
- A facility is `isPublished = false`: it is not in lists, home, suggestions or shared links.
- A facility is closed today (hours or closure): the card and the page say "مقفول النهارده" and the availability summary is "مفيش مواعيد النهارده".
- Every slot today is in the past: availability reads "مفيش مواعيد النهارده", not "0".
- Filters are applied, the user opens a facility and goes back: filters and scroll position are still there.
- The user changes the app language or theme while on a screen: it updates in place, with the selected facility and filters kept.
- The user is signed in with a role that is not a booker (trainer, admin): home and catalogue show the same discovery content; role-specific home content belongs to features 8 and 9.
- A trainer in the data has no profile name: the trainer row shows a neutral label instead of an empty line.
- Window is resized from medium to compact with a facility open in the pane: the details open as a full screen on the same facility.
- On a foldable, the hinge splits the window: the list and details stay on their own sides, never under the hinge.
- Offers exist in the seed data: this feature does not show offer tags or discounted prices (offers are feature 10); prices are the regular tier prices.

## Requirements *(mandatory)*

### Functional Requirements

**Home (FR-CAT-03, US-01)**

- **FR-001**: The home destination MUST show, to a signed-out guest, a discovery layout: facility types to jump into, a featured facilities section as `FacilityCard`s, and an action to see all facilities.
- **FR-002**: Home MUST NOT require sign-in for any content in FR-001, and MUST NOT show a sign-in wall before content.
- **FR-003**: For a signed-in user, home MUST show upcoming `CONFIRMED` bookings first, soonest first, and MUST link to My bookings (feature 7) for the rest.
- **FR-004**: Home MUST show suggested facilities for a signed-in user, chosen by a simple, deterministic, explainable rule: at most 4 facilities, first those of the facility types of the user's previous bookings (each with the reason in words, such as "لأنك حجزت سباحة قبل كده"), then the remaining published facilities in a fixed order, never repeating a facility where the user already has an upcoming booking. Suggestions MUST NOT use AI.
- **FR-005**: When a signed-in user has no upcoming bookings, home MUST show discovery with a short, friendly note, not an empty section.
- **FR-006**: Home MUST show skeleton placeholders shaped like the content while loading.

**Facility list and filters (FR-CAT-01)**

- **FR-007**: The list MUST show all published facilities and MUST NOT show unpublished ones.
- **FR-008**: The list MUST filter by facility type, by owning unit, and by free / paid, alone or combined (AND), through the catalogue repository's filter parameters.
- **FR-009**: Active filters MUST be visible as chips, each removable, with one action that clears all, and the result count MUST be visible.
- **FR-010**: An empty result MUST show an empty state in words that names the active filters and offers clearing them.
- **FR-011**: Each facility MUST appear as a `FacilityCard` with its type, name, owning unit, unit count, today's availability level and count, and the price shown by the card's rules (both tiers for a guest; the user's tier with its label for a signed-in user), with the tags "مجاني" and "بمدرب" where they apply.
- **FR-012**: On compact windows the list MUST be a single column using the horizontal card layout; on medium and larger it MUST be a grid with the vertical layout, and on medium and larger a selected facility MUST show in a details pane beside the list.
- **FR-013**: Filters, the selected facility and the scroll position MUST survive navigating to details and back, rotation, window resize and fold / unfold.

**Facility details (FR-CAT-02, US-01, US-11)**

- **FR-014**: The details screen MUST show photos or the placeholder, name, type, owning unit, description and location.
- **FR-015**: It MUST show the weekly operating hours per day in 12-hour format in Africa/Cairo time, mark today, and say "مقفول" for closed days.
- **FR-016**: It MUST show current and upcoming closures with their dates in words, and a facility closed now MUST say so near the top.
- **FR-017**: It MUST show prices for both tiers per unit type, each labelled with its tier and its basis (per slot or per place), formatted "120 ج.م" / "EGP 120", and MUST NOT show a misleading "from" price.
- **FR-018**: For a signed-in user it MUST highlight the user's own tier with a word, while keeping the other tier visible.
- **FR-019**: For a free facility it MUST show "مجاني", no price, and that no payment step is needed (BR-19).
- **FR-020**: For a facility that requires a trainer it MUST list its trainers with name, short bio and trainer capacity, and MUST state that booking starts by choosing a trainer (BR-09, BR-10). For a facility with no trainers it MUST say so.
- **FR-021**: It MUST list the facility's active units by name, and MUST NOT list inactive ones. Under the name of a unit whose weekly hours differ from the facility's, it MUST show a short line with that unit's own hours; units with the same hours show nothing extra.
- **FR-022**: It MUST show today's availability summary and an enabled "عرض المواعيد" action that opens a simple "قريبًا" screen with a way back, to be replaced by feature 5's day strip. That screen MUST NOT show slots or any booking action, and this feature MUST NOT present a working booking path.
- **FR-023**: Back navigation (button, system back, back gesture) MUST return to the previous screen with its state kept.

**Share link (FR-CAT-04)**

- **FR-024**: Each facility page MUST offer a share action producing a link of the form `/facilities/<id>` (the facility's stable id, never its name), using the platform's share mechanism or copy-link.
- **FR-025**: Opening that link signed out MUST land on the facility page on the web and on the matching app route, and the web address MUST always reflect the facility on screen so a reload reopens it.
- **FR-026**: A link to a missing or unpublished facility MUST show a friendly not-found screen with a way back to the list.

**Data, settings and rules**

- **FR-027**: All catalogue data MUST come through the catalogue repository interface and today's availability through the existing availability service; screens MUST NOT touch the in-memory implementations directly (constitution IV).
- **FR-028**: Anything the BRD marks as a setting that these screens display (the booking window days, the few-left threshold, the free-range maximum hours) MUST be read from the settings repository with university → facility → unit inheritance, never hard-coded (constitution III).
- **FR-029**: The seed data MUST be enough to show every case in the stories: at least one shared-lane facility, one exclusive-pitch facility, one free facility, one trainer facility, a facility with a closure, a facility with several photos and one without, and facilities from more than one owning unit, with Arabic names, EGP prices and 12-hour times. If the Foundation's seed already covers a case, it MUST be reused, and any addition MUST be marked as placeholder until Dr. Sara's data arrives.

**Quality, language and accessibility (constitution II, V)**

- **FR-030**: All text MUST come from the l10n files in Arabic (default) and English, in the light Egyptian dialect with no imperative verbs (actions are verbal nouns), Western digits and 12-hour time. New string keys MUST be prefixed for this feature so they cannot collide with another feature's keys.
- **FR-031**: Every colour, size, spacing, radius and duration MUST come from tokens, and the screens MUST use the existing design-system widgets rather than re-implementing them.
- **FR-032**: Every interactive element MUST be at least 48dp, show a visible focus ring on keyboard platforms, carry a word or an icon with every state (never colour alone), and have a meaningful Arabic screen-reader label; text MUST scale to 200% without clipping; motion MUST respect reduce-motion.
- **FR-033**: Loading MUST show skeletons, and a load failure MUST show a clear error with a retry action.
- **FR-034**: Navigation bars, back gestures, share sheets and scroll physics MUST follow the platform (adaptive.md); brand components look the same everywhere.

### Key Entities *(include if feature involves data)*

- **Facility**: a place that can be booked (type, name, description, photos, location, free or paid, requires trainer, published or not), owned by one owning unit. Already defined by the Foundation; this feature only reads it.
- **Owning unit**: the faculty or central administration a facility belongs to; used as a filter and shown on cards.
- **Bookable unit**: a lane, pitch or hall inside a facility; listed by name and carrying the price per tier.
- **Price**: an amount per unit and per tier (`INTERNAL` or `EXTERNAL`), in EGP; shown per slot (`EXCLUSIVE`) or per place (`SHARED`).
- **Operating hours and closures**: weekly opening and closing times, and periods with no slots; shown on the page and used to say whether the facility is closed today.
- **Trainer**: a person who gives sessions at one or more facilities, with a bio and a capacity.
- **Availability summary (today)**: a level (plenty, few, none) and a count for today, read from the existing availability service; the full 7-day view is feature 5.
- **Facility filter**: the current type, owning unit and free / paid choices, kept while the user moves around.
- **Suggestion**: a facility offered to a signed-in user with the reason in words.
- **Facility link**: a stable address that identifies a facility on the web and in the app.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A guest who opens the app sees facilities and their prices on the first screen with no sign-in, and reaches any facility's full details in at most 2 taps.
- **SC-002**: A reviewer can narrow the list by type, owning unit and free / paid and see the result count update in under 1 second on seed data, and clear every filter in 1 tap.
- **SC-003**: Every facility page shows all FR-CAT-02 content (photos or placeholder, description, hours, both prices, trainers where they apply, location) with no section blank without an explanation, checked on every facility in the seed data.
- **SC-004**: The price a user sees on a card and on a details page always matches the seed price for their tier, in 100% of the seed facilities, with the tier named in words.
- **SC-005**: Home, list and details render with no layout overflow or clipped text at all four window size classes, in Arabic and English, in light and dark, at 200% text scale.
- **SC-006**: Filters, selection and scroll position are identical after opening a facility and going back, rotating, resizing or folding, in 100% of the tested transitions.
- **SC-007**: A shared facility link opened signed out lands on the right facility, and a link to a missing facility shows a not-found screen, never a blank screen or an error crash.
- **SC-008**: Every interactive element is reachable and operable by keyboard and by screen reader with an Arabic label, and no information depends on colour alone.
- **SC-009**: The web build of the three screens loads and becomes usable within the Foundation's recorded web load budget (NFR-01), with no regression against the 002 recorded times.
- **SC-010**: A walkthrough of the catalogue (home, list with filters, details of each facility kind) can be shown at the defense using only the seed data, from a cold start, in under 3 minutes.

## Out of scope

This feature is UI-only and delivers the catalogue screens, not booking. These are explicitly not part of it:

- **Backend**: no Supabase, no Firebase, no server, no real database, no real push, no real image upload or storage. Facilities, prices, hours and trainers come from the in-memory repositories on seed data.
- **Real payments**: no gateway, no checkout and no payment screens. Prices are displayed only; checkout is feature 6.
- **SMS and any paid service**: not used.
- **Slot browsing and booking**: the 7-day day strip with slots, the sign-in-then-return-to-the-slot flow, exclusive, shared, free-range and trainer booking, the Hold and conflict checks (FR-AVL-01, FR-AVL-02, FR-BKG-01 – FR-BKG-03, BR-11 – BR-14) are features 5 and 6. This feature reserves the place for them and stops there.
- **Sign-in, registration and verification screens**: feature 3 (US-02 – US-05). The catalogue reads the Foundation's session and tier as they are; it does not build or depend on the 003 screens.
- **My bookings, cancellation, notifications and profile**: feature 7. Home only links to them.
- **Trainer and admin home content, trainer dashboard, QR scan**: features 8 and 9.
- **Admin editing** of facilities, units, hours, closures, prices and settings: feature 9.
- **Offers and discounted prices** (FR-MKT, US-24, BR-20): feature 10. Offer tags and struck-through prices are not shown even if offers exist in the seed.
- **Reports, KPIs, assets and damage reports**: feature 10.
- **Lottie moments** (empty states and success animations): feature 11. This feature uses static icons and text for empty and error states.
- **Real facility photos, prices, hours and trainer names**: the data from Dr. Sara arrives later; seed placeholders stand in.
- **Maps, directions and distance**: location is shown as text. An embedded map or an "open in maps" action needs coordinates and a plugin that the data does not have yet.
- **Native universal-link and app-link configuration** (domain association files, store listings): the share link works on the web and as an in-app route. Making it open the installed app from outside needs a real domain and store setup, which comes with deployment.
- **Search by keyword and sort**: not in FR-CAT-01; only the three filters are built.
- **Favourites, ratings and reviews**: not in the BRD.
- **Anything from P2**: university system integration, SMS, e-collection payment.

## Assumptions

- **Home and list share seed facilities, and the Foundation's seed is the starting point.** The catalogue domain, repository interface, availability service and seed data already exist from Foundation; this feature reuses them and adds only seed cases that FR-029 needs and that are missing.
- **Current user and tier come from the Foundation's session.** Until feature 3 merges, a seeded identity or the demo role switch supplies the signed-in user and their tier; once 003 merges, the same session provider supplies the real flow. This feature must work with either, and does not wait for 003.
- **A signed-in user's tier follows their verification status at the time of viewing** (BR-17). It is frozen on a booking only when a booking is created, which is feature 6, so the page only shows "سعرك" for the tier as it is now.
- **Today's availability uses the existing availability service.** The level (plenty, few, none) uses the `fewLeftThreshold` setting (BR-45) and the FacilityCard rules from feature 2, as the 002 spec assumed the catalogue feature would decide the level.
- **Suggestions are a simple rule, not a recommender (settled in clarify, 2026-11-16).** Four facilities: types of the user's earlier bookings first, then the rest in a fixed order, skipping facilities with an upcoming booking. No personal data leaves the device, and there is no AI.
- **Hours are shown as the facility's weekly hours (settled in clarify, 2026-11-16).** A unit with different hours gets a short line under its name; the rest show nothing extra.
- **Photos are placeholders for now.** The seed has no real images; the placeholder from the design system shows, and the carousel is built so real images drop in.
- **The share link format is settled (clarify, 2026-11-16):** `/facilities/<id>`, so the web address, the in-app route and the share link are the same thing, and a renamed facility keeps its links.
- **Platforms checked** are web, macOS, Android and iOS, as in the Foundation. Windows and Linux are scaffolded but not built or run.
- **The stack and architecture** are those fixed in `CLAUDE.md` and the constitution. This spec states outcomes; where the code lives and how it is built belongs to the plan.
- **Parallel work with feature 003.** Feature 003 (auth and verification) is being specified and built in another working copy on its own branch. To keep merges easy, this feature adds new l10n keys with a catalogue prefix, adds new seed in new files where it can, adds new routes without reordering existing ones, and does not edit `CLAUDE.md`; the "built" note for this feature goes in after merge.
