---
name: image-generation
description: Generate and edit images via OpenAI's gpt-image-2 (ChatGPT Images 2.0) API. Use when the user asks to "generate an image", "create an image", "make a picture of X", "draw X", "edit this image", "remove the background from this image", "extend this image", "regenerate this image with Y", or invokes /image-generation. Outputs PNG/JPEG/WebP files to disk. Requires OPENAI_API_KEY in the environment.
---

# Image Generation (OpenAI gpt-image-2)

Generate images from text or edit existing images using OpenAI's `gpt-image-2` model (ChatGPT Images 2.0). Runs `scripts/generate.py` with no third-party Python dependencies.

## Prerequisite

`OPENAI_API_KEY` must be exported in the shell. The user keeps it in `~/dotfiles/zsh/ignored/` (auto-sourced). If unset, the script exits with a clear error. To verify:

```bash
[ -n "$OPENAI_API_KEY" ] && echo ok || echo "set OPENAI_API_KEY first"
```

## Quick start (text-to-image)

```bash
~/.claude/skills/image-generation/scripts/generate.py \
  "A minimalist watercolor of a fjord at dawn, soft blues" \
  --size 1024x1024 --quality high
```

Writes `image_<timestamp>_1.png` to the current directory and prints the absolute path. The user expects you to print the path so they can open it.

## Quick start (image edit)

```bash
~/.claude/skills/image-generation/scripts/generate.py \
  "Make the sky a vivid sunset" \
  --edit-image ./photo.png \
  --quality high
```

Multiple input images (up to 16) compose into a single output:

```bash
~/.claude/skills/image-generation/scripts/generate.py \
  "Combine these into a product hero shot" \
  --edit-image mug.png --edit-image background.png
```

## Workflow

1. **Flesh out the prompt.** Never pass the user's request verbatim. gpt-image-2 rewards specific, sensory prompts. Expand the brief into a richer prompt that names:
   - subject and pose/action
   - setting and time of day
   - art style or medium (photo, watercolor, 3D render, line art, etc.)
   - lighting, mood, palette
   - composition, framing, camera angle
   - level of detail and any "no X" exclusions

2. **Present the drafted prompt before executing.** Show the user the rewritten prompt and the planned flags (size, quality, n, edit images if any) and wait for confirmation. Format:

   ```
   Drafted prompt:
   > <full rewritten prompt>

   Flags: --size 1024x1024 --quality high --n 1
   Proceed? (or tell me what to tweak)
   ```

   If the user says "go" / "yes" / "ship it", run the script. If they tweak, redraft and re-confirm.

3. Confirm `OPENAI_API_KEY` is set. If not, tell the user to `export OPENAI_API_KEY=...` and stop.

4. Decide generate vs. edit based on the request. Edit needs at least one `--edit-image`. For edits, the prompt should describe the *change*, not redescribe the whole image.

5. Pick a sensible size and quality. Default `auto` for both is fine; pick `high` only if the user asks for high fidelity or print-quality output.

6. Run the script. If it exits non-zero, surface the error message verbatim (it includes the OpenAI error body).

7. Print the output path(s). Do not embed the image inline.

## Skipping the confirmation

If the user pre-approves with phrases like "just generate it", "go ahead", "no need to confirm", or "iterate until I say stop", skip step 2 for the rest of the session. Otherwise always confirm.

## Parameters

| Flag | Default | Values |
|------|---------|--------|
| positional `prompt` | (required) | up to 32,000 chars |
| `--model` | `gpt-image-2` | `gpt-image-2`, `gpt-image-1.5`, `gpt-image-1`, `gpt-image-1-mini` |
| `--size` | `auto` | `auto`, `1024x1024`, `1536x1024`, `1024x1536`, or any `WxH` where W and H are divisible by 16 and aspect ratio is between 1:3 and 3:1 (gpt-image-2 only, max 3840x2160) |
| `--quality` | `auto` | `auto`, `low`, `medium`, `high` |
| `--n` | `1` | `1`-`10` |
| `--format` | `png` | `png`, `jpeg`, `webp` |
| `--background` | `auto` | `auto`, `transparent`, `opaque` (transparent requires png/webp) |
| `--output` | `image_<ts>_<i>.<ext>` | output path; with `--n>1`, `_<i>` is appended before the extension |
| `--edit-image` | (none) | path to an input image; repeatable, max 16 |
| `--mask` | (none) | PNG mask file; transparent pixels mark editable regions (edit mode only) |
| `--input-fidelity` | `low` | `low`, `high` (edit mode only) |
| `--compression` | `100` | `0`-`100` (jpeg/webp only) |

## Notes

- gpt-image-2 returns base64; the script decodes and writes to disk for you.
- Latency: `high` quality can take 30 to 90 seconds. Mention this if the user is waiting.
- Cost varies by size and quality. The script does not estimate cost.
- For brand-safe or work content, keep `moderation` at default `auto`. The `--moderation low` flag exists for less restrictive filtering but is rarely needed.
- This skill does not view the resulting image. If the user wants to see it, suggest `open <path>` on macOS.
