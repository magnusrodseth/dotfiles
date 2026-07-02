# Rewrite toward human

The rest of this skill is subtractive: find a tell, strip it. This file is the other direction. Once the tells are gone you can be left with prose that is clean but inert, correct but clearly machine-shaped. These are the moves that push it back toward how a person writes.

Sources: the writing-craft canon (Orwell, Strunk & White, Zinsser, King, Klinkenborg, Gopen & Swan, Paul Graham, Oxide Computer's "LLMs as writers") and the stylometry / AI-detection literature (GPTZero on perplexity and burstiness; Muñoz-Ortiz et al. on human vs. LLM news text; Kobak et al. on excess vocabulary). Specific citations and URLs are in [sources.md](sources.md); the durable findings are below.

## The one principle underneath all of it

Human prose is the trace of a mind that did the work and took a position. Oxide frames it as a social contract: the reader trusts that the writer undertook the greater intellectual effort. AI prose breaks that contract, so it reads as text nobody quite stood behind. Every move below is a tactic in service of one goal: make the prose reflect real understanding and a real stance. If a passage has no point of view, no move here can save it; that is a content problem, not a cadence problem.

Detection signals are also a moving target as human and machine writing coevolve. Do not chase one detector's score. Favor the durable moves: rhythm variance, concreteness, stance, and voice.

## Group A: structural moves (apply freely, they change cadence not content)

These restructure what is already there. They add no facts, so they stay inside "strip, don't embellish."

### Vary sentence length (burstiness)
The single strongest human signal in the detection literature. Machine prose clusters in a 10 to 25 word band; human prose alternates long, embedded sentences with very short ones. After any run of two sentences over ~20 words, force the next one under 8. Aim for a sentence-length spread (standard deviation) at least as large as the mean.

> Before: "The migration improved performance across all endpoints, and the team was pleased with the reduction in latency that followed the rollout."
> After: "The migration improved performance across every endpoint. Latency dropped by half. The team was relieved."

### Vary sentence openings
No two consecutive sentences should start with the same word or the same part of speech. Lead some sentences with a subordinate clause or a prepositional phrase instead of the subject.

> Before: "The system logs errors. The system retries failed jobs. The system alerts on-call."
> After: "The system logs errors. When a job fails, it retries twice. On-call only hears about it if both retries die."

### Cut academic transitions
Machines open with "Moreover / Furthermore / Additionally / In addition / It is important to note" at several times the human rate. Delete most of them and let the ideas sit next to each other. Juxtaposition carries the logic.

> Before: "Moreover, it is important to note that the API is rate-limited. Furthermore, this affects batch jobs."
> After: "The API is rate-limited. That breaks batch jobs."

### Restore the active voice with a real agent
Agentless passives ("mistakes were made", "gains were observed") dodge the doer. Name who did what.

> Before: "Improvements were implemented and gains were observed."
> After: "We rewrote the query and cut load time in half."

### Put the action in the verb (de-nominalize)
Machine prose stacks abstract nouns and buries the verb far from its subject. Turn the noun-action back into a verb and keep subject and verb close.

> Before: "The utilization of caching resulted in a reduction of latency."
> After: "Caching reduced latency."

### Land on the strongest word (stress position)
Readers emphasize whatever arrives at the end of a sentence. Move the point there. Never trail off into "...which is important for a variety of reasons."

> Before: "This change reduced error rates significantly in most cases."
> After: "This change cut the error rate to zero."

### Thread old to new
Start each sentence with something the reader already has; deliver the new part at the end; hook the next sentence to it. This makes a paragraph read as one continuous thought instead of a list of adjacent true statements.

> Before: "Latency dropped. A new cache was the reason. Users noticed."
> After: "Latency dropped because we added a cache. That cache is what users noticed first."

### Prefer short plain words over long Latinate ones
Swap the register down: use (not utilize), help (not facilitate), use (not leverage), about (not regarding), so (not thus). Plain words read as someone talking.

### Cut adverbs, upgrade the verb
Delete the "-ly" hedge or intensifier. If the sentence weakens, find a stronger verb instead of restoring the adverb.

> Before: "The service quickly and significantly improved."
> After: "The service went from ten seconds to one."

### Break rule-of-three and symmetric parallelism
Machines default to triads and matched clauses: rhythm without thought. Cut to two or push to four, and make the items different lengths.

> Before: "It's fast, reliable, and scalable."
> After: "It's fast and, once you're past the setup, genuinely reliable."

### Vary paragraph length; dissolve needless scaffolding
Even, parallel paragraphs and bold-lead bullet lists are their own fingerprint. Collapse a list back into prose where the structure isn't earning its keep, and let one very short paragraph sit among longer ones.

### State claims in positive form and take a position
Remove hedge stacks ("it could be argued that this may not be ineffective"). Turn "not X" into the positive claim. A verdict signals a real judgment was made. (See Group B for keeping genuine, varied hedging.)

> Before: "It could be argued that shorter subject lines may not be ineffective."
> After: "Short subject lines win. Keep them under eight words."

## Group B: content and voice moves (never fabricate, ask or flag instead)

These are what most separate human from machine prose, and they are also where the skill's core rule bites hardest: **do not invent facts, numbers, sources, anecdotes, or opinions the author did not supply.** A fabricated specific is worse than a bland abstraction. Use these to *reshape* specifics the author already has, or to *flag a gap* for the author to fill. Never to manufacture content.

### Concreteness and named specifics
The clearest human marker, and the most dangerous to fake. Replace abstract nouns (impact, solution, framework, dynamics) and vague quantifiers (many, significantly, over time) with the actual instance, figure, date, or named source.

> Before: "The solution delivered significant business impact."
> After (only if the author's material supports it): "The new checkout flow cut cart abandonment from 40% to 22%."

If the text does not contain the specific, do not invent one. Leave a marker or ask: "This sentence would land harder with a real number. What was the actual figure?" The detection literature warns that machines already sprinkle invented numbers to sound convincing; grounded specifics good, fabricated precision bad.

### First-person perspective and lived detail
Where the genre allows it, one first-person observation or short concrete anecdote does more than any amount of polish. Only if the author actually has it. Do not write an anecdote they did not live.

### Varied epistemic stance
Machines are either uniformly confident or flatly hedged. Humans modulate: a genuine "I'm not sure this holds under load" next to a blunt "for normal traffic this is the right call." Only reflect the author's real confidence; do not invent doubt or certainty.

### Emotional edge; drop relentless positivity
Human writing runs cooler and sometimes sharper: skeptical, irritated, flatly critical. Cut reflexive enthusiasm ("exciting potential", "worth celebrating") when it isn't the author's actual view. Only where it matches what they think.

### Controlled imperfection and idiolect
Grammatical pristineness is itself a tell. Allow contractions, an occasional deliberate fragment for emphasis, an opening "And" or "But." Keep it subtle, and don't override a formal register the author chose on purpose.

### One apt, unexpected word per passage
Machines pick the safest continuation, so phrasing is unsurprising. Reject the first collocation that comes to mind ("a sense of peace", "bubbled gently") and choose one specific, slightly unexpected, still-accurate alternative. Only where it doesn't distort meaning.

## Self-check on the rewrite

Measurable targets, not vibes. Run these against your rewritten text:

- Sentence-length standard deviation is roughly at least the mean. If every sentence is 12 to 25 words, add a short one and a long one.
- Near-zero "Moreover / Furthermore / Additionally / It is important to note" at paragraph and sentence starts.
- No two consecutive sentences share an opening word or part of speech.
- The concrete-and-named to abstract noun ratio went up, not down.
- First-person count is above zero where the genre permits it (and the author supplied the perspective).
- No "studies show / experts say / many companies" placeholders remain.

## Two standing caveats

1. **Specificity must be real.** The single fastest way to make prose read human is concrete, checkable detail, and the single worst failure is inventing it. When in doubt, flag the gap; never fabricate a statistic, source, quote, or anecdote.
2. **Don't game one detector.** Detection thresholds drift. Optimizing a single perplexity or burstiness score is brittle. The durable moves (variance, concreteness, stance, voice) are the point; the metrics are just how you check them.
