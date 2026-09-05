# Light physics

These rules turn the token table into the `--unflat-*` values. Ranges are limits, not suggestions; pick inside them.

## The one rule

**One light source per page.** Default is top-left: light enters from the upper left, the vignette sits bottom-right, top edges are lit, shadows fall down. Every layer obeys the same direction. The backlit material is the only exception: the light is behind the surfaces, so the light-line is symmetric and edges glow with the accent.

## Ground and lift

Where a material table (`materials.md`) states a number, it wins over the general ranges below; these ranges apply to anything the table leaves out.

The separation between ground and surface is 4–6% L in total, and it is split: the ground goes down a little, the surfaces come up a little. Dark pages have no room below them (a page at L 0.15 is two steps from black), so most of the separation is lift. The origin site (a different, darker palette: page-bg L 0.154) measured ground L 0.144 and surfaces L 0.187–0.202. The worked example below uses `#121110` (L 0.178). The ground never goes below L 0.10, and a surface's base never rises more than 3% L above the original background, so text contrast is unchanged.

## How each value is derived

Grain tint and alpha are edited inside the SVG in `recipe.css` (its `feColorMatrix`), not declared as custom properties. On light themes, `--unflat-shadow` and `--unflat-vignette` use the text color (`--ink`) at the stated alphas; on dark themes they use `rgba(0,0,0,α)` — the material tables' rgba values are examples of exactly that rule.

| Property | Dark theme | Light theme |
|---|---|---|
| `--unflat-ground` | page-bg darkened 1–3% L, never below L 0.10; hue pulled toward accent, chroma ≤ 0.02 | page-bg darkened 3–4% L, hue kept warm or cool as the palette |
| `--unflat-surface-bottom` | page-bg lightened 2–3% L (the surface's base color) | page-bg lightened 0.5–1% L |
| `--unflat-surface-top` | surface-bottom lightened 1.5–2.5% L | surface-bottom lightened 0.5–1% L (stay below `#fff`) |
| `--unflat-edge` (lit top border) | text at 9–12% alpha | white at 75–85% alpha |
| `--unflat-line` (other borders) | the site's line token, or text at 8–10% | the site's line token, or text at 6–8% |
| `--unflat-lightline` | text at .18–.25 alpha | white at .85–.95 alpha |
| `--unflat-shadow` | `0 40px 90px -50px rgba(0,0,0,.9), 0 2px 0 rgba(0,0,0,.55)` | `0 30px 60px -40px <ground hue dark at .25>, 0 1px 0 <text at .06>` |
| `--unflat-glow` | `0 60px 140px -70px <accent at .35–.40>` | `0 40px 100px -60px <accent at .12–.18>` |
| `--unflat-light` | warm palette `rgba(255,196,150,.075)`, cool `rgba(190,210,255,.06)`, neutral `rgba(255,255,255,.05)` | warm `rgba(255,250,240,.6)`, cool `rgba(240,246,255,.6)` |
| `--unflat-vignette` | `rgba(0,0,0,.45)` | `<ground hue dark at .10>` |
| grain tint (SVG feColorMatrix) | warm `1 .93 .84`, cool `.85 .9 1`, neutral `.8 .82 .86` | warm `.55 .5 .45`, cool `.45 .5 .58` |
| grain alpha (SVG feColorMatrix) | .12–.18 (renders as roughly 3–6% visible grain) | .08–.12 (≤ 4% under dense text) |
| `--unflat-inset` | `clamp(8px, 1.6vw, 24px)` | same |
| `--unflat-gap` | `clamp(14px, 2vw, 28px)` | same |
| `--unflat-pad` | the site's container padding variable, else `0px` | same |
| `--unflat-max` | the container's outer max-width: `var(--max)` or the px value (add the horizontal padding when the container is `content-box`); `100vw` when the container is fluid | same |

"Text at N% alpha" means the site's primary text color with that alpha, for example `rgba(236,231,223,.10)`.

## Computing the colors

Preferred, when the codebase already uses modern CSS (any evergreen browser since 2023):

```css
--unflat-ground: color-mix(in oklch, var(--bg), black 15%);           /* about -2.5% L on a dark bg */
--unflat-surface-bottom: color-mix(in oklch, var(--bg), white 3%);    /* about +2.5% L */
--unflat-surface-top: color-mix(in oklch, var(--bg), white 6%);       /* about +5% L */
```

Rules of thumb: mixing with black scales L by (1 − p); mixing with white adds p × (1 − L). On a dark bg (L ≈ 0.15–0.20): black 15% ≈ −2.5% L, white 3% ≈ +2.5% L, white 6% ≈ +5% L. On a light bg (L ≈ 0.96): black 4% ≈ −4% L, white 40% ≈ +1.5% L.

To pull the hue toward the accent, do not mix the accent color in directly — it carries its own lightness along with its hue, so a bright accent lifts L by several percent. Use relative color syntax instead: it changes only lightness and sets a low, fixed chroma at the accent's hue:

```css
--unflat-ground: oklch(from var(--bg) calc(l - 0.03) 0.015 H);
--unflat-surface-bottom: oklch(from var(--bg) calc(l + 0.02) 0.015 H);
--unflat-surface-top: oklch(from var(--bg) calc(l + 0.045) 0.015 H);
```

`H` is the accent's OKLCh hue in degrees, a literal number you compute and write in (see the Node snippet below). Relative color syntax (`oklch(from …)`) is Baseline: Chrome 119, Safari 16.4, Firefox 128.

When you must write literal hex (older codebases, or the site has no custom properties), compute in OKLab with Node instead of guessing:

```bash
node -e '
const hex=process.argv[1], dl=parseFloat(process.argv[2])/100, accentHex=process.argv[3];
const s2l=c=>c<=.04045?c/12.92:((c+.055)/1.055)**2.4, l2s=c=>c<=.0031308?12.92*c:1.055*c**(1/2.4)-.055;
const toLab=h=>{const [r,g,b]=[1,3,5].map(i=>s2l(parseInt(h.slice(i,i+2),16)/255));
  const l_=Math.cbrt(.4122214708*r+.5363325363*g+.0514459929*b), m_=Math.cbrt(.2119034982*r+.6806995451*g+.1073969566*b), s_=Math.cbrt(.0883024619*r+.2817188376*g+.6299787005*b);
  return [.2104542553*l_+.7936177850*m_-.0040720468*s_,1.9779984951*l_-2.4285922050*m_+.4505937099*s_,.0259040371*l_+.7827717662*m_-.8086757660*s_]};
const [L0,A0,B0]=toLab(hex);
let L=L0+dl<.10?.102:Math.min(1,L0+dl), A=A0, B=B0, pre="";
if(accentHex){
  const [,aA,aB]=toLab(accentHex), H=(Math.atan2(aB,aA)*180/Math.PI+360)%360, c=Math.sqrt(A*A+B*B), c2=Math.min(.02,Math.max(c,.012)), rad=H*Math.PI/180;
  A=c2*Math.cos(rad); B=c2*Math.sin(rad); pre="H="+H.toFixed(1)+" ";
}
const l2=(L+.3963377774*A+.2158037573*B)**3, m2=(L-.1055613458*A-.0638541728*B)**3, s2=(L-.0894841775*A-1.2914855480*B)**3;
const out=[4.0767416621*l2-3.3077115913*m2+.2309699292*s2,-1.2684380046*l2+2.6097574011*m2-.3413193965*s2,-.0041960863*l2-.7034186147*m2+1.7076147010*s2].map(v=>Math.round(Math.min(1,Math.max(0,l2s(v)))*255).toString(16).padStart(2,"0")).join("");
console.log(pre+"#"+out)' "#121110" -3
```

`-3` darkens by three OKLab lightness points; `+2` lightens by two. Expected results (no third argument, behavior unchanged from before): `"#121110" -3` → `#0c0b0a`, `"#121110" +2` → `#161514`, `"#121110" +4.5` → `#1c1b1a`. Print the result for the ground, the surface base and the surface top, then write the hex values into the block. When the shift would cross the floor, the snippet lands at L 0.102 so the printed hex stays at or above L 0.10.

Give a third argument, the accent's hex, to also pull the hue: the snippet then prints the accent's OKLCh hue `H` followed by the shifted color with its hue set to `H` and its chroma set to `min(0.02, max(c, 0.012))` (`c` is the shifted color's own chroma) — the same low-chroma technique as the CSS above. Without the third argument the snippet behaves exactly as today. Apply the hue pull for the ground only (surfaces keep the page background's own hue): the tint comes either from this third argument or from the relative-color CSS above. Skip it when the page background's chroma is below 0.01.

## Texture

The grain is an inline SVG in `body::before`:

```
<svg xmlns='http://www.w3.org/2000/svg' width='220' height='220'>
  <filter id='n'>
    <feTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='3' stitchTiles='stitch'/>
    <feColorMatrix values='0 0 0 0 R  0 0 0 0 G  0 0 0 0 B  0 0 0 A 0'/>
  </filter>
  <rect width='220' height='220' filter='url(#n)'/>
</svg>
```

`R G B` is `--unflat-grain-tint` (0–1 each) and `A` is `--unflat-grain-alpha`. Tile 200–260px. Keep the SVG on one line inside `url("data:image/svg+xml;utf8,...")` and encode `#` as `%23`. The texture sits behind content by default; an optional film overlay on top of everything is capped at 4% opacity and must not cover photography.

## Glow

Glow marks the one surface the page is about (pricing, the product, the featured collection). One surface only; two for backlit. Glow is `box-shadow` with negative spread so it bleeds outward without a hard edge.

## What never happens

- A second light direction (for example lit top edges plus a shadow that falls upward).
- Ground and surface base further apart than 6% L, which reads as boxes instead of depth. A ground below L 0.10 on a dark page, which reads as a hole.
- Pure black or pure white anywhere in the block.
- Texture over images or video.
