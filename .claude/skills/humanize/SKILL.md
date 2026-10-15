---
name: humanize
description: "Detect and rewrite prose that reads as AI-generated: em dashes, AI vocabulary, negative parallelisms, rule-of-three filler, puffery, tone tells. Use for \"humanize this\", \"de-slop\", \"sounds like ChatGPT\", \"make this less AI\"."
---

# Humanize

Make the author's intended meaning easier for the reader to understand. Use the smallest edit that helps; preserve qualifications, uncertainty, and meaningful emphasis.

## The two layers

AI-ness lives at two levels, and they are not equally durable.

- **Surface layer** (vocabulary, punctuation, sentence rhythm, paragraph scaffolding): the tells in [references/tells.md](references/tells.md). Cheap to detect and cheap to remove, but transient. Newer models shed them on their own, and a light edit strips the rest.
- **Discourse layer** (whether the piece communicates what its reader needs, with an argument or concrete evidence where its purpose requires them): the moves in [references/rewrite-toward-human.md](references/rewrite-toward-human.md).

Surface cleanup alone does not establish clarity or fidelity. In a fiction study, artifact removal moved a discourse-level detector by only 1.6 points (Russell et al., 2026; see [references/sources.md](references/sources.md)). Use step 5 when prose needs structural editing. A status update or factual explanation can serve its reader without taking a contestable position.

## When to invoke

User pastes text and asks to clean it up, flags something as sounding like AI or ChatGPT, asks for "tells" to be removed, or asks for general humanizing of a paragraph, email, blog post, doc, or message.

## Workflow

1. **Hard-tell scan.** Grep for deterministic markers:
   ```bash
   grep -nE 'utm_source=(chatgpt|openai|copilot)|referrer=grok\.com|:contentReference|oai_citation|turn0(search|image|news|file)|grok_render_citation|grok-card|attached_file:[0-9]|attributableIndex|【[0-9]+†|20[0-9]{2}-XX-XX' <file>
   ```
   Also in every pass, EN and NO, the two reply-shaped greps that hit nearly every
   model-drafted text and whose fix is deletion (see Reply-shaped tells in
   [references/tells.md](references/tells.md)):
   ```bash
   # Tie-back (closing by looping to the question) and compulsive counting
   grep -niE "to (answer|come back to|bring it back to) (your|the) question|in short, this gives|for å (svare|komme tilbake) (på|til) spørsmålet|kort (sagt|oppsummert)|\b(for|there are|here are) (two|three|four|five) (reasons|things|ways|points|parts)\b|\bav (to|tre|fire) grunner\b" <file>
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

2. **Triage.** Read against [references/tells.md](references/tells.md), including its Reply-shaped tells section and its Currency table (weight `new` and `rising` hits above `fading` ones; a text that trips only fading tells is not evidence of a current model), and classify each candidate change by risk tier (see [references/risk-tiers.md](references/risk-tiers.md)):
   - **Tier 1** (mechanical, low risk): apply silently, then compare with the original. Em dashes, curly quotes, hard-tell markers, placeholder text.
   - **Tier 2** (low-risk swaps): apply, then mention in the closing summary. AI vocab swaps, didactic disclaimers, superficial tails, weasel attributions, copulative restoration.
   - **Tier 3** (could change tone, meaning, voice, or structure): resolve intent under step 4.

3. **Apply Tier 1 and Tier 2.** Use patterns from [references/rewrite-patterns.md](references/rewrite-patterns.md). Work category by category.

4. **Resolve Tier 3 decisions.** Follow authority the user already gave. When intent remains unclear, use the available question tool or ask in chat before changing the passage. Cap at 3-4 questions per document; batch further decisions. Continue independent edits while awaiting answers.

5. **Edit for the reader (prose only, where needed).** Use [references/rewrite-toward-human.md](references/rewrite-toward-human.md) for structural and voice edits. Structural changes can alter emphasis or meaning even without adding facts. Apply changes within the user's instructions and compare them with the original. For content and voice, use only supplied material. Skip this pass when the text already serves its reader.

6. **Compare and score (skip scoring short messages and terse factual text).** Compare every rewrite with the original for changes in certainty, scope, attribution, and emphasis. Restore any unintended change. Score prose 1 to 5 on these axes; an axis below 3 gets one revision pass.

   | Axis | What you are scoring | 1 | 5 |
   |---|---|---|---|
   | **Fidelity** | Does it preserve the author's meaning and confidence? | Claims, qualifications, or emphasis changed | Intended meaning and confidence preserved |
   | **Usefulness** | Can the intended reader understand or act on it? | Purpose or needed information is unclear | The text serves its reader's purpose |
   | **Economy** | Does each passage contribute something needed? | Repetition and filler waste attention | Each passage earns its reading time |
   | **Register** | Does it still sound like the register it arrived in? | A formal memo now reads breezy, or voice markers got flattened as tells | Same register, AI accent gone |

   Check position when the genre needs an argument, and specifics when the reader needs evidence. If a needed fact, decision, or rationale is missing, name the exact gap in the editorial note, outside the draft. Preserve unresolved questions and genuine uncertainty. The author supplies missing thinking.

   Word count is a signal, not a ceiling. Prefer deletions and replacements; allow a short clarification supported by the original when it saves reader effort. See the editing research and Clay's author-responsibility policy in [references/sources.md](references/sources.md).

   **Stopping rule: at most two passes.** If a needed fact or decision still blocks usefulness, return the faithful draft and identify the gap. If an edit cannot preserve meaning, restore the original passage and explain the unresolved issue.

7. **Re-scan.** Re-run the greps. Remove hard-tell artifacts; judge style hits in context. Keep legitimate wording that survived the fidelity check.

## Output

Return the rewritten text. End with a brief editorial note: Tier 1 and Tier 2 fix counts, material structural changes, and unresolved Tier 3 passages with reasons. Put missing facts, decisions, or rationale here, outside the draft. Identify passages needing the author's judgment without claiming their endorsement of the rewrite.

Where you scored (step 6), stamp the axes on one line: `Score: Fidelity 5 · Usefulness 4 · Economy 5 · Register 5`. If the stopping rule fired, identify the gap or restored passage.

If the text was already clean, say so and return it unchanged. Do not invent tells to justify edits.

## Rules

- Preserve facts, argument, and intent. Structure and wording affect what readers understand; use the comparison in step 6 to check edits.
- Every sentence you write new during a rewrite is generated under `writing-whip`. A rewrite that trades an em dash for a tie-back or a self-answered question has moved the tell, not removed it.
- Default to deletion and replacement. Never invent facts, numbers, sources, quotes, anecdotes, or opinions. Use supplied material for clarification; report content gaps outside the draft.
- **Rewrite at the register, not the phrase.** The greps are a detector; they are not the rewrite instruction. Em dashes, emphatic colons, punchy fragments and the Claude-era phrase list are four surfaces of one behaviour: sentences built to land rather than to state (see Turn-of-phrase optimization in [references/tells.md](references/tells.md)). Fix each hit individually and the behaviour moves into unlisted synonyms. State what the prose should do instead ("claim first, qualification after"), then use the greps to catch residue. This applies to instructions you write for a model as much as to prose you edit: enumerating banned tokens is measurably weaker than naming the register, and a long ban list degrades compliance rather than improving it.
- Replace em dashes with two sentences, a comma, or parentheses. Do not swap them for colons by default: the colon-instead-of-em-dash habit produces the emphatic-colon tell, and the author's standing preference is full sentences. A colon earns its place only before a genuine list or a quotation. Never preserve the em dash itself.
- Replace curly quotes and apostrophes with straight ASCII (`"`, `'`).
- Leave useful sentences alone. Edit identifiable tells or obstacles to the reader's understanding.
- **Humanizing is not casualizing.** A condolence note, a board memo, a legal letter and a group chat are all human, and none of them sound alike. Strip the AI accent from whatever register the text is already in; do not drag formal writing toward breezy startup voice, and do not add contractions or fragments to a register that was formal on purpose. If the register itself seems wrong for the audience, say so instead of silently changing it.
- **Don't overcorrect.** Every rule here describes taste, not a checklist to satisfy. The failure mode on the other side is real: every sentence punchy, every paragraph one line, forced fragments, inserted slang, a useful word avoided because it appears on a list. Do not swing so far that the output reads as an AI performing humanness. The test is whether a person would plausibly have written this, not whether it avoids the most tells. If a rewrite feels forced, keep the plainer original.
- Norwegian text: preserve æ, ø, å. Apply the same tells taxonomy (calques translate). On Norwegian text, always run the Norwegian negative-parallelism grep from the ad-hoc list in the same pass as the English one, since "ikke bare X, men Y" is the same setup-payoff move and hides from the English pattern.
- When meaning, tone, or voice remains uncertain, follow step 4. Preserve the original passage until the author's intent is clear.

## Related skills

Invoke these skills where supported; otherwise read their SKILL.md. Follow the links below, or resolve names in project skills, then `~/.agents/skills/`. Load them before continuing.

- `writing-whip`: invoke it before writing any replacement sentence. This file catches what was written; the whip stops the same behaviours at generation, so a rewrite done under it cannot put a tie-back or a self-answered question where the em dash used to be. Its Behaviours list and the Reply-shaped tells section here describe the same moves from the two sides.
- [write-in-my-voice](../write-in-my-voice/SKILL.md): invoke it first whenever the text is Magnus's own (he says so, or the register and the æ/ø/å make it plain). It names the voice markers this skill must leave alone: a real rule of three, rhetorical questions, second-person "du", parenthetical glosses of English terms, sparing intensifiers. Without it loaded those get flattened as tells. It calls this skill narrowly in return: em dashes, the emphatic colon, slop vocabulary, didactic disclaimers, clustered negative parallelism.

## Ad-hoc greps for specific tells

When checking a long doc for one category at a time. Exception: the emphatic/appositive-colon grep below is not ad-hoc - it runs in step 1 on every pass:

```bash
# AI vocabulary (GPT-4 era + newer additions)
grep -niE '\b(delve|underscore|tapestry|vibrant|pivotal|robust|meticulous|crucial|testament|bolster|garner|interplay|intricate|enduring|landscape|certainly|utilize|streamline|harness|paradigm|synergy|ecosystem)\b' <file>

# Claude-era phrases (2026+). Opus 5 and Fable 5 lineages; see tells.md for which is which.
# These are surface residue of the turn-of-phrase register - fix the register first, then re-run this.
grep -niE '\b(carry the argument|worth stating plainly|stated fairly|load-bearing|gated|key insight|full stop\.|the [a-z]+ matters more)\b|, and the trap' <file>

# Reply-shaped tells (tropes.fyi 2026: reasoning leak, preamble announcers, counting, tie-back). Fix is deletion.
grep -niE "\bI (want|should|need) to be (clear|exact|precise|honest|careful) (about|here|that)|^(Two|Three|Four|Several) [a-z]+ (shape|drive|matter|are worth|follow)\b|the more important point is|\b(for|there are|here are) (two|three|four|five) (reasons|things|ways|points|parts)\b|to (answer|come back to|bring it back to) (your|the) question|in short, this gives" <file>

# Comma-clipped trailing phrase (low precision: a one-word tail after a comma at sentence end)
grep -nE ', [a-z]+\.$' <file>

# Appeal to familiarity
grep -niE '\b(a classic|famously|notoriously|as we all know|as everyone knows|it is well known that|needless to say)\b' <file>

# Wh-word headings
grep -nE '^#+ (What|Where|Why|How|When)\b' <file>

# "Where it actually lives"
grep -niE 'where ([a-z]+ ){0,3}(actually|really) (lives|sits|happens)|where the real (work|value) (happens|sits|is)' <file>

# Hyphen-stacked compounds and arrow chains (Fable 5; also generic agent shorthand leaking into prose).
# Low precision: legitimate triples exist (state-of-the-art, out-of-the-box). Judge each; weigh by density.
grep -nE '[[:alpha:]]+-[[:alpha:]]+-[[:alpha:]]+|→' <file>

# Magic adverbs (lower precision, weigh by density)
grep -niE '\b(quietly|deeply|fundamentally|remarkably|arguably|profoundly)\b' <file>

# Negative parallelisms (incl. causal variant)
grep -niE "not (just|only|merely|because) .{1,60}\b(but|it'?s|because)\b" <file>

# Negative parallelisms, Norwegian calques ("ikke bare X, men Y" and kin; judge each; a contrast doing real work stays, the setup-payoff reflex goes)
grep -niE 'ikke (bare|kun|utelukkende|nødvendigvis) .{1,60}\b(men|samt)\b|er ikke (bare )?et spørsmål om|handler ikke (bare )?om|ikke fordi .{1,60}\bmen fordi\b' <file>

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
