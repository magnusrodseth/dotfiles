# Mode: explainer (concept, data, strategy, pitch deck, LinkedIn insight)

One argument, made in 4-6 beats, with type and data drawn in code. 15-45 s. Style default: `kinetic-swiss` (LinkedIn, decks) or `editorial-paper` (strategy, essays).

## Rules for this branch
- **One claim per bar pair.** Write the argument as 4-6 short sentences first; each becomes a shot. If a sentence needs a comma, it is two shots.
- **Data is drawn, not screenshotted.** Charts are code (bars growing on springs, lines drawing with `lineDash`, counters ticking on beats). Numbers must come from a named source in the brief; never invent a figure.
- **Deck use.** Render 16:9 at the deck's resolution, with a loopable last frame equal to the first if it sits on a slide. For the presentations repo, place the MP4 in the deck's public assets and play it muted with autoplay and loop.
- **LinkedIn use.** 1:1 or 4:5 (`--w 1080 --h 1350`), readable with sound off: every claim on screen, captions burned in if there is a voice.

## Brief template additions
```
## The argument (one sentence per shot)
1. <hook claim, surprising, 6 words max>
2. <context>
3. <evidence: number + source>
4. <turn>
5. <so what / CTA>
## Data
| Figure | Value | Source | Date |
```
