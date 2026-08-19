## Personal Hubs

Cross-cutting repos I refer to from anywhere (paths are `$HOME`-relative; identical layout on both machines):

- `~/dev/personal/vault`: Obsidian second brain. Notes, people, projects, meetings, health, travel, Personlig Økonomi. Read its `AGENTS.md` before writing to it. Use the `read-up-on` skill for briefings, the `vault` skill for capturing knowledge.
- `~/dev/personal/presentations`: all my talks and slide decks (TanStack Start app, deployed to presentations.magnusrodseth.com). Read its `AGENTS.md` before working in it. Use the `scaffold-presentation` skill to create new decks.
- `~/dotfiles`: machine config, stow-managed. Every skill I author lives in `~/dotfiles/.claude/skills/` (that is the authoring path for all agents, not a Claude-only directory). `scripts/skills/link-dotfiles-skills.sh` symlinks each one into both user-scope skill roots: `~/.claude/skills/` for Claude Code, and `~/.agents/skills/` for you. Run it after adding a skill. `~/.codex` is a real directory, NOT a symlink into dotfiles, and `~/.codex/skills/` holds only the preinstalled `.system/` skills.

### Skills you can and cannot see

You discover skills in `~/.agents/skills/` (user scope) and `<repo>/.agents/skills/` (project scope). You never read `.claude/skills/` at any level, so a skill present there and absent from `.agents/skills/` is invisible to you no matter what this file says about it.

Being on disk is not enough either. You pack the available-skills list into a fixed context budget (roughly 19-22k characters), shortening descriptions to fit and then omitting the overflow, so with ~325 skills installed some are silently left out of your prompt. If a skill named here is not in your available-skills list, say so plainly instead of improvising a substitute; do not report it as missing from the machine, because it is probably installed and merely omitted. `rg --files ~/.agents/skills -g SKILL.md` shows what is actually on disk.

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

All other commands are rewritten automatically by the `rtk hook claude` PreToolUse hook in `hooks.json` (transparent, 0 tokens overhead). Example: `git status` becomes `rtk git status`.

**It silently truncates large output**, including `du`, removing middle rows from a sorted list so the result still looks complete and correctly sorted. For any disk-size or large-output work, run `rtk proxy <cmd>` instead, and sanity-check that listed entries sum to roughly the parent total.

## Context7

Synced from `scripts/agents/rules/context7.md` by `scripts/agents/sync-rules.sh`. This
rule reached Claude Code and OpenCode but never you, because it lived only in
`scripts/agents/rules/`, and this file was not a target. Added 11.08.2026.

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
