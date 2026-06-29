# Reflection Rubric

How to turn a cluster of feedback into a verdict without monkey-patching. Run every candidate pattern through this. The discipline is borrowed from how a good engineering manager coaches a report on receiving feedback: do not react, reflect.

## The six questions

For each candidate pattern, answer in order. Stop and reject early if a question kills it.

1. **What went wrong?** State the concrete behavior the skill produced and the behavior the user expected. If you cannot name both, the feedback is too vague to act on. Send it back to the "not yet a pattern" bucket.

2. **How many independent reports back it?** One or two: apply the two-data-point rule, defer. Three or more from different sources: a real pattern.

3. **Why did the skill do that?** Trace it to a specific line, instruction, missing guardrail, or ambiguity in the skill. "The model just did it" is not a cause. If you cannot point at the skill text responsible, the fix probably is not in the skill.

4. **Is this the instance or the class?** Restate the fix at one level of abstraction up. If the abstracted version still makes sense and covers other plausible cases, it is a class-level change worth making. If only the literal instance survives abstraction, you are about to monkey-patch. Reject or defer.

5. **Does it fit the skill's stated purpose?** Re-read the skill's opener and description. A change that pulls against the skill's reason for existing is a conflict to raise with the user, not an edit to make. Flag it.

6. **What does it cost in tokens and clarity?** Every added instruction is read on every invocation. Is the pattern frequent and damaging enough to earn permanent space? If the fix is longer than the problem is common, defer.

## Output

One line per pattern:

```
<pattern name>: VERDICT(change | defer | reject): <one-sentence reason>
```

`change` patterns proceed to a proposed edit. `defer` patterns stay in the bucket with a note on what new signal would promote them. `reject` patterns are dropped with a reason so they are not re-litigated next window.

## Anti-patterns to catch in yourself

- **Recency bias.** The report that triggered the session is not automatically the most important pattern. Weight by frequency and damage, not by what is freshest.
- **Agenda creep.** Wanting the skill to do what *you* prefer is not user feedback. Keep your preferences out of the verdict unless real reports back them.
- **Abstraction-too-early.** Three reports that look similar may have three different causes. Confirm the cause (question 3) before merging them into one pattern.
- **Bloat as fix.** Adding an instruction is the laziest fix and usually the worst. Prefer sharpening or removing an existing instruction over appending a new one.
