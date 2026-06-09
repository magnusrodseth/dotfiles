---
name: nordic-watercolor
aliases: [watercolor, nordic-watercolor, line-and-wash, storybook-watercolor, scandi-watercolor, akvarell]
trigger_keywords:
  - watercolor
  - watercolour
  - akvarell
  - line and wash
  - ink and watercolor
  - nordic watercolor
  - scandinavian watercolor
  - storybook illustration
  - soft painted illustration
  - watercolor concept / slide illustration
  - cozy painted illustration
  - friluftsliv illustration
inspired_by:
  - Traditional wet watercolor painting
  - Ink line-and-wash / picture-book illustration
  - Nordic / Norwegian friluftsliv brand illustration
---

# Nordic-watercolor style

Soft, hand-painted **line-and-wash** illustration: confident fine ink and
graphite linework drawn over traditional wet watercolor washes. Calm,
contemplative, a little wistful. Best understood as a *treatment* (how the
image is painted) rather than a subject — it applies just as well to an
abstract concept for a slide as to a landscape.

This is the look the user fell for on a Nordic brand's illustration set. The
brand used a star-headed mascot in front of fjords; that mascot and the
landscape setting are NOT part of this preset. What we keep is the **form**:
wet watercolor + ink linework + a soft limited palette + one warm accent.

When the user references this aesthetic, "watercolor", "line and wash",
"akvarell", a soft painted illustration, or any trigger keyword above, weave
the reusable prompt fragment below into the prompt, then add the subject on top.

## Use it for
- **Concept / metaphor visuals for slides** (the most common case) — an idea
  rendered as a single painted object or scene, not a landscape.
- Objects, characters, vignettes, gentle scenes.
- Landscapes too, but that is the rare case, not the default.

## Visual DNA
- **Line-and-wash, ink-forward by default.** Confident fine ink and graphite
  outlines define the forms and structure, drawn *over* the washes. This is the
  user's chosen default — without explicitly asking for visible ink linework,
  gpt-image-2 drifts into a pure soft wash that loses structure (see Tips).
- **Real wet watercolor underneath**: visible pigment pooling and blooms,
  granulation, darker edges where washes settle, and paper grain showing
  through. NOT digital-flat, gouache, or oil.
- **Limited, desaturated, harmonious palette** — one mood per image (e.g. soft
  slate blue + dusty lavender + warm grey), almost always with a **single warm
  golden-yellow accent** carrying the focal point or a glow.
- **Generous negative space**, clean off-white / paper background.
- **Soft diffuse light**; warm self-illuminated glows allowed.
- **Mood-forward** — name the register: calm, thoughtful, cozy, wistful, serene.

## What it is NOT
- Photo-real, 3D, anime/cartoon cel-shading, flat vector, heavy oil/impasto
- A precise technical diagram. The wash blurs fine structure — great for an
  *evocative* concept, weak for a legible labelled chart. For a clean diagram,
  reach for a different tool.
- The `magazine-editorial` preset (that one is flat color blocks + grain; this
  is wet pigment + visible ink linework).

## Reusable prompt fragment
Append this (or weave it in) when the style applies:

> Line-and-wash illustration: confident fine ink and graphite linework drawn
> over traditional watercolor washes. Real wet-on-wet watercolor underneath with
> visible pigment blooms, granulation and paper grain. Visible hand-drawn ink
> linework throughout defining the structure. Limited desaturated harmonious
> palette with a single warm golden accent. Soft diffuse light, generous
> negative space, clean off-white background. Calm, contemplative mood.
> No text, no labels.

Then add the subject, the mood word, the 3–5 colour palette, and any "no X"
exclusions. For a slide concept, lead with "a conceptual illustration (not a
landscape) of …".

## Recommended flags
- `--quality medium` — **default**. Preserves the watercolor grain and ink
  detail. Note: in some sandboxed/proxied networks `--quality high` renders
  exceed a ~70–90s response timeout and the connection is dropped (fails in
  curl too, not just the script). If `high` errors with a dropped connection,
  fall back to `medium`. From a normal shell `high` is fine.
- `--size 1280x720` for true 16:9 slide visuals (fast, safely under timeouts)
- `--size 1536x864` for a larger 16:9, `2048x1152` for higher-res 16:9
- `--size 1024x1024` for square inline use
- `--format png` for slides (clean), `webp` for web, `jpeg` for banners

## Example prompts
### 1. Concept visual for a slide (the common case — "second brain")
```
Line-and-wash illustration, a conceptual presentation visual (not a landscape).
Confident fine ink and graphite linework over traditional watercolor washes.
Subject: a human head in left profile, its contour and features defined by clear
fine ink outlines and filled with soft washes. Inside the head, a clearly drawn
knowledge graph: small circular nodes outlined in ink, connected by thin ink line
edges, a "second brain". The nodes glow warm golden-yellow; the rest is a
desaturated palette of soft slate blue, dusty lavender and warm grey. Wet-on-wet
washes with visible blooms, granulation and paper grain beneath the ink lines.
Generous negative space, clean off-white background. Calm, thoughtful mood.
No text, no labels.
```

### 2. Object / metaphor vignette
```
Line-and-wash watercolor illustration of [single object/metaphor], drawn with
confident fine ink outlines over soft wet washes, visible pigment blooms and
paper grain. Limited palette of [3–5 muted colours] with one warm golden accent.
Generous negative space on a clean off-white background. [Mood word]. No text.
```

### 3. Gentle scene (rarer — and the landscape case)
```
Line-and-wash watercolor, wide 16:9. [Scene], with ink linework defining the
forms over soft wet washes, granulated sky, visible paper grain. Limited
[palette] with one warm golden accent. Atmospheric depth with layered misty
ridges, generous negative space. Calm, wistful mood. No text.
```

## Tips
- **Always say "visible ink/graphite linework over the washes".** This is the
  single most important phrase. Drop it and the model produces a pure soft wash
  that loses all structure — proven during the demo that built this preset.
- **Name "wet watercolor" and "paper grain" explicitly**, or it drifts toward
  clean digital flat.
- **Commit to one palette per image.** Name 3–5 colours plus the warm accent.
- **Lead with the mood word** (calm, thoughtful, cozy, wistful) — it does real
  work.
- **For slide concepts, prefer one clear central object/metaphor** over a busy
  scene, and say "(not a landscape)" so it doesn't default to scenery.
- **The wash blurs detail.** If a concept needs legible structure, draw it as
  ink shapes ("small circles connected by ink lines") rather than relying on the
  wash to define it.
