# AI tells taxonomy

Patterns that indicate AI-generated prose. Source: Wikipedia's "Signs of AI writing" field guide, filtered to general prose (Wikipedia-specific wikitext/AfC tells dropped).

One or two of these in a passage is coincidence. Clusters across multiple categories are signal.

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
"Not X, but Y" / "Not just X, but also Y" / "It's not X, it's Y". Setup-payoff cadence that mimics punched-up sales writing.

Examples:
- "This isn't just a meme, it's a celebration of..."
- "Not a career, not a body of work, just an algorithmic moment."
- "The issue here isn't sourcing, it's framing."

### Rule of three
Triplets everywhere. Three adjectives, three short phrases, three bullets. Used to make superficial analyses sound comprehensive.

Examples:
- "engaging, repetitive, and entertaining"
- "identity, authenticity, and what it means to live on"
- "construction, renovation, hobby and craft, automotive"

### Outline-style "Challenges and Future" sections
Rigid formula: "Despite its [positives], X faces several challenges, including..." closing with "Despite these challenges, X continues to thrive..." or "Future investments could enhance...". Pure filler.

### Knowledge-cutoff / speculation hedges
The model admitting it doesn't know, then guessing anyway.

Watch for: *as of my last knowledge update, up to my last training update, while specific details are limited, not widely documented/disclosed, based on available information, in the available sources, likely supports, maintains a low profile, keeps personal details private.*

### Didactic disclaimers (older models, 2022–2024)
Unprompted advice to an imagined reader.

Watch for: *it's important/critical/crucial to note, worth noting, may vary depending on, it is crucial to differentiate, please consult.*

## Language tells

### AI vocabulary
Specific words overused by LLMs. Density matters: one is coincidence, five across a paragraph is signal.

**GPT-4 era (2023 to mid-2024):** Additionally (sentence-initial), boasts (meaning "has"), bolstered, crucial, delve, emphasizing, enduring, garner, intricate/intricacies, interplay, key (adj.), landscape (abstract), meticulous/meticulously, pivotal, underscore, tapestry, testament, valuable, vibrant.

**GPT-4o era (mid-2024 to mid-2025):** align with, bolstered, crucial, emphasizing, enhance, enduring, fostering, highlighting, pivotal, showcasing, underscore, vibrant.

**GPT-5 era (mid-2025+):** emphasizing, enhance, highlighting, showcasing, plus heavy "media coverage / attribution" language.

**Robust** is era-spanning. So is **leverage** (as a verb).

### Copulative avoidance
LLMs swap "is/are" for fancier alternatives.

Watch for: *serves as, stands as, marks, represents, constitutes, features, offers, boasts, maintains, refers to* (in lead sentences where "is" would be natural).

Tell: "X serves as a hub" instead of "X is a hub". "The gallery features four spaces" instead of "The gallery has four spaces".

### Lexical elegant variation
Repetition-penalty avoidance. Same concept referred to by 3+ different phrasings within a paragraph, even when repetition would be clearer.

Example: a paragraph that calls one thing "Soviet artistic constraints", then "state-imposed artistic norms", then "the confines of socialist realism", all within a few sentences.

### "Concrete" as a defensive tic
When defending text against AI accusations, models lean on "concrete": "no concrete evidence", "without concrete examples". Specific to defensive contexts.

## Style and markup tells

### Em dashes (—)
LLMs overuse em dashes, especially in places where a human would pick a comma, parentheses, or a colon. Pat, formulaic, sales-y cadence.

A few em dashes in long-form essay writing is normal. Dense em-dash use in short-form text (emails, comments, short paragraphs) is a strong signal, especially when combined with negative parallelisms.

### Curly quotes and apostrophes
`"..."`, `'...'`, `'` (right single quote as apostrophe). ChatGPT and DeepSeek output curlies by default. Claude and Gemini don't.

Caveats: macOS smart-quotes setting, Microsoft Word, Chicago Manual of Style typesetting all produce curlies legitimately. Treat as supporting evidence only, except in technical or casual contexts where curlies would be unusual.

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
