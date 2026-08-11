## Personal Hubs

Cross-cutting repos I refer to from anywhere (paths are `$HOME`-relative; identical layout on both machines):

- `~/dev/personal/vault`: Obsidian second brain. Notes, people, projects, meetings, health, travel, Personlig Økonomi. Read its `CLAUDE.md` before writing to it. Use the `read-up-on` skill for briefings, the `vault` skill for capturing knowledge.
- `~/dev/personal/presentations`: all my talks and slide decks (TanStack Start app, deployed to presentations.magnusrodseth.com). Read its `AGENTS.md` before working in it. Use the `scaffold-presentation` skill to create new decks.
- `~/dotfiles`: machine config, stow-managed. Skills I author live in `~/dotfiles/.claude/skills/` as real dirs; skills installed via `npx skills` land in `~/.agents/skills/` and are symlinked into dotfiles from there.
  - `~/.claude` is a real directory, NOT a symlink to `~/dotfiles/.claude`. Stow links individual entries into the repo (`CLAUDE.md`, `RTK.md`, `commands`), but `~/.claude/skills/` is a real dir managed per-entry by `scripts/skills/link-dotfiles-skills.sh`.
  - **`~/.agents/skills/<name>` is the source of truth for every skill.** It is either a real dir (installed, provenance in `skill-lock.json`) or a symlink into `~/dotfiles/.claude/skills/` (authored). `~/.claude/skills/<name>` is ALWAYS just a symlink to `../../.agents/skills/<name>`. Read `~/.agents/skills/<name>` when checking whether a skill is current.
  - Reason: Claude Code reads only `~/.claude/skills`, while Codex, the ChatGPT app, and **Zed** read only `~/.agents/skills`. Zed's scan is flat, one level deep, and never looks at `.claude` at all. Mirroring one root into the other is what stops the tools disagreeing.
  - Until 02.08.2026 the two roots were linked independently, so `npx skills` real dirs shadowed the dotfiles copies silently: 42 skills had diverged, 4 with real content differences. `check-skill-integrity.sh` now fails on any `.claude` entry that is not a mirror symlink, and on any authored skill shadowed by an installed copy.

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

**Completion means:**
- Build/type-check commands exit 0
- Tests pass (if applicable)
- All todo items marked complete
- The original request is fully satisfied, not partially
<!-- /rules:task-completion -->

## Writing Style

<!-- rules:writing-style -->
- **Never use em dashes** (—). Use alternatives: commas, parentheses, colons, semicolons, or separate sentences.
- Write plainly: one idea per sentence, active voice, present tense. Prefer the short common word over the long formal one. Cut hedges, filler, and throat-clearing.
- Keep prose sentences under ~25 words. Split a longer one in two.
- Use a table or a list when the content is a set of parallel facts.
- Full ASD-STE100 Simplified Technical English is opt-in, not the default. Use it when I ask for it, or when I run `/wait-what`.
<!-- /rules:writing-style -->

## Norwegian Text

<!-- rules:norwegian -->
- When working with Norwegian text, always ensure correct grammar and spelling, including proper use of **æ, ø, å** (and **Æ, Ø, Å**). Verify these characters are not accidentally replaced with ae, o, a or other ASCII equivalents.
<!-- /rules:norwegian -->

## Context7

<!-- rules:context7 -->
Use the `ctx7` CLI to fetch current documentation whenever the user asks about a library, framework, SDK, API, CLI tool, or cloud service -- even well-known ones like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. This includes API syntax, configuration, version migration, library-specific debugging, setup instructions, and CLI tool usage. Use even when you think you know the answer -- your training data may not reflect recent changes. Prefer this over web search for library docs.

Do not use for: refactoring, writing scripts from scratch, debugging business logic, code review, or general programming concepts.

## Steps

1. Resolve library: `npx ctx7@latest library <name> "<user's question>"` — use the official library name with proper punctuation (e.g., "Next.js" not "nextjs", "Customer.io" not "customerio", "Three.js" not "threejs")
2. Pick the best match (ID format: `/org/project`) by: exact name match, description relevance, code snippet count, source reputation (High/Medium preferred), and benchmark score (higher is better). If results don't look right, try alternate names or queries (e.g., "next.js" not "nextjs", or rephrase the question)
3. Fetch docs: `npx ctx7@latest docs <libraryId> "<user's question>"`
4. Answer using the fetched documentation

You MUST call `library` first to get a valid ID unless the user provides one directly in `/org/project` format. Use the user's full question as the query -- specific and detailed queries return better results than vague single words. Do not run more than 3 commands per question. Do not include sensitive information (API keys, passwords, credentials) in queries.

For version-specific docs, use `/org/project/version` from the `library` output (e.g., `/vercel/next.js/v14.3.0`).

If a command fails with a quota error, inform the user and suggest `npx ctx7@latest login` or setting `CONTEXT7_API_KEY` env var for higher limits. Do not silently fall back to training data.
<!-- /rules:context7 -->

@RTK.md
