#!/usr/bin/env python3
"""
Generate or edit images via OpenAI's gpt-image-2 (ChatGPT Images 2.0) API.
Stdlib only. Requires OPENAI_API_KEY in the environment.

Examples:
    generate.py "A watercolor fjord at dawn" --size 1024x1024 --quality high
    generate.py "Make the sky a sunset" --edit-image photo.png
    generate.py "Combine these" --edit-image a.png --edit-image b.png --n 2
"""
from __future__ import annotations

import argparse
import base64
import json
import mimetypes
import os
import sys
import time
import urllib.error
import urllib.request
import uuid
from pathlib import Path

API_BASE = "https://api.openai.com/v1"
GENERATE_URL = f"{API_BASE}/images/generations"
EDIT_URL = f"{API_BASE}/images/edits"
TIMEOUT_SECONDS = 300


def die(msg: str, code: int = 1) -> None:
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(code)


def require_api_key() -> str:
    key = os.environ.get("OPENAI_API_KEY")
    if not key:
        die("OPENAI_API_KEY is not set. Export it in your shell first.")
    return key


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        prog="generate.py",
        description="OpenAI gpt-image-2 image generation and editing.",
    )
    p.add_argument("prompt", help="Text prompt (up to 32,000 chars).")
    p.add_argument("--model", default="gpt-image-2",
                   choices=["gpt-image-2", "gpt-image-1.5", "gpt-image-1", "gpt-image-1-mini"])
    p.add_argument("--size", default="auto",
                   help="auto | 1024x1024 | 1536x1024 | 1024x1536 | WxH (gpt-image-2, divisible by 16)")
    p.add_argument("--quality", default="auto", choices=["auto", "low", "medium", "high"])
    p.add_argument("--n", type=int, default=1, help="Number of images (1-10).")
    p.add_argument("--format", dest="output_format", default="png",
                   choices=["png", "jpeg", "webp"])
    p.add_argument("--background", default="auto", choices=["auto", "transparent", "opaque"])
    p.add_argument("--compression", type=int, default=None,
                   help="0-100, jpeg/webp only.")
    p.add_argument("--moderation", default="auto", choices=["auto", "low"])
    p.add_argument("--output", default=None,
                   help="Output path. Default: image_<ts>_<i>.<ext> in cwd.")
    p.add_argument("--edit-image", action="append", default=[],
                   help="Path to input image. Repeat up to 16 to enter edit mode.")
    p.add_argument("--mask", default=None,
                   help="PNG mask (transparent = editable). Edit mode only.")
    p.add_argument("--input-fidelity", default=None, choices=["low", "high"],
                   help="Edit mode only. Higher preserves more of the source.")
    return p.parse_args()


def build_output_paths(args: argparse.Namespace) -> list[Path]:
    ext = args.output_format
    if args.output:
        base = Path(args.output).expanduser().resolve()
        if args.n == 1:
            return [base]
        stem, suffix = base.with_suffix(""), base.suffix or f".{ext}"
        return [Path(f"{stem}_{i+1}{suffix}") for i in range(args.n)]
    ts = int(time.time())
    return [Path.cwd() / f"image_{ts}_{i+1}.{ext}" for i in range(args.n)]


def post_json(url: str, api_key: str, payload: dict) -> dict:
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
    )
    return _send(req)


def post_multipart(url: str, api_key: str, fields: list[tuple[str, str]],
                   files: list[tuple[str, Path]]) -> dict:
    boundary = f"----imgen{uuid.uuid4().hex}"
    lines: list[bytes] = []
    for name, value in fields:
        lines.append(f"--{boundary}".encode())
        lines.append(f'Content-Disposition: form-data; name="{name}"'.encode())
        lines.append(b"")
        lines.append(str(value).encode("utf-8"))
    for name, path in files:
        ctype = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
        lines.append(f"--{boundary}".encode())
        lines.append(
            f'Content-Disposition: form-data; name="{name}"; filename="{path.name}"'.encode()
        )
        lines.append(f"Content-Type: {ctype}".encode())
        lines.append(b"")
        lines.append(path.read_bytes())
    lines.append(f"--{boundary}--".encode())
    lines.append(b"")
    body = b"\r\n".join(lines)

    req = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": f"multipart/form-data; boundary={boundary}",
        },
    )
    return _send(req)


def _send(req: urllib.request.Request) -> dict:
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT_SECONDS) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        die(f"HTTP {e.code} from OpenAI: {body}")
    except urllib.error.URLError as e:
        die(f"network error: {e.reason}")
    except TimeoutError:
        die(f"request timed out after {TIMEOUT_SECONDS}s")


def generate(args: argparse.Namespace, api_key: str) -> dict:
    payload: dict = {
        "model": args.model,
        "prompt": args.prompt,
        "n": args.n,
        "size": args.size,
        "quality": args.quality,
        "output_format": args.output_format,
        "background": args.background,
        "moderation": args.moderation,
    }
    if args.compression is not None:
        payload["output_compression"] = args.compression
    return post_json(GENERATE_URL, api_key, payload)


def edit(args: argparse.Namespace, api_key: str) -> dict:
    images = [Path(p).expanduser().resolve() for p in args.edit_image]
    if len(images) > 16:
        die("max 16 --edit-image files.")
    for p in images:
        if not p.is_file():
            die(f"edit image not found: {p}")

    fields: list[tuple[str, str]] = [
        ("model", args.model),
        ("prompt", args.prompt),
        ("n", str(args.n)),
        ("size", args.size),
        ("quality", args.quality),
        ("output_format", args.output_format),
        ("background", args.background),
        ("moderation", args.moderation),
    ]
    if args.compression is not None:
        fields.append(("output_compression", str(args.compression)))
    if args.input_fidelity:
        fields.append(("input_fidelity", args.input_fidelity))

    files: list[tuple[str, Path]] = [("image[]" if len(images) > 1 else "image", p)
                                     for p in images]
    if args.mask:
        mask_path = Path(args.mask).expanduser().resolve()
        if not mask_path.is_file():
            die(f"mask not found: {mask_path}")
        files.append(("mask", mask_path))

    return post_multipart(EDIT_URL, api_key, fields, files)


def save_results(response: dict, out_paths: list[Path]) -> list[Path]:
    data = response.get("data") or []
    if not data:
        die(f"no images returned. raw response: {json.dumps(response)[:400]}")
    if len(data) != len(out_paths):
        out_paths = out_paths[: len(data)]

    written: list[Path] = []
    for item, path in zip(data, out_paths):
        b64 = item.get("b64_json")
        if not b64:
            die(f"response missing b64_json: {json.dumps(item)[:200]}")
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(base64.b64decode(b64))
        written.append(path)
    return written


def main() -> None:
    args = parse_args()
    if not (1 <= args.n <= 10):
        die("--n must be between 1 and 10.")
    if args.background == "transparent" and args.output_format == "jpeg":
        die("transparent background requires png or webp output.")

    api_key = require_api_key()
    out_paths = build_output_paths(args)

    if args.edit_image:
        response = edit(args, api_key)
    else:
        if args.mask or args.input_fidelity:
            die("--mask and --input-fidelity require --edit-image.")
        response = generate(args, api_key)

    written = save_results(response, out_paths)
    for p in written:
        print(p)


if __name__ == "__main__":
    main()
