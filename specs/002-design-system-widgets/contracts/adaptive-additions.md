# Contract: Adaptive additions

**Spec**: FR-005, FR-009, FR-016, FR-027, FR-051, FR-055, FR-065 | **Research**: R2, R8, R16
**Extends**: [`specs/001-foundation/contracts/adaptive-controls.md`](../../001-foundation/contracts/adaptive-controls.md)

Four new files in `lib/core/adaptive/`. They are the only new code allowed to name a platform. The
decision still lives in `platform.dart` (`adaptiveStyleOf`); these files turn the three styles into
answers a widget can use without knowing which style it got.

## `AdaptiveTraits`

`AdaptiveTraits.of(context)` returns an immutable value read from `adaptiveStyleOf(context)`:

| Trait | Apple | Android | Desktop (web, Windows, Linux) |
| --- | --- | --- | --- |
| `pressFeedback` | `fade` (fill to 70%, no ripple) | `ripple` (`primary-pressed`) | `hover` (`primary-hover`, pointer cursor) |
| `hapticsOnSelect` | true | true | false |
| `tabBarPill` | false (no pill behind the icon) | true (may use the `primary-soft` pill) | n/a (the rail or sidebar is used) |
| `numberShortcuts` | false | false | true (keys 1 to 5 open a destination) |
| `keyboardFocusRing` | true | true | true |

`keyboardFocusRing` is always true because the ring appears only when keyboard focus is real (the
Foundation's `SprintFocusRing` already hides it for touch); it is a trait so tests can assert it.

## `AdaptivePressable`

```text
AdaptivePressable(
  label,            // spoken label
  onTap?,           // null = not pressable (disabled, full, past)
  selected = false, // spoken state
  builder(context, state)   // state: pressed, hovered, focused (one wins, in that order)
  restingColor?, pressedColor?, hoverColor?   // tokens passed by the widget
)
```

Behaviour: Apple fades the child to `applePressedOpacity` while pressed; Android draws an ink ripple in
the given pressed colour; desktop swaps the colour on hover and sets a pointer cursor. All styles show
the `focus-ring` (2 px, 2 px away) on keyboard focus, activate on Enter and Space, expose
`Semantics(button: true, selected, label)`, and keep a hit area of at least `control-height` (48). A
null `onTap` renders the resting look, is skipped by focus, and exposes the disabled semantic.

## `AdaptiveHaptics`

`AdaptiveHaptics.selection(context)` fires a light selection haptic when `hapticsOnSelect` is true and
does nothing otherwise. It never throws if the platform has no haptic engine.

## `AdaptivePlatformOverride`

```text
AdaptivePlatformOverride(style: AdaptiveStyle, child: Widget)
```

Wraps `child` in a `Theme` whose target platform maps to `style` (`apple` → iOS, `android` → Android,
`desktop` → Windows), so `adaptiveStyleOf` inside it returns `style`. It is used only by the gallery
and by tests. It does not persist and is not a product setting. `apple` maps to iOS, which `adaptiveStyleFor` keeps as `apple` on the web too, so the override works in a desktop browser.

## Guard rules (unchanged files, new coverage)

- `test/guards/no_platform_checks_test.dart`: still allows platform names only in `lib/core/adaptive/`,
  `lib/core/scroll/` and `lib/core/theme/`; the four new files are inside the allowed folder and
  nothing under `lib/core/widgets/` may name a platform.
- `test/guards/widgets_presentation_only_test.dart` (new): no file under `lib/core/widgets/` imports
  `package:sprint/features/`, `package:sprint/app/`, or a Riverpod provider file (FR-010).

## Tests

`test/core/adaptive/` gains one file per primitive: each trait value per style (overriding the theme
platform), the pressable's three feedbacks, the single-state precedence, the disabled case, the
haptic no-op on desktop, and the override mapping.
