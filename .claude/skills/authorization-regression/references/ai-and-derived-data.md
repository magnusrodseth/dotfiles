# AI and derived data

Trace authorization before information reaches the model, then through every
stored or disclosed derivative. Output filtering alone cannot undo disclosure
to an unauthorized model context.

| Boundary | Evidence to establish |
|---|---|
| Retrieval and model input | The data owner selects allowed sources using verified identity and scope. Test inaccessible sources with distinct synthetic markers and inspect the actual model request. |
| Summary, translation, extraction or answer | The audience is authorized for the information disclosed. A result generated for a privileged reader is not automatically safe for another audience. |
| Cache, search index, embedding or memory | Scope and lookup rules preserve the policy across readers. Exercise warm-cache reuse and colliding resource IDs across customers where relevant. |
| Changed access or source deletion | The documented lifecycle covers stored derivatives and queued work. Distinguish removed access from permitted retention; flag an undefined disclosure policy. |
| Agent tool call | The receiving operation validates authority independently of the model's chosen resource IDs, user IDs, destinations or approval claims. |

For indirect prompt injection, treat document text, messages and tool results as
untrusted data. Use synthetic content that requests a forbidden read, write or
recipient change. Test the deterministic authority boundary with a controlled
model/tool request, even if the real model refuses the text. A model's refusal
does not establish backend enforcement. Model robustness tests are separate
evidence and cannot make an authorization regression pass on their own.

Inspect actual context construction, not only the returned answer. A synthetic
marker absent from the answer may still have reached a model, trace or cache.
Apply the documented policy to derivatives; broader disclosure requires an
explicit policy basis. Record any intentional declassification or aggregation
rule and test its conditions rather than inventing one.
