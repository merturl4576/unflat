# Guardrails and verification

Run this after writing the block. Every line is pass or fail.

## Checklist

| Check | Pass condition | How to check |
|---|---|---|
| Rhythm | the hero is on the ground; no strip (one row, under about 300px) is a surface; between a third and two-thirds of the top-level sections are surfaces; on plate, slate and backlit no two surfaces are adjacent unless the page has fewer than four sections; on paper and glass the ground shows at least twice below the hero | `[...document.querySelectorAll('<root>')].map(e => [e.className, getComputedStyle(e).boxShadow !== 'none'])` — read the pattern; the first entry is false, the true entries are separated by false entries |
| Narrow screens | at 390px the cards inside surfaces carry the narrow shadow and no lift; nothing reads as floating off the page | screenshot a surface with cards at 390px; `getComputedStyle(card).boxShadow` shows the `-10px` spread |
| Radius | surfaces carry the site's shape language: `0` on a square site, otherwise the card radius or 1.4× it, never a new value | compare `--unflat-radius` to the audit's radius token |
| Taste | at most two fields, alpha within the material ceiling, neither behind a long text column; one motif with at most three strokes, alpha ≤ .09, off the text columns at 1440; cards inside surfaces within 2% L of the surface | read the block; screenshot the two field surfaces |
| Contrast | text on surfaces keeps its original contrast; the surface base (`--unflat-surface-bottom`) is within 3% L of the original section background and the gradient top at most 2.5% above that (nominal values; 8-bit hex rounding may add up to 0.2% L — `#161514`→`#1c1b1a` measures 2.64%). For semi-transparent surfaces (glass) measure the composited color (`getComputedStyle` of the section over the ground), not the raw token. | compare `--unflat-surface-bottom` to the page-bg token; spot-check a heading and a paragraph |
| Horizontal scroll | none introduced | `document.documentElement.scrollWidth <= innerWidth` |
| Gap | every surface has `--unflat-gap` of breathing room above and below it (against ground sections and against another surface, where the two margins collapse into one gap) | `getComputedStyle(document.querySelector('<your SURFACE selector>')).marginTop` equals the gap value; same for `marginBottom` |
| Alignment | content inside surfaces stays on the header's grid at every width — and a container that is also a padded card keeps equal padding on all sides; a page plate's first text element aligns the same way | `getBoundingClientRect().left` of the header's first text element vs the first and last surface's first text element at 1440, at a width just under the container's max plus twice the inset (e.g. 1100 for a 1160px container), and 390: equal within 1px |
| Fixed and sticky | header, banners, widgets unchanged | screenshot top of page and compare |
| One light | edges lit from the same side as the light; shadows fall down | eye check on two surfaces |
| Motion | the only motion is the hover lift on cards inside surfaces, under `prefers-reduced-motion: no-preference` and `(hover: hover)`, plus the one optional drift from taste.md §6 when it was chosen | grep the block for `animation` and `transition`: one `transition` (the lift), no `animation` unless the drift was chosen |
| Filters | no `filter`; `backdrop-filter` only for glass and off by default | grep the block |
| Fixed layers | at most two `position: fixed` pseudo-elements: `body::before` (light) and `body::after` (motif) | grep the block |
| Placeholders | no `SURFACE`, `GLOW`, `FIELD1`, `FIELD2`, `CARD` or `MOTIF` token left in the block; rules without a target deleted | grep the block for the six words |
| Images | photography and video not tinted by grain; texture behind content | look at a section with an image |
| Print | ground, texture and shadows removed | print preview or `@media print` present |
| Reduced motion | nothing to do unless glow is animated; it is not | grep |
| Reversible | removing start..end restores the file byte for byte | delete start..end (plus the one newline after end) and diff; for a single HTML file also confirm the bytes between `/* unflat: end */` and `</style>` are exactly one `\n`: `node -e "const s=require('fs').readFileSync('FILE','utf8');console.log(JSON.stringify(s.slice(s.indexOf('/* unflat: end */')+17,s.lastIndexOf('</style>'))))"` must print `"\n"` |
| Report | nine lines delivered (material, rhythm, taste, values, file, revert, dials, deleted rules, markup) | read the response |

## Painting order gotcha

The light layer is `body::before` with `position: fixed; z-index: -2`, and the motif layer is `body::after` at `z-index: -1`. It paints above the canvas but below in-flow content only when:

1. the ground is painted by `html { background }` (the canvas), and
2. `body { background: transparent }`, and
3. neither `html` nor `body` creates a stacking context (`position` plus `z-index`, `transform`, `filter`, `isolation`, `contain: paint`).

If the site sets `body { position: relative; z-index: 0 }` or similar, the layer disappears behind the body background. Fix by moving the ground and the layer to `html` (`html::before`) or by removing the body stacking context if it is harmless.

## Existing `body::before`

A site that already uses `body::before` or `body::after`: the block's layers replace them. Put the light on `html::before` and the motif on `html::after` instead, and say so in the report.

## Re-auditing after install

The audit snippet's `rootVars` now also picks up the block's own `@media` override (`--unflat-inset:0px`); read the block's `:root` values directly instead.

## Content that sits on top of the layer

Anything with `z-index: -1` of its own (decorative blobs) will now sit level with the motif layer. Move the motif to `z-index: -2` and the light to `-3` in that case and keep the blobs at `-1`.

## When to stop instead of writing the block

- The page already has three or more distinguishable planes with a consistent light.
- The design is deliberately flat or brutalist.
- Every section is full-bleed photography; surfaces would fight the images.
- The target is an app dashboard, admin panel or product UI.

Say which one applies and what, if anything, you would do instead (texture and light only, or nothing).

## Dials to hand back

- `--unflat-ground`: deeper ground, more separation. Stay within 6% L of the surface base and never below L 0.10.
- `--unflat-edge` and `--unflat-lightline`: more or less edge light.
- grain alpha inside the SVG: more or less texture, within 3–6%.
- `--unflat-inset`: wider inset reads as more mounted; narrower reads as calmer.
- the field and motif alphas: the fastest way to turn the atmosphere up or down; zero removes it without touching the rules.
- the SURFACE list itself: moving one section between ground and mounted is the biggest change a reader can ask for; keep the alternation when you do.
