# Contract: tokens.json → Dart

**Spec**: FR-009 – FR-012, FR-016, FR-018 | **Source of truth**: `docs/design-system/tokens.json`

## Generator

`dart run tool/gen_tokens.dart` reads `tokens.json` and writes, under `lib/core/tokens/`:

| Output | Content | Naming |
| --- | --- | --- |
| `sprint_colors.g.dart` | `SprintColors extends ThemeExtension<SprintColors>` with `light` and `dark` instances, `copyWith`, `lerp`; also the three shadows (`shadowCard`, `shadowSheet`, `shadowPopover`) as box-shadow lists | field per token, kebab → camel (`surface-raised` → `surfaceRaised`) |
| `sprint_spacing.g.dart` | `SprintSpacing.space1 … space16` | `space-N` → `spaceN` |
| `sprint_radius.g.dart` | `SprintRadius.sm … full` as `double`, plus `smRadius` and `smBorder` forms | `radius-sm` → `sm` |
| `sprint_size.g.dart` | `SprintSize.controlHeight`, icon sizes, `tabbarHeight`, `railWidth`, `sidebarWidth`, `contentMax`, and the breakpoints `bpMedium`, `bpExpanded`, `bpLarge` | token name in camel case |
| `sprint_motion.g.dart` | `SprintMotion.durationFast/Base/Slow/Pulse` (`Duration`), curves `easeStandard`, `easeEnter`, `easeExit` | per handoff.md |
| `sprint_text.g.dart` | the 12 type styles + `code` as `TextStyle` with family, the generic fallback families from `tokens.json` (for example `system-ui`, `sans-serif`), weight, size, **explicit `height`** (lineHeight ÷ fontSize) and, for `code`, letter spacing | style name in camel case |

Hand-written files (not generated): `context_extensions.dart` (`context.colors`, `context.text`),
`reduced_motion.dart` (`ReducedMotion.fade` and `.skip`), `sprint_extras.dart` (the few constants the
design docs state in prose but `tokens.json` does not carry: focus ring width and offset, iOS pressed
opacity, tab bar blur, label threshold at large text, skeleton minimum opacity, reduced-motion loader
progress; some are design judgements and are flagged as such in the file). `WindowSize` lives in
`lib/core/window/`.

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
7. `tool/gen_cairo_tzdata.dart` is a second generator: it writes `lib/core/time/cairo_tzdata.g.dart`,
   a 2 KB time zone database with only Africa/Cairo, so the web build does not ship every zone.
   A test checks it against the full database for 2026 – 2035 and fails on drift.
