## Personal Hubs

Cross-cutting repos I refer to from anywhere (paths are `$HOME`-relative; identical layout on both machines):

- `~/dev/personal/vault`: Obsidian second brain. Notes, people, projects, meetings, health, travel, Personlig Økonomi. Read its `CLAUDE.md` before writing to it. Use the `read-up-on` skill for briefings, the `vault` skill for capturing knowledge.
- `~/dev/personal/presentations`: all my talks and slide decks (TanStack Start app, deployed to presentations.magnusrodseth.com). Read its `AGENTS.md` before working in it. Use the `scaffold-presentation` skill to create new decks.
- `~/dotfiles`: machine config, stow-managed. Skills I author live in `~/dotfiles/.claude/skills/` as real dirs; skills installed via `npx skills` land in `~/.agents/skills/` and are symlinked into dotfiles from there.
  - `~/.claude` is a real directory, NOT a symlink to `~/dotfiles/.claude`. Stow links individual entries into the repo (`CLAUDE.md`, `RTK.md`, `commands`), but `~/.claude/skills/` is a real dir managed per-entry by `scripts/skills/link-dotfiles-skills.sh`.
  - **`~/.agents/skills/<name>` is the source of truth for every skill.** It is either a real dir (installed, provenance in `skill-lock.json`) or a symlink into `~/dotfiles/.claude/skills/` (authored). `~/.claude/skills/<name>` is ALWAYS just a symlink to `../../.agents/skills/<name>`. Read `~/.agents/skills/<name>` when checking whether a skill is current.
  - Reason: Claude Code reads only `~/.claude/skills`, while Codex, the ChatGPT app, and **Zed** read only `~/.agents/skills`. Zed's scan is flat, one level deep, and never looks at `.claude` at all. Mirroring one root into the other is what stops the tools disagreeing.
  - Until 02.08.2026 the two roots were linked independently, so `npx skills` real dirs shadowed the dotfiles copies silently: 42 skills had diverged, 4 with real content differences. `check-skill-integrity.sh` now fails on any `.claude` entry that is not a mirror symlink, and on any authored skill shadowed by an installed copy.

## Browser

<!-- rules:t3-browser -->
Pick the browser by what the page needs, also inside T3 Code. When Magnus names a
browser, use that one.

- **Logged-in sites, or anything that needs his extensions** (1Password and
  others): use `playwriter`. It drives his real Brave through the Playwriter
  extension, with his cookies and extensions. He sees the tab in Brave and can
  take over there. Start every session with `--tab-group "<emoji> <label>"`:
  one emoji for the kind of task, then a one- or two-word label naming the task
  or site, for example `"🛒 REMA-handel"`, `"🧪 Kimaki-test"` or
  `"📬 Innboks"`. Quote the value, because it contains a space. When
  `playwriter browser list` shows more than one browser, pass the Brave row's key
  (`install:Brave:<id>`, different per machine) as `--browser <key>`. Work in a
  tab you opened, and never act on his other tabs. If the extension rejects the
  CLI version, run `npm install -g playwriter@latest`.
- **Local dev servers and public pages, when he wants to watch inline**: use T3's
  built-in browser, the preview tab driven by the `t3-browser` skill. Its profiles
  are separate Electron sessions: no browser extensions, no real logins, no
  1Password.
- **Headless or parallel work with no login**: `agent-browser` with a named
  session.
<!-- /rules:t3-browser -->

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

## Calendar Event Titles

<!-- rules:calendar-titles -->
For meetings with other people, use a title that makes sense to every participant. Prefer names and purpose, for example `Magnus x Ola: Lunsj`.
<!-- /rules:calendar-titles -->

## Context7

<!-- rules:context7 -->
Before you write or debug code against a library, framework, SDK, CLI or cloud
API, load the `find-docs` skill and fetch the current docs, even for a library
you know well. It covers API syntax, configuration, version migration and
setup. Skip it for refactoring, business logic and general concepts. Without
the skill, run `npx ctx7@latest library <name> "<question>"`, then
`npx ctx7@latest docs <id> "<question>"`.
<!-- /rules:context7 -->

@RTK.md
