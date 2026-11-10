# Voice (opt-in only)

No voiceover unless the user asks for one. Films must work with sound off anyway: every claim is on screen.

## Generate
```bash
node $S/voice.mjs --lang no --text "Se opp i kveld. Melkeveien venter." --out audio/voice.mp3
node $S/voice.mjs --lang en --script docs/voice.json --out audio/voice.mp3   # [{ "id": "hook", "text": "..." }, ...]
node $S/voice.mjs --list-voices
```
Needs `ELEVENLABS_API_KEY` (env or `./.env`; on this machine it belongs in `~/dotfiles/zsh/ignored/`, sourced from 1Password with the `onepassword-cli` skill). Never paste the key into a prompt.

## Models and languages
| Model | Norwegian | English | Use |
|---|---|---|---|
| `eleven_v3` (default) | yes | yes | most natural, best for Norwegian; supports audio tags like `[warmly]` |
| `eleven_flash_v2_5` | yes | yes | fast drafts, request stitching across parts |
| `eleven_multilingual_v2` | **no** | yes | the API default; the script refuses `--lang no` with it |

Pick a voice that is native for the language: list voices and choose one labelled Norwegian for `no` (the default premade voice is English-native and sounds accented in Norwegian). Pass `--voice <id>` or set `ELEVENLABS_VOICE_ID`.

## Norwegian script rules
Write for the ear: short sentences, bokmål, numbers as words where they are read aloud ("ti tusen kroner"), abbreviations spelled as spoken ("tilstandsgrad tre", not "TG3"). Read every line aloud in your head for natural stress; avoid anglicisms.

## Sync
`voice.mjs` writes `<out>.words.json` (`[{ word, start, end }]`). Place the voice on the timeline with `mix.sh --voice audio/voice.mp3 --voice-delay <s>` (music ducks under it automatically), and time on-screen text to word starts. Picture still cuts on the beat grid; start each voice part on a beat.
