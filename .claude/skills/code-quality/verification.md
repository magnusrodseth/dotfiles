# Verification and operational fitness

Select checks from the behavior and failure mechanism being claimed. An isolated test, storage integration test, and composed workflow check establish different properties.

## Behavior and test quality

Exercise stable, meaningful interfaces. Assert observable outcomes against an independent expectation: a requirement, worked example, known result, or invariant. A test that recomputes the production algorithm can agree with the same mistake.

Inspect whether the test detects its intended failure and whether internal restructuring alone would break it. Use existing regression evidence where adequate. Add tests when risk or changed behavior warrants them; test count and coverage alone do not establish quality.

For unfamiliar existing code, characterize the behavior needed for safe change. Separate behavior being preserved from known defects that the task authorizes correcting. Test doubles can control time and external failures; check that critical assumptions about real adapters also hold.

Targeted mutation testing can investigate weak assertions in important logic. Interpret surviving mutations before changing tests; equivalent behavior and tooling limits can produce survivors. Use the repository's tooling and proportion effort to risk.

## Persistence and concurrency

Trace every affected writer and the actual transaction, constraint, lock, or version check. A validation followed by a write can race even when both operations pass isolated tests.

For example, two requests can both read the last available seat. Evidence for capacity enforcement must exercise the operation that atomically decides and records the reservation. An in-memory repository cannot establish the database's concurrency semantics.

For schema or contract changes, inspect old readers and writers, rollout order, data backfill, and failure during migration where applicable. Check compatibility beyond field names: defaults, identities, units, and business meanings can change behavior.

## External input and permissions

Trace untrusted input through parsing, validation, and use. Check authorization at the operation that reads or changes protected data, including tenant or resource scope when applicable. UI visibility and type assertions do not enforce permission.

Examine secrets and sensitive data at actual log, error, and serialization paths. Select focused security checks from the changed data flow and threat. Use specialist review when the relevant risk exceeds the available evidence.

## Partial failure and asynchronous work

Before changing delivery or recovery behavior, follow the architecture skill's events reference. Establish what success promises, which state survives a crash, and who recovers unfinished work.

Verify relevant duplicate delivery, interrupted processing, lost responses, reordering, and terminal failure. Retries need an appropriate failure classification, bounded attempts or deadlines, and a safe repeated effect. A timeout after remote success creates an uncertain outcome that local rollback alone cannot resolve.

Make pending and failed work discoverable through the application's established state and operational signals. Observability should identify the failed operation and recovery action without exposing sensitive data.

## Capacity and performance

Specify the growth under discussion: traffic, data volume, feature complexity, or teams. For runtime growth, state the workload, relevant resource, and required latency, throughput, or capacity. Obtain measurements before claiming an improvement.

Inspect unbounded queries, N+1 access, concurrency, queue growth, memory retention, and resource lifetime where the path makes them relevant. Use representative data and a comparable baseline for benchmarks. For overload, define backpressure, rejection, or degradation instead of assuming extra concurrency increases capacity.

For feature or team growth, evaluate expected change propagation, ownership, and coordination. Independently deployable services introduce network and operational duties; a modular monolith can satisfy the requirement. Distribution, caching, and events each need a demonstrated purpose.

## Executable constraints

Use types, linters, architecture checks, and CI for agreed properties those tools can establish. A new rule needs a concrete violation it detects and a rationale for its maintenance cost. Inspect configuration and actual failures before claiming enforcement.

When verification fails, distinguish a production defect, invalid expectation, environment failure, and existing debt. Explain proposed expectation changes. Preserve enforcement and report unresolved failures accurately; passing checks support only the properties they exercise.
