# Finding verification

Verify every candidate against the reviewed revision before reporting it as a defect or dismissing it as a false positive.

## Evidence

1. State the claim: triggering input or state, expected behavior, observed or traced behavior, and consequence. Cite the requirement or contract that defines the expectation. For a standards breach, cite the rule and the conflicting code.
2. Check reachability through real callers, validation, error handling, and the supported runtime. Record assumptions; a test that bypasses a public contract cannot establish a defect in supported use.
3. Attempt refutation. Search for guards, caller guarantees, intended behavior, and tests that contradict the claim. Agent agreement and confidence scores are not evidence.
4. Establish the mechanism with a minimal reproduction or an unambiguous code trace. Record the revision, relevant environment, input, expected/actual result, and command/output or file/line chain. Distinguish executed checks from proposed checks.
5. Establish PR relevance separately. Compare the base and reviewed revisions when behavior may predate the change. A pre-existing defect remains real, but belongs in a separately labeled out-of-scope report.

Keep the reviewed code and test expectations fixed while judging the claim. Run experiments in isolated copies and preserve unrelated changes. Apply production fixes only within the user's authorized scope.

## Validate the check

For important or disputed findings, confirm that the reproduction exercises the relevant production path and reaches its assertion. Mocks must not manufacture the alleged failure.

When a minimal fix is available and authorized, check that the same reproduction fails for the claimed reason before the fix and passes afterward. Keep its expectation unchanged.

For an invariant test that only passes, use a temporary, deliberate violation to check that the test detects it. Remove the mutation afterward. Use this selectively when the test's sensitivity matters, rather than for every review comment.

## Disposition

| Status | Required evidence | Report |
|---|---|---|
| **confirmed** | A reproduction or decisive code trace establishes the claim under supported assumptions | Finding, evidence, assumptions, consequence, and PR relevance |
| **refuted** | Specific counterevidence defeats the claim at the reviewed revision | Reason and counterevidence when assessing existing feedback; omit from newly generated findings |
| **unconfirmed** | Context is missing or investigation cannot decide the claim | Material unresolved risk and the evidence needed to decide it, separately from confirmed findings |
| **design judgement** | A heuristic or tradeoff supports an improvement, without establishing a defect | Explicitly labeled suggestion with rationale |

Failure to reproduce is not refutation. Failure to complete a formal proof is not confirmation. Passing tests support only the checked cases; a checked formal proof supports only its stated property, model, and assumptions.

Count only confirmed findings as defects. Keep design judgements and material unconfirmed risks separate. Verification is complete when every candidate has a disposition and supporting evidence or an explicit evidence gap.
