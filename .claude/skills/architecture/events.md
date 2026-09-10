# Events and asynchronous workflows

A command requests an action; an event records an occurrence. A background task commonly carries a command. Event-driven architecture connects producers and consumers through facts, but each consumer still depends on their meaning and delivery contract.

## Decide what success means

Before adding asynchronous work, identify what must be true when the caller receives success. Decide which later outcome may be pending, who owns that state, and how users or operators discover failure.

Keep these choices separate:

| Choice | Question |
| --- | --- |
| Event notification | Can a consumer fetch details later, including during a producer outage? |
| Event-carried state transfer | Which data may the consumer retain, and how does it handle stale versions? |
| Event sourcing | Is event history authoritative for reconstructing domain state? |
| CQRS | Do separate read and write models solve an actual need? |

An audit row or replayable transport is insufficient evidence of event sourcing. Asynchronous delivery can reduce simultaneous availability requirements while retaining schema, semantic, and ordering dependencies.

## Inspect the durable handoff

Trace the actual state change, publication, consumer, and scheduler registration before claiming recovery. Find the crash gap between the durable state change and dispatch.

For example, workshop reservation confirmation may need to commit immediately while email delivery can wait. A crash after saving the reservation but before dispatching email leaves a gap unless pending work survives.

Select explicit best effort when loss is acceptable, an existing durable reconciliation path when applicable, or a transactional outbox when required. An outbox atomically records outgoing intent with state; publication can still repeat. Check that recovery actually runs and handles work already in flight.

## Failure contract

Before implementation, answer each applicable case:

| Failure | Evidence required |
| --- | --- |
| Crash after commit, before dispatch | A durable pending record and a proven recovery path, or explicitly accepted loss |
| Duplicate or concurrent delivery | An atomic claim, uniqueness constraint, or repeat-safe operation protecting the effect |
| External service succeeds, response is lost | Provider idempotency or reconciliation; otherwise state the uncertain outcome |
| Messages arrive out of order | A version or transition rule, or an explicit ordering guarantee |
| Worker dies partway through | Which completed effects survive and how restart handles them |
| Consumer stays unavailable | Recovery deadline, observable backlog, and terminal failure handling |

A local send ledger cannot make a remote side effect atomic with its database write. Test the interruption between those operations before claiming exactly-once behavior.

Use the repository's task implementation guidance and inspect actual acknowledgment, retry, and retention settings. Verify failure behavior at the durable boundary, including real database concurrency where claimed. Fakes are useful for producing a provider timeout after simulated success.

## Background

See Fowler's [event-driven distinctions](https://martinfowler.com/articles/201701-event-driven.html), Richardson's [Transactional Outbox](https://microservices.io/patterns/data/transactional-outbox.html), and Hohpe and Woolf's [Idempotent Receiver](https://www.enterpriseintegrationpatterns.com/patterns/messaging/IdempotentReceiver.html). The reservation scenario is illustrative.
