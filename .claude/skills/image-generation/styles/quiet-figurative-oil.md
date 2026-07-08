---
name: quiet-figurative-oil
aliases: [02ui-style, hopper-oil, painterly-blog-hero, quiet-oil, figurative-oil-metaphor]
trigger_keywords:
  - quiet oil painting
  - figurative oil painting
  - painterly blog hero
  - the 02ui look
  - 02ui style
  - hopper style
  - hopper light
  - impasto blog image
  - oil painting hero image
  - quiet surreal painting
  - contemplative painting
  - one red accent
inspired_by:
  - 02ui.com blog hero images (Murat Bayral / Can Hoskan's design blog)
  - Edward Hopper (directional light, geometric shadow planes, solitude)
  - Fairfield Porter (loose garden/domestic scenes, warm-cool paint handling)
  - Euan Uglow and Wayne Thiebaud (still-life planes, deadpan objects)
  - René Magritte (one quiet surreal element, played completely straight)
  - Alex Katz (flattened space, simplified faces)
---

# Quiet figurative oil style

The look of the blog hero images on 02ui.com: contemporary figurative oil paintings that work as understated visual metaphors for an article's topic. Each image is a calm, painterly scene that would hang comfortably in a gallery, except one element is quietly wrong or symbolic, and that element carries the concept.

When the user references this aesthetic, "the 02ui look", a Hopper vibe, a painterly/oil blog hero, or any of the trigger keywords above, inject the reusable prompt fragment below and then design the scene around a single metaphor for the subject.

## Visual DNA

- **Contemporary figurative oil painting.** Visible impasto and dry-brush strokes, canvas/linen weave showing through, blocky confident paint handling, soft unresolved edges, no outlines. Reads as physical paint, never as digital airbrush.
- **Muted mid-century palette.** Teal / slate / petrol blue, dusty cream and butter yellow, sage and olive green, warm putty beige, muddy brown. Low-to-medium saturation across the whole canvas.
- **Exactly one small saturated orange-red accent object.** This is the signature. Every image has a single vermilion item and nothing else saturated: a marker, a mug, a teapot, a bucket, a chess pawn, a hat, a pair of glasses, a floating brain. Small, deliberate, and placed off-center.
- **Hopper light.** Strong directional late-afternoon sunlight casting large hard-edged geometric shadow shapes that slice the composition diagonally into warm and cool planes. The shadow shapes are compositional elements in their own right.
- **One understated surreal element.** A robot sitting on the sofa, a fish among the breakfast fruit, a mummy-like statue watching a garden tea party, a chessboard hovering over a city skyline. Exactly one, played deadpan, never explained. Magritte's idea in Hopper's paint.
- **Anonymous figures.** People are seen from behind, in profile, or with simplified/blurred faces. Never a rendered portrait likeness, never eye contact with the viewer.
- **Quiet, contemplative, slightly melancholic mood.** Stillness. Nothing is happening; something has just happened or is about to.
- **Flattened, simplified space.** Big planes, generous negative space, horizon bands, restrained detail. A scene reduced to 5-10 shapes.
- **No text, no labels, no UI.** Even for tech topics, the metaphor is always analog: chess, tea parties, still lifes, park benches, cats in snow.

## What it is NOT

- Flat vector or editorial-illustration style (that's `magazine-editorial`; this one has real brushwork and rendered light)
- Photo-realistic or 3D rendered
- Digital-smooth "AI art" gradients or fantasy lighting
- Cartoon, anime, caricature
- Busy multi-event scenes; more than one surreal element
- Saturated all over; the palette stays muddy except the one accent

## Reusable prompt fragment

Append this (or weave it in) when the style applies:

> Contemporary figurative oil painting with visible impasto brushwork and canvas texture, blocky confident strokes, soft unresolved edges, no outlines. Muted mid-century palette of teal and slate blue, dusty cream and butter yellow, sage and olive green, warm putty beige. Exactly one small saturated orange-red accent object in the scene. Strong directional late-afternoon sunlight casting large hard-edged geometric shadow planes diagonally across the composition. Quiet, contemplative, slightly melancholic mood. Figures, if any, seen from behind or with simplified indistinct faces. Flattened simplified space with generous negative space. No text, no labels. In the spirit of Edward Hopper's light and Fairfield Porter's paint handling.

Then add: (1) the scene, (2) the single surreal/symbolic element that carries the concept, (3) what the orange-red accent object is.

## How the metaphor works (observed examples)

The source images pair each article topic with one deadpan symbolic scene. Use this table as a template for inventing new ones:

| Article topic | Painted scene | Surreal/symbolic element | Orange-red accent |
|---|---|---|---|
| Writing AI prompts | Figure hunched over a desk, writing | (none needed; the act itself) | Marker on the desk |
| Second brain / AI memory | Man and a robot side by side on an armchair, Hopper interior | Pink brain floating above the robot's head | The floating brain |
| Design system audit | Breakfast still life: banana, coffee, fruit plate | A blue-grey fish lying among the breakfast items (the inconsistency you're auditing for) | Orange on the plate |
| Agentic-ready websites | Garden tea party, three people at a white-clothed table | A pale humanoid statue standing at the garden wall, waiting to be invited (the agent as guest) | Teapot on the table |
| Designer ships a product in a weekend | Two black cats on a snowy field at the edge of a big shadow | Cats as small explorers at the edge of unknown territory | Bucket in the snow |
| Claude vs Lovable head-to-head | Two people working on laptops at the same table, moody interior | The pairing itself | Mug in the foreground |
| Model version comparison (4.7 vs 4.6) | City skyline with sky above | A giant chessboard hovering as a middle band over the city, one pawn advanced | The pawn |
| Storytelling / pitch clarity | Man alone on a park bench, seen from behind, city in the distance | Cloud-shadow shapes pooling on the ground around him | His hat |
| DESIGN.md / taste as a spec | Close-up profile of a man in headphones gazing out a window | Houseplant fronds sprouting behind his head like an idea | His glasses frames |

Pattern: pick a calm, ordinary, analog scene; embed exactly one element that encodes the concept; make the accent object either that element or a nearby prop.

## Recommended flags

- `--size 1232x928` for the native 4:3 landscape of the source images (both dimensions divisible by 16)
- `--size 1536x1024` for wider banner crops
- `--quality high`; the impasto texture and canvas weave need it
- `--format png` or `jpeg`; texture survives jpeg fine at default compression

## Tips

- **Design the metaphor first, the scene second.** Ask "what is the one quiet visual pun for this topic?" before describing any paint.
- **One surreal element, maximum.** Two makes it whimsical; this style is deadpan.
- **Name the accent object explicitly** ("a single vermilion teapot") or the model will scatter warm tones everywhere.
- **Describe the shadow as a shape**, e.g. "a large hard-edged triangular shadow crossing the wall diagonally". The geometric shadow is half the Hopper feel.
- **Keep faces away from the camera.** "Seen from behind" or "face turned away, features indistinct" avoids both uncanny portraits and the stock-photo look.
- **Say "muddy" and "muted" more than feels necessary.** gpt-image-2 drifts toward saturation; the palette should look like it was mixed with a little raw umber in everything.
