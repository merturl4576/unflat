---
name: unflat
description: Use when a website or landing page looks flat - one background color across the whole page, sections and cards floating on the same plane, no depth, no ground, no light. Also use when asked to add depth or texture, ground a site, make a background less boring, or to "unflat" a page. For marketing and content pages built with plain CSS, Tailwind, CSS modules or CSS-in-JS; not for app dashboards.
---

# unflat

Give a flat page a **ground**, **one light source** and **a few mounted surfaces** with a single reversible CSS block derived from the site's own colors. No markup changes. Delete the block to revert.

## Why pages look flat

AI-built pages put everything on one plane: a single background color, sections stacked on it, cards floating with nothing under them. There is no ground, no light, no material. The fix is not a redesign. It is three missing layers, added after the fact, in the site's own palette, and a rhythm: some sections mounted on the ground, the rest resting on it.

## The model: six moves

1. **Ground and lift.** Move the page background 1–3% lightness down (never near black) and lift the sections 2–3% up, the ground tinted toward the accent hue at very low chroma when the background does not already carry it (dark themes only). A separation of about 4–6% (never more than 6%) is what makes the sections sit on something.
2. **Light.** One fixed full-viewport layer behind content: a directional light (top-left by default) and a vignette in the opposite corner.
3. **Texture.** Inline SVG fractal noise tinted to the palette, 3–6% opacity. No image files.
4. **Rhythm.** Not every section is mounted. The hero, strips one row tall, sections with their own artwork or an interactive tool, and full-bleed galleries stay on the ground. The sections the visitor reads (a statement, the process, the story, a lookbook, the featured collection, pricing with a featured tier) alternate with them as surfaces. A third to a half of the sections end up mounted, with ground between them. A page where every section is a surface is a stack of boxes; that is flatness with borders.
5. **Surfaces.** The mounted sections: inset from the viewport edge, a 1.5–2.5% vertical gradient, a 1px border with a lit top edge, a deep shadow with a hairline base, a centered top light-line, and breathing room above and below. At most one surface carries an accent glow (two for the backlit material; none when the page has no call to action). A page that is one continuous flow (a store, an article, a product page) is one surface: the page plate.
6. **Alignment compensation.** Content inside a surface keeps the page grid: inner padding gives back the inset only where the container fills the surface (narrow viewports); centered max-width containers already align. Header and footer stay on the ground.

## Rules that do not bend

- **One block.** Everything lives between `/* unflat: start */` and `/* unflat: end */`, appended at the end of the global stylesheet (or in `unflat.css` imported last). Nothing else in the codebase changes.
- **Derived colors.** Every color comes from the site's tokens or computed styles. Never invent a palette. Never pure `#000` or `#fff` as a fill; alpha-white edges and alpha-black shadows are fine, and the print block resets the page to white for paper.
- **Rhythm over coverage.** The hero stays on the ground. Strips stay on the ground. Surfaces alternate with ground; two in a row is the exception, never the pattern, and every section mounted is never right.
- **One light source.** Ground, surfaces and shadows agree on a direction. Backlit is the only exception (light from behind).
- **Contrast preserved.** A surface's base color stays within 3% lightness of the original section background and its gradient adds at most 2.5% at the top edge, so existing text colors keep their contrast.
- **Ground stays ground.** Header, nav, footer, and anything `position: fixed` or `sticky` are never turned into surfaces.
- **No motion, no filters.** No animation, no `filter`, and `backdrop-filter` only for the glass material, off by default.
- **Reversible.** Deleting the block restores the site exactly. If a markup annotation was unavoidable, say so in the report.

## Workflow

### Step 0 — Scope
Find the pages in scope and the global stylesheet: Next `app/globals.css`, Vite `src/index.css`, Astro `src/styles/global.css`, Nuxt `assets/css/main.css`, styled-components `createGlobalStyle`, plain HTML: the last `<style>` in `<head>`.

### Step 1 — Flatness audit
Follow `references/audit.md`. Answer: is the page background one color; how many distinct section backgrounds exist (two or fewer means flat); what depth cues already exist; which elements are fixed or sticky. Extract the token table: page bg, card bg, text primary, text secondary, line, accent, radius, display font. List the top-level sections in order with their height and what they hold (the audit snippet returns this); Step 3 reads from that list. Write a five-line audit summary, the token table and the section list in your response.

Stop here if the page already has three or more distinguishable planes with a consistent light, or if it is an app shell or dashboard. Say why.

### Step 2 — Read the world, pick a material
Follow `references/materials.md`. What is this site about, what is its tone, is it dark or light, how saturated is the accent. Pick one of five materials from the decision table: **plate**, **paper**, **glass**, **slate**, **backlit**. Neutral fallbacks are plate for dark themes and paper for light themes. Glass is never a default. State the choice in one sentence.

### Step 3 — Choose the rhythm
Follow `references/selectors.md` §2–5. Walk the section list from Step 1 and mark every section **ground** or **mounted** with one reason each: the hero, strips, artwork and interactive sections, full-bleed galleries, header, footer, fixed and sticky elements are ground; the sections the visitor reads are candidates, and they alternate with ground. Then pick the one surface that carries the glow (§4). A page that is one continuous flow rather than a sequence of sections becomes one surface, the page plate (§5). Write the marked list in your response before deriving any value; it is the design decision of the whole job.

### Step 4 — Derive the material spec
Follow `references/light.md` to compute concrete values: ground color, surface top and bottom, edge highlight, line, light-line, shadow, glow target, light color, vignette, texture tint and opacity, inset, gap, container padding and outer max-width (`--unflat-pad`, `--unflat-max`). Present them as a short table before writing any CSS.

### Step 5 — Write the block
Copy `references/recipe.css`, fill in the `--unflat-*` values from Step 4, and replace the three placeholders — `SURFACE` (the mounted sections from Step 3, and only those), `GLOW` (one section) and `.wrap` (container class) — per `references/selectors.md`. Append the block at the end of the global stylesheet. For a single HTML file, insert it immediately before the last `</style>`. The block's last line is `/* unflat: end */`, and exactly one newline character separates it from `</style>` — no blank line. Byte view: `…/* unflat: end */\n</style>`. `recipe.css` already ends with that newline; do not add another. Insert it programmatically rather than by hand — with the block saved as `unflat-block.css`: `node -e "const fs=require('fs');const [f,b]=process.argv.slice(1);const s=fs.readFileSync(f,'utf8');const i=s.lastIndexOf('</style>');fs.writeFileSync(f,s.slice(0,i)+fs.readFileSync(b,'utf8').replace(/\s+$/,'')+'\n'+s.slice(i))" page.html unflat-block.css` — it trims the block's trailing whitespace and writes exactly one newline. A material's structural override (backlit's `body::before`, glass's field) replaces the recipe rule with the same selector; everything else in the recipe stays. Adjust or delete the inline comments next to values you override — they describe plate. Delete the recipe's header comment from the block you insert; keep the numbered rule comments.

### Step 6 — Verify
Run the checklist in `references/guardrails.md`. If a browser tool is available, screenshot before and after at 1440×900 and compare. Confirm: the hero and every strip still on the ground, surfaces alternating with ground, text contrast on surfaces unchanged, no horizontal scroll, sticky header untouched, print clean, no motion, one fixed pseudo-element, images not tinted.

### Step 7 — Report
Seven lines: material and why; the rhythm (which sections are mounted, which stay on the ground, which one glows); key values (ground, surface, edge, shadow); file touched and where the block sits; how to revert; four dials to tune (`--unflat-ground` depth, `--unflat-edge` light, `--unflat-inset` mounting, the grain alpha inside the SVG for texture); any markup change made.

## When to stop instead

- The site already has layered surfaces with a consistent light.
- The design is deliberately flat, brutalist, or every section is full-bleed photography.
- The target is an app dashboard, admin panel or product UI. unflat is for marketing and content pages.

## References

- `references/audit.md` — flatness audit procedure and a browser snippet that extracts tokens and the section list.
- `references/materials.md` — five materials, when to pick each, parameter tables and property overrides.
- `references/light.md` — light physics rules and how to compute the colors.
- `references/selectors.md` — rhythm: which sections are mounted; targeting them without touching markup; the page plate; framework notes.
- `references/guardrails.md` — verification checklist and gotchas.
- `references/recipe.css` — the block skeleton.
