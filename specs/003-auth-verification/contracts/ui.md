# Contract: UI additions and changes

**Spec**: FR-016, FR-023, FR-029, FR-039, FR-045 – FR-047 | **Research**: R6, R12, R13

## Changes to Feature 002 widgets (additive, no breaking change)

`SprintTextField`, also written into `docs/design-system/components/TextField/README.md` in the same PR:

| Addition | Behaviour |
| --- | --- |
| type `code` | numeric keyboard, `oneTimeCode` autofill, LTR isolate, max 6 digits, Arabic-Indic digits converted, read by screen readers as one field with its label |
| `autofillHints` | optional override of the type's default (`newPassword` on sign up and reset) |
| `textInputAction` | optional; `next` moves focus, `done` submits |
| `focusNode` | optional external focus node for form order |

No other design-system widget changes.

## New feature widgets (presentation only, in `features/*/presentation/`)

| Widget | Purpose |
| --- | --- |
| `AccountGatePrompt` | the gate: icon, what needs an account (passed in), "تسجيل الدخول", "إنشاء حساب", dismiss; shown in `AdaptiveSheet` |
| `AuthFormScaffold` | centred column (max width from tokens), `AdaptiveAppBar`, `AutofillGroup`, keyboard order, primary `SprintButton` |
| `CodeEntry` | `SprintTextField` type `code`, the address the code went to, resend with countdown, and the demo code notice slot |
| `DemoCodeNotice` | dismissible "للعرض بس" notice with the current code; built only when `demoToolsEnabled` (FR-023) |
| `AccountCard` | Profile: name, masked phone and email, tier, `VerificationStatusBadge`, next action, sign out |
| `VerificationStatusBadge` | status word plus icon for none, under review, approved (with expiry), rejected, expired |
| `MaskedNationalId` | last 4 digits only, LTR isolate (FR-033) |
| `VerificationQueueList` / `VerificationRequestDetail` / `SheetUploadSummary` | verifier screens (FR-031 – FR-039) |
| `NoAccessScreen` | word and icon for a missing role (FR-018) |

## Demo area additions (behind `demoToolsEnabled`)

- "صندوق البريد التجريبي" entry to `/demo/mailbox`.
- "إرجاع الداتا التجريبية" with an `AdaptiveDialog` confirmation (FR-013b).
- The user switcher goes through `AuthRepository.actAs` (FR-015).
