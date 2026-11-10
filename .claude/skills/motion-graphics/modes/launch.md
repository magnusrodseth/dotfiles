# Mode: launch (product, project or solution promo, demo showcase)

The brief is a story about one user problem and 3 features that answer it, told with real UI. 15-25 s.

## Assets (before the brief)
- **Real UI, privacy-safe.** Order of preference: Storybook stories with mock data (`node $S/shoot.mjs --storybook <url> name=<story-id> ...`), a local dev server with seeded data, the public website. Never a logged-in session with real customer data.
- **Per-format captures.** Desktop viewport (1440x900 @2x) for 16:9; phone viewport (`--w 430 --h 932`) of the same screens for 9:16. A desktop crop shrunk into a tall frame is unreadable.
- Prefer stories with a settled state. Play functions can leave hover tooltips or open dialogs in the shot: LOOK at every capture and re-shoot a cleaner state.
- Real logo SVG (make a dark-background variant from the brand's own dark-mode colors if needed) and the real font files into `assets/fonts`.
- Record source-pixel crops for each shot and click target (`[x, y, w, h]` in screenshot pixels).

## Brief template (docs/brief.md)
```
# Brief: <product> <film type>
Mode: launch. Brand: <brand>. Style: <style file>.
## The film in one line
<what the viewer understands or feels at the end>
## Audience and use
<who, where it plays>; language: <nb/en>; formats: 16:9 first, then 9:16.
## Look
<palette with roles, type, the one container, banned looks>
## Beat sheet (BPM, bar = 4 beats)
| Time | Section | Picture | On-screen text | Sound |
| 0:00-0:02 | intro | hook: the problem in a striking image | <5 words> | |
| ... | build | the problem grows; collapse into the logo | | riser |
| downbeat | drop | wipe; feature 1 in the container, cursor click | <headline> / <sub> | impact, click |
| +3 s | drop | container morphs: feature 2 | | whoosh, click |
| +3 s | drop | feature 3 | | |
| +3 s | drop | overview: all of it in one place | | |
| last 4 s | outro | container shrinks into the logo, lockup + CTA | <tagline> | thump, chime |
## Sound
<score flags>; SFX on beats; voice: none | VOICE.md
## Deliverables
```

## Patterns that work (learned on a real product launch film)
- Hook: big type rising word by word plus a line drawing that starts on frame 0, so the first second moves. Real UI fragments (category rows, badges) land in a constellation, then collapse into the logo on the build's last bar.
- Copy top-left, container below, identical in every format. Headline 7-9u Display, one sub line.
- Camera push-in toward each click target, zoom sized per shot so the card never climbs into the copy or out of the safe area. In portrait, pull the zoom origin toward the card centre.
- Every click, reveal and swap on a beat; wipes start one frame early so they read on the downbeat.
- Product claims on screen must be true of the product. Check each feature line against the code or docs.
