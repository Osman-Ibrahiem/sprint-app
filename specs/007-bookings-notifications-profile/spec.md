# Feature Specification: My Bookings, Cancellation, Notifications, Account and Search

**Feature Branch**: `claude/007-bookings-notifications-profile-7c3ba5` (spec directory `007-bookings-notifications-profile`)

**Created**: 2026-11-18

**Status**: Draft

**Input**: User description: "Feature 007 — my bookings, booking details and cancellation, notifications centre and reminders, account and edit profile, catalogue search (US-13, US-14, US-01 search). Design pack in `specs/007-bookings-notifications-profile/design-pack/` (delete before merge). Replaces `BookingsPlaceholder` and `ProfilePlaceholder`."

**BRD coverage**: FR-MYB-02 (upcoming and past bookings, cancel when allowed), FR-MYB-03 (profile: data, photo, verification status, language; edit name and photo), FR-NTF-01 (in-app records of confirmation, reminder, cancellation and verification decisions; real push is P2), FR-NTF-02 (notifications centre), FR-PAY-04 (refund on cancel), FR-CAT-05 (new: catalogue search), FR-CAT-03 (Home's upcoming bookings now lead somewhere). User stories: **US-13** (complete), **US-14** (complete), **US-01** (search added), **US-12** (the booking-confirmed record appears in the centre). Business rules: BR-17 (tier and price are frozen on the booking), BR-30, BR-31, BR-32, BR-39, BR-40, BR-41, BR-45, BR-48 (new), BR-26 (the rejection reason is shown), NFR-06 (no national ID on any screen here). NFRs: NFR-01, NFR-02, NFR-03, NFR-04, NFR-05, NFR-09, NFR-10, NFR-13. Builds on `specs/001-foundation/` (repositories, settings, rule services, shell), `specs/002-design-system-widgets/` (`StatusBadge`, `BookingTicket`, `SprintButton`, `SprintTextField`, `AppNavigation`), `specs/003-auth-verification/` (account, tier, verification notifications), `specs/004-facility-catalogue/` (facility list, filters, details) and `specs/006-checkout-hold-payment/` (ticket, receipt, Hold, payments).

**Design source**: Figma file `xeuMQ0KyXsXVh4QldmkbDf`, pages Compact, Medium and Expanded & Large. Sections and frames: "My bookings" (and `· past`, `· empty`, `· upcoming empty`, `· past empty`), "Booking details" for every status, "Booking states", "Cancellation & refund states · Compact", "Notifications" (and `· empty`, `· reminder with cancel`, `· reminder after cutoff`, `· verification`), "Account" (booker, guest, loading, language and appearance sheets or popovers, sign out dialog), "Edit profile" (and `· no changes`, `· photo set`, `· name error`), "Permission · notifications", "Push · reminder", "Search" (`empty`, `typing`, `results`, `suggestions`, `no results`). Components on the Components page: `NotificationBell`, `NotificationCard`, `BookingRow`, `SegmentedControl`, `SettingsRow`, `Avatar`, `Banner`, `WideDialog`, `Popover`, `TextField` (`locked`, search `filled`), `Skeleton` (`profile-card`, `settings-row`). The spec describes no screen; the design pack is the layout reference.

## Scope decisions

These are settled with Osman on 2026-11-18 (see `docs/decisions.md`) and are not reopened here.

- **Who sees what.** A signed-in booker on a compact window sees four tabs (الرئيسية، المنشآت، حجوزاتي، حسابي) and a notification bell with an unread badge in the header of each of the four root screens. From the medium window class up, notifications is a destination in the rail or sidebar (with the badge) and there is no bell. A guest has neither the bell nor a notifications destination; the "حجوزاتي" and "حسابي" tabs keep leading a guest to the account gate and the guest account card. Other roles (trainer, admin) keep their own destinations; this feature does not change them.
- **Cancellation is decided by rules, shown by wording.** Whether the cancel action exists (BR-30), how much comes back (BR-31) and by whom the booking was cancelled (BR-32) are computed by the cancellation rules behind the booking repository from `cancellationCutoffHours` and `refundPercent` (inheriting university → facility → unit). Screens never hard-code a time or an amount.
- **Four cancel cases.** Full refund (100%), partial refund (`refundPercent` below 100), no refund (0%), and free booking (nothing was paid, so nothing comes back). "Free" is decided by the frozen price being zero, not by the facility type. Cancelled by the facility is always a full refund (BR-32) and shows its own reason.
- **Cancelling a booking still waiting for payment (BR-48, new).** While the Hold is running and no payment is being processed, the booker can cancel from the booking details: the booking becomes `CANCELLED` (cancelled by the booker, no refund because nothing was paid) and the place returns to everyone at once. During "جاري تأكيد الدفع" the action is not offered (BR-47). The BRD state diagram and rules are updated in this PR.
- **Reminders without a backend.** A reminder checker runs when the app opens, every 60 seconds while it is open, and when it returns from the background. It writes one reminder record per confirmed booking when the booking enters the window `reminderLeadMinutes` before its start. A demo action brings the next confirmed booking into that window on demand. The cancel action inside a reminder is decided when the reminder is shown, from the booking's current state, never stored in the record (BR-40).
- **Notification kinds shown.** Booking confirmed, reminder, cancelled by the facility, cancelled by me (recorded already read), verification under review, verification approved, verification rejected (with the reason, BR-26). There is no offer kind (US-24 is later).
- **The permission prompt is simulated.** The notification permission dialog appears once, remembers the answer on the device and changes nothing real, since there is no push in P1.
- **Edit profile.** Name and photo are editable; email and phone are shown locked with a line explaining they are tied to signing in. Changing them is not part of P1.
- **Search.** The booker or guest searches facilities by name, type and owning unit. Results are ordered by places available today (then by name). With an empty field, suggestions show the two most booked facilities (confirmed bookings in the last 30 days across the demo data, ties by name) and the last five searches kept on the device. Static art replaces the Lottie moments.
- **Settings are read, never hard-coded:** `cancellationCutoffHours`, `refundPercent`, `reminderLeadMinutes`, `fewLeftThreshold`, and the existing ones, all inherited.
- **Booking codes** are `SP-1xxx` everywhere (decisions of 2026-11-17); Figma's older samples are examples only.
- **Where a string differs between Figma and the design pack,** the design pack wins; where the design pack is silent, `docs/design-system/README.md` copy rules apply.

## Clarifications

### Session 2026-11-18

- Q: What does the Account row "الإشعارات" (shown with the value "مفعّلة") do? → A: It shows "مفعّلة" or "متوقفة" from the simulated permission answer stored on the device, and tapping it opens the same permission dialog to change the answer. The notifications centre, the bell and the badge are not affected by it (in-app records are always kept).
- Q: When the booker cancels their own booking, do they get a notification in the centre? → A: Yes, a seventh kind "تم إلغاء حجزك" (with the refunded amount when there is one), recorded as already read because the booker did it themselves, so it does not raise the badge; tapping it opens the booking details.
- Q: Is there a "report a problem" action on past bookings? → A: No; out of scope for this feature (default confirmed, no objection).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See my bookings, upcoming and past (Priority: P1)

A signed-in booker opens "حجوزاتي" and sees their upcoming bookings first, with a switch to past ones. Each booking shows the facility, date and time, status and code. From Home, the upcoming-bookings section and "كل حجوزاتي" lead here. On a wide window the list sits beside the details of the selected booking.

**Why this priority**: Today the tab is a placeholder that even tells a signed-in booker to sign in; every booking flow dead-ends here.

**Independent Test**: Sign in as the demo booker, open "حجوزاتي": upcoming bookings appear in time order, "السابقة" shows finished, cancelled and expired ones, and tapping any row opens its details.

**Acceptance Scenarios**:

1. **Given** a booker with upcoming and past bookings, **When** they open "حجوزاتي", **Then** "الجاية" is selected, the bookings are ordered by start time, and each row shows its status with a word and an icon.
2. **Given** the same booker, **When** they switch to "السابقة", **Then** attended, no-show, cancelled and expired bookings show, newest first.
3. **Given** a booker with no bookings at all, **When** they open the tab, **Then** an empty state with "استعراض المنشآت" appears; **given** only past bookings, **then** "الجاية" shows its own empty message and "السابقة" stays usable; **given** only upcoming, **then** "السابقة" shows its own empty message.
4. **Given** the Home screen with upcoming bookings, **When** the booker taps a booking or "كل حجوزاتي", **Then** they land on that booking's details or on this list.
5. **Given** a medium or larger window, **When** the list opens, **Then** the first booking is selected and its details show beside the list, and with no bookings in the chosen segment a short "مفيش حجز محدد" message shows in the detail area.
6. **Given** a guest, **When** they tap "حجوزاتي", **Then** the account gate appears (unchanged from feature 3), never an empty list.

---

### User Story 2 - Open a booking and understand its state (Priority: P1)

The booker opens a booking and sees everything about it: facility, unit, trainer if any, date and time, tier and frozen price, booking code and QR, and what they can do next, according to its status.

**Why this priority**: There is no booking details screen; the confirmation ticket exists only right after payment.

**Independent Test**: Open one booking in each status (confirmed, pending payment, attended, no-show, cancelled, expired) and verify the content and the actions listed below.

**Acceptance Scenarios**:

1. **Given** a confirmed booking before its cutoff, **When** opened, **Then** the ticket with QR and code shows, with the cancel action.
2. **Given** a confirmed booking after its cutoff, **When** opened, **Then** the cancel action is not shown and a line explains until when cancelling was possible.
3. **Given** a booking waiting for payment, **When** opened, **Then** the Hold countdown and "إكمال الدفع" lead to checkout, and "إلغاء الحجز" shows only while holding.
4. **Given** attended, no-show, cancelled or expired bookings, **When** opened, **Then** each shows its own neutral banner (no penalty wording for no-show, BR-37), the amount paid or "ما اتدفعش", and no QR action that implies check-in is still possible.
5. **Given** a paid, confirmed booking, **When** opened, **Then** the receipt (feature 6) is reachable.
6. **Given** a link to a booking that is not the signed-in booker's, **When** opened, **Then** a not-found state shows and nothing is revealed (NFR-05).

---

### User Story 3 - Cancel a confirmed booking and get the right refund (Priority: P1)

Before the cutoff, the booker cancels a confirmed booking after a confirmation that states exactly what they get back. After cancelling, a result screen confirms it.

**Why this priority**: Self-cancel is the BRD's answer to inflexible scheduling (US-13), and `BookingRepository.cancel` has no screen.

**Independent Test**: With the demo settings, cancel a paid booking at 100%, change `refundPercent` to 50 and 0 and cancel again, then cancel a free booking; check amount, wording and the notification each time.

**Acceptance Scenarios**:

1. **Given** a confirmed paid booking before the cutoff and `refundPercent` 100, **When** the booker confirms the cancel, **Then** the booking is `CANCELLED`, the full paid amount is refunded to the same method, the place is released, and the result says so.
2. **Given** `refundPercent` 50, **Then** the dialog says "هترجع X من Y ج.م" with X computed, and the result matches; **given** 0, **then** the dialog and result say nothing returns.
3. **Given** a free booking, **Then** the dialog says the place is released and nothing is charged or returned, and no refund line shows.
4. **Given** a cancel attempt after the cutoff passed while the dialog was open, **Then** the booker sees "فات وقت الإلغاء" and nothing changes.
5. **Given** a booking cancelled by the facility (demo action), **Then** the details and the notification state the cause, the refund is 100% whatever the settings (BR-32), and the booker is told they were notified at once (BR-41).
6. **Given** any cancel, **Then** the money line states the refund goes back to the same payment method (BR-31) and promises no time.

---

### User Story 4 - Cancel a booking I haven't paid yet (Priority: P1)

The booker who started a booking and changed their mind cancels from the booking details while the Hold runs.

**Why this priority**: The Figma flow draws it, and leaving a held booking half-open otherwise leaves a booker with no way to release it except waiting.

**Independent Test**: Start a paid booking, open it from "حجوزاتي", cancel it with the short confirmation; the place is free again for another booker immediately and the booking shows "اتلغى".

**Acceptance Scenarios**:

1. **Given** a booking holding with no payment pending, **When** cancelled with confirmation, **Then** the status is `CANCELLED`, cancelled by the booker, no refund, and the place is available to others at once.
2. **Given** a payment being confirmed by the provider, **Then** the cancel action is not shown (BR-47).
3. **Given** the Hold ended meanwhile, **Then** the booking shows as expired and no cancel is offered.

---

### User Story 5 - See my notifications and know what is new (Priority: P1)

The booker sees a bell with a count of unread notifications (a tab with a badge on wider windows). The centre lists notifications newest first; unread ones stand out; a "تعليم الكل كمقروء" action clears the count; tapping one opens what it is about.

**Why this priority**: Notifications exist only as a repository; the confirmation, reminder and cancellation records written by earlier features have no screen.

**Independent Test**: Book, wait for or trigger a reminder, cancel by the facility (demo), and have a verification decision; the centre shows each, the badge counts correctly, and tapping each leads to the right place.

**Acceptance Scenarios**:

1. **Given** unread notifications, **When** the booker looks at any root screen on a compact window, **Then** the bell shows the count; with none unread the bell has no badge, and while content loads there is no badge.
2. **Given** the centre, **When** opened, **Then** notifications are newest first with kind, short text and time; opening a notification marks it read.
3. **Given** "تعليم الكل كمقروء", **When** used, **Then** all become read and the badge disappears.
4. **Given** a booking-related notification, **When** tapped, **Then** it opens that booking's details; a verification notification opens the account's verification area; a rejected verification shows its reason (BR-26).
5. **Given** no notifications, **Then** an empty state shows.
6. **Given** a guest, **Then** no bell and no notifications destination exist.
7. **Given** a window class change (for example a fold), **Then** the bell becomes the destination or the reverse, and the unread state and scroll position are kept.

---

### User Story 6 - Get a reminder with a cancel option while it still applies (Priority: P1)

Before a confirmed booking starts, the booker receives a reminder record (and, on first use, is asked once about notification permission). The reminder offers cancelling only if the cutoff has not passed when it is shown.

**Why this priority**: US-13's first criterion and BR-40; with the defaults the cancel window inside a reminder is only about an hour, so display-time evaluation matters.

**Independent Test**: Use the demo action to bring a confirmed booking into the reminder window, open the reminder before the cutoff (cancel shown) and again after (cancel hidden, a line says it closed).

**Acceptance Scenarios**:

1. **Given** a confirmed booking entering the `reminderLeadMinutes` window, **Then** exactly one reminder is recorded, even if the checker runs many times or the lead setting changes afterwards.
2. **Given** a reminder shown before the cutoff, **Then** it offers "إلغاء الحجز"; **given** after the cutoff, **Then** the action is gone, a line says the cancel closed, and tapping the reminder opens the booking.
3. **Given** a booking cancelled or finished, **Then** its reminder keeps showing without the action.
4. **Given** the first time the booker reaches the notification permission step, **Then** the dialog shows once and the answer is remembered; declining changes nothing visible except that choice being stored.
5. **Given** the reminder text, **Then** the lead time in words comes from the setting, not from the text.

---

### User Story 7 - My account: details, verification, language, theme, sign out (Priority: P1)

The booker opens "حسابي" and sees their details, verification status, price tier, language and appearance choices, a way to edit, and sign out with confirmation. A guest sees an invitation to sign in or sign up.

**Why this priority**: The tab is a placeholder with no edit, and FR-MYB-03 asks for data, photo, verification status and language.

**Independent Test**: Walk each verification state, change language and appearance, sign out, and open as a guest.

**Acceptance Scenarios**:

1. **Given** a signed-in booker, **Then** name, photo or initial, email, verification status (not verified, under review, verified, rejected, expired) with its tier wording, and the entry to the verification request (feature 3) show; no national ID or ID photo appears (NFR-06).
2. **Given** language or appearance, **When** changed, **Then** the whole app changes at once and the choice persists; on compact it is a sheet, on medium and up a popover.
3. **Given** sign out, **When** tapped, **Then** a confirmation shows and confirming returns to the guest state with the demo data kept.
4. **Given** a guest, **Then** the card invites sign-in and sign-up and language and appearance are still available.
5. **Given** loading, **Then** a placeholder shaped like the real screen shows, with no badge on the bell.

---

### User Story 8 - Edit my name and photo (Priority: P2)

The booker changes their name and photo. Email and phone are visible but locked with a line saying why.

**Why this priority**: FR-MYB-03 lists the photo, and BR-36 shows it to the trainer at check-in, so it must be changeable; it is P2 because the rest works without it.

**Independent Test**: Change the name, choose and then remove a photo, save; the new data shows in the account.

**Acceptance Scenarios**:

1. **Given** no change yet, **Then** "حفظ" is disabled; once the name is valid or the photo changed it is enabled.
2. **Given** a name shorter than two characters, **Then** an inline error shows and saving is blocked.
3. **Given** a photo chosen from the camera or the gallery, **Then** it shows at once and saving keeps it on the device with the demo data; removing it returns to the initial.
4. **Given** email and phone, **Then** they are not editable, are announced as read-only with the reason, and are shown left-to-right.
5. **Given** the camera is unavailable, **Then** only the gallery is offered.

---

### User Story 9 - Search facilities (Priority: P1)

From the search field on Home or Facilities, the booker or guest types a word and sees matching facilities; with an empty field they see suggestions and their last searches.

**Why this priority**: The field is a placeholder today; "find a facility" is the first thing a guest does in the demo.

**Independent Test**: Search "سباحة", a facility name, an owning unit, and a word with no match; check ordering, the empty-field suggestions, recents and the no-results state with a filter on.

**Acceptance Scenarios**:

1. **Given** an empty focused field, **Then** two suggestions "الأكتر حجزًا" and up to five recent searches show with "مسح الكل".
2. **Given** a typed word, **When** matching facility name, type or owning unit (ignoring diacritics and common Arabic letter variants), **Then** results show ordered by places available today, then by name, with the existing facility card and a result count worded by the existing plural rules.
3. **Given** results, **When** a facility is tapped, **Then** its details open (master-detail from the medium class up); the search term is added to recents.
4. **Given** a typed word, **Then** a clear button (48 touch target) empties it and "إلغاء" leaves search on a compact window.
5. **Given** no match, **Then** the no-results state shows with a "مسح الفلاتر" action when a filter is on, and no count line.
6. **Given** a guest, **Then** search works the same, with recents kept on the device.
7. **Given** a facility closed today, **Then** it still appears, after the open ones.

---

### User Story 10 - It works everywhere and every branch can be shown (Priority: P2)

Every new screen works on compact, medium, expanded and large windows, in Arabic and English, light and dark, at text scale 200%, with keyboard and screen reader; the demo can trigger a reminder and a facility cancellation on demand.

**Why this priority**: The deliverable is a recorded demo and a web link on iPhone Safari and desktop; no flow may dead-end.

**Independent Test**: Walk Stories 1–9 on each window class, language and theme; trigger each demo action.

**Acceptance Scenarios**:

1. **Given** any new screen, **Then** targets are at least 48 (except the native Apple bar), a visible focus ring shows on keyboard platforms, every state has a word or icon, and screen-reader labels are in Arabic.
2. **Given** `/demo`, **Then** "إظهار تذكير حجزي الجاي" and "إلغاء من الإدارة" exist and reset with the demo data.
3. **Given** a signed-in booker, **Then** every route from Home, the tabs, notifications and details reaches a screen with a way back; there is no placeholder or "قريبًا" left on the booker and guest paths.

---

### Edge Cases

- Two bookings at the same time, one cancelled: the other is unaffected and the freed place is offered to others.
- Cancel pressed twice quickly or from a reminder and the details together: one cancel, one refund, the second request shows the booking as already cancelled.
- A booking's start passes while its details are open: the cancel action disappears and the status updates to attended or no-show without leaving the screen.
- Time zone: all times are Cairo time (NFR-03); the cutoff and reminder are computed on that basis.
- Settings changed after a booking: the cutoff and refund use the values at the moment of cancelling; a stored reminder is not re-timed.
- Many notifications: the list stays smooth and the badge shows a capped count (99+).
- Reminder record for a booking cancelled before the window: none is created.
- Window resized or folded on a selected booking: the selection and the list scroll are kept.
- Search with only spaces, very long text, or Arabic and English mixed: handled as empty or normal text, never an error.
- Recents containing a facility that no longer exists: the term still works as a search.
- Photo too large or an unsupported file: a friendly error, and the previous photo stays.
- Offline or loading: skeleton states, never a blank page (the offline screen itself is not part of this feature).

## Requirements *(mandatory)*

### Functional Requirements

**My bookings**

- **FR-001**: "حجوزاتي" MUST list the signed-in booker's own bookings in two segments, "الجاية" (confirmed or pending payment, not yet ended) ordered by start time, and "السابقة" (attended, no-show, cancelled, expired, or ended) newest first, each row with facility, unit, date, time, status (word and icon) and code.
- **FR-002**: Each segment MUST have its own empty state; the screen with no bookings at all MUST offer "استعراض المنشآت".
- **FR-003**: From the medium window class up, the list MUST sit beside the selected booking's details with the first row selected by default; on compact, a row opens the details as a pushed screen.
- **FR-004**: Home's upcoming bookings and its "كل حجوزاتي" link MUST lead to the booking details and to this list.
- **FR-005**: A guest MUST still reach the account gate from this tab.

**Booking details**

- **FR-006**: Booking details MUST exist for every status (`PENDING_PAYMENT`, `CONFIRMED`, `ATTENDED`, `NO_SHOW`, `CANCELLED`, `EXPIRED`) showing facility, unit, trainer if any, date and time, tier and frozen price (BR-17), code, and the amount paid, or "ما اتدفعش" when nothing was paid.
- **FR-007**: A confirmed booking MUST show the ticket with QR (feature 2 and 6 components) and the receipt entry when paid; the other statuses MUST show their neutral banner and MUST NOT present check-in as possible.
- **FR-008**: The cancel action MUST show only for a confirmed booking before the cutoff (BR-30) and for a booking holding with no payment pending (BR-48); after the cutoff a line MUST state until when cancelling was possible.
- **FR-009**: A booking that is not the signed-in user's MUST NOT be readable by id or link; the screen shows not-found (NFR-05).

**Cancelling and refunds**

- **FR-010**: Cancelling MUST always go through a confirmation that states, computed from the settings and the booking, one of: full refund, partial refund (amount of total), no refund, or free (nothing charged or returned); the refund line MUST say it returns to the same method (BR-31) and MUST NOT promise a time.
- **FR-011**: Confirming a cancel MUST move the booking to `CANCELLED` with who cancelled, release the place for others at once, create the refund when money was paid, and write a notification record; it MUST be idempotent per booking.
- **FR-012**: The cancel MUST be refused with "فات وقت الإلغاء" when the cutoff has passed at confirmation time, and with an "already cancelled" state when it was done already.
- **FR-013**: A cancellation by the facility (demo action in P1) MUST always refund 100% regardless of settings (BR-32), record the cause, and notify at once (BR-41).
- **FR-014**: Cancelling a booking holding with no payment pending (BR-48) MUST set `CANCELLED` by the booker with no refund and release the place; it MUST be unavailable while a payment is being confirmed.
- **FR-015**: Every amount, time and percentage in these messages MUST come from the booking and the settings, never from text.

**Notifications**

- **FR-016**: The notifications centre MUST list the booker's notifications newest first, mark one read when opened, offer "تعليم الكل كمقروء", and show an empty state when there are none.
- **FR-017**: Notification kinds MUST be: booking confirmed, reminder, cancelled by the facility, cancelled by the booker (recorded already read, so it never raises the badge), verification under review, verification approved, verification rejected (with its reason); the kind alone decides icon, wording and where tapping leads.
- **FR-018**: On compact windows a bell with an unread badge MUST appear in the header of the four root screens for a signed-in booker; on medium and larger windows notifications MUST be a destination with the badge; a guest MUST have neither. The badge MUST hide at zero and while loading, and cap at 99+.
- **FR-019**: Reminders MUST be created by a checker that runs on app open, every 60 seconds while open and on return from the background; it MUST create at most one reminder per confirmed booking, when the booking enters the `reminderLeadMinutes` window, and none for bookings no longer confirmed.
- **FR-020**: A reminder's cancel action MUST be decided at display time from the booking's current state and the cutoff (BR-40); after the cutoff, or if the booking is no longer confirmed, the action MUST be absent and tapping MUST open the booking.
- **FR-021**: The notification permission dialog MUST appear once, simulate the choice, and store it on the device; the Account row "الإشعارات" MUST show that stored answer ("مفعّلة" or "متوقفة") and reopen the same dialog to change it, without affecting the centre, the bell or the badge.
- **FR-022**: `/demo` MUST offer an action that brings the next confirmed booking into the reminder window and one that cancels a chosen booking as the facility, both reset with the demo data.

**Account and profile**

- **FR-023**: "حسابي" MUST show the signed-in user's name, photo or initial, email, verification status with tier wording, and entries for the verification request, language, appearance, edit profile and sign out; it MUST NOT show the national ID or ID photo (NFR-06).
- **FR-024**: Language and appearance MUST change the app at once and persist, shown as a sheet on compact and a popover from medium up.
- **FR-025**: Sign out MUST ask for confirmation, then return to the guest state keeping the demo data.
- **FR-026**: A guest's account screen MUST invite sign-in and sign-up and keep language and appearance.
- **FR-027**: Edit profile MUST allow changing the name (at least two characters) and the photo (choose, replace, remove), MUST keep Save disabled until something valid changed, MUST show email and phone locked with a line explaining, and MUST store the result with the demo data. The booker's own photo is the one other roles later see at check-in (BR-36).

**Search**

- **FR-028**: Search MUST match facility name, type and owning unit, ignoring diacritics and Arabic letter variants (hamza forms, taa marbuta/haa, alif maqsura/yaa), and MUST order results by places available today, then by name; closed-today facilities MUST still appear, last.
- **FR-029**: With an empty field, the screen MUST show the two most booked facilities (confirmed bookings in the last 30 days, ties by name) and up to five recent searches with "مسح الكل"; recents are kept on the device for guests and bookers alike, newest first, without duplicates.
- **FR-030**: Search MUST show a clear button and, on compact, "إلغاء"; the result count MUST use the existing plural wording; no results MUST show the empty state, with "مسح الفلاتر" when a filter is on and no count line.
- **FR-031**: Tapping a result MUST open the facility details (beside the results from the medium class up) and add the term to recents.

**Cross-cutting**

- **FR-032**: Every new screen MUST work on compact (<600), medium (600–839), expanded (840–1199) and large (≥1200) windows, in Arabic RTL and English, light and dark, at text scale 200%, keeping selection and scroll when the window changes.
- **FR-033**: Interactive targets MUST be at least 48 (except the native Apple bar), show a visible focus ring on keyboard platforms, and carry Arabic screen-reader labels; status is never conveyed by colour alone.
- **FR-034**: All strings MUST be in the localisation files; times use Western digits and 12-hour format ("5:00 م"); money reads "120 ج.م" / "EGP 120"; booking codes, phones and emails are isolated left-to-right.
- **FR-035**: The rules for cancellation, refund, reminders and search ordering MUST live behind the repositories and rule services, enforced by the in-memory implementations as the backend will later; screens only display their outcomes.
- **FR-036**: Every route a guest or a booker can take from Home, the tabs, notifications, booking details and search MUST end on a screen with a way back; no placeholder or "قريبًا" may remain on those paths.

### Key Entities

- **Booking** (existing): gains who cancelled (booker or facility) and the cancel time, and the new transition `PENDING_PAYMENT → CANCELLED`.
- **Refund** (existing): created on cancel when money was paid, at the computed amount, with the reason (booker cancel or facility cancel).
- **Notification** (existing): its kind becomes a closed set of seven (FR-017) instead of free text; keeps read time; payload carries the booking code or the verification reference.
- **Reminder record** (derived): at most one per booking; the checker's memory of which bookings already got one.
- **User profile** (existing): gains an optional photo; name editable; email and phone read-only here.
- **Recent search** (device state): up to five terms, newest first.
- **Notification permission** (device state): asked or not, and the answer.
- **Settings** (existing): `cancellationCutoffHours`, `refundPercent`, `reminderLeadMinutes`, `fewLeftThreshold` and the others, inherited university → facility → unit.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A signed-in booker reaches any of their bookings from Home or the tabs in at most two taps, and cancels a confirmed booking in under 30 seconds on every window class.
- **SC-002**: In 100% of automated runs, a cancel produces the refund the settings dictate (100%, partial, 0%, none for free, 100% for facility cancel), frees the place for others at once, and is applied exactly once.
- **SC-003**: In 100% of automated runs, the cancel action is absent after the cutoff, in the details and inside a reminder, whatever the screen was showing when the time passed.
- **SC-004**: Each branch (reminder before and after the cutoff, facility cancel, pending-payment cancel, each verification decision, each refund case) can be reached on purpose from `/demo` or the normal flow and recorded end to end with no dead end and no code change.
- **SC-005**: The unread count always equals the unread notifications, on compact bell and wide destination alike, including after resizing.
- **SC-006**: A search with a typical word returns results in under 1 second and ordering follows FR-028 in 100% of automated runs; recents never exceed five or repeat.
- **SC-007**: Every new screen passes the walk in Arabic and English, light and dark, on all four window classes, at text scale 200% with no cut text, keyboard-only on web, and with a screen reader.
- **SC-008**: No national ID, ID photo or card data appears on any new screen, log or share (checked by tests).
- **SC-009**: No placeholder remains for "حجوزاتي" and "حسابي", and a walk of every guest and booker path from Home finds no dead end.

## Out of scope

This feature is UI-first on mock data. These are explicitly not part of it:

- **Backend**: no Supabase, no Firebase, no server, no scheduled jobs. The reminder checker, cancellation and refund rules run in the app against the in-memory repositories and move to the server later.
- **Real push and SMS**: notifications are in-app records; the permission dialog is simulated; SMS and any paid service are P2.
- **Real payments and refunds**: refunds are records on the fake provider's side; no real money moves; the university's e-collection platform is P2.
- **Offers on prices** (US-24, BR-20): feature 10.
- **Lottie animations**: feature 11; static art in the empty and success moments.
- **Refactoring features 001–006** or reconciling their screens with Figma: a separate planned refactor.
- **Trainer and admin notifications, tabs and screens** (features 8 and 9): their destinations keep their placeholders.
- **Changing email or phone** and any re-verification of them.
- **Offline screen and push-opening deep links** from outside the app.
- **Real search backend, typo tolerance beyond letter variants, voice search, filters inside search beyond the existing facility filters.**
- **Android-specific Figma frames**: not drawn; the adaptive primitives decide.
- **Anything from P2.**

## Assumptions

- **The cancel entry points** are the booking details, the reminder notification and the cancel confirmation; no swipe-to-cancel in the list.
- **"Ended" bookings** (confirmed whose time passed and not yet marked) show as upcoming until the rules mark them attended or no-show; the existing rules do the marking (BR-37).
- **Most booked** counts confirmed and attended bookings of all demo users in the last 30 days of the demo clock; the seed is extended so the order is not a tie.
- **Recents** are stored per device, not per account, so a guest and a booker share them in P1.
- **Photo storage** is on the device with the demo data; the file is downscaled and compressed.
- **Notification display time** uses the demo clock when the demo moves it.
- **`FR-CAT-05`, BR-48, the FR-MYB-03 edit rule, the verification notification kinds, and the US-13/US-14 additions** are written into `docs/BRD.md` and `docs/decisions.md` in this PR.
- **No action on past bookings** other than opening them and the receipt for paid ones (clarify 2026-11-18).
