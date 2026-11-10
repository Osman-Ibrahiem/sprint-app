# Contract: Adaptive controls

**Spec**: FR-019, FR-020, User Story 3 | **Source**: `docs/design-system/adaptive.md`

Public widgets in `lib/core/adaptive/`. Screens call them and never inspect the platform.

| Widget / function | Key inputs | Apple (iOS, iPadOS, macOS) | Android | Web, Windows, Linux |
| --- | --- | --- | --- | --- |
| `AdaptiveAppBar` | `title`, `largeTitle` (bool), `leading?`, `actions` | Centred title, large title when `largeTitle`, chevron back | Start-aligned title, arrow back | Same as Android, hover and focus states |
| `showAdaptiveDialog` | `title`, `message`, `actions` (label, `isDestructive`, `isDefault`) | `CupertinoAlertDialog` | Material dialog, `radius-xl`, actions at the end | Centred dialog; Enter = default action, Esc = cancel |
| `showAdaptiveSheet` | `title?`, `actions` or `builder` | Action sheet from bottom | Modal bottom sheet, `radius-xl` top corners | Menu anchored to the trigger; Esc closes |
| `AdaptiveSwitch` | `value`, `onChanged`, `semanticLabel` | `CupertinoSwitch` look | Material switch coloured `primary` | Material switch |
| `AdaptiveLoader` | `size?`, `semanticLabel` | Activity indicator | Circular progress | Circular progress |

Shared rules:

- Colours, radius, spacing and text styles come from tokens. The Volt lime is never used as a
  line or icon on a light surface.
- Every control exposes a semantic label from l10n; state is conveyed by text or icon, not
  colour only.
- Touch targets are at least 48 logical pixels, with a visible focus ring on keyboard platforms.
- Destructive actions use `danger` plus a word ("حذف" style verbal noun), never colour alone.
- Animation respects reduced motion (fade at `duration-fast` or none). Page, sheet and dialog
  transitions keep the platform's own timing.
- Tests override the target platform and assert which concrete widget appears, so the table
  above is verified, not just documented.
