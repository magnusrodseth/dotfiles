---
name: magazine-editorial
aliases: [editorial, op-ed, economist-style, nyt-opinion, atlantic-illustration, print-editorial, conceptual-illustration]
trigger_keywords:
  - editorial illustration
  - magazine style
  - the economist style
  - new york times opinion
  - nyt opinion illustration
  - the atlantic illustration
  - the new yorker illustration
  - op-ed illustration
  - print editorial
  - thoughtful magazine illustration
  - conceptual illustration
  - editorial mood
  - the aesthetic from post 35
inspired_by:
  - The Economist editorial illustrations
  - New York Times opinion section
  - The Atlantic feature illustrations
  - The New Yorker covers and inline art
  - Modern print-media editorial illustration (Christoph Niemann-adjacent, but flatter)
---

# Magazine-editorial style

The look the user fell in love with on the "Første dose er gratis" blog post (post 35 in `agentic-coding-blog`). Restrained, symbolic, single-concept-per-image illustrations in the visual language of high-end magazine opinion sections.

When the user references this aesthetic, "the post 35 look", an editorial/magazine vibe, or any of the trigger keywords above, inject the reusable prompt fragment below into the prompt you build.

## Visual DNA

- **Flat color blocks**, not painterly gradients or 3D rendering
- **Subtle paper grain texture** giving a slightly tactile, printed-page feel
- **Limited muted palette** (typically 3-5 colors total, low saturation, often warm neutrals plus one accent)
- **Restrained detail**, no fine line work, no rendered surface textures beyond the grain
- **Single central concept** per image, no busy multi-character scenes
- **Symbolic over literal**, prefer metaphor over depiction
- **No labels, no text inside the image**, captions in the article do that work
- **Generous negative space**, the composition breathes
- **Mood-forward**, prompts should name the emotional register (quietly ironic, contemplative, ominous-but-contained, melancholic, expansive)

## What it is NOT

- Photo-realistic
- 3D rendered
- Cartoon, anime, or comic book style
- Detailed pencil/watercolor with visible brushwork
- Vector logo style (too clean, no grain)
- Infographic with labels and arrows

## Reusable prompt fragment

Append this (or weave it in) when the style applies:

> Flat editorial illustration style with subtle paper grain texture, limited muted palette of 3-5 colors, restrained detail, no fine line work. Single central concept, symbolic rather than literal, generous negative space. No labels, no text, no captions inside the image. Magazine opinion-section feel, like The Economist or New York Times opinion illustrations.

Then add the mood/palette specifics for the individual image, plus the "no X" exclusions that fit the concept.

## Recommended flags

- `--size 1536x1024` for wide editorial / banner compositions
- `--size 1024x1024` for square inline illustrations
- `--quality high` for blog post / print-quality use
- `--format webp` for inline web images, `jpeg` for banners

## Proven prompts from post 35

These four prompts produced the images the user wanted to remember the style by. Use them as concrete templates when building new prompts in the same family.

### 1. Banner (single-subject metaphor with Norwegian text on signage)

```
Editorial illustration, side-on composition. Single subject: a vintage ice cream cart with a small chalkboard sign mounted on the front reading "FØRSTE GRATIS" in clean hand-lettered chalk. A single waffle cone with a soft serve scoop sits on top of the cart counter, slightly tilted. Empty quiet street setting, no people, no crowd, no queue, no price list. Limited muted palette: cream, dusty pink, soft brown, with one accent of warm yellow on the cart awning. Flat editorial illustration style with subtle paper grain texture, limited color blocks, restrained detail. Mood: quietly ironic, inviting but with a hint of caution. Wide 16:9 banner composition with generous negative space on one side.
```

### 2. Iceberg (visible-vs-hidden contrast, no figures)

```
Editorial illustration of an iceberg seen from the side, horizontal water surface across the middle of the image. The visible tip above water is tiny, almost insignificant, a small triangular sliver. Below water, the iceberg extends downward and outward into an immense dominant mass that fills most of the lower frame. Limited palette: pale blue-grey water, soft white-blue ice with subtle shadow gradations. No labels, no text, no boat, no figures. Flat editorial illustration style with subtle paper grain. Wide 16:9 composition.
```

### 3. Falling dominoes (mechanical inevitability, no labels)

```
Editorial illustration of a single line of dominoes in side profile, set up on a flat surface extending across the image with mild perspective receding to the right. The first dozen dominoes are falling in mid-cascade, frozen in motion. Further down the line most dominoes lie toppled flat. At the very far end one final domino still stands upright, slightly tilted, on the verge of falling. Soft directional lighting from the upper left. Limited palette: warm cream background, dominoes in a muted terracotta or rust tone. Flat editorial illustration style with subtle paper grain. No labels, no percentages, no text, no figures. Wide 16:9 composition.
```

### 4. Figure with ghost echoes (abstract concept, single human silhouette)

```
Editorial illustration of a single human figure in silhouette, seen from behind, standing at center frame and facing forward into open space. Three to four semi-transparent ghost versions of the same figure fan outward from the central figure, each stepping in a slightly different direction. The ghost figures decrease in opacity the further they extend from the central solid figure. The central figure is solid in a muted deep indigo; the ghost echoes are progressively more translucent in lighter shades of the same indigo. Open empty space around them, no setting, no environment, no objects. Warm off-white background. Flat editorial illustration style with subtle paper grain. No labels, no text. Wide 16:9 composition.
```

## Tips

- **Strip detail aggressively.** If you find yourself describing a scene with three characters doing three things, you have left the style. Cut to one concept.
- **Lead with the mood word.** "Quietly ironic", "contemplative", "ominous but contained", "expansive" do more work than visual specifics.
- **Specify "no X" liberally.** This style benefits from explicit exclusions: no labels, no text, no figures (if abstract), no environment (if studio-style).
- **Norwegian text on signs works** but only short phrases (1-3 words). Longer Norwegian renders unreliably.
- **The paper grain matters.** Without it, gpt-image-2 drifts toward sterile vector-flat. With it, the result feels printed.
