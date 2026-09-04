---
name: unflat
description: Use when a website or landing page looks flat - one background color across the whole page, sections and cards floating on the same plane, no depth, no ground, no light. Also use when asked to add depth or texture, ground a site, make a background less boring, or to "unflat" a page. For marketing and content pages built with plain CSS, Tailwind, CSS modules or CSS-in-JS; not for app dashboards.
---

# unflat

Give a flat page a **ground**, **one light source** and **mounted surfaces** with a single reversible CSS block derived from the site's own colors. No markup changes. Delete the block to revert.

## Why pages look flat

AI-built pages put everything on one plane: a single background color, sections stacked on it, cards floating with nothing under them. There is no ground, no light, no material. The fix is not a redesign. It is three missing layers, added after the fact, in the site's own palette.

## The model: five moves

1. **Ground and lift.** Move the page background 1–3% lightness down (never near black) and lift the sections 2–3% up, both tinted toward the accent hue at very low chroma. The 4–6% separation is what makes the sections sit on something.
2. **Light.** One fixed full-viewport layer behind content: a directional light (top-left by default) and a vignette in the opposite corner.
3. **Texture.** Inline SVG fractal noise tinted to the palette, 3–6% opacity. No image files.
4. **Surfaces.** Top-level sections become mounted surfaces: inset from the viewport edge, a 2–3% vertical gradient, a 1px border with a lit top edge, a deep shadow with a hairline base, and a centered top light-line. At most one surface carries an accent glow (two for the backlit material).
5. **Alignment compensation.** Content inside a surface keeps the page grid by reducing inner horizontal padding by the inset. Header and footer stay on the ground. Breathing margins separate surfaces.

## Rules that do not bend

- **One block.** Everything lives between `/* unflat: start */` and `/* unflat: end */`, appended at the end of the global stylesheet (or in `unflat.css` imported last). Nothing else in the codebase changes.
- **Derived colors.** Every color comes from the site's tokens or computed styles. Never invent a palette. Never pure `#000` or `#fff`.
- **One light source.** Ground, surfaces and shadows agree on a direction. Backlit is the only exception (light from behind).
- **Contrast preserved.** A surface's base color stays within 3% lightness of the original section background and its gradient adds at most 2.5% at the top edge, so existing text colors keep their contrast.
- **Ground stays ground.** Header, nav, footer, and anything `position: fixed` or `sticky` are never turned into surfaces.
- **No motion, no filters.** No animation, no `filter`, and `backdrop-filter` only for the glass material, off by default.
- **Reversible.** Deleting the block restores the site exactly. If a markup annotation was unavoidable, say so in the report.

## Workflow

### Step 0 — Scope
Find the pages in scope and the global stylesheet: Next `app/globals.css`, Vite `src/index.css`, Astro `src/styles/global.css`, Nuxt `assets/css/main.css`, styled-components `createGlobalStyle`, plain HTML: the last `<style>` in `<head>`.

### Step 1 — Flatness audit
Follow `references/audit.md`. Answer: is the page background one color; how many distinct section backgrounds exist (two or fewer means flat); what depth cues already exist; which elements are fixed or sticky. Extract the token table: page bg, card bg, text primary, text secondary, line, accent, radius, display font. Write a five-line audit summary and the token table in your response.

Stop here if the page already has three or more distinguishable planes with a consistent light, or if it is an app shell or dashboard. Say why.

### Step 2 — Read the world, pick a material
Follow `references/materials.md`. What is this site about, what is its tone, is it dark or light, how saturated is the accent. Pick one of five materials from the decision table: **plate**, **paper**, **glass**, **slate**, **backlit**. Neutral fallbacks are plate for dark themes and paper for light themes. Glass is never a default. State the choice in one sentence.

### Step 3 — Derive the material spec
Follow `references/light.md` to compute concrete values: ground color, surface top and bottom, edge highlight, line, light-line, shadow, glow target, light color, vignette, texture tint and opacity, inset, gap. Present them as a short table before writing any CSS.

### Step 4 — Write the block
Copy `references/recipe.css`, fill in the `--unflat-*` values from Step 3, and replace every `SURFACE` token with the structural selector list chosen per `references/selectors.md`. Append the block at the end of the global stylesheet. For a single HTML file, insert it immediately before the last `</style>`, followed by one newline.

### Step 5 — Verify
Run the checklist in `references/guardrails.md`. If a browser tool is available, screenshot before and after at 1440×900 and compare. Confirm: text contrast on surfaces unchanged, no horizontal scroll, sticky header untouched, print clean, no motion, one fixed pseudo-element, images not tinted.

### Step 6 — Report
Six lines: material and why; key values (ground, surface, edge, shadow); file touched and where the block sits; how to revert; three dials to tune (`--unflat-ground` depth, `--unflat-edge` light, the grain alpha inside the SVG for texture); any markup change made.

## When to stop instead

- The site already has layered surfaces with a consistent light.
- The design is deliberately flat, brutalist, or every section is full-bleed photography.
- The target is an app dashboard, admin panel or product UI. unflat is for marketing and content pages.

## References

- `references/audit.md` — flatness audit procedure and a browser snippet that extracts tokens.
- `references/materials.md` — five materials, when to pick each, parameter tables and property overrides.
- `references/light.md` — light physics rules and how to compute the colors.
- `references/selectors.md` — targeting sections without touching markup; framework notes.
- `references/guardrails.md` — verification checklist and gotchas.
- `references/recipe.css` — the block skeleton.
