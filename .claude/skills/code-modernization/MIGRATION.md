# Migration branches

Read the branch that matches the agreed target. Resolve current framework and migration-tool documentation against the detected versions before using version-specific APIs or commands.

## Uplift: newer versions in the same stack

Preserve structure and change what the version move requires.

1. Pin the source and target version pair from repository evidence and the requested target.
2. Build a delta catalog from official migration documentation. Include only changes that apply to cited call sites or configuration.
3. Classify deltas as compiler-visible, runtime-visible, or behavior changes that can compile silently. Assign tests to each affected site.
4. Establish a harness that can run under both versions. A required test-runner migration comes before application changes.
5. Migrate dependency leaves first. Shared contracts, cycles, and changes affecting external consumers require an explicit compatibility strategy.
6. Complete one pilot end to end. Record its recurring fixes before batching more units. A sequence of major-version hops needs independently verified steps.

Run the same behavior suite on source and target. Treat a legacy expectation that fails on the new version as a difference to investigate. If most application structure must change, reclassify the work as a transform and revise the plan.

## Transform: another language or framework

Use a strangler fig approach where the old system can keep serving unaffected work.

1. Select a vertical slice with a clear boundary and a way to compare its outputs and effects.
2. Pin the behavior contract with characterization tests before implementation.
3. Implement the contract using target-stack idioms. Preserve compatibility at the boundary rather than reproducing accidental internal structure.
4. Run old and new implementations with identical inputs, initial state, clocks, and dependency responses.
5. Compare return values, errors, persisted state, emitted events, and ordering where observable. Record cutover and rollback steps.

Language-semantic risks include rounding, overflow, null handling, date/time behavior, iteration order, serialization, and exception behavior. Cover those that the slice actually uses.

For gradual typing, start with dependency-light files and a measured type-debt baseline. A passing compiler does not establish behavioral parity. Record new suppressions and unsafe casts. Treat dynamic framework conventions and build-chain changes as distinct risks.

## Reimagine: rebuild on a new architecture

Separate recovered behavior from requested product changes.

1. Recover the existing contract and mark behavior the new product intentionally changes.
2. Record the selected boundaries, deployment model, data ownership, compatibility, and migration strategy. Resolve consequential architecture choices within existing user authority.
3. Build one vertical slice with executable acceptance tests before scaffolding the full estate.
4. Establish data reconciliation, coexistence, cutover criteria, and rollback before retiring the old path.

Report parity only for preserved contracts. Report acceptance of changed behavior separately. New service boundaries and green tests alone do not prove equivalence.

## Security hardening

Treat security findings as a separate branch of work. A parity migration can preserve a legacy defect. Document the finding, exploit conditions, and the proposed behavior change. Implement a security fix when it is in scope, with a regression test and an explicit entry in the difference ledger.

## Scaling after the pilot

Expand batch size only when verification time and review capacity permit it. Move recurring repairs into repository-owned transforms with input/output fixtures and idempotence checks. For a mechanical transform, a second application must produce no new diff.

Track remaining units, verification failures, new migration debt, review time, and reversals. Percentage converted alone can reward migrations that hide errors.
