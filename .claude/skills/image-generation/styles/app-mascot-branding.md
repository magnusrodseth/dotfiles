---
name: app-mascot-branding
aliases: [app-branding, app-logo, app-icon, mascot, app-mascot, brand-character, maskot]
trigger_keywords:
  - app branding
  - app logo
  - app icon
  - app mascot
  - mascot logo
  - brand character
  - maskot
  - app-ikon
  - logo for my app
  - icon for my app
  - mascot for my app
  - empty state illustration
  - loading screen character
  - duolingo style mascot
  - subscriptionmonster style
inspired_by:
  - Chris Raroque's App Branding Masterclass (vault note "App Branding Masterclass - Chris Raroque")
  - Duolingo's Duo owl and character-first app brands
  - SubscriptionMonster's helpful-monster mascot
  - Indie iOS app icon culture (friendly character over abstract glyph)
---

# App-mascot branding style

Character-first app branding: one friendly mascot that becomes the app's face
across the icon, logo, empty states, loading screens, and onboarding. The core
idea (from Chris Raroque's masterclass, saved in the vault) is that people
attach to a character far more easily than to an abstract mark, and seeing the
same character everywhere in the app builds emotional association with the
product.

This preset covers two things: the **look** of the mascot itself, and the
**iteration workflow** that keeps it consistent across dozens of variations.
The workflow matters as much as the aesthetic; without it, AI-generated
mascots drift off-model within a few generations.

## Use it for

- **App icons** (the most common case): mascot head or bust as a full-bleed
  square icon.
- **Logos and wordmark companions**: mascot on transparent background.
- **In-app states**: empty states, loading screens, error screens, onboarding,
  success/celebration moments. Each is the same mascot in a new pose or prop.
- **Marketing**: App Store screenshots, landing page hero, social cards.

## Visual DNA

- **One character, one silhouette.** A single friendly mascot with a bold,
  instantly readable outline. If the silhouette is not recognizable at 64
  pixels, simplify.
- **Simple rounded shapes**, soft geometry, no sharp aggressive angles.
- **Large expressive eyes** carrying most of the personality. Expression is
  the variable across variations; anatomy stays fixed.
- **Flat colors with soft cel shading**: 2-4 body colors plus one accent,
  subtle highlights, no painterly rendering, no heavy gradients.
- **Thick smooth outlines** (sticker-like) that keep the character crisp on
  any background.
- **Personality embodies the product.** Name the trait in the prompt: a calm
  owl for a sleep app, a helpful monster for scary finances, an eager dog for
  a habit tracker. SubscriptionMonster worked because business finances feel
  like a monster, so the mascot is the monster made friendly.
- **No text in the image.** Wordmarks are set in real type later, never
  generated.

## What it is NOT

- Corporate Memphis / flat corporate humans with tiny heads
- Photo-realistic or painterly rendering
- Detailed anime or comic book style
- Busy multi-character scenes
- Abstract geometric logo marks (if the user wants a glyph-style logo, that is
  a different preset)
- Baked-in rounded corners or squircle masks on icons (the OS applies those)

## Reusable prompt fragment

For the mascot itself (logo, stickers, in-app states):

> Friendly app mascot character in a modern flat-vector sticker style: simple
> rounded shapes, bold clean silhouette, large expressive eyes, thick smooth
> outlines, flat colors with soft cel shading and subtle highlights. One
> character only, centered, full body visible. Crisp edges that stay readable
> at small sizes. No text, no watermark, no background scene.

For the app-icon rendering, add:

> Rendered as a full-bleed square app icon: the mascot's head and shoulders
> fill most of the frame, bold saturated solid background color with a very
> subtle radial gradient, centered composition, square canvas with no rounded
> corners (the OS applies the icon mask). No text.

Then add the character specifics: species/creature, personality trait, palette
tied to the brand color, and the pose or prop for the specific variation.

## The iteration workflow (this is the important part)

The masterclass's biggest lesson: asking for many changes at once destroys the
art style. The fix maps directly onto this skill's edit mode.

1. **Create or obtain a base mascot.** Hand-drawn art as a starting point
   makes the result far more unique than a cold text-to-image start. If
   starting from text, generate until one output feels right, then promote it
   to the canonical base.
2. **Save the canonical base** as e.g. `mascot-base.png` in the project. All
   future work derives from this file.
3. **Iterate with edit mode, one change per prompt:**

   ```bash
   ~/.claude/skills/image-generation/scripts/generate.py \
     "Change only the belly color to warm cream. Keep everything else identical." \
     --edit-image mascot-base.png --input-fidelity high \
     --background transparent --format png --quality high
   ```

   One modification per run. Never bundle "swap the animal, change the colors,
   add a hat" into one prompt.
4. **Always branch from the base, not from drifted outputs.** When a variation
   goes off-model, throw it away and re-run from `mascot-base.png` instead of
   trying to correct the bad output. (This is the CLI equivalent of "start a
   new chat".)
5. **When the base is final, fan out variations** for app states, still via
   edit mode from the base: holding a magnifying glass (empty search), asleep
   (no notifications), typing on a laptop (loading), celebrating with confetti
   (success), and the icon rendering.
6. **Be patient.** Landing the right mascot can take a very large number of
   generations. That is normal, not failure.

## Recommended flags

- `--size 1024x1024 --quality high` for icons and base mascot work
- `--background transparent --format png` for logo/sticker/in-app assets
- `--edit-image mascot-base.png --input-fidelity high` for every variation
  once a base exists; high input fidelity is what preserves the art style
- `--n 4` on early exploratory runs to get options cheaply, then `--n 1` for
  refinement

## Starter prompt templates

No proven prompts yet; these are starting templates in the style's voice.
Replace them with real winners as they emerge.

### Base mascot (text-to-image, exploration)

```
Friendly app mascot character in a modern flat-vector sticker style: a small
round monster with soft teal fur, simple rounded shapes, bold clean
silhouette, large expressive eyes with a helpful, reassuring expression, tiny
stubby arms, thick smooth outlines, flat colors with soft cel shading and
subtle highlights. Personality: a gentle guardian who tames scary paperwork.
One character only, centered, full body visible, standing facing the viewer.
Plain transparent background. Crisp edges readable at small sizes. No text,
no watermark, no background scene.
```

### App icon rendering (edit mode from base)

```
Render this exact character as a full-bleed square app icon: head and
shoulders fill most of the frame, looking slightly up and to the right with a
confident smile. Bold saturated deep-teal background with a very subtle
radial gradient, centered composition, square canvas, no rounded corners.
Keep the character's colors, proportions and art style exactly as in the
input image. No text.
```

### Empty-state variation (edit mode from base)

```
Same character, same art style, same colors and proportions as the input
image. Change only the pose: sitting on the floor holding an oversized
magnifying glass with both hands, looking through it with one curious
enlarged eye. Transparent background. No text.
```

## Tips

- **Test at target size.** Downscale icon candidates to 64x64 and squint. If
  the silhouette or expression dies, simplify the design, not the rendering.
- **Lead with personality.** "Helpful, reassuring monster" steers the output
  more than ten visual adjectives.
- **Keep a pose sheet.** Once 4-5 variations exist, a single reference grid
  image fed via `--edit-image` alongside the base helps hold the style on new
  poses.
- **The base image is the brand asset.** Version it in the project repo like
  code; regenerating it later from prompts alone will not reproduce it.
- **Mascot names feed app names.** The masterclass pattern: mascot personality
  first, then name pairings (mascot + descriptive word: SubscriptionMonster,
  LunaBudgeting). Brainstorm pairings in text before generating.
