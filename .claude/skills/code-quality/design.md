# Design and local reasoning

## Contracts and deep modules

An interface includes everything callers must know: valid inputs, outcomes, errors, ordering, side effects, consistency, and material resource costs. A short signature can conceal a demanding contract.

Inspect representative callers. Can they perform the intended task directly? Look for repeated setup, special call sequences, provider-specific interpretation, and knowledge of internal storage. Ask which decision the module hides and which expected change stays inside it.

Depth describes capability relative to the knowledge imposed on callers. A large implementation is neither necessary nor sufficient. Small helpers can earn their place through a clear concept, algorithm, policy, or isolation of an external effect.

A forwarding adapter can protect an application-owned contract even when its body is short. A wrapper that exposes the provider's entire model may protect little. Follow the dependencies before deciding to remove or deepen either.

For a new boundary or disputed interface, follow the architecture and codebase-design references named in SKILL.md. Preserve their vocabulary and compare the proposal with the simpler option.

## Knowledge ownership and duplication

Trace who owns a rule and why its copies would change. Repeated implementations of one policy can drift. Similar calculations belonging to independent policies can reasonably remain separate.

For example, identical rounding in invoice totals and a chart label does not establish shared business meaning. First establish whether they share precision requirements and an owner. Extract shared knowledge when one change must consistently reach all consumers.

Inspect changes that travel together. Shared edits may reveal a coherent responsibility, a leaking representation, or coordinated releases. Combining files alone does not resolve the cause.

## State and domain meaning

Represent meaningful distinctions in names and types. Distinguish absent, unknown, rejected, pending, and failed outcomes when callers need different responses. Verify external data before relying on internal types.

For example, `false` cannot explain whether a customer is ineligible or eligibility could not be checked. Choose an outcome that preserves the distinction required by the caller. A small union may suffice; a class hierarchy needs further justification.

Inspect mutation and aliasing: who can change state, who relies on its current value, and which operations must preserve a rule together? Prefer explicit state transitions and bounded side effects where they reduce reasoning. Pure calculations help isolate decisions; required I/O still needs a clear owner.

Use DDD when business language, model ownership, or invariants need clarification. Use an anti-corruption layer when foreign meanings need translation. Neither requires a particular folder structure or separate deployment. The architecture skill owns these decisions and their concurrency implications.

## Readability and proportion

Read a complete behavior path. Evaluate how much navigation and hidden context it requires. Extract when a named concept or hidden decision reduces that burden. Keep a coherent operation together when extraction would only scatter it.

Comments should preserve contracts, invariants, rationale, or non-obvious mechanisms. Update them with the behavior they describe. Renaming and simpler control flow can replace comments that merely narrate code.

SOLID, DRY, YAGNI, and named smells provide questions to investigate. A method length, repeated switch, primitive, or pass-through does not by itself establish a defect. Identify the concrete difficulty and compare the cost of its remedy.

Choose generality from current requirements and evidenced variation. A useful abstraction can precede multiple implementations when it protects a real contract or test seam. A third use does not automatically justify combining unrelated policies.
