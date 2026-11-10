---
name: adversarial-review
description: "Runs a fresh-context adversarial review of a diff for bugs and security holes, then verifies every finding against the code. Use before opening or updating a PR with a code change, when a diff touches auth, input parsing, secrets, money, shell, SQL or CI, or when asked for an adversarial or security review."
---

# Adversarial review

The agent that wrote a change shares the reasoning that produced its bugs. This
skill hands the diff to reviewers that have none of that context, tells them to
break it, and then checks each finding against the code. It complements
`code-review` (Standards and Spec axes); it does not replace it.

## 1. Pin the scope

- Resolve the base: the PR's base branch, else the default branch from
  `gh repo view --json defaultBranchRef`. Use `git merge-base HEAD origin/<base>`.
- Record base SHA, head SHA, and whether the tree is dirty.
- The diff is `git diff <base-sha>...HEAD`, plus `git diff HEAD` when dirty.
  Stop and say so when the diff is empty.

## 2. Write the brief

Give the reviewers only:
- the repository path, base and head SHAs, and the exact diff commands;
- the intent of the change in one sentence, taken from the issue, PR or user
  request;
- the path of the repo's `AGENTS.md` or `CLAUDE.md`;
- the matching section of [reviewer prompt](references/reviewer-prompt.md).

Leave out your own explanation of the change, your test results, and which parts
you consider risky. Each of those anchors the reviewer on your view.

## 3. Spawn fresh-context reviewers

Run two read-only reviewers in parallel: one with the **Bugs** section, one with
the **Security** section. For a diff under about 100 changed lines that touches
no security-sensitive area, one reviewer with both sections is enough.

- Claude Code: the `Agent` tool with `subagent_type: "general-purpose"`, never
  `"fork"` (a fork inherits your context). Send both calls in one message with
  `run_in_background: false`.
- Codex: `spawn_agent` without forking the conversation, then wait.

Tell each reviewer it must not edit files, commit, push, deploy, or call external
services. When the diff touches who may read or write what, add the
[authorization-regression](../authorization-regression/SKILL.md) skill to the
security reviewer's brief.

## 4. Verify every finding

Check each finding yourself against the code at the head SHA:

| Verdict | Meaning |
|---|---|
| Confirmed | You reproduced it, or traced the path from input to effect |
| Plausible | The path exists but depends on config or input you cannot check |
| Rejected | Name the guard, test or invariant that prevents it |

Do not drop a finding because it is inconvenient, and do not accept one because
it sounds severe.

## 5. Act and report

- Fix confirmed findings that are in scope. List out-of-scope ones for the user.
- When fixes are substantial, review only the changed region again. Stop after
  two rounds.
- Report a table: finding, `file:line`, severity, verdict, action. Add base and
  head SHA and the number of reviewers.
- When the change goes into a PR, `github-pr` records this report as evidence.
