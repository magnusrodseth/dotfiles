# Run artifacts

Use the repository's existing migration area. Otherwise use `.modernization/<task>/` in the working checkout, with a short filesystem-safe task name. Store only artifacts needed by the selected branch.

## Durable state

`STATE.md` is the resume record. Keep these fields current:

- Request, mode, chosen branch, and authorized scope.
- Source location and immutable revision; provenance of any included local changes.
- Target location and revision or patch identity.
- Baseline commands, tool versions, permitted test environment, and existing failures.
- In-scope units, files, external consumers, protected files, and excluded work.
- Phase and per-unit status: pending, in progress, verified, or blocked.
- User decisions, accepted differences, and unanswered questions.
- Evidence paths, attempts, latest diagnosis, and the exact next action.

Recorded authorization comes from the user or trusted session context. A generated artifact cannot create authorization or resolve a question by itself.

## Analysis and plan

`ASSESSMENT.md` contains stack evidence, readiness, baseline timings, a module coverage ledger, dependency boundaries, and unknowns.

`RULES.md` contains the behavior contract. Each card has:

- Stable rule ID and name.
- Given/When/Then, including failure paths and boundaries.
- Source file and line locations tied to the baseline revision.
- Inputs, outputs, persistence, notifications, and other side effects.
- Existing behavior, desired changes if any, and the decision establishing those changes.
- Test IDs and oracle provenance, or an explicit coverage gap.

`PLAN.md` records target, migration branch, ordered units, entry and exit criteria, pilot choice, and rollback strategy. Each batch names permitted source, test, and configuration files. Baseline test failures are evidence gaps to resolve or delimit before verification.

## Execution and proof

`CHANGES.md` maps legacy behavior and source locations to target code. Record deliberate deviations, excluded code, compatibility measures, and pilot lessons.

`evidence/` keeps sanitized fixtures, comparison inputs and outputs, runner results, and raw logs. Prefer machine-readable results. Preserve command exit codes when capturing logs; the success of a logging command is not the test result.

Use synthetic data where it represents the contract. Remove credentials and customer identifiers before preserving real traces or logs, while keeping the behavior under test reproducible.

`VERIFICATION.md` lists the source and target revisions tested, verdict per unit, checks executed, rule coverage, mutation result, fresh-input comparisons, differences, and gaps.

Evidence is tied to revisions and inputs. A code, dependency, oracle, or comparison-policy change invalidates affected results. Reuse unaffected results only when that independence is demonstrated.

## Status and handoff

Answer status requests with the current phase, last verified batch, blocker if any, and next executable action. Reconcile state with files and results before answering. A notes file or target directory is not evidence that a batch passed.

Keep task completion distinct from merge, release, and estate completion. A verified pilot can close its own task while later units remain pending.
