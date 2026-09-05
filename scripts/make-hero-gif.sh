#!/usr/bin/env bash
# Builds assets/hero.gif: a left-to-right wipe from before to after for demos 01 and 03.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p scratch
W=960; H=600
clip() { # $1 before $2 after $3 out
  ffmpeg -y -loglevel error -loop 1 -t 2.2 -i "$1" -loop 1 -t 2.6 -i "$2" \
    -filter_complex "[0]scale=$W:$H[a];[1]scale=$W:$H[b];[a][b]xfade=transition=wipeleft:duration=1.0:offset=1.2,format=yuv420p" "$3"
}
clip assets/01-before.png assets/01-after.png scratch/scratch-01.mp4
clip assets/03-before.png assets/03-after.png scratch/scratch-03.mp4
printf "file '$(cd scratch && pwd -W)/scratch-01.mp4'\nfile '$(cd scratch && pwd -W)/scratch-03.mp4'\n" > scratch/scratch-list.txt
ffmpeg -y -loglevel error -f concat -safe 0 -i scratch/scratch-list.txt -c copy scratch/scratch-all.mp4
ffmpeg -y -loglevel error -i scratch/scratch-all.mp4 -vf "fps=12,scale=$W:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer:bayer_scale=4" assets/hero.gif
rm -rf scratch
ls -la assets/hero.gif
