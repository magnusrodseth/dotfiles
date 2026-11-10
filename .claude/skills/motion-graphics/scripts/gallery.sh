#!/usr/bin/env bash
# gallery.sh: render the component gallery (every transition, text effect, background, post effect, camera move,
# UI component, chart and logo reveal in its own labelled tile) as contact images. Use it to browse the library
# or to verify the library after a change.
#
#   bash gallery.sh [out-dir] [--logo path/to/logo.svg] [--groups transitions,text,...]
#
# Writes <out-dir>/<group>.png (several moments per group stacked vertically). Default out-dir: ~/Movies/motion-studio/_gallery
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"; skill="$(dirname "$here")"
out="$HOME/Movies/motion-studio/_gallery"; if [ $# -gt 0 ] && [[ "$1" != --* ]]; then out="$1"; shift; fi
logo=""; groups="transitions,text,backgrounds,post,camera,ui,charts,logo"
while [ $# -gt 0 ]; do case "$1" in --logo) logo="$2"; shift 2;; --groups) groups="$2"; shift 2;; *) echo "unknown flag $1" >&2; exit 1;; esac; done
proj="$out/project"; bash "$here/init.sh" "$proj" --w 1920 --h 1080 --dur 3 >/dev/null
cp "$skill/templates/gallery.html" "$proj/gallery.html"; for f in "$here"/lib/*.js "$here/motion.js"; do cp "$f" "$proj/lib/"; done
if [ -n "$logo" ]; then cp "$logo" "$proj/assets/logo.svg"; elif [ ! -f "$proj/assets/logo.svg" ]; then
  printf '%s' '<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg"><circle cx="24" cy="24" r="24" fill="#FFD84D"/><path d="M12 22 L24 11 L36 22 V37 H12 Z" fill="#141413"/><rect x="21" y="27" width="6" height="10" fill="#FFD84D"/></svg>' > "$proj/assets/logo.svg"; fi
cd "$proj"; mkdir -p "$out"
IFS=, read -ra G <<<"$groups"
for g in "${G[@]}"; do
  case "$g" in transitions|text|backgrounds|post|camera|ui|charts|logo) ;; *) echo "unknown group: $g" >&2; exit 1;; esac
  if [ "$g" = transitions ]; then times="0.2,0.4,0.6,0.8"; else times="0.25,0.7,1.5,2.6"; fi
  rm -rf "out/stills-$g"; node "$here/render.mjs" --page "gallery.html?group=$g" --stills "$times" --outdir "out/stills-$g" >/dev/null || echo "WARN: page errors in group $g (see red tiles)"
  ins=(); n=0; for f in out/stills-$g/*.png; do ins+=(-i "$f"); n=$((n+1)); done
  ffmpeg -hide_banner -loglevel error -y "${ins[@]}" -filter_complex "vstack=inputs=$n" "$out/$g.png"
  echo "$out/$g.png  ($times)"
done
