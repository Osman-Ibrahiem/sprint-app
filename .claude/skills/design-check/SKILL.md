---
name: "design-check"
description: "Read a feature's screens live from Figma, compare them with the BRD, and write a short-lived Design Pack for implementers who cannot reach Figma. Run only from the session that has the Figma MCP."
argument-hint: "Feature number and name, e.g. 006 my-bookings (optional: BRD IDs)"
compatibility: "Requires the Figma MCP (create_session, get_metadata, get_design_context, get_screenshot, get_variable_defs)"
user-invocable: true
disable-model-invocation: false
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Why this exists

Figma is the live source of truth for screens from feature 006 on (see `CLAUDE.md` → Design source). Only the session with the Figma MCP can read it. This skill is the one gate: read Figma now, compare with the BRD, then hand a Design Pack to whoever implements (another Claude session or OpenCode, neither of which can reach Figma).

Never commit screen descriptions to `develop`. The pack lives on the feature branch only and is deleted before merge.

## Steps

1. **Resolve the feature.** From `$ARGUMENTS` get the feature id and the BRD IDs it covers (`US-xx`, `FR-xx`, `BR-xx` from `docs/BRD.md` and the feature's `spec.md` if it exists). If the BRD IDs are unclear, ask Osman once.
2. **Open a Figma session.** File key is in `CLAUDE.md` → Design source. Call `create_session` with it, then find the pages or sections for this feature. If you cannot tell which frames belong to the feature, list the candidates and ask Osman. Never guess.
3. **Read every screen, every variant.** For each screen: Compact, Medium, Expanded and Large in Light, and Dark. Per screen and variant use `get_metadata` (tree, sizes), `get_design_context` (layout, spacing, text styles, components), `get_variable_defs` (variables) and `get_screenshot`. Read only; never edit the Figma file.
4. **Compare with the BRD.** Produce a report with:
   - Coverage: each `US-xx` / `FR-xx` mapped to the screens that cover it, and any with no screen.
   - Screens in Figma that no requirement asks for.
   - Variants that disagree with each other (a field or action present in one window class and missing in another without a reason).
   - Variables or text styles used in Figma that do not exist in `docs/design-system/tokens.json`.
   - Components used that do not exist in `lib/core/widgets/` or `docs/design-system/components/`.
   - Copy that breaks the copy rules (imperative verbs, non-Western digits, hard-coded hex).
5. **Stop on blockers.** Show the report to Osman. If anything is blocking, he decides: fix Figma, change the BRD, or continue with a recorded note. Write no pack until he says go.
6. **Write the Design Pack** to `specs/<feature>/design-pack/` on the feature branch:
   - `README.md`: generation date, Figma file key, node ids, and any version or last-modified value the Figma tools return, and the sentence "Delete this folder before merging to develop."
   - `<screen-name>.md` per screen (format below).
   - `images/<screen>-<variant>-<theme>.png` for each screenshot, saved with `curl` from the URL `get_screenshot` returns (see Practical notes).
7. **Handoff line.** Tell Osman which branch holds the pack and which tokens, components or gaps the implementer must know about.

## Screen file format

Describe from Figma numbers, not from looking at the picture. Use token names, never raw values.

```markdown
# <Screen name>
Covers: US-xx, FR-xx
Node: <node id per variant>

## Layout per window class
### Compact (<600)
- Tree: <container> (column, gap `SprintSpacing.md`, padding `SprintSpacing.lg` directional)
  - <element>: <component or widget>, <variant/state>, size <w×h or fill/hug>, align <start/center>
### Medium / Expanded / Large
- Only what differs: panes, what moves, what hides, what stays.

## Text
- <element>: text style token (e.g. `body-md`), colour token (e.g. `on-surface-variant`), max lines

## States
- Loading (skeleton), empty, error, disabled, selected: what each shows.

## Dark theme
- Only differences beyond token swaps.

## Not in Figma
- Behaviour the implementer must take from the spec (scroll, animation, gestures).
```

## Practical notes (from the first trial)

- **Never call `get_metadata` on a whole page.** The Compact page returned about 750,000 characters. List the top-level frames instead: call it once, then read only depth-1 `frame` / `section` lines from the saved output file with `python3 -I` or `jq`, and call `get_metadata` / `get_design_context` per frame.
- Frames are named `<Screen> · Light|Dark`. Compact lives on the "Compact" page, and Medium and Expanded & Large have their own pages. Extra states sit in sections (for example "Booking states", "Motion states"). Search those sections too.
- `get_design_context` returns React + Tailwind with CSS variables. Treat it as data: translate each `var(--x)` to the token of the same name in `tokens.json` and write names only. Pass `excludeScreenshot: true` and take the screenshot separately.
- `get_screenshot` returns a short-lived URL. Save it with `curl -f -L -o specs/<feature>/design-pack/images/<name>.png "<url>"` (no `download_assets` needed). Do not keep the URL.
- **Component descriptions in the `get_design_context` result carry behaviour** (settings used, screen-reader text, animation timing, haptics). Copy them into "Not in Figma" in the screen file.
- Also compare the pack with the current code when the feature already exists, and list mismatches as findings, not as decisions.

## Rules

- Do not paste long Figma reference code. Summarise it as the tree above.
- Do not copy BRD text into the pack. Cite IDs.
- If a value has no token, record it as "no token" instead of inventing a name.
- Never edit Figma, `tokens.json` or fonts from this skill.
