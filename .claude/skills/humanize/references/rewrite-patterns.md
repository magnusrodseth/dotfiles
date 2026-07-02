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

## Magic adverbs

Delete the adverb. The sentence almost always says the same thing, more honestly, without it.

| Before | After |
|---|---|
| `The tool quietly orchestrates your workflows.` | `The tool orchestrates your workflows.` |
| `This is a fundamentally different approach.` | `This is a different approach.` (or say how it differs) |
| `The results were remarkably consistent.` | `The results were consistent.` |

If deleting "quietly" removes the whole point of the sentence, the sentence had no point. Cut it.

## Negative parallelisms

Strip the setup. Keep the payoff if it has content, drop it if it's empty.

| Before | After |
|---|---|
| `It's not just a meme, it's a celebration of car culture.` | `It's a celebration of car culture.` |
| `This isn't sourcing, it's framing.` | `This is a framing problem, not a sourcing one.` (or split into two sentences) |
| `Not only dismissive but also unnecessarily harsh.` | `Dismissive and harsh.` |
| `Not a career, not a body of work, just an algorithmic moment.` | `Just an algorithmic moment, with no career or body of work behind it.` |

## Dramatic countdown ("Not X. Not Y. Just Z.")

Collapse the countdown into a plain statement of Z.

| Before | After |
|---|---|
| `Not a bug. Not a feature. A fundamental design flaw.` | `This is a design flaw.` |
| `Not ten. Not fifty. Five hundred and twenty-three violations.` | `There are 523 violations.` |

## Rhetorical question-and-answer ("The X? A Y.")

Drop the question, state the answer.

| Before | After |
|---|---|
| `The result? Devastating.` | `The result was devastating.` |
| `The worst part? Nobody saw it coming.` | `Worst of all, nobody saw it coming.` |

Keep a rhetorical question only when it's genuinely doing work (a real pivot the reader is asking too). One is fine; a string of them is the tell.

## Rule of three

Cut to two, or to one if the third item was filler. Most triplets are padding.

| Before | After |
|---|---|
| `engaging, repetitive, and entertaining` | `engaging and repetitive` (or whichever two carry the meaning) |
| `identity, authenticity, and what it means to live on` | `identity and authenticity` |
| `through critique, correction, and clarity` | `through critique and correction` |

If the triplet has genuinely three distinct items (e.g. "Photoshop, Figma, and Sketch"), keep it. The tell is when the three are near-synonyms or vague abstractions.

## False ranges

If the two ends aren't a real spectrum, list the things plainly or name what you mean.

| Before | After |
|---|---|
| `From innovation to cultural transformation.` | `Both new products and the way people work.` (say what you actually mean) |
| `Everything from strategy to execution.` | `Strategy and execution.` |

## Anaphora

Keep one instance of the repeated opening; vary or merge the rest.

| Before | After |
|---|---|
| `They assume users will pay. They assume developers will build. They assume ecosystems will emerge.` | `They assume users will pay, developers will build, and ecosystems will emerge.` |

Deliberate anaphora in a speech or a punchy close can stay. Ask if it reads as intentional rhetoric rather than a generation tic.

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

## Dead metaphor

If one metaphor recurs more than twice, keep the strongest instance and state the rest literally.

Before:
> Platforms are the doors. Products build walls; platforms build doors. Without doors, the ecosystem has no way in, and every wall is just another wall.

After:
> Products are closed; platforms let others build on top. Without that opening, there's no ecosystem.

## Tone and rhetorical tells

These usually get deleted, not rewritten. The setup phrase is the tell; the point underneath is often fine on its own.

| Before | After |
|---|---|
| `Here's the kicker: the API is rate-limited.` | `The API is rate-limited.` |
| `Think of it as a Swiss Army knife for your workflow.` | Delete the analogy; describe what it does. |
| `Imagine a world where every tool has intelligence built in.` | `If every tool had this built in, ...` (or state the claim directly) |
| `Let's break this down step by step.` | Delete. Just explain it. |
| `The truth is simple: nobody tested it.` | `Nobody tested it.` |
| `And yes, I'll be honest, I love this model.` | `I like this model.` (or cut) |
| `This will fundamentally reshape how we think about everything.` | State the actual, bounded effect. If you can't, cut the sentence. |
| `This is the classic supervision paradox.` | Describe the problem in plain words; drop the coined label unless it's genuinely established. |

## Unicode arrows

Replace `→` with a word or restructure. Never leave the arrow.

| Before | After |
|---|---|
| `Input → Processing → Output` | `Input, then processing, then output.` |
| `More engagement → more revenue.` | `More engagement means more revenue.` |

## Short punchy fragments

Rejoin fragments into complete sentences with varied length. Don't flatten everything to one rhythm; the goal is variety, not uniformity. Ask first if the staccato is clearly deliberate voice.

Before:
> He published this. Openly. In a book. As a priest.

After:
> He published it openly, in a book, as a priest.

## Listicle in a trench coat

Either commit to a real list or write real connected prose. Don't leave the "The first... The second..." scaffolding in disguised paragraphs.

Before:
> The first wall is the missing API. The second wall is the lack of delegated access. The third wall is the absence of scoped permissions.

After (prose):
> Three things block it: there's no API, no delegated access, and no scoped permissions.

## One-point dilution and fractal summaries

Cut. If a section restates the thesis with a fresh metaphor but adds no new fact or argument, delete the restatement. Remove per-section previews and recaps that only echo what the prose already says. These are wholesale-deletion candidates, so confirm before cutting large blocks (see risk tiers).

## Historical analogy stacking

Keep at most one example that actually earns its place; delete the rapid-fire roll call.

Before:
> Apple didn't build Uber. Facebook didn't build Spotify. Stripe didn't build Shopify. AWS didn't build Airbnb.

After:
> Platform owners rarely build the apps on top of them (AWS didn't build Airbnb).

## When to leave it alone

- Quotes from other people (don't rewrite their voice)
- Direct citations of source material
- Technical jargon that has only one right word
- The author's deliberate stylistic choices (e.g. they actually like em dashes and the text is already otherwise clean)
- Text that already reads human and has at most one or two minor tells (don't over-rewrite)
