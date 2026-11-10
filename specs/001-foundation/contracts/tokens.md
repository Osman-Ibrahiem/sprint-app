# Contract: tokens.json → Dart

**Spec**: FR-009 – FR-012, FR-016, FR-018 | **Source of truth**: `docs/design-system/tokens.json`

## Generator

`dart run tool/gen_tokens.dart` reads `tokens.json` and writes, under `lib/core/tokens/`:

| Output | Content | Naming |
| --- | --- | --- |
| `sprint_colors.g.dart` | `SprintColors extends ThemeExtension<SprintColors>` with `light` and `dark` instances, `copyWith`, `lerp` | field per token, kebab → camel (`surface-raised` → `surfaceRaised`) |
| `sprint_spacing.g.dart` | `SprintSpacing.space1 … space16` | `space-N` → `spaceN` |
| `sprint_radius.g.dart` | `SprintRadius.sm … full` (as `Radius` and `double`) | `radius-sm` → `sm` |
| `sprint_size.g.dart` | `SprintSize.controlHeight`, icon sizes, `tabbarHeight`, `railWidth`, `sidebarWidth`, `contentMax`, breakpoints | token name in camel case |
| `sprint_motion.g.dart` | `SprintMotion.durationFast/Base/Slow/Pulse` (`Duration`), curves `easeStandard`, `easeEnter`, `easeExit` | per handoff.md |
| `sprint_text.g.dart` | the 12 type styles + `code` as `TextStyle` with family, weight, size, **explicit `height`** (lineHeight ÷ fontSize) | style name in camel case |

Hand-written files (not generated): `context_extensions.dart` (`context.colors`, `context.text`),
`reduced_motion.dart` (fade-or-zero helper), `window_size.dart`.

## Rules

1. Generated files carry a "do not edit" header and are committed.
2. The drift test regenerates in memory and fails if the committed output differs from
   `tokens.json` (CI runs it).
3. Dark theme `shadow-card` is `none`; the generator emits an empty shadow list for dark.
4. Font families are `Alexandria`, `Cairo`, `IBM Plex Mono`; weights match `tokens.json` and the
   `pubspec.yaml` font declarations exactly (a test checks that every weight used is declared).
5. Fonts declared in `pubspec.yaml` and nothing else: Alexandria 600/700, Cairo 400/500/600/700,
   IBM Plex Mono 400/500 (files already in `assets/fonts/`).
6. Changing a token means editing `tokens.json` first, then re-running the generator, in the
   same pull request (constitution I and II).
