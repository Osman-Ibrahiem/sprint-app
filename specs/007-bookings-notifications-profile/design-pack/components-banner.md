# Banner (component)

Covers: US-13, US-14, FR-MYB-02, FR-PAY-04, BR-12 (hold), BR-31 (refund), BR-32 (admin cancel)
Node: component set `278:35499`; variant nodes: hold `278:35496`, neutral `278:35497`, success `278:35498`, info `287:897`, danger `287:901`. Round 2 (2026-11-18): design context of the whole component set read (all five tones).

## Description (from Figma, round 2)
Inline banner. tone=hold: payment hold with countdown (warning-soft, turns danger in the last minute, BR-12). tone=info: primary-soft notes (attended, no-show, expired, after cutoff). tone=success: refund on its way. tone=neutral: surface-sunken (cancelled with no refund, free booking). tone=danger: danger-soft (admin cancellation, failures). The icon is swappable: attended icon/check, no-show icon/user-minus, after cutoff icon/clock, expired icon/hourglass. Never colour alone. A Figma annotation on the text of neutral, info and danger: the amount is refundPercent x paid before the cutoff (BR-31), an admin cancellation is always 100% (BR-32).

## Variants
| tone | Fill | Text | Default icon (swap per use) | Padding / gap | Use |
| --- | --- | --- | --- | --- | --- |
| hold | `warning-soft` | `warning` | hourglass 24 | h `space-4`, v `space-3`, gap `space-3` | pending payment, live countdown; last minute turns `danger` (tokens `danger-soft` / `danger` presumed, not drawn) |
| neutral | `surface-sunken` | `ink` | warning-circle 20 (swap) | `space-3`, gap `space-2` | cancelled free or no refund |
| success | `success-soft` | `success` | warning-circle 20 (swap to check-circle in use) | same | refund on its way (full, partial) |
| info | `primary-soft` | `on-primary-soft` | warning-circle 20 (swap to check, user-minus, hourglass or clock in use) | same | attended, no-show, expired, after cutoff |
| danger | `danger-soft` | `danger` | warning-circle 20 | same | admin cancellation, failures (not seen on a screen yet) |
The component's default text is a long sentence ("الحجز اتلغى. الـ 80 ج.م هترجع على نفس وسيلة الدفع."), real copy is per screen.

## Anatomy
- Row, items centred, radius `radius-md`, overflow clipped. Default height 72 at 358 wide; instances are 48 high when one line fits (Medium booking details, Compact cancelled full refund) and 72 when the text wraps to two lines (My bookings detail pane at 252 wide). So the real height hugs the text with min 48 (a fixed-72 variant is a Figma default, not a rule).
- hold: text block in a column aligned to the end (line 1 `label` 14/20 600, line 2 `caption` 13/20, both in the tone colour), 24 icon at the physical end. Others: a single `body` 15/24 text filling the width (flex 1), 20 icon at the physical end (left in the Figma frame; the description says start: in RTL the icon is at the end of the text line).
- Icon colour follows the tone text colour (info: `on-primary-soft`, success: `success`, danger: `danger`, neutral: `ink`).

## Status change since round 1
The old mismatch (hand-built banners in the cancelled and past screens vs the Banner component) is resolved in Figma: those screens now use Banner instances (instance names "Banner", tones as above). The previous note about a missing `primary-soft` tone is closed: it is `info`. Still open: the old `info` meaning (`surface-sunken`) moved to `neutral`; the repository code `info_banner.dart` (warning tone) and `hold_banner.dart` should become one shared Banner with a `tone` parameter (refactor decision for Osman).

## Not in Figma
- Countdown updates once per second visually; announce as a polite live region only at start and at the last minute.
- No dismiss action.
- danger tone and the hold last-minute styling are specified in text only; no screen uses them.
- Text styles inside Banner map to tokens `label`, `caption`, `body`.
