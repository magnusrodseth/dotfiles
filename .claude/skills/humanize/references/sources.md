# Sources

Where the guidance in this skill comes from. Two lineages: a detection taxonomy (what AI prose looks like) and a craft/measurement set (what human prose looks like, and how to move toward it).

## Detection taxonomy (tells.md)

- Wikipedia, "Signs of AI writing" (WikiProject AI Cleanup field guide). GPT-4-era vocabulary and citation artifacts.
- tropes.fyi by ossama.is (https://tropes.fyi). Snapshot taken 27.08.2026: 46 tropes, each tagged consistent / rising / new / fading; the tags feed the Currency table in [tells.md](tells.md). Contributes the structural and tonal tells (rhetorical question-and-answer, anaphora, short-fragment paragraphs, false vulnerability, pedagogical voice, invented concept labels, dead metaphor, historical analogy stacking) and the 2026 reply-shaped set (reasoning leak, premise stacking, preamble, compulsive counting, belaboring the unnecessary, tie-back, never-ending conclusion, comma-clipped trailing phrase, self-echo, quotable one-liners, appeal to familiarity, Wh-word headings, "where it actually lives", collaborative "we"). The same author ships the list as a generation-time skill, vendored here as `writing-whip` (Ossama Chaib, v0.1.0). Full taxonomy at https://tropes.fyi/tropes-md.

## Editing research: what people do when they rewrite machine text (rewrite-patterns.md)

Basis for the "What the editing research says" section in [rewrite-patterns.md](rewrite-patterns.md). Researched 27.08.2026. Abstracts and result sections read directly; full-text figures not independently re-derived.

High-confidence, peer-reviewed:

- Chakrabarty, Laban and Wu, "Can AI writing be salvaged? Mitigating Idiosyncrasies and Improving Human-AI Alignment in the Writing Process through Edits," CHI 2025, arXiv:2409.14509. The LAMP corpus: 18 professional writers, 1,057 LLM paragraphs (GPT-4o, Claude 3.5 Sonnet, Llama 3.1 70B), 8,035 edits under a seven-category taxonomy (cliché; unnecessary/redundant exposition; purple prose; poor sentence structure; lack of specificity and detail; awkward word choice and phrasing; tense inconsistency). 74% replacements, 18% deletions, 8% insertions; 70% of non-deletion edits meaning-preserving. Experts preferred expert-edited text over LLM-edited. Domain is literary fiction and creative non-fiction, so the proportions may not transfer to technical prose; the taxonomy does. This is the "LAMP edit" that Russell et al. 2026 (below) used as their surface-scrub baseline.
- Artemova et al., "Beemo: Benchmark of Expert-edited Machine-generated Outputs," NAACL 2025, arXiv:2411.04032. 25 expert annotators edited 6.5k machine texts across five task types; the same texts were also "humanized" by GPT-4o and Llama 3.1 70B. Expert edits cut detector AUROC by up to 22 points and the effect was flat across 20 to 80% edit ratios; LLM-edited texts stayed detectable, GPT-4o-edited ones most of all. Basis for "moderate human edits are enough; machine humanizing is not".
- Russell, Karpinska and Iyyer, "People who frequently use ChatGPT for writing tasks are accurate and robust detectors of AI-generated text," ACL 2025, arXiv:2501.15654. 300 non-fiction articles, five expert annotators (frequent LLM users, untrained) with a majority vote wrong on 1 of 300, including texts paraphrased or generated under a humanization prompt built from the experts' own clue list. Clue categories in their explanations: vocabulary 53.1%, sentence structure 35.9%, grammar 24.8%, originality 23.7%; formulaic and "optimistically vague" introductions and conclusions, listing in threes, and same-slot quotations named explicitly. Basis for the reply-shaped tells section in [tells.md](tells.md) and for "vocabulary scrubbing leaves the structure".
- Reinhart et al., "Do LLMs write like humans? Variation in grammatical and rhetorical styles," PNAS 122(8), 2025, doi:10.1073/pnas.2422455122, arXiv:2410.16107. Biber's 66 features over parallel human and LLM corpora. Instruction-tuned models: present participial clauses at 2 to 5x the human rate (GPT-4o 5.3x, d=1.38), "that" clauses as subject 2.6x, nominalizations about 2x, phrasal coordination 1.9x; agentless passive at roughly half the human rate. Instruction tuning, not scale, produces the gap. Basis for the -ing tail and de-nominalization moves, and for listing passive voice under "not a tell".
- Dugan, Ippolito, Kirubarajan, Shi and Callison-Burch, "Real or Fake Text? Investigating Human Ability to Detect Boundaries Between Human-Written and Machine-Generated Text," AAAI 2023. 21k annotations. Detection is a trainable skill: the group given feedback and an incentive improved over rounds, and having read the help guide (an error taxonomy with annotated examples) was the strongest single predictor of score. GPT-2-era generations, so only the trainability finding is cited, not the accuracy numbers.
- Geng and Trotta, "Human-LLM Coevolution: Evidence from Academic Writing," arXiv:2502.09606 (2025). 1.29M arXiv abstracts. "delve", "intricate", "realm", "showcasing" dropped from April 2024, the month they were publicly named as ChatGPT words; "significant" and "additionally" kept rising. Authors adapt by avoiding named words while the less conspicuous shift continues. Basis for the Currency table and for "naming a word retires it".
- Kousha and Thelwall, "How much are LLMs changing the language of academic papers after ChatGPT?", arXiv:2509.09596 (2025). 2.4M PMC full texts. LLM-associated terms now co-occur: "underscore" with "pivotal" r=0.449 in 2024 against 0.032 in 2022. Corroborates "cluster, not single word" as the unit of detection.
- Zhang et al., "LLM-as-a-Coauthor: Can Mixed Human-Written and Machine-Generated Text Be Detected?", NAACL Findings 2024, arXiv:2401.05952. MixSet: eight human experts "adapted" machine text for fluency; mainstream detectors scored between 0.3 and 0.7 on the mixed texts, near chance. Corroborates Beemo.

Directional only (small samples, preprints, or read via abstract):

- Tabach, "Can Humans Detect AI? Mining Textual Signals of AI-Assisted Writing Under Varying Scrutiny Conditions," arXiv:2604.23471 (2026). 21 writers, half warned of AI detection; 251 judges over 1,999 pairs picked the warned writer's text as human 54.1% vs 45.9% (p=0.00024), yet no extracted feature (AI overlap, lexical diversity, sentence structure, pronouns) differed between groups. The author flags the p-value as likely anti-conservative. Interesting because the judges saw something the features did not; too small to build on.
- "Writing in Symbiosis: Mapping Human Creative Agency in the AI Era," NeurIPS 2025 Creative AI track. 2,100 authors with pre- and post-2022 samples; a model-perplexity gap rose 23% (social) and 15% (formal) in early 2023, then fell 18% and 12% below peak through 2024, read by the authors as stylistic avoidance once AI patterns became stigmatised. Read via the paper's highlights only.
- "LLM Detection as an Intervention: Downstream Impact under Strategic User Behavior," arXiv:2607.19300 (2026). A formal model of writers post-processing to evade detection, plus a reproduction of the "rise-then-fall" curve for style words in arXiv cs abstracts 2022 to 2025. Theory with one empirical check.
- Juzek and Ward, "Why Does ChatGPT 'Delve' So Much?", COLING 2025. 21 focal words; RLHF consistent with, but not shown to be, the source of the overuse.

What the editing research does **not** show: no study here measures a human writer *trained* to write less like a model from a blank page. The closest are LAMP and Beemo (humans editing machine text), RoFT (humans trained to detect, not to write), and the arXiv word drop (avoidance, not craft). "People can be taught to write more human" is inferred from those, not measured. Treat it as a working assumption.

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
