# Contract: Routes added by feature 003

**Spec**: FR-014, FR-016 – FR-019, FR-031 – FR-039 | **Research**: R6, R10, R12

Extends `specs/001-foundation/contracts/routes.md`; its rules 1, 2, 4 and 5 are unchanged and rule 3 is refined below.

| Path | Screen | Where | Access |
| --- | --- | --- | --- |
| `/sign-in` | Sign in | outside shell | guests; a signed-in person is sent to `from` or `/home`. Query `from` = in-app path to return to |
| `/sign-up` | Sign up | outside shell | guests; keeps `from` |
| `/confirm-email` | Code entry (confirm) | outside shell | query `email`; keeps `from` |
| `/forgot-password` | Reset request | outside shell | anyone |
| `/reset-password` | Code and new password | outside shell | query `identifier` |
| `/profile/verification` | Verification request or renewal form | Profile branch | requires account |
| `/verification` | Review queue | Verification destination | `VERIFIER` or `SUPER_ADMIN` (section `verification`) |
| `/verification/:id` | Request detail | Verification branch (side panel from expanded) | same, and the request in scope |
| `/verification/upload` | Sheet upload and its summary | Verification branch | same |
| `/demo/mailbox` | Simulated mailbox | outside shell | only when `demoToolsEnabled` |

Rules:

1. **Base tabs never redirect** (Foundation rule 3 kept): `/bookings` and `/profile` show the sign-in prompt to guests, now with "تسجيل الدخول" and "إنشاء حساب" that open the gate.
2. **Gated routes** declare `requiresAccount` and optionally `requiredSection`. For a guest the router redirects to `/sign-in?from=<location>`; after sign in it goes to `from`. For a signed-in person without the section, the route renders `NoAccessScreen` at the same location (word and icon), never a redirect and never the sign-in prompt.
3. **`from` is validated**: only a path that the router itself recognises is accepted; anything else (absolute URL, unknown path) goes to `/home`.
4. **In-screen gate**: `requireAccount(...)` pushes the auth routes on top of the current page and pops back with the result; the page underneath keeps its state (R6).
5. **Sign out** re-evaluates every route: a gated route open at sign out shows the sign-in prompt flow on next visit, and the shell drops the staff destinations at once.
6. **Auth screens are outside the shell**, so their back gesture and app bar follow the platform and no navigation bar shows.
