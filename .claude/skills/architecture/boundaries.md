# Boundaries and translation

A useful boundary hides a decision from callers and keeps related policy together. An interface includes required knowledge about errors, ordering, and effects, beyond its language-level signature.

## Ports, adapters, and dependency direction

Ports and adapters and hexagonal architecture name the same architecture. A port defines an application conversation. A driving adapter initiates it; a driven adapter serves the application's requests. Select ports from use cases and external dependencies.

Dependency inversion puts implementation details behind contracts shaped by their consumers. Dependency injection supplies implementations; injecting a concrete provider client alone leaves its vocabulary in the consumer.

Before introducing a contract, name the behavior that needs independent testing or change. A callable can be sufficient; use an interface or protocol when several operations form one contract. Specify outcomes and failure semantics rather than reproducing an entire SDK.

Draw two relationships when evaluating the proposal:

```text
Source dependencies: application -> application-owned contract <- adapter
Runtime calls:       application -> adapter -> external service
```

Composition code selects implementations. Check real import paths before claiming the application is isolated.

## Preserve useful existing boundaries

Suppose a document-intake service owns validation, duplicate detection, storage ordering, and dispatch for several callers. Extending that lifecycle owner can preserve cohesion even if it imports a web framework and ORM.

Treat it as an existing module, not evidence of a technology-independent domain core. Compare adding a second caller with extracting a narrower contract. Require a concrete benefit before changing its dependency structure.

Trace transaction and duplicate behavior across every affected entry point. In-memory substitutes help test policy; adapter tests establish real storage semantics, and composed tests check wiring.

## Anti-corruption layers protect meaning

An anti-corruption layer translates a foreign model into local concepts. Decoding JSON or renaming a field is technical adaptation; a semantic mismatch justifies additional translation policy.

For example, a provider's active billing account might not imply entitlement to local support. Write down the upstream meaning, local meaning, missing or unknown outcome, and identity namespace. Ask the policy owner about ambiguous mappings.

Keep translation in maintained integration code, outside generated clients. Test unknown values, ambiguous identities, and transport failure separately from valid negative business outcomes. If meanings align, a small adapter may suffice.

The boundary earns its maintenance cost when provider changes stop propagating into unrelated policy. It retains a dependency on the provider contract; it concentrates that dependency rather than eliminating it.

## Background

See Cockburn's [original hexagonal architecture article](https://alistair.cockburn.us/hexagonal-architecture), Martin's [A Little Architecture](https://blog.cleancoder.com/uncle-bob/2016/01/04/ALittleArchitecture.html), Fowler's [dependency injection](https://martinfowler.com/articles/injection.html), and Evans's [DDD Reference](https://www.domainlanguage.com/ddd/reference/). Examples above are illustrative.
