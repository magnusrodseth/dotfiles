# Contextual scans

Use these to locate candidates, then inspect their meaning. Matches are not an authorship
verdict or an instruction to delete. Work on the requested file; do not scan an entire
repository by default. Inspect pasted prose directly if it has no file.

Always check citation artifacts, reply-shaped scaffolding and emphatic colons. For Norwegian,
run both language patterns for negative parallelism. Apply only changes within requested scope.
Preserve exact quotations, code, identifiers and useful technical terms. Re-scan after the
last edit; retained legitimate matches do not fail the review.

```bash
# Artifact candidates; preserve evidence when fixing their presentation.
rg -n 'utm_source=(chatgpt|openai|copilot)|referrer=grok\.com|:contentReference|oai_citation|turn[0-9]+(search|image|news|file)|grok_render_citation|grok-card|attached_file:[0-9]|attributableIndex|【[0-9]+†|20[0-9]{2}-XX-XX' <file>

# Reply-shaped English and Norwegian candidates.
rg -ni "to (answer|come back to|bring it back to) (your|the) question|in short, this gives|for å (svare|komme tilbake) (på|til) spørsmålet|kort (sagt|oppsummert)|\b(for|there are|here are) (two|three|four|five) (reasons|things|ways|points|parts)\b|\bav (to|tre|fire) grunner\b" <file>
```

The remaining scans are optional by category, except the colon scan, which runs on every
pass. Review the candidates; a real list, quotation or useful label earns its colon.

```bash
# AI vocabulary (GPT-4 era + newer additions)
rg -ni '\b(delve|underscore|tapestry|vibrant|pivotal|robust|meticulous|crucial|testament|bolster|garner|interplay|intricate|enduring|landscape|certainly|utilize|streamline|harness|paradigm|synergy|ecosystem)\b' <file>

# Observed phrases from the 2026 taxonomy; these do not identify a model or author.
# These are surface residue of the turn-of-phrase register - fix the register first, then re-run this.
rg -ni '\b(carry the argument|worth stating plainly|stated fairly|load-bearing|gated|key insight|full stop\.|the [a-z]+ matters more)\b|, and the trap' <file>

# Reply-shaped candidates. Delete only setup that adds no needed information.
rg -ni "\bI (want|should|need) to be (clear|exact|precise|honest|careful) (about|here|that)|^(Two|Three|Four|Several) [a-z]+ (shape|drive|matter|are worth|follow)\b|the more important point is|\b(for|there are|here are) (two|three|four|five) (reasons|things|ways|points|parts)\b|to (answer|come back to|bring it back to) (your|the) question|in short, this gives" <file>

# Comma-clipped trailing phrase (low precision: a one-word tail after a comma at sentence end)
rg -n ', [a-z]+\.$' <file>

# Appeal to familiarity
rg -ni '\b(a classic|famously|notoriously|as we all know|as everyone knows|it is well known that|needless to say)\b' <file>

# Wh-word headings
rg -n '^#+ (What|Where|Why|How|When)\b' <file>

# "Where it actually lives"
rg -ni 'where ([a-z]+ ){0,3}(actually|really) (lives|sits|happens)|where the real (work|value) (happens|sits|is)' <file>

# Hyphen-stacked compounds and arrow chains. Preserve correct terms and notation.
# Low precision: legitimate triples exist (state-of-the-art, out-of-the-box). Judge each; weigh by density.
rg -n '[[:alpha:]]+-[[:alpha:]]+-[[:alpha:]]+|→' <file>

# Magic adverbs (lower precision, weigh by density)
rg -ni '\b(quietly|deeply|fundamentally|remarkably|arguably|profoundly)\b' <file>

# Negative parallelisms (incl. causal variant)
rg -ni "not (just|only|merely|because) .{1,60}\b(but|it'?s|because)\b" <file>

# Negative parallelisms, Norwegian calques ("ikke bare X, men Y" and kin; judge each; a contrast doing real work stays, the setup-payoff reflex goes)
rg -ni 'ikke (bare|kun|utelukkende|nødvendigvis) .{1,60}\b(men|samt)\b|er ikke (bare )?et spørsmål om|handler ikke (bare )?om|ikke fordi .{1,60}\bmen fordi\b' <file>

# Softened reframes (same setup-payoff move with the "not" dissolved; low precision, judge each)
rg -ni "(while|although|sure,|at first glance|on the surface|most people (think|assume)|conventional wisdom|everyone talks about).{0,80}\b(but|yet|actually|really|instead|rather|ultimately|in reality|the truth is|what matters is)\b" <file>

# Product-marketing vocabulary (decorative use only; keep the correct technical term)
rg -ni '\b(seamless|unlock|empower|elevate|supercharge|frictionless|effortless|game-changer|revolutioniz(e|es|ed|ing)|cutting-edge|state-of-the-art|best-in-class|groundbreaking|unparalleled|unprecedented|transformative|disruptive|reimagine|redefine|democratize|turnkey|plug-and-play|future-proof|holistic|mission-critical|embark|deep dive|look no further|rest assured)\b' <file>

# Craft-metaphor verbs for abstract work (low precision, weigh by density and literal sense)
rg -ni '\b(sanded down|bolted on|stripped back|stitched together|woven|carved out|baked in|distilled|crystalliz(e|ed|ing)|sharpened|surfaced|amplified|anchored|cemented|bridged|unpacked)\b' <file>

# Analogy setups (keep accurate explanations that help this reader)
rg -ni "it'?s (like|basically) a|picture (this|a)|works like a|acts like a|functions as a|the (backbone|engine|dna|north star|flywheel|plumbing) of|a (bridge|lens|roadmap) for" <file>

# Superficial analysis tails
rg -ni ', (highlighting|underscoring|emphasizing|reflecting|symbolizing|showcasing|fostering|ensuring|contributing to|cultivating)\b' <file>

# Didactic disclaimers + empty-emphasis openers
rg -ni "it'?s (important|crucial|worth) (to )?(note|remember|consider)|^(Importantly|Interestingly|Notably)," <file>

# Tone / rhetorical transitions
rg -ni "here'?s (the|what) (kicker|thing|deal|where|most)|let'?s (break|unpack|dive|explore)|think of it (as|like)|imagine a world where" <file>

# Rhetorical question-and-answer ("The X? A Y.")
rg -ni '\b[A-Z][a-z]+( [a-z]+){0,4}\? [A-Z][a-z]+\.' <file>

# False ranges
rg -ni '\bfrom [a-z]+ to [a-z]+\b' <file>

# Section summaries
rg -ni '^(In (summary|conclusion)|Overall),' <file>

# Puffery + grandiose stakes
rg -ni '\b(boasts|nestled|in the heart of|vibrant|rich tapestry|stands as|serves as|a testament to|reshape (how we|everything)|define the next era|changes everything)\b' <file>

# Unicode candidates. Protect code, formulas and meaningful notation.
rg -n '→|⇒|↔' <file>

# Emphatic / appositive colon (candidates only; judge each). Excludes URLs, image/alt lines, frontmatter keys, attributions, list intros, fixed openers.
rg -n '[[:alpha:]]+: [[:alpha:]]' <file> | rg -v 'https?://|!\[|^[0-9]+:(title|date|author|tags|description|draft|slug|type|created|aliases|status|related|source|linkedin_teaser):|Kilde:|Figure [0-9]|Figur [0-9]|For ordens skyld:|Konkret:|^[0-9]*: *[-*]'
```
