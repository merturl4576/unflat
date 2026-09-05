# Flatness audit

Goal: decide in five minutes whether the page is flat, and extract the tokens the block will be derived from. Do not write CSS during the audit.

## 1. Look

Open the page (browser tool if available; otherwise read the stylesheet). Answer these in your notes:

| Question | Flat answer |
|---|---|
| Is the page background one solid color? | yes |
| How many distinct background colors do top-level sections have? | 0, 1 or 2 |
| Do sections have shadows, borders, gradients or textures of their own? | no |
| Do cards float on the same color as the page, or on a different plane? | same color |
| Is there a light direction anyone could point to? | no |

Verdict:
- **Flat** when the page background is one color and sections have two or fewer distinct backgrounds with no depth cues. Continue.
- **Already layered** when three or more distinguishable planes exist with a consistent light. Stop and say so; offer only texture and light if asked.
- **Out of scope** when it is an app shell, admin panel or dashboard. Stop and say so.

## 2. Find fixed and sticky elements

They are excluded from surfaces and must be untouched: sticky header, cookie banner, floating action button, chat widget, drawers, modals. List them by selector.

## 3. Extract tokens

Priority order for each value:
1. `:root` custom properties (`--bg`, `--background`, `--surface`, `--text`, `--fg`, `--muted`, `--border`, `--line`, `--accent`, `--primary`, `--brand`, `--radius`).
2. Tailwind theme (`tailwind.config.*` `theme.extend.colors`, or `@theme` in the CSS entry for v4).
3. Computed styles of `body`, the first section, a card, a heading, a paragraph, a border and a primary button.

Fill this table; every later step reads from it:

| Token | Value | Source |
|---|---|---|
| page-bg | | |
| card-bg | (same as page-bg if cards are transparent) | |
| text | | |
| text-2 | (secondary or muted) | |
| line | (border color used on cards or dividers) | |
| accent | (primary button or link color) | |
| radius | (card or button radius; 0 if square) | |
| display-font | | |

Also note: theme (dark or light), warmth of the palette (warm, cool, neutral), accent saturation (low, medium, high), and the container padding variable if one exists (for example `--pad`, `--container-padding`, or Tailwind `px-6`).

## 4. Browser snippet

When a browser tool can evaluate JavaScript, run this on the page. It returns backgrounds of top-level children, fixed and sticky elements, and all `:root` custom properties, including ones declared inside `@media`, `@supports` or `@layer` blocks (later declarations overwrite earlier ones — this includes `@media` breakpoints, so audit at the viewport you are designing for and note which theme you are in).

```js
(() => {
  const cs = (el) => getComputedStyle(el);
  const roots = ['main > *', '#app > *', '#root > *', '#__next > *', 'body > *'];
  const kids = (roots.map((s) => [...document.querySelectorAll(s)]).find((a) => a.length) || [])
    .filter((e) => !['SCRIPT', 'STYLE', 'LINK', 'TEMPLATE'].includes(e.tagName));
  const visible = kids.filter((e) => !['fixed', 'sticky'].includes(cs(e).position));
  const bgs = visible
    .map((e) => cs(e).backgroundColor).filter((c) => c !== 'rgba(0, 0, 0, 0)');
  const shadowed = visible.filter((e) => cs(e).boxShadow !== 'none').length;
  const withBgImage = visible.filter((e) => cs(e).backgroundImage !== 'none').length;
  const sig = (e) => e.tagName.toLowerCase() + (e.id ? '#' + e.id : '') +
    (typeof e.className === 'string' && e.className ? '.' + e.className.trim().split(/\s+/).slice(0, 3).join('.') : '');
  const fixed = [...document.querySelectorAll('body *')]
    .filter((e) => ['fixed', 'sticky'].includes(cs(e).position)).map(sig).slice(0, 20);
  const vars = {};
  let hasUnflatBlock = [...document.querySelectorAll('style')].some((s) => s.textContent.includes('unflat: start'));
  const walk = (rules) => {
    for (const r of rules) {
      if (r.selectorText === ':root' || r.selectorText === 'html')
        for (const p of r.style) if (p.startsWith('--')) vars[p] = r.style.getPropertyValue(p).trim();
      try { if (r.cssText && r.cssText.includes('unflat: start')) hasUnflatBlock = true; } catch {}
      if (r.cssRules) walk(r.cssRules); // @media, @supports, @layer, nested rules
    }
  };
  for (const sheet of document.styleSheets) { let rules = []; try { rules = [...sheet.cssRules]; } catch {} walk(rules); }
  return {
    htmlBg: cs(document.documentElement).backgroundColor,
    bodyBg: cs(document.body).backgroundColor,
    topLevelCount: kids.length,
    distinctSectionBgs: [...new Set(bgs)],
    shadowed,
    withBgImage,
    hasUnflatBlock,
    fixedOrSticky: fixed,
    rootVars: vars,
  };
})()
```

Interpretation: `distinctSectionBgs.length <= 2` with no shadows means flat. `hasUnflatBlock` true, or `shadowed >= 2`, or `distinctSectionBgs.length >= 3` means already layered: stop and say why. `withBgImage` is informational only (gradients on sections are common on flat pages) and does not by itself mean layered. `htmlBg` not transparent matters for the block (see `guardrails.md`, painting order).

## 5. Output of the audit

Write in your response:
1. Five-line audit summary (one line per question in section 1).
2. The token table.
3. The exclusion list (fixed and sticky).
4. Theme, warmth, saturation, container padding variable.
