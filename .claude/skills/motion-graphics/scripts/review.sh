#!/usr/bin/env bash
# review.sh: the critique-loop evidence for a rendered film. LOOK at every image it writes.
#
#   bash review.sh out/final.mp4 [--at 4.2 --at 9.8] [--loop] [--poster 18.5]
#
# Writes into out/review/:
#   contact.png   2 frames per second, timestamped: pacing, dead beats, repetition
#   phone.png     1 fps at 360 px wide: readability at phone size
#   strip-<t>.png 12 consecutive frames around t: pops, overlaps, sliding instead of springing
#   poster.png    a single frame for thumbnails (default 40% in)
#   loop.mp4      the film twice back to back (only with --loop): watch the seam
# Prints loudness (integrated LUFS, true peak) when the file has audio.
set -euo pipefail
in="$1"; shift
ats=(); loop=0; poster=""
while [ $# -gt 0 ]; do
  case "$1" in --at) ats+=("$2"); shift 2;; --loop) loop=1; shift;; --poster) poster="$2"; shift 2;; *) echo "unknown flag $1" >&2; exit 1;; esac
done
od="$(dirname "$in")/review"; mkdir -p "$od"
font="/System/Library/Fonts/Supplemental/Arial Bold.ttf"
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$in")
w=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$in")
h=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$in")
if [ "$w" -gt "$h" ]; then cols=6; tw=400; else cols=8; tw=225; fi
rows=$(python3 -c "import math; print(math.ceil($dur*2/$cols))")
# Timestamps need drawtext (libfreetype). Homebrew's ffmpeg 9 dropped it (ffmpeg-full has it): stamp only when available.
if ffmpeg -hide_banner -filters 2>/dev/null | grep -q ' drawtext '; then
  stamp="drawtext=fontfile='$font':text='%{pts\:hms}':x=6:y=6:fontsize=$((tw/13)):fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=3,"
else stamp=""; echo "note: ffmpeg has no drawtext; review images are not timestamped (brew install ffmpeg-full to get them)"; fi
q=(-hide_banner -loglevel error -y)

ffmpeg "${q[@]}" -i "$in" -vf "fps=2,scale=${tw}:-2,${stamp}tile=${cols}x${rows}:padding=3:color=0x222222" -frames:v 1 "$od/contact.png"
prow=$(python3 -c "import math; print(math.ceil($dur/5))")
ffmpeg "${q[@]}" -i "$in" -vf "fps=1,scale=360:-2,${stamp}tile=5x${prow}:padding=3:color=0x222222" -frames:v 1 "$od/phone.png"
for t in "${ats[@]+"${ats[@]}"}"; do
  [[ "$t" =~ ^[0-9]+(\.[0-9]+)?$ ]] || { echo "invalid --at $t" >&2; exit 1; }
  s=$(python3 -c 'import sys; print(max(0, float(sys.argv[1]) - 0.1))' "$t")
  ffmpeg "${q[@]}" -ss "$s" -i "$in" -vf "scale=320:-2,tile=12x1:padding=2" -frames:v 1 "$od/strip-$t.png"
done
pt=${poster:-$(python3 -c "print(round($dur*0.4,2))")}
ffmpeg "${q[@]}" -ss "$pt" -i "$in" -frames:v 1 "$od/poster.png"
[ "$loop" = 1 ] && ffmpeg "${q[@]}" -stream_loop 1 -i "$in" -c copy "$od/loop.mp4"

echo "review: $(cd "$od" && pwd)"; ls -1 "$od"
if ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$in" | grep -q .; then
  ffmpeg -hide_banner -nostats -i "$in" -filter_complex ebur128=peak=true -f null - 2>&1 | awk '/Summary/{f=1} f&&/I:|Peak:/{print "  " $0}'
fi
