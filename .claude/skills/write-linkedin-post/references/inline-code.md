# Inline code on LinkedIn

LinkedIn strips markdown and has no code formatting. The code look you see in
Guillermo Rauch's posts (𝚛𝚎𝚜𝚎𝚝, 𝚝𝚜𝚎𝚝, 𝚗𝚌𝚞𝚛𝚜𝚎𝚜, 𝙰𝙶𝙴𝙽𝚃𝚂.𝚖𝚍) is not a font. It is
the Unicode **Mathematical Monospace** block: letters at U+1D670 to U+1D6A3 and
digits at U+1D7F6 to U+1D7FF, pasted in as ordinary text. Verified 27.08.2026 by
pulling his feed through `linkedin-mcp` and inspecting the code points.

## How to produce it

```
python3 scripts/mono.py 'vercel connect create notion'   # → 𝚟𝚎𝚛𝚌𝚎𝚕 𝚌𝚘𝚗𝚗𝚎𝚌𝚝 𝚌𝚛𝚎𝚊𝚝𝚎 𝚗𝚘𝚝𝚒𝚘𝚗
python3 scripts/mono.py --decode '𝚏𝚡'                    # → fx
```

The script changes only `[A-Za-z0-9]`. Punctuation and spaces pass through, so
`sandbox@latest`, `sleep(1)`, `-o /server` and `"gitSource": {` all come out the
way he writes them. Always paste the script's output. Hand-typing these
characters is where a stray ASCII letter slips in and breaks the look mid-word.

## What gets it, from his feed

| Gets monospace | Example from rauchg |
|---|---|
| Shell commands, with their flags and arguments | 𝚟𝚎𝚛𝚌𝚎𝚕 𝚒𝚗𝚝𝚎𝚐𝚛𝚊𝚝𝚒𝚘𝚗 𝚊𝚍𝚍 𝚜𝚝𝚛𝚒𝚙𝚎, 𝚗𝚙𝚡 𝚜𝚊𝚗𝚍𝚋𝚘𝚡@𝚕𝚊𝚝𝚎𝚜𝚝 𝚜𝚑, 𝚟𝚌 𝚍𝚎𝚟 |
| Program and library names that are typed, not branded | 𝚛𝚎𝚜𝚎𝚝, 𝚝𝚜𝚎𝚝, 𝚗𝚌𝚞𝚛𝚜𝚎𝚜, 𝚝𝚎𝚛𝚖𝚒𝚗𝚏𝚘, 𝚏𝚡 |
| Function and API names | 𝚞𝚜𝚎𝚁𝚎𝚊𝚕𝚝𝚒𝚖𝚎, 𝚐𝚎𝚗𝚎𝚛𝚊𝚝𝚎𝚂𝚙𝚎𝚎𝚌𝚑, 𝚝𝚛𝚊𝚗𝚜𝚌𝚛𝚒𝚋𝚎 |
| Filenames and paths | 𝙰𝙶𝙴𝙽𝚃𝚂.𝚖𝚍, 𝚛𝚎𝚜𝚎𝚊𝚛𝚌𝚑/, 𝙳𝚘𝚌𝚔𝚎𝚛𝚏𝚒𝚕𝚎.𝚟𝚎𝚛𝚌𝚎𝚕 |
| Short code blocks, one line per line | a five-line Dockerfile, a JSON payload with 𝚐𝚒𝚝𝚂𝚘𝚞𝚛𝚌𝚎 and 𝚛𝚎𝚙𝚘𝙸𝚍 |
| Numbers inside code | 𝚜𝚕𝚎𝚎𝚙(𝟷), 𝚐𝚘𝚕𝚊𝚗𝚐:𝟷.𝟸𝟺 |

| Stays plain | Example |
|---|---|
| Product and company names | Vercel Sandbox, AI SDK, Zig, Orion, Claude Code |
| URLs and domains | github.com/rauchg/rst, fx.sh, vercel.fyi/caps |
| Prose numbers | 1ms instead of 1s, 62%, 6,000 deployments |
| Anything in a Norwegian sentence that is not literally typed | see below |

He is not rigid about it. One post writes `$ npm i -g @googleworkspace/cli` in
plain ASCII with a `$` prompt. The rule of thumb that fits every case: **if the
reader would type it, it gets monospace; if they would say it, it stays plain.**

## For Magnus's posts

His corpus so far has none of this. Places in past posts where it would have
fit: `/goal`, the `sb1` CLI name, `npx`, `AGENTS.md`, a package name at launch.
It suits Bygg / ship and Forklaring posts. It has no place in Arrangement or
Omtale posts, where nothing is typed.

Three constraints on top of rauchg's usage:

- **Keep it out of the hook.** The first two paragraphs are plain prose. The
  fold is measured in characters and these are four-byte code points, so a
  monospace hook is a fold count you cannot predict, and it reads as noise in
  the preview card anyway.
- **Never on words with æ, ø or å.** There is no monospace variant of those
  letters, so 𝚕ø𝚗𝚗.𝚖𝚍 renders with one ASCII-looking letter in the middle.
  Rename the example in the post, or leave the word plain.
- **Use it two to five times per post, not on every noun.** Each run is one
  thing the reader could type. A paragraph that is half monospace is a code
  block, and LinkedIn is the wrong place for one longer than the Dockerfile
  above.

## Known costs

- Screen readers announce each character as "mathematical monospace small n",
  so the word is unreadable to anyone on VoiceOver. Keep runs short and make
  sure the sentence works if the monospace word were skipped.
- LinkedIn search and browser find do not match the ASCII word. A post about
  𝚏𝚡 will not come up when someone searches for "fx". If searchability matters
  for the post's main term, write it plain at least once.
- Some older Android and Windows fonts render the block as boxes. Rare on
  LinkedIn's audience in 2026, but it is why the first mention of a tool
  should still be a sentence a reader can understand without the glyphs.
