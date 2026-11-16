# Implementation Plan: Auth and Verification

**Branch**: `003-auth-verification` | **Date**: 2026-11-16 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-auth-verification/spec.md`

## Summary

Turn the Foundation's demo-only identity into a real P1 sign-in and verification system on mock data. A new `AuthRepository` handles sign up with an emailed 6-digit code, sign in by email or phone, password reset, the session and the demo user switcher; emails go to an `EmailOutbox` whose P1 implementation is a simulated mailbox shown in the demo area and as a demo-only notice on the code screen. A reusable account gate lets guests sign in from any action or deep link and returns them to the same place. A new `VerificationRepository` handles requests with ID card photos, automatic approval against uploaded CSV sheets, refusal of duplicate national IDs, manual review scoped by the verifier's unit, expiry from the `verificationExpiry` setting, notifications and audit. One function decides the tier at any moment, and bookings keep the tier they were made with. All demo data now survives a restart through a snapshot of the in-memory layer, with a reset action. Decisions and alternatives are in [research.md](research.md).

## Technical Context

**Language/Version**: Dart 3.13.7 / Flutter 3.47.9 stable (as features 1 and 2; CI is pinned to it).

**Primary Dependencies**: the existing packages, plus runtime `json_annotation` (R1), `crypto` (R3), `image_picker` (R7), `file_selector` (R8), `csv` (R8), and `image` moved from dev to runtime (R7); dev `json_serializable` (R1). Exact constraints are fixed with `flutter pub add` at implementation.

**Storage**: `shared_preferences` (already a dependency) holds a JSON snapshot of the in-memory data layer and ID card photos under separate keys, behind `DemoSnapshotStore` (R1). Theme and language stay where the Foundation keeps them.

**Testing**: `flutter_test` unit tests for the pure rules, repository contract suites against the in-memory implementations, widget tests per screen across theme, language, width, 200% text, keyboard and semantics, router tests for the gate, a privacy guard (SC-006), and one acceptance test per BRD scenario of US-02 to US-05 (R15). No pixel goldens (project precedent).

**Target Platform**: web, macOS, Android, iOS checked by hand; Windows and Linux scaffolded, not run (as before). Camera capture on Android and iOS; file pick everywhere.

**Project Type**: Mobile + web + desktop app (single Flutter package, no backend).

**Performance Goals**: sign in, sign up and verification actions answer in under 1 second on the fake layer (the loading state still shows); snapshot saves never block a frame (debounced, R1); the Foundation's web splash target (SC-011) still holds, since none of the new packages is imported by the first route.

**Constraints**: tokens only; all strings in ARB; no platform checks outside `lib/core/adaptive/`; Clean Architecture boundaries (presentation reads interfaces only); `BR-17` freeze kept; passwords never in plain text (R3); national ID and photo only on verifier screens (NFR-06); web local storage quota about 5 MB (photos resized, R7).

**Scale/Scope**: 3 new repositories plus 1 outbox and 1 snapshot store; 5 auth screens, 1 gate, 1 request form, 1 profile card, 3 verifier screens, 1 mailbox screen; about 110 ARB keys; about 8 new seed people and records; JSON serialisation for every Foundation model.

No "NEEDS CLARIFICATION" remains; see [research.md](research.md) R1 – R16.

## Constitution Check

*GATE: passed before Phase 0 and re-checked after Phase 1.*

| Principle | How this plan complies | Status |
| --- | --- | --- |
| I. Repository is the source of truth | The two clarify decisions (saved demo data, verifier scope) go into `docs/decisions.md` and the `SprintTextField` additions into its component README, as the PR's first commit, before code (R16) | Pass |
| II. Tokens only, one identity | Screens use 002 widgets and tokens only; the auth column width and photo preview size come from tokens or `SprintExtras` named constants; the source-scan guard covers the new files | Pass |
| III. Settings, not constants | `verificationExpiry` is read from the settings repository (FR-028). Code and lockout numbers are constants by Osman's clarify answer (2026-11-16): security limits, not business rules, kept in one file (R4) | Pass |
| IV. Every data source behind a repository | Auth, verification, outbox and snapshot are interfaces; in-memory implementations enforce every rule (uniqueness, codes, lockout, BR-27, scope); presentation never imports `data/` | Pass |
| V. Arabic first, adaptive, accessible | ARB parity; verbal-noun buttons; LTR isolates for codes, phones, emails, national IDs; auth screens and verifier screens adapt by width class; platform dialogs and sheets; 48 targets; 200% text; keyboard order; screen reader labels | Pass |
| Product constraints | No SMS, no paid service, emails simulated; no AI or cash; Cairo time for expiry; no Lottie | Pass |
| Workflow | Spec Kit order kept; Out of scope present; one branch, one PR; BRD IDs in commits | Pass |

Post-design re-check (after data-model, contracts, quickstart): no new violation. One note in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/003-auth-verification/
├── plan.md              # This file
├── research.md          # Phase 0: decisions and alternatives (R1 – R16)
├── data-model.md        # Phase 1: entities, state transitions, seed additions, snapshot
├── quickstart.md        # Phase 1: how to run and validate, story by story
├── contracts/
│   ├── repositories.md  # Auth, outbox, identity, verification, parser, snapshot store
│   ├── routes.md        # New routes, the gate, redirect and no-access rules
│   └── ui.md            # SprintTextField additions and the feature widgets
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks, not created here)
```

### Source Code (repository root)

```text
pubspec.yaml                                   # + json_annotation, crypto, image_picker, file_selector, csv;
                                               #   image moved to runtime; dev: json_serializable
                                               #   + assets/demo/ (sample CSV, placeholder ID card)
docs/decisions.md                              # + 2026-11-16 entries (first commit)
docs/design-system/components/TextField/README.md  # + code type and the optional props (first commit)
lib/
├── core/
│   ├── data/
│   │   ├── in_memory_data_layer.dart          # + toSnapshot, fromSnapshot, reset, save on changes
│   │   ├── demo_snapshot_store.dart           # NEW: interface (R1)
│   │   └── preferences_snapshot_store.dart    # NEW: shared_preferences implementation
│   ├── providers/
│   │   ├── data_providers.dart                # + auth, verification, outbox providers; load at startup
│   │   └── session_provider.dart              # signIn / signOut / actAs; listens to changes (R9)
│   ├── tokens/sprint_extras.dart              # + authFormMaxWidth, idCardPreviewHeight (R12)
│   ├── seed/
│   │   ├── seed_users.dart                    # + new people, statuses
│   │   ├── seed_credentials.dart              # NEW: demo password (hashed at build) (R3)
│   │   └── seed_verification.dart             # NEW: requests, sheet batch, rows
│   └── widgets/sprint_text_field/             # + code type, autofillHints, textInputAction, focusNode (R13)
├── features/
│   ├── auth/                                  # NEW
│   │   ├── domain/                            # auth_repository, email_outbox, auth_limits, validators,
│   │   │                                      #   credential, email_code, simulated_email, password_hasher
│   │   ├── data/                              # in_memory_auth_repository, simulated_mailbox
│   │   └── presentation/                      # sign_in, sign_up, confirm_email, forgot_password,
│   │                                          #   reset_password screens; account_gate; code_entry; account_card;
│   │                                          #   demo_code_notice; auth_form_scaffold
│   ├── verification/                          # NEW
│   │   ├── domain/                            # verification_repository, national_id, sheet_parser,
│   │   │                                      #   reviewer_scope, tier (tierFor), sheet_batch, sheet_row
│   │   ├── data/                              # in_memory_verification_repository, csv_sheet_parser
│   │   └── presentation/                      # request_form, status_badge mapping (shown on account_card),
│   │                                          #   queue, request_detail, sheet_upload, photo picker
│   ├── identity/                              # narrowed interface; models get JSON; User status extended
│   ├── booking/data/in_memory_booking_repository.dart  # uses tierFor (R9)
│   ├── demo/presentation/                     # + mailbox screen, reset action; switcher uses actAs
│   └── (every model with freezed)             # + fromJson/toJson (R1)
├── app/
│   ├── router/                                # + auth routes, gate redirect, refreshListenable,
│   │                                          #   verification destination in the registry, NoAccessScreen
│   └── shell/placeholders/sign_in_prompt.dart # + the two gate actions (FR-019)
└── l10n/app_ar.arb, app_en.arb                # + about 110 keys (R14)
test/
├── features/auth/                             # validators, hasher, codes/lockout, contract suite, screens
├── features/verification/                     # national ID, parser, rules, scope, tier, contract suite, screens
├── core/data/                                 # snapshot round trip, fallback, reset
├── shell/                                     # gate, redirects, no access, sections for verifier/super admin
├── guards/                                    # + privacy_guard_test.dart (SC-006)
└── acceptance/                                # NEW: one test per BRD scenario of US-02 – US-05 (SC-005)
assets/demo/                                   # verification_sheet_sample.csv, id_card_placeholder.jpg
```

**Structure Decision**: Feature-first Clean Architecture as in the Foundation. Auth and verification are separate features because the backend will replace them separately (Supabase or Firebase Auth versus a database table and storage bucket) and because verification has its own staff screens. Snapshot persistence lives in `core/data/` next to the in-memory layer it saves, since it covers every feature's data and disappears with that layer. The design-system change is limited to additive props on `SprintTextField`.

## Complexity Tracking

| Deviation | Why needed | Simpler alternative rejected because |
| --- | --- | --- |
| JSON serialisation for every Foundation model, not only this feature's | Clarify answer: all demo data and the session survive a restart (FR-013a); a session pointing at a person who vanished on reload breaks the demo | Persisting only identity data loses bookings made in features 5 to 7 on reload while the account survives |
| Auth form width and ID card preview height are `SprintExtras` constants, not tokens (Principle II note) | `tokens.json` has no form-width token and this feature does not edit it (research R12) | Adding tokens means a Figma and handoff round trip outside this feature; 002 set the precedent of named constants with a follow-up |
| Code and lockout numbers are constants, not settings (Principle III note) | Osman's clarify answer (2026-11-16): security limits, not business rules | Making them settings adds admin UI and inheritance for values nobody at the university changes |
