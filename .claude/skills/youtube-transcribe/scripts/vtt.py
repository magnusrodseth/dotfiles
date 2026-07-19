#!/usr/bin/env python3
"""Parse a WebVTT subtitle file.

Two jobs, both needed by the youtube-transcribe skill:

  text   Clean the VTT into readable prose (dedup overlapping cue windows,
         strip markup, decode HTML entities).
  find   Map phrases from the transcript back to timestamps, so a concept
         can be turned into an ffmpeg seek for frame extraction.

Deliberately Python rather than a sed/awk pipeline in SKILL.md. Three reasons,
all learned the hard way:

  1. `awk '!seen[$0]++'` in a SKILL.md body gets its `$0` INTERPOLATED with the
     skill's invocation argument before the agent ever sees it. The dedup then
     silently does nothing, and a plausible-looking transcript comes out with
     every line doubled.
  2. YouTube VTT payloads carry HTML-escaped markup (`&lt;b&gt;`). A `sed
     's/<[^>]*>//g'` strips real tags but leaves the escaped ones as literal
     text in the output.
  3. Timestamps must survive cleaning to drive frame extraction, which a
     one-way text pipeline throws away.

Usage:
    vtt.py text  <file.vtt>
    vtt.py find  <file.vtt> "phrase one" "phrase two" ...
"""

import html
import re
import sys


def parse(path):
    """Return [(timestamp, [line, ...])] with markup stripped and entities decoded.

    Line structure is PRESERVED rather than flattened to a single string. Auto-
    generated YouTube captions use rolling cue windows: each cue repeats the
    previous cue's line and appends one new one. Flattening here would make
    every cue body unique, so the caller's dedup could never fire and the
    transcript would come out with each line repeated two or three times.
    Manual subtitles are one line per cue and hide this entirely, so it only
    shows up on the auto-generated fallback path.
    """
    raw = open(path, encoding="utf-8").read()
    blocks = re.findall(
        r"(\d\d:\d\d:\d\d)\.\d\d\d --> [\d:.]+.*?\n(.*?)(?=\n\n|\Z)", raw, re.S
    )
    out = []
    for ts, body in blocks:
        body = html.unescape(body)          # &lt;b&gt; -> <b>
        body = re.sub(r"<[^>]*>", "", body)  # then strip all tags
        lines = [" ".join(l.split()) for l in body.split("\n")]
        lines = [l for l in lines if l]
        if lines:
            out.append((ts, lines))
    return out


def cmd_text(path):
    seen, lines = set(), []
    for _, body in parse(path):
        # Dedup at LINE level: rolling cue windows repeat lines across cues.
        for line in body:
            if line not in seen:
                seen.add(line)
                lines.append(line)
    text = " ".join(lines)
    # Group into paragraphs so the result is readable and quotable.
    sentences = re.findall(r"[^.!?]*[.!?]+", text) or [text]
    for i in range(0, len(sentences), 12):
        print(" ".join(s.strip() for s in sentences[i : i + 12]))
        print()


def cmd_find(path, phrases):
    cues, hit = parse(path), set()
    for ts, lines in cues:
        body = " ".join(lines)
        for p in phrases:
            if p.lower() in body.lower() and p not in hit:
                hit.add(p)
                print(f"{ts} | {body[:100]}")
    for p in phrases:
        if p not in hit:
            print(f"--:--:-- | NOT FOUND: {p}", file=sys.stderr)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    mode, vtt = sys.argv[1], sys.argv[2]
    if mode == "text":
        cmd_text(vtt)
    elif mode == "find":
        cmd_find(vtt, sys.argv[3:])
    else:
        sys.exit(f"unknown mode: {mode}")
