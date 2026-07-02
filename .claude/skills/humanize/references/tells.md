# AI tells taxonomy

Patterns that indicate AI-generated prose. Two sources: Wikipedia's "Signs of AI writing" field guide (strong on GPT-4-era vocabulary and citation artifacts), filtered to general prose; and tropes.fyi (strong on the newer structural and tonal tells that survive a vocab scrub).

One or two of these in a passage is coincidence. Clusters across multiple categories are signal. The vocabulary and citation tells are high-precision; the rhetorical, tonal, and short-fragment tells are lower-precision (a human might do any one deliberately), so weigh them by density and prefer to ask before rewriting voice.

## Content tells

### Puffery / undue significance
Inflating the importance of mundane subjects. Adding statements that the topic "represents", "marks", "contributes to" some broader trend.

Watch for: *stands as, serves as, is a testament to, plays a vital/significant/crucial/pivotal/key role, underscores/highlights its importance, reflects broader, symbolizing its ongoing/enduring/lasting, contributing to, setting the stage for, marking/shaping the, represents/marks a shift, key turning point, evolving landscape, focal point, indelible mark, deeply rooted, boasts a, nestled, in the heart of, groundbreaking, renowned, diverse array, rich cultural heritage.*

### Superficial analysis tails
Sentences ending with a present-participle phrase that adds vague significance. Often attached to neutral facts to puff them up.

Watch for sentence endings like: *..., highlighting X. ..., underscoring X. ..., emphasizing X. ..., reflecting X. ..., symbolizing X. ..., contributing to X. ..., fostering X. ..., showcasing X. ..., ensuring X. ..., cultivating X.*

### Weasel attributions
Vague authorities cited instead of specific sources. Single sources presented as widespread consensus.

Watch for: *Industry reports, observers have cited, experts argue, some critics argue, scholars have noted, researchers treat X as, several sources/publications (when only one or two are present), it is widely understood, is described in scholarship as.*

### Negative parallelisms
"Not X, but Y" / "Not just X, but also Y" / "It's not X, it's Y". Setup-payoff cadence that mimics punched-up sales writing. AI uses it to manufacture false profundity by framing every point as a surprising reframe. One per piece can land; ten is an insult to the reader.

Examples:
- "This isn't just a meme, it's a celebration of..."
- "Not a career, not a body of work, just an algorithmic moment."
- "The issue here isn't sourcing, it's framing."

Variants to catch:
- **Causal:** "not because X, but because Y" (every explanation framed as a surprise reveal).
- **Em-dash dismissal:** "X, not Y" ("It's backwards, not bold").
- **Cross-sentence reframe:** the same noun negated then repositioned across two sentences. "The question isn't X. The question is Y."

### Dramatic countdown ("Not X. Not Y. Just Z.")
Negating two or more things in staccato before revealing the "real" one. Builds false tension and a false sense of narrowing to the truth. A cousin of negative parallelism and rule-of-three, but distinctive enough to name.

Examples:
- "Not a bug. Not a feature. A fundamental design flaw."
- "Not ten. Not fifty. Five hundred and twenty-three violations."

### Rhetorical question-and-answer ("The X? A Y.")
A question nobody asked, posed and immediately answered for dramatic effect. The model treats this as the height of punchy writing.

Examples:
- "The result? Devastating."
- "The worst part? Nobody saw it coming."
- "So what changed? Everything."

### Rule of three
Triplets everywhere. Three adjectives, three short phrases, three bullets. Used to make superficial analyses sound comprehensive.

Examples:
- "engaging, repetitive, and entertaining"
- "identity, authenticity, and what it means to live on"
- "construction, renovation, hobby and craft, automotive"

### Anaphora abuse
The same sentence opening repeated in quick succession. One deliberate anaphora is a rhetorical device; three or four back-to-back is a pattern-generation tic.

Examples:
- "They assume users will pay. They assume developers will build. They assume ecosystems will emerge."
- "They have built engines, but not vehicles. They have built power, but not leverage."

### False ranges ("from X to Y")
"From X to Y" where X and Y aren't endpoints of any real scale, so there's no meaningful middle. Legitimate ranges imply a spectrum ("from novice to expert"). AI uses the frame to dress up a list of two loosely related things.

Examples:
- "From innovation to cultural transformation."
- "From the Big Bang to the cosmic web."
- Tell: ask "what's in the middle?" If nothing, it's a false range.

### Outline-style "Challenges and Future" sections
Rigid formula: "Despite its [positives], X faces several challenges, including..." closing with "Despite these challenges, X continues to thrive..." or "Future investments could enhance...". Pure filler.

### Knowledge-cutoff / speculation hedges
The model admitting it doesn't know, then guessing anyway.

Watch for: *as of my last knowledge update, up to my last training update, while specific details are limited, not widely documented/disclosed, based on available information, in the available sources, likely supports, maintains a low profile, keeps personal details private.*

### Didactic disclaimers (older models, 2022–2024)
Unprompted advice to an imagined reader.

Watch for: *it's important/critical/crucial to note, worth noting, it bears mentioning, may vary depending on, it is crucial to differentiate, please consult.* Also the empty-emphasis openers *Importantly, Interestingly, Notably* when they introduce a point without connecting it to the argument.

## Rhetorical and tone tells

Newer models (mid-2024 onward) lean less on flagged vocabulary and more on rhetorical posture. These are the tells that survive a vocab scrub. Most are lower-precision than the citation/vocab tells: a human might do any one deliberately, so weigh density and ask before rewriting voice.

### False suspense transitions
Promising a revelation, then delivering an ordinary point. Manufactured drama.

Watch for: *Here's the kicker, Here's the thing, Here's where it gets interesting, Here's what most people miss, Here's the deal.*

### Patronizing analogy
Reaching for a simplifying metaphor the reader didn't need. The model defaults to teacher mode and assumes a metaphor is always clarifying (often it's less clear than the plain statement).

Watch for: *Think of it as..., Think of it like..., It's like a... (for X), It's basically a...*

### Futurism invitation
Selling an argument by asking the reader to picture a wonderful hypothetical, usually followed by a list of good things that happen if you accept the premise.

Watch for: *Imagine a world where..., Imagine if..., Picture this:..., In that world, ...*

### Pedagogical voice
Hand-holding an audience that doesn't need it, even in expert writing. Announces the act of explaining.

Watch for: *Let's break this down, Let's unpack this, Let's dive in, Let's explore, step by step.*

### Asserting obviousness instead of proving it
Telling the reader a point is clear, simple, or unambiguous in place of demonstrating it. If you have to say it's obvious, it usually isn't. Includes the "privileged insight" reveal: "but none of that is the real story. The real story is..."

Watch for: *The truth is simple, The reality is (simpler/starker), History is clear/unambiguous, It's obvious that, Make no mistake.*

### False vulnerability
Performed self-awareness or confession that costs the writer nothing. Real vulnerability is specific and uncomfortable; the AI version is polished and risk-free.

Watch for: *And yes, I'll admit..., Let's be honest..., since we're being honest..., This isn't a rant, it's a...*

### Grandiose stakes inflation
Inflating the stakes of an ordinary argument to world-historical significance. A post about API pricing becomes a meditation on the future of civilization. Related to puffery, but about consequence rather than importance.

Watch for: *will fundamentally reshape everything, will define the next era of, changes everything, something entirely new, the future of X depends on.*

### Invented concept labels
Coining an authoritative-sounding compound term and using it as if it were an established, defined concept. Usually an abstract problem-noun (paradox, trap, creep, divide, vacuum, inversion) bolted to a domain word. Names the thing to skip the argument. Several in one piece is a strong signal.

Examples: *"the supervision paradox", "the acceleration trap", "workload creep".*

## Language tells

### AI vocabulary
Specific words overused by LLMs. Density matters: one is coincidence, five across a paragraph is signal.

**GPT-4 era (2023 to mid-2024):** Additionally (sentence-initial), boasts (meaning "has"), bolstered, crucial, delve, emphasizing, enduring, garner, intricate/intricacies, interplay, key (adj.), landscape (abstract), meticulous/meticulously, pivotal, underscore, tapestry, testament, valuable, vibrant.

**GPT-4o era (mid-2024 to mid-2025):** align with, bolstered, crucial, emphasizing, enhance, enduring, fostering, highlighting, pivotal, showcasing, underscore, vibrant.

**GPT-5 era (mid-2025+):** emphasizing, enhance, highlighting, showcasing, plus heavy "media coverage / attribution" language.

**Robust** is era-spanning. So is **leverage** (as a verb).

**Also era-spanning:** certainly, utilize, streamline, harness, paradigm, synergy, ecosystem, framework (when used as a vague abstraction rather than a named thing).

### Magic adverbs
An adverb dropped in to make a mundane claim feel significant or subtly powerful. "Quietly" is the flagship. The word implies hidden importance the sentence never earns.

Watch for: *quietly* (quietly orchestrating, quietly suffocating, a quiet intelligence behind it), *deeply, fundamentally, remarkably, arguably, profoundly, subtly.*

Lower precision than the vocab list. Humans use these too. Signal is density plus the "unearned significance" function: cut the adverb and the sentence usually says the same thing more honestly.

### Copulative avoidance
LLMs swap "is/are" for fancier alternatives.

Watch for: *serves as, stands as, marks, represents, constitutes, features, offers, boasts, maintains, refers to* (in lead sentences where "is" would be natural).

Tell: "X serves as a hub" instead of "X is a hub". "The gallery features four spaces" instead of "The gallery has four spaces".

### Lexical elegant variation
Repetition-penalty avoidance. Same concept referred to by 3+ different phrasings within a paragraph, even when repetition would be clearer.

Example: a paragraph that calls one thing "Soviet artistic constraints", then "state-imposed artistic norms", then "the confines of socialist realism", all within a few sentences.

### Dead metaphor (the opposite failure)
Latching onto one metaphor and beating it into the ground for a whole piece. A human introduces a metaphor, uses it, and moves on; AI repeats the same figure 5-10 times ("primitives", "walls and doors", "the ecosystem needs ecosystems"). Where elegant variation over-synonymizes, this over-repeats a single image.

### "Concrete" as a defensive tic
When defending text against AI accusations, models lean on "concrete": "no concrete evidence", "without concrete examples". Specific to defensive contexts.

## Style and markup tells

### Em dashes (—)
LLMs overuse em dashes, especially in places where a human would pick a comma, parentheses, or a colon. Pat, formulaic, sales-y cadence.

A few em dashes in long-form essay writing is normal. Dense em-dash use in short-form text (emails, comments, short paragraphs) is a strong signal, especially when combined with negative parallelisms.

### Curly quotes and apostrophes
`"..."`, `'...'`, `'` (right single quote as apostrophe). ChatGPT and DeepSeek output curlies by default. Claude and Gemini don't.

Caveats: macOS smart-quotes setting, Microsoft Word, Chicago Manual of Style typesetting all produce curlies legitimately. Treat as supporting evidence only, except in technical or casual contexts where curlies would be unusual.

### Unicode decoration (arrows and typed-out symbols)
Characters a person typing in a normal editor wouldn't reach for: unicode arrows (`→`, `⇒`, `↔`), and decorative symbols mid-prose. Claude in particular loves `→`. A human types `->` or rewrites the sentence. Replace `→` with "to", "leads to", "then", or restructure.

Watch for: *Input → Processing → Output*, *engagement → revenue → growth.*

### Title case in section headings
Capitalizing All Main Words In Headings. Common in AI output, against most style guides for sentence-case prose.

### Boldface overuse
Bolding **every** instance of a chosen phrase in a "key takeaways" pattern. Inherited from readme files, listicles, slide decks, sales pitches.

### Inline-header vertical lists
List items where the marker is followed by a bold inline header, colon, then descriptive text:
- **Standard Rotary Saws**: Typically used for drywall and light materials.
- **Heavy-Duty Rotary Saws**: Designed for tougher materials.

Strong signal when applied to topics that don't need this structure.

### Markdown leakage
Bare `**bold**`, `#` headings, `---` thematic breaks in text that should be plain prose (e.g. pasted into a CMS, email, or wiki that doesn't render Markdown).

Three-backtick fenced blocks in non-code contexts. Mixed Markdown and target-format syntax (Markdown plus wikitext, Markdown plus BBCode).

### Unnecessary tables
Three- or four-row tables that should be prose or a single sentence. Common pattern: "Market and Statistics" with one stat per row.

## Composition and structure tells

Document-level and paragraph-level patterns. These survive any word-level scrub, so they matter most on longer pieces.

### Short punchy fragments
Very short sentences or fragments used as standalone paragraphs for manufactured emphasis. One thought per line, no state to hold. RLHF pushed models toward this "writing for readability" style; almost nobody drafts this way, because it doesn't match how people think or speak.

Examples:
- "He published this. Openly. In a book. As a priest."
- "Platforms do."

Lower precision: punchy fragments are a legitimate human device. The tell is when a whole passage is built from them. Ask before flattening; it can be deliberate voice.

### Listicle in a trench coat
A list disguised as prose. Each point wrapped in a paragraph that opens "The first... The second... The third..." Often what a model does after being told to stop using bullet lists.

Examples:
- "The first wall is... The second wall is... The third wall is..."
- "The second takeaway is that... The third takeaway is that..."

### Fractal summaries
"Tell them what you'll tell them; tell them; tell them what you told you" applied at every level. Every subsection previews and recaps itself, every section does, the document does. Reads as template-following, not thinking. (The single "In conclusion" recap is the smaller version, see Section summaries.)

### One-point dilution
A single argument restated ten ways across thousands of words. The model pads a simple thesis to feel comprehensive, rephrasing the same idea with new metaphors and examples that add nothing. An 800-word point stretched to 4000.

### Content duplication
Whole sections or paragraphs repeated near-verbatim in one piece, a giveaway of unedited long-form output where the model lost track of what it already wrote. Rarer now, but a dead tell when present.

### Historical analogy stacking
Rapid-fire lists of companies or eras to borrow authority, common in tech writing. "Apple didn't build Uber. Facebook didn't build Spotify. Stripe didn't build Shopify." Or "every major shift, the web, mobile, social, cloud, followed the same pattern."

## Citation artifacts (hard tells)

These are near-proof of AI involvement. Grep for them.

- `utm_source=chatgpt.com` or `utm_source=openai` (ChatGPT)
- `utm_source=copilot.com` (Microsoft Copilot)
- `referrer=grok.com` (Grok)
- `:contentReference[oaicite:N]{index=N}` (ChatGPT bug)
- `oai_citation`, `[oai_citation:N‡...]`
- `turn0search0`, `turn0image0`, `turn0news0`, `turn0file0`
- `grok_render_citation_card_json`, `<grok-card data-id="...">`
- `[attached_file:1]`, `[web:1]` (Perplexity)
- Lenticular bracket markers: `【85†L261-269】`
- `({"attribution":{"attributableIndex":"X-Y"}})`
- Placeholder dates: `2025-XX-XX`, `2026-XX-XX`
- Placeholder URLs: `PASTE_URL_HERE`, `INSERT_SOURCE_URL_N`, `[link to ...]`
- DOIs that lead to unrelated articles, book citations without page numbers, broken external links clustered in one document.

## Communication tells (when humanizing emails, messages, comments)

### Canned good faith
"I am committed to...", "I assure you...", "my intention is to...", "I align with your values/mission/standards". Legalese formality applied to casual contexts.

### Canned offer to take feedback
"If there are specific areas you'd like me to address, I am happy to...", "I welcome any further input/guidance", "I would greatly appreciate your input".

### Canned redirect to content over conduct
"Let's focus on X instead of Y", "rather than [behavior], let's [content]". Used to dodge criticism.

### Subject lines in plain text
Messages that start with "Subject: ..." as if pasted from an email form.

### Section titles in plain text
Headings broken out as standalone capitalized lines in what should be flowing prose.

### Section summaries
Paragraphs starting with "In summary", "In conclusion", "Overall" when the surrounding context doesn't call for a recap.

### Emoji as section markers
🧠 🚨 🧭 📌 at the start of headings or bullets. Almost always AI in formal-ish contexts.

## What's NOT a tell

These get mistaken for AI signs but aren't reliable:

- Perfect grammar (many humans write well)
- Mixed casual/formal register (often indicates technical writers, code switchers, or neurodivergent voices)
- "Fancy" or formal prose (only specific words are overused, not formal prose generally)
- Letter-like formatting (predates LLMs)
- Single transition words like "Additionally" (overused only in clusters)
- Unsourced content (most of the web is unsourced)
- Em dashes alone (overused by AI, but also by many human writers)
- Curly quotes alone (macOS, Word, Chicago style)
