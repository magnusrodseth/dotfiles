# PR description template

Read the repository's instructions and actual PR template first.
Keep required local headings and order. Use this default when no local structure
is specified. Keep the same information in an equivalent local field when the
repository template already provides one.

## Explain why the change matters

Lead with one or two sentences explaining the problem, who benefits and what
improves. Use the heading Why this matters by default. A small correction can
state its rationale inline when the local format calls for a short summary.

| Value | Explain | Evidence boundary |
|---|---|---|
| Product | Which user's task, correctness or experience improves, and how | Separate the intended benefit from an observed customer outcome. |
| Technical | Which developer or operator problem improves, through what mechanism | Name the removed failure mode, maintenance burden or enabling capability. |
| Enabling work | What capability this PR prepares and who can use it | State any remaining work before customer or operational value is realised. |

A list of changed files is not a value explanation. Use inspected facts and the
request's actual acceptance source. Do not invent metrics, savings or business
impact. Say when the benefit is expected and has not been measured. Routine
maintenance can have a concrete technical rationale without a product claim.

## Default body

Replace the prompts with the actual change and remove unused optional sections.
Keep status truthful: an unchecked scenario is pending, and a command not run
must not appear as a passing check. Name material verification gaps.

```markdown
## Why this matters

Explain the problem, beneficiary and concrete product or technical benefit.

## Summary

Describe the change and resulting behaviour. Use the visual guidance below
when a diagram or illustration makes the change easier to review.

## Design decisions

Include significant choices and their rationale when the diff alone is unclear.
Omit this section for routine changes without a meaningful trade-off.

## Test plan

List executed commands or scenarios and their observed results. Separate
pending, failed and untested checks, with reasons and relevant limits.

## Manual test plan

For behaviour that needs manual verification, give the reviewer reproducible
steps and expected results. Identify the required environment and safe fixtures.
Omit this section when manual testing adds no useful evidence, unless required
by the repository's template.

## Merge danger

**Door:** one-way or two-way, with the concrete rollback limit when relevant.

**Blast Radius:** the affected users, services, data, configuration or tooling.

Describe release effects, compatibility or verification limits that affect the
merge decision. Keep this proportional to the actual change.
```

## Show the change visually when useful

For changed dependency boundaries, interactions, data flow or lifecycle states,
include a small visual when it explains the change more clearly than prose.
Write diagrams in fenced `mermaid` blocks. Choose a flowchart, sequence diagram
or state diagram to suit the change. Use screenshots for UI evidence.

Show before/after when the difference matters. Keep only the changed boundary
and the context needed to understand it. Label arrows as source dependencies,
runtime calls or data flow so readers know what they mean. Distinguish this PR's
implemented change from a future target and keep remaining debt visible.

Check names, directions and claims against the diff. Place the visual beside a
short explanation, retain a textual account, and verify syntax or rendering.
Skip visuals for trivial changes where they add no information. A diagram
explains the change; behavioral claims still need execution evidence.

For visible changes, include the before/after captures required by the evidence
workflow and local context. For non-visual behaviour, use meaningful command,
payload or state-transition evidence. Documentation-only changes can explain
why application checks do not apply while demonstrating any claimed mechanism.

Add closing issue references only for requirements this PR actually completes.
Preserve unfinished requirements and link related work accurately.
