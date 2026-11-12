# Rewrite patterns

Each replacement below preserves the supplied facts and confidence. Read the sentence in
context before applying it. Use [risk tiers](risk-tiers.md) for structural or voice choices.

The editing studies in [sources](sources.md) motivate examining redundant exposition,
word choice and sentence structure. Their observed edit proportions are not quotas, and
detector performance does not establish an editing rule for every genre.

## Punctuation and artifacts

| Before | After |
|---|---|
| The process is simple: upload the file. | Upload the file. |
| Retningen stemmer: tyngdepunktet flytter oppover. | Retningen stemmer. Tyngdepunktet flytter oppover. |
| The tool has one requirement: Python 3. | The tool requires Python 3. |

Keep genuine list introductions, useful labels and quotations. An em dash can become a
comma, parentheses or a full sentence, but the new punctuation must preserve attachment,
negation and scope. Do not replace it with an emphatic colon.

Normalize quotes only in editable prose. Preserve source quotations, code, identifiers,
mathematical arrows and ranges.

Remove tracking parameters while retaining the link destination. When a leaked citation
marker represents evidence, replace it with the actual source only if known or verified.
Otherwise flag the missing reference outside the text. Do not erase evidence or intentional
drafting placeholders merely because their formatting looks machine-generated.

## Plain wording

| Before | After |
|---|---|
| We utilize a cache. | We use a cache. |
| The gallery features four rooms. | The gallery has four rooms. |
| The tool quietly schedules jobs. | The tool schedules jobs. |
| The utilization of caching resulted in a reduction of latency. | Caching reduced latency. |
| Observability was bolted on after launch. | Observability was added after launch. |

For the "quietly" example, the surrounding context must confirm that the word is decorative.
If it means no notifications or unobtrusive execution, keep that information.

Keep domain meanings. "Robust regression", "landscape orientation", "database key" and a
named software framework can be the precise terms. Do not ask about an unambiguous technical use.

## Setup and repetition

| Before | After |
|---|---|
| Here's the kicker: the API is rate-limited. | The API is rate-limited. |
| It is important to note that the API is rate-limited. | The API is rate-limited. |
| Let's break this down. The queue holds jobs until a worker is free. | The queue holds jobs until a worker is free. |
| The result? A failed build. | The result was a failed build. |
| Not a bug. Not a feature. A design flaw. | This is a design flaw. |
| The question isn't whether the API is rate-limited. The question is how to handle that limit. | The question is how to handle the API's rate limit. |
| To answer your question: yes, the employee can be added. | The employee can be added. |
| For å svare på spørsmålet: du kan legge til den ansatte. | Du kan legge til den ansatte. |
| The first issue is the missing API. The second issue is the missing permissions. | The issues are the missing API and permissions. |

Cut setup only when it adds no information the reader needs. Preserve a real objection or
factual contrast. Removing a whole closing paragraph is a structural decision; check its
unique content and the user's authorization.

Keep counts when they convey information. Numbered steps, named dimensions and actual sets
of three are legitimate. An informative heading such as "How to reset your password" may stay.

## Claims and sources

| Before | After |
|---|---|
| According to the 2025 report, it is important to note that demand may decline. | According to the 2025 report, demand may decline. |
| Smith (2019) argues that the method is unreliable in most cases. | Keep unchanged; both attribution and "most cases" carry meaning. |
| Experts argue that X. | Keep unchanged; flag the unidentified experts outside the text. |
| Industry reports suggest declining demand. | Keep unchanged; flag the unidentified reports outside the text. |
| This change reduced error rates significantly in most cases. | Keep unchanged; clarify "significantly" only if supplied context supports the clarification. |
| The method is substantially faster. | Keep unchanged; flag the missing comparison baseline and measurement if the genre requires them. |

A named citation may still lack support for its associated claim. Humanizing wording does
not verify the source. Do not turn "suggests" into "shows", "often" into "always", an
association into a cause, or "not ineffective" into an unqualified recommendation.

Never supply a plausible name, figure, year, quote or citation key to fix missing evidence.
Keep cited wording and citation keys as provided.

## Lists, modifiers and emphasis

| Before | After |
|---|---|
| It is fast, reliable and scalable. | Keep all three properties; the list contains distinct claims. |
| All the methods do not converge. | Keep unchanged; ask whether none converge or some fail to converge. |
| The system logs errors. The system retries failed jobs. The system alerts on-call. | The system logs errors, retries failed jobs and alerts on-call. |
| A comparison of the methods was performed by the team. | The team compared the methods. |

The system example supplies no retry count or condition for alerting. The passive example
supplies the actor; without one, an active rewrite could invent responsibility.

Remove an adverb or modifier only when it contributes no meaningful degree, timing,
scope or confidence. Keep a qualification near the claim it limits.

## Figurative language and voice

Replace a decorative metaphor only when its literal meaning is available.

| Before | After |
|---|---|
| Think of the queue as a post office. It holds jobs until a worker is free. | The queue holds jobs until a worker is free. |
| We sharpened the positioning. | Keep unchanged; ask what changed if a literal description is needed. |
| Your onboarding is a leaky bucket. | Keep unchanged; flag the missing description of where users leave. |
| He published it. Openly. In a book. As a priest. | He published it openly, in a book, as a priest. |

The last example changes emphasis. Apply only when that change fits the request and voice.
Keep an analogy that accurately explains an unfamiliar subject. Do not enforce a word-count
budget for analogies.

Preserve deliberate rhetoric, personal pronouns and genre conventions. In a formal memo,
do not add contractions or conversational fragments. In a personal post, do not flatten
a meaningful short paragraph or rhetorical question.

## Substantial cuts

For duplicated content, unnecessary summaries, historical examples or a central metaphor,
first identify what each passage adds. Preserve distinct facts and logical relations.
Apply substantial deletions or reordering only within authorized scope.

Do not remove necessary limitations, resolve a genuine uncertainty, manufacture doubt,
or make an explanation argumentative to satisfy a style preference.

## Leave unchanged

- Text that already fits its reader and purpose.
- Exact quotations and cited source wording.
- Correct technical terms and notation.
- Deliberate voice choices consistent with the user's instructions.
- Ambiguous claims that cannot be clarified from supplied material.

A retained scan match is acceptable when it serves the text. Report material unresolved
ambiguities; do not invent problems or harmless-looking replacements to justify an edit.
