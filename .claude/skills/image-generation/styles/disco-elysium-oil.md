---
name: disco-elysium-oil
aliases: [disco-elysium, disco-alysium, revachol, rostov-portrait, thought-cabinet, painterly-rpg-portrait, gritty-oil-sketch]
trigger_keywords:
  - disco elysium
  - disco elysium style
  - disco elysium art
  - disco alysium
  - revachol
  - thought cabinet
  - rostov style
  - aleksander rostov
  - painterly rpg portrait
  - gritty painted portrait
  - ugly-beautiful portrait
  - oil sketch portrait
  - loose brushstroke portrait
  - painterly character portrait
  - post-industrial painted cityscape
inspired_by:
  - Aleksander Rostov, art director of Disco Elysium (ZA/UM), and the game's character portraits
  - Disco Elysium environment and key art (Revachol, Martinaise, the Whirling-in-Rags)
  - Russian and Baltic realist / plein-air oil painting, the adjacent tradition the look sits in (Repin's unflattering portrait heads, Levitan's skies)
  - Alla prima oil sketching: paint laid once, wet into wet, never blended smooth
  - Expressionist figure painting, where distortion and unattractive color serve character
---

# Disco Elysium oil style

Loose, unblended painterly oil work with the polish deliberately withheld. Faces
are built from chunky patches of unexpected color and left half-finished;
backgrounds are abstract color fields or vast dying skies. The register is
hungover, melancholic, grand and slightly ridiculous at once. Nothing is pretty,
everything is characterful.

The style has two modes that share one hand. Pick by subject:

- **Portrait mode** for a person, a face, a character, a headshot. This is the
  default when the user names a subject with a face.
- **Vista mode** for a place, a city, a landscape, a wide scene, key art.

When the user references Disco Elysium, Revachol, the thought cabinet, Rostov,
or any trigger keyword above, read this file, weave the matching prompt fragment
below into the prompt, then add the subject on top.

## Visual DNA (shared by both modes)

- **Alla prima oil, brushstrokes never blended away.** Every mark stays legible:
  chisel-edged strokes, dry-brush chatter, palette-knife slabs, canvas tooth
  showing through. It must read as paint pushed around once, not as a rendered
  surface.
- **Form built from flat planes of color, not gradients.** A cheek is four or
  five distinct patches meeting at hard edges. Values step, they do not ramp.
- **Wrong-color realism.** Skin carries olive green, lilac, grey-blue, ochre and
  brick red side by side; a cheek can be green and still read as flesh. This is
  the single most identifiable trait and the first thing a generator drops.
- **Loose ink-like linework drawn over the paint.** Fast scratchy strokes for
  hair strands, spectacle frames, collar edges, wrinkles, teeth. Drawn on top,
  clearly after the fact, sometimes missing the form slightly.
- **Unresolved edges.** The silhouette dissolves into the background in at least
  one place. Hair, shoulders and hands are allowed to go unfinished.
- **Limited palette, high complementary tension.** Four to six colors per image,
  usually a warm/cool clash: burnt orange against teal, mustard against slate,
  olive-lime against violet, cream against near-black brown.
- **Melancholy, exhaustion, faded grandeur.** Post-war, post-industrial,
  mid-century-Eastern-Europe-adjacent. Wet asphalt, bad tailoring, cheap
  cigarettes, a beautiful sky over a broken city.
- **No cleanup pass.** No smooth shading, no glossy highlights, no rim-light
  polish, no symmetry correction.

## Portrait mode

- **Deliberately unflattering.** Sagging eyelids, broken capillaries, stubble,
  crooked teeth, a bulbous or crooked nose, thinning hair, jowls, sweat. Aged,
  hungover, mid-thought, caught between expressions. Never handsome, never
  neutral, never a stock headshot.
- **Tight crop, head and shoulders**, three-quarter or downward tilt, head
  slightly off-center, cropped hard at the frame edge. Portrait aspect.
- **The background is not a place.** It is flat blocks and diagonal slashes of
  saturated color: mustard, crimson, teal, cream. Sometimes a single pale oval
  or halo of light directly behind the head. It describes mood, not space.
- **Backlight or halo separating the head** from a dark surround, or the reverse:
  a bright field with the figure as a dark mass.
- **Eye contact is optional and usually sidelong.** Looking down, looking past
  the viewer, one eye in shadow.

## Vista mode

- **The sky does the work.** Two thirds of the frame can be gestural cloud:
  towering cumulus in burnt orange, cream and sea-green, slashed through with
  diagonal knife strokes. Sunset, dusk, or overcast dawn.
- **Architecture implied, never drawn.** A city is small blocky strokes; windows
  are single dabs of warm light. Detail collapses into stroke with distance.
- **Near-black foreground masses.** Dark water, dark quay, dark rooftops
  anchoring the bottom of the frame against the glowing sky.
- **Post-industrial coastal decay.** Harbor, cranes, concrete blocks, tenements,
  a lone statue or spire, boats, snow or wet ground.
- **Human figures tiny or absent.** Scale belongs to the city and the weather.

## What it is NOT

- Clean digital painting, smooth airbrush, or concept-art gloss
- Photorealism, 3D render, or a photo with a paint filter
- Anime, cartoon, caricature, comic-book inking
- Flat vector or editorial illustration (that is `magazine-editorial`)
- The calm Hopper stillness of `quiet-figurative-oil`: this one is messier,
  uglier, more saturated and more emotional
- Watercolor (`nordic-watercolor` is wet pigment and paper bloom; this is opaque
  oil laid thick)
- Flattering. If the face looks good, the style has failed.

## Reusable prompt fragment, portrait mode

> Loose alla prima oil painting in the style of Disco Elysium character
> portraits: thick unblended brushstrokes and palette-knife marks left fully
> visible, canvas texture showing through, the face built from chunky flat
> planes of color meeting at hard edges rather than smooth gradients. Skin
> painted in unexpected hues, olive green, lilac, grey-blue and brick red sitting
> side by side. Scratchy loose ink-like linework drawn over the paint for hair,
> wrinkles and edges. Deliberately unflattering and characterful: tired,
> weathered, caught mid-expression, imperfect features. Tight three-quarter head
> and shoulders crop, slightly off-center. Abstract background of flat blocks and
> diagonal slashes of saturated color, not a real place. Limited palette of
> [4 colors] with strong warm-cool contrast. Unresolved dissolving edges where
> the figure meets the background. Melancholic, hungover, faded-grandeur mood.
> No smooth shading, no glossy polish, no photorealism, no text.

Then add: who the person is, their expression and state, the four colors, and
what the background field does (halo, diagonal slashes, dark surround).

## Reusable prompt fragment, vista mode

> Wide painterly oil sketch in the style of Disco Elysium environment art: thick
> gestural brushwork and palette-knife slashes, forms suggested rather than
> drawn, canvas texture visible throughout. A vast dramatic sky filling the upper
> two thirds in burnt orange, cream and sea-green cloud masses, cut through with
> diagonal knife strokes. Below it a post-industrial coastal city painted in
> small blocky strokes, windows reduced to single dabs of warm light,
> architecture implied never detailed. Near-black foreground masses of water and
> quay anchoring the bottom of the frame. Limited palette of ochre, burnt orange,
> teal, slate blue and near-black brown. Melancholic faded grandeur, decaying
> mid-century industrial city. No smooth digital rendering, no photorealism,
> no text.

Then add: the specific place, the weather and hour, and one silhouette that owns
the skyline (a spire, a crane, a statue, a chimney).

## Recommended flags

- Portrait: `--size 928x1232` (roughly 3:4, both divisible by 16), or
  `--size 1104x1536` for a taller crop
- Vista: `--size 1536x864`, `--size 2048x1152`, or `--size 3840x2160` for the
  full-width key-art look
- `--quality high`. The whole style is texture; `medium` sands the strokes off.
- `--format png` to keep the brush edges crisp

## Turning a photo into a portrait

Edit mode works well here, and is the most common use.

```bash
~/.claude/skills/image-generation/scripts/generate.py \
  "<portrait fragment above, plus: keep the pose, framing and likeness of the source photo>" \
  --edit-image ./photo.jpg --size 928x1232 --quality high
```

Say explicitly what to keep (pose, framing, likeness, clothing) and what to
replace (rendering, background, palette). Without that, the model repaints the
composition too.

## Tips

- **Name the wrong colors on the skin.** "Olive green, lilac and grey-blue
  patches in the flesh" is what separates this from generic digital painting.
  Omit it and you get clean concept art with visible brushstrokes.
- **Ask for the flaws by name.** Say sagging eyelids, broken capillaries,
  stubble, crooked teeth. "Weathered" alone is too polite and the model still
  renders someone attractive.
- **Say "unblended" and "planes, not gradients" more than feels necessary.**
  gpt-image-2 smooths surfaces unless repeatedly told not to.
- **Insist the background is abstract.** Otherwise it invents a room. The phrase
  "flat blocks and diagonal slashes of color, not a real place" does the job.
- **Ask for one unresolved edge.** "Let the shoulder dissolve into the
  background" buys most of the hand-painted feel on its own.
- **Cap the palette out loud.** Four named colors beats "colorful"; this style
  falls apart when every hue shows up.
- **The mood word matters.** Hungover, exhausted, defeated, quietly grandiose.
  It changes the face more than any adjective about paint.
