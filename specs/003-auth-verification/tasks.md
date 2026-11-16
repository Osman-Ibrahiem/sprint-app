---

description: "Task list for the Auth and Verification feature"
---

# Tasks: Auth and Verification

**Input**: Design documents from `/specs/003-auth-verification/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Included. SC-005 requires one automated test per BRD acceptance scenario of US-02 to US-05, SC-006 a privacy guard, SC-007 a booking-freeze test, and the constitution's guards cover every new file. Each story lists its tests first, and they MUST fail before the code they cover exists.

**Organization**: Grouped by user story. The phases follow dependency order, not strict priority: sign in (US2) comes first because sign up, the gate and every staff screen need a session; password reset (US4, P2) comes last because it reuses the code entry built for sign up (US1).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: US1 sign up and confirm · US2 sign in, session, sign out · US3 account gate · US4 password reset · US5 verification request · US6 verifier review and sheet · US7 tier at booking time
- Paths are relative to the repository root (single Flutter package, see plan.md)

## Rules for every task

- Tokens only; direction-aware layout; strings only in `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb`, added in both together, light Egyptian dialect, verbal-noun buttons (research R14). Settings only through `SettingsRepository` (`verificationExpiry`); code and lockout numbers only from `lib/features/auth/domain/auth_limits.dart`.
- Presentation imports domain interfaces and providers only, never `data/`. No platform checks outside `lib/core/adaptive/`. Dialogs through `AdaptiveDialog`, sheets through `AdaptiveSheet`, loaders through `AdaptiveLoader`.
- Every repository method returns `Result` from `lib/core/result/` for business outcomes, uses the app clock, and fires `changes` after each successful write (contracts/repositories.md).
- Emails, phone numbers, national IDs and codes are shown inside LTR isolates; the national ID is masked to its last 4 digits everywhere except the verifier's request detail (FR-033).
- Commit messages and the PR description cite BRD IDs. Branch: `003-auth-verification`. No force-push, no history rewrite. Do not touch Figma, `tokens.json` or fonts.

---

## Phase 1: Setup

**Purpose**: Docs first, then dependencies, so every later commit is green.

- [ ] T001 Add two entries dated 2026-11-16 to `docs/decisions.md`: (1) demo data and the session are saved on the device with a "reset demo data" action, replacing the Foundation rule that only theme and language are saved (clarify Q3, research R1); (2) a verifier scoped to an owning unit sees and decides only requests of that unit and their sheet matches only that unit, a university-scope verifier and `SUPER_ADMIN` see all (clarify Q1). Also document in `docs/design-system/components/TextField/README.md` the new `code` type (numeric keyboard, `oneTimeCode` autofill, LTR, max 6 digits, read as one field) and the optional `autofillHints`, `textInputAction` and `focusNode` props (research R13). This MUST be the first commit of the PR (constitution I)
- [ ] T002 Add runtime `json_annotation`, `crypto`, `image_picker`, `file_selector`, `csv` with `flutter pub add`, move `image` from dev to runtime, add dev `json_serializable`; add camera and photo-library usage strings to `ios/Runner/Info.plist` and `macos/Runner/Info.plist`, and the macOS file-read entitlement (user-selected, read-only) to `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` (research R7, R8)
- [X] T003 [P] Add `assets/demo/verification_sheet_sample.csv` (header `national_id,code,type`; one row matching the `ou-pe` pending request of دينا محمود, كريم السيد's row again (it is already in the seed batch, so the upload counts it as a duplicate), one row with an impossible birth date, one row for a person with no request; all fictional IDs valid per research R5) and `assets/demo/id_card_placeholder.jpg` (a plain illustrated card under 60 KB, no real person); declare `assets/demo/` in `pubspec.yaml`

---

## Phase 2: Foundational (blocks every story)

**Purpose**: Serialisation and snapshot persistence, the pure rules, the repository interfaces and in-memory implementations, the session, the router hooks and the seed. After this phase every story only adds screens and story-specific rules.

### JSON for every model (research R1)

- [X] T004 Add `fromJson` factories (Freezed + `json_serializable`, enums by name, `DateTime` as UTC ISO strings) to every Freezed model under `lib/features/*/domain/` (identity, catalogue, booking, payments, notifications, attendance, assets, audit, settings) and run `dart run build_runner build --delete-conflicting-outputs`; `MonthDay` and any non-Freezed value used in a model gets a `JsonConverter` in `lib/core/data/json_converters.dart`
- [X] T005 [P] Write `test/core/data/model_json_test.dart`: every model built by `test/helpers/domain_builders.dart` survives `toJson` → `fromJson` unchanged, including enums, nullable fields and times in UTC

### Snapshot store and data layer (research R1, contracts/repositories.md)

- [X] T006 Create the `DemoSnapshotStore` interface in `lib/core/data/demo_snapshot_store.dart` with `load()`, `save(Map<String, Object?>)`, `loadPhoto(id)`, `savePhoto(id, bytes)` (fails with `storageFull`) and `clear()` (snapshot and `photo/*` keys only; theme and language keys untouched)
- [X] T007 Implement `PreferencesSnapshotStore` in `lib/core/data/preferences_snapshot_store.dart` on `shared_preferences`: snapshot under one key as JSON, photos base64 under `photo/<id>`, every read tolerant of missing or corrupt values (returns null), quota errors mapped to `storageFull`; and an `InMemorySnapshotStore` in the same folder for tests
- [X] T008 Extend `lib/core/data/in_memory_data_layer.dart` with `toSnapshot()` (object with `schemaVersion: 1`, `seededAt`, `savedAt`, `data` holding every repository's lists by name), `InMemoryDataLayer.fromSnapshot(...)`, and `reset()`; any `schemaVersion` other than 1, or a snapshot that fails to parse, falls back to `SeedData.build`
- [X] T009 Wire persistence in `lib/core/providers/data_providers.dart`: a `snapshotStoreProvider` (overridden in `main.dart` with `PreferencesSnapshotStore`, `InMemorySnapshotStore` by default in tests), load the layer from the snapshot at startup, and save once per event-loop turn when any repository's `changes` fires; saving never blocks a frame
- [X] T010 [P] Write `test/core/data/snapshot_test.dart`: round trip of the whole seeded layer; corrupt JSON, missing snapshot and `schemaVersion: 2` each start from the seed; a write in any repository triggers exactly one save per turn; `reset()` clears snapshot and photos but keeps the theme and language preference keys; restoring a snapshot restores the signed-in user (FR-013); after signing up with a known password the saved snapshot JSON does not contain that password anywhere (FR-044)

### Pure rules (research R3, R4, R5)

- [X] T011 [P] Create `lib/features/auth/domain/auth_limits.dart` with the only definitions of: code length 6, code life 15 minutes, 5 wrong code tries, resend wait 60 seconds, 5 wrong passwords then 5-minute lockout (clarify Q4)
- [X] T012 [P] Create `lib/features/auth/domain/validators.dart`: `normalizeDigits` (Arabic-Indic `٠–٩` and Persian `۰–۹` to Western, spaces and dashes removed); `normalizePhone` (strip `+20`, `0020`, `20`; must match `01[0125]` followed by 8 digits; stored as `01xxxxxxxxx`); `normalizeEmail` (trim, lower-case, one `@`, a dot in the domain, no spaces); `validateName` ("2 to 60 characters after trimming, at least two words, letters (Arabic or Latin), spaces and the apostrophe only"); `validatePassword` ("at least 8 characters with a letter and a digit"); `identifierKind` (contains `@` → email, else phone). Each returns a typed reason, never a string
- [X] T013 [P] Create `lib/features/verification/domain/national_id.dart`: "14 digits; first digit `2` (1900s) or `3` (2000s); digits 2–7 a real date not in the future; digits 8–9 a governorate code from 01–04, 11–19, 21–29, 31–35, 88"; no checksum (research R5); plus `maskNationalId` (last 4 digits only)
- [X] T014 [P] Create `lib/features/auth/domain/password_hasher.dart`: 16-byte random salt (base64), `hash = SHA-256(salt + password)` iterated 10,000 times with `crypto`, constant-time compare (research R3)
- [X] T015 [P] Write `test/features/auth/validators_test.dart` and `test/features/verification/national_id_test.dart` covering every rule above, Arabic-Indic digits, every phone prefix form, boundary lengths, a future birth date, governorate `00` and `88`, and masking
- [X] T016 [P] Write `test/features/auth/password_hasher_test.dart`: same password and salt give the same hash, different salts differ, the plain password never appears in the output

### Domain models and interfaces (data-model.md, contracts/repositories.md)

- [X] T017 Extend `lib/features/identity/domain/user.dart`: `UserStatus` becomes `unconfirmed`, `active`, `suspended`; add `createdAt`. Add `lib/features/auth/domain/credential.dart` (`userId`, `salt`, `hash`, `failedAttempts`, `lockedUntil?`), `lib/features/auth/domain/email_code.dart` (`userId`, `purpose` of `CodePurpose { confirmEmail, resetPassword }`, `code`, `expiresAt`, `wrongTries`, `resendAfter`) and `lib/features/auth/domain/simulated_email.dart` (`id`, `to`, `subject`, `body`, `purpose`, `sentAt`), all Freezed with JSON
- [X] T018 Extend `lib/features/identity/domain/verification.dart` per data-model.md: add `id`, `nationalId`, `code` ("1–20 digits or letters"), `owningUnitId`, `photoId?`, `reviewerId?`, `submittedAt`, `decidedAt?`; keep `reason` ("required (≥ 10 chars) when `rejected`") and `expiresAt`; add derived `isExpiredAt(now)`. Create `lib/features/verification/domain/sheet_row.dart` (`nationalId`, `code`, `type`, `owningUnitId?`, `uploadedBy`, `batchId`) and `lib/features/verification/domain/sheet_batch.dart` (`id`, `uploadedBy`, `owningUnitId?`, `fileName`, `uploadedAt`, `rowsRead`, `rowsAdded`, `duplicates`, `invalid`, `approved`, `problems` as (rowNumber, reasonCode))
- [X] T019 Create the interfaces exactly as in contracts/repositories.md: `lib/features/auth/domain/auth_repository.dart` (with result types `PendingConfirmation`, `SignedIn`, `CodeSent` and failures `invalidField`, `emailTaken`, `phoneTaken`, `codeWrong(triesLeft)`, `codeExpired`, `codeDead`, `noPendingConfirmation`, `resendTooSoon(wait)`, `badCredentials`, `lockedOut(until)`, `suspended`, `needsConfirmation(email)`), `lib/features/auth/domain/email_outbox.dart`, `lib/features/verification/domain/verification_repository.dart`, `lib/features/verification/domain/verification_sheet_parser.dart`; every repository has `Stream<void> get changes`
- [X] T020 Narrow `lib/features/identity/domain/identity_repository.dart` to `users()`, `getUser(id)`, `roleAssignments(userId)` and `changes`; move `currentUser`/`setCurrentUser` callers to `AuthRepository` and `verification(userId)` callers to `VerificationRepository.current(userId)` across `lib/` and `test/` (research R2)
- [X] T021 Create `lib/features/verification/domain/reviewer_scope.dart`: from role assignments, `SUPER_ADMIN` anywhere or `VERIFIER` at `UNIVERSITY` → all units; `VERIFIER` at `OWNING_UNIT` → those unit ids (several add up); otherwise none (data-model.md, FR-032)
- [X] T022 Create `lib/features/verification/domain/tier.dart` with `tierFor(user, verification, now)`: internal only with an approved, unexpired verification and an `active` user, otherwise external; replace the Foundation's `tierAt` callers with it and delete `tierAt` (research R9, FR-040)
- [X] T023 [P] Write `test/features/verification/reviewer_scope_test.dart` and `test/features/verification/tier_test.dart` (none, pending, rejected, approved, approved and expired, suspended user)

### In-memory implementations (contracts/repositories.md)

- [X] T024 Implement `lib/features/auth/data/simulated_mailbox.dart` (`EmailOutbox`): stores messages, `list()` newest first, `latestCodeFor(email, purpose)`; subjects and bodies come from a localised template passed in at construction so the data layer has no `BuildContext`
- [X] T025 Implement `lib/features/auth/data/in_memory_auth_repository.dart` against contracts/repositories.md: uniqueness of email and phone after normalising; account created `unconfirmed` with a `confirmEmail` code sent; one live code per (user, purpose), new code replaces old; code rules from `auth_limits.dart`; `confirmEmail` sets the account `active` and creates its `BOOKER` role assignment at `UNIVERSITY` scope (FR-004); `signIn` normalises the identifier and checks in this order: lockout of the identifier → password (wrong password, unknown email and unknown phone all give one `badCredentials` and count a failure on a `SignInThrottle` kept per normalised identifier whether or not an account exists, locking per `auth_limits.dart`, FR-010) → account status (`suspended`, `needsConfirmation` which sends a new code; only after a correct password, FR-011) → success (throttle reset); `requestPasswordReset` returns `CodeSent` for unknown identifiers too; `resetPassword` replaces the hash and clears the lock; `actAs` for the demo switcher; `changes` stream; all lists, the throttles and `currentUserId` serialisable for the snapshot
- [X] T026 Implement `lib/features/verification/data/csv_sheet_parser.dart` (`VerificationSheetParser`): strip UTF-8 BOM, parse with `csv`, header skipped when the first cell is not 14 digits after `normalizeDigits`, columns national ID, code, type, type accepts `student/staff/faculty` and `طالب/موظف/عضو هيئة تدريس`, each row validated with `national_id.dart`, problems with 1-based row numbers and reason codes (research R8)
- [X] T027 Implement `lib/features/verification/data/in_memory_verification_repository.dart` against contracts/repositories.md and data-model.md: `submit` checks in order: another account has a pending or approved (including expired) request with the same national ID → auto `rejected` with reason code `duplicateNationalId` (a rejected request never blocks a national ID); match on a sheet row in scope (same nationalId, code, type; row unit null or equal to the request's unit) → auto `approved`; else `pending`; `alreadyPending` when one is pending; on any approval set `User.nationalId` from the request; approval sets `expiresAt` from `verificationExpiry` read through `SettingsRepository` ("that month and day at 23:59:59 Cairo time, in the approval's year if still ahead, otherwise the next year"); `queue`, `request`, `approve`, `reject`, `uploadSheet`, `batches`, `photo` all filtered by `reviewer_scope.dart` and refusing `ownRequest` and `alreadyDecided`; `reject` needs a reason of at least 10 characters; sheet rows tagged with the uploader's unit, duplicates skipped, every pending in-scope request matching a new row auto-approved; audit and notification side effects exactly as the table in data-model.md through `AuditLogRepository.append` and `NotificationRepository.push`; photos saved through `DemoSnapshotStore.savePhoto`, `storageFull` reported without losing the request; `tierFor(userId, at)`
- [X] T028 Wire the new repositories into `lib/core/data/in_memory_data_layer.dart` and add `authRepositoryProvider`, `verificationRepositoryProvider`, `emailOutboxProvider` and a demo-only `simulatedMailboxProvider` (returns null when `demoToolsEnabled` is false) to `lib/core/providers/data_providers.dart`
- [X] T029 [P] Write the contract suite `test/features/auth/auth_repository_contract_test.dart` as a function taking a factory, run against the in-memory implementation with a fake clock: every row of the AuthRepository table, resend wait, code expiry after 15 minutes, 5 wrong tries kill a code, lockout after 5 wrong passwords and its end after 5 minutes, the same lockout after 5 tries on an unknown email and an unknown phone, `suspended` and `needsConfirmation` only with the correct password, a confirmed account has the `BOOKER` role at university scope, unknown identifiers indistinguishable from wrong passwords (SC-009)
- [X] T030 [P] Write the contract suite `test/features/verification/verification_repository_contract_test.dart` the same way: FR-026 order, a national ID from another account's rejected request is accepted while one from a pending or expired request is refused, `alreadyPending`, scope filtering for a PE verifier, a university verifier and the super admin, `ownRequest`, `alreadyDecided`, reason length, expiry from the setting (approval on 20 August and on 1 September), sheet tagging and matching, audit and notification entries
- [X] T031 [P] Write `test/features/verification/csv_sheet_parser_test.dart`: with and without header, BOM, quoted cells, CRLF, Arabic type names, Arabic-Indic digits, wrong column count, empty file

### Session, router hooks and seed

- [X] T032 Rework `lib/core/providers/session_provider.dart`: `Session` holds `user`, `roles`, `verification` and a derived `tier` from `tierFor`; `SessionNotifier` gains `signIn` (delegates to `AuthRepository`), `signOut`, `actAs`, reloads on `changes` of the auth, identity and verification repositories, and schedules one timer at the current verification's `expiresAt` so expiry shows during a session (research R9, FR-042)
- [X] T033 Update `lib/features/identity/domain/app_section.dart` so `sectionsFor` adds `AppSection.verification` for `SUPER_ADMIN` as well as `VERIFIER` (research R10); update `test/features/identity/` expectations
- [X] T034 Add to `lib/app/router/`: `refreshListenable` bound to the session; a route-level `requiresAccount` and `requiredSection` (in `routes.dart`); the redirect for guests to `/sign-in?from=<location>` with `from` accepted only when the router recognises it as an in-app path, else `/home`; `NoAccessScreen` in `lib/app/shell/placeholders/no_access_screen.dart` (word and icon) for a signed-in person without the section; route constants in `AppPaths`/`AppRouteNames` for every path in contracts/routes.md (contracts/routes.md rules 1 – 6)
- [X] T035 Extend seed data in `lib/core/seed/`: `seed_credentials.dart` with the one demo password, hashed at seed build with `password_hasher.dart`, for every person, all `active`; in `seed_users.dart` add a person with a pending request in `ou-eng`, a person with a rejected request and its reason, an `unconfirmed` account, a `suspended` account; `seed_verification.dart` with full requests (national ID, code, `owningUnitId`, placeholder photo id) for the existing three and the new two, `دينا محمود` in `ou-pe`, a sheet batch already uploaded by the seed verifier for `ou-pe` containing كريم السيد's row (national ID, code, type `student`) and not دينا محمود's row, so كريم's live request with unit `ou-pe` is approved at once and the sample CSV's دينا row approves her on upload; update `SeedIds`; extend `test/features/seed_data_test.dart` (unique emails, phones and national IDs, every national ID valid per T013, FR-048)
- [X] T036 Add `SprintTextField` additions in `lib/core/widgets/sprint_text_field/sprint_text_field.dart` per contracts/ui.md: `SprintTextFieldType.code`, optional `autofillHints`, `textInputAction`, `focusNode`; update `test/core/widgets/sprint_text_field_test.dart` (code field semantics read as one field, LTR, digit conversion, max 6) and the gallery section in `lib/features/demo/presentation/component_gallery/sections/` to show the code type
- [X] T037 Create the shared auth UI in `lib/features/auth/presentation/widgets/`: `auth_form_scaffold.dart` (`AdaptiveAppBar`, centred column capped at `SprintExtras.authFormMaxWidth` (480, added to `lib/core/tokens/sprint_extras.dart` with `idCardPreviewHeight` 200 and a comment naming the follow-up to promote both to `tokens.json`), `AutofillGroup`, keyboard order, Enter submits, one primary `SprintButton` with loading) and `code_entry.dart` (the address the code went to in an LTR isolate, `SprintTextField` type `code`, resend with a countdown from `resendAfter`, a slot for the demo notice)

**Checkpoint**: `flutter test` green; the app runs exactly as before for guests, the demo switcher works through `actAs`, and data survives a reload.

---

## Phase 3: User Story 2 - Sign in from one form and land in the right place (Priority: P1) 🎯 MVP

**Goal**: One form, email or phone, generic error, lockout, session kept across restarts, sign out from Profile, sections from roles.

**Independent Test**: Sign in as a seed booker by email and the seed verifier by phone; compare sections; wrong password, unknown email and unknown phone give the same message; reload keeps the session; sign out returns to guest.

### Tests for US2

- [X] T038 [P] [US2] Write `test/acceptance/us03_sign_in_test.dart` with one test per BRD US-03 scenario (loading then the right sections; the same message for any wrong detail) plus suspended, unconfirmed and lockout cases
- [X] T039 [P] [US2] Write `test/features/auth/sign_in_screen_test.dart`: Arabic and English, Light and Dark, compact and expanded, 200% text without overflow, Tab order and Enter submits, semantics labels, the error announced, no double submit while loading
- [X] T040 [P] [US2] Write `test/shell/session_shell_test.dart`: after sign in the shell shows the seed person's sections (booker four; verifier plus Verification; super admin plus Verification and Administration with the overflow on compact); after sign out staff destinations disappear and a staff deep link no longer opens

### Implementation for US2

- [X] T041 [US2] Add the US2 ARB keys to `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` (sign-in title, identifier label "الإيميل أو رقم الموبايل", password label, "تسجيل الدخول", "بيانات الدخول مش صحيحة", locked message with remaining time, suspended message, "نسيت الباسورد؟", "إنشاء حساب", sign-out confirmation title, body and "تسجيل الخروج")
- [X] T042 [US2] Build `lib/features/auth/presentation/sign_in_screen.dart` on `AuthFormScaffold`: identifier field with email/username autofill, password with show/hide and `password` autofill, map each failure to its message, `needsConfirmation` goes to `/confirm-email`, success calls `TextInput.finishAutofillContext()` and goes to `from` or `/home`; links to forgot password and sign up keep `from`
- [X] T043 [US2] Register `/sign-in` in `lib/app/router/app_router.dart` outside the shell; a signed-in person opening it goes to `from` or `/home`
- [X] T044 [US2] Build `lib/features/auth/presentation/account_card.dart` (US2 part): name, masked phone and email in LTR isolates, tier, and "تسجيل الخروج" with an `AdaptiveDialog` confirmation; show it at the top of the Profile screen for signed-in people in `lib/app/shell/placeholders/profile_placeholder.dart` (status and verification actions are added in US5)
- [X] T045 [US2] Route the demo user switcher in `lib/features/demo/presentation/demo_user_switcher.dart` through `SessionNotifier.actAs`, unchanged in look (FR-015)

**Checkpoint**: US2 testable alone with seed accounts.

---

## Phase 4: User Story 1 - Create an account and confirm the email (Priority: P1)

**Goal**: Sign up with validation and uniqueness, code by simulated email, confirm, signed in as external.

**Independent Test**: As a guest sign up, read the code from the demo notice or the mailbox, confirm, see tier external; a taken email or phone shows the message and creates nothing.

### Tests for US1

- [X] T046 [P] [US1] Write `test/acceptance/us02_sign_up_test.dart` with one test per BRD US-02 scenario (new account external after confirming; taken phone or email shows the error and creates nothing) plus wrong code, expired code, resend wait and leaving before confirming
- [X] T047 [P] [US1] Write `test/features/auth/sign_up_screen_test.dart` and `test/features/auth/confirm_email_screen_test.dart` with the same cross-cutting matrix as T039, plus each field error shown next to its field in words, and the code field read as one field
- [X] T048 [P] [US1] Write `test/features/demo/mailbox_test.dart`: the mailbox screen and the demo code notice show the latest code; with `demoToolsEnabled` false neither the route nor the notice exists (FR-023)

### Implementation for US1

- [X] T049 [US1] Add the US1 ARB keys to `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` (sign-up title, name, phone, email, password labels and helpers, every validation reason, "إنشاء الحساب", "مسجل قبل كده" for email and for phone with sign-in and reset links, confirm title "تأكيد الإيميل", "بعتنا كود على", wrong, expired and dead code messages, "إرسال الكود تاني" with the countdown, email subject and body templates for confirm and reset, demo notice "للعرض بس", mailbox title "صندوق البريد التجريبي" and its empty state)
- [X] T050 [US1] Build `lib/features/auth/presentation/sign_up_screen.dart`: four fields with validation on leaving a field and on submit, `newPassword` autofill on the password, submit → `/confirm-email?email=…` keeping `from`; taken email or phone shows the message with links
- [X] T051 [US1] Build `lib/features/auth/presentation/confirm_email_screen.dart` on `CodeEntry`: confirm, resend with countdown, every failure message; success signs in and goes to `from` or `/home`
- [X] T052 [US1] Build `lib/features/auth/presentation/widgets/demo_code_notice.dart` (dismissible, "للعرض بس", the current code from `simulatedMailboxProvider`, LTR isolate; renders nothing when the provider is null) and plug it into `CodeEntry`
- [X] T053 [US1] Build `lib/features/demo/presentation/mailbox_screen.dart` (list newest first: to, subject, time in Cairo 12-hour, body with the code copyable) and register `/demo/mailbox` behind `demoToolsEnabled`; add its entry to `lib/features/demo/presentation/demo_screen.dart`
- [X] T054 [US1] Register `/sign-up` and `/confirm-email` in `lib/app/router/app_router.dart` outside the shell

**Checkpoint**: US1 and US2 together give a complete account life cycle.

---

## Phase 5: User Story 3 - A guest is asked to sign in and comes back to the same place (Priority: P1)

**Goal**: One reusable gate for actions and routes; return to the same screen with its state.

**Independent Test**: As a guest open My Bookings → sign in → back on My Bookings; a demo "book this slot" action keeps its selection through sign up; `/#/verification` as a guest lands there after signing in as the verifier.

### Tests for US3

- [X] T055 [P] [US3] Write `test/shell/account_gate_test.dart`: `requireAccount` on a guest shows the prompt over the current screen; sign in returns `true` and the screen's state (a selected item and scroll offset) is kept; dismiss returns `false` and nothing changes; sign up through the code returns too; the action is not run by the gate
- [X] T056 [P] [US3] Write `test/shell/gated_routes_test.dart`: guest deep link to a gated route goes to `/sign-in?from=…` and back after sign in; `from` with an external URL or unknown path goes to `/home`; base tabs never redirect; a booker opening `/verification` sees `NoAccessScreen` at the same location

### Implementation for US3

- [X] T057 [US3] Add the US3 ARB keys to `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` (gate title, the reasons passed by callers such as "عشان تحجز" and "عشان تشوف حجوزاتك" and "عشان تطلب التوثيق", "تسجيل الدخول", "إنشاء حساب", dismiss, no-access title and body)
- [X] T058 [US3] Build `lib/features/auth/presentation/account_gate.dart`: `requireAccount(context, ref, reason)` returning `Future<bool>`, showing `AccountGatePrompt` in an `AdaptiveSheet`, pushing `/sign-in` or `/sign-up` on top with `context.push` and awaiting the result; the auth screens pop with `true` when opened this way instead of navigating to `from`
- [X] T059 [US3] Update `lib/app/shell/placeholders/sign_in_prompt.dart` to add "تسجيل الدخول" and "إنشاء حساب" that open the gate (FR-019), keeping no redirect on base tabs
- [X] T060 [US3] Add a "book this slot" stand-in to `lib/features/demo/presentation/demo_screen.dart` that keeps a selected `SlotChip` and calls `requireAccount`, so the gate can be shown before feature 5 exists

**Checkpoint**: Features 4 to 10 can now gate any action with one call.

---

## Phase 6: User Story 5 - Request verification and see its status (Priority: P1)

**Goal**: Request form with ID card photo; automatic approval, pending or refusal; status on Profile; renewal.

**Independent Test**: As كريم submit the sample sheet's row: internal at once with expiry; another external person with no match: under review, still external; another person's national ID: refused with the reason.

### Tests for US5

- [X] T061 [P] [US5] Write `test/acceptance/us04_request_verification_test.dart` with one test per BRD US-04 scenario (in sheet → internal at once; not in sheet → under review and still full price; national ID on another account → refused with a clear reason), plus incomplete form, rejected then request again, expired then renew, and no second request while pending
- [X] T062 [P] [US5] Write `test/features/verification/request_form_test.dart` and `test/features/verification/account_card_test.dart`: every field error next to its field, photo required, owning units listed, each status shown as word plus icon (none, under review, approved with expiry date, rejected with reason, expired) with its next action, the national ID masked, cross-cutting matrix as T039

### Implementation for US5

- [X] T063 [US5] Add the US5 ARB keys to `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` (form title "طلب التوثيق", type options طالب / موظف / عضو هيئة تدريس, national ID, code, faculty or department, photo labels and helpers, every validation reason, photo source choices, "إرسال الطلب", "تجديد التوثيق", status words and their explanations, "متوثق لحد" with the date, rejection reason label, "الصورة متحفظتش، ممكن تبعتها تاني", tier words داخلي / خارجي)
- [X] T064 [US5] Build `lib/features/verification/presentation/id_card_photo_picker.dart`: camera (Android, iOS) or gallery/files (every platform) through `image_picker`, images only, re-encode to JPEG with longest side 1280 px and quality 80 using `image` in `compute`, preview at `SprintExtras.idCardPreviewHeight` and replace before sending (research R7)
- [X] T065 [US5] Build `lib/features/verification/presentation/verification_request_screen.dart` at `/profile/verification` (`requiresAccount`): the five fields with validation, owning units from `CatalogueRepository`, prefilled from the previous request on renewal or after rejection with the photo empty; submit shows the result at once (approved with expiry, under review, or refused with the reason)
- [X] T066 [US5] Build `lib/features/verification/presentation/verification_status_badge.dart` (status word plus icon in `StatusBadge`'s visual language) and finish `lib/features/auth/presentation/account_card.dart` by adding a verification slot filled from `features/verification`: tier, status, rejection reason or expiry date, and the next action (request, wait, renew, request again) linking to the request screen
- [X] T067 [US5] Register `/profile/verification` under the Profile branch in `lib/app/router/routes.dart`

**Checkpoint**: The tier changes for new bookings as soon as a request is approved.

---

## Phase 7: User Story 6 - A verifier reviews requests and uploads the sheet (Priority: P1)

**Goal**: Scoped queue, request detail with full national ID and photo, approve, reject with reason, sheet upload with summary.

**Independent Test**: As the PE verifier approve دينا and reject another with a reason; the Engineering request is absent; upload the sample sheet and read the summary; switch to each person and check tier, reason and notification.

### Tests for US6

- [X] T068 [P] [US6] Write `test/acceptance/us05_verifier_review_test.dart` with one test per BRD US-05 scenario (approve → internal and a notification; reject needs a reason shown to the user; a new sheet auto-verifies every matching pending request) plus out-of-scope request hidden and refused by direct link, own request refused, already decided refused, bad columns add nothing
- [X] T069 [P] [US6] Write `test/features/verification/review_screens_test.dart`: queue oldest first with type, unit and waiting time; list then detail on compact, side by side from expanded (FR-039); reject dialog blocks confirm until 10 characters; upload summary counts and problem rows; cross-cutting matrix as T039
- [X] T070 [P] [US6] Write `test/guards/privacy_guard_test.dart` (SC-006): for every seed role, pump every screen it can reach and assert no full seed national ID text and no ID card image appears outside `/verification/:id`

### Implementation for US6

- [X] T071 [US6] Add the US6 ARB keys to `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` (section label "التوثيق", queue title and empty state, waiting time, "قبول الطلب", "رفض الطلب", reject dialog title, reason label and minimum-length helper, already decided, own request, "رفع الشيت", expected columns help, summary labels for read, added, duplicates, invalid with row reasons, approved; notification texts for approved and rejected)
- [X] T072 [US6] Register the Verification destination in `destinationRegistry` in `lib/app/router/destinations_provider.dart` with Phosphor icons and its label, path `/verification`, `requiredSection: verification`
- [X] T073 [US6] Build `lib/features/verification/presentation/verification_queue_screen.dart` and `verification_request_detail.dart`: queue from `VerificationRepository.queue`, detail with the full national ID (LTR), the photo from `photo(...)`, type, code, unit, submitted time; approve, and reject through an `AdaptiveDialog` with the reason field; list and detail side by side from expanded, detail route `/verification/:id` on compact
- [X] T074 [US6] Build `lib/features/verification/presentation/sheet_upload_screen.dart` at `/verification/upload`: pick a `.csv` with `file_selector`, read as UTF-8, call `uploadSheet`, show `SheetUploadSummary` (counts and problem rows), and the expected-columns help on `badColumns` or `noValidRows`; list earlier batches in scope
- [X] T075 [US6] Show the in-app notifications for approval and rejection on the account card in `lib/features/auth/presentation/account_card.dart` (latest unread, marked read when seen) until feature 7 builds the notifications screen

**Checkpoint**: US-04 and US-05 can be demonstrated end to end (SC-004).

---

## Phase 8: User Story 7 - The tier is decided at booking time and frozen (Priority: P2)

**Goal**: One tier answer used by bookings; existing bookings never change.

**Independent Test**: Approve, reject and expire verifications for people with bookings; every booking keeps its tier and price.

- [X] T076 [P] [US7] Write `test/features/booking/tier_freeze_test.dart` (SC-007): for every seed booking record tier and price, then approve كريم, reject and expire others, renew one; assert no stored booking changed and `tierFor` for a new booking reflects the new state
- [X] T077 [US7] Switch `lib/features/booking/data/in_memory_booking_repository.dart` to `VerificationRepository.tierFor` when creating a booking; keep `tierAtBooking` and `priceAtBooking` frozen
- [X] T078 [P] [US7] Write `test/core/providers/session_tier_test.dart`: approval while signed in updates `Session.tier` without sign out (FR-042); passing `expiresAt` during a session turns the tier external through the scheduled timer

---

## Phase 9: User Story 4 - Reset a forgotten password by email (Priority: P2)

**Goal**: Reset by code from the sign-in form; same response for unknown identifiers.

**Independent Test**: Forgot password with a seed email, read the code, set a new password; old fails, new works.

- [X] T079 [P] [US4] Write `test/features/auth/password_reset_test.dart`: same message for known and unknown identifiers; wrong and expired code; the new password must meet the rules; old password rejected and new accepted; lockout cleared; screens pass the cross-cutting matrix as T039
- [X] T080 [US4] Add the US4 ARB keys to `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb` ("استرجاع الباسورد", the neutral "لو الحساب موجود هيوصله كود" message, new password label, "حفظ الباسورد")
- [X] T081 [US4] Build `lib/features/auth/presentation/forgot_password_screen.dart` and `reset_password_screen.dart` (on `CodeEntry` with the new password field, `newPassword` autofill); success signs in and goes to `from` or `/home`; register `/forgot-password` and `/reset-password` outside the shell

---

## Phase 10: Polish and cross-cutting

- [ ] T082 Add "إرجاع الداتا التجريبية" to `lib/features/demo/presentation/demo_screen.dart` behind `demoToolsEnabled`: `AdaptiveDialog` confirmation, then `reset()` on the data layer, sign out, back to `/home` with theme and language kept (FR-013b); test in `test/features/demo/reset_demo_data_test.dart`
- [ ] T083 [P] Write `specs/003-auth-verification/copy-review.md` in the style of `specs/002-design-system-widgets/copy-review.md`: every new key, Arabic and English, where it shows, for Osman's review before merge
- [ ] T084 [P] Add `test/features/auth/cross_cutting_test.dart` for anything the per-screen tests miss: every new screen at 200% text on a 400-wide window without overflow; every interactive element at least 48; codes, phones, emails and national IDs inside LTR isolates in Arabic; no hard-coded strings (the ARB parity and source-scan guards run unchanged)
- [ ] T085 Run the quickstart checks on web, macOS, one Android and one iOS target (camera on the phones, file pick on web and macOS, reload persistence, reset) and record results with dates in `specs/003-auth-verification/evidence.md` (SC-001 – SC-004, SC-008)
- [ ] T086 Measure the published web build as in `specs/001-foundation/evidence.md` (splash within 1 second, interactive within 5 seconds on Fast 4G) and record it in `evidence.md`
- [ ] T087 Run `flutter analyze --fatal-infos`, `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter test` and `flutter build web --release --base-href /sprint-app/` (the constitution's web build gate, which PR checks no longer run since PR #9) from a clean checkout and confirm `git diff --exit-code` shows no stale generated files (CI parity)
- [ ] T088 [P] After merge only: update `CLAUDE.md` "Current state" (feature 003 built, next is feature 4) and the Foundation comments that say real sign-in arrives later (`identity_repository.dart`, `session_provider.dart`, `sign_in_prompt.dart`)
- [ ] T089 Open the PR into `develop` titled "feat(003): auth and verification", description citing US-01 – US-05, US-23, FR-AUTH-01 – FR-AUTH-04, FR-VER-01 – FR-VER-04, BR-17, BR-21 – BR-27, NFR-06, NFR-12, the two decisions added, the `SprintTextField` additions and the new packages

---

## Dependencies and execution order

- **Phase 1** first. T001 is the first commit of the PR; T002 before any code task; T003 any time.
- **Phase 2** blocks every story. Inside it: T004 → T005, T008; T006 → T007 → T008 → T009 → T010. T011 – T016 are independent pure files. T017, T018 → T019 → T020; T021, T022 after T018. T024 – T027 need T019 and T011 – T014; T027 also needs T021, T022, T026. T028 needs T024 – T027 and T009. T029 – T031 after their implementations. T032 needs T028; T033 any time; T034 needs T032. T035 needs T017, T018, T014. T036 any time after T002; T037 needs T036.
- **US2 (Phase 3)** needs Phase 2. It is the MVP: seed accounts sign in and out.
- **US1** needs US2's screen flow (`from` handling) and T037.
- **US3** needs US1 and US2 (the gate opens both).
- **US5** needs US2 (Profile card) and US3 (the request route is gated).
- **US6** needs US5 (requests to review). T070 needs every screen that exists by then and is re-run in Polish.
- **US7** needs Phase 2 only for T076 – T078; it can run in parallel with US1 – US6.
- **US4** needs US1's `CodeEntry`; it can run in parallel with US3 – US7.
- **Polish** last. T088 only after merge. T089 only after T087 is clean and Osman has reviewed `copy-review.md`.
- Within a story: tests first and failing, then ARB keys, then screens, then route registration. ARB files are edited by one task per story, so stories touching them are merged one at a time.

## Parallel examples

```text
Phase 2 after T002:
  Agent A: T004 → T005, T006 → T007 → T008 → T009 → T010                (persistence)
  Agent B: T011, T012, T013, T014 → T015, T016                          (pure rules)
  Agent C: T017, T018 → T019 → T020 → T021, T022 → T023                 (models and interfaces)
  then T024 – T027 in parallel (different files) → T028 → T029, T030, T031 in parallel

After US2 and US1:
  Agent A: US3 (T055 – T060) → US5 (T061 – T067) → US6 (T068 – T075)
  Agent B: US7 (T076 – T078) and US4 (T079 – T081)
```

## Implementation strategy

- **MVP**: Phase 1, Phase 2 and US2. Seed people sign in by email or phone, the shell shows their sections, the session survives a reload, and sign out works.
- **Then**: US1 (new accounts), US3 (the gate every later feature needs), US5 and US6 (the verification story for the defense), then US7 and US4 in parallel, then Polish.
- **Order of commits** (research R16): docs (T001), packages and assets, serialisation and snapshot, pure rules, repositories, session and router, then one commit or more per story, then copy review and evidence.
- Stop at any checkpoint to demo; each story is visible through the seed accounts and the demo tools.
- Do not open the PR (T089) until T087 is clean and Osman has reviewed `copy-review.md`.
