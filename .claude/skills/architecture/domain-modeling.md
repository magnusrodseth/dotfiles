# Domain modeling

Use domain-driven design to clarify business meanings and the rules that must hold. Strategic design asks where a model applies and who owns it. Tactical design expresses those rules within that boundary. Choose a rich model when its behavior earns the cost.

## Meaning before structure

Read the project's domain vocabulary, then inspect affected callers and write paths. A bounded context is the scope in which a model has consistent meanings; a package or deployment alone does not establish one.

For a new term, record its owner, identity, lifecycle, and a scenario that distinguishes it from the closest existing term. Agree unresolved meanings before implementing dependent policy. Keep provider identifiers in their own namespaces until a verified mapping establishes equivalence.

## Invariants and transaction ownership

An entity retains identity as its attributes change. A value object expresses meaning through its values. An aggregate is a proposed consistency boundary whose root controls changes to its invariants. Related database rows alone do not define that boundary.

For every changed invariant, identify:

- All writers, including routes, agent tools, workers, imports, and administrative paths.
- The transaction and constraint or locking mechanism that enforce it under concurrent writes.
- Which outcomes can be delayed and which must hold when the caller receives success.
- The permitted retry or compensation after a partial failure.

## Example: reserve the last workshop seat

This is an illustrative design exercise. Suppose confirmed reservations must never exceed capacity. A method that reads availability and later writes a reservation is insufficient when two callers overlap.

Identify the operation that atomically decides and records the reservation. Inspect every writer and test two concurrent requests for the final seat. Define the conflict outcome and the meaning of a retry after a lost response.

If payment belongs to another system, decide whether a seat may be held pending payment. That business decision determines which state is local and which transition needs coordination. Read [events.md](events.md) when introducing a delayed transition.

## Shared policy versus similar code

When two operations look alike, compare their owners and reasons for change before sharing them. Discount eligibility and commission calculation can use identical arithmetic while representing independently changing policies.

Prefer extending an existing service when it already owns the lifecycle. Introduce an aggregate or repository abstraction only with a named invariant or access contract it protects. An ORM model can remain the implementation when a second model merely repeats fields.

Verification should include a counterexample: a second writer, concurrent transition, stale read, or ambiguous identity that would defeat the proposed rule. Model-method tests alone cannot establish database concurrency guarantees.

## Background

Adapted from Eric Evans's [DDD Reference](https://www.domainlanguage.com/ddd/reference/) and Fowler's [Bounded Context](https://martinfowler.com/bliki/BoundedContext.html). The example is original and does not prescribe a repository structure or deployment topology.
