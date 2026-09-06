# Taste: the site's own atmosphere

Ground, light and surfaces make a page built. Taste makes it *this* page. Everything here is derived from the site's world (what it is about), its palette (the accent and its temperature) and its shape language (the radius). Nothing is invented from outside. Every element in this file is optional and reversible; when a site's world gives nothing, delete the rule and say so.

## 1. Read the world

Answer in one line each before choosing anything:

- **Subject** — what the page sells or shows (a camera, a knife, a terminal, a journal, a festival).
- **Temperature** — the accent's hue: warm (red, orange, amber, brass), cool (blue, cyan, violet, teal), or neutral. The page background's warmth too.
- **Shape language** — the card or button radius from the audit: square (0), soft (8–16px), round (20px+), pill buttons.
- **What already moves** — hero animation, hover states, scroll effects. A page that already animates gets no motion from the block.

## 2. Radius

Surfaces take the site's shape language, never a new one.

| Site radius (cards, tiles) | `--unflat-radius` |
|---|---|
| 0 (square site) | `0px` |
| 4–12px | the same value |
| 14px and up | `calc(<radius token> * 1.4)`, capped at 32px, e.g. `calc(var(--r) * 1.4)` or `28px` |

A surface is larger than a card, so it earns a slightly larger radius; a square site stays square. Cards inside keep their own radius.

## 3. Fields — two soft washes

A field is a very soft radial wash inside a surface, behind its content, that ties the section to the palette. Two at most, on the two sections that benefit: the photographic or gallery section and the featured or product section. Never behind a section that is mostly long text.

| | Light theme | Dark theme |
|---|---|---|
| `--unflat-field-a` | accent at .10 | accent at .08 |
| `--unflat-field-b` | the accent's counterpart at .12 | the counterpart at .06 |

The counterpart is the accent's temperature opposite: a cool accent (blue `#2f6be6`) gets a warm peach `rgba(255,176,120,α)`; a warm accent (amber `#e0b25c`, ember `#ff6a1f`) gets a cool blue `rgba(120,160,255,α)`; a neutral accent gets both from the palette's own warmth: warm ink → peach, cool ink → blue. A high-saturation accent (backlit) uses the secondary color the site already has instead of a counterpart.

Placement in the recipe: `FIELD1` (the counterpart wash, low left, bleeding out of the surface) and `FIELD2` (the accent wash, upper right). Each placeholder is one section from the SURFACE list; the recipe's `::after` draws it and `overflow: clip` on the surface trims the bleed. A page with one qualifying section uses only `FIELD2` and deletes the `FIELD1` rule.

## 4. Motif — one shape from the world

The motif is one geometric echo of the subject, drawn once on the fixed motif layer (`body::after`), at most three strokes, so faint it is noticed only after the second look. Alpha .06–.09 (`--unflat-motif` = accent at that alpha on light themes, text at .06 on dark). Never over a text column at 1440; anchor it top-right and bottom-left where heroes and galleries leave room.

| The world | Motif | Background value for `MOTIF` |
|---|---|---|
| optics, cameras, audio, watches, wheels, anything round | rings: two concentric circles top-right, one bottom-left | `radial-gradient(circle at 82% 18%,transparent 0 22vw,var(--unflat-motif) 22vw,transparent calc(22vw + 1.5px)),radial-gradient(circle at 82% 18%,transparent 0 31vw,var(--unflat-motif) 31vw,transparent calc(31vw + 1.5px)),radial-gradient(circle at 10% 88%,transparent 0 16vw,var(--unflat-motif) 16vw,transparent calc(16vw + 1.5px))` |
| workshops, tools, engineering, hardware, code, developer tools | a fine grid that fades out below the hero | `linear-gradient(var(--unflat-motif) 1px,transparent 1px) 0 0/100% 96px,linear-gradient(90deg,var(--unflat-motif) 1px,transparent 1px) 0 0/96px 100%` plus `mask-image:linear-gradient(180deg,#000,transparent 70vh)` on the layer |
| motion, sport, events, music, streetwear | one diagonal hairline across the page | `linear-gradient(115deg,transparent 0 58%,var(--unflat-motif) 58% calc(58% + 1.5px),transparent calc(58% + 1.5px))` |
| editorial, publishing, journals, education, agencies | one wide arc above the fold, like a page curl | `radial-gradient(circle at 50% -60vw,transparent 0 92vw,var(--unflat-motif) 92vw,transparent calc(92vw + 1.5px))` |
| finance, legal, enterprise, government | none: delete the motif layer | — |
| anything else | none, unless the subject hands you a shape in one sentence | — |

The motif never repeats the site's own decoration (a page that already draws rings gets no rings) and never competes with photography: keep it off the hero when the hero is a full-bleed image.

## 5. Cards on a surface

Inside a mounted surface, the site's cards, tiles and cells read as a second level when they get their own fill and a small shadow, one step from the surface:

| | Light theme | Dark theme |
|---|---|---|
| `--unflat-card` | the surface base mixed 30% toward the ground, e.g. `color-mix(in oklab, var(--unflat-surface-bottom), var(--unflat-ground) 30%)` | surface-top lightened 2% L, e.g. `color-mix(in oklab, var(--unflat-surface-top), white 2%)` |
| `--unflat-card-shadow` | `0 14px 34px -22px <ink at .30>` | `0 14px 34px -22px rgba(0,0,0,.6)` |
| `--unflat-card-shadow-narrow` | `0 6px 14px -10px <ink at .16>` | `0 6px 14px -10px rgba(0,0,0,.33)` |

On screens under 640px the cards stack full-width, and the desktop shadow reads as cards floating off the page; the recipe swaps in `--unflat-card-shadow-narrow` there (a user report, v1.2.1). `CARD` is the site's card selector (`.card`, `.tile`, `.cell`, `article`), comma-separated when there are several. Only cards inside SURFACE change; a card on the ground keeps its own look. When the site has no cards, delete rule 4c.

## 6. Motion

The block adds one motion and nothing else: cards inside a surface lift 3px on hover, 350ms, `cubic-bezier(.16,1,.3,1)`, under `prefers-reduced-motion: no-preference` and `(hover: hover)`, so touch screens never see a lift. No animation on load, nothing on scroll: those belong to the site, not to a layer that must be deletable. If the site already lifts its cards on hover, delete rule 6 rather than doubling it.

Optional, only when the page has one large still visual (a product render, a device, a lens) and no scroll effects of its own: a two-degree turn or a 2% drift tied to scroll, on that one element, using a `view()` timeline inside `@supports (animation-timeline: view())` and the same reduced-motion guard. One element, one property. Write it below rule 6 and mention it in the report.

## 7. Restraint

- Two fields, one motif, one hover. More is decoration, not taste.
- Every alpha in this file is a ceiling, not a target; the page should not be able to point at any of it.
- If the audit says the site already has fields, patterns or a motif of its own, the block adds none and the report says why.
- The report's taste line names the world, the motif, the two field colors and the card treatment in one sentence each, so a reader can dial them.
