# Behavioral parity

## Choose and identify the oracle

Prefer differential execution: run the immutable legacy baseline and target on identical inputs in isolated environments.

If legacy execution is unavailable, use recorded traces or fixtures with known source revision, capture conditions, and expected outputs. Label this evidence as trace-based. Source reading and domain-owner examples can guide test creation, but cannot establish executable equivalence alone.

Freeze the oracle and comparison policy before repairing the target. Resolve disputed behavior through the relevant user decision. Keep intended bug fixes in the difference ledger.

## Make the tests capable of failing

Use a scratch copy of the target to make one small, behavior-relevant mutation. A changed threshold, permission check, or state transition must cause a corresponding assertion to fail. Preserve the result, then discard only the task-owned scratch copy and rerun the unmodified target.

Distinguish an assertion failure from a compiler failure or broken test harness. For multiple independent contract areas, check sensitivity in each high-risk area. Passing one mutation establishes only that case's sensitivity.

## Compare observable behavior

Include applicable success, failure, boundary, malformed-input, permission, and state-transition cases. Compare meaningful outputs and effects, not merely process success or HTTP status.

Use a deterministic comparator. Persist input IDs, oracle and target outputs, policy, and results. Missing fixtures, missing runners, zero executed cases, skipped cases, or unparseable results are coverage gaps. Make a missing required oracle fail the harness.

Normalize only identified nondeterminism. Explain each ignored field. Numeric tolerances need a stated domain reason. Preserve array and event order when order is contractual. A normalization rule that hides a meaningful change invalidates the comparison.

Add fresh inputs selected from the contract and cited implementation after development cases pass. For example, use values on both sides of a threshold or a role that lacks permission. Keep excluded inputs and their reasons visible.

## Separate verification pass

Review the contract, immutable baseline, batch manifest, current diff, and raw evidence. Re-run required checks and inspect:

- Rules without an executed passing test.
- Changed expectations, removed tests, new skips, weakened checks, or altered comparison masks.
- Out-of-scope files and changes affecting external consumers.
- Differences in outputs, persistence, authorization, notifications, or ordering.
- Baseline failures, unavailable dependencies, and environment limitations.

Verification reports findings. Repairs happen in a subsequent implementation pass and invalidate affected evidence. Use an independent reviewer when authorized and available; otherwise disclose self-review.

## Verdict per declared slice

| Verdict | Required evidence |
|---|---|
| Verified within scope | All required build, type, lint, and behavior checks pass; every declared rule has executed evidence; meaningful mutations are detected; fresh differential cases pass; legacy execution is available; no unresolved differences or protected-check changes remain |
| Partially verified | Some valid checks pass, but trace-only evidence, missing legacy execution, uncovered rules, or unresolved baseline gaps limit the claim |
| Not verified | Required checks fail or cannot execute, a required oracle is missing, zero meaningful cases ran, the sensitivity check fails, or a material mismatch remains |

An accepted intentional difference must cite its human decision and have passing tests for the new contract. Describe the verdict as verification of the agreed contract with those differences, rather than exact equivalence.

Compute counts and comparison outcomes from runner output. Attach result files and exit codes so another run can reproduce the verdict. An LLM's confidence is not a verification result.
