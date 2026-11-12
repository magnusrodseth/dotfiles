# Evaluation

These are synthetic editing fixtures, not reports about real products or experiences.
Use the same inputs and task wording for a baseline and a candidate skill.
Correctness requirements are fixed before inspecting either output.

## Regression cases

Each request is "Humanize this; preserve meaning" unless specified otherwise.
A safe edit is illustrative, not the only acceptable wording. Check the full input.

### English email

Input: "It is important to note that the migration may reduce latency by 12% in the test environment."

Safe edit: "The migration may reduce latency by 12% in the test environment."

Require: keep "may", 12%, latency and the test-environment restriction. Reject an established
improvement, a broader deployment claim or an added measurement.

### Norwegian email

Input: "For å svare på spørsmålet: rapporten tyder på at etterspørselen kan falle i juni."

Safe edit: "Rapporten tyder på at etterspørselen kan falle i juni."

Require: keep attribution to the report, "tyder på", "kan", juni and Norwegian spelling.
Reject "etterspørselen faller" or a new explanation of why.

### Personal LinkedIn paragraph

Input: "Jeg prøvde løsningen i går. Jeg er fortsatt usikker på om jeg vil bruke den videre."

Safe edit: "Jeg prøvde løsningen i går. Jeg er fortsatt usikker på om jeg vil bruke den videre."

Require: retain first-person singular, the actual uncertainty and the experience supplied.
Reject a new anecdote, endorsement or switch to "vi". An unchanged output can pass.

### Technical documentation

Input: "The framework uses robust regression. The dashboard supports landscape orientation."

Safe edit: "The framework uses robust regression. The dashboard supports landscape orientation."

Require: retain technical meanings. Reject replacements motivated only by the vocabulary list.
No contestable position, first-person statement or extra example is needed.

### Formal memo

Input: "In light of the fact that the review is incomplete, approval remains conditional."

Safe edit: "Because the review is incomplete, approval remains conditional."

Require: retain conditional approval, its reason and formal register. Reject an unconditional
approval, a deadline, an actor or conversational filler.

### Quotation and citation key

Input: `The report states, "Results may differ across sites" (\cite{smith2025}).`

Safe edit: `The report states, "Results may differ across sites" (\cite{smith2025}).`

Require: preserve the quotation verbatim, its attribution and the exact citation key.
A wording pass must not claim to have verified the report.

### Ambiguous negation

Input: "All the methods do not converge."

Safe edit: "All the methods do not converge."

Require: leave the sentence intact and flag whether it means none converge or some fail.
Reject choosing either interpretation without context.

### Retry logic

Input: "The system logs errors. The system retries failed jobs. The system alerts on-call."

Safe edit: "The system logs errors, retries failed jobs and alerts on-call."

Require: retain all actions. Reject a retry count, ordering or a condition for alerting.

### Unsupported magnitude

Input: "This change reduced error rates significantly in most cases."

Safe edit: "This change reduced error rates significantly in most cases."

Require: preserve "most cases" and the claimed degree. Flag ambiguity in "significantly"
if needed. Reject zero errors, a percentage or universal success.

### Unnamed source

Input: "Industry reports suggest declining demand."

Safe edit: "Industry reports suggest declining demand."

Require: retain attribution and the strength of "suggest"; flag the unidentified reports.
Reject an assertion that demand is declining or an invented report name.

### Distinct list members

Input: "The design is fast, reliable and scalable."

Safe edit: "The design is fast, reliable and scalable."

Require: keep all distinct claims. Reject dropping or adding a property to meet a rhythm rule.

### Narrow scope

Request: "Remove the em dash only; preserve the rest."

Input: "The change may help—in the test environment."

Safe edit: "The change may help in the test environment."

Require: preserve confidence and the setting. Inspect other candidates, but do not broaden
the edit or restructure unrelated passages.

## Blind comparison procedure

1. Freeze these inputs and requirements. Record skill versions, model and settings.
2. Run baseline and candidate in separate contexts using the same requests. Do not show
   either run the other's output. Keep the review context out of both runs.
3. Randomize the order of each output pair. Hide version labels from the evaluator.
4. Check facts, scope, confidence, attribution and protected text first. Any unsupported
   detail or changed meaning fails that output, regardless of fluency.
5. For faithful outputs, compare usefulness, readability and voice for the stated genre.
   Allow ties and unchanged text. Count new unnecessary questions or expansions as friction.
6. Reveal labels after recording judgments. Report case-level failures and the evaluator's
   identity and limits. Self-evaluation by the drafting model is not independent reader testing.

## Limits

Reading the examples and checking their values or references tests local consistency only.
It does not establish how a model will follow the skill or prove a quality improvement.
Do not report a blind comparison as completed unless the isolated runs and hidden labels
actually occurred. Do not substitute detector scores, word counts or empty search results
for meaning preservation and reader judgment.
