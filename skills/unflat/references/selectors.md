# Selectors: rhythm and surfaces without touching markup

`SURFACE` in recipe.css stands for the list of top-level sections that become surfaces — the mounted ones from §2, never every section. `GLOW` stands for the one of them that carries the accent glow. Fill both with structural selectors; never add classes or wrappers to the markup. recipe.css wraps every token in `:is()`, so paste your selector or comma-separated list as-is — do not add your own `:is()`, and do not strip the existing one.

## 1. Find the root

Look for the tightest element that directly holds the page's sections. Its children are the candidate list; §2 decides which of them are mounted.

| Markup | Root (candidates) |
|---|---|
| `<main><section>…</section>…</main>` | `main > section` |
| `<main><div class="…">…</div>…</main>` | `main > div` |
| `<div id="app"><section>…` | `#app > section` |
| `<div id="root"><main><section>…` | `#root > main > section` |
| `<div id="__next"><main>…` | `#__next > main > section` |
| Sections directly under `<body>` | `body > section` |

## 2. Rhythm: which sections are mounted

A surface reads as a surface only when there is ground next to it. Walk the candidates in order and mark each one.

**Ground** — never a surface:
- the hero, whatever it holds: it is the ground's own opening, and a mounted hero reads as a banner;
- strips: a row of logos, a ticker, a stats or trust band, a job ticker, a newsletter bar — anything one row tall, roughly under 300px;
- sections whose artwork fills them: a canvas, a video or a full-bleed image behind the whole section, an interactive tool that is the section (a bench, a configurator, a map, an editor); a card with a toggle, tabs or a color picker is content, not a tool;
- full-bleed galleries, accordions, marquees and masonry grids that run edge to edge with no container around them — the images are already the surfaces. A gallery inside the container, with a heading and captions, is a readable section and a candidate;
- header, nav, footer, and anything `position: fixed` or `sticky` (cookie banners, chat widgets, floating buttons, drawers, dialogs).

**Mounted** — the sections the visitor reads: a statement or manifesto with a heading and paragraphs, the process or how-it-works, the story or about, a lookbook, the featured collection or product, testimonials, pricing with a featured tier, a text call to action.

Then apply the rhythm, which depends on the material. On **plate, slate and backlit** (dark, low contrast between ground and surface) mounted sections alternate with ground: when two readable sections sit next to each other, mount the one that carries the page's argument (the statement over the detail, the featured collection over the plain grid, the process over the specification) and leave the other on the ground; two surfaces in a row only when nothing can sit between them and the page has fewer than four sections; a third to a half of the candidates mounted. On the origin site, eleven sections gave four surfaces: ground (hero), strip, **statement**, bench, **lookbook**, materials, **process**, gallery, **featured collection**, band, strip. On **paper and glass** (the ground is clearly darker than the sheet, and the gap shows it) consecutive sheets read as sheets on a desk: mount every readable section, half to two-thirds of the candidates, and keep the hero, the strips and one artwork-led section on the ground so the desk is seen at least twice.

Write the list in your response: every section, its height, ground or mounted, one reason each. If the marked list has no ground between any two surfaces, the rhythm is wrong; go back.

## 3. Writing the selector

Express the choice structurally. Existing class names are fine in plain HTML and in CSS modules with stable names; with generated class names (Tailwind, hashed modules, styled-components) use position or content:

```css
main > :is(.manifesto, .knives, .commission)                 /* by class, plain HTML */
main > :is(:nth-child(3), :nth-child(5), :nth-child(7))      /* by position; DOM order is static */
main > :has(> .container > h2):not(:has(canvas, video, img)) /* by content */
```

`:has()` is supported in every evergreen browser since 2023. Whatever form you use, the sections marked ground must not match; check the count in the browser (`document.querySelectorAll('<SURFACE>').length`) against your list. If the root mixes header, nav or footer with sections, exclude them explicitly: `main > :not(header):not(nav):not(footer):not([role="dialog"])`.

## 4. Choosing GLOW

One surface only (two for backlit): the one the page is about. Pricing, the featured product, the collection, the signup. GLOW must be one of the mounted sections; if the alternation left it on the ground, flip it and its neighbour. Pick by content when possible: `main > section:is(.pricing, :has(.pricing, .tiers, form))` (Baseline `:has()` in all evergreen browsers) (`:has()` never matches the section's own class, so the class goes in `:is()`). Otherwise, `main > section:last-child` when the CTA is the last section (most pages), or `main > section:nth-last-child(2)` only when a newsletter or contact strip sits after it. Glow the section the page wants the visitor to act on: a pricing section with one featured tier, a subscribe form, or the final CTA. A plain pricing grid with no featured tier is not the target — glow the CTA instead. Confirm the section you hit before writing the rule. When nothing qualifies — parallel sections with no call to action, an article, a gallery — there is no glow: delete the `:is(GLOW){…}` rule and remove `:is(GLOW)` from the print rule, as the slate material does. For the backlit material only, GLOW may be two sections — usually the featured section and the CTA, never the hero — joined with a comma.

## 5. The page plate

A page that is one continuous flow rather than a sequence of sections — a store listing, a product page, an article, docs, a checkout, a cart — is one surface: the content container itself is mounted, at its own max width, centered when the viewport is wider, header and footer on the ground. Put the container in SURFACE (`main > .wrap`, `#app > div.wrap`) so it gets rule 4's gradient, border, shadow and light-line, and add this sizing rule after rule 4, with the same SURFACE and the container as PAGE:

```css
/* page plate — the container is the surface; sized to its own max width, padding gives back the inset */
:is(SURFACE):is(PAGE){margin-inline:max(var(--unflat-inset),calc((100% - var(--unflat-max))/2));max-width:none;width:auto;box-sizing:border-box;
  padding-inline:calc(var(--unflat-pad) - clamp(0px,var(--unflat-inset) - (100% - var(--unflat-max))/2,var(--unflat-inset)))}
```

`100%` is the parent's width here, so the clamp is rule 5's compensation with the plate's own inset: above `--unflat-max` plus twice the inset the plate is exactly `--unflat-max` wide and centered, below that it keeps the inset. Rule 5 does not apply to the plate (nothing inside it needs compensation; the plate carries the padding). A site with both kinds of page — a landing page of sections and a store — gets both in one block: the section list and the container together in SURFACE, the sizing rule for the container, one GLOW. Verify the plate like any surface: its first text element's `left` equals the header's at 1440, at the container's max plus twice the inset, and at 390.

## 5b. Fields and cards

`FIELD1` and `FIELD2` are one surface each, from the SURFACE list: the counterpart wash goes low-left on the photographic or gallery surface, the accent wash upper-right on the featured or product surface (`taste.md` §3). Write them in the same shape as SURFACE (`main > .gallery`), so specificity does not surprise you. `CARD` is the site's card selector inside those surfaces: `.card, .tile, .cell`, `article`, or a structural form like `section > div > div` when class names are generated; it matches only inside SURFACE, so the ground's cards stay as they are. A rule whose placeholder has no target is deleted.

## 6. Alignment compensation

An auto-centered container already absorbs the inset by itself; only a container that fills the surface needs compensation, and recipe.css handles both with `--unflat-max`.

Fill in the three placeholders: `SURFACE`, `GLOW`, and `.wrap` — replace `.wrap` with the site's container class, or `> *`.

- Set `--unflat-pad` to the container padding token (`--pad`, `--gutter`, `--container-padding`) or its literal value.
- Set `--unflat-max` to the container's outer max-width (`var(--max)` or a px value). Check `getComputedStyle(container).boxSizing` first; with `border-box` (the usual global reset) use the max-width as it is; add the horizontal padding when the container is `content-box`; leave `100vw` for a fluid container.
- If it does not (Tailwind `px-6`, hard-coded padding): read the container's computed `padding-left` and set `--unflat-pad` to that literal value (`24px`). When there is no container padding to give back (content touches the section edge), delete rule 5 from the block and shrink the inset to `clamp(8px, 1vw, 16px)` so the uncompensated shift stays under 16px; mention it in the report. The smaller inset is the one documented exception to the standard `clamp(8px, 1.6vw, 24px)`.

The compensation declaration is `!important` so it wins over `.section .container{padding…}` rules. If the container class is also used as a padded card somewhere (a bordered `.cta .wrap` with its own padding), exclude that section from rule 5 — `:is(SURFACE):not(.cta) > .wrap` — so its card padding stays symmetric; a section like that still gets its surface, only the compensation is skipped. If the container's padding changes at breakpoints with literal values, mirror them in `--unflat-pad` inside the block with the same media queries.

Verify: compare `getBoundingClientRect().left` of the header's first text element and of the first surface's first text element at 1440 and 390 — equal within 1px (at intermediate widths a 1px difference is the surface's own border).

## 7. Framework notes

| Stack | Where the block goes | Notes |
|---|---|---|
| Plain HTML | last `<style>` in `<head>`, before `</style>` | one newline character, no blank line: `/* unflat: end */\n</style>`. Insert programmatically: `node -e "const fs=require('fs');const [f,b]=process.argv.slice(1);const s=fs.readFileSync(f,'utf8');const i=s.lastIndexOf('</style>');fs.writeFileSync(f,s.slice(0,i)+fs.readFileSync(b,'utf8').replace(/\s+$/,'')+'\n'+s.slice(i))" page.html unflat-block.css` |
| Next.js (app or pages) | end of `app/globals.css` or `styles/globals.css` | after the Tailwind import if present |
| Vite / React / Vue | end of `src/index.css` or `src/style.css` | |
| Astro | end of `src/styles/global.css`, imported in the layout | |
| Nuxt | end of `assets/css/main.css` | |
| SvelteKit | end of `src/app.css` | |
| styled-components / Emotion | inside `createGlobalStyle` / `<Global>` as a template literal | keep the markers as comments |
| Tailwind v3 / v4 | plain unlayered CSS after `@tailwind utilities` / `@import "tailwindcss"` | unlayered CSS beats `@layer`; do not wrap the block in `@layer` |

## 8. Gotchas

- Surfaces carry `overflow: clip` so the field washes bleed no further than the surface; a child that must overflow a surface (a floating badge, a dropdown) needs `overflow: visible` on that surface, which then loses its wash. Sticky children keep working under `clip`.
- A section that already has `position: absolute` or `fixed` is not a surface.
- If `SURFACE` sections already carry a background image, keep it: use `background-image` and set only `background-color` on them.
- If the root has `display: grid` or `flex` with `gap`, set `margin-block: 0` on `:is(SURFACE)` and rely on the gap; margins do not collapse in a grid or flex container, so the recipe's breathing room would double between two adjacent surfaces.
- When SURFACE carries a `:not()` (`main > section:not(.hero)`), a bare-class GLOW (`.pricing`) loses on specificity and its shadow never shows; write GLOW in the same shape (`main > section.pricing`) so source order decides.
- A section that has its own class rule for `background`, `border` or `box-shadow` beats `:is(SURFACE)` on specificity; include that class in SURFACE (`main > section.story`) or repeat the selector (`:is(SURFACE):is(SURFACE)`) for that section.
- A ground section that has its own opaque background (the hero, a band) keeps it; the ground shows only where sections are transparent. That is fine: the hero's own color is part of the ground.

## 9. Escape hatch

When structure alone cannot express the choice, `data-unflat="surface"`, `data-unflat="ground"` and `data-unflat="glow"` attributes are allowed on sections. This is a markup change: report it explicitly, and keep it to the minimum.
