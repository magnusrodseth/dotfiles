These apply when the session works in a code repository. Vault and note edits skip
them.

**Match the steps to the task.** A request for a plan, review or experiment does
not mean publishing it.

| Task | Own worktree | Evidence | PR | `pre-pr-review` |
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
`pre-pr-review`. It runs `adversarial-review` (bugs and security holes) and
`code-review` (Standards and Spec) on the same diff, with a reviewer count
sized by risk. Also run it when a diff touches access control, auth,
transactions or concurrency, input parsing, secrets, money, shell or SQL
execution, or CI and infra. Skip it for docs-only changes.

**Repeat findings.** When a review finding names a mistake this repo has
already fixed once, make it a check that fails: a test, a lint rule or a
boundary rule. When no check can hold it, add it to the repo's `AGENTS.md`.
Pick the tool for this repo's language and existing tooling, since the right
one differs per stack (an architecture rule is dependency-cruiser in
TypeScript, import-linter in Python, ArchUnitNET in C#). Extend a tool the repo
already runs before adding one, and load `find-docs` to confirm the current
choice and its config.
