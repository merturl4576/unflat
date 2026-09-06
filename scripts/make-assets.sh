#!/usr/bin/env bash
# Builds the README images from the page captures in assets/:
#   assets/NN-compare.png  — before | after card for each demo
#   assets/hero.gif        — the terminal-agent demo: typing, a scroll, and a wipe from before to after
# Inputs: assets/NN-before.png and assets/NN-after.png are full-page screenshots of
# examples/NN-*/{before,after}.html at a 1440 px viewport, cropped to the top 2000 px and
# scaled to 720×1000. assets/src/hero-{before,after}.mp4 are frame-synchronized 960×600 captures of
# examples/06-terminal-agent/{before,after}.html (a faked clock drives the page's timers so both files
# animate identically; 12 fps, 8.5 s, a scroll from 3 s to 7.5 s). Captures are made with headless Chromium
# and are not part of this script.
# Needs ffmpeg with drawtext and one monospace TTF (FONT env var; defaults to Consolas on Windows).
set -euo pipefail
cd "$(dirname "$0")/.."
FONT=${FONT:-'C\:/Windows/Fonts/consola.ttf'}
mkdir -p scratch

card() { # NN material bar-color before-label-color after-label-color
  ffmpeg -y -loglevel error -i "assets/$1-before.png" -i "assets/$1-after.png" -filter_complex \
    "[0]pad=iw+8:ih:0:0:color=$3[a];[a][1]hstack[s];[s]pad=iw:ih+40:0:40:color=$3,\
drawtext=fontfile='$FONT':text='BEFORE':x=16:y=12:fontsize=15:fontcolor=$4,\
drawtext=fontfile='$FONT':text='AFTER  ·  $2':x=744:y=12:fontsize=15:fontcolor=$5" \
    "assets/$1-compare.png"
}
card 01 plate   0x0c0b0a 0x8a857d 0xe0b25c
card 02 paper   0xe9e6e1 0x7a756d 0x1f1c18
card 03 glass   0x070b12 0x8b96ab 0x6d8cff
card 04 backlit 0x060304 0x9a8f96 0xff2d9b
card 05 plate   0x0f0b08 0x7f7263 0xff6a1f
card 06 plate   0x0d0c0a 0x756d62 0xffb020

ffmpeg -y -loglevel error -i assets/src/hero-before.mp4 -i assets/src/hero-after.mp4 -filter_complex "[1]trim=start=5,setpts=PTS-STARTPTS[a1];[0][a1]xfade=transition=wipedown:duration=1.0:offset=5.0[x];[x]drawbox=x=14:y=14:w=78:h=26:color=0x0d0c0a@0.8:t=fill:enable='lt(t,5.5)',drawtext=fontfile='$FONT':text='before':x=24:y=19:fontsize=14:fontcolor=0xa89f92:enable='lt(t,5.5)',drawbox=x=14:y=14:w=66:h=26:color=0x0d0c0a@0.8:t=fill:enable='gte(t,5.5)',drawtext=fontfile='$FONT':text='after':x=24:y=19:fontsize=14:fontcolor=0xffb020:enable='gte(t,5.5)',format=yuv420p" scratch/hero.mp4
ffmpeg -y -loglevel error -i scratch/hero.mp4   -vf "fps=10,split[s0][s1];[s0]palettegen=max_colors=256:stats_mode=diff[p];[s1][p]paletteuse=dither=sierra2_4a"   assets/hero.gif
rm -rf scratch
ls -la assets/*-compare.png assets/hero.gif
