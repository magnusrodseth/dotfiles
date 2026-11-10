# Library: royalty-free assets

What a film can pull in from outside, with license rules enforced by `scripts/fetch.mjs`. Catalogs live in
`library/*.json` (researched and URL-verified on 10.11.2026). Nothing binary is stored in this repo: files are downloaded
on demand to `~/.cache/motion-graphics` and copied into the film project, and every download is written to the
project's `credits.json` and `CREDITS.md`. **Ship CREDITS.md with the film and publish its credit lines.**

## License rules (enforced)
- Allowed: CC0, public domain, CC BY (credit required, generated for you), and site licenses that allow commercial video use.
- Never: NC, ND or SA (share-alike would infect the film), personal-use-only.
- **YouTube Content ID:** Kevin MacLeod (Incompetech) and Scott Buckley register their tracks. They are hidden unless
  `--content-id`; if used, put the credit text in the video description. LinkedIn and Vimeo do not use Content ID.
- **Mixkit** bans TV/radio broadcast (web and social are fine): `music --broadcast` hides it.
- Public-domain classical recordings can still be fingerprinted against a label's recording; prefer CC0 for YouTube.
- Moods, genres and energy come from source tags, not listening. Audition before committing; measure BPM with `beats.py`.

## Music: 82 tracks (35 CC0-1.0, 21 Mixkit, 10 CC-BY-4.0, 8 CC-BY-3.0, 8 PD)
```bash
node $S/fetch.mjs music --mood calm --energy 1-2        # filter by mood, genre, energy, license
node $S/fetch.mjs get holiznacc0-bubbles               # -> audio/music/, credited
uv run --with librosa --with numpy python $S/beats.py audio/music/holiznacc0-bubbles.mp3 > audio/beats.json
```
Genres include orchestral, folk, lofi hip-hop, hip-hop beat, synthwave, chiptune, ambient, solo piano, acoustic folk, techno, minimal electronic, quirky pop underscore, minimal electronic underscore, downtempo electronic. Moods: run `music` with no filter to see them.
Synthesized alternative with no license questions at all: `score.mjs` (10 genres x 6 moods).

## Sound effects: 135 sounds + 14 packs (~1,700 files)
```bash
node $S/fetch.mjs sfx --category whoosh                # categories below
node $S/fetch.mjs get fs-sfx-ui-button-click-253168
node $S/fetch.mjs packs && node $S/fetch.mjs pack kenney-interface-sounds   # 100 CC0 UI sounds -> audio/packs/
node $S/fetch.mjs search "door creak"                  # live Openverse search, CC0/CC BY only; get ov:<uuid>
```
Categories: camera-shutter, cash-coin, city-ambience, clock-tick, crowd-applause, ding-bell, drum-one-shot, error-alert, glitch-digital, heartbeat, impact-hit-boom, keyboard-typing, magic-sparkle, mouse-click, nature-birds, notification-chime, office-ambience, paper-page-turn, pop-bubble, riser-build-up, sci-fi-beep, scratch-record, sub-drop, success-confirm, swipe, swoosh-transition, toggle-switch, ui-click, ui-tap-soft, water-rain-ambience, whoosh, wind.
Packs: Kenney (Interface, UI, Impact, Digital, Casino, RPG, Sci-fi, Music Jingles; CC0), OpenGameArt CC0 collections
(512 retro, 100 CC0 SFX v1/v2 incl. ambience loops, 50 retro synth), Little Robot UI library (CC BY 3.0).
Recorded sounds go in the same `cues.json` as synthesized ones: `{ "t": 3.0, "file": "audio/packs/.../click_001.ogg" }`.

## Fonts: 36 Google Fonts families (OFL), all with æ ø å
```bash
node $S/fetch.mjs fonts --role display                 # roles: display sans/grotesk, variable fun axes, display serif, condensed, script/handwritten, rounded/friendly, mono
node $S/fetch.mjs font fraunces --weights 400,700      # -> assets/fonts/, prints the FontFace() line
```
Static TTFs report odd internal names, so always set family and weight in `FontFace`. Variable fonts: use the
google/fonts raw TTF (see `library/visual.json` fonts notes). Color fonts (Honk, Nabla) ignore fillStyle.

## Icons, illustrations, emoji
```bash
node $S/fetch.mjs icon lucide:rocket ph:house-duotone tabler:chart-bar --color "#090C33"   # any Iconify set, license checked
```
Defaults: Lucide (ISC) outline, Phosphor (MIT, 6 weights incl. duotone), Tabler (MIT). Remix Icon changed to a custom
license in 01.2026 (no logo use, no icon packs). Illustrations: Open Peeps, Humaaans, Open Doodles (CC0);
DiceBear `notionists`/`lorelei`/`open-peeps` avatars (CC0, deterministic by seed). **unDraw forbids scraping:** download
by hand only. Emoji: Fluent Emoji (MIT), Twemoji (CC BY), Noto (Apache; animated Noto is CC BY). OpenMoji is BY-SA: excluded.

## Photos, B-roll, textures, maps
- Pexels (photos + video, free API key, 200 req/h), Unsplash (key), Pixabay (key; no recognisable brands in commercial
  use), Mixkit video (direct mp4, check per-clip license), Coverr. Raw files may not be committed anywhere public.
- Textures: Poly Haven and ambientCG (CC0, API, send a User-Agent). Generated textures in `lib/backgrounds.js` need no license.
- Maps: world-atlas TopoJSON (ISC), Natural Earth (PD), Norwegian counties/municipalities from Kartverket data
  (CC BY 4.0, credit "© Kartverket"; WMS tiles are not covered).
- Device frames: draw them (`lib/ui.js`), no trade-dress risk.
- Lottie: lottie-web with `anim.goToAndStop(t * anim.frameRate, true)` is deterministic; avoid files with random expressions.

Details, per-source terms and verified URL patterns: `library/visual.json`, `library/music.json` (`sources`), `library/sfx.json` (`sources`).
