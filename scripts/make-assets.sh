#!/usr/bin/env bash
# Builds the README images from the page captures in assets/:
#   assets/NN-compare.png  — before | after card for each demo
#   assets/hero.gif        — two demos (glass, backlit) wiping from before to after
# Inputs: assets/NN-before.png and assets/NN-after.png are full-page screenshots of
# examples/NN-*/{before,after}.html at a 1440 px viewport, cropped to the top 2000 px and
# scaled to 720×1000 (headless Chromium; the capture is not part of this script).
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

W=576; H=800
ffmpeg -y -loglevel error \
  -loop 1 -t 2.6 -i assets/03-before.png -loop 1 -t 2.6 -i assets/04-before.png \
  -loop 1 -t 3.6 -i assets/03-after.png  -loop 1 -t 3.6 -i assets/04-after.png \
  -filter_complex "[0]scale=$W:$H[b0];[1]scale=$W:$H[b1];[b0][b1]hstack[before];\
[2]scale=$W:$H[a0];[3]scale=$W:$H[a1];[a0][a1]hstack[after];\
[before][after]xfade=transition=wipedown:duration=1.2:offset=1.2[x];\
[x]pad=iw:ih+40:0:40:color=0x08080a,\
drawtext=fontfile='$FONT':text='before':x=16:y=12:fontsize=16:fontcolor=0x9a958d:enable='lt(t,1.8)',\
drawtext=fontfile='$FONT':text='after  ·  one CSS block, colors derived from the site':x=16:y=12:fontsize=16:fontcolor=0xe0b25c:enable='gte(t,1.8)',\
format=yuv420p" scratch/hero.mp4
ffmpeg -y -loglevel error -i scratch/hero.mp4 \
  -vf "fps=12,split[s0][s1];[s0]palettegen=max_colors=256:stats_mode=diff[p];[s1][p]paletteuse=dither=sierra2_4a" \
  assets/hero.gif
rm -rf scratch
ls -la assets/*-compare.png assets/hero.gif
