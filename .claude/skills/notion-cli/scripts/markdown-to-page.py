#!/usr/bin/env python3
"""
markdown-to-page.py — publish a markdown file as a Notion page, optionally with image uploads.

Workflow:
  1. Strip YAML frontmatter and HTML comments from the source markdown.
  2. Optionally strip embedded `![](path) \n _caption_` image groups (default on).
  3. For each entry in --images-json, upload the local file via `ntn files create`.
  4. Create the Notion page with the cleaned markdown via `ntn pages create`.
  5. If --title or --properties-json given, PATCH the page properties.
  6. For each image, find the anchor block (by substring match against block plain_text),
     insert the image as a Notion image block (file_upload type) with --notion-version 2022-06-28,
     and optionally delete the anchor (used for the "insert at top" sentinel pattern).

Usage:
  markdown-to-page.py \
      --source article.md \
      --parent data-source:<id> \
      [--title "Title"] \
      [--status "Kladd"] \
      [--properties-json props.json] \
      [--images-json images.json] \
      [--keep-image-markdown]

images.json schema (array of objects):
  [
    {
      "path": "/abs/path/to/banner.jpeg",
      "content_type": "image/jpeg",
      "caption": "Caption text shown below image in Notion",
      "anchor": "__TOP__"                  // special: insert at very top via sentinel
    },
    {
      "path": "/abs/path/to/fig1.webp",
      "content_type": "image/webp",
      "caption": "Caption 2",
      "anchor": "Unique substring that appears in one block's plain_text"
    }
  ]

The `anchor` field's special value `__TOP__` triggers a sentinel-paragraph workaround:
the script prepends a unique alphanumeric paragraph to the markdown, finds that block,
inserts the image after it, then deletes the sentinel. See SKILL.md / REFERENCE.md
for the "Inserting blocks at the top" gotcha.

Auth: relies on NOTION_API_TOKEN. Falls back to NOTION_API_KEY if NOTION_API_TOKEN is unset.
"""

import argparse
import json
import os
import re
import subprocess
import sys

SENTINEL = "NTNCLISENTINELANKER"
TOP_MARKER = "__TOP__"


def clean_markdown(src: str, strip_images: bool = True) -> str:
    """Remove frontmatter, HTML comments, and (optionally) image+italic-caption groups."""
    src = re.sub(r"^---\n.*?\n---\n", "", src, count=1, flags=re.DOTALL)
    src = re.sub(r"<!--.*?-->\n?", "", src, flags=re.DOTALL)
    if strip_images:
        src = re.sub(r"!\[[^\]]*\]\([^)]*\)\n_[^\n]*_\n", "", src)
    src = re.sub(r"\n{3,}", "\n\n", src)
    return src.strip() + "\n"


def run(cmd: list, input_: str = None, check: bool = True) -> str:
    r = subprocess.run(cmd, input=input_, capture_output=True, text=True)
    if check and r.returncode != 0:
        sys.stderr.write(f"FAIL: {' '.join(cmd)}\nSTDERR: {r.stderr}\n")
        sys.exit(1)
    return r.stdout


def ensure_token() -> None:
    token = os.environ.get("NOTION_API_TOKEN") or os.environ.get("NOTION_API_KEY")
    if not token:
        sys.exit("error: NOTION_API_TOKEN (or NOTION_API_KEY) must be set")
    os.environ["NOTION_API_TOKEN"] = token


def upload_image(path: str, content_type: str) -> str:
    filename = os.path.basename(path)
    with open(path, "rb") as f:
        out = subprocess.run(
            ["ntn", "files", "create", "--filename", filename, "--content-type", content_type, "--json"],
            input=f.read(),
            capture_output=True,
        )
    if out.returncode != 0:
        sys.exit(f"upload failed for {path}: {out.stderr.decode()}")
    return json.loads(out.stdout)["id"]


def find_anchor_id(blocks: list, substr: str) -> str | None:
    for b in blocks:
        rich = b.get(b["type"], {}).get("rich_text", [])
        text = "".join(rt["plain_text"] for rt in rich)
        if substr in text:
            return b["id"]
    return None


def insert_image_block(page_id: str, anchor_id: str, upload_id: str, caption: str) -> None:
    image_block = {
        "object": "block",
        "type": "image",
        "image": {
            "type": "file_upload",
            "file_upload": {"id": upload_id},
            "caption": [{"type": "text", "text": {"content": caption}}],
        },
    }
    run([
        "ntn", "api", f"v1/blocks/{page_id}/children", "-X", "PATCH",
        "--notion-version", "2022-06-28",
        "children:=" + json.dumps([image_block]),
        "after=" + anchor_id,
    ])


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--source", required=True, help="Path to markdown file")
    p.add_argument("--parent", required=True, help="Parent (e.g. data-source:<id>)")
    p.add_argument("--title", help="Title to set on the page after creation")
    p.add_argument("--status", help="Status name (status property)")
    p.add_argument("--properties-json", help="Path to JSON file with additional properties payload")
    p.add_argument("--images-json", help="Path to JSON file describing images to upload and insert")
    p.add_argument("--keep-image-markdown", action="store_true",
                   help="Do not strip embedded ![](path) markdown image blocks from the source")
    args = p.parse_args()

    ensure_token()

    with open(args.source) as f:
        raw = f.read()
    md = clean_markdown(raw, strip_images=not args.keep_image_markdown)

    images = []
    if args.images_json:
        with open(args.images_json) as f:
            images = json.load(f)

    needs_top_sentinel = any(img.get("anchor") == TOP_MARKER for img in images)
    if needs_top_sentinel:
        md = SENTINEL + "\n\n" + md

    print(f"Cleaned markdown: {len(md)} chars; {len(images)} image(s) to insert", file=sys.stderr)

    # Upload each image (capture upload_id on the image dict)
    for img in images:
        img["upload_id"] = upload_image(img["path"], img["content_type"])
        print(f"Uploaded {img['path']} -> {img['upload_id']}", file=sys.stderr)

    # Create page
    out = run(
        ["ntn", "pages", "create", "--parent", args.parent, "--json"],
        input_=md,
    )
    page = json.loads(out)
    page_id = page["id"]
    page_url = page["url"]
    print(f"Created page: {page_url}", file=sys.stderr)

    # Set properties if requested
    props = {}
    if args.title:
        props["Name"] = {"title": [{"text": {"content": args.title}}]}
    if args.status:
        props["Status"] = {"status": {"name": args.status}}
    if args.properties_json:
        with open(args.properties_json) as f:
            props.update(json.load(f))
    if props:
        run([
            "ntn", "api", f"v1/pages/{page_id}", "-X", "PATCH",
            "properties:=" + json.dumps(props),
        ])
        print(f"Set properties: {list(props.keys())}", file=sys.stderr)

    if not images:
        print(page_url)
        return

    # Fetch block list once for anchor lookup
    blocks_out = run(["ntn", "api", f"v1/blocks/{page_id}/children"])
    blocks = json.loads(blocks_out)["results"]

    for img in images:
        anchor = img["anchor"]
        anchor_substr = SENTINEL if anchor == TOP_MARKER else anchor
        anchor_id = find_anchor_id(blocks, anchor_substr)
        if not anchor_id:
            sys.stderr.write(f"WARN: anchor not found for '{anchor_substr}' (caption: {img['caption'][:40]}...)\n")
            continue

        insert_image_block(page_id, anchor_id, img["upload_id"], img["caption"])
        print(f"Inserted image after {anchor_id}: {img['caption'][:40]}...", file=sys.stderr)

        if anchor == TOP_MARKER:
            run(["ntn", "api", f"v1/blocks/{anchor_id}", "-X", "DELETE"])
            print(f"Deleted sentinel block {anchor_id}", file=sys.stderr)

    print(page_url)


if __name__ == "__main__":
    main()
