# Data Model: Auth and Verification

Business-level model for this feature. It extends the Foundation's entities (`specs/001-foundation/data-model.md`); fields marked **new** are added here. Every entity below is a Freezed value with JSON serialisation (research R1). Times are UTC; display is Africa/Cairo (NFR-03).

## User (extended)

| Field | Type | Rule |
| --- | --- | --- |
| id | string | unchanged |
| name | string | 2–60 chars, at least two words (R5) |
| phone | string | normalised `01xxxxxxxxx`, **unique** (FR-003) |
| email | string | trimmed, lower-case, **unique** (FR-003) |
| nationalId | string? | set when a verification request is sent; unique across accounts (BR-27); shown masked except to `VERIFIER` and `SUPER_ADMIN` (FR-033) |
| status | `UserStatus` | **extended**: `unconfirmed`, `active`, `suspended` |
| createdAt | datetime | **new** |

**State transitions** (`UserStatus`):

```text
[sign up] → unconfirmed ──(correct code)──► active
active ──(admin, feature 9; seed only here)──► suspended
```

Only `active` can sign in (FR-006, FR-011). Price tier is never stored on the user (BR-17).

## Credential (new)

Kept apart from `User` so the real backend's auth provider replaces it alone.

| Field | Type | Rule |
| --- | --- | --- |
| userId | string | one per user |
| salt | string | base64, 16 bytes (R3) |
| hash | string | iterated SHA-256 (R3); never logged or shown |
| failedAttempts | int | reset on success; 5 in a row → lock (R4) |
| lockedUntil | datetime? | now + 5 min after the 5th failure |

## EmailCode (new)

| Field | Type | Rule |
| --- | --- | --- |
| userId | string | |
| purpose | `CodePurpose` | `confirmEmail`, `resetPassword` |
| code | string | 6 digits, `Random.secure` |
| expiresAt | datetime | sentAt + 15 min |
| wrongTries | int | 5 → code is dead, a new one must be sent |
| resendAfter | datetime | sentAt + 60 s |

At most one live code per (userId, purpose); sending replaces it (FR-005). A used code is deleted.

## SimulatedEmail (new, P1 only)

| Field | Type | Rule |
| --- | --- | --- |
| id | string | |
| to | string | email |
| subject | string | localised at send time in the app's current language |
| body | string | includes the code |
| purpose | `CodePurpose` | |
| sentAt | datetime | |

Listed newest first in the demo mailbox (FR-023).

## Session (extended)

| Field | Type | Rule |
| --- | --- | --- |
| user | User? | null = guest |
| roles | list of `RoleAssignment` | unchanged |
| verification | Verification? | **new**, replaces the stored `tier` |
| tier | derived | `tierFor(user, verification, now)` (R9) |

The signed-in user id is part of the snapshot (FR-013).

## Verification (extended)

| Field | Type | Rule |
| --- | --- | --- |
| id | string | **new**; a person can have several over time (renewals, re-requests) |
| userId | string | |
| type | `VerificationType` | `student`, `staff`, `faculty` |
| nationalId | string | **new**; 14 digits, valid date and governorate (R5) |
| code | string | **new**; university or staff code, 1–20 digits or letters |
| owningUnitId | string | **new**; the faculty or department chosen (from `OwningUnit`) |
| photoId | string? | **new**; key of the saved ID card photo (R7) |
| status | `VerificationStatus` | `pending`, `approved`, `rejected` (stored); `expired` derived |
| method | `VerificationMethod` | `auto`, `manual` |
| reviewerId | string? | **new**; set for manual decisions and sheet approvals |
| reason | string? | required (≥ 10 chars) when `rejected` (BR-26) |
| submittedAt | datetime | **new** |
| decidedAt | datetime? | **new** |
| expiresAt | datetime? | set on approval from `verificationExpiry` (FR-028) |

The person's **current** verification is the latest by `submittedAt`. Earlier ones are kept as history.

**State transitions**:

```text
[submit] ─┬─ national ID used by another account ──► rejected (auto, reason "duplicate national ID")   BR-27
          ├─ matches a sheet row in scope ─────────► approved (auto, expiresAt from setting)           BR-23
          └─ otherwise ─────────────────────────────► pending                                           BR-24
pending ──(verifier approves)──► approved (manual)
pending ──(verifier rejects + reason)──► rejected (manual)
pending ──(sheet uploaded with a match)──► approved (auto, reviewer = uploader)
approved ──(now ≥ expiresAt)──► expired (derived, never stored)                                      BR-25
rejected | expired ──(new request / renewal)──► new Verification, back to [submit]
```

Rules: one `pending` per person at a time (FR-027); a reviewer never decides their own (FR-035); deciding a non-pending request fails with `alreadyDecided`.

**Expiry** (FR-028): read `verificationExpiry` (`MonthDay`, default 31 August) at university scope; `expiresAt` = that month and day at 23:59:59 Cairo time, in the approval's year if still ahead, otherwise the next year.

## SheetRow / VerificationWhitelist (extended)

| Field | Type | Rule |
| --- | --- | --- |
| nationalId | string | 14 digits, valid (R5) |
| code | string | |
| type | `VerificationType` | |
| owningUnitId | string? | **new**; the uploader's unit, null for a university-scope uploader (FR-032) |
| uploadedBy | string | user id |
| batchId | string | |

Uniqueness: (nationalId, code, type, owningUnitId) — a repeat is a duplicate (edge case).

**Matching** a request: same nationalId, code and type, and the row's `owningUnitId` is null or equals the request's `owningUnitId`.

## SheetBatch (new)

| Field | Type | Rule |
| --- | --- | --- |
| id | string | |
| uploadedBy | string | |
| owningUnitId | string? | scope of the uploader |
| fileName | string | |
| uploadedAt | datetime | |
| rowsRead / rowsAdded / duplicates / invalid / approved | int | the summary (FR-038) |
| problems | list of (rowNumber, reasonCode) | invalid rows |

## Reviewer scope (derived, FR-032)

From the reviewer's `RoleAssignment`s:

- `SUPER_ADMIN` anywhere, or `VERIFIER` with `UNIVERSITY` scope → all units.
- `VERIFIER` with `OWNING_UNIT` scope → that unit id (several assignments add up).
- Anything else → none (no Verification section, no access).

## AuditLog and Notification (reused)

| Event | Audit action | Notification type |
| --- | --- | --- |
| manual approve | `verification.approve` | `verification.approved` |
| manual reject | `verification.reject` | `verification.rejected` (with reason) |
| auto approve at submit | `verification.autoApprove` (actor `system`) | `verification.approved` |
| auto approve from sheet | `verification.autoApprove` (actor = uploader) | `verification.approved` |
| auto reject, duplicate national ID | `verification.autoReject` (actor `system`) | none (shown at once on screen) |
| sheet upload | `verification.sheetUpload` (entity = batch) | none |

## Seed additions (FR-048)

All fictional; national IDs pass R5.

- Every Foundation person gets a credential with the demo password (R3), status `active`.
- The existing pending request (`usr-unverified`) gets `owningUnitId = ou-pe`, a national ID, a code and a placeholder ID card image from assets.
- A new person with a **pending** request in `ou-eng` (outside the seed verifier's unit).
- A new person with a **rejected** request and its reason.
- A new **unconfirmed** account (signing in sends it to the confirm step).
- A new **suspended** account.
- A sample sheet batch already uploaded by the seed verifier for `ou-pe`, plus a sample CSV file in `assets/demo/` for the live upload demo, with rows that match the `ou-pe` pending request, one duplicate, one invalid row and one row for a person with no request.
- Bookings of `usr-booker-ext` stay external, used by the freeze test (SC-007).

## Snapshot (new, R1)

| Field | Type | Rule |
| --- | --- | --- |
| schemaVersion | int | starts at 1; any other value → seed |
| seededAt | datetime | when the seed was built |
| savedAt | datetime | |
| data | object | every repository's lists, by name |

Photos are stored outside the snapshot under `photo/<photoId>`.
