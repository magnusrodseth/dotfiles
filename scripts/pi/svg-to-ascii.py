#!/usr/bin/env python3
"""Render Lucide's `terminal` icon to half-block ASCII for the Pi header logo.

Source of the LOGO constant in .pi/agent/extensions/claude-parity/index.ts.
Committed so the logo is reproducible rather than a magic block of glyphs.

    python3 scripts/pi/svg-to-ascii.py --cols 24 --rows 12 --radius 1.2

The SVG is two stroked polylines with round caps, so coverage is analytic: a
point is ink when its distance to either polyline is <= the stroke radius. No
rasteriser, no dependencies, and no anti-aliasing to threshold.

Sampling happens at half-block resolution, mapping each cell's upper and lower
half to one of ▀ ▄ █ or a space. A terminal cell is about twice as tall as it
is wide, which makes a half-cell roughly square, so a `cols` x `2*rows` sample
grid with cols == 2*rows reproduces the icon's square aspect.
"""

from __future__ import annotations

import argparse

# <svg viewBox="0 0 24 24" stroke-width="2" stroke-linecap="round" ...>
#   <path d="M12 19h8"/>
#   <path d="m4 17 6-6-6-6"/>
VIEWBOX = 24.0
POLYLINES: list[list[tuple[float, float]]] = [
    [(12.0, 19.0), (20.0, 19.0)],
    [(4.0, 17.0), (10.0, 11.0), (4.0, 5.0)],
]


def dist_to_segment(px, py, ax, ay, bx, by) -> float:
    vx, vy = bx - ax, by - ay
    wx, wy = px - ax, py - ay
    length_sq = vx * vx + vy * vy
    t = 0.0 if length_sq == 0 else max(0.0, min(1.0, (wx * vx + wy * vy) / length_sq))
    cx, cy = ax + t * vx, ay + t * vy
    return ((px - cx) ** 2 + (py - cy) ** 2) ** 0.5


def is_ink(px: float, py: float, radius: float) -> bool:
    """Round caps and joins mean the stroke is a capsule around each segment."""
    for line in POLYLINES:
        for i in range(len(line) - 1):
            if dist_to_segment(px, py, *line[i], *line[i + 1]) <= radius:
                return True
    return False


def render(cols: int, rows: int, radius: float, supersample: int = 3) -> list[str]:
    half_rows = rows * 2
    grid = []
    for hr in range(half_rows):
        line = []
        for c in range(cols):
            hits = 0
            for sy in range(supersample):
                for sx in range(supersample):
                    x = VIEWBOX * (c + (sx + 0.5) / supersample) / cols
                    y = VIEWBOX * (hr + (sy + 0.5) / supersample) / half_rows
                    if is_ink(x, y, radius):
                        hits += 1
            line.append(hits * 2 >= supersample * supersample)
        grid.append(line)

    out = []
    for r in range(rows):
        top, bottom = grid[2 * r], grid[2 * r + 1]
        out.append(
            "".join(
                "█" if t and b else "▀" if t else "▄" if b else " "
                for t, b in zip(top, bottom)
            )
        )
    return out


def trim(rows: list[str]) -> list[str]:
    """Drop blank edge rows and columns so the glyph sits flush in its frame."""
    rows = list(rows)
    while rows and not rows[0].strip():
        rows.pop(0)
    while rows and not rows[-1].strip():
        rows.pop()
    if not rows:
        return rows
    width = max(len(r) for r in rows)
    rows = [r.ljust(width) for r in rows]
    left = min(len(r) - len(r.lstrip()) for r in rows if r.strip())
    rows = [r[left:].rstrip() for r in rows]
    width = max(len(r) for r in rows)
    return [r.ljust(width) for r in rows]


def framed(inner: list[str], pad_x: int = 2) -> list[str]:
    """Light rounded corners with heavy edges.

    Unicode has no heavy rounded corner: ╭╮╰╯ exist only at light weight and
    ┏┓┗┛ are heavy but square. The rounding matters more than a matched join.
    """
    width = max(len(line) for line in inner)
    body = [" " * pad_x + line.ljust(width) + " " * pad_x for line in inner]
    inner_width = width + 2 * pad_x
    return (
        ["╭" + "━" * inner_width + "╮"]
        + ["┃" + line + "┃" for line in body]
        + ["╰" + "━" * inner_width + "╯"]
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cols", type=int, default=24)
    parser.add_argument("--rows", type=int, default=12)
    parser.add_argument("--radius", type=float, default=1.2, help="stroke radius in SVG units")
    parser.add_argument("--ts", action="store_true", help="emit a TypeScript array literal")
    args = parser.parse_args()

    logo = framed(trim(render(args.cols, args.rows, args.radius)))
    if args.ts:
        print("const LOGO = [")
        for line in logo:
            print(f'\t"{line}",')
        print("];")
    else:
        for line in logo:
            print(line)


if __name__ == "__main__":
    main()
