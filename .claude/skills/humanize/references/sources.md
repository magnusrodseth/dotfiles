# Sources

Where the guidance in this skill comes from. Two lineages: a detection taxonomy (what AI prose looks like) and a craft/measurement set (what human prose looks like, and how to move toward it).

## Detection taxonomy (tells.md)

- Wikipedia, "Signs of AI writing" (WikiProject AI Cleanup field guide). GPT-4-era vocabulary and citation artifacts.
- tropes.fyi by ossama.is (https://tropes.fyi). The newer structural and tonal tells: rhetorical question-and-answer, anaphora, short-fragment paragraphs, false vulnerability, pedagogical voice, invented concept labels, dead metaphor, historical analogy stacking. Full taxonomy at https://tropes.fyi/tropes-md.

## Positive direction: writing craft (rewrite-toward-human.md, Group A and the "one principle")

High-confidence, verifiable:

- George Orwell, "Politics and the English Language" (the six rules; concrete over abstract; cut words; active voice). https://www.orwellfoundation.com/the-orwell-foundation/orwell/essays-and-other-works/politics-and-the-english-language/
- Strunk & White, *The Elements of Style* (Rule 14 active voice, Rule 16 definite/specific/concrete, Rule 17 omit needless words).
- William Zinsser, *On Writing Well* (clutter: every word that serves no function).
- Stephen King, *On Writing* (second draft = first draft minus 10 percent; the road to hell is paved with adverbs).
- Verlyn Klinkenborg, *Several Short Sentences About Writing* (sentence-length variety and rhythm).
- Gopen & Swan, "The Science of Scientific Writing," *American Scientist* (1990). Stress position, old-to-new information flow, action-in-the-verb. https://www.crowl.org/Lawrence/writing/GopenSwan90.html
- Paul Graham, "Writing, Briefly" (https://paulgraham.com/writing44.html) and "Write Simply" (https://paulgraham.com/simply.html). Short Germanic words; write like you talk.
- Oxide Computer, "LLMs as writers," RFD 576. The reader-writer social contract; prose as the trace of real understanding. https://rfd.shared.oxide.computer/rfd/0576

## Positive direction: detection / stylometry research (rewrite-toward-human.md, self-check metrics)

High-confidence, verifiable:

- GPTZero, "What is perplexity and burstiness." https://gptzero.me/news/perplexity-and-burstiness-what-is-it/
- Muñoz-Ortiz et al., "Contrasting Linguistic Patterns in Human- and LLM-Generated News Text," arXiv:2308.09067. Sentence-length scatter, noun/adjective density, emotion distribution.
- Kobak et al., "Delving into LLM-assisted writing in biomedical publications through excess vocabulary." Published in *Science Advances* (2025), doi:10.1126/sciadv.adt3813; preprint arXiv:2406.07016. 15M PubMed abstracts 2010-2024; at least 13.5% of 2024 abstracts LLM-processed, up to 40% in some subcorpora. Establishes that excess vocabulary is measurable and **era-specific**, which is why the vocabulary list in [tells.md](tells.md) is split by model generation.
  **Do not transplant its word list.** The published set (`results/excess_words.csv`, github.com/berenslab/llm-excess-vocab) has 900 words, 407 tagged "style", but those are excess *in biomedical abstracts under GPT-3.5/4-era editing*. It includes `across`, `both`, `this`, `these`, `were`, `within`, `during`, `however`, `like`. Checked against this skill's vocabulary greps in August 2026: it corroborates the existing GPT-4-era layer and adds nothing usable for 2026 Claude-era prose.
- Sadoski & Paivio, concreteness effect on comprehension and recall (dual coding). ERIC EJ466317.
- Russell et al., "StoryScope: Investigating idiosyncrasies in AI fiction," arXiv:2604.03136 (2026). Discourse-level narrative features (theme explicitness, embodied vs. named emotion, allusion specificity, structural tidiness, temporal complexity) separate AI from human writing at 93% macro-F1 with style withheld, and survive surface artifact removal (the LAMP edit) with only a 1.6-point drop. The empirical basis for this skill's claim that AI-ness is structural, not just lexical: backs the discourse-level tells in [tells.md](tells.md) and the "trace of a mind that took a position" principle in [rewrite-toward-human.md](rewrite-toward-human.md).

## Steering: why the rewrite targets the register, not the phrase list

Basis for the "Rewrite at the register, not the phrase" rule in [SKILL.md](../SKILL.md) and the Turn-of-phrase optimization tell in [tells.md](tells.md). Researched August 2026.

- Anthropic, "Prompting Claude Opus 5" (platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5). Vendor-primary, and self-critical rather than promotional. Confirms Opus 5 responses "run longer than prior Opus models'." Two directly relevant statements: *"Positive examples of the communication style you want tend to be more effective than instructions about what not to do"*, and, on suppressing leaked XML tags, *"Instructions that call out thinking tags by name are less effective than the general form, so avoid naming them specifically."* Also reports that a rule telling the model not to reason **increases** the leakage it was meant to prevent.
- Anthropic, "Prompting Claude Fable 5" (same path, `prompting-claude-fable-5`). *"Instruction-following is improved enough that you can steer most behaviors with a brief instruction rather than enumerating each behavior by name... A short brevity instruction is as effective as listing each pattern."* Also warns that skills written for earlier models are *"often too prescriptive... and can degrade output quality"*, which is the direct argument against growing this skill's ban lists further.
- Instruction-dilution literature: compliance falls as the number of simultaneous constraints grows, and mid-prompt constraints are the first to be dropped. Read via secondary summaries only, not the primary papers. Treat as directional.

Counter-evidence, recorded because it is real and this file should not read as settled:

- Few-shot exemplars carry their own cost. StyleAdaptedLM (arXiv:2507.18294) reports that extensive few-shot examples degrade instruction-following; example-based style transfer (STYLL) lags badly on meaning preservation. So "use positive examples" is not a free win over enumeration, it trades one failure mode for another.
- The popular "pink elephant" claim (telling a model *not* to do X makes X more likely, in general) is **not** established. The most-cited write-up of it is built on Reddit anecdotes with no measurements, and says so itself. The narrow, vendor-measured version above is the only part that holds.

Net position: enumeration is fine for **detection** (the greps), weak for **generation and rewriting** (the instructions). That asymmetry is why this skill keeps long grep lists but tells you to rewrite at the register.

The web research pass also surfaced several 2024-2026 arXiv papers on lexical diversity, stance/engagement, markdown fingerprints, and synthetic lived experience. Those informed the metrics but were not all independently verified. Verify any specific arXiv ID before citing it in published work; the durable findings (burstiness, concreteness, stance variety, voice) are corroborated across the high-confidence sources above.
