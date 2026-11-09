# Verification boundaries

Choose the boundary from the behavior being claimed. Record each service as real,
substituted, unavailable or outside scope. The following are assertion examples,
not a mandatory suite for every change.

| Claim | Exercise and observe | Insufficient by itself |
|---|---|---|
| Browser feature saves state | Running web calls the selected real API; write succeeds; reload/fresh read shows the saved state | Screenshot or intercepted successful response |
| Authorization isolates resources | Approved synthetic identities with different resource ownership exercise the real permission boundary | UI hides a button |
| Background work completes | Application action creates the intent; the real worker processes it; public status or relevant stored outcome changes | HTTP 202 or queued task ID |
| Cross-service event converges | Publishing action, transport identity/version, consumer materialization and observable result correlate | Direct SQL fixture or a readable broker record alone |
| Provider delivery succeeds | Approved provider interaction and the provider's documented acceptance/result are observed | Suppressed sending or mocked provider response |
| Error state is recoverable | Safe induced error preserves intended state; retry or recovery restores the expected behavior | Happy-path checks |

Database fixtures can establish transport or storage behavior; identify those
claims separately from application-triggered behavior. A local fake provider is
a valid control, but the result ends at the provider adapter boundary.

Choose assertions proportionate to the changed feature: duplicate submission,
refresh, ownership, delayed worker, unavailable dependency or retry may matter.
Agree expected behavior from the requirement and actual implementation. Restore
only test-owned state through an authorized cleanup path; keep evidence before
cleanup. Do not create production activity merely to turn an untested row green.
