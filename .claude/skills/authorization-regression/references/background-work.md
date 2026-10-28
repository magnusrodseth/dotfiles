# Background work and external recipients

Map the job's authority separately from its trigger. A customer ID in a message
does not itself authorize a read or delivery. Locate trusted producers,
credential validation and the consumer's authorization control.

Trace which permissions and approvals are evaluated at enqueue, execution,
retry, delivery and later viewing. Follow the product's documented policy for
changes over time. Missing lifecycle policy is a gap, not permission to reuse
an old session or grant the worker unrestricted access.

Select relevant scenarios:

- Permission, ownership or service authority changes while work waits.
- A stored result is requested by a different or no-longer-authorized reader.
- An approval expires or the content, audience or action changes after approval.
- A destination, callback URL or recipient is substituted in untrusted input.
- Duplicate delivery or a retry repeats an external effect after authority changes.
- A per-customer feature is disabled before queued work executes.

Verify the documented allow/deny outcome and downstream effects. Hold external
delivery at a controlled adapter and assert recipient, payload and invocation
count. Exercise real persistence/worker boundaries when those establish the
claim; a mocked handler does not prove queue-to-delivery wiring.

Record whether the test proves authorization, idempotency or both. A successful
duplicate-suppression test does not prove the recipient may receive the data.
Use bounded local tests and synthetic recipients. Live delivery and production
identities are outside this workflow.
