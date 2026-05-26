---
name: humanize
description: Detect and rewrite prose that reads as AI-generated. Strips em dashes, curly quotes, AI vocabulary (delve, underscore, tapestry, vibrant, robust), negative parallelisms ("not just X, but Y"), rule-of-three filler, weasel attributions, puffery, didactic disclaimers, and citation artifacts. Use when the user says "humanize this", "de-slop", "make this less AI", "sounds like ChatGPT", "remove AI tells", "rewrite without AI voice", "this reads AI-generated", or pastes prose for cleanup.
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

5. **Re-scan.** Re-run the grep on the rewritten text. Should come back empty.

## Output

Return the rewritten text. End with a brief summary: counts of Tier 1 fixes (e.g. "4 em dashes, 2 curly quotes"), Tier 2 fixes (e.g. "swapped 3 instances of 'underscore', dropped 2 didactic disclaimers"), and any Tier 3 passages left alone with the reason ("kept the closing paragraph; you confirmed it's the brand voice").

If the text was already clean, say so and return it unchanged. Do not invent tells to justify edits.

## Rules

- Preserve meaning, facts, structure, and the author's argument. Only change voice.
- Do not inject personality or flair the original lacked. Humanize means strip, not embellish.
- Replace em dashes with commas, parentheses, colons, semicolons, or two sentences. Never preserve them.
- Replace curly quotes and apostrophes with straight ASCII (`"`, `'`).
- Do not "improve" sentences that aren't AI-tell carriers. Leave them alone.
- Norwegian text: preserve æ, ø, å. Apply the same tells taxonomy (calques translate).
- When in doubt about whether a rewrite changes meaning, tone, or voice: ask. The cost of one extra question is low; the cost of paving over the user's actual voice is high.

## Ad-hoc greps for specific tells

When checking a long doc for one category at a time:

```bash
# AI vocabulary (GPT-4 era)
grep -niE '\b(delve|underscore|tapestry|vibrant|pivotal|robust|meticulous|crucial|testament|bolster|garner|interplay|intricate|enduring|landscape)\b' <file>

# Negative parallelisms
grep -niE "not (just|only|merely) .{1,60}\b(but|it'?s)\b" <file>

# Superficial analysis tails
grep -niE ', (highlighting|underscoring|emphasizing|reflecting|symbolizing|showcasing|fostering|ensuring|contributing to|cultivating)\b' <file>

# Didactic disclaimers
grep -niE "it'?s (important|crucial|worth) (to )?(note|remember|consider)" <file>

# Section summaries
grep -niE '^(In (summary|conclusion)|Overall),' <file>

# Puffery
grep -niE '\b(boasts|nestled|in the heart of|vibrant|rich tapestry|stands as|serves as|a testament to)\b' <file>
```
