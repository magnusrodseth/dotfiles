---
name: humanize
description: "Detect and rewrite prose that reads as AI-generated: em dashes, AI vocabulary, negative parallelisms, rule-of-three filler, puffery, tone tells. Use for \"humanize this\", \"de-slop\", \"sounds like ChatGPT\", \"make this less AI\"."
---

# Humanize

Rewrite prose to remove AI tells. Preserve meaning, strip the cadence.

## The two layers

AI-ness lives at two levels, and they are not equally durable.

- **Surface layer** (vocabulary, punctuation, sentence rhythm, paragraph scaffolding): the tells in [references/tells.md](references/tells.md). Cheap to detect and cheap to remove, but transient. Newer models shed them on their own, and a light edit strips the rest.
- **Discourse layer** (whether the piece took a real, contestable position; whether it holds genuine tension; whether its specifics are named and concrete): the moves in [references/rewrite-toward-human.md](references/rewrite-toward-human.md).

Stripping the surface layer is necessary but not sufficient. In a controlled test, running AI text through exactly this kind of span-level artifact removal (clichés, purple prose, redundant exposition) moved a discourse-level detector by only 1.6 points: the structural fingerprint survived the scrub (Russell et al., 2026; see [references/sources.md](references/sources.md)). So for anything longer than a short message, treat the positive-direction pass (step 5) as load-bearing work, not a finishing gloss. If a passage has no point of view, no amount of tell-stripping will make it read human.

## When to invoke

User pastes text and asks to clean it up, flags something as sounding like AI or ChatGPT, asks for "tells" to be removed, or asks for general humanizing of a paragraph, email, blog post, doc, or message.

## Workflow

1. **Hard-tell scan.** Grep for deterministic markers:
   ```bash
   grep -nE 'utm_source=(chatgpt|openai|copilot)|referrer=grok\.com|:contentReference|oai_citation|turn0(search|image|news|file)|grok_render_citation|grok-card|attached_file:[0-9]|attributableIndex|【[0-9]+†|20[0-9]{2}-XX-XX' <file>
   ```
   In the same pass, run the emphatic/appositive-colon grep from the ad-hoc list
   below. It is mandatory on every invocation, including narrow or scoped passes:
   a scope like "em-dash and vocabulary only" limits which rewrites you apply, not
   which scans you run, and colon overuse is exactly the tell that hides behind an
   em-dash ban. Judge each hit: a colon introducing a genuine list, a quotation, or
   a code block stays; an appositive "X: Y" doing the job of a banned em dash gets
   recast as a full sentence; a labeled opener repeated across sections ("Regelen:
   ..." again and again) is template scaffolding and gets varied or dropped. Report
   the colon findings even when the requested scope did not name them.

2. **Triage.** Read against [references/tells.md](references/tells.md) and classify each candidate change by risk tier (see [references/risk-tiers.md](references/risk-tiers.md)):
   - **Tier 1** (mechanical, can't change meaning): apply silently. Em dashes, curly quotes, hard-tell markers, placeholder text.
   - **Tier 2** (low-risk swaps): apply, then mention in the closing summary. AI vocab swaps, didactic disclaimers, superficial tails, weasel attributions, copulative restoration.
   - **Tier 3** (could change tone, meaning, voice, or structure): pause and ask.

3. **Apply Tier 1 and Tier 2.** Use patterns from [references/rewrite-patterns.md](references/rewrite-patterns.md). Work category by category.

4. **Ask about Tier 3 decisions.** Use the `AskUserQuestion` tool, one decision at a time, with a recommended option labeled "(Recommended)". Wait for the answer before applying. Cap at 3-4 questions per document; if more high-risk passages exist than that, batch them into a single question ("apply my recommendation to all / ask one by one / leave them").

5. **Positive-direction pass (the load-bearing layer; for prose, not short messages).** Stripping tells only removes the transient surface signal (see The two layers above); this pass addresses the durable one, and for anything longer than a short message it is where the real work happens. Clean text can still be inert. Use [references/rewrite-toward-human.md](references/rewrite-toward-human.md) to restore human rhythm. Apply the Group A structural moves freely (vary sentence length, cut filler transitions, restore active voice, land on the strong word): they change cadence, not content. For the Group B content-and-voice moves (add a concrete number, a first-person note, an emotional edge), **never fabricate**: reshape specifics the author already gave, or flag the gap and ask. Skip this pass for terse factual text or short messages where the machine rhythm isn't the problem.

6. **Re-scan.** Re-run the grep on the rewritten text. Should come back empty.

## Output

Return the rewritten text. End with a brief summary: counts of Tier 1 fixes (e.g. "4 em dashes, 2 curly quotes"), Tier 2 fixes (e.g. "swapped 3 instances of 'underscore', dropped 2 didactic disclaimers"), and any Tier 3 passages left alone with the reason ("kept the closing paragraph; you confirmed it's the brand voice"). If you ran a positive-direction pass, note the structural moves ("varied sentence length in the second paragraph, restored active voice twice") and flag any gap you left for the author ("the '40% faster' claim needs a real number, left a marker").

If the text was already clean, say so and return it unchanged. Do not invent tells to justify edits.

## Rules

- Preserve meaning, facts, structure, and the author's argument. Only change voice.
- Default to stripping, not embellishing. You may restructure for human rhythm (vary sentence length, restore active voice, cut filler transitions, land on the strong word): that changes cadence, not content. But never invent facts, numbers, sources, quotes, anecdotes, or opinions the author didn't supply. If human-sounding prose needs a concrete specific the text lacks, flag the gap or ask. A fabricated detail is worse than a bland one.
- **Rewrite at the register, not the phrase.** The greps are a detector; they are not the rewrite instruction. Em dashes, emphatic colons, punchy fragments and the Claude-era phrase list are four surfaces of one behaviour: sentences built to land rather than to state (see Turn-of-phrase optimization in [references/tells.md](references/tells.md)). Fix each hit individually and the behaviour moves into unlisted synonyms. State what the prose should do instead ("claim first, qualification after"), then use the greps to catch residue. This applies to instructions you write for a model as much as to prose you edit: enumerating banned tokens is measurably weaker than naming the register, and a long ban list degrades compliance rather than improving it.
- Replace em dashes with two sentences, a comma, or parentheses. Do not swap them for colons by default: the colon-instead-of-em-dash habit produces the emphatic-colon tell, and the author's standing preference is full sentences. A colon earns its place only before a genuine list or a quotation. Never preserve the em dash itself.
- Replace curly quotes and apostrophes with straight ASCII (`"`, `'`).
- Do not "improve" sentences that aren't AI-tell carriers. Leave them alone.
- **Humanizing is not casualizing.** A condolence note, a board memo, a legal letter and a group chat are all human, and none of them sound alike. Strip the AI accent from whatever register the text is already in; do not drag formal writing toward breezy startup voice, and do not add contractions or fragments to a register that was formal on purpose. If the register itself seems wrong for the audience, say so instead of silently changing it.
- **Don't overcorrect.** Every rule here describes taste, not a checklist to satisfy. The failure mode on the other side is real: every sentence punchy, every paragraph one line, forced fragments, inserted slang, a useful word avoided because it appears on a list. Do not swing so far that the output reads as an AI performing humanness. The test is whether a person would plausibly have written this, not whether it avoids the most tells. If a rewrite feels forced, keep the plainer original.
- Norwegian text: preserve æ, ø, å. Apply the same tells taxonomy (calques translate).
- When in doubt about whether a rewrite changes meaning, tone, or voice: ask. The cost of one extra question is low; the cost of paving over the user's actual voice is high.

## Ad-hoc greps for specific tells

When checking a long doc for one category at a time. Exception: the emphatic/appositive-colon grep below is not ad-hoc - it runs in step 1 on every pass:

```bash
# AI vocabulary (GPT-4 era + newer additions)
grep -niE '\b(delve|underscore|tapestry|vibrant|pivotal|robust|meticulous|crucial|testament|bolster|garner|interplay|intricate|enduring|landscape|certainly|utilize|streamline|harness|paradigm|synergy|ecosystem)\b' <file>

# Claude-era phrases (2026+). Opus 5 and Fable 5 lineages; see tells.md for which is which.
# These are surface residue of the turn-of-phrase register - fix the register first, then re-run this.
grep -niE '\b(carry the argument|worth stating plainly|stated fairly|load-bearing|key insight|full stop\.|the [a-z]+ matters more)\b|, and the trap' <file>

# Hyphen-stacked compounds and arrow chains (Fable 5; also generic agent shorthand leaking into prose).
# Low precision: legitimate triples exist (state-of-the-art, out-of-the-box). Judge each; weigh by density.
grep -nE '[[:alpha:]]+-[[:alpha:]]+-[[:alpha:]]+|→' <file>

# Magic adverbs (lower precision, weigh by density)
grep -niE '\b(quietly|deeply|fundamentally|remarkably|arguably|profoundly)\b' <file>

# Negative parallelisms (incl. causal variant)
grep -niE "not (just|only|merely|because) .{1,60}\b(but|it'?s|because)\b" <file>

# Softened reframes (same setup-payoff move with the "not" dissolved; low precision, judge each)
grep -niE "(while|although|sure,|at first glance|on the surface|most people (think|assume)|conventional wisdom|everyone talks about).{0,80}\b(but|yet|actually|really|instead|rather|ultimately|in reality|the truth is|what matters is)\b" <file>

# Product-marketing vocabulary (decorative use only; keep the correct technical term)
grep -niE '\b(seamless|unlock|empower|elevate|supercharge|frictionless|effortless|game-changer|revolutioniz(e|es|ed|ing)|cutting-edge|state-of-the-art|best-in-class|groundbreaking|unparalleled|unprecedented|transformative|disruptive|reimagine|redefine|democratize|turnkey|plug-and-play|future-proof|holistic|mission-critical|embark|deep dive|look no further|rest assured)\b' <file>

# Craft-metaphor verbs for abstract work (low precision, weigh by density and literal sense)
grep -niE '\b(sanded down|bolted on|stripped back|stitched together|woven|carved out|baked in|distilled|crystalliz(e|ed|ing)|sharpened|surfaced|amplified|anchored|cemented|bridged|unpacked)\b' <file>

# Analogy setups (beyond the tone grep below; check against the budget and permission test)
grep -niE "it'?s (like|basically) a|picture (this|a)|works like a|acts like a|functions as a|the (backbone|engine|dna|north star|flywheel|plumbing) of|a (bridge|lens|roadmap) for" <file>

# Superficial analysis tails
grep -niE ', (highlighting|underscoring|emphasizing|reflecting|symbolizing|showcasing|fostering|ensuring|contributing to|cultivating)\b' <file>

# Didactic disclaimers + empty-emphasis openers
grep -niE "it'?s (important|crucial|worth) (to )?(note|remember|consider)|^(Importantly|Interestingly|Notably)," <file>

# Tone / rhetorical transitions
grep -niE "here'?s (the|what) (kicker|thing|deal|where|most)|let'?s (break|unpack|dive|explore)|think of it (as|like)|imagine a world where" <file>

# Rhetorical question-and-answer ("The X? A Y.")
grep -niE '\b[A-Z][a-z]+( [a-z]+){0,4}\? [A-Z][a-z]+\.' <file>

# False ranges
grep -niE '\bfrom [a-z]+ to [a-z]+\b' <file>

# Section summaries
grep -niE '^(In (summary|conclusion)|Overall),' <file>

# Puffery + grandiose stakes
grep -niE '\b(boasts|nestled|in the heart of|vibrant|rich tapestry|stands as|serves as|a testament to|reshape (how we|everything)|define the next era|changes everything)\b' <file>

# Unicode decoration (arrows, typed-out symbols). Literal chars so it works with BSD grep too.
grep -nE '→|⇒|↔' <file>

# Emphatic / appositive colon (candidates only; judge each). Excludes URLs, image/alt lines, frontmatter keys, attributions, list intros, fixed openers.
grep -nE '[[:alpha:]]+: [[:alpha:]]' <file> | grep -vE 'https?://|!\[|^[0-9]+:(title|date|author|tags|description|draft|slug|type|created|aliases|status|related|source|linkedin_teaser):|Kilde:|Figure [0-9]|Figur [0-9]|For ordens skyld:|Konkret:|^[0-9]*: *[-*]'
```
