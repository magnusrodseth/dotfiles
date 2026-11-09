---
name: akira-neo-tokyo
aliases: [akira, neo-tokyo, otomo, akira-cel, akira-manga, 80s-anime-cyberpunk]
trigger_keywords:
  - akira
  - akira style
  - akira aesthetic
  - neo-tokyo
  - neo tokyo
  - otomo
  - katsuhiro otomo
  - kaneda bike
  - kaneda slide
  - 80s anime cyberpunk
  - 1988 anime
  - cel anime cyberpunk
  - retro anime cyberpunk
  - hand-painted anime cel
  - akira manga
inspired_by:
  - Akira (1988), directed by Katsuhiro Otomo, colour design by Toshiharu Mizutani
  - Otomo's Akira manga (1982-1990), dense black-and-white ink and screentone
  - Hand-painted anime background art of the cel era (see Stefan Riekeles, Anime Architecture)
  - Japanese Metabolist megastructures and postwar Tokyo reconstruction
  - 1980s bosozoku biker subculture
---

# Akira Neo-Tokyo style

Late-1980s theatrical cel animation of a dystopian megacity at night. Inked,
flat-shaded figures sit over obsessively detailed hand-painted backgrounds. The
darkness is built from dozens of subtle dark tones, and light comes only from
isolated sources: headlight trails, lit windows, streetlamps, searchlights,
explosions. The register is urgent, gritty, adolescent and apocalyptic.

The style has two modes. Pick by request:

- **Film cel mode** (default). Full colour, night, the look of the 1988 film.
- **Manga ink mode** when the user says manga, black and white, ink, comic
  page, or screentone.

When the user references Akira, Neo-Tokyo, Otomo or any trigger keyword above,
read this file, weave the matching prompt fragment below into the prompt, then
add the subject on top.

## Do not name the source in the prompt

Do not write "Akira", "Otomo" or "Kaneda" into the prompt sent to the API.
Style references to a living artist and a copyrighted film can get refused,
and the model copies the iconic bike and jacket instead of the style. Describe
the traits below instead. The names exist in this file only as triggers.

## Visual DNA (shared by both modes)

- **Hand-made, pre-digital.** Every surface reads as paint on paper or ink on
  board. No CG gloss, no bloom filters, no airbrushed gradients.
- **Overwhelming urban density.** Slab skyscrapers, stacked elevated highways,
  Metabolist megastructures, thousands of tiny windows, cables, signage,
  construction cranes, rubble of an older city underneath.
- **Realistic, unglamorous figures.** Grounded proportions, small eyes, heavy
  jackets, scrappy teenagers and tired soldiers. Not moe, not chibi, not
  big-eyed modern anime.
- **Kinetic diagonals.** Low camera, strong perspective, speed lines, objects
  tearing across the frame. Even still scenes feel about to explode.
- **Catastrophe on the horizon.** Craters, a white dome of energy, ruins,
  searchlights, military hardware.

## Film cel mode

- **Two layers.** Crisp inked character outlines with flat two-tone cel
  shading, placed over a softer, highly detailed hand-painted poster-colour
  background. The difference between the two layers is the signature.
- **Crushed darkness made of colour.** Shadows are deep blues, slate greys,
  bruised browns and dark greens, never flat black.
- **Isolated light sources only.** A brick-red streaking tail-light trail,
  teal or cyan-white streetlamps, warm sodium amber, a few small neon signs.
  Light punctuates the dark; it never washes the frame evenly.
- **Red against teal.** The signature pair is warm brick red against cool
  teal. Magenta and purple turn it into generic synthwave.
- **Wet surfaces.** Rain-slick asphalt with long smeared reflections.
- **Film artefacts.** Fine grain, a little cel dust, slight colour shift of an
  old 35 mm print.

## Manga ink mode

- **Pure black ink on white**, with dense mechanical hatching and dot
  screentone for mid-tones.
- **Architectural precision.** Ruled perspective lines, every window drawn,
  rubble rendered stone by stone.
- **Explosions and motion as line.** Radiating speed lines, shockwave rings,
  debris drawn as hundreds of small shapes.
- **Optional single spot colour** (red) only if the user asks for a cover or
  poster feel.

## What it is NOT

- Synthwave or outrun: magenta-to-cyan gradients, sunsets, palm trees, grids
- Modern digital anime: glossy highlights, bloom, lens flares, big shiny eyes
- Photoreal cyberpunk (Blade Runner stills, Cyberpunk 2077 renders, 3D)
- Ghibli: soft pastels, pastoral calm, round friendly faces
- Daylight. The style collapses without darkness to punch light through.
- A rainbow of neon. Restraint and repetition of red and teal keep it coherent.

## Reusable prompt fragment, film cel mode

> Hand-painted 1988 theatrical anime cel animation still: crisp inked character
> outlines with flat two-tone cel shading, placed over a richly detailed
> hand-painted poster-colour background. Night in a dense dystopian megacity:
> towering slab skyscrapers and stacked elevated highways, thousands of tiny lit
> windows, rain-wet asphalt with long smeared reflections. Shadows built from
> many subtle dark blues, slate greys and bruised browns rather than flat black.
> Light from isolated sources only: a streaking brick-red tail-light trail, cool
> teal streetlamps, warm sodium amber, a few small scattered neon signs.
> Realistic, unglamorous character proportions with small eyes, not modern
> anime. Low dynamic camera angle with strong diagonal perspective. Fine film
> grain and slight cel dust, faded 35 mm print colour. Palette restricted to
> brick red, teal, near-black blue and sodium amber. No magenta, no purple
> synthwave gradients, no 3D render, no glossy digital anime shading, no bloom,
> no text.

Then add: the subject and action, where the light comes from, and one element
of catastrophe or scale on the horizon.

## Reusable prompt fragment, manga ink mode

> Black-and-white 1980s seinen manga panel drawn in black ink on white board:
> dense mechanical cross-hatching and dot screentone for mid-tones, ruled
> architectural perspective with every window and girder drawn, rubble rendered
> stone by stone. Dystopian megacity of slab towers and elevated highways.
> Realistic, gritty character proportions with small eyes. Motion and impact
> shown with radiating speed lines, shockwave rings and hundreds of small
> debris fragments. High contrast, heavy solid blacks. No colour, no grey
> gradients, no digital smoothness, no speech bubbles, no text.

Then add: the subject, the camera angle, and what is exploding or collapsing.

## Recommended flags

- Film still: `--size 1536x832` (about 1.85:1, the theatrical frame)
- Banner or header: `--size 3072x1024` (3:1) or `--size 2400x800`
- Manga page: `--size 1104x1536`; manga panel: `--size 1536x1024`
- `--quality high`. Background density is the style; `medium` loses it.
- `--format png`

## Tips

- **Name the light sources one by one.** "Neon city at night" gives an even
  pink-blue wash. List the trail, the streetlamps and two small signs.
- **Say "flat two-tone cel shading" and "hand-painted background" both.** The
  contrast between figure layer and background layer is what reads as 1988.
- **Ban magenta out loud.** Without it the model drifts to synthwave.
- **Ask for small eyes and realistic proportions.** Otherwise you get modern
  anime faces.
- **For banners, keep one side quiet.** Put the action on one third and let
  dark sky or wet road hold the rest, so a title can sit there.
- **For the iconic motorcycle shot, describe a generic futuristic red bike**
  sliding sideways, not the original design.
