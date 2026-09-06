#!/usr/bin/env bash
# Builds the README images from the page captures in assets/:
#   assets/hero.gif        — the camera demo: the page scrolls, the camera turns and sinks, then a wipe from before to after
# Inputs: assets/src/hero-{before,after}.mp4 are frame-synchronized captures of
# examples/07-camera-light/{before,after}.html at a 1440×1800 viewport scaled to 800×1000: time-based animations and
# transitions are switched off by an injected style, and the scroll position is set per frame from one schedule (12 fps, 10 s,
# a scroll of 1400 px from 2.5 s to 5 s), so both files show the same page state in every frame. Captures are made with
# headless Chromium and are not part of this script.
# Needs ffmpeg with drawtext and one monospace TTF (FONT env var; defaults to Consolas on Windows).
set -euo pipefail
cd "$(dirname "$0")/.."
FONT=${FONT:-'C\:/Windows/Fonts/consola.ttf'}
mkdir -p scratch


# hero: the camera demo. Before for 5 s (the page scrolls from 2.5 s, the camera turns and sinks), then a wipe from left to
# right into the after page over 2.5 s, then a hold. The label switches mid-wipe.
ffmpeg -y -loglevel error -i assets/src/hero-before.mp4 -i assets/src/hero-after.mp4 -filter_complex "\
[1]trim=start=5,setpts=PTS-STARTPTS[a1];[0][a1]xfade=transition=wiperight:duration=2.5:offset=5[x];\
[x]drawbox=x=14:y=14:w=78:h=26:color=0xffffff@0.85:t=fill:enable='lt(t,6.25)',drawtext=fontfile='$FONT':text='before':x=24:y=19:fontsize=14:fontcolor=0x6e6e73:enable='lt(t,6.25)',\
drawbox=x=14:y=14:w=66:h=26:color=0xffffff@0.85:t=fill:enable='gte(t,6.25)',drawtext=fontfile='$FONT':text='after':x=24:y=19:fontsize=14:fontcolor=0x2f6be6:enable='gte(t,6.25)',format=yuv420p" scratch/hero.mp4
ffmpeg -y -loglevel error -i scratch/hero.mp4   -vf "fps=10,split[s0][s1];[s0]palettegen=max_colors=256:stats_mode=diff[p];[s1][p]paletteuse=dither=sierra2_4a"   assets/hero.gif
rm -rf scratch
ls -la assets/hero.gif
