# Feature Specification: Availability and Booking

**Feature Branch**: `005-availability-booking` (spec directory `005-availability-booking`)

**Created**: 2026-11-16

**Status**: Draft

**Input**: User description: "Feature 005 — Availability and booking (المواعيد والحجز). UI-first on mock data (phase P1). Covers BRD US-06 – US-09 and US-11 plus the related FR-BKG / FR-AVL requirements and business rules: from facility details ("عرض المواعيد", currently a "قريبًا" placeholder from feature 004) the booker picks a day (DayStrip, within the booking-window setting) and sees availability per bookable unit, then books in one of the modes: EXCLUSIVE, SHARED, free time range, and booking with a trainer. Price tier comes from verification status at booking time and is frozen on the booking. All settings are read from the Settings repository with inheritance; fake in-memory repositories enforce availability and conflict rules. Booking requires an account. The flow ends at a booking summary ready to hand off to checkout."

**BRD coverage**: FR-AVL-01 (slots for the booking window with available, booked and disabled states and places left in `SHARED`), FR-AVL-02 (availability refreshed on opening and before confirming; conflicting bookings refused by the data layer), FR-BKG-01 (`EXCLUSIVE` and `SHARED` booking by the unit's setting), FR-BKG-02 (hour range in a free facility), FR-BKG-03 (trainer first, then slot), FR-BKG-04 (summary before confirming). User stories: **US-01** second half (a guest sees the slots, and tapping one asks for sign-in and returns to the same slot), **US-06** up to the summary (payment is feature 6), **US-07** (places left and the full state on screen; booking a paid place goes up to the summary, and a completed booking that fills a slot is shown with a free shared unit), **US-08** (complete, because a free booking has no payment), **US-09**, **US-11**, **US-23** (an `EXTERNAL` account books at the full price with no verification). Business rules: BR-01 – BR-03 (booking modes), BR-05 – BR-07 (slots from hours minus closures, booking window, past slots and lead time), BR-45 (few left), BR-08 (free range), BR-09 and BR-10 (trainer path, two separate paths), BR-11 (availability checked at creation), BR-13 (no overlapping bookings for one booker), BR-14 (optional cap on active bookings), BR-15 – BR-18 (tiers and price basis), BR-19 (free booking confirms at once), BR-21 (new accounts are `EXTERNAL` and can book), BR-30 and BR-31 (cancellation policy, displayed in the summary only). NFRs: NFR-01, NFR-02, NFR-03, NFR-04, NFR-05, NFR-09, NFR-10. Builds on `specs/001-foundation/` (slot and booking rules, settings, repositories, seed), `specs/002-design-system-widgets/` (`DayStrip`, `SlotChip`, `StatusBadge`, `SprintButton`), `specs/003-auth-verification/` (account gate, tier from verification) and `specs/004-facility-catalogue/` (facility details and the "عرض المواعيد" entry).

## Scope decisions

These were decided in this specification so the plan does not have to guess.

- **This feature replaces the "قريبًا" screen.** "عرض المواعيد" on a facility page now opens the real schedule: the days of the booking window and the slots of each bookable unit.
- **Paid bookings stop at the summary.** BR-12 says the place is held when the booker enters payment, so the Hold, the `PENDING_PAYMENT` booking, the payment and the confirmation ticket all belong to feature 6. Here the summary's main action for a paid booking ("متابعة للدفع") re-checks availability and then opens a "قريبًا" checkout screen. Nothing is stored and no place is held for a paid booking in this feature.
- **Free bookings finish here.** A free facility has no payment step (BR-19), so US-08 is delivered end to end: the booking is created and `CONFIRMED` from the summary.
- **Three booking paths, chosen by the facility, never by the user.** A paid facility without a trainer uses the slot path (one slot, `EXCLUSIVE` or `SHARED` by the unit's setting). A free facility uses the range path (BR-08). A facility that requires a trainer uses the trainer path (BR-09). The paths are separate in the interface (BR-10).
- **One place per booking.** In `SHARED` a booking takes exactly one place (BR-03). There is no seat-count picker.
- **Rules live behind the repositories.** The screens show what the availability and booking repositories return and show their refusals in words. They never decide availability, conflicts, tiers or prices themselves (NFR-05).
- **No new chip or day states.** The slot and day components keep the states their design-system documents define. Anything else (a closed day, an overlap with the booker's own booking) is said in words around them.

## Clarifications

### Session 2026-11-16

- Q: In a facility with several units (for example 6 lanes), how does the user reach each unit's slots? → A: A unit picker above one slot grid. Each unit is marked when it has places that day, and the first unit with availability is selected.
- Q: How is "the slot was booked by someone else while my screen was open" (US-06) shown, when all data is on one device? → A: No special demo tool. The UI is being built now to show Dr. Sara; the defense will be a recorded video of the working system after the backend is connected, so every flow must be complete and recordable. In this feature the conflict is proven by automated tests and can be shown by booking from a second seeded account with the existing demo account switch.
- Q: When is a booker told that the chosen time overlaps another booking of theirs (BR-13)? → A: As soon as they tap the slot. The slot keeps its normal look, tapping it shows a message naming the overlapping booking, and it is not selected.
- Q: In a trainer facility, after choosing the trainer, does the booker pick the lane or see all of the trainer's sessions in one grid? → A: One grid of the trainer's sessions with no unit picker. The unit of each session comes from the trainer's schedule and is named in the summary.
- Q: What does the booker see right after a free booking is confirmed? → A: A simple success screen with the booking code and details and an action to home, with no QR. The full ticket with the QR stays in feature 6.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See a facility's slots for the coming days (Priority: P1)

Anyone, signed in or not, opens a facility and taps "عرض المواعيد". They see a strip of days from today to the end of the booking window, pick a day, and see that day's slots for a bookable unit: which are available, which have few places left, which are full and which have passed. In a shared unit each slot says how many places are left.

**Why this priority**: FR-AVL-01 and the first half of US-01. Every booking path starts on this screen, and it is the screen that answers the research problem of "traditional booking and scheduling".

**Independent Test**: On seed data, signed out, open the schedule of a shared-lane facility and of an exclusive-pitch facility, move across all days of the window, and compare each slot's state and count with the seed bookings, hours and closures.

**Acceptance Scenarios**:

1. **Given** a facility page, **When** the user taps "عرض المواعيد", **Then** the schedule opens with a day strip whose length is the booking-window setting (7 by default, BR-06), starting today, and with no day before today or after the window.
2. **Given** the schedule opens with no day chosen, **When** it loads, **Then** the first day that has an available slot is selected, and days with availability carry the day strip's "فيه أماكن" mark.
3. **Given** a day on which the facility is closed (closure or no operating hours), **When** the strip shows, **Then** that day is shown as closed with the word "مقفول" for screen readers, cannot be selected, and its slots never appear (BR-05).
4. **Given** a shared unit and a selected day, **When** the slots show, **Then** each available slot shows its start time in 12-hour format and the places left; a slot at or below the few-left threshold shows "فاضل …" (BR-45); a slot with no places shows "مكتمل" and cannot be selected (US-07).
5. **Given** an exclusive unit, **When** the slots show, **Then** a free slot shows as available with no count, and a booked slot shows "مكتمل" and cannot be selected (BR-02).
6. **Given** today is selected, **When** a slot's start has passed, or is closer than the minimum lead time setting, **Then** it shows "فات" and cannot be selected (BR-07).
7. **Given** a facility with more than one active unit, **When** the schedule shows, **Then** a unit picker above the slot grid lists the active units by name, each marked in words when it has places that day; the first unit with availability is selected, one grid shows the selected unit's slots, and inactive units never appear. A facility with one unit shows its name and no picker.
8. **Given** the schedule, **When** it is loading, **Then** skeletons shaped like the day strip and the slot grid show instead of a spinner; **When** loading fails, **Then** a clear error with a retry action shows.
9. **Given** a day with operating hours but no slot left to book, **When** it is selected, **Then** the grid still shows the full and past slots, with a line in words saying nothing is left that day and suggesting another day.
10. **Given** a guest, **When** they browse the schedule, **Then** nothing asks them to sign in until they choose a slot, and prices show for both tiers with their labels.

---

### User Story 2 - Book one slot in a paid facility, up to the summary (Priority: P1)

A signed-in booker picks an available slot in an exclusive unit (a whole pitch) or a shared unit (one place in a lane) and continues to a summary that shows the facility, the unit, the day and time, what the booking covers, their price tier in words, the price, and the cancellation policy. The summary's main action hands off to payment, which arrives in feature 6.

**Why this priority**: US-06 and US-07, FR-BKG-01 and FR-BKG-04. This is the main paid flow that the defense shows.

**Independent Test**: Signed in as a seeded booker, book a pitch slot and a lane place up to the summary, and check every summary line against the seed prices and settings. Then take the same slot from another seeded account's booking and confirm the stale choice is refused in words.

**Acceptance Scenarios**:

1. **Given** an available slot, **When** the booker selects it, **Then** it shows as "مختار", a light haptic plays on phones, and a single main action "متابعة" appears with the slot's time and price.
2. **Given** a selected slot, **When** the booker selects another slot, **Then** the selection moves to it; only one slot is selected at a time in this path.
3. **Given** a selection, **When** the booker continues, **Then** the summary shows: facility, unit, date, start and end time, what the booking covers ("الملعب كله" with the maximum participants for `EXCLUSIVE`, "مكان واحد" for `SHARED`), the tier in words, the price with its basis (BR-16), and the cancellation policy built from the cutoff-hours and refund-percent settings (BR-30, BR-31).
4. **Given** the summary of a paid booking, **When** the booker taps "متابعة للدفع", **Then** availability is checked again; if the slot is still free a "قريبًا" checkout screen opens with a way back to the summary, and no booking is stored.
5. **Given** the chosen slot was taken or filled since the screen opened, **When** the booker continues from the schedule or from the summary, **Then** a message says the slot was booked or is now full, the selection is cleared, and the schedule shows the slot's new state (US-06 second scenario, FR-AVL-02).
6. **Given** the booker already has a booking that overlaps the chosen time, in this or any other facility, **When** they tap the slot (or the slot that would complete a range), **Then** it is not selected and a message at once names the existing booking's facility and time (BR-13). The slot keeps its normal look before the tap.
7. **Given** the active-bookings cap setting has a value and the booker has reached it, **When** they continue, **Then** the choice is refused with a message that states the cap (BR-14). With the default (no cap) this never appears.
8. **Given** the summary, **When** the booker goes back, **Then** the schedule shows the same day, unit and selected slot.

---

### User Story 3 - A guest picks a slot, signs in and comes back to it (Priority: P1)

A guest browsing the schedule taps an available slot. The app asks them to sign in or create an account, saying why ("عشان تحجز"). After they sign in they are back on the same facility, day, unit and slot, ready to continue, and the price shown is now their own tier's.

**Why this priority**: The second half of US-01, deferred here by feature 004. Without it a guest cannot turn browsing into a booking.

**Independent Test**: Signed out, select a slot, go through sign-in with a seeded account and through sign-up with a new one, and confirm the same slot is selected afterwards. Repeat by reloading the web page mid-way.

**Acceptance Scenarios**:

1. **Given** a guest, **When** they tap an available slot and continue, **Then** the account gate from feature 003 shows with the reason, offering sign in and sign up.
2. **Given** the guest signs in or completes sign-up, **When** they return, **Then** the same facility, day, unit, trainer (if any) and slot or range are still selected, and the action waits for a new tap rather than running by itself.
3. **Given** the guest dismisses the gate, **When** they return to the schedule, **Then** their selection is kept and nothing is booked.
4. **Given** the slot stopped being available while the guest was signing in, **When** they return, **Then** the message from User Story 2, scenario 5 shows and the selection is cleared.
5. **Given** a new account (always `EXTERNAL`, BR-21), **When** it returns to the slot, **Then** it can continue at the full price with no verification step (US-23).
6. **Given** the web, **When** the page is reloaded on a schedule with a selection, **Then** the same facility, day, unit and selection reopen, because the address reflects them.

---

### User Story 4 - Book a range of hours in a free facility (Priority: P1)

In a free facility the booker picks a run of consecutive hours on one day, for example 4:00 to 6:00, instead of one slot. The summary shows "مجاني" and no payment step, and confirming creates the booking at once.

**Why this priority**: US-08 and FR-BKG-02. It is the only path this feature finishes end to end, so it proves the whole chain from schedule to a stored, confirmed booking.

**Independent Test**: On the seeded free facility, book a two-hour range and see it confirmed and listed in the upcoming bookings on home; then try a range across a taken hour and a range longer than the maximum.

**Acceptance Scenarios**:

1. **Given** a free facility's schedule, **When** it opens, **Then** a line in words explains that a range of consecutive hours can be chosen, up to the maximum-range setting (3 hours by default), in steps of the granularity setting (60 minutes by default) (BR-08).
2. **Given** no selection, **When** the booker taps a slot and then a later slot the same day, **Then** the first and last show as selected, the ones between are highlighted as part of the range, and the range's start, end and length show in words next to the main action.
3. **Given** a one-slot selection, **When** the booker continues without picking an end, **Then** the range is that single slot.
4. **Given** a range, **When** one hour inside it is full, past or closed, **Then** the range is not accepted and a message names the conflicting hour (US-08).
5. **Given** a range, **When** the booker tries to extend it beyond the maximum-range setting, **Then** the extension is refused with a message that states the maximum (US-08).
6. **Given** a valid range, **When** the booker continues, **Then** the summary shows the facility, unit, date, start and end, "مجاني" in place of a price, no tier price and no payment step, and the main action is "تأكيد الحجز" (BR-19).
7. **Given** the summary of a free booking, **When** the booker confirms, **Then** the booking is created as `CONFIRMED`, the hours show as taken (or one place fewer in a shared unit) to everyone, and the booker sees a simple success screen: a confirmation in words, the booking code, the facility, unit, date and time, and an action to home. It has no QR; the full ticket is feature 6.
8. **Given** two people confirm overlapping ranges at the same moment on an exclusive unit, **When** both confirm, **Then** exactly one booking is created and the other person sees that the hours were just booked (BR-11).
9. **Given** a confirmed free booking, **When** the booker opens home, **Then** it appears in their upcoming bookings (feature 004's section).

---

### User Story 5 - Book a session with a trainer (Priority: P2)

In a facility that requires a trainer (swimming lessons), the booker first chooses a trainer, then sees only the days and slots when that trainer is available and has room, picks one session, and continues to the summary, which names the trainer.

**Why this priority**: US-09 and FR-BKG-03. It answers the research problem about choosing trainers and distributing sessions, but it reuses the slot path's screens, so it comes after them.

**Independent Test**: On the seeded trainer facility, pick each trainer and compare the slots with the trainer's seeded availability and capacity; fill a trainer's capacity with seed bookings and confirm the slot shows "مكتمل" while the lane still has places.

**Acceptance Scenarios**:

1. **Given** a trainer facility, **When** "عرض المواعيد" is tapped, **Then** the first step is choosing a trainer: each trainer shows a name, a short bio, and whether they have sessions in the booking window.
2. **Given** a trainer is chosen, **When** the schedule shows, **Then** one grid shows that trainer's sessions for the selected day across all the units they work in, with no unit picker; only slots inside the trainer's availability show, each of the fixed session length from settings (60 minutes by default), and the days without any session for that trainer are marked as having no availability (BR-09).
3. **Given** a session, **When** its places are counted, **Then** the places left are the smaller of the unit's places left and the trainer's remaining capacity (BR-09).
4. **Given** the trainer has reached their capacity for a session, **When** the slot shows, **Then** it shows "مكتمل" even though the lane has places (US-09).
5. **Given** a chosen trainer, **When** the booker changes the trainer, **Then** the slot selection is cleared and the schedule reloads for the new trainer, keeping the selected day when that day is still valid.
6. **Given** a selected session, **When** the booker continues, **Then** the summary adds the trainer's name and the session length to the lines of User Story 2, and ends the same way (payment hand-off for a paid facility).
7. **Given** a trainer facility with no trainers, or whose trainers have no sessions in the window, **When** the schedule opens, **Then** it says so in words, with a way back to the facility.

---

### User Story 6 - The price I see is my tier's price (Priority: P2)

A signed-in booker sees one price everywhere in the booking flow: their own tier's. A verified student, employee or faculty member sees the internal price; everyone else sees the full price, with a short pointer to verification. A booking keeps the tier and price it was made with.

**Why this priority**: US-11 and BR-15 – BR-17. Price fairness between internal and external users is central to the thesis, and wrong prices in the summary would undermine the demonstration.

**Independent Test**: Walk the same slot as a seeded `INTERNAL` user, a seeded `EXTERNAL` user, a user with a pending verification request and a guest, and compare the schedule and summary prices with the seed prices.

**Acceptance Scenarios**:

1. **Given** an `INTERNAL` booker, **When** they see prices in the schedule and the summary, **Then** all are the internal price, labelled "سعر الطلاب والعاملين" (US-11).
2. **Given** an `EXTERNAL` booker, **When** they see the summary, **Then** the price is the full price, labelled "السعر الكامل", with a short line that verification gives the internal price and a link to the verification request. A booker whose request is under review sees that it is under review instead (BR-24).
3. **Given** a guest, **When** they see prices in the schedule, **Then** both tiers show with their labels, as in the catalogue.
4. **Given** an exclusive unit, **When** the price is shown, **Then** it is the booker's own tier's price for the whole slot, whoever plays with them (BR-18), and it is labelled "للحجز كله"; a shared unit's price is labelled "للمكان الواحد" (BR-16).
5. **Given** a booker whose verification expired or was approved between opening the schedule and continuing, **When** the summary shows, **Then** it uses the tier as it is at that moment, and says so if the price changed from what the schedule showed (BR-17, BR-25).
6. **Given** a free booking made while `EXTERNAL`, **When** the booker is verified later, **Then** the stored booking's tier does not change (US-11 second scenario).

---

### User Story 7 - It works on every screen, language and theme (Priority: P2)

The schedule, the trainer step and the summary work in Arabic RTL and English, in light and dark, with large text, by keyboard and screen reader, on phones, tablets, foldables, the web and desktop.

**Why this priority**: Non-negotiable project rules (constitution V), and booking is the flow reviewers will try on their own devices.

**Independent Test**: Walk the three paths in Arabic and English, both themes, 200% text, each window size class, with a screen reader and with a keyboard only.

**Acceptance Scenarios**:

1. **Given** Arabic, **When** the schedule shows, **Then** today is at the start of the day strip (the right), slots run from early to late in reading direction, and all digits are Western.
2. **Given** a compact window, **When** a slot is selected, **Then** the main action stays reachable at the bottom without covering the slots; the day strip scrolls sideways when it does not fit.
3. **Given** a medium or larger window, **When** the user opens the schedule from the facilities list, **Then** it opens in the details pane beside the list (as facility details does), and on expanded and large windows the current selection and its main action sit in a panel beside the slot grid instead of a bottom bar. The summary is its own screen at every width.
4. **Given** a foldable, **When** it is folded or unfolded, or a window is resized or rotated, **Then** the facility, day, unit, trainer and selection are kept, and nothing sits under the hinge.
5. **Given** a screen reader, **When** a slot is focused, **Then** it reads as a sentence ("الساعة 6 مساءً، فاضل مكان واحد"), and a full or past slot says why it cannot be chosen.
6. **Given** text scale 200%, **When** any screen in the flow shows, **Then** nothing is clipped, and every target is at least 48dp.
7. **Given** a keyboard, **When** the user tabs through days, units, trainers, slots and actions, **Then** a focus ring is visible and Enter or Space selects.
8. **Given** reduce-motion is on, **When** selections and transitions happen, **Then** they change without animation.

---

### Edge Cases

- A facility has no active units, or none of its units has operating hours: the schedule says there are no slots to book, with a way back, instead of an empty grid.
- Every day in the window is closed or fully booked: no day is preselected as available; the first open day is selected and the "nothing left" line shows.
- The booking-window, capacity, few-left, lead-time, granularity, maximum-range or session-length setting differs at the facility or unit level: the schedule follows the most specific value (university → facility → unit).
- A unit's own hours differ from the facility's: that unit's slots follow its own hours.
- A closure covers part of a day: only the slots inside the closure disappear, and the day stays selectable.
- The clock passes a slot's start (or its lead time) while the schedule is open: the slot becomes "فات" on the next refresh, and continuing with it is refused with a message.
- Midnight passes while the schedule is open: the day strip rolls forward on refresh, and a selection on a day that left the window is cleared with a message.
- A slot crosses midnight: it belongs to the day it starts on. Times follow Africa/Cairo, including daylight-saving changes.
- A range path's first tap is followed by a tap on an earlier slot: the range runs from the earlier to the later slot.
- A range is selected and the booker taps a third slot outside it: a new selection starts from that slot.
- In a shared free unit, hours inside a range have different places left: the range is accepted while every hour has at least one place.
- The booker opens a schedule link for a facility that is missing or unpublished: the catalogue's not-found screen shows.
- The address names a day outside the window, an unknown unit or trainer, or a slot that no longer exists: the schedule opens on its defaults and says the earlier choice is no longer available.
- A trainer works in more than one unit of the facility: their sessions still show in one grid ordered by time, each session belongs to the unit the trainer's schedule gives it, and the summary names that unit.
- A signed-in user with a non-booker role (trainer, manager, verifier, admin) books: they can, the same as a booker (BRD §6 matrix).
- The booker signs out while on the summary, the checkout placeholder or the success screen (for example from another tab, or when the session ends): the sign-in screen opens and signing in again brings the person back to the same place.
- The demo data is reset (feature 003's action) while a schedule is open: the schedule reloads from the seed and the selection is cleared.
- Offers exist in the seed data: no offer tag or discounted price shows (feature 10).
- Loading the summary or confirming a free booking fails for a reason that is not a booking rule: an error with a retry action shows, and no duplicate booking is created by retrying.
- The booker double-taps "تأكيد الحجز": one booking is created.

## Requirements *(mandatory)*

### Functional Requirements

**Schedule and availability (FR-AVL-01, FR-AVL-02, US-01)**

- **FR-001**: "عرض المواعيد" on a facility page MUST open that facility's schedule, replacing feature 004's "قريبًا" screen, for guests and signed-in users alike.
- **FR-002**: The schedule MUST show one day per day of the booking-window setting, starting today in Africa/Cairo time, with no past day and no day beyond the window (BR-06).
- **FR-003**: When no day is chosen, the schedule MUST select the first day with an available slot, or the first open day when there is none, and MUST mark the days that have availability in words for screen readers as well as visually.
- **FR-004**: A day with no slots because of a closure or missing operating hours MUST show as closed, be announced as "مقفول", and not be selectable (BR-05).
- **FR-005**: For the selected day and unit, the schedule MUST show every slot generated from the unit's operating hours minus closures (BR-05) with one of these states and its word: available, few left, full, past, and selected.
- **FR-006**: In a `SHARED` unit an available slot MUST show the places left, and MUST show the few-left state when the places left are at or below the few-left threshold setting (BR-03, BR-45). In an `EXCLUSIVE` unit no count is shown (BR-02).
- **FR-007**: A slot whose start has passed, or is closer than the minimum-lead setting, MUST show as past and MUST NOT be selectable (BR-07). Full slots MUST NOT be selectable.
- **FR-008**: The schedule MUST list only active units of a published facility, and each unit's slots MUST follow that unit's own booking mode, capacity and hours. Outside the trainer path, a facility with several units MUST show a unit picker above a single slot grid, each unit marked in words when it has places on the selected day, with the first unit that has availability selected by default; a facility with one unit shows no picker.
- **FR-009**: Availability MUST be reloaded when the schedule opens, when the day, unit or trainer changes, on a manual refresh, when the app returns to the foreground, and immediately before continuing to the summary and before confirming (FR-AVL-02).
- **FR-010**: When a selected slot or range is no longer available after a reload, the selection MUST be cleared, a message MUST say what changed, and the grid MUST show the new state.
- **FR-011**: The schedule MUST show skeletons while loading and an error with a retry action when loading fails; a day with nothing left to book MUST say so in words and suggest another day.
- **FR-012**: The schedule's address MUST identify the facility and reflect the chosen day, unit, trainer and selection, so a reload, a shared link or a return from sign-in reopens the same state. An address whose choices are no longer valid MUST fall back to the defaults with a message.

**Selecting and the three paths (FR-BKG-01 – FR-BKG-03, BR-10)**

- **FR-013**: The booking path MUST follow the facility: the range path for a free facility, the trainer path for a facility that requires a trainer, and the single-slot path otherwise. The user MUST NOT be asked to choose a path.
- **FR-014**: In the single-slot path the booker MUST be able to select exactly one bookable slot; selecting another moves the selection. One booking takes the whole unit in `EXCLUSIVE` and one place in `SHARED` (BR-01 – BR-03).
- **FR-015**: In the range path the booker MUST be able to select one or more consecutive slots on one day of one unit, in steps of the granularity setting, up to the maximum-range setting (BR-08). The start, end and length MUST show in words.
- **FR-016**: A range MUST be refused when any hour inside it is not bookable, naming the conflicting hour, and when it exceeds the maximum, stating the maximum (US-08).
- **FR-017**: In the trainer path the booker MUST choose a trainer before any slot shows. Trainers MUST show a name and short bio and whether they have sessions in the window (BR-09).
- **FR-018**: With a trainer chosen, the schedule MUST show one grid of that trainer's sessions for the selected day, ordered by time, with no unit picker; the unit of each session comes from the trainer's availability and MUST be named in the summary. It MUST show only slots inside the trainer's availability, of the session-length setting, with places left equal to the smaller of the unit's places left and the trainer's remaining capacity; a session at the trainer's capacity MUST show as full (BR-09, US-09).
- **FR-019**: Changing the trainer, the unit or the day MUST clear a selection that no longer applies, and MUST keep the day when it is still valid.
- **FR-020**: With a selection, exactly one main action ("متابعة") MUST be visible, with the selected time and the price or "مجاني". Without a selection it MUST NOT be active.

**Account gate (US-01, US-23)**

- **FR-021**: Browsing the schedule MUST NOT require an account. Continuing from a selection as a guest MUST open feature 003's account gate with the reason for it.
- **FR-022**: After signing in or signing up from the gate, the booker MUST return to the same facility, day, unit, trainer and selection, with the action waiting for a new tap. Dismissing the gate MUST keep the selection and book nothing.
- **FR-023**: Any signed-in account MUST be able to book, whatever its verification status or role; an unverified account books at the full price (BR-21, US-23, BRD §6).

**Summary (FR-BKG-04, US-06, US-11)**

- **FR-024**: Before any booking is created or handed to payment, a summary MUST show: facility, unit, date, start and end time, length, what the booking covers (whole unit with the maximum participants where set, or one place), the trainer when there is one, the booker's tier in words, the price with its basis or "مجاني", and the cancellation policy.
- **FR-025**: The cancellation policy text MUST be built from the cancellation-cutoff and refund-percent settings for that unit, never fixed wording (BR-30, BR-31).
- **FR-026**: The tier and price in the summary MUST be the ones the pricing rules return for the booker at that moment (BR-15 – BR-18). When they differ from what the schedule showed, the summary MUST say so.
- **FR-027**: For an `EXTERNAL` booker the summary MUST show a short pointer to verification (or that a request is under review), and MUST NOT block the booking (BR-21, BR-24).
- **FR-028**: For a paid booking the summary's main action MUST be "متابعة للدفع". It MUST re-check availability and the booker's own conflicts, then open a "قريبًا" checkout screen with a way back to the summary. It MUST NOT create a booking, hold a place or take a payment (BR-12 is feature 6).
- **FR-029**: For a free booking the summary's main action MUST be "تأكيد الحجز". It MUST create the booking as `CONFIRMED` through the booking repository, with the tier and price at that moment stored on it (BR-17, BR-19), and MUST create at most one booking however many times it is tapped.
- **FR-030**: After a free booking is confirmed, the booker MUST see a simple success screen with a confirmation in words, the booking code (left-to-right), the facility, unit, date and time, and an action to home. It MUST NOT show a QR or the full ticket (feature 6), and going back from it MUST NOT return to the summary or allow confirming again.
- **FR-031**: Going back from the summary MUST return to the schedule with the same day, unit, trainer and selection.

**Refusals and conflicts (BR-11, BR-13, BR-14)**

- **FR-032**: Every refusal from the availability and booking repositories MUST be shown in words that say what happened and what to do next: slot taken, slot full, slot passed, outside the booking window, closed, range too long, overlap with the booker's own booking (naming that booking's facility and time), active-bookings cap reached (stating the cap), and not permitted.
- **FR-033**: For a signed-in booker, an overlap with one of their own bookings MUST be reported when they tap the slot, or the slot that would complete a range: the slot is not selected and the message names the overlapping booking (BR-13). For a guest it MUST be reported on returning from sign-in, clearing the selection. A reached active-bookings cap MUST be reported no later than continuing to the summary (BR-14). Both apply to paid and free bookings alike, and both MUST be checked again before the summary hand-off and before confirming.
- **FR-034**: When two bookers confirm the same exclusive slot or the last shared place at the same moment, exactly one booking MUST be created; the other booker MUST get the taken or full message (BR-11, US-06, NFR-09).

**Data, settings and rules (constitution III, IV)**

- **FR-035**: All slots, places left, prices, tiers and refusals MUST come through the existing repository interfaces (availability, booking, catalogue, settings, session); screens MUST NOT touch the in-memory implementations or re-implement a rule.
- **FR-036**: Every value the BRD marks as a setting and this flow uses (booking mode, capacity, maximum participants, booking window, few-left threshold, minimum lead, granularity, maximum range, session length, active-bookings cap, cancellation cutoff, refund percent) MUST be read from the settings repository with university → facility → unit inheritance, never hard-coded.
- **FR-037**: The seed data MUST let every scenario here be shown without editing data by hand: an exclusive unit with free and booked slots, a shared unit with slots that are available, few-left and full, a free facility with a taken hour, a trainer facility with a trainer at capacity while the lane has places, a closure inside the window, and seeded accounts in each tier with and without overlapping bookings. Existing seed MUST be reused; additions MUST be marked as placeholders until Dr. Sara's data arrives.
- **FR-038**: Bookings created here MUST be kept with the rest of the demo data on the device and removed by the demo-data reset (decisions.md 2026-11-16).
- **FR-038a**: The taken-slot and full-slot refusals (US-06, FR-034) MUST be covered by automated tests, and MUST be reproducible by hand on one device by booking the same slot from a second seeded account through the existing demo account switch. No dedicated simulation tool is added.

**Quality, language and accessibility (constitution II, V)**

- **FR-039**: All text MUST come from the l10n files in Arabic (default) and English, in the light Egyptian dialect, with actions as verbal nouns, Western digits, 12-hour time and "120 ج.م" / "EGP 120". New string keys MUST carry a prefix for this feature.
- **FR-040**: Every colour, size, spacing, radius and duration MUST come from tokens, and the screens MUST use the existing `DayStrip`, `SlotChip`, `StatusBadge` and `SprintButton` as documented, without adding states or restyling them. `volt` appears only as the few-left fill.
- **FR-041**: Each screen MUST have a single primary action; every state MUST carry a word or icon; every target MUST be at least 48dp with a visible focus ring on keyboard platforms and a meaningful Arabic screen-reader label; text MUST scale to 200%; motion MUST respect reduce-motion.
- **FR-042**: Layout MUST follow the window size classes: one column with a bottom action on compact; inside the details pane beside the facilities list from medium up; the selection and its main action beside the grid on expanded and large windows, with the summary as its own screen at every width. State MUST survive resize, rotation and fold or unfold, and hinges MUST be respected.
- **FR-043**: Navigation bars, back gestures, sheets, dialogs, haptics and scroll physics MUST follow the platform (adaptive.md); booking codes, when shown, MUST be wrapped as left-to-right text.

### Key Entities *(include if feature involves data)*

- **Facility**: decides the booking path (paid slot, free range, or trainer) and whether a payment step follows. Read only.
- **Bookable unit**: the lane, pitch or hall whose slots are shown; carries the booking mode, capacity and maximum participants through settings.
- **Slot**: a computed period of a unit on a day, with a state (available, few left, full, past) and places left. Never stored (BRD §5).
- **Day**: one day of the booking window, with whether it has availability and whether it is closed.
- **Trainer and trainer availability**: who gives sessions, when and in which unit, and how many people a session takes.
- **Selection**: what the person has chosen so far: facility, day, unit, optional trainer, and one slot or a range. Lives in the address and survives sign-in, reload and resize.
- **Booking summary (quote)**: the selection plus the booker's tier, the price and its basis, and the cancellation policy, as they are at that moment.
- **Booking**: created here only for free facilities, as `CONFIRMED`, with unit, optional trainer, start, end, one place, and the tier and price frozen on it.
- **Refusal**: a named reason a selection or booking was not accepted, shown in words.
- **Setting**: the values above, each resolved university → facility → unit.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: From a facility page, a person reaches the schedule in 1 tap and sees the selected day's slots in under 2 seconds on seed data (NFR-09).
- **SC-002**: A signed-in booker goes from the facility page to the summary of a paid slot in at most 4 taps and under 30 seconds.
- **SC-003**: A booker completes a free range booking, from the facility page to a confirmed booking, in under 1 minute, and it appears in their upcoming bookings on home.
- **SC-004**: For every seeded unit and every day of the window, each slot's state and places left on screen match the seed hours, closures, bookings and settings in 100% of cases.
- **SC-005**: Conflicting bookings are prevented in 100% of attempts: two simultaneous confirmations of the same exclusive slot or last shared place always yield exactly one booking, and no booker ever holds two overlapping bookings.
- **SC-006**: The price and tier in the summary match the seed price for the booker's tier in 100% of the seeded units, for `INTERNAL`, `EXTERNAL` and pending-verification accounts.
- **SC-007**: A guest who selects a slot and signs in or signs up lands back on the same selection in 100% of the tested paths (sign-in, sign-up, web reload).
- **SC-008**: Changing any setting this flow uses, at university, facility or unit level, changes the schedule or summary accordingly with no other change, verified for each setting in FR-036.
- **SC-009**: Every refusal in FR-032 shows a message that names the reason; no refusal ends in a blank screen, a silent failure or a technical error text.
- **SC-010**: The schedule, trainer step and summary show no overflow or clipped text at all four window size classes, in Arabic and English, in light and dark, at 200% text scale, and every action is reachable by keyboard and by screen reader.
- **SC-011**: The selection is identical after going to the summary and back, rotating, resizing and folding, in 100% of the tested transitions.
- **SC-012**: The three booking paths can be walked from a cold start on seed data alone in under 4 minutes, each from the facility page to its end (summary hand-off or confirmed booking) with no dead end, so the flow can be shown to Dr. Sara now and recorded on video for the defense later.

## Out of scope

This feature is UI-only on mock data and delivers the schedule, selection and summary. These are explicitly not part of it:

- **Backend**: no Supabase, no Firebase, no server, no real database, no real-time channel and no real push. Slots and bookings come from the in-memory repositories on seed data, which enforce the rules the backend will enforce later (BR-11, NFR-05).
- **Real payments**: none. Payments in P1 are sandbox only, and even the sandbox is feature 6.
- **Checkout, Hold and payment** (feature 6): the Hold and its countdown (BR-12, FR-BKG-05), `PENDING_PAYMENT` and `EXPIRED` bookings, `PaymentProvider`, payment success and failure (FR-PAY-01, FR-PAY-02, US-10), receipts, and the second half of US-06 ("pays successfully → `CONFIRMED`"). A paid booking stops at the summary and a "قريبًا" checkout screen.
- **The confirmation ticket** with booking code and QR (FR-MYB-01, US-12) and the booking-confirmed notification: feature 6 and feature 7.
- **My bookings, cancellation, refunds, reminders, notifications centre and profile** (US-13, US-14, FR-MYB-02, FR-MYB-03, FR-NTF, FR-PAY-04): feature 7. The cancellation policy is only displayed in the summary.
- **SMS and any paid service**: not used in P1.
- **Trainer tools** (dashboard, QR scan, manual attendance, US-15 – US-17): feature 8.
- **Admin tools** (facility bookings, administrative cancellation, hours and closures, prices, settings panel, trainer availability, roles, US-18 – US-20, BR-04): feature 9. Settings are read here and changed only through the existing demo settings inspector.
- **Offers and discounted prices** (BR-20, US-24, FR-MKT): feature 10. No offer tag or struck-through price shows.
- **Reports, KPIs, assets and damage reports**: feature 10.
- **Lottie moments** (booking success, empty states): feature 11. Static icons and text are used for now.
- **Booking more than one place, booking for someone else, transferring a booking, waiting lists, recurring bookings and editing a booking's time**: not in the BRD (BR-03, BR-38).
- **An "any trainer" option, trainer ratings and trainer search**: not in the BRD; BR-09 says the trainer is chosen first.
- **Calendar export and add-to-calendar**: not in the BRD.
- **Real facility data**: Dr. Sara's facilities, hours, prices, trainers and capacities arrive later; seed placeholders stand in.
- **Anything from P2**: university system integration, SMS, the university's e-collection platform.

## Assumptions

- **The rules already exist behind the repositories.** The Foundation built the slot generation, availability, conflict, pricing and hold rules and the booking and availability repositories on seed data. This feature builds the screens on them and extends the rules or seed only where a scenario here cannot be shown otherwise.
- **Paid bookings create nothing here** (see Scope decisions). The consequence is that US-06's "one of two simultaneous bookers wins" is demonstrated in this feature through the re-check before the summary hand-off and through free bookings; the paid version with a Hold is demonstrated in feature 6.
- **Overlaps with the booker's own bookings are reported at the tap, not drawn on the chip (settled in clarify, 2026-11-16).** The slot component has no state for it, and adding one changes the design system, which is a separate decision.
- **Closed slots are not drawn.** A closure removes its slots from the grid (BRD §5: "the slots in it disappear"); only a wholly closed day is shown as closed, on the day strip.
- **A range is within one unit and one day.** BR-08 speaks of consecutive hours; ranges across units or across midnight are not offered.
- **The trainer path is one session per booking**, in the unit the chosen trainer's schedule gives that session (a trainer is in one unit at a time), at that unit's price for the booker's tier. There is no separate trainer fee in the BRD.
- **"Refreshed live or on opening" (FR-AVL-02) means on opening and at the moments in FR-009** in P1. Live push of other people's bookings needs the backend.
- **The current user, their tier and the account gate come from feature 003** as built; this feature does not change them.
- **The defense is shown as a recorded video of the working system** (Osman, 2026-11-16), after the backend is connected. This UI phase is for showing Dr. Sara, so each flow must run to its end without dead ends, and no on-stage demo tools are built for it.
- **Platforms checked** are web, macOS, Android and iOS, as in earlier features.
- **The stack and architecture** are those fixed in `CLAUDE.md` and the constitution. This spec states outcomes; where the code lives and how it is built belongs to the plan.
- **Open BRD §11 items stay settings.** The maximum free range (default 3 hours), lanes starting `SHARED`, and pricing an exclusive pitch on the booker's tier only (BR-18) are used at their BRD defaults and are not decided here.
