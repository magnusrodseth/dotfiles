#!/usr/bin/env bash
# mix.sh: mix music + sfx (+ optional voice, which ducks the music), normalize to -14 LUFS, mux onto the picture.
#
#   bash mix.sh --video out/silent.mp4 --music audio/score.wav [--sfx audio/sfx.wav] [--voice audio/voice.mp3] \
#               [--music-gain 0.8] [--sfx-gain 0.9] [--lufs -14] [--out out/final.mp4]
#
# Two-pass loudnorm, so the integrated loudness actually lands on target. Audio is trimmed to the video length.
set -euo pipefail

video="" music="" sfx="" voice="" out="out/final.mp4" mg=0.8 sg=0.9 lufs=-14 vdelay=0
while [ $# -gt 0 ]; do
  case "$1" in
    --video) video="$2"; shift 2;; --music) music="$2"; shift 2;; --sfx) sfx="$2"; shift 2;;
    --voice) voice="$2"; shift 2;; --out) out="$2"; shift 2;; --music-gain) mg="$2"; shift 2;;
    --sfx-gain) sg="$2"; shift 2;; --lufs) lufs="$2"; shift 2;; --voice-delay) vdelay="$2"; shift 2;;
    *) echo "unknown flag $1" >&2; exit 1;;
  esac
done
[ -n "$video" ] && [ -n "$music" ] || { echo "need --video and --music" >&2; exit 1; }

dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$video")
inputs=(-i "$music"); chain="[0:a]volume=${mg}[m]"; n=1; mixin="[m]"; count=1
if [ -n "$sfx" ]; then inputs+=(-i "$sfx"); chain+=";[$n:a]volume=${sg}[s]"; mixin+="[s]"; n=$((n+1)); count=$((count+1)); fi
if [ -n "$voice" ]; then
  inputs+=(-i "$voice")
  ms=$(python3 -c 'import sys; print(int(float(sys.argv[1])*1000))' "$vdelay")
  chain+=";[$n:a]adelay=${ms}|${ms},aformat=channel_layouts=stereo,asplit=2[v][vk];[m][vk]sidechaincompress=threshold=0.03:ratio=8:attack=20:release=350[md]"
  mixin="${mixin/\[m\]/[md]}[v]"; count=$((count+1))
fi
pre="${chain};${mixin}amix=inputs=${count}:normalize=0,atrim=0:${dur},apad=whole_dur=${dur}"

# Pass 1: measure.
stats=$(ffmpeg -hide_banner -nostats "${inputs[@]}" -filter_complex "${pre},loudnorm=I=${lufs}:TP=-1.5:LRA=11:print_format=json" -f null - 2>&1 | sed -n '/^{/,/^}/p')
get() { python3 -c "import json,sys; print(json.loads(sys.stdin.read())['$1'])" <<<"$stats"; }
mi=$(get input_i); mtp=$(get input_tp); mlra=$(get input_lra); mth=$(get input_thresh); off=$(get target_offset)

# Pass 2: apply, mux.
mkdir -p "$(dirname "$out")"
vin=$count  # the video goes last, so the audio input indexes in $pre stay valid
ffmpeg -hide_banner -loglevel error -y "${inputs[@]}" -i "$video" -filter_complex \
  "${pre},loudnorm=I=${lufs}:TP=-1.5:LRA=11:measured_I=${mi}:measured_TP=${mtp}:measured_LRA=${mlra}:measured_thresh=${mth}:offset=${off}:linear=true,aresample=192000,alimiter=limit=0.82:attack=1:release=50:level=false,aresample=48000[a]" \
  -map "${vin}:v" -map "[a]" -c:v copy -c:a aac -b:a 256k -movflags +faststart "$out"

got=$(ffmpeg -hide_banner -nostats -i "$out" -filter_complex ebur128=peak=true -f null - 2>&1 | awk '/Integrated loudness/{f=1} f&&/I:/{print $2; exit}')
echo "$(cd "$(dirname "$out")" && pwd)/$(basename "$out")  ${dur}s  integrated ${got} LUFS (target ${lufs})"
# The live preview (render.mjs --serve) plays this file in sync with the picture.
ffmpeg -hide_banner -loglevel error -y -i "$out" -vn -ac 2 -ar 48000 "$(dirname "$out")/preview.wav" || true
