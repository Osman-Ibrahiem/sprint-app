# Contract: Repositories

**Spec**: FR-001 – FR-013b, FR-020 – FR-044 | **Plan**: [../plan.md](../plan.md) | **Research**: R1 – R4, R8 – R11

Interfaces in Dart terms (names are final; exact signatures are fixed at implementation). Every method returns a `Result<T, Failure>` (the Foundation's `lib/core/result/`), never throws for a business outcome. Every repository exposes `Stream<void> get changes`, which fires after each successful write. The in-memory implementations enforce every rule listed here; the same contract test suite runs against them now and against the backend later (R15).

## AuthRepository (new) — `lib/features/auth/domain/auth_repository.dart`

| Method | Success | Failures |
| --- | --- | --- |
| `signUp(name, phone, email, password)` | `PendingConfirmation(userId, email)`; sends a `confirmEmail` code | `invalidField(field, reason)`, `emailTaken`, `phoneTaken` |
| `confirmEmail(email, code)` | `SignedIn(userId)`; status → `active`; session set | `codeWrong(triesLeft)`, `codeExpired`, `codeDead`, `noPendingConfirmation` |
| `resendCode(email, purpose)` | `CodeSent(resendAfter)` | `resendTooSoon(wait)`; unknown email returns `CodeSent` too (SC-009) |
| `signIn(identifier, password)` | `SignedIn(userId)` | `badCredentials` (wrong password, unknown email, unknown phone: one failure), `lockedOut(until)`, `suspended`, `needsConfirmation(email)` (also sends a new code) |
| `signOut()` | `Done` | none |
| `requestPasswordReset(identifier)` | `CodeSent(resendAfter)` always, also for unknown (FR-021) | `resendTooSoon(wait)` |
| `resetPassword(identifier, code, newPassword)` | `SignedIn(userId)`; old password stops working; lock cleared | `invalidField(password)`, `codeWrong(triesLeft)`, `codeExpired`, `codeDead` |
| `currentUserId()` | `String?` | none |
| `actAs(userId?)` | `Done`; demo-only user switcher (FR-015) | none |

Rules: identifiers are normalised before lookup (R5); time comes from the app clock; `badCredentials`, `lockedOut` and the reset response never depend on whether the account exists. `signIn` checks, in order: lockout of the identifier → password (wrong or unknown → `badCredentials`, counted per identifier) → account status (`suspended`, `needsConfirmation`) → success (counter reset). `confirmEmail` also creates the `BOOKER` role assignment at university scope (FR-004). The signed-in user id, the throttles and the codes are part of the snapshot.

## EmailOutbox (new) — `lib/features/auth/domain/email_outbox.dart`

| Method | Notes |
| --- | --- |
| `send(SimulatedEmail)` | P1 `SimulatedMailbox` stores it; a real provider sends it later |

`SimulatedMailbox` also offers `list()` (newest first) and `latestCodeFor(email, purpose)` for the demo mailbox screen and the demo code notice (FR-023). Neither is on the interface; screens reach them only through a demo-only provider that returns null when `demoToolsEnabled` is false.

## IdentityRepository (existing, narrowed)

Keeps `users()`, `getUser(id)`, `roleAssignments(userId)`, and adds `changes`. `currentUser()` and `setCurrentUser()` move to `AuthRepository` (R2); `verification(userId)` moves to `VerificationRepository.current(userId)`. Callers in the Foundation are updated in this feature.

## VerificationRepository (new) — `lib/features/verification/domain/verification_repository.dart`

| Method | Success | Failures |
| --- | --- | --- |
| `current(userId)` | `Verification?` (latest) | none |
| `history(userId)` | list, newest first | none |
| `submit(userId, type, nationalId, code, owningUnitId, photo)` | the new `Verification` with status `approved`, `pending` or `rejected` per FR-026 (duplicate = another account's pending or approved request, incl. expired); on approval `User.nationalId` is set | `invalidField(field, reason)`, `alreadyPending`, `notSignedIn` |
| `queue(reviewerId)` | pending in the reviewer's scope, oldest first | `noAccess` |
| `request(reviewerId, verificationId)` | full request incl. national ID and photo | `noAccess` (not a reviewer, or out of scope) |
| `approve(reviewerId, verificationId)` | approved, with `expiresAt` | `noAccess`, `alreadyDecided`, `ownRequest` |
| `reject(reviewerId, verificationId, reason)` | rejected | `noAccess`, `alreadyDecided`, `ownRequest`, `reasonTooShort` |
| `uploadSheet(reviewerId, fileName, csvText)` | `SheetBatch` with its summary | `noAccess`, `badColumns`, `noValidRows` |
| `batches(reviewerId)` | uploads in scope, newest first | `noAccess` |
| `photo(reviewerId, photoId)` | image bytes | `noAccess` |
| `tierFor(userId, at)` | `PriceTier` (R9) | none |

Side effects: approve, reject, auto-approve and sheet upload append to `AuditLogRepository` and push to `NotificationRepository` exactly as in data-model.md.

## VerificationSheetParser (new)

`parse(String csvText) → SheetParseResult(rows, problems, headerSkipped)`. Pure; P1 columns per R8.

## DemoSnapshotStore (new) — `lib/core/data/demo_snapshot_store.dart`

| Method | Notes |
| --- | --- |
| `load()` | `Map<String, Object?>?`; null when missing or unreadable |
| `save(Map<String, Object?>)` | debounced by the caller |
| `loadPhoto(id)` / `savePhoto(id, bytes)` | separate keys; `savePhoto` can fail with `storageFull` |
| `clear()` | snapshot and photos; theme and language untouched |

`InMemoryDataLayer` gains `toSnapshot()`, `fromSnapshot(...)` and `reset()`; `dataLayerProvider` loads at startup and saves on any repository's `changes`.
