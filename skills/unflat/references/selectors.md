# Selectors: surfaces without touching markup

`SURFACE` in recipe.css stands for the list of top-level sections that become surfaces. `GLOW` stands for the one of them that carries the accent glow. Fill both with structural selectors; never add classes or wrappers to the markup. recipe.css wraps every token in `:is()`, so paste your selector or comma-separated list as-is — do not add your own `:is()`, and do not strip the existing one.

## 1. Find the container

Look for the tightest element that directly holds the page's sections. Common shapes:

| Markup | SURFACE |
|---|---|
| `<main><section>…</section>…</main>` | `main > section` |
| `<main><div class="…">…</div>…</main>` | `main > div` |
| `<div id="app"><section>…` | `#app > section` |
| `<div id="root"><main><section>…` | `#root > main > section` |
| `<div id="__next"><main>…` | `#__next > main > section` |
| Sections directly under `<body>` | `body > section` |

## 2. Exclude what stays on the ground

Header, nav, footer, and anything `position: fixed` or `sticky` (cookie banners, chat widgets, floating buttons, drawers, dialogs). If the container mixes them with sections, exclude explicitly:

```css
main > :not(header):not(nav):not(footer):not([role="dialog"])
```

## 3. The hero

If the hero has a background image, video or canvas, it stays on the ground (a surface border would fight the artwork). Otherwise it becomes the first surface. Exclude with `:not(:first-child)` or `:not(.hero)` when needed.

## 4. Alternating sections

If the site alternates two background shades, map them to planes instead of flattening them: the lighter shade becomes a surface, the darker shade stays on the ground. Example:

```css
main > section:nth-child(odd)    /* SURFACE */
main > section:nth-child(even){background:transparent}   /* rests on the ground */
```

## 5. Unstable class names

Tailwind, hashed CSS modules and styled-components produce class names you cannot rely on. Target by structure and content with `:has()`:

```css
main > :has(> .container)              /* sections that contain a container */
main > :has(> h2)                      /* sections with a heading */
main > *:not(:has(img, video, canvas)) /* sections without artwork */
```

`:has()` is supported in every evergreen browser since 2023.

## 6. Choosing GLOW

One surface only (two for backlit): the one the page is about. Pricing, the featured product, the collection, the signup. Examples: `main > section:nth-last-child(2)` (usually the CTA before the footer), `main > section:has(> .pricing)`, `main > section:has(h2:first-of-type)` is too broad; be specific.

## 7. Alignment compensation

Surfaces are inset by `--unflat-inset`. Content inside them must keep the page grid.

- If the site has a container padding variable (`--pad`, `--gutter`, `--container-padding`): set `--unflat-pad: var(--pad)` and keep `SURFACE > .wrap { padding-inline: calc(var(--unflat-pad) - var(--unflat-inset)) }`, replacing `.wrap` with the container class or `> *`.
- If it does not (Tailwind `px-6`, hard-coded padding): keep the inset small (`clamp(8px, 1vw, 16px)`) and let centered content stay centered. Left-aligned content next to the edge shifts by the inset; mention it in the report.

## 8. Framework notes

| Stack | Where the block goes | Notes |
|---|---|---|
| Plain HTML | last `<style>` in `<head>`, before `</style>` | insert block + one newline |
| Next.js (app or pages) | end of `app/globals.css` or `styles/globals.css` | after the Tailwind import if present |
| Vite / React / Vue | end of `src/index.css` or `src/style.css` | |
| Astro | end of `src/styles/global.css`, imported in the layout | |
| Nuxt | end of `assets/css/main.css` | |
| SvelteKit | end of `src/app.css` | |
| styled-components / Emotion | inside `createGlobalStyle` / `<Global>` as a template literal | keep the markers as comments |
| Tailwind v3 / v4 | plain unlayered CSS after `@tailwind utilities` / `@import "tailwindcss"` | unlayered CSS beats `@layer`; do not wrap the block in `@layer` |

## 9. Gotchas

- A section with `overflow: hidden` clips the light-line at `top: -1px`. Use `top: 0` for that section.
- A section that already has `position: absolute` or `fixed` is not a surface.
- If `SURFACE` sections already carry a background image, keep it: use `background-image` and set only `background-color` on them.
- If the container has `display: grid` or `flex` with `gap`, drop the `:is(SURFACE) + :is(SURFACE) { margin-top }` rule and rely on the gap.

## 10. Escape hatch

When structure alone cannot express the choice, `data-unflat="surface"`, `data-unflat="ground"` and `data-unflat="glow"` attributes are allowed on sections. This is a markup change: report it explicitly, and keep it to the minimum.
