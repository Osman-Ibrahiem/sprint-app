# Permission · notifications (sheet and wide dialog)
Covers: US-13, FR-NTF-01, BR-39
Node: Compact Light 256:6628, Dark 256:6898 · Medium dialog Light 266:7577 (Dark 266:7983, Expanded 267:17020, Large 267:17849 not read)
## Layout
### Compact: bottom sheet over Home booker
- Underlay: Home booker (see home-upcoming.md) with a full-screen scrim (`scrim`).
- Sheet: full width 390, top 514, `surface`, radius top 24 (`radius-xl`), padding top `space-3`, x `space-4`, bottom 28, gap `space-3`, centred column. Grabber 40x4 `line` radius 2.
  - Icon disc: 64 high, `primary-soft`, radius 32, bell icon 32.
  - Title, body, primary Button (full width, 48, `primary`), ghost Button (full width, 48).
### Medium and up: dialog
- Scrim over the whole 720x1000 frame. Dialog 400 wide, centred, `surface`, 1px `line`, radius `radius-xl` (24), padding `space-4`, gap `space-3`, shadow `shadow-popover`. Same content (icon disc, title, body, two buttons, buttons full width).
- Rail visible behind with the notifications badge.
## Text
- Title "عايزين نبعتلك تأكيد حجزك": `title`, `ink`, centred.
- Body "هنبعت إشعار لما حجزك يتأكد، وتذكير قبل الميعاد بثلاث ساعات": `body`, `ink-muted`, centred. Annotation: the duration comes from `reminderLeadMinutes` (default 180, BR-39).
- Primary "السماح بالإشعارات": `button`, `on-primary`. Ghost "مش دلوقتي": `button`, `primary`.
## States
Shown once, after the first booking is made (trigger not drawn). "مش دلوقتي" dismisses without a system prompt; "السماح بالإشعارات" triggers the platform prompt.
## Dark theme
Not read.
## Not in Figma
- When to show it and how often after "مش دلوقتي", and what the Account notifications row shows when denied ("مفعّلة" is the only value drawn): spec decision.
- Sheet vs dialog follows `adaptive.md` (docs: wide sheets rule): sheet on Compact, dialog from Medium.
