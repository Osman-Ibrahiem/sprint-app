# Sprint (سبرنت) Constitution

## Core Principles

### I. The Repository Is the Source of Truth
`docs/` and `docs/design-system/tokens.json` win over Figma and over the claude.ai artifacts
(frozen snapshots dated 2026-11-08). Any change to requirements, tokens or components lands in
this repository first, through a pull request; Figma and Flutter follow. Every spec cites the BRD
IDs it covers (`US-xx`, `FR-xx`, `BR-xx`). A decision recorded in `docs/decisions.md` MUST NOT be
reopened without Osman, and a new decision MUST be added there with its date and reason.
Rationale: one source prevents three conflicting copies (repo, Figma, artifacts).

### II. Tokens Only, One Identity
Colours come from `SprintColors` (a `ThemeExtension` with light and dark instances); spacing,
radius and size from `SprintSpacing`, `SprintRadius`, `SprintSize`; durations and curves from
`SprintMotion`; type from the token text styles. Token names are identical in `tokens.json`,
Figma Variables and Flutter. Widgets MUST NOT contain hex colours or magic numbers. Palette
"Volt": `primary` for the single main action per screen; `volt` is a fill only, always with
`on-volt` text. QR modules are always dark on white. Dark lifts surfaces instead of using shadows.
Rationale: tokens are what keep the brand identical across platforms and themes.

### III. Settings, Not Constants
Every number or behaviour the BRD marks as a setting (booking window, capacity, booking mode,
hold minutes, cancellation cutoff, refund percent, reminder lead time, and the rest) MUST be read
from the `Settings` repository with university → facility → unit inheritance, falling back to the
BRD default. It MUST NOT be hard-coded in a screen or in logic.
Rationale: the business rules are not final and must change without code changes.

### IV. Every Data Source Behind a Repository
Presentation code talks only to repository interfaces (feature-first Clean Architecture). Phase
P1 ships in-memory implementations on seed data, and the real backend replaces them without
touching presentation code. The fake repositories MUST enforce the same availability, conflict,
pricing, refund and permission rules the backend will, because the server is the future source
of truth. `PaymentProvider` is an interface: booking code never knows which gateway answers.
Rationale: the UI is built first, and the backend (Supabase or Firebase) is decided later.

### V. Arabic First, Adaptive, Accessible
Arabic RTL is the default and English the second language; all strings live in l10n files.
Layout follows window width (compact below 600, medium 600–839, expanded 840–1199, large 1200 and
above), never device names, and respects foldable hinges while keeping state. Brand components
look the same everywhere, while navigation bars, back gestures, dialogs, sheets, switches,
loaders and scroll physics follow the platform; iOS MUST NOT look like Material. Copy uses a
light Egyptian dialect with no imperative verbs, Western digits, 12-hour time, and
"120 ج.م" / "EGP 120". Interactive targets are at least 48dp, except the native Apple navigation bar and its back
button, which keep the platform's 44pt height (decisions.md, 2026-11-11); every state carries a word or an
icon, never colour alone; text scales to 200% with a minimum size of 12; animation respects the
reduce-motion setting.
Rationale: the users are Egyptian university students on every kind of device.

## Product Constraints

- Stack: Flutter, Riverpod (codegen), Freezed, GoRouter, Clean Architecture, feature-first.
- Phase P1 is for the thesis demonstration. Payments run in sandbox or test mode only. There is
  no SMS and no paid service: notifications are push and in-app, and account confirmation and
  password reset go by email.
- There is no AI, no cash payment and no no-show penalty in the system.
- Fonts are bundled static-weight assets: Alexandria for headings and buttons, Cairo for body
  text and every number, IBM Plex Mono for booking codes. Every `TextStyle` sets its token
  `height`.
- Motion is mostly code, timed by `SprintMotion`. Lottie is used only for booking and payment
  success, payment failure and empty states, plays once and stays within 100KB. No GIF or video.
- Times display in Africa/Cairo and are stored in UTC.

## Development Workflow

- Spec Kit is followed strictly in order: specify → clarify → plan → tasks → implement.
- Every UI-only feature spec has a mandatory "Out of scope" section listing backend, real
  payments, SMS and anything from P2.
- One branch and one pull request per feature. History MUST NOT be rewritten: no force-push and
  no rebase of shared branches. `main` and `develop` are protected and change only by pull request.
- Commit messages and pull request descriptions reference BRD IDs.
- `develop` deploys to GitHub Pages through CI. A pull request and a publish require static
  analysis, all automated tests and a web build to pass.
- Osman decides and reviews; Claude Code plans and reviews; OpenCode implements. When something
  is not settled in the BRD (§11) or in `docs/decisions.md`, ask Osman instead of guessing and
  record the assumption in the spec's clarify step.

## Governance

This constitution supersedes other practices. Every plan and pull request MUST check compliance
with it, and any deviation MUST be written in the plan's complexity section with a reason.
Amendments require a pull request that updates this file, states the reason, and is approved by
Osman; changes to what a principle means also update `CLAUDE.md` and `docs/decisions.md` in the
same pull request. Versioning follows semantic rules: MAJOR for removing or redefining a
principle, MINOR for adding a principle or materially expanding one, PATCH for wording fixes.
`CLAUDE.md` is the runtime guidance for day-to-day work and is kept consistent with this file.

**Version**: 1.1.0 | **Ratified**: 2026-11-10 | **Last Amended**: 2026-11-11
