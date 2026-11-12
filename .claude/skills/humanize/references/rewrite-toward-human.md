# Rewrite toward human

Improve clarity and rhythm using the information the author already supplied.
The meaning check in [SKILL.md](../SKILL.md) takes priority over every move here.
See [sources](sources.md) for the evidence and its limits.

## Sentence edits

These are usually Tier 2 when they preserve scope, attribution and emphasis.
Apply the [risk tiers](risk-tiers.md) to each passage. Adding no facts does not
automatically make a structural change safe.

### Let sentence length follow the thought

Split a sentence when its ideas are hard to follow. Combine short sentences when they
describe one action. Keep useful repetition. Do not enforce a length quota, a statistical
spread, different opening words, or a set number of fragments.

| Before | After |
|---|---|
| The migration improved performance across all endpoints, and the team was pleased with the reduction in latency that followed the rollout. | The migration improved performance across all endpoints. The team was pleased with the reduction in latency after the rollout. |
| The system logs errors. The system retries failed jobs. The system alerts on-call. | The system logs errors, retries failed jobs and alerts on-call. |

The first example supplies no amount of improvement or emotion beyond "pleased".
The second supplies no retry count, ordering or condition for alerting.

### Cut transitions that add no relation

Keep transitions that express a real contrast, consequence or sequence.

| Before | After |
|---|---|
| Moreover, it is important to note that the API is rate-limited. Furthermore, this affects batch jobs. | The API is rate-limited. This affects batch jobs. |

"Affects" does not establish that jobs fail. Do not replace it with "breaks".

### Make attribution clear

Name an actor only when the source or supplied context identifies one. Passive can
appropriately describe system properties or keep the relevant noun in subject position.

| Before | After |
|---|---|
| A comparison of the methods was performed by the team. | The team compared the methods. |
| Improvements were implemented and gains were observed. | Keep unchanged; ask who acted and what changed if that information is needed. |

### Put the action in the verb

Remove nominalizations when the relation between the actions remains the same.

| Before | After |
|---|---|
| The utilization of caching resulted in a reduction of latency. | Caching reduced latency. |

### Keep qualifications attached to the claim

End a sentence where its meaning is complete. Put new information where the reader can
follow it. A qualification may properly come last. Do not move it merely to create emphasis.

| Before | After |
|---|---|
| This change reduced error rates significantly in most cases. | Keep unchanged; "significantly" needs clarification if its statistical meaning is unclear. |
| It could be argued that shorter subject lines may not be ineffective. | Keep unchanged unless the author clarifies the intended strength of the claim. |

"Not ineffective" does not necessarily mean "effective". A tentative suggestion does not
support a universal recommendation or a new word-count limit.

### Connect known information to new information

Use the preceding thought when it helps the reader understand the next one.
Preserve who acted and what a pronoun refers to.

| Before | After |
|---|---|
| Latency dropped. A new cache was the reason. Users noticed the drop. | A new cache reduced latency. Users noticed the drop. |

### Prefer familiar words without changing register

Use a plain equivalent when it has the same meaning. Keep established technical terms.
"Use" often replaces "utilize"; "significant" may carry a statistical meaning and must be
judged in context. Do not swap formal writing into conversational language by default.

### Cut decoration, keep information

Remove empty emphasis. Keep degree, frequency and confidence when they are part of the
claim. A stronger verb can strengthen the claim, so check it against the source.

| Before | After |
|---|---|
| The service quickly and significantly improved. | Keep unchanged; the source supplies no timing or magnitude with which to replace these terms. |
| It is fast, reliable and scalable. | Keep all three properties unless the author says one is unsupported or redundant. |

## Paragraph and content decisions

Judge these by the user's requested scope. A full editorial rewrite can permit
reorganization; a narrow vocabulary pass usually does not.

- Keep one subject per paragraph when that helps the reader. Preserve intentional short
  paragraphs, especially in messages and LinkedIn posts.
- Make each paragraph's role in the whole text clear. Remove a repeated preview or recap
  only when its unique content is preserved and its deletion is authorized.
- Present supplied facts, interpretation and limitations distinctly. Preserve genuine
  uncertainty, resolved conclusions and open questions as the author wrote them.
- Preserve existing first-person perspective, emotion and anecdotes. Do not add any to
  make the text appear human.
- Replace an abstraction with a specific only when supporting material supplies it.
  Otherwise identify the missing information outside the prose.
- An explanation or factual update needs useful information. An argument needs a supplied
  position and support. Evaluate the genre the author chose.

## Final reading

Read the changed passage in context. Confirm that its facts, logical relations,
confidence and attribution still match the original. Check whether it reads naturally
for this audience. Revert forced edits.

No quota for first-person statements, unexpected words, sentence openings, analogies or
sentence-length variance applies. Correct grammar and deliberate repetition can stay.
