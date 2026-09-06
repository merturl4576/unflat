# Dogfood log

Each run: a fresh agent is told to read `skills/unflat/SKILL.md` and follow it on one `before.html`, writing `after.html` next to it. The demo is never hand-patched; if the result is weak, the skill is fixed and the run repeated.

Runs use a mid-tier model (Claude Sonnet) to stand in for a typical user. Browser steps ran through a headless Chromium helper because the Playwright MCP was unreachable; the audit snippet and the guardrail checks were evaluated in the page exactly as the references describe. Every accepted `after.html` passes `node scripts/check-examples.mjs` (after == before + one block).

| Run | Demo | Material chosen | Checker | Review verdict | Skill change made |
|---|---|---|---|---|---|
| 1 | 01-dark-workshop | plate | FAIL — block followed by a blank line before `</style>` | REJECT (transformation itself correct: plate, ground #0c0b0a, surfaces #161514→#1c1b1a, one glow on pricing) | wave 1: byte-exact terminator in SKILL.md/selectors.md + guardrails one-liner; audit snippet takes the first matching root and ignores fixed/sticky backgrounds; plate ground −3% L; glow selector guidance by content; tint guidance; hex-rounding tolerance |
| 2 | 01-dark-workshop | plate | PASS | REJECT — alignment compensation shifted surface content 23px outward at 1440 (auto-centered `.wrap` already absorbs the inset) | wave 2: width-aware compensation via `--unflat-max` (+ mobile block zeroes the inset); three named placeholders (`SURFACE`, `GLOW`, `.wrap`); programmatic insertion one-liner; hue pull via relative color syntax / snippet accent argument; audit snippet returns `shadowed`, `withBgImage`, `hasUnflatBlock`; wording fixes (tint is ground-only, print `#fff` exception, four dials, precedence of material tables, grain rows are SVG params, gap check generalised, backlit two glows) |
| decline | 01-dark-workshop/after.html (already layered) | — | — | PASS — stopped at Step 1, wrote nothing | — |
| exploratory | 02-light-editorial | paper | PASS | not judged (pre-wave-2 recipe) | notes folded into wave 2 |
| exploratory | 03-dark-saas | glass | FAIL — blank line before `</style>` (run cut by a usage limit) | not judged | reproduced the terminator trap → programmatic insertion (wave 2) |
| exploratory | 04-backlit-brand | backlit | PASS | not judged (pre-wave-2 recipe) | ground clamp printed L .098 → snippet floor lands at .102 |
| final | 01-dark-workshop | plate | PASS | ACCEPT — 14/14; alignment 0px at 1440 and 390; one glow on pricing | wave 3 (polish): tint whenever an accent exists (prose had contradicted the snippet) |
| final | 02-light-editorial | paper | PASS | ACCEPT — 14/14; ground −3.9% L, surfaces +0.6/+1.5% L; sheets on a desk | wave 3 (polish): light-theme shadow/vignette stated as a recipe (ink at alpha); re-audit gotcha |
| final | 03-dark-saas | glass | PASS | ACCEPT — 24/24 (14 checklist rows + 7 rules + 3 extra checks); alignment 0px at 1440 and 390; the run agent noticed `color-mix(in oklch, …, white N%)` drops the hue in Chromium and used `in oklab` | wave 3: `in oklab` for every white/black mix in light.md and the glass override (verified: oklch mix rendered rgb(28,18,21) warm, oklab rgb(17,21,29) cool) |
| final | 04-backlit-brand | backlit | PASS | ACCEPT — 14/14; ground clamped at L .102 (page bg L .126); two glows (hero, tickets) | wave 3 (polish): backlit override references `var(--unflat-light)`; override-merge wording |
| decline (final) | 01-dark-workshop/after.html | — | — | PASS — stopped at Step 1; audit returned shadowed 7, withBgImage 7, hasUnflatBlock true; wrote nothing | — |

## After the final wave

Two more fix waves landed after the final judgments: wave 3 (doc polish, `in oklab` for white/black mixes) and wave 4, driven by the task review — one tint rule (the snippet tints only when the accent's hue is more than 30° from the background's; light themes never), plate and glass tables aligned with the recipe (glass surfaces raised to `white 7%`/`3.5%` mixes: 2.9% L nominal, about 2.1% as rendered through the panels' transparency — for glass the 1.5–2.5% band is judged on that composited value), the glow-target wording, `!important` on the alignment compensation so it beats `.section .container{padding…}` rules, and audit counts that ignore fixed/sticky elements. Because the recipe changed, every demo was re-run against the current skill; the rows below are the shipped pages.

| Run | Demo | Material chosen | Checker | Review verdict | Skill change made |
|---|---|---|---|---|---|
| re-run | 01-dark-workshop | plate | PASS | ACCEPT — block identical in every value to the accepted run (ground untinted: accent hue 13.6° from the background's); differences limited to the removed header comment, the glow selector spelling and the `!important` compensation | — |
| re-run | 02-light-editorial | paper | PASS | ACCEPT — values identical to the accepted run; glow selector `:last-child` (same subscribe section) | — |
| re-run | 03-dark-saas | glass | PASS | ACCEPT — glass table raised to `white 7%`/`3.5%`: gradient 2.9% nominal, 2.1% as rendered through the panels' transparency (the band is judged on the composited value for glass); glow on the pricing section (featured tier); alignment first/last surface 0/+1px at 1440, 1100 and 390 | — |
| re-run | 04-backlit-brand | backlit | PASS | ACCEPT — values identical to the accepted run (ground tinted: accent hue 59.6° from the background's); two glows | — |


## After the final review

The final whole-branch review changed two things in the alignment rule: `--unflat-pad` is never `0px` while the rule is present, and a container class that is also a padded card is excluded from the compensation. Demo 03 has such a card (`.cta .wrap`), so it was re-run against the reviewed skill; the row below is the shipped page.

| Run | Demo | Material chosen | Checker | Review verdict | Skill change made |
|---|---|---|---|---|---|
| re-run 2 | 03-dark-saas | glass | PASS | ACCEPT — every `--unflat-*` value identical to the previous re-run; the compensation now skips the `.cta` card (`:is(main > section):not(.cta) > .wrap`), which keeps its padding symmetric (56px on every side at 1440); the run put the glow on the CTA instead of the pricing grid (it judged the Team tier's filled button not a featured tier — a call the skill leaves open); alignment 0/+1/0 px at 1440, 1100 and 390 | — |

## Showcase demo

After publishing, a fifth demo was added to show the block on a page with photographs: `05-forge-workshop`, a dark craft site with fourteen images. Its `after.html` was produced the same way as the others, by a fresh mid-tier agent following `SKILL.md`.

| Run | Demo | Material chosen | Checker | Review verdict | Skill change made |
|---|---|---|---|---|---|
| showcase | 05-forge-workshop | plate | PASS | ACCEPT — ground −3% L untinted (accent hue 10° from the background's), surfaces +1.9/+4.4% L; glow on the commission section (the page's call to action); alignment 0/+1/0 px at 1440, 1100 and 390; images untouched (`filter: none`, opaque surfaces under every photograph, grain visible only in the ground gaps); block strips back to before.html byte-for-byte | — |

## What the runs taught the skill

- Prose instructions about whitespace do not survive contact with a model; the insertion is now a one-line script.
- Alignment compensation depends on whether the container fills the surface; the recipe now derives that from `--unflat-max` at runtime instead of assuming a fluid container.
- Mixing a bright accent into a dark ground with `color-mix` raises lightness by about 3%; the hue pull now changes only hue and chroma.
- "Already layered" is decided by counts the audit snippet returns (`shadowed`, `withBgImage`, `hasUnflatBlock`), not by eye.
