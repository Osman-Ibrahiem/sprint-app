# Research: Auth and Verification

Each section gives the decision, why, and what else was considered. Section numbers (R1 – R16) are cited by the plan, the data model, the contracts and later by tasks.

## R1. How the demo data survives a restart (FR-013, FR-013a, FR-013b)

**Decision**: Snapshot persistence of the whole in-memory data layer. After every successful write, `InMemoryDataLayer` serialises all repositories into one JSON document with a `schemaVersion` and the `seededAt` time and saves it through a new `DemoSnapshotStore` interface. The P1 implementation, `PreferencesSnapshotStore`, uses `shared_preferences`, which the Foundation already has (local storage on web, platform preferences elsewhere). At startup the data layer loads the snapshot; if it is missing, unreadable or has another `schemaVersion`, it builds the seed as today. Saving is debounced (one write per event-loop turn) and never blocks a screen. ID card photos are saved under separate keys (R7), so a failed photo save never loses the rest of the snapshot. "إرجاع الداتا التجريبية" clears the snapshot and photo keys, keeps theme and language, and rebuilds the layer from the seed.

Freezed models get `fromJson` and `toJson` through `json_serializable` (`json_annotation` at runtime, `json_serializable` as a dev dependency), which Freezed generates directly. Enums serialise by name. Times are stored as UTC ISO strings (NFR-03).

**Why**: One mechanism covers this feature and every later feature that writes to the same layer (FR-013a), and the backend later replaces the whole layer, so nothing in presentation knows about it. A snapshot is simple to reason about and to reset.

**Alternatives considered**:
- *Replay a journal of actions over a fresh seed.* Keeps seed dates fresh, but breaks whenever an action's rules change between builds, which is exactly what happens during P1. Rejected.
- *Persist only identity and verification.* Bookings made in features 5 to 7 would vanish on reload while the account survives. Rejected: the clarify answer was "all demo data".
- *SQLite / Drift / Hive.* A real database for a layer that is thrown away when the backend arrives, plus a web worker setup for Drift. Rejected as heavier than needed.

**Consequence**: seeded relative dates stop moving once a snapshot exists (an "upcoming" booking becomes past after its day). This is acceptable for the demo; the reset action returns to fresh relative dates. Written into quickstart.

## R2. Repository boundaries for auth

**Decision**: Split the Foundation's `IdentityRepository` by responsibility and keep it backward compatible:

- `AuthRepository` (new): sign up, confirm email, resend code, sign in, sign out, request reset, reset password, current account id, and the demo-only `actAs(userId)` used by the user switcher.
- `IdentityRepository` (existing): read people and role assignments. `currentUser()` and `setCurrentUser()` move to `AuthRepository`, and every caller is moved in the same change (no temporary delegations).
- `VerificationRepository` (new, in `features/verification/`): submit, current request for a person, queue for a reviewer, decide, upload sheet, sheet batches, tier lookup.
- `EmailOutbox` (new interface): `send(Email)`. P1: `SimulatedMailbox`, which also lists messages for the demo mailbox screen. Later: a real email provider.

Every repository exposes `Stream<void> changes` so the session and screens refresh when data changes (R9).

**Why**: The backend will be Supabase or Firebase Auth for sign-in and a database for verification; keeping them apart means each is replaced independently. The outbox interface is the seam FR-023 asks for.

**Alternatives considered**: one big `AccountRepository` (simpler now, harder to swap piece by piece later); putting verification under `identity/` (the verifier screens and the sheet parser make it a feature of its own).

## R3. Passwords in the fake repositories (FR-044)

**Decision**: Store `salt` (16 random bytes, base64) and `hash = SHA-256(salt + password)` iterated 10,000 times, using the `crypto` package. Seed people share one demo password, documented once in `lib/core/seed/seed_credentials.dart` and in quickstart, hashed at seed build time; it never appears in l10n or UI.

**Why**: FR-044 forbids plain text, and the snapshot (R1) lands in browser storage. Iterated SHA-256 is enough for a fake repository; the real backend will use its own provider's hashing.

**Alternatives**: plain text (forbidden); bcrypt or argon2 packages (native or slow on web for no real benefit in P1).

## R4. Codes, resend wait and lockout (FR-005, FR-010)

**Decision**: Codes are 6 digits from `Random.secure()`, one active code per account and purpose (`confirmEmail`, `resetPassword`); a new code replaces the old. Constants live in one file, `lib/features/auth/domain/auth_limits.dart`: code life 15 minutes, 5 wrong tries, resend wait 60 seconds, lockout 5 minutes after 5 wrong passwords in a row. All times come from the app clock (`appClockProvider`), so tests move time instead of waiting. Lockout counters are kept per normalised identifier, whether or not an account exists, so the lockout itself never reveals an account (FR-010). On sign in the password is checked first; only a correct password reveals `suspended` or `needsConfirmation` (FR-011). Counters, codes and the signed-in user id are part of the snapshot (R1). Unknown identifiers on sign in and reset go through the same code path and return the same result type, so timing and message do not reveal existence (SC-009). New accounts get the `BOOKER` role at university scope when their email is confirmed (FR-004).

**Why**: Settled as constants in clarify (2026-11-16). One file keeps them in one place.

## R5. Normalising and validating input (FR-002, FR-025, edge cases)

**Decision**: Pure functions in `lib/features/auth/domain/validators.dart` and `lib/features/verification/domain/national_id.dart`, unit-tested on their own:

- Every digit field first converts Arabic-Indic (`٠–٩`) and Persian (`۰–۹`) digits to Western digits and removes spaces and dashes.
- Mobile: strips `+20` / `0020` / `20` prefix, then must match `01[0125]` followed by 8 digits; stored as `01xxxxxxxxx`.
- Email: trimmed, lower-cased, a pragmatic pattern (one `@`, a dot in the domain, no spaces).
- Name: 2 to 60 characters after trimming, at least two words, letters (Arabic or Latin), spaces and the apostrophe only.
- Password: at least 8 characters with a letter and a digit.
- National ID: 14 digits; first digit `2` (1900s) or `3` (2000s); digits 2–7 a real date not in the future; digits 8–9 a governorate code from the published list (01–04, 11–19, 21–29, 31–35, 88). No checksum: the check digit's algorithm is not published, so checking it would reject real IDs.
- Sign-in identifier: if it contains `@` it is an email, otherwise a mobile number.

**Why**: Validation is business behaviour the backend repeats; pure functions are easy to share later and to test.

## R6. The account gate and returning to the same place (FR-016 – FR-019)

**Decision**: Two entry points, one flow.

1. **In-screen actions**: `requireAccount(context, ref, reason)` returns `Future<bool>`. For a guest it shows the gate prompt in an `AdaptiveSheet` (bottom sheet on compact, dialog from medium); choosing sign in or sign up pushes the auth route on top of the current screen (`context.push`) and awaits its result. The screen underneath is never popped, so its state (selected day, selected slot, scroll) is kept. It returns `true` when the person is signed in, and the caller then shows the action ready to continue; it never performs the action itself (FR-017).
2. **Routes that need an account** (deep links): a route declares `requiresAccount` and optionally `requiredSection` in its definition. The router's `redirect` sends a guest to `/sign-in?from=<encoded location>`; after sign in, the auth flow `go`es to `from` (only if it is an in-app path; anything else falls back to Home). A signed-in person without the section sees `NoAccessScreen` (word plus icon) at that location instead of a redirect (FR-018).

My Bookings and Profile stay in the shell for guests and keep the Foundation's `SignInPrompt`, which gains the two actions and opens the gate (FR-019; Foundation contracts/routes.md rule 3 still holds: no redirect from a base tab).

The router listens to the session (`refreshListenable`), so sign in and sign out re-evaluate every route; the existing `destinationPaths` key already rebuilds the shell only when the set of sections changes.

**Alternatives**: redirect for every gated action (loses in-screen state); storing the pending action globally (complex and easy to replay by mistake).

## R7. ID card photo (FR-024, edge cases)

**Decision**: `image_picker` for camera (Android, iOS) and gallery or files (all platforms; on web and desktop it uses the file selector). The picked image is decoded and re-encoded with the `image` package (moved from dev to runtime) to JPEG, longest side 1280 px, quality 80, in a background isolate where available (`compute`; on web it runs inline). Typical result is under 250 KB. Only image types are accepted. The bytes are held by `VerificationRepository` and saved under their own key (R1). If the store refuses the photo (quota on web), the request is still kept and the person sees "الصورة متحفظتش، ممكن تبعتها تاني" with a retry.

**Why**: Smallest set of well-maintained packages that covers all six targets; resizing keeps local storage within the web quota (about 5 MB per origin) for the handful of demo requests.

**Alternatives**: `file_picker` (no camera); keeping original photos (several MB each, breaks the web quota quickly).

## R8. CSV sheet upload (FR-036 – FR-038)

**Decision**: `file_selector` to pick a `.csv` file on every platform; the `csv` package to parse (quotes, commas inside quotes, CRLF), after stripping a UTF-8 BOM. Columns in order: national ID, code, type. A first row is treated as a header if its first cell is not 14 digits after normalising. Type accepts `student / staff / faculty` and Arabic `طالب / موظف / عضو هيئة تدريس`. Each row is validated with R5's national ID rule; invalid rows are reported with their 1-based row number and a reason code. Parsing is a pure function `parseVerificationSheet(String) → SheetParseResult`, behind `VerificationSheetParser` so the real format from student affairs can replace it (BRD §11 open question).

Sheet rows are tagged with the uploader's scope (unit id, or none for university scope). Matching (FR-026, FR-037) requires national ID, code and type to match a row that applies to the request's owning unit (a row with no unit applies to all).

## R9. Session and tier that stay current (FR-012, FR-040 – FR-042)

**Decision**: `SessionNotifier` (Foundation) gains `signIn`, `signOut` and `actAs`, and listens to `AuthRepository.changes`, `IdentityRepository.changes` and `VerificationRepository.changes` to reload. `Session.tier` is no longer a stored field: `Session` keeps the person's `Verification` and computes the tier through one function, `tierFor(user, verification, now)`, which extends the Foundation's `tierAt` with the account status (suspended is external). `SessionNotifier` schedules a single timer for the verification's `expiresAt` and reloads when it fires, so expiry during a session shows at once (edge case).

`InMemoryBookingRepository` already freezes `tierAtBooking` and `priceAtBooking`; it switches to `tierFor` so feature 5 uses the same answer. A test proves no booking changes when verifications change (SC-007).

## R10. Role-driven sections for verifiers and super admins

**Decision**: `sectionsFor` adds `AppSection.verification` for `SUPER_ADMIN` as well as `VERIFIER` (FR-031). The verification destination is registered in `destinationRegistry` (the Foundation's extension point), so no role is named in shell code. `AppNavigation` already handles more than five destinations with its overflow ("المزيد") on compact.

Scope filtering (FR-032) is enforced inside `VerificationRepository.queue(reviewerId)` and `decide`, from the reviewer's `RoleAssignment`s, not in the screen. The screen shows what the repository returns; a direct link to a request outside scope gets `NoAccessScreen`.

## R11. Notifications and audit (FR-034, FR-037)

**Decision**: Reuse the Foundation's `NotificationRepository.push` with types `verification.approved` and `verification.rejected` (the seed already has `verification.pending`), payload with the reason or expiry. Reuse `AuditLogRepository.append` with actions `verification.approve`, `verification.reject`, `verification.autoApprove`, `verification.sheetUpload` and before/after status. Automatic approvals from a sheet record the uploader as actor; automatic approvals at submit record actor `system`.

## R12. Screens and adaptive layout

**Decision**: Auth screens (sign in, sign up, confirm, forgot, reset) are full-screen routes outside the shell with an `AdaptiveAppBar` and a single centred column capped at `SprintExtras.authFormMaxWidth` (480) on every size class; the shell's navigation is not shown while signing in. The verification queue is a shell destination: list on compact and medium, list and detail side by side from expanded (FR-039), with the detail as its own route on compact so the back gesture works natively. The request form and the profile account card live under Profile. Dialogs (sign out, reject reason, reset demo data) use `AdaptiveDialog`; pickers use the platform sheet (`AdaptiveSheet`).

**Form width and photo preview**: `tokens.json` has no form-width token, and this feature does not edit `tokens.json`. Following feature 002 (research R3 there), the auth form cap (`authFormMaxWidth = 480`) and the ID card preview height (`idCardPreviewHeight = 200`) are named constants in `lib/core/tokens/sprint_extras.dart`, with a follow-up to promote them to `tokens.json` (see plan Complexity Tracking).

## R13. Widget changes needed from Feature 002

**Decision**: Small additive changes to `SprintTextField`, recorded in contracts/ui.md and the component README in the same PR (Principle I):

- a `code` type (numeric keyboard, `oneTimeCode` autofill hint, LTR, 6 characters, read as one field);
- an optional `autofillHints` override (to tell `newPassword` from `password`);
- optional `textInputAction` and `focusNode`, so forms move between fields with the keyboard and Enter submits (FR-047).

No new design-system widget. Status words with icons reuse `StatusBadge`'s visual language through a small `VerificationStatusBadge` mapping in the feature (presentation only).

## R14. Copy

**Decision**: About 110 new ARB keys in Arabic and English (FR-045, NFR-02). Buttons are verbal nouns: "تسجيل الدخول"، "إنشاء الحساب"، "تأكيد الإيميل"، "إرسال الكود تاني"، "استرجاع الباسورد"، "حفظ الباسورد"، "تسجيل الخروج"، "طلب التوثيق"، "إرسال الطلب"، "تجديد التوثيق"، "قبول الطلب"، "رفض الطلب"، "رفع الشيت"، "إرجاع الداتا التجريبية". The generic sign-in error is "بيانات الدخول مش صحيحة". A `copy-review.md` like feature 002's lists every key with both languages for Osman.

## R15. Tests and guards

**Decision**:
- Unit: validators and national ID (R5), password hashing (R3), codes and lockout with a fake clock (R4), sheet parser (R8), verification rules order (FR-026), scope filtering (FR-032), `tierFor` and expiry (R9), snapshot round trip and fallback on corrupt or older data (R1).
- Repository contract tests run against the in-memory implementations, written so the backend implementation can run the same suite later.
- Widget: each screen in Arabic and English, Light and Dark, compact and expanded, 200% text, keyboard order, semantics labels, and the error states.
- Router: guest deep link to a gated route returns to it after sign in; base tabs never redirect; no-access screen for a missing role; the gate keeps the underlying screen's state.
- Privacy guard (SC-006): a test pumps every screen reachable by each seed role and asserts no full seed national ID text and no ID card image appear outside the verifier's screens.
- Acceptance: one test per BRD acceptance scenario of US-02 to US-05 (SC-005), named after it.
- Existing guards (ARB parity, source scan, no platform checks, widgets presentation-only) cover the new files unchanged.

## R16. Delivery order and what the PR contains

1. Docs first: `docs/decisions.md` gets the persistence decision (clarify Q3) and the verifier-scope decision (clarify Q1); `docs/design-system/components/TextField/README.md` gets the `code` type (R13).
2. Serialisation and snapshot store (R1), with the reset action in the demo area.
3. Auth repository, validators, mailbox, session changes (R2 – R5, R9).
4. Auth screens and the gate (R6, R12), then the demo mailbox and code notice.
5. Verification repository, parser and rules (R7, R8, R10, R11).
6. Request form and profile account card; verifier queue, detail and upload.
7. Tests and the copy review; evidence (screens on web, macOS, Android, iOS) like features 1 and 2.

New packages (exact versions fixed with `flutter pub add` at implementation): runtime `json_annotation`, `crypto`, `image_picker`, `file_selector`, `csv`, and `image` moved from dev to runtime; dev `json_serializable`. None is imported by the first route, so the Foundation's web splash target (SC-011) is not affected; this is measured again before the PR.
