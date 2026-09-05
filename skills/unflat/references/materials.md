# Materials

A material is a set of `--unflat-*` values plus a few structural choices. Where a material table states a number, it wins over the general ranges in light.md; light.md's ranges apply to anything the table leaves out. An override snippet replaces the recipe rule that has the same selector; do not keep both. Pick one per site. The material must come from the site's own world; when nothing fits, the neutral fallbacks are **plate** (dark) and **paper** (light). Glass is never a default.

## Decision table

| Theme | Domain | Material |
|---|---|---|
| dark | workshop, industrial, craft, hardware, automotive, gaming, restaurants, architecture | plate |
| dark | SaaS, AI, developer tools, modern fintech, analytics | glass |
| dark | brand, music, events, streetwear, nightlife, crypto, high-saturation accent | backlit |
| dark | enterprise, legal, B2B, government, insurance | slate |
| light | editorial, blog, docs, portfolio, publishing, education, agencies | paper |
| light | enterprise, legal, B2B, government, fintech | slate (light) |
| light | anything else | paper |
| dark | anything else | plate |

Tie-breakers: high accent saturation on a dark theme pushes toward backlit; a cool accent (blue, cyan, violet) on a dark theme pushes toward glass; warm accents (amber, brass, ember, terracotta) on dark push toward plate.

## plate — mounted plate

Dark. A panel mounted on a wall: warm light from the top-left catches the top edge, a deep shadow falls below, grain on the wall behind.

| Property | Value |
|---|---|
| ground | page-bg −3% L (the recipe default; never below L .10), hue toward accent, chroma ≤ .02 |
| surface top / bottom | page-bg +5% L / page-bg +3% L |
| edge | text at .10 |
| line | site line token |
| lightline | text at .22 |
| shadow | `0 40px 90px -50px rgba(0,0,0,.9), 0 2px 0 rgba(0,0,0,.55)` |
| glow | accent at .38, one surface |
| light | warm `rgba(255,196,150,.075)` (cool palettes: `rgba(190,210,255,.06)`) |
| vignette | `rgba(0,0,0,.45)` |
| grain | tint `1 .93 .84`, alpha .16 |

Override snippet: recipe.css defaults are the plate values; nothing to override beyond the derived colors.

## paper — sheets on a desk

Light. Sheets of paper lying on a slightly darker desk, lit from the top-left, with a soft diffuse shadow.

| Property | Value |
|---|---|
| ground | page-bg −4% L, keep the palette's warmth |
| surface top / bottom | page-bg +1.5% L (never `#fff`) / page-bg +0.5% L |
| edge | `rgba(255,255,255,.8)` |
| line | site line token, or text at .07 |
| lightline | `rgba(255,255,255,.9)` |
| shadow | `0 30px 60px -40px <ground hue, dark, at .25>, 0 1px 0 <text at .06>` e.g. `rgba(60,45,30,.25)` (= `--ink` at .25) |
| glow | accent at .14, one surface, optional |
| light | `rgba(255,250,240,.6)` |
| vignette | `<ground hue dark at .10>` e.g. `rgba(80,60,40,.10)` (= `--ink` at .10) |
| grain | tint `.55 .5 .45`, alpha .10 |

```css
/* paper overrides */
:root{--unflat-edge:rgba(255,255,255,.8);--unflat-lightline:rgba(255,255,255,.9);
  --unflat-shadow:0 30px 60px -40px rgba(60,45,30,.25),0 1px 0 rgba(28,26,23,.06);
  --unflat-light:rgba(255,250,240,.6);--unflat-vignette:rgba(80,60,40,.10)}
```
Change the grain `feColorMatrix` to `0 0 0 0 .55  0 0 0 0 .5  0 0 0 0 .45  0 0 0 .10 0`.

## glass — frosted panels on a field

Dark, cool or saturated accent. The ground is a soft field with two low-chroma accent blobs; panels are semi-transparent so the field shows through them; a 1px inner highlight reads as a glass edge. Blur is off by default (performance); enable `backdrop-filter` only for a few small panels.

| Property | Value |
|---|---|
| ground | page-bg −2% L, hue toward accent |
| field | two radial blobs in `body::before`: accent at .10 at `15% -10%`, secondary or accent at .07 at `90% 110%` |
| surface top / bottom | `color-mix(in oklab, <page-bg +4% L>, transparent 15%)` / `color-mix(in oklab, <page-bg +3% L>, transparent 8%)` |
| edge | `rgba(255,255,255,.12)` |
| line | `rgba(255,255,255,.07)` |
| lightline | `rgba(255,255,255,.25)` |
| shadow | `0 30px 80px -40px rgba(0,0,0,.7), inset 0 1px 0 rgba(255,255,255,.06)` |
| glow | accent at .30, one surface |
| light | cool `rgba(190,210,255,.06)` |
| vignette | `rgba(0,0,0,.4)` |
| grain | tint `.85 .9 1`, alpha .12 |

```css
/* glass overrides */
:root{--unflat-surface-top:color-mix(in oklab,color-mix(in oklab,var(--bg),white 5%),transparent 15%);
  --unflat-surface-bottom:color-mix(in oklab,color-mix(in oklab,var(--bg),white 3.5%),transparent 8%);
  --unflat-edge:rgba(255,255,255,.12);--unflat-line:rgba(255,255,255,.07);--unflat-lightline:rgba(255,255,255,.25);
  --unflat-shadow:0 30px 80px -40px rgba(0,0,0,.7),inset 0 1px 0 rgba(255,255,255,.06);
  --unflat-light:rgba(190,210,255,.06);--unflat-vignette:rgba(0,0,0,.4)}
body::before{background:
  radial-gradient(60% 50% at 15% -10%,<accent at .10> 0%,transparent 60%),
  radial-gradient(50% 40% at 90% 110%,<secondary at .07> 0%,transparent 60%),
  radial-gradient(100% 80% at 100% 110%,var(--unflat-vignette) 0%,transparent 60%),
  url("data:image/svg+xml;utf8,<grain svg with tint .85 .9 1 alpha .12>");
  background-size:auto,auto,auto,220px 220px}
```

## slate — stone

Neutral, dark or light. Cold light, planes close together, hairline borders, very fine grain, no glow. For sites that must feel serious.

| Property | Dark | Light |
|---|---|---|
| ground | page-bg −2% L, neutral hue | page-bg −3% L |
| surface top / bottom | page-bg +3% L / page-bg +1.5% L | page-bg +1% L / page-bg +0.5% L |
| edge | text at .08 | `rgba(255,255,255,.7)` |
| line | text at .07 | text at .06 |
| lightline | text at .14 | `rgba(255,255,255,.8)` |
| shadow | `0 24px 60px -40px rgba(0,0,0,.6), 0 1px 0 rgba(0,0,0,.4)` | `0 20px 40px -30px rgba(30,35,45,.2), 0 1px 0 rgba(30,35,45,.05)` (= `--ink` at .2 / at .05) |
| glow | none | none |
| light | `rgba(200,215,235,.05)` | `rgba(240,246,255,.5)` |
| vignette | `rgba(0,0,0,.3)` | `rgba(30,35,45,.06)` (= `--ink` at .06) |
| grain | tint `.8 .82 .86`, alpha .09 | tint `.45 .5 .58`, alpha .07 |

Remove the `GLOW` rule entirely for slate.

## backlit — lit from behind

Dark, high-saturation accent. The ground is the darkest; surfaces are lit from behind by the accent; edges carry the accent; the light-line is symmetric. Glow is allowed on two surfaces.

| Property | Value |
|---|---|
| ground | page-bg −3% L (never below L .10), hue toward accent |
| surface top / bottom | page-bg +4% L / page-bg +2% L |
| edge | accent at .25 |
| line | accent at .10 |
| lightline | accent at .45 |
| shadow | `0 40px 90px -50px rgba(0,0,0,.9), 0 0 0 1px <accent at .06>` |
| glow | `0 0 120px -30px <accent at .40>, 0 60px 140px -70px <accent at .40>`, up to two surfaces |
| light | `radial-gradient(60% 40% at 50% -10%, <accent at .12>, transparent 60%)` (replaces the top-left light) |
| secondary light | `radial-gradient(50% 40% at 50% 110%, <secondary at .06>, transparent 60%)` |
| vignette | `rgba(0,0,0,.5)` |
| grain | tint toward accent, e.g. `1 .85 .95` for pink, alpha .18 |

```css
/* backlit overrides (accent example #ff2d95) */
:root{--unflat-edge:rgba(255,45,149,.25);--unflat-line:rgba(255,45,149,.10);--unflat-lightline:rgba(255,45,149,.45);
  --unflat-shadow:0 40px 90px -50px rgba(0,0,0,.9),0 0 0 1px rgba(255,45,149,.06);
  --unflat-glow:0 0 120px -30px rgba(255,45,149,.40),0 60px 140px -70px rgba(255,45,149,.40);
  --unflat-light:rgba(255,45,149,.12);--unflat-vignette:rgba(0,0,0,.5)}
body::before{background:
  radial-gradient(60% 40% at 50% -10%,var(--unflat-light) 0%,transparent 60%),
  radial-gradient(50% 40% at 50% 110%,rgba(124,245,255,.06) 0%,transparent 60%),
  radial-gradient(100% 80% at 100% 110%,var(--unflat-vignette) 0%,transparent 60%),
  url("data:image/svg+xml;utf8,<grain svg with tint 1 .85 .95 alpha .18>");
  background-size:auto,auto,auto,220px 220px}
```

`--unflat-light` holds the primary light; only the second (foil) light is a literal.

## Adding a material

A new material needs: a name, the theme and domains it serves, the physics in one sentence, the full property table, and an override snippet. Add it to the decision table. Keep the one-light-source rule unless the physics genuinely differs, as with backlit.
