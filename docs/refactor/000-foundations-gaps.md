# Refactor 000: Foundations + Design system, three-way gaps

Scope: Figma pages Cover, Foundations, Components, Splash, App icon, against `docs/design-system/*`, `docs/BRD.md` and `lib/core/*`. Date: 2026-11-18. Working copy, not for merge until decided.

## Aligned (checked)

- All 28 colour tokens, both modes: Figma Variables = `tokens.json` (same hex). Regenerating `lib/core/tokens/*.g.dart` gives zero diff.
- Spacing (10), radius (5), size (9), breakpoints (3), motion durations and the three easings: same values in Figma and `tokens.json`.
- 13 text styles (Cairo, size, line height, weight) = `tokens.json`. Effect styles `shadow-card/sheet/popover` (+ dark) exist.
- Splash (4 size classes + Android 12) and App icon (iOS light/dark, Android adaptive layers) exist in Figma, handoff and code (`SprintSplash`, `#sprint-splash`, iOS `AppIcon-Dark`, Android `mipmap-anydpi-v26`, `values-v31`).

## Gaps

| # | Gap | Figma | Docs (`docs/design-system`) | Code | Suggested fix |
| --- | --- | --- | --- | --- | --- |
| 1 | ~~Button `danger`~~ | RETRACTED 2026-11-19: Figma Button has `danger` (50 variants: 5 variants x 2 sizes x 5 states) and Show start/end icon + icon swap properties. My first read cut the list at 40 | `SprintButtonVariant.danger` exists, no screen uses it yet | none |
| 2 | TextField types and states | types text, password, search; states default, focused, error, disabled, + `filled` (search) and `locked` (text) | 3 types, 4 states | 7 types (+ phone, email, nationalId, code); `locked` not found | Docs: add `filled`, `locked`; decide if phone, email, nationalId are variants or just keyboard config on `text`; code entry is already its own `CodeEntry` in Figma |
| 3 | SlotChip `in-range` | has `in-range` | 5 states, no `in-range` | `SlotState` has 5 values, no `in-range` | Check how feature 005 shows free-range selection in code; then docs + code get the state, or Figma drops it |
| 4 | Mono family name | Typography frame says `font-mono`; the Variable is `font-code` | `tokens.json` says `mono` | `SprintText.code` | Pick one name (suggest `font-code`, matches the `code` style); update the other two |
| 5 | Motion easing in Variables | `ease-standard/enter/exit` exist as STRING variables in Motion | handoff says easing is NOT in Variables | n/a | Docs: fix handoff sentence |
| 6 | Collections list | also has Breakpoint, Typography | handoff table omits both | n/a | Docs: add the two rows |
| 7 | Icons location | 71 icons live on the Components page (frame `Icons`) | handoff says Icons are on Foundations | Phosphor | Docs (or move frame in Figma) |
| 8 | Components missing from docs | 17 sets not in handoff table or `components/`: DayItem, QRCode, Skeleton, LottieMoment, VerificationStatusBadge, CodeEntry, DemoCodeNotice, AccountGatePrompt, NotificationBell, WideDialog, BookingRow, SegmentedControl, NotificationCard, SettingsRow, Avatar, Banner, Popover | not documented | some exist as feature widgets, `Skeleton` in `core/motion`; no `lottie` package or `assets/lottie/` yet (planned, feature 11) | Docs: table rows now for the ones already built; the rest wait for their feature |
| 9b | AppNavigation `selected` | booker variants also exist per tab (home, facilities, notifications, account), admin has `more` (75 variants) | handoff says booker is `default` only and the `selected` row says instances are overridden | n/a | Docs: update the AppNavigation row |
| 9 | Code sample | n/a | `tokens.json` sample `SPR-7K2Q9` | generator emits `SP-1xxx` (decisions 2026-11-17) | Docs: change the sample |

## Second pass: BRD, Copy, component sizes, Splash

Splash numbers that match (Figma = code = decisions 2026-11-17): bolt 88 with the 60 × 66 glyph, rise 86 from step 1 to 3, wordmark 20 below the bolt (10 lower in step 2), tagline 4 below it, lane widths 56/36/46 × 6 spaced 8, pulse 1200, 600 ms native hold, 350 + 250 ms, background `primary` in both themes, Android 12 `windowSplashScreenBackground` = `#2445E0`, web `#sprint-splash` 88px.

| # | Gap | Figma / docs / BRD | Code | Suggested fix |
| --- | --- | --- | --- | --- |
| 10 | Splash loader and caption on wide windows | Medium, Expanded, Large all put the loader 116 and the caption 74 above the bottom, same as Compact. decisions 2026-11-17: "fixed to the bottom on every size" | `_loaderBottomWide = 72`, `_captionBottomWide = 32` from width 600 | Code: drop the wide constants (or Figma follows code; Figma + decision say drop) |
| 11 | SlotChip radius | `radius-sm` (8), and `tokens.json` says slot chips use `radius-sm` | `SprintRadius.mdBorder` (12) | Code: `smBorder` |
| 12 | Button sm radius and padding | `size=sm`: radius-sm (8), horizontal padding space-3 (12). `size=md`: radius-md (12), padding space-5 (20) | radius always `md`; horizontal padding always `space4` (16) | Code: follow Figma (both are token-bound there). Or Figma to 12/16 if 16 was deliberate; no decision records it |
| 13 | Copy: English wording differs | `status/pending-payment` "Pending payment"; `message/booking-confirmed` "Your booking's confirmed"; `slot/few-left` "1 left" / "2 places left"; `nav/account` "Account" | "Awaiting payment"; "Your booking is confirmed"; "1 place left"; `navProfile` "Profile" | Pick the wording once and update the other side. The Arabic matches in these rows except `nav/account` (same word, different key) |
| 14 | Copy: Arabic wording differs | `message/hold-expired` one line "المهلة خلصت والمكان رجع متاح"; `button/pay` "الدفع" | title "المهلة خلصت" + body "المكان رجع متاح للناس…"; "الدفع · {amount}" | Probably intended (code splits title/body, adds amount). Update the Copy rows in Figma |
| 15 | Copy: 17 Figma strings have no key yet | `view-ticket`, `change-time`, `scan-qr`, `skip`, `details`, `message/admin-cancelled`, `verification-review`, `no-bookings`, `nav/notifications|sessions|dashboard|bookings|assets|reports|settings` | not in the `.arb` | Not a defect now: they belong to features 7 – 9. They get keys in their own features; re-check then |
| 16 | BRD NFR-04 digits | "numbers shown by UI language" | decision 2026-11-08 and CLAUDE.md: Western digits (0–9) in both languages; code follows the decision | BRD: reword NFR-04 |
| 17 | `specs/001-foundation/evidence.md` | n/a | still lists Alexandria and IBM Plex Mono (fonts changed 2026-11-15) | Leave: it is a dated snapshot; or add one line pointing to the decision |

Component sizes that match Figma (all bound to variables): Button md 48 / sm 36 height; Button, SlotChip (100 × 56), StatusBadge (28, full radius), StatTile (radius-lg, padding 16), DayItem (56 × 64, full radius), tab bar 64, rail 88, sidebar 280, FacilityCard and BookingTicket (radius-lg, ticket width 340), TextField (radius-sm, 48 control).

FR-001 … FR-031 against code: evidence from `specs/001-foundation/evidence.md` (dated 2026-11-11) maps each success criterion to a test; I ran the suite again today (result below) rather than re-reading each FR.

## Still not checked

- Pixel-level visuals (screenshot against widget) for each component.
- Android icon layer geometry (safe zone 66dp, monochrome shape) against the Figma frames; only checked that the three layers exist.

Checked and matching: iOS `LaunchScreen` (bolt 88, background `#2445E0` = `primary`), iOS AppIcon 1024 × 1024 RGB (no alpha) in light and dark, Android adaptive icon (background = `primary`, foreground, monochrome), Android 12 splash icon 288dp canvas.
