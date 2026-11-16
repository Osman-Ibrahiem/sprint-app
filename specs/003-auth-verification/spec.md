# Feature Specification: Auth and Verification

**Feature Branch**: `003-auth-verification` (spec directory `003-auth-verification`)

**Created**: 2026-11-16

**Status**: Draft

**Input**: User description: "Feature 003: Auth and verification (UI on mock data, P1). Covers BRD US-01 to US-05 and the related FR/BR IDs (sign-up, email confirmation, sign-in, password reset by email, guest browsing, profile tier and verification status: default external account, verification by CSV sheet import or manual review by a VERIFIER, valid for one academic year, internal vs external price tier frozen at booking time). Built on the Feature 001 foundation and Feature 002 widgets. All auth and verification data goes through repository interfaces with fake in-memory implementations on realistic seed data; no real backend, no SMS, emails are simulated." (CLAUDE.md, suggested feature order, step 3).

**BRD coverage**: US-01 (the sign-in gate and the return to where the guest was), US-02, US-03, US-04, US-05; US-23 (an external account books at full price with no verification, shown here as the account's tier); FR-AUTH-01 – FR-AUTH-04; FR-VER-01 – FR-VER-04; BR-17 (tier is read at booking time and frozen), BR-21 – BR-27; NFR-02 (language, no hard-coded text), NFR-05 (the fake repositories enforce the same rules the server will), NFR-06 (national ID and ID card photo privacy), NFR-10 (accessibility), NFR-12 (verifier decisions and sheet uploads are audited), NFR-13 (realistic seed data). Roles and the capability matrix: BRD §6 (`GUEST`, `BOOKER`, `VERIFIER`, `SUPER_ADMIN` rows "طلب توثيق" and "مراجعة التوثيق ورفع الشيت"). Builds on `specs/001-foundation/` (shell, role-driven sections, settings with inheritance, identity repository, demo user switcher) and `specs/002-design-system-widgets/` (`SprintButton`, `SprintTextField`, `StatusBadge`, `AppNavigation`).

## Scope decisions

These were decided in this specification so that the plan does not have to guess.

- **US-01 is split.** Its first criterion (a guest sees a facility's details, 7 days of slots and both tier prices) belongs to features 4 and 5, which build those screens. This feature delivers its second criterion: a guest who tries an action that needs an account is asked to sign in or sign up, and returns to the same place afterwards. The gate is built as a reusable behaviour so features 4 to 10 use it unchanged.
- **The Foundation's demo user switcher stays.** Reviewers at the defense still need to jump between roles in one tap. It now goes through the same session as real sign-in (switching user is a sign-in without a password), and stays behind the Foundation's demo release switch. Seed people also get a sign-in password so the real form can be shown with them.
- **The verifier's screens are in this feature**, not in feature 9 (admin operations). US-05 is in Epic A and the `verification` section already exists in the role-driven navigation; leaving it empty would break the demo of US-04.
- **Profile here is account and verification only.** The Profile tab shows who is signed in, the tier, the verification status and its actions, and sign out. Editing name, phone or photo, notification preferences and the rest of the profile are feature 7 (US-13, US-14).
- **One code by email for both confirmation and password reset.** FR-AUTH-03 allows a link or a code. A short numeric code works the same on every platform without deep-link handling and is easy to show in a demo, so both flows use it.

## Clarifications

### Session 2026-11-16

- Q: When a verifier's scope is one owning unit, which requests do they see and decide, and which requests does their uploaded sheet match? → A: Only requests whose chosen faculty or department belongs to their unit, and their sheet matches only those; a university-scope verifier and `SUPER_ADMIN` see and match all.
- Q: How do reviewers read the simulated email codes at the defense? → A: Both: a simulated mailbox screen in the demo area and a demo-only notice showing the code on the code entry screen, both hidden by the demo release switch.
- Q: Do accounts and requests created during a demo survive closing the app or reloading the page? → A: Yes. All demo data and the session are saved on the device, and a confirmed "reset demo data" action in the demo area returns to the seed data. This replaces the Foundation's rule that only theme and language are saved.
- Q: Are the code and sign-in security numbers (15-minute code, 5 wrong tries, 60-second resend wait, 5-minute lockout after 5 wrong passwords) fixed or admin settings? → A: Fixed product constants, not settings; they protect accounts and are not business rules, so Principle III does not apply.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create an account and confirm the email (Priority: P1)

A new visitor (a student or an outside visitor of the same age) creates an account with their name, mobile number, email and a password. A confirmation code is sent to the email. They enter it, and the account is created with the external tier, so they can book straight away at full price (BR-21, US-23).

**Why this priority**: Nobody can book, verify or be reviewed without an account. It is the entry to every later feature and the first thing the reviewers try.

**Independent Test**: As a guest, open sign up, fill in valid details, read the code from the simulated email, enter it, and land signed in with the tier shown as external. Repeat with an email or a mobile number that already belongs to a seed person and confirm no account is created.

**Acceptance Scenarios**:

1. **Given** a guest on the sign-up form, **When** they enter a valid name, an Egyptian mobile number, an email and a password that meets the rules, and submit, **Then** a confirmation code is sent to that email and the confirmation step opens showing the email the code went to.
2. **Given** the confirmation step, **When** the correct code is entered before it expires, **Then** the account exists with the external tier, the person is signed in, and they land where they were before signing up (or Home).
3. **Given** a mobile number or an email already used by another account, **When** sign up is submitted, **Then** a clear message says the number or email is already registered, offers sign in and password reset, and no account is created (US-02).
4. **Given** the confirmation step, **When** a wrong or expired code is entered, **Then** a message says so and the person can ask for a new code after the resend wait.
5. **Given** a guest who left the confirmation step without entering the code, **When** they later try to sign in with that email, **Then** they are taken back to the confirmation step instead of being signed in.

---

### User Story 2 - Sign in from one form and land in the right place (Priority: P1)

A person with an account signs in from one form with their email or mobile number and their password. The button shows loading, then the app opens with the sections their roles allow (FR-AUTH-04): a booker sees the four base sections, a verifier also sees Verification, and so on. If something is wrong, one message says the sign-in details are not correct, without saying which field (US-03). They stay signed in when the app is reopened, until they sign out.

**Why this priority**: It is how every role reaches its part of the app, and the role-driven navigation built in the Foundation only means something once real sign-in exists.

**Independent Test**: Sign in as a seed booker by email and as a seed verifier by mobile number; confirm each sees its sections. Enter a wrong password and confirm the message does not name a field. Close and reopen the app and confirm the session is kept; sign out and confirm the app is back to a guest.

**Acceptance Scenarios**:

1. **Given** an existing account, **When** its email or its mobile number and the right password are entered, **Then** the sign-in button shows loading, and the app opens with the sections for that person's roles and scopes.
2. **Given** a wrong password, an unknown email or an unknown number, **When** sign in is submitted, **Then** the same message appears in all three cases and does not say which part is wrong.
3. **Given** a signed-in person, **When** the app is closed and opened again, **Then** they are still signed in with the same sections.
4. **Given** a signed-in person, **When** they choose sign out and confirm, **Then** the app returns to guest mode with the base sections, and staff-only screens are no longer reachable, including by direct link.
5. **Given** a suspended account, **When** its correct details are entered, **Then** sign in is refused with a message that the account is suspended, not the generic one.

---

### User Story 3 - A guest is asked to sign in and comes back to the same place (Priority: P1)

A guest browses freely. When they try something that needs an account (booking a slot, opening My Bookings, requesting verification), the app asks them to sign in or create an account, and after they do, it takes them back to exactly where they were, with what they had chosen still chosen (US-01).

**Why this priority**: Browsing without an account is a core promise of the product, and losing the guest's place at sign-in is the most common way such apps lose bookings. Every later feature relies on this gate.

**Independent Test**: As a guest, open a screen that needs an account (My Bookings, or a test action on the demo area standing in for "book this slot"), choose sign in, sign in, and confirm the app returns to that screen with its state. Repeat choosing sign up, through the email code.

**Acceptance Scenarios**:

1. **Given** a guest, **When** they trigger an action that needs an account, **Then** they see a prompt that names what needs the account and offers sign in and create account, without losing the current screen.
2. **Given** that prompt, **When** they sign in or finish sign up, **Then** they return to the screen they came from, and the action they started is ready to continue (the selection is kept; nothing is booked or paid without a new tap).
3. **Given** that prompt, **When** they dismiss it, **Then** they stay where they were as a guest, with nothing lost.
4. **Given** a guest who opens a deep link to a screen that needs an account, **When** they sign in, **Then** they land on that screen.
5. **Given** a signed-in person whose roles do not allow a screen, **When** they open it by deep link, **Then** they see a word and an icon saying they do not have access, not a blank page and not a sign-in prompt.

---

### User Story 4 - Reset a forgotten password by email (Priority: P2)

A person who forgot their password asks for a reset from the sign-in form, receives a code by email, enters it, and sets a new password. Then they are signed in.

**Why this priority**: Needed for a complete system at the defense (FR-AUTH-03 is a Must), but a person can still use the demo without it.

**Independent Test**: From sign in, choose forgot password, enter a seed person's email, read the code from the simulated email, set a new password, and confirm the old one no longer works and the new one does.

**Acceptance Scenarios**:

1. **Given** the sign-in form, **When** forgot password is chosen and an email or mobile number is entered, **Then** the app says a code was sent to the account's email if the account exists, with the same message whether or not it exists.
2. **Given** a valid code, **When** a new password that meets the rules is set, **Then** the person is signed in and the old password no longer works.
3. **Given** a wrong or expired code, **Then** a message says so and a new code can be asked for after the resend wait.

---

### User Story 5 - Request verification and see its status (Priority: P1)

A booker with the external tier asks to be priced as internal. They fill in the request: type (student, staff or faculty member), national ID, university or staff code, faculty or department, and a photo of their ID card (BR-22). If the national ID and the code match a row in an uploaded sheet, they are verified at once and see the internal tier (BR-23). If not, the request waits for a verifier, and meanwhile they keep booking at full price (BR-24). If the national ID is already used in another account's pending or approved request, the request is refused at once with a clear reason (BR-27). The Profile tab always shows the tier and the request's status in a word and an icon, with the rejection reason or the expiry date when there is one.

**Why this priority**: The two price tiers are the core of the pricing rules and of the thesis problem (fair access for students), and US-04 is a Must for the defense.

**Independent Test**: Sign in as the seed external booker, submit a request whose national ID and code are in the seed sheet, and confirm the tier becomes internal at once. Sign in as another external person, submit one that is not in the sheet, and confirm the status is "under review" and the tier stays external. Submit one with a national ID used by another seed person and confirm it is refused with that reason.

**Acceptance Scenarios**:

1. **Given** an external booker, **When** they submit a complete request whose national ID and code match a sheet row of the same type, **Then** they are verified automatically, the tier shows internal, and the expiry date is shown.
2. **Given** a request with no matching row, **When** it is submitted, **Then** its status is "under review", the tier stays external, and booking at full price is still possible.
3. **Given** a national ID used in another account's pending or approved request, **When** the request is submitted, **Then** it is refused automatically with a reason that says the national ID is already registered on another account.
4. **Given** an incomplete or invalid request (missing photo, national ID that is not 14 digits or has an impossible birth date or governorate code), **When** submit is tried, **Then** each problem is shown next to its field and nothing is sent.
5. **Given** a rejected request, **Then** the reason is shown, and the person can send a new request.
6. **Given** a verification whose expiry date has passed, **Then** the tier shows external again, the status says expired, and a renewal starts from the previous answers with a new ID card photo (BR-25, FR-VER-04).
7. **Given** a request under review, **Then** a second request cannot be sent until the first is decided.

---

### User Story 6 - A verifier reviews requests and uploads the sheet (Priority: P1)

A verifier opens the Verification section and sees the requests waiting for review in their scope, oldest first. Each request shows the person's details, the full national ID and the ID card photo (visible only to `VERIFIER` and `SUPER_ADMIN`, NFR-06). They approve, or reject with a reason that the person will see (BR-26). They can also upload a CSV sheet from student affairs or human resources; every pending request that matches a row is verified automatically, and the upload shows how many rows were read, how many requests were matched, and which rows were skipped and why (US-05).

**Why this priority**: Without it, every request that is not in a sheet stays under review forever, and US-05 is a Must for the defense.

**Independent Test**: Sign in as the seed verifier, approve one pending request and reject another with a reason; then sign in as each person and confirm the tier and the reason. Upload a sample sheet that matches a third pending request and confirm the summary and the person's new tier.

**Acceptance Scenarios**:

1. **Given** a verifier, **When** they open the review queue, **Then** they see only the pending requests in their scope, oldest first, each with its type, faculty or department and how long it has waited.
2. **Given** a pending request, **When** the verifier approves it, **Then** the account becomes internal with an expiry date from the `verificationExpiry` setting, an in-app notification is created for the person, and the decision is recorded in the audit log.
3. **Given** a pending request, **When** the verifier chooses reject, **Then** a reason is required before the rejection can be confirmed, the person sees that reason, a notification is created, and the decision is audited.
4. **Given** a valid CSV sheet, **When** the verifier uploads it, **Then** its rows are added to the sheet records, every pending request that matches a row is verified automatically, and a summary shows rows read, rows added, requests matched and rows skipped with the reason for each.
5. **Given** a sheet with wrong columns or no valid row, **When** it is uploaded, **Then** nothing is added and a message explains the expected columns.
6. **Given** a person who is not a verifier or super admin, **Then** they cannot see the Verification section, the queue, any full national ID or any ID card photo, including by direct link.
7. **Given** the national ID anywhere outside the verifier's screens (profile, lists), **Then** it is shown masked.

---

### User Story 7 - The tier is decided at booking time and frozen (Priority: P2)

Whatever happens to a person's verification, a booking keeps the tier and price it was made with (BR-17, BR-24). Feature 5 makes the bookings; this feature makes the single place that answers "what is this person's tier now?" and proves that changes to verification never touch existing bookings.

**Why this priority**: It is a business rule the booking features depend on, and the demo must show that approving or expiring a verification changes only new bookings. It is P2 because no booking screen exists yet.

**Independent Test**: Take a seed person with confirmed external bookings, approve their verification, and confirm the bookings keep the external price while the tier for a new booking reads internal. Expire a verification and confirm the reverse.

**Acceptance Scenarios**:

1. **Given** an approved verification that has not expired, **Then** the tier for a new booking is internal; in every other case (none, under review, rejected, expired, suspended account) it is external.
2. **Given** existing bookings, **When** the person's verification is approved, rejected or expires, **Then** the tier and price stored on those bookings do not change.
3. **Given** a verification approved while the person is signed in, **Then** the tier shown in the app updates without signing out and in.

---

### Edge Cases

- **Email typed in a different case or with spaces**: emails are compared without case and trimmed; the mobile number is accepted with or without the country prefix (`+20`, `0020`) and with spaces, and stored in one form (`01xxxxxxxxx`).
- **Mobile number that is not Egyptian**: refused with a message naming the expected form (11 digits starting with 010, 011, 012 or 015). Outside visitors are assumed to have Egyptian numbers in P1.
- **Arabic-Indic digits typed** (٠١٢٣…) in the mobile number, the code, the national ID or the university code: accepted and converted to Western digits, because many Arabic keyboards type them.
- **Many sign-in attempts with a wrong password**: after 5 failures in a row for the same email or mobile number, sign in with it waits 5 minutes, with the remaining time shown. Failures are counted per identifier whether or not an account exists, so the wait itself never confirms that an account exists.
- **Code asked for again and again**: a new code can be sent only after a 60-second wait (shown as a countdown); each new code replaces the previous one; a code lasts 15 minutes and allows 5 wrong tries.
- **Password visibility**: the password field can be shown or hidden; the platform's password manager and autofill can fill and save it.
- **The ID card photo**: taken with the camera on phones or picked from files on every platform; very large photos are reduced before they are kept; only images are accepted; the person can see and replace it before sending.
- **A sheet row that duplicates an existing row**: skipped and counted as a duplicate, not added twice.
- **A sheet row whose national ID is already verified on another account**: it does not verify a second account (BR-27); the matching request is refused with the same reason as in User Story 5.
- **A rejected request with a mistyped national ID**: it does not block that national ID for anyone else; only a pending or approved (including expired) request ties a national ID to an account.
- **A sheet uploaded while a person is submitting a request**: the request is matched against the sheet as it is at the moment it is received.
- **A verifier reviews a request that another verifier decided a moment before**: the second decision is refused with a message that the request was already decided, and the queue refreshes.
- **A verifier's own request**: a verifier cannot approve or reject their own verification request.
- **Expiry while signed in**: when the expiry date passes during a session, the tier reads external from that moment for new bookings.
- **Text scaled to 200% and compact width**: every form, the code entry and the review queue stay usable without horizontal scroll; the code entry wraps or shrinks instead of clipping.
- **Screen reader**: each field has its label, its error is read when it appears, the code entry is read as one field, and status badges are read as words.
- **Offline**: the fake repositories are local, so there is no network failure in P1, but every action shows the same loading and error states the backend will need.

## Requirements *(mandatory)*

### Functional Requirements

**Sign up and email confirmation (FR-AUTH-01, BR-21, US-02)**

- **FR-001**: The system MUST let a guest create an account with name, mobile number, email and password, and MUST create it only after the email is confirmed with a code.
- **FR-002**: The system MUST validate each field before submitting: name of 2 to 60 letters with at least two words; Egyptian mobile number (11 digits starting 010, 011, 012 or 015, after normalising); a valid email; a password of at least 8 characters with at least one letter and one digit. Each problem MUST appear next to its field, in a word, not colour alone.
- **FR-003**: The system MUST refuse sign up when the email or mobile number already belongs to an account, and MUST say which one is taken and offer sign in and password reset.
- **FR-004**: Every new account MUST start with the external tier and the booker role at university scope, with no verification (BR-21). The booker role MUST be assigned when the email is confirmed, so the account can book in later features.
- **FR-005**: Confirmation and reset codes MUST be 6 digits, valid for 15 minutes, allow 5 wrong tries, replace any earlier code when a new one is sent, and be resent only after 60 seconds.
- **FR-006**: An account that exists but is not yet confirmed MUST NOT be signed in; signing in with it MUST lead to the confirmation step with a new code.

**Sign in, session and sign out (FR-AUTH-02, FR-AUTH-04, US-03)**

- **FR-007**: The system MUST offer one sign-in form that accepts an email or a mobile number in the same field, and a password.
- **FR-008**: While sign in is processed, the main button MUST show its loading state and the form MUST not be submitted twice.
- **FR-009**: A wrong password, an unknown email and an unknown mobile number MUST all produce the same message, which MUST NOT say which part is wrong.
- **FR-010**: After 5 wrong passwords in a row for one identifier (normalised email or mobile number), sign in with that identifier MUST be blocked for 5 minutes and the remaining time MUST be shown. Failures MUST be counted the same way for identifiers with no account, so the lockout never reveals that an account exists.
- **FR-011**: A suspended account MUST be refused with a message that says it is suspended. The account status (suspended, unconfirmed) MUST be checked only after the password is correct, so a wrong password always gets the generic message of FR-009.
- **FR-012**: After sign in, the app MUST build its sections from the person's role assignments and scopes, using the Foundation's role-driven sections, with no extra code per role.
- **FR-013**: The session MUST be kept across app restarts until sign out, on every platform.
- **FR-013a**: The demo data MUST persist on the device across app restarts and web page reloads: accounts, passwords (hashed), verification requests, sheet rows and uploads, simulated emails, notifications, audit entries and the session, and any data later features change in the same data layer. Persistence MUST sit behind the same repository interfaces so the backend replaces it without touching screens. If saved data cannot be read (missing, corrupt, older format), the app MUST start from the seed data instead of failing.
- **FR-013b**: The demo area MUST offer "إرجاع الداتا التجريبية", behind the demo release switch, which asks for confirmation with the platform's dialog, then erases the saved data, signs out, and restarts from the seed data. Theme and language choices are kept.
- **FR-014**: Sign out MUST be reached from Profile, MUST ask for confirmation with the platform's dialog, and MUST return the app to guest mode and remove every staff-only section and route.
- **FR-015**: The Foundation's demo user switcher MUST go through the same session as real sign in, stay behind the demo release switch, and every seed person MUST also be able to sign in through the form with a demo password documented in the seed data.

**The account gate and return (US-01)**

- **FR-016**: The system MUST provide one reusable account gate: when a guest triggers an action or route that needs an account, it MUST show a prompt naming what needs the account, with "تسجيل الدخول" and "إنشاء حساب" choices and a way to dismiss it.
- **FR-017**: After sign in or sign up from the gate, the app MUST return to the screen and state the guest came from; any pending action MUST be ready to continue and MUST NOT run without a new tap.
- **FR-018**: A deep link to a screen that needs an account MUST, for a guest, open sign in and then that screen; for a signed-in person without the role, it MUST show a no-access state with a word and an icon.
- **FR-019**: The Foundation's sign-in prompt on My Bookings and Profile MUST open the gate instead of being information only.

**Password reset (FR-AUTH-03)**

- **FR-020**: The sign-in form MUST offer password reset; reset MUST accept an email or a mobile number and MUST send the code to the account's email.
- **FR-021**: The reset request MUST show the same message whether or not an account exists.
- **FR-022**: After a valid code and a new password that meets FR-002, the old password MUST stop working and the person MUST be signed in.

**Simulated email (P1 only)**

- **FR-023**: Every email the system would send (confirmation code, reset code) MUST be written to a simulated mailbox behind an interface, so a real email service can replace it without touching any screen. Reviewers MUST be able to read the code in two ways, both only behind the Foundation's demo release switch: (a) a simulated mailbox screen in the demo area listing every sent email with its recipient, subject, body and time; (b) a small dismissible notice on the code entry screen, marked as demo only, showing the current code. With the demo switch off, neither appears.

**Verification request (FR-VER-01, FR-VER-04, BR-22 – BR-27, US-04)**

- **FR-024**: A signed-in person with no pending request MUST be able to send a verification request with: type (student, staff, faculty member), national ID, university or staff code, faculty or department (from the owning units list), and an ID card photo (BR-22).
- **FR-025**: The national ID MUST be validated as 14 digits with a valid century digit, birth date and governorate code before submitting.
- **FR-026**: When received, a request MUST be checked in this order: (1) if another account has a pending or approved (including expired) request with the same national ID, refuse it automatically with that reason (BR-27); a rejected request never blocks a national ID; (2) if its national ID, code and type match a sheet row, approve it automatically (method automatic) (BR-23); (3) otherwise, mark it pending for manual review.
- **FR-027**: While a request is pending, the person MUST stay external (BR-24) and MUST NOT be able to send another request.
- **FR-028**: An approved verification MUST get its expiry date from the `verificationExpiry` setting (the next occurrence of that month and day after the approval, BRD default 31 August) (BR-25). This value MUST NOT be hard-coded.
- **FR-029**: Profile MUST show the tier and the verification status (none, under review, approved with expiry date, rejected with reason, expired) using `StatusBadge`-style word plus icon, and the next possible action (request, wait, renew, request again).
- **FR-030**: Renewal after expiry or a new request after rejection MUST start from the previous answers, require a new ID card photo, and go through FR-026 again.

**Verifier review and sheet upload (FR-VER-02, FR-VER-03, US-05)**

- **FR-031**: People with `VERIFIER` (in their scope) or `SUPER_ADMIN` MUST see a Verification section with the queue of pending requests, oldest first, showing type, faculty or department, waiting time and how it would be priced.
- **FR-032**: The verifier's scope MUST decide which requests they see and which they can decide. A verifier scoped to an owning unit MUST see and decide only requests whose chosen faculty or department belongs to that unit, and the rows of a sheet they upload MUST be tagged with that unit and match only requests of that unit. A verifier scoped to the university and a `SUPER_ADMIN` MUST see and decide every request, and their sheets match every request. A request outside a verifier's scope MUST NOT be reachable by them, including by direct link.
- **FR-033**: A request's detail MUST show the full national ID and the ID card photo only to `VERIFIER` and `SUPER_ADMIN`; everywhere else the national ID MUST be masked so only its last 4 digits show (NFR-06).
- **FR-034**: Approve MUST make the person internal with an expiry from FR-028; reject MUST require a reason of at least 10 characters. Both MUST create an in-app notification for the person and an audit log entry with who, when and the before and after status (NFR-12).
- **FR-035**: A verifier MUST NOT decide their own request, and a decision on a request already decided MUST be refused with a message.
- **FR-036**: A verifier MUST be able to upload a CSV sheet with the columns national ID, code and type (student, staff, faculty), with or without a header row, in UTF-8; each valid row MUST be added to the sheet records with the uploader and an upload batch.
- **FR-037**: After an upload, every pending request that matches a new row MUST be approved automatically (method automatic), with the same notification and audit as a manual approval.
- **FR-038**: The upload MUST end with a summary: rows read, rows added, duplicates skipped, invalid rows skipped (with the row number and reason), and requests approved. A file with wrong columns or no valid rows MUST add nothing and explain the expected columns.
- **FR-039**: The Verification section MUST work on every window size class: list then detail on compact, list and detail side by side from expanded.

**Tier at booking time (BR-17, US-07)**

- **FR-040**: The system MUST offer one way to read a person's tier at a given moment: internal only with an approved verification that has not expired and an active account; otherwise external. Feature 5 MUST use it when a booking is created and freeze the result on the booking.
- **FR-041**: Changes to a verification (approve, reject, expire, renew) MUST NOT change the tier or price stored on any existing booking.
- **FR-042**: When a person's verification changes while they are signed in, the tier shown in the app MUST update without signing in again.

**Cross-cutting**

- **FR-043**: All identity, session, verification, sheet and mailbox data MUST go through repository interfaces; P1 ships in-memory implementations that enforce every rule above (uniqueness, codes, lockout, scope, BR-27), so the backend can replace them without touching screens.
- **FR-044**: Passwords MUST never be shown, logged, stored in plain text in the fake repositories, or kept in the seed data in plain text other than the one documented demo password.
- **FR-045**: Every screen MUST use the Feature 002 widgets (`SprintButton` for actions, `SprintTextField` for inputs, `StatusBadge`-style word and icon for statuses), tokens only, platform-native dialogs, sheets and loaders, and all text from l10n files in Arabic and English, in a light Egyptian dialect with verbal-noun buttons ("تسجيل الدخول", "إنشاء الحساب", "إرسال الطلب", "قبول الطلب", "رفض الطلب").
- **FR-046**: Emails, mobile numbers, national IDs and codes MUST be shown in left-to-right isolates inside Arabic text, and their fields MUST use the right keyboard type and autofill hints.
- **FR-047**: Every form MUST be usable at 200% text, at compact width, with a keyboard (tab order, Enter submits, visible focus ring) and with a screen reader (labels, errors announced).
- **FR-048**: The seed data MUST include, besides the Foundation's people: one pending request in a second faculty (outside the seed verifier's unit, so only `SUPER_ADMIN` or a university-scope verifier can decide it), one rejected request with its reason, one unconfirmed account, one suspended account, and a sample sheet with rows that match some pending requests and rows that do not; all people fictional, with valid-format national IDs.

### Key Entities

- **Account (User)**: a person who can sign in: name, normalised mobile number, lower-case email, status (unconfirmed, active, suspended), and a password kept only in hashed form. Email and mobile number are each unique. Extends the Foundation's `User`.
- **Session**: who is signed in on this device, their role assignments and their tier now; persisted until sign out. Extends the Foundation's `Session`.
- **Email code**: a 6-digit code for one purpose (confirm email, reset password) tied to one account, with its expiry, wrong-try count and the time a new one can be sent.
- **Simulated email**: a message the system would have sent: to, subject, body with the code, sent time. P1 only.
- **Verification request (Verification)**: type, national ID, code, faculty or department (an owning unit), ID card photo, status (pending, approved, rejected, expired as derived), method (automatic or manual), reviewer, reason, decided time, expiry. Extends the Foundation's `Verification`.
- **Sheet row (VerificationWhitelist)**: national ID, code, type, who uploaded it, the upload batch, and the owning unit it applies to (none for a university-scope upload).
- **Sheet upload**: one upload: who, when, file name, and its summary counts.
- **Audit entry**: who did what to which request or batch, when, with the before and after status (from the Foundation's audit log).
- **Notification**: the in-app notice of an approval or rejection (from the Foundation's notifications).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A first-time user creates an account and confirms the email in under 2 minutes, starting from the guest Home screen.
- **SC-002**: A returning user signs in within 3 taps after opening the form (field, field, button), with autofill where the platform offers it.
- **SC-003**: In 100% of the tested cases, a guest who signs in or signs up from the account gate returns to the screen they came from with their selection kept.
- **SC-004**: A reviewer sees the full US-04 and US-05 story in under 5 minutes using the seed data: an automatic approval from the sheet, a pending request approved by hand, a rejection with its reason, and a sheet upload that approves a pending request.
- **SC-005**: Every acceptance scenario of US-02 to US-05 in the BRD passes as an automated test against the fake repositories.
- **SC-006**: No screen outside the verifier's shows a full national ID or an ID card photo, checked for every role in the seed data.
- **SC-007**: No existing booking changes tier or price after any verification change, checked over every seed booking.
- **SC-008**: Every new screen passes the Foundation's checks: Light and Dark, Arabic and English, 200% text, compact to large widths, keyboard focus and screen reader labels, with no hard-coded text, colour or size.
- **SC-009**: A wrong sign-in never reveals whether an email or mobile number is registered (same message and same flow for all three wrong cases).

## Out of scope

This feature is UI-only on mock data. These are explicitly not part of it:

- **Backend and real authentication**: no Supabase, no Firebase, no auth provider, no server-side session or token, no real database or file storage. Everything runs on the in-memory repositories behind interfaces.
- **Real email delivery**: no email service; every email goes to the simulated mailbox.
- **SMS and mobile OTP**: P2 (FR-AUTH-01, FR-AUTH-03). The mobile number is collected and validated but never verified.
- **Third-party sign in** (Google, Apple, Microsoft, university SSO): not in the BRD.
- **Real student affairs and human resources integration**: P2. In P1 the sheet is a CSV the verifier uploads by hand.
- **Real payments**: no payment, no tier price shown on a real checkout; feature 6.
- **Booking screens**: the facility details, slots, booking and checkout screens that use the account gate and the tier are features 4 to 6. This feature proves the gate in the demo area and on My Bookings and Profile.
- **The rest of Profile and notifications**: editing name, phone, email or photo, changing the password while signed in, notification preferences and the notifications screen are feature 7. This feature only creates the notifications.
- **Role management**: assigning roles and scopes is feature 9 (US-20 area). Seed role assignments are used as they are.
- **Account deletion and data export**: not in the BRD for P1.
- **Signing out other devices or listing sessions**: there is one in-memory store per device in P1.
- **Two-factor authentication and CAPTCHAs**: not in the BRD.
- **Anything from P2**: university system integration, e-collection payment, SMS.

## Assumptions

- **Seed people sign in with one demo password**, documented in the seed data and in the quickstart, never shown in the UI. The demo user switcher stays for fast role switching (see Scope decisions).
- **Code rules are product constants, not settings (settled in clarify, 2026-11-16)**: 6 digits, 15 minutes, 5 wrong tries, 60-second resend wait, 5-minute lockout after 5 wrong passwords. They protect accounts and are not business rules, so they are not in the settings registry or BRD §4; each is defined once, in one place.
- **Password rules**: at least 8 characters with a letter and a digit. The BRD does not set them; this is a common minimum that is not a burden on a phone keyboard.
- **Egyptian mobile numbers only** in P1, since outside visitors are assumed to be local (`docs/decisions.md`, 2026-11-08: outside visitors are the same age as the students).
- **Faculty or department** is chosen from the owning units in the seed data; real faculties come with Dr. Sara's data.
- **The CSV columns** are national ID, code and type, in that order. The real sheet's format is still an open question in BRD §11 ("شؤون الطلاب والموارد البشرية هيدونا شيت…"); the parser is behind an interface so the columns can change.
- **Expiry from the setting**: the expiry is the next occurrence of the `verificationExpiry` month and day after the approval, which the Foundation already registers with a default of 31 August (BR-25, still marked as an assumption in BRD §11).
- **Approval notifications are in-app records only** in P1; push delivery comes with the notifications feature and the backend.
- **The ID card photo stays in memory** for the session of the fake repository; there is no file storage in P1.
- **Landing after sign in** is the screen the person came from, otherwise Home. Staff do not land on their own section by default; their sections appear in the navigation.
- **Saved demo data replaces a Foundation rule.** `specs/001-foundation/spec.md` said only theme and language survive a restart and seed data resets on every start. Clarify (2026-11-16) changed that so a sign-in and the data a reviewer creates survive a reload; the decision is added to `docs/decisions.md` in this feature's pull request.
- **The stack and architecture** are those in `CLAUDE.md` and the constitution. This spec states outcomes; where things live and how they are built belongs to the plan.
- **Platforms checked**: web, macOS, Android and iOS, as in features 1 and 2.
