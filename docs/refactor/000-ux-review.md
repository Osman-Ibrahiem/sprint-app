# Refactor 000: UX review of the design system

Date: 2026-11-23. Scope: the components and foundations in Figma (Components, Platform variants, Splash) and their code, read from a UX point of view: things can match across Figma, docs and code and still be wrong for the user. Feature screens get the same review when each feature is refactored.

Order: most harmful first. Each item is discussed with Osman one at a time; decisions go to `000-decisions.md`.

| # | Finding | Where | Why it hurts | Status |
| --- | --- | --- | --- | --- |
| U1 | Button hover and pressed are broken (Figma, and partly code): `tonal`, `ghost`, `danger` hover/pressed are filled with `ink` (dark navy at full opacity), so the label is barely readable; `secondary` hover/pressed are identical to default (no feedback) | Components › Button | Anyone building from Figma copies a dark block on hover and press; in code, tonal and danger hover turn grey and their pressed state does not change | decided (000-decisions U1) |
| U2 | Search "no results" is drawn as a field **error** (red field, red message) | Components › TextField `type=search, state=error` | No results is not a mistake by the user; a red field says "you typed something wrong". It belongs in an empty state under the field | decided (000-decisions U2) |
| U3 | StatTile arrow contradicts its text: absence rate shows a down arrow in red with "2% أكتر من الأسبوع اللي فات" | Components › StatTile `trend=down` | The arrow should follow the number (up when it went up); the colour says good or bad. Mixing them makes admins misread KPIs | decided (000-decisions U3) |
| U4 | Banner tones all use the same info icon; only the colour changes | Components › Banner (hold, neutral, success, info, danger) | Our rule: every state carries a word or icon, never colour alone. Success and danger need their own icons | decided (000-decisions U4) |
| U5 | Booker navigation differs by size: the compact tab bar has 4 tabs (no Notifications) while rail and sidebar have 5; the tab bar has no "حجوزاتي selected" variant; the Android tab bar `selected=home` also shows the pill on حجوزاتي (two items look selected) | Components › AppNavigation | People who switch phone/tablet/web find Notifications in different places; a double selection is confusing | decided (000-decisions U5) |
| U6 | The splash adds about 2 seconds on every cold start (600 ms native hold + 600 ms intro + 650 ms hold + 150 ms fade, from `sprint_splash.dart`) | Splash, `lib/core/splash/` | Frequent users wait every time even when the app is ready; the splash should end when loading ends | kept as is (000-decisions U6) |
| U7 | FacilityCard shows the internal price ("سعر الطلاب والعاملين") to every viewer, including guests and external users who pay the full price | Components › FacilityCard, catalogue | An external user sees 80 and pays 150 at checkout. Code already handles it; only Figma lacks the guest and external cases | decided (000-decisions U7) |
| U8 | Password field: placeholder "8 حروف على الأقل" repeats the helper "8 حروف على الأقل، فيها رقم" | Components › TextField `type=password` | Minor noise; the helper alone is enough. Figma helper also lacks "حرف" | decided (000-decisions U8) |

## Contrast audit (WCAG, measured 2026-11-23)

Script: every text and control pair from `tokens.json` usages, both themes (text 4.5:1, controls and focus 3:1). 66 of 72 pairs pass. Failures:

| # | Pair | Light | Dark | Where it shows | Status |
| --- | --- | --- | --- | --- | --- |
| C1 | `control-border` on `bg` | 2.88 | 3.59 | filter chips on the page background (decision 21), any bordered control placed on `bg` | decided (C1) |
| C1 | `control-border` on `surface-sunken` | 2.70 | 3.69 | bordered control on a sunken area | decided (C1) |
| C1 | `control-border` on `surface-raised` | 3.08 | 2.94 | text fields and chips inside sheets, dialogs and the filter popover in Dark | decided (C1) |
| C2 | `success` on `success-soft` | 4.49 | 8.81 | "مؤكد" badge and success banners in Light | decided (C2) |
| info | `primary-soft` on `surface` | 1.18 | 1.17 | tonal fill has no edge; fine while its label carries the meaning, so not a defect | none |

`tokens.json` claims "3:1 on surface and bg in both themes" for `control-border`; that is false for `bg` in Light.
Candidate values that pass everywhere: `control-border` Light `#80899e` (3.27 on bg, 3.51 on surface, 3.08 on surface-sunken), Dark `#65708c` (3.16 on surface-raised); `success` Light `#157c3c` (4.72 on success-soft, 5.28 on surface).

## Dark mode review (2026-11-23)

8 key Dark screens viewed and all 144 Dark frames on Compact checked by script: every Dark frame sets the Color mode to Dark, and no element inside is pinned to Light. Issues already decided elsewhere show up here too (decision 21 black chip borders, U3 arrow). One new finding:

| # | Finding | Status |
| --- | --- | --- |
| D1 | Cards keep their shadow in Dark frames (about 47), and some sheets use the Light sheet shadow (12). Code is right (`shadowCard` is empty in Dark) | decided (D1) |

## Text scale review (2026-11-23)

Existing matrices (booking, checkout, catalogue, auth, verification, shell) run at 1.0 and 2.0 in ar/en, Light/Dark, every width, and assert no overflow and 48dp targets; all pass. They do not catch text cut with an ellipsis. Code with `maxLines: 1` + ellipsis: the three navigation forms, `SprintLogo`, `DayStrip`.

| # | Finding | Status |
| --- | --- | --- |
| T1 | DayStrip day names cut at 150% and 200% (6 of 7) | decided (T1, part of decision 18) |
| T2 | Navigation labels (tab bar, rail) are hidden above 130% text (`navLabelMaxTextScale`), leaving icons only | decided (T2: keep labels, cap their scale at 1.3) |

## Platform variants review (2026-11-23)

| # | Component | Finding | Status |
| --- | --- | --- | --- |
| — | AdaptiveAppBar | iOS large title and pushed chevron, Android start-aligned title with back arrow; RTL correct | fine |
| — | AdaptiveSwitch | Cupertino and Material forms, mirrored correctly in RTL. Small wording slip in its description ("on = thumb at the start"; in Arabic it is the end, on the left) | fine, fix the description wording in the Figma session |
| — | AdaptiveLoader | see decision 20 | decided |
| P1 | AdaptiveDialog | Android variant has the actions reversed for RTL; code order depends on each screen; danger style differs (filled in Figma, text in code) | decided (P1) |

## Remaining components (2026-11-23)

Viewed: QRCode, Skeleton, Popover, Avatar, NotificationBell, DemoCodeNotice, VerificationStatusBadge, SegmentedControl, AccountGatePrompt, WideDialog, SettingsRow. Icon mirroring in code: arrows and carets go through `DirectionalIcon` (10 places); no directional icon is drawn with the non-mirroring `SprintIcon`. Fine: QRCode (dark on white, quiet zone), Skeleton (shapes match content, static under reduced motion), Popover (48 rows, radio state), NotificationBell, VerificationStatusBadge (word + icon per state), SegmentedControl, AccountGatePrompt (one primary, then secondary, then ghost), SettingsRow (chevrons point left in RTL).

| # | Finding | Status |
| --- | --- | --- |
| K1 | Avatar initials join into a word: "سارة محمود" shows "سم" (reads as the word for poison). Arabic letters connect, so two initials side by side form a word. Not built in code yet (feature 7) | decided (K1: one letter) |

## Last checks (2026-11-23)

Android icon: matches (foreground and monochrome bolt at 32.5–75.5 × 30–78 of 108, inside the 66dp safe zone, same as Figma at 4x). Foundation FR-001 – FR-031: each has tests or evidence (hinge in `test/shell/hinge_test.dart`, CI in `.github/workflows/ci.yml` and `deploy.yml`, constitution present), and the full suite passes (2003).

| # | Finding | Status |
| --- | --- | --- |
| R1 | README copy table (`docs/design-system/README.md` § المحتوى) differs from the app in three rows: "انتهاء المهلة" (one line vs title + body, see decision 14), "مفيش مواعيد في اليوم" (README mentions the green dot; app says "وفيه أيام تانية متاحة"), English payment failed ("Try again" vs "You can try again") | decided (R1) |
| E1 | Figma has no English screen and no text is bound to the Copy variables (0 on Compact), so the handoff claim "switch the Copy mode to get the English screen" does not work. English is only checked in code (matrices in ar and en) | decided (E1) |
| F1 | The constitution (`.specify/memory/constitution.md`, last amended 2026-11-15) lacks the "Design source (feature 006 onward)" rules now in CLAUDE.md: `/design-check` before specify, the design pack and its delete-before-merge rule, implementers stop when the pack is missing | decided (F1) |

## Visual check of the running app (`/demo/components`, web build of this worktree, 2026-11-23)

Viewed in Light at 1100 wide: buttons, text fields, slot chips, day strip, status badges, logo, facility cards, booking tickets. Shapes and colours match Figma apart from items already decided (button sizes 12, slot radius 11, decision 18).

| # | Finding | Where | Status |
| --- | --- | --- | --- |
| V1 | Times break between the number and م/ص: the ticket band shows "… 12:00" on one line and "م" on the next. `SprintFormat.time` uses `DateFormat('h:mm a')` with a normal space, so any narrow width or large text can split a time | `lib/core/l10n/sprint_format.dart`, every screen that shows a time | decided (V1) |
| V2 | The gallery's facility cards show raw English type keys ("swimming", "football", "gym") as tags; real screens are fine (`facility_card_mapper.dart` localizes them) | `component_gallery/sections/facility_card_section.dart:80` | decided (V2) |
| V3 | Password toggle: code shows the eye icon only; Figma shows the eye plus the word "إظهار" | `SprintTextField` password | decided (V3) |
| note | The code's `SprintTextField` still renders an error state for `type=search` (gallery); screens don't use it. Remove it with decision U2 | | decided (U2 addendum) |
