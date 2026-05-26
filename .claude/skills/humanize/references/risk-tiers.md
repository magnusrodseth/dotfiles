# Risk tiers

Every candidate change falls into one of three tiers. Use this to decide whether to fix silently, fix-and-mention, or pause and ask.

The bar for asking is: **could a reasonable author have made this choice deliberately?** If yes, ask. If no, just fix.

## Tier 1: auto-fix, no notification

Mechanical changes that cannot change meaning. Apply without comment.

- Em dashes (`—`) replaced with comma, parens, colon, semicolon, or sentence split
- En dashes in prose where a hyphen or "to" is correct
- Curly quotes (`"`, `"`) to straight (`"`)
- Curly apostrophes (`'`) to straight (`'`)
- Hard-tell citation markers: `utm_source=chatgpt.com`, `:contentReference`, `oai_citation`, `turn0search`, `grok_render_citation`, `<grok-card>`, lenticular bracket markers (`【NN†L...】`), `[attached_file:N]`, `attributableIndex`, placeholder dates (`2025-XX-XX`), placeholder URLs (`PASTE_URL_HERE`, `INSERT_SOURCE_URL_N`) → delete
- Markdown syntax that leaked into a plain-text or email context where it won't render → strip
- Trailing whitespace, double spaces, stray "Subject: ..." prefixes pasted from email forms

These are non-debatable. If the user pasted them, they didn't mean to.

## Tier 2: auto-fix, mention in summary

Changes that almost never alter meaning. Apply them, but tell the user what you did in the closing summary so they can spot-check.

- **AI vocabulary swaps** when the surrounding sentence is generic: `delve`, `underscore` (figurative), `tapestry`, `vibrant`, `intricate`, `pivotal`, `meticulous`, `garner`, `bolster`, `foster`, `showcase`, `leverage` (as a verb), `landscape` (abstract sense)
- **Copulative restoration**: "X serves as a hub" → "X is a hub"; "the gallery features four spaces" → "the gallery has four spaces"
- **Superficial analysis tails** that add no factual content: `, highlighting the importance of...`, `, reflecting broader trends...`, `, contributing to the development of...`, `, fostering a sense of...`
- **Weasel attributions** with no named source: "experts argue", "industry reports suggest", "observers have noted" → either name a source or delete
- **Didactic disclaimers**: "it's important to note", "it's worth noting", "it's crucial to remember"
- **Section summaries** ("In conclusion", "In summary", "Overall") in documents under ~5 paragraphs
- **Inline-header bullet lists** (`- **Foo**: bar`) when 3-4 lines of prose would read better

## Tier 3: ask before changing

Use `AskUserQuestion` with one decision per question. Always include a recommended option marked `(Recommended)`.

### Domain-correct words

Some AI-vocab words have legitimate technical meanings. Ask when context is ambiguous.

- `robust` in statistics, ML, control theory, software resilience
- `underscore` in music (incidental score), design, programming (literal `_`)
- `key` in cryptography, music, databases, UX
- `tapestry` in textile or art history
- `landscape` referring to actual terrain or screen orientation
- `interplay` in physics or systems analysis
- `garner` when the subject genuinely gathered something specific
- `pivotal` in mechanical engineering

### Tone the user may have wanted

- **Marketing copy** where some puffery is intentional and the brand voice expects it
- **Speeches, poetry, song lyrics, headlines** where rule-of-three or negative parallelism is rhetorical, not AI cadence
- **Personal essays** where the author's voice happens to use em dashes or "not just X, but Y" deliberately
- **Sales-flavored prose** that's supposed to be punchy

### Wholesale deletion candidates

Don't delete a whole section without asking, even if it reeks of AI.

- Entire "Challenges and Future" sections (the user may have meant to flag real challenges)
- Whole paragraphs that are pure puffery (the user may want a softened version, not a cut)
- Closing summary paragraphs (the user may want a tighter summary, not none)
- Bulleted lists of "media coverage" (the user may want them prosified, not removed)

### Structural choices that could go either way

- Converting a list to prose, or vice versa, when both are defensible
- Combining or splitting paragraphs
- Reordering sentences for flow
- Changing heading style or hierarchy

## How to ask

Use `AskUserQuestion`. One decision per question. Recommended option first, labeled `(Recommended)`. Briefly state why it's uncertain.

Example question shape:

> The closing paragraph reads "This commitment to excellence underscores our enduring dedication to customer success." plus three more AI-tell sentences. Could be intentional marketing voice or could be slop.
>
> - Strip the AI cadence; keep the core point (Recommended)
> - Delete the closing paragraph entirely
> - Leave as-is, it's the brand voice

### What NOT to ask about

- Tier 1 or Tier 2 changes. Just do them.
- Global "should I proceed?" questions. The user already invoked humanize; they want it done.
- Stylistic preferences with no risk attached ("should this be a comma or a semicolon?"). Pick one and move on.

### Budget

Cap Tier 3 questions at 3-4 per document. If you find more, batch them:

> I found 7 passages where I'm uncertain whether the AI cadence is intentional. Want to:
> - Apply my recommendation to all 7 (Recommended)
> - Walk through them one by one
> - Leave all 7 untouched and only apply Tier 1 and Tier 2 fixes

## When to skip Tier 3 entirely

If the user said something like "just clean it up", "be aggressive", or "I trust you", reduce Tier 3 to the single highest-risk decision (or skip entirely) and note in the summary what you took the liberty of changing.

If the user said "ask me about anything risky" or "be conservative", expand the Tier 3 budget and ask about borderline Tier 2 cases too.
