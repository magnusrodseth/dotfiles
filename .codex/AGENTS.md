## Personal Hubs

Cross-cutting repos I refer to from anywhere (paths are `$HOME`-relative; identical layout on both machines):

- `~/dev/personal/vault`: Obsidian second brain. Notes, people, projects, meetings, health, travel, Personlig Økonomi. Read its `AGENTS.md` before writing to it. Use the `read-up-on` skill for briefings, the `vault` skill for capturing knowledge.
- `~/dev/personal/presentations`: all my talks and slide decks (TanStack Start app, deployed to presentations.magnusrodseth.com). Read its `AGENTS.md` before working in it. Use the `scaffold-presentation` skill to create new decks.
- `~/dotfiles`: machine config, stow-managed. Every skill I author lives in `~/dotfiles/.claude/skills/` (that is the authoring path for all agents, not a Claude-only directory). `scripts/skills/link-dotfiles-skills.sh` symlinks each one into both user-scope skill roots: `~/.claude/skills/` for Claude Code, and `~/.agents/skills/` for you. Run it after adding a skill. `~/.codex` is a real directory, NOT a symlink into dotfiles, and `~/.codex/skills/` holds only the preinstalled `.system/` skills.

### Skills you can and cannot see

You discover skills in `~/.agents/skills/` (user scope) and `<repo>/.agents/skills/` (project scope). You never read `.claude/skills/` at any level, so a skill present there and absent from `.agents/skills/` is invisible to you no matter what this file says about it.

Being on disk is not enough either. You pack the available-skills list into a fixed context budget (roughly 19-22k characters), shortening descriptions to fit and then omitting the overflow, so with ~325 skills installed some are silently left out of your prompt. If a skill named here is not in your available-skills list, say so plainly instead of improvising a substitute; do not report it as missing from the machine, because it is probably installed and merely omitted. `rg --files ~/.agents/skills -g SKILL.md` shows what is actually on disk.

## Calendar Event Titles

<!-- rules:calendar-titles -->
For meetings with other people, use a title that makes sense to every participant. Prefer names and purpose, for example `Magnus x Ola: Lunsj`.
<!-- /rules:calendar-titles -->

## Browser Preference

<!-- rules:t3-browser -->
When you run inside the T3 Code harness, prefer T3's built-in browser for browser
work when Magnus does not name a browser. That is the preview tab shown inline in
the thread, driven by the `t3-browser` skill and the t3-code MCP preview tools, so
Magnus can watch it. Outside T3 Code, follow the agent's own browser preference.
<!-- /rules:t3-browser -->

Outside T3 Code, prefer `@Brave Browser` (computer use) when Magnus does not name a
browser. It uses the Brave Personal profile. Use `@Browser` for localhost, an isolated
browser profile, or when Magnus explicitly asks for the Codex in-app browser. Use
another browser only when Magnus names it or Brave cannot support the task, and state
the reason when switching.
Use one named browser group for each browser task, even when the task needs only one tab.
Create it before opening or claiming tabs with `await browser.nameSession("🔎 Short task name")`;
use a short, task-specific name that starts with an emoji.

## 1Password

Use `@1Password` for website sign-in and browser credential workflows in ChatGPT or
Codex when its browser-login capability is available. Use the `onepassword-cli` skill
for terminal commands, CLI authentication, secret references, and local secret injection.
Use the 1Password Environments integration only for Developer Environments and local
`.env` mounts. Never read a secret with `op` and pass it through chat or browser automation.
If browser-login support is unavailable, ask Magnus to complete the 1Password autofill
or approval step.

## Code Repository Workflow

<!-- rules:code-repo-workflow -->
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
<!-- /rules:code-repo-workflow -->

## Durable Agents

<!-- rules:durable-agents -->
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
<!-- /rules:durable-agents -->

## Modern Web

<!-- rules:modern-web -->
When you write or change code that runs in the browser in a code repository,
load the `modern-web-guidance` skill before you write the code. That means
markup, styles and client-side scripts in any flavour: `.html`, `.css`,
`.scss`, `.js`, `.ts`, `.jsx`, `.tsx`, `.vue`, `.svelte`, `.astro`, Tailwind
classes, CSS-in-JS, and web components. It covers UI components, layout,
animation, forms, accessibility, Core Web Vitals, and browser APIs. Skip it
for server-only code (API routes, server actions, loaders, ORMs), infra,
build tooling, tests, renames and copy edits, and for vault or note work.

- Run the globally installed `modern-web-guidance` binary (declared in
  `scripts/npm/npm_packages.txt`), not `npx -y modern-web-guidance@latest`.
  The `@latest` form downloads and executes whatever version is newest on npm
  at every call. Keep the skill's other arguments, such as `--skill-version`.
- Follow the skill's search, retrieve and verify steps. Treat a retrieved guide
  as the default unless the repo states its own browser support policy.
- Replace the skill's "Disclose Skill Usage" step. Do not add a
  `### Modern Web Guidance` section. Name a guide id in your reply only when it
  changed the code, in one line with the reason.
- If you deliberately skip the skill for a web task, say so.
<!-- /rules:modern-web -->

## Outbound Messages

<!-- rules:outbound-messages -->
A message that leaves this machine in Magnus's name goes out only after he
says "send" for that exact text. This covers email, Slack, LinkedIn, iMessage,
Vibbo, GitHub comments to people outside his own repos, and any reply or
forward.

1. Write the full draft inline in your chat reply: recipient, subject, and the
   complete body as it will be sent. A file path, a Gmail draft id or a
   summary is not a draft he can read.
2. Stop and wait. "Ser bra ut", "ok" or a thumbs-up on an earlier version is
   not a send. Any edit restarts the cycle with the new full text.
3. After he says "send", send that text unchanged and report what went out.

Saving a draft in Gmail is fine without asking; say that it is a draft and
that nothing was sent. In Claude Code the send tools also sit behind an `ask`
permission rule, so the approval prompt shows the final text once more.
<!-- /rules:outbound-messages -->

## Dev Server

<!-- rules:dev-server -->
If a project ships an agent-friendly dev command (a background launcher with
idempotent status/stop, e.g. `make dev` / `make dev-status` / `make dev-stop`
in hei-huset-agent), use it: those are safe for me to start, query, and stop.
Otherwise, when servers are run manually in separate terminals, assume they're
already running and don't launch them in the foreground (a foreground `dev`
blocks indefinitely).
<!-- /rules:dev-server -->

## Task Completion Rules

<!-- rules:task-completion -->
**NEVER stop a task prematurely.** If you start something, finish it.

- Do not stop with "I've made progress, let me pause here" or "I'll update the todo and stop"
- Do not ask for permission to continue mid-task - just continue
- Do not summarize partial progress as if the task is done
- If fixing errors: run the check command, fix ALL errors, repeat until the command exits 0
- If a todo item exists and is not complete, you are NOT done
- If you hit a wall, try a different approach rather than stopping
- Only stop when the task is actually complete with verification

**Do the step yourself.** When the next step is something a tool here can do,
run it instead of handing it to Magnus: a CLI (`gh auth refresh`, an export
script, `gjcli` PIM activation), a logged-in browser session, or a one-time
code that arrives in Gmail. Hand back only what needs his body or his
authority: BankID, approving a payment, a physical action, or a decision that
is his to make.

Persistence does not permit scope expansion, bypassing a safety boundary, or
repeating failed work without new information. When safe in-scope approaches
are exhausted, or the next step needs user input or new authority, report the
blocker and the smallest change that would unblock it.

**Completion means:**
- Build/type-check commands exit 0
- Tests pass (if applicable)
- All todo items marked complete
- The original request is fully satisfied, not partially
<!-- /rules:task-completion -->

## Refactoring

<!-- rules:refactoring -->
Keep behavior-preserving refactoring separate from behavior changes so each can be reviewed independently.
When prerequisite refactoring materially simplifies the requested change, explain why and do it first.
Propose optional refactoring with its scope and benefit before including it.
Pause between phases only when I request a review checkpoint.
<!-- /rules:refactoring -->

## Writing Style

Synced from `scripts/agents/rules/writing-style.md` by `scripts/agents/sync-rules.sh`.
Edit the source, not the block.

<!-- rules:writing-style -->
- **Never use em dashes** (—). Use alternatives: commas, parentheses, colons, semicolons, or separate sentences.
- Write plainly: one idea per sentence, active voice, present tense. Prefer the short common word over the long formal one. Cut hedges, filler, and throat-clearing.
- Keep prose sentences under ~25 words. Split a longer one in two.
- Use a table or a list when the content is a set of parallel facts.
- Full ASD-STE100 Simplified Technical English is opt-in, not the default. Use it when I ask for it, or when I run `/wait-what`.
<!-- /rules:writing-style -->

## No Slop

<!-- rules:no-slop -->
This applies to your own prose in every response, not only when I ask for it. `/humanize` is the deep on-demand pass over text I hand you; this is what you must not write in the first place.

**Write at the register first, because that is where the behaviour lives.** State the claim directly, then qualify it. Do not withhold it through a setup clause and deliver it as a payoff, and do not close every paragraph on its strongest phrasing instead of its most useful qualification. Punchy fragments, the emphatic colon, terminal emphasis and most of the phrase list below are surfaces of that one habit, so fixing them one at a time leaves the cause.

**The list below is a detector for what slips past that instruction, not the primary rule.** It is not exhaustive, and naming tokens is weaker than naming the register: ban an enumerated phrase and the habit moves into a synonym nobody listed. Use the register instruction to write, and this list to check.

- **Never emit citation artifacts.** `utm_source=chatgpt.com`, `oai_citation`, `:contentReference`, `turn0search`, `grok_render_citation`, `【NN†...】`, `[attached_file:N]`, placeholder dates (`2025-XX-XX`), placeholder URLs.
- **No negative parallelism.** "It's not just X, it's Y", "This isn't about X. It's about Y." State the claim in positive form.
- **No rule-of-three padding** when two or four is the real number, and no repeated sentence openings for rhythm.
- **No puffery or stakes inflation.** "game-changing", "revolutionary", "seamless", "a testament to", "stands as", "in today's fast-paced".
- **No weasel attributions.** "studies show", "experts say", "many companies", with no named source.
- **No superficial `-ing` tails.** "..., highlighting the importance of...", "..., underscoring the need for...". Cut the clause, or name the actual consequence.
- **No emphatic colon doing an em dash's job.** A colon is for a real list or a quote.
- **No craft-metaphor verbs or abstract metaphor nouns** standing in for the specific: *sanded down, stitched together, distilled, crystallized, surfaced, anchored*; *substrate, wedge, vector, nexus, bedrock, "API surface", endgame*. Say what actually happened. In-domain uses are correct and stay.
- **Name the mechanism, not the feeling.** "`.toSQL()` returns the exact string sent to the database", not "SQL you can read".
- **No chatbot scaffolding.** No "Great question!", "I hope this helps!", "Let me know if you need anything else", "You're absolutely right!", and no closing summary that restates what I just read.
- **Never invent a specific to sound concrete.** No fabricated numbers, sources, quotes or anecdotes. If the specific does not exist, say that, or leave it out.
- **Cut any sentence that would read identically in another project's docs.** It says nothing about this one.
<!-- /rules:no-slop -->

## Norwegian Text

<!-- rules:norwegian -->
- When working with Norwegian text, always ensure correct grammar and spelling, including proper use of **æ, ø, å** (and **Æ, Ø, Å**). Verify these characters are not accidentally replaced with ae, o, a or other ASCII equivalents.
<!-- /rules:norwegian -->

## GitHub References

<!-- rules:github-refs -->
- **Always render a GitHub reference as a markdown link, never as bare text.** This applies everywhere: chat replies, commit bodies, PR and issue descriptions, review comments, and docs. Covers issues, pull requests, workflow runs, commits, releases, discussions, projects and gists.
- Link text is the short human form, and the target is the full URL:
  - `#1731` → `[#1731](https://github.com/<owner>/<repo>/pull/1731)`
  - a workflow run → `[run 18234567890](https://github.com/<owner>/<repo>/actions/runs/18234567890)`
  - a commit → `[3bf4ae5b](https://github.com/<owner>/<repo>/commit/3bf4ae5b...)`
  - another repo's issue → `[gjensidige/skills#39](https://github.com/gjensidige/skills/issues/39)`
- Resolve the owner and repo from the working directory's `origin` remote when they are not stated. If you cannot determine the real URL, say so rather than inventing one; a wrong link is worse than a bare number.
- **One deliberate exception: text that GitHub itself renders.** Inside an issue body, PR description, or a comment posted to GitHub, a bare `#1731` already autolinks, so leave it bare there. The rule is about surfaces that do not autolink, which is everything else, including this chat.
- Do not link the same reference more than once in a short passage. First mention links, later mentions stay plain.
<!-- /rules:github-refs -->

## RTK - Rust Token Killer

Inlined deliberately. Claude Code expands `@RTK.md` imports; **you do not**. This file previously ended with a bare `@RTK.md`, which reached you as three literal characters and nothing else, so these rules never applied in Codex. Verified 25.07.2026 with `codex debug prompt-input`. Keep the content here rather than reintroducing an import.

Token-optimized CLI proxy (60-90% savings on dev operations).

### Meta commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze agent history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

### Installation verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

Name collision: if `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

### Hook-based usage

Codex's PreToolUse hook in `hooks.json` calls the tracked
`.codex/hooks/rtk-rewrite.sh` adapter. The adapter uses `rtk rewrite` and returns
Codex's `updatedInput` JSON. Example: `pytest` becomes `rtk pytest`.

Do not use `rtk hook claude` here. Its input and output protocol is specific to
Claude Code, so Codex accepts the command but receives no usable rewrite.

**It silently truncates large output**, including `du`, removing middle rows from a sorted list so the result still looks complete and correctly sorted. For any disk-size or large-output work, run `rtk proxy <cmd>` instead, and sanity-check that listed entries sum to roughly the parent total.

## Context7

Synced from `scripts/agents/rules/context7.md` by `scripts/agents/sync-rules.sh`. This
rule reached Claude Code and OpenCode but never you, because it lived only in
`scripts/agents/rules/`, and this file was not a target. Added 11.08.2026.

<!-- rules:context7 -->
Before you write or debug code against a library, framework, SDK, CLI or cloud
API, load the `find-docs` skill and fetch the current docs, even for a library
you know well. It covers API syntax, configuration, version migration and
setup. Skip it for refactoring, business logic and general concepts. Without
the skill, run `npx ctx7@latest library <name> "<question>"`, then
`npx ctx7@latest docs <id> "<question>"`.
<!-- /rules:context7 -->
