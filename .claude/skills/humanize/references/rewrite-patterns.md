# Rewrite patterns

Concrete before/after for each category in [tells.md](tells.md). When humanizing, work category by category. Don't try to fix everything in one pass.

## Em dashes

Replace with comma, parentheses, colon, semicolon, or split into two sentences. Pick whichever fits the rhythm.

| Before | After |
|---|---|
| `Wikipedia is community-run — it depends on collaboration.` | `Wikipedia is community-run; it depends on collaboration.` |
| `The issue isn't sourcing — it's framing.` | `The issue isn't sourcing. It's framing.` |
| `She gained attention in the early 2020s — and her feminist message resonated.` | `She gained attention in the early 2020s, and her feminist message resonated.` |
| `Three tools — Photoshop, Figma, and Sketch — dominate the market.` | `Three tools (Photoshop, Figma, and Sketch) dominate the market.` |

Rule: if there are more than two em dashes in a short paragraph, the rhythm itself is the tell. Vary the replacements so the rewrite doesn't read like search-and-replace.

## Curly quotes and apostrophes

Replace every `"` `"` `'` `'` `'` with straight ASCII `"` and `'`. Mechanical.

## AI vocabulary

Replace the word with a plainer synonym. Don't try to preserve the cadence of the AI sentence; usually the whole sentence needs to relax.

| Before | After |
|---|---|
| `Let me delve into the details.` | `Here are the details.` |
| `This underscores the importance of testing.` | `This shows testing matters.` (or just delete the sentence) |
| `The intricate tapestry of urban life` | `Urban life` |
| `A pivotal moment in the evolution of regional statistics` | `A turning point for regional statistics` (or drop entirely) |
| `Meticulously crafted to enhance user experience` | `Built to be easy to use` |
| `A robust framework that fosters collaboration` | `A framework that helps people work together` |
| `Valuable insights into the data` | `What the data shows` |
| `A vibrant community of contributors` | `A community of contributors` |
| `Bolstered by recent investment` | `With recent investment` |
| `Showcasing the team's commitment` | `Showing what the team built` |

If a sentence is mostly AI vocabulary with little factual content, delete it. Most "underscore" / "highlight the importance of" sentences add nothing.

## Negative parallelisms

Strip the setup. Keep the payoff if it has content, drop it if it's empty.

| Before | After |
|---|---|
| `It's not just a meme, it's a celebration of car culture.` | `It's a celebration of car culture.` |
| `This isn't sourcing, it's framing.` | `This is a framing problem, not a sourcing one.` (or split into two sentences) |
| `Not only dismissive but also unnecessarily harsh.` | `Dismissive and harsh.` |
| `Not a career, not a body of work, just an algorithmic moment.` | `Just an algorithmic moment, with no career or body of work behind it.` |

## Rule of three

Cut to two, or to one if the third item was filler. Most triplets are padding.

| Before | After |
|---|---|
| `engaging, repetitive, and entertaining` | `engaging and repetitive` (or whichever two carry the meaning) |
| `identity, authenticity, and what it means to live on` | `identity and authenticity` |
| `through critique, correction, and clarity` | `through critique and correction` |

If the triplet has genuinely three distinct items (e.g. "Photoshop, Figma, and Sketch"), keep it. The tell is when the three are near-synonyms or vague abstractions.

## Superficial analysis tails

Delete the trailing participle phrase. The sentence almost always stands without it.

| Before | After |
|---|---|
| `The station has six platforms, contributing to the socio-economic development of the region.` | `The station has six platforms.` |
| `He stepped down in 2010, marking the end of an era.` | `He stepped down in 2010.` |
| `The mall employs 3,000 staff, reflecting its scale.` | `The mall employs 3,000 staff.` |
| `Its features support remote work, fostering productivity.` | `Its features support remote work.` |

## Weasel attributions

Either name a source or delete the attribution.

| Before | After |
|---|---|
| `Experts argue that X.` | `[Name] argued that X in [year].` or just `X.` |
| `Industry reports suggest declining demand.` | `Demand is declining.` (if uncontested) or cite the report |
| `Researchers treat X as a fluid formation.` | `Smith (2019) treats X as fluid.` or `X is generally treated as fluid.` |
| `Some critics have noted...` | Drop, unless you can name them |

## Copulative avoidance

Swap fancy verbs back to "is/has/was".

| Before | After |
|---|---|
| `The gallery features four spaces.` | `The gallery has four spaces.` |
| `X serves as a hub for trade.` | `X is a trade hub.` |
| `The book stands as a testament to...` | `The book shows...` (or drop) |
| `Y constitutes a deviation from...` | `Y is a deviation from...` |
| `Z refers to a class of problems.` | `Z is a class of problems.` |

## Puffery

Strip the inflated framing. State the fact plainly.

| Before | After |
|---|---|
| `Nestled in the heart of Tuscany, this vibrant town boasts a rich cultural heritage.` | `The town is in Tuscany.` (then state actual facts) |
| `A groundbreaking achievement that reshaped the landscape of computing.` | `A new approach in computing.` (then say what it actually did) |
| `Renowned for its commitment to excellence.` | Delete. Replace with a specific fact if you have one. |

## Outline-style "Challenges and Future" sections

Delete the section if it contains no specific information. Most "Despite these challenges, X continues to thrive" paragraphs are pure filler. If the challenges are real and specific, keep them as plain prose with no canned framing.

## Didactic disclaimers

Delete. The reader didn't ask.

| Before | After |
|---|---|
| `It's important to note that results may vary.` | Delete (or move to a footnote if genuinely needed). |
| `It's worth considering the historical context.` | Delete. |
| `It is crucial to differentiate X from Y.` | `X is different from Y.` (then say how) |

## Knowledge-cutoff hedges

Delete or replace with concrete uncertainty.

| Before | After |
|---|---|
| `As of my last knowledge update, X is the current standard.` | `X is the current standard as of [year].` (verify first) |
| `While specific details are limited in available sources...` | Delete, or rewrite to acknowledge the actual gap. |
| `The subject likely supports a low profile.` | Delete; don't speculate. |

## Section summaries

Delete "In summary", "In conclusion", "Overall" at paragraph starts unless the document is genuinely long enough to need a recap. In a four-paragraph piece, no.

## Boldface overuse

Remove all bold except where the document genuinely needs it (one-off emphasis, a defined term being introduced, a UI label). If a paragraph has more than one bolded phrase, ask whether any of them needed it.

## Inline-header vertical lists

Convert to flowing prose, or to a list without the colon-and-bold pattern.

Before:
```
- **Construction**: Used for drywall and plywood.
- **Electrical**: Used for outlets and switches.
- **Automotive**: Used for auto body repair.
```

After (prose):
> Used in construction (drywall, plywood), electrical work (outlets, switches), and auto body repair.

After (list, if list is genuinely needed):
```
- Construction: drywall, plywood
- Electrical: outlets, switches
- Automotive: auto body repair
```

## Markdown leakage in non-Markdown contexts

When the target is plain text, email, a CMS that doesn't render Markdown, or a wiki with different syntax: strip all `**`, `#`, `` ``` ``, `---`. Convert headings to either real headings in the target syntax or to plain capitalized lines followed by a blank line.

## Lexical elegant variation

If one concept is being referred to with three different phrasings in adjacent sentences, pick one phrasing and stick with it. Repetition reads more natural than thesaurus-driven variation.

Before:
> Vierny supported the artists. Her commitment to the avant-garde fostered creativity. This dedication to Russian non-conformists shaped the era.

After:
> Vierny supported the artists. Her backing shaped the era.

## When to leave it alone

- Quotes from other people (don't rewrite their voice)
- Direct citations of source material
- Technical jargon that has only one right word
- The author's deliberate stylistic choices (e.g. they actually like em dashes and the text is already otherwise clean)
- Text that already reads human and has at most one or two minor tells (don't over-rewrite)
