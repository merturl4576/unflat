# Guardrails and verification

Run this after writing the block. Every line is pass or fail.

## Checklist

| Check | Pass condition | How to check |
|---|---|---|
| Contrast | text on surfaces keeps its original contrast; the surface base (`--unflat-surface-bottom`) is within 3% L of the original section background and the gradient top at most 2.5% above that (nominal values; 8-bit hex rounding may add up to 0.2% L — `#161514`→`#1c1b1a` measures 2.64%). For semi-transparent surfaces (glass) measure the composited color (`getComputedStyle` of the section over the ground), not the raw token. | compare `--unflat-surface-bottom` to the page-bg token; spot-check a heading and a paragraph |
| Horizontal scroll | none introduced | `document.documentElement.scrollWidth <= innerWidth` |
| Gap | consecutive surfaces are separated by `--unflat-gap` | the second top-level section's computed `margin-top` equals the gap value (`getComputedStyle(document.querySelectorAll('<your SURFACE selector>')[1]).marginTop`) |
| Alignment | content inside surfaces stays on the header's grid at every width | `getBoundingClientRect().left` of the header's first text element vs the first and last surface's first text element at 1440, at a width just under the container's max plus twice the inset (e.g. 1100 for a 1160px container), and 390: equal within 1px |
| Fixed and sticky | header, banners, widgets unchanged | screenshot top of page and compare |
| One light | edges lit from the same side as the light; shadows fall down | eye check on two surfaces |
| Motion | no animation added | grep the block for `animation` and `transition` |
| Filters | no `filter`; `backdrop-filter` only for glass and off by default | grep the block |
| Fixed layers | exactly one `position: fixed` pseudo-element (`body::before`) | grep the block |
| Images | photography and video not tinted by grain; texture behind content | look at a section with an image |
| Print | ground, texture and shadows removed | print preview or `@media print` present |
| Reduced motion | nothing to do unless glow is animated; it is not | grep |
| Reversible | removing start..end restores the file byte for byte | delete start..end (plus the one newline after end) and diff; for a single HTML file also confirm the bytes between `/* unflat: end */` and `</style>` are exactly one `\n`: `node -e "const s=require('fs').readFileSync('FILE','utf8');console.log(JSON.stringify(s.slice(s.indexOf('/* unflat: end */')+17,s.lastIndexOf('</style>'))))"` must print `"\n"` |
| Report | six lines delivered (material, values, file, revert, dials, markup) | read the response |

## Painting order gotcha

The light layer is `body::before` with `position: fixed; z-index: -1`. It paints above the canvas but below in-flow content only when:

1. the ground is painted by `html { background }` (the canvas), and
2. `body { background: transparent }`, and
3. neither `html` nor `body` creates a stacking context (`position` plus `z-index`, `transform`, `filter`, `isolation`, `contain: paint`).

If the site sets `body { position: relative; z-index: 0 }` or similar, the layer disappears behind the body background. Fix by moving the ground and the layer to `html` (`html::before`) or by removing the body stacking context if it is harmless.

## Re-auditing after install

The audit snippet's `rootVars` now also picks up the block's own `@media` override (`--unflat-inset:0px`); read the block's `:root` values directly instead.

## Content that sits on top of the layer

Anything with `z-index: -1` of its own (decorative blobs) will now compete with the light layer. Give the light layer `z-index: -2` in that case and keep the blobs at `-1`.

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
