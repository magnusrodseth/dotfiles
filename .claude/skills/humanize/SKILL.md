---
name: humanize
description: Detect and rewrite prose that reads as AI-generated. Strips em dashes, curly quotes, unicode arrows, AI vocabulary (delve, underscore, tapestry, vibrant, robust, quietly), negative parallelisms ("not just X, but Y"), rhetorical question-and-answer, rule-of-three filler, tone tells ("here's the kicker", "let's break this down", "imagine a world where"), weasel attributions, puffery, didactic disclaimers, and citation artifacts. Then rewrites toward human rhythm (sentence-length variance, active voice, concreteness) without fabricating facts. Use when the user says "humanize this", "de-slop", "make this less AI", "make this sound more human", "sounds like ChatGPT", "remove AI tells", "rewrite without AI voice", "this reads AI-generated", or pastes prose for cleanup.
---

# Humanize

Rewrite prose to remove AI tells. Preserve meaning, strip the cadence.

## When to invoke

User pastes text and asks to clean it up, flags something as sounding like AI or ChatGPT, asks for "tells" to be removed, or asks for general humanizing of a paragraph, email, blog post, doc, or message.

## Workflow

1. **Hard-tell scan.** Grep for deterministic markers:
   ```bash
   grep -nE 'utm_source=(chatgpt|openai|copilot)|referrer=grok\.com|:contentReference|oai_citation|turn0(search|image|news|file)|grok_render_citation|grok-card|attached_file:[0-9]|attributableIndex|【[0-9]+†|20[0-9]{2}-XX-XX' <file>
   ```

2. **Triage.** Read against [references/tells.md](references/tells.md) and classify each candidate change by risk tier (see [references/risk-tiers.md](references/risk-tiers.md)):
   - **Tier 1** (mechanical, can't change meaning): apply silently. Em dashes, curly quotes, hard-tell markers, placeholder text.
   - **Tier 2** (low-risk swaps): apply, then mention in the closing summary. AI vocab swaps, didactic disclaimers, superficial tails, weasel attributions, copulative restoration.
   - **Tier 3** (could change tone, meaning, voice, or structure): pause and ask.

3. **Apply Tier 1 and Tier 2.** Use patterns from [references/rewrite-patterns.md](references/rewrite-patterns.md). Work category by category.

4. **Ask about Tier 3 decisions.** Use the `AskUserQuestion` tool, one decision at a time, with a recommended option labeled "(Recommended)". Wait for the answer before applying. Cap at 3-4 questions per document; if more high-risk passages exist than that, batch them into a single question ("apply my recommendation to all / ask one by one / leave them").

5. **Positive-direction pass (for prose, not short messages).** Stripping tells can leave text that is clean but inert. Use [references/rewrite-toward-human.md](references/rewrite-toward-human.md) to restore human rhythm. Apply the Group A structural moves freely (vary sentence length, cut filler transitions, restore active voice, land on the strong word): they change cadence, not content. For the Group B content-and-voice moves (add a concrete number, a first-person note, an emotional edge), **never fabricate**: reshape specifics the author already gave, or flag the gap and ask. Skip this pass for terse factual text or short messages where the machine rhythm isn't the problem.

6. **Re-scan.** Re-run the grep on the rewritten text. Should come back empty.

## Output

Return the rewritten text. End with a brief summary: counts of Tier 1 fixes (e.g. "4 em dashes, 2 curly quotes"), Tier 2 fixes (e.g. "swapped 3 instances of 'underscore', dropped 2 didactic disclaimers"), and any Tier 3 passages left alone with the reason ("kept the closing paragraph; you confirmed it's the brand voice"). If you ran a positive-direction pass, note the structural moves ("varied sentence length in the second paragraph, restored active voice twice") and flag any gap you left for the author ("the '40% faster' claim needs a real number, left a marker").

If the text was already clean, say so and return it unchanged. Do not invent tells to justify edits.

## Rules

- Preserve meaning, facts, structure, and the author's argument. Only change voice.
- Default to stripping, not embellishing. You may restructure for human rhythm (vary sentence length, restore active voice, cut filler transitions, land on the strong word): that changes cadence, not content. But never invent facts, numbers, sources, quotes, anecdotes, or opinions the author didn't supply. If human-sounding prose needs a concrete specific the text lacks, flag the gap or ask. A fabricated detail is worse than a bland one.
- Replace em dashes with commas, parentheses, colons, semicolons, or two sentences. Never preserve them.
- Replace curly quotes and apostrophes with straight ASCII (`"`, `'`).
- Do not "improve" sentences that aren't AI-tell carriers. Leave them alone.
- Norwegian text: preserve æ, ø, å. Apply the same tells taxonomy (calques translate).
- When in doubt about whether a rewrite changes meaning, tone, or voice: ask. The cost of one extra question is low; the cost of paving over the user's actual voice is high.

## Ad-hoc greps for specific tells

When checking a long doc for one category at a time:

```bash
# AI vocabulary (GPT-4 era + newer additions)
grep -niE '\b(delve|underscore|tapestry|vibrant|pivotal|robust|meticulous|crucial|testament|bolster|garner|interplay|intricate|enduring|landscape|certainly|utilize|streamline|harness|paradigm|synergy|ecosystem)\b' <file>

# Magic adverbs (lower precision, weigh by density)
grep -niE '\b(quietly|deeply|fundamentally|remarkably|arguably|profoundly)\b' <file>

# Negative parallelisms (incl. causal variant)
grep -niE "not (just|only|merely|because) .{1,60}\b(but|it'?s|because)\b" <file>

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
```
