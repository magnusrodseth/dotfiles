These apply when the session works in a code repository. Vault and note edits skip
them.

**Match the steps to the task.** A request for a plan, review or experiment does
not mean publishing it.

| Task | Own worktree | Evidence | PR | `adversarial-review` |
|---|---|---|---|---|
| Read-only review, explanation, investigation | No | No | No | No |
| Plan or local experiment | No | No | Only if asked | No |
| Docs or comment-only change | If agents run in parallel | No runtime evidence | If asked | No |
| Code change meant to ship | If agents run in parallel | Yes | When asked or the repo expects one | Yes |

**Evidence and PRs.** Use the `evidence` skill to capture the failing behaviour
before a fix and the passing behaviour after it. Use `github-pr` to open or update
a PR; it calls `evidence` and owns the body template. Use `pr` only when asked to
write a PR body on its own.

**Order work by risk.** Architecture and integration points first, spikes for
unknowns next, polish last. Fail fast on the risky part.

**Parallel agents.** Several agents often work on the same repo at once.
- One worktree and one branch per task and per agent. Never edit a checkout
  another agent is using.
- Before starting, run `gh pr list`, then `gh pr diff <n> --name-only` on open PRs
  that may overlap. Report any overlap before writing code.
- Never use plain `--force`. Use `--force-with-lease`, and only on your own task
  branch.
- Resolve lockfile conflicts by regenerating the lockfile, never by hand-merging.
- Before trusting a dev server, confirm the port answers your process
  (`lsof -i :<port>`).

**Review.** Before opening or updating a PR with a code change, run
`adversarial-review`. Also run it when a diff touches auth, input parsing, secrets,
money, shell or SQL execution, or CI and infra. Skip it for docs-only changes.
`code-review` stays the Standards and Spec review; `adversarial-review` hunts bugs
and security holes. They answer different questions, so a PR can need both.
