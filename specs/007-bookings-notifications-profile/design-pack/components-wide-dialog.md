# WideDialog (component)

Covers: US-13, FR-MYB-02 (used by the cancel dialog), also the sign-out dialog on wide layouts
Node: component `277:33768`; instance on Medium full-refund `277:33788` (inside `123:917`). Variants for Expanded/Large exist in the dialog frames (not read).

## Description (from Figma)
Confirmation dialog for Medium, Expanded and Large: centred, 400 wide, `radius-xl`, `space-6` padding, over a scrim. Compact uses the platform alert (AdaptiveDialog ios/android). Actions sit at the end; the destructive one first in reading order. Enter confirms, Esc closes (web/desktop).

## Anatomy (read from the Medium instance)
- Container: column, 400 wide, fill `surface`, 1 `line` border, radius `radius-xl`, padding `space-6`, gap `space-3`, shadow `shadow-popover`; items aligned to the start. Sits on a full-window `scrim`.
- Title: `title` (Cairo 600 20/30), `ink`, full width.
- Message: `body` (15/24), `ink-muted`, full width, wraps.
- Actions row: padding top `space-3`, gap `space-2`, items start-aligned at the end of the row; each button 48 high, radius `radius-md`, padding horizontal `space-5`, 120 wide in the sample (size should hug content, min 120):
  - Primary action as destructive: SprintButton danger "إلغاء الحجز" (`danger` fill, `on-danger`).
  - Dismiss: SprintButton ghost "الرجوع" (`primary` text, no fill).

## Differences from AdaptiveDialog (compact)
Fill `surface` here vs `surface-raised` in compact (component text says always surface-raised: inconsistent, flag); radius `radius-xl` vs `radius-lg`; message `body`/`ink-muted` vs `caption`/`ink`; buttons are real SprintButtons, not text cells; no `line` divider.

## Behaviour (not in Figma beyond the description)
Enter confirms the focused default, Esc dismisses; focus ring visible; focus trapped; initial focus on the dismiss button for destructive dialogs; scrim tap dismisses; scale/fade from `SprintMotion`, respect `disableAnimationsOf`. Dark not read.
