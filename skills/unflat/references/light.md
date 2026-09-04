# Light physics

These rules turn the token table into the `--unflat-*` values. Ranges are limits, not suggestions; pick inside them.

## The one rule

**One light source per page.** Default is top-left: light enters from the upper left, the vignette sits bottom-right, top edges are lit, shadows fall down. Every layer obeys the same direction. The backlit material is the only exception: the light is behind the surfaces, so the light-line is symmetric and edges glow with the accent.

## How each value is derived

| Property | Dark theme | Light theme |
|---|---|---|
| `--unflat-ground` | page-bg darkened 4–8% L, hue pulled toward accent, chroma ≤ 0.02 | page-bg darkened 4–6% L, hue kept warm or cool as the palette |
| `--unflat-surface-bottom` | page-bg (unchanged) | page-bg (unchanged) |
| `--unflat-surface-top` | surface-bottom lightened 2–3% L | surface-bottom lightened 1–2% L (stay below `#fff`) |
| `--unflat-edge` (lit top border) | text at 9–12% alpha | white at 75–85% alpha |
| `--unflat-line` (other borders) | the site's line token, or text at 8–10% | the site's line token, or text at 6–8% |
| `--unflat-lightline` | text at .18–.25 alpha | white at .85–.95 alpha |
| `--unflat-shadow` | `0 40px 90px -50px rgba(0,0,0,.9), 0 2px 0 rgba(0,0,0,.55)` | `0 30px 60px -40px <ground hue dark at .25>, 0 1px 0 <text at .06>` |
| `--unflat-glow` | `0 60px 140px -70px <accent at .35–.40>` | `0 40px 100px -60px <accent at .12–.18>` |
| `--unflat-light` | warm palette `rgba(255,196,150,.075)`, cool `rgba(190,210,255,.06)`, neutral `rgba(255,255,255,.05)` | warm `rgba(255,250,240,.6)`, cool `rgba(240,246,255,.6)` |
| `--unflat-vignette` | `rgba(0,0,0,.45)` | `<ground hue dark at .10>` |
| `--unflat-grain-tint` | warm `1 .93 .84`, cool `.85 .9 1`, neutral `.8 .82 .86` | warm `.55 .5 .45`, cool `.45 .5 .58` |
| `--unflat-grain-alpha` | .12–.18 (renders as roughly 3–6% visible grain) | .08–.12 (≤ 4% under dense text) |
| `--unflat-inset` | `clamp(8px, 1.6vw, 24px)` | same |
| `--unflat-gap` | `clamp(14px, 2vw, 28px)` | same |
| `--unflat-pad` | the site's container padding variable, else `0px` | same |

"Text at N% alpha" means the site's primary text color with that alpha, for example `rgba(236,231,223,.10)`.

## Computing the colors

Preferred, when the codebase already uses modern CSS (any evergreen browser since 2023):

```css
--unflat-ground: color-mix(in oklch, var(--bg), black 12%);          /* about -6% L on a dark bg */
--unflat-ground: color-mix(in oklch, color-mix(in oklch, var(--bg), black 12%), var(--accent) 6%); /* + tint */
--unflat-surface-top: color-mix(in oklch, var(--bg), white 3%);
```

Rules of thumb: on a dark page-bg, `black 12%` ≈ −6% L and `white 3%` ≈ +2.5% L. On a light page-bg, `black 8%` ≈ −5% L and `white 40%` ≈ +1.5% L.

When you must write literal hex (older codebases, or the site has no custom properties), compute with Node instead of guessing:

```bash
node -e '
const hex=process.argv[1], dl=parseFloat(process.argv[2]);
const [r,g,b]=[1,3,5].map(i=>parseInt(hex.slice(i,i+2),16)/255);
const max=Math.max(r,g,b),min=Math.min(r,g,b);let h=0,s=0,l=(max+min)/2;
if(max!==min){const d=max-min;s=l>.5?d/(2-max-min):d/(max+min);
h=max===r?((g-b)/d+(g<b?6:0)):max===g?((b-r)/d+2):((r-g)/d+4);h/=6;}
l=Math.min(1,Math.max(0,l+dl/100));
const f=(p,q,t)=>{t<0&&(t+=1);t>1&&(t-=1);return t<1/6?p+(q-p)*6*t:t<.5?q:t<2/3?p+(q-p)*(2/3-t)*6:p};
const q=l<.5?l*(1+s):l+s-l*s,p=2*l-q;
const out=[f(p,q,h+1/3),f(p,q,h),f(p,q,h-1/3)].map(v=>Math.round(v*255).toString(16).padStart(2,"0")).join("");
console.log("#"+out)' "#121110" -6
```

`-6` darkens by six lightness points; `+2` lightens by two. HSL lightness is close enough to perceptual lightness for shifts this small.

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
- Ground and surface further apart than 8% L, which reads as boxes instead of depth.
- Pure black or pure white anywhere in the block.
- Texture over images or video.
