When you build an agent, an LLM loop, or any multi-step job that calls models
or tools, separate the run from the client connection, even in a first version.
The engine is secondary: Temporal, a cloud workflow service, or a DB-backed
queue in the repo's own stack all qualify. Follow the repo's existing pattern
when it has one.

- The request admits the run, returns its id, and relays events. The loop runs
  elsewhere.
- The run's state lives in a durable store. An event stream is transport, not
  the source of truth.
- Clients reattach by run id with a cursor and replay what they missed.
- A closed connection never cancels a run. Only an explicit stop does, and there
  is exactly one cancel path.
- Submissions carry an idempotency key. External side effects are not
  exactly-once, so never blindly repeat one after a crash.

Before you implement it, load the `architecture` skill and answer its failure
contract in `events.md`. Do not add this to prototypes, CLIs or one-shot
scripts unless asked. If you deliberately skip it, say so.
