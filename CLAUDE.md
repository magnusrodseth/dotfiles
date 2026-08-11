# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles repository using GNU `stow` for symlink management. The repo must be cloned to `$HOME/dotfiles` for symlinks to resolve correctly.

## Installation & Setup

```bash
# Full installation (requires sudo for macOS defaults)
./install.sh

# Manual stow (creates symlinks to ~/)
stow .
```

`install.sh` is **honest** (every step reports its real exit status),
**resilient** (a failing step is recorded but does not abort the run; the
script exits non-zero at the end listing what failed), and **idempotent**
(safe to re-run; it converges toward a fully set-up machine). It sources
`.zshenv` (not the interactive `.zshrc`) to put freshly-installed tools on
PATH, and calls every sub-script with `bash`.

Steps, in order:
1. Ensure Homebrew, ensure stow
2. Init git submodules (`.tmux/plugins/*`; without this a fresh clone gets a
   broken tmux and a failing tpm step)
3. Sync shared agent rules into the three agent instruction files
   (`scripts/agents/sync-rules.sh sync`); runs before stow so the spliced
   content is what gets symlinked
4. Stow symlinks (`stow --restow .`)
5. Homebrew packages from `Brewfile` (fonts via `font-fira-code-nerd-font`, and
   VS Code extensions via the `vscode` entries)
6. Cargo packages from `scripts/cargo/cargo_packages.txt`
7. pnpm packages from `scripts/pnpm/pnpm_packages.txt`
8. npm global packages from `scripts/npm/npm_packages.txt` (this is where `gws`,
   `ctx7`, `agent-browser` and `playwriter` come from; skills depend on them)
9. Agent skills from `scripts/skills/skill-lock.json`
10. Link dotfiles-authored skills into `~/.agents/skills/`, then mirror that
   whole root into `~/.claude/skills/`
11. Enable repo git hooks (`core.hooksPath scripts/githooks`; pre-commit
    validates skills, rejects skills that duplicate a lock entry, checks script
    refs, and gitleaks-scans the staged diff)
12. macOS App Store apps
13. tmux plugin manager (tpm) setup
14. macOS system defaults
15. Default apps for developer file types (`scripts/macos/file-associations.sh`)
16. bat cache build

install.sh must never source `~/.zshenv`. It did until 28.07.2026, and since
that file is zsh (`typeset -U path`, `path=( ... )`), bash 3.2 died on it under
`set -u` before step 1 ran. PATH is bootstrapped natively in `bootstrap_env()`;
keep it in sync with `.zshenv` by hand.

After installing, run `bash scripts/doctor.sh` to verify the machine matches
the dotfiles' desired state. `doctor.sh` only reads state; it prints a ✓/✗
checklist (symlinks, Brewfile, cargo/pnpm/npm/VS Code packages, skills, fonts, key
CLI tools, file-type defaults) and exits non-zero if anything is missing. This is
the convergence target: run install → run doctor → fix what's red → repeat until
green.

## Key Commands

```bash
# Verify machine state against the dotfiles (read-only checklist)
bash scripts/doctor.sh

# Package management
# Scripts are committed mode 644, so invoke them with `bash`, not `./`.
brew bundle                                   # Homebrew packages, fonts, VS Code extensions
bash scripts/cargo/packages.sh install        # Install Cargo packages
bash scripts/pnpm/packages.sh install         # Install pnpm packages
bash scripts/npm/packages.sh install          # Install npm global packages
bash scripts/skills/packages.sh install       # Restore agent skills from lock file
bash scripts/skills/validate-skills.sh --links  # SKILL.md frontmatter + symlinks

bash scripts/agents/sync-rules.sh sync             # splice shared rules into agent files
bash scripts/agents/sync-rules.sh check            # drift check, exit 1 if behind

# Export current packages to lists
bash scripts/cargo/packages.sh export
bash scripts/pnpm/packages.sh export
bash scripts/npm/packages.sh export
bash scripts/skills/packages.sh export        # Snapshot skill-lock.json to dotfiles

# Drift check: what is installed but declared nowhere?
brew bundle cleanup --file=Brewfile           # dry run without --force

# macOS defaults
bash scripts/macos/defaults.sh

# Default apps for developer file types (Get Info > Change All, scripted)
bash scripts/macos/file-associations.sh status      # drift, exit 1 if any
bash scripts/macos/file-associations.sh apply       # converge (~95s, silent)
bash scripts/macos/file-associations.sh check ts    # explain one extension
```

## Architecture

### Stow Configuration

`.stow-local-ignore` excludes from symlinking:
- `fonts/`, `macos/`, `scripts/`, `browser/`, `google-cloud-sdk/`
- `Brewfile`, `install.sh`
- The repo-root `CLAUDE.md` and `AGENTS.md`. Both patterns are anchored
  (`^/CLAUDE\.md$`), and must stay that way: a pattern with no `/` is compiled
  into a *segment* regexp and tested against every path component, so a bare
  `CLAUDE.md` also silently un-stowed `.claude/CLAUDE.md`, the globally-loaded
  instruction file.
- Agent trees that are machine-local or derived: `.agents`, `.agent`, `.cursor`,
  `.kiro`, `.windsurf`, `.claude/skills`, `.config/op`
- Nothing under `Library/` is excluded. All of it is stowed, including
  `Library/LaunchAgents/*.plist`, so `stow` installs launch agents on a new
  machine. The `!`-prefixed lines in the file are inert: stow has no negation
  syntax, so they exclude nothing and grant nothing.

### Shell (Zsh)

- Plugin manager: `zinit`
- Prompt: `oh-my-posh` (config at `.config/ohmyposh/config.toml`)
- History: `atuin` for cross-machine sync
- Key tools remapped: `vim`→`nvim`, `ls`→`eza`, `cd`→`zoxide`, `ps`→`procs`,
  `top`→`btm`, `cp`→`xcp`. There is no `cat`→`bat` alias; `bat` is configured
  (`.config/bat/`) but is invoked by name.
- `^R` is atuin. zsh-vi-mode rebuilds the keymap after `.zshrc` finishes, so
  every binding is re-applied through `zvm_after_init_commands`. Add new
  bindkeys there as well as inline, or they will be silently discarded.

Local secrets go in `zsh/ignored/` (auto-sourced, gitignored).

### Editor Configurations

- **Neovim**: LazyVim config in `.config/nvim/`
- **VS Code**: Settings symlinked from `Library/Application Support/Code/User/`
- **Default editor**: Zed (`$EDITOR="zed -w"` in `.zshenv`)
- Note: `.zshenv` holds env vars + PATH; `.zshrc` holds interactive shell config only.

### Claude Code Integration

Settings in `.claude/settings.json`:
- `permissions` is `{"defaultMode": "bypassPermissions"}`. There has never been
  an allow-list here. Note the `.zshrc` comment: this mode is ignored when read
  as project settings, which is why the shell aliases pass the CLI flag instead.
- Hooks: `Notification` and `Stop` play sounds; `PreToolUse` runs `rtk hook
  claude`, which rewrites every Bash command an agent runs. If a command behaves
  oddly under an agent, that hook is the first thing to check, and
  `rtk proxy <cmd>` bypasses it.
- `enabledPlugins`: seven official LSP plugins plus `cloudflare@cloudflare`.
- `.claude/settings.local.json` also exists and is gitignored globally.

Custom commands in `.claude/commands/`:
- `ship.md` - Automated commit and push

Shell aliases (all pass `--dangerously-skip-permissions` explicitly):
- `clc` → `claude --continue`
- `clr` → `claude --resume`
- `ship` is a shell *function*, not `/ship`: a headless `claude -p` run pinned to
  haiku with `--allowedTools "Bash(git *)"`.

### OpenCode Configuration

Located at `.config/opencode/`:
- MCP servers: Playwright (local), Context7 (remote)
- Custom agents defined in `oh-my-opencode.json` (oracle, librarian, explore, etc.)

### Agent skill roots

One rule, enforced by `scripts/skills/link-dotfiles-skills.sh`:

```
~/.agents/skills/<name>   canonical: real dir (installed, see skill-lock.json)
                          or symlink into ~/dotfiles/.claude/skills (authored)
~/.claude/skills/<name>   ALWAYS a symlink -> ../../.agents/skills/<name>
```

Three agents read these and only one reads `.claude`: Claude Code reads
`~/.claude/skills`; Codex, the ChatGPT app, and **Zed** read `~/.agents/skills`.
Zed is the strict one, it scans only `.agents/skills`, exactly one level deep,
and rejects a skill outright if `name` is not `[a-z0-9-]{1,64}` or `description`
is empty. Every skill's `name + description` also shares a fixed 50KB catalog
budget, and on overflow Zed drops everything after the offender in path order
rather than just the large ones. `check-skill-integrity.sh` warns from 85%.

Authored skills still live in this repo under `.claude/skills/` (the
stow-managed authoring home); the link script is what makes `~/.agents`
canonical at runtime. Never vendor a skill that `skill-lock.json` already
installs: the installed copy wins in every agent and the committed one becomes
dead code. `scripts/skills/check-staged-skills.sh` rejects that at commit time.

Before 02.08.2026 the two roots were linked independently and `npx skills` real
dirs silently shadowed the dotfiles copies. 42 skills had diverged, 4 of them
with real content differences that made Claude Code and Zed load different text
for the same skill name.

### Shared agent rules

Instructions that must apply in every agent live once, in
`scripts/agents/rules/<name>.md` (body only, no heading), and are spliced into
each agent's own instruction file by `scripts/agents/sync-rules.sh`:

```
scripts/agents/rules/          .claude/  .codex/  opencode/
  dev-server.md                   x         x
  task-completion.md              x         x
  writing-style.md                x         x         x
  norwegian.md                    x         x
  context7.md                     x         x         x
```

Each target takes its own list, in `MANIFEST`. OpenCode is deliberately thin: it
carries only the two rules that change what it does on every task. Widen its
list on purpose, not for symmetry.

The target file owns the `##` heading and the position. The script owns only the
bytes between `<!-- rules:<name> -->` and `<!-- /rules:<name> -->`, and rewrites
them verbatim from the source. `sync` converges, `check` exits non-zero on drift
and is wired into `doctor.sh`. A rule file that no target lists is also an error:
it reaches no agent at all.

Three things are deliberate here:

- **Sources live under `scripts/`** because `.stow-local-ignore` already excludes
  that whole directory. Only the spliced copies reach `$HOME`, so there is no
  second path by which an agent could pick up a rule.
- **Not a symlink and not an import.** Codex expands neither. `.codex/AGENTS.md`
  ended with a bare `@RTK.md` for months and Codex received three literal
  characters, so those rules applied nowhere (verified 25.07.2026 with `codex
  debug prompt-input`). The same class of silent failure is what `check` exists
  to catch.
- **Claude Code is spliced like everything else**, even though it auto-loads
  `~/.claude/rules/*.md` with no `@import` and could have read the sources
  directly. That free ride was the original design and lasted one afternoon: on
  11.08.2026 the em-dash rule moved out of `.claude/CLAUDE.md` into a new file
  under `.claude/rules/`, and because stow had not yet linked it, Claude Code
  had the rule in neither place. One delivery mechanism, three targets, nothing
  undocumented in the path.

What is deliberately **not** shared: `## Personal Hubs` and `## RTK`. Both differ
between Claude Code and Codex on purpose. The Codex copy of Personal Hubs is
written in second person to Codex and carries the "Skills you can and cannot
see" section about its 19-22k character skill-catalog budget; the Codex copy of
RTK explains why it is inlined rather than imported. Flattening either into one
shared body would lose that. The test for sharing a section is not its size, it
is whether the text is addressed to one agent.

### Default apps for file types

`scripts/macos/file-associations.txt` lists ~205 developer extensions that
should open in Zed; `file-associations.sh apply` points them all there.

macOS stores what "Get Info → Change All" does in
`~/Library/Preferences/com.apple.launchservices.secure.plist`, and that file is
deliberately **not** tracked. It is a binary plist (useless in a diff), it is
TCC-protected (a terminal without Full Disk Access cannot even read it), it is
owned by the `lsd` daemon, which caches it in memory and overwrites hand-edits,
and it mixes these bindings with browser/mail/URL-scheme defaults. Intent is
declared in the `.txt` instead and applied through the LaunchServices API.

Four things about this are non-obvious, and all four were learned the hard way:

- **Bindings are per-UTI, not per-extension.** Several developer extensions are
  squatted on by an unrelated type: `.key` is a Keynote presentation, `.pub` an
  MS Publisher document, `.exs` a Logic sampler instrument, `.fs` a GLSL
  fragment shader. Binding those steals the real type. They are listed as
  exclusions at the bottom of the `.txt`, and the engine independently refuses
  any extension resolving to a movie/audio/image/presentation UTI. `.ts` and
  `.mts` are the two deliberate exceptions (they are MPEG-2 transport stream and
  AVCHD video to macOS), allowlisted in `mediaAllowed`.
- **It must run through `/usr/bin/swift`.** The identical
  `LSSetDefaultRoleHandlerForContentType` call from an ad-hoc-signed binary
  raises a modal "keep using X?" panel per extension. `duti` is ad-hoc-signed,
  so a full run there is ~84 dialogs; through Apple-signed `/usr/bin/swift` the
  same calls apply silently. `duti` was tried and rejected for this, and because
  it cannot set dynamic UTIs at all (error -50 on roughly half the list) and
  reports success for a bundle ID matching no installed app.
- **The API is asynchronous.** It returns `noErr` when `lsd` *accepts* the
  change, not when it applies it; the daemon then drains at ~1.7 UTIs/sec, so a
  full run takes ~95s. Reading back sooner reports the old handlers and looks
  like total failure. `apply` polls to convergence instead of sleeping.
- **Extensions no app declares still work.** ~88 of these (`.nix`, `.svelte`,
  `.tf`, `.zig`) resolve to dynamic `dyn.*` UTIs that no installed app claims.
  They bind fine and silently, since there is no incumbent to displace.

Drift is expected: installing or updating VS Code, Xcode or a JetBrains IDE
hands bindings back. `doctor.sh` warns rather than fails, and `apply` is
idempotent, so re-running is the fix.

`.html`/`.htm` are excluded by preference, not collision, so double-clicking
still previews in the browser.

### Raycast

Config at `.config/raycast/`. Import the `*.rayconfig` via Raycast Settings →
Advanced → Import/Export.

**Extensions do not come from this repo.** The entire `.config/raycast/extensions/`
tree is gitignored (not just the source maps), because the compiled JS is
gitignored anyway and a fresh checkout would only ever restore icon-only
`assets/` folders that Raycast then reports as "Could not find command's
executable JS file". They are restored per-machine by Raycast Cloud Sync after
signing in. `doctor.sh` checks for extensions missing their compiled JS as the
safety net. `.config/raycast/config.json` is untracked too: it holds an account
access token that was once committed to this public repo.

### AI Agent Configurations

- `.pi/` - Pi coding agent config (`agent/`, `suggester/`). Roughly 475 MB on
  disk, almost all of it `.pi/agent/npm/node_modules`, which has its own
  `.gitignore` (`*` plus `!.gitignore`) so it stays invisible to git.
- `.config/opencode/` - OpenCode (see above)
- `.claude/` - Claude Code (settings, commands, skills)
- `.codex/`, `.agents/`, `.agent/`, `.cursor/`, `.kiro/`, `.windsurf/` - all
  gitignored except two allowlisted `.codex` files; mostly derived output that
  `scripts/skills/packages.sh install` regenerates.

### Other top-level directories

- `.tt/` - Theme Suggester themes
- `browser/` - Browser extension configs (Dark Reader, Vimium, wallpapers)
- `macos/Wallpapers/` - Desktop wallpapers (assets, not stowed)
- `scripts/macos/` - macOS setup scripts (defaults, App Store install, file
  associations)

## File Organization

```
.zshrc, .zshenv           # Shell configuration
.tmux.conf                # Tmux with Catppuccin theme
.gitconfig                # Git: SSH commit signing, delta pager, gh credential helper
Brewfile                  # 18 taps, 141 formulae, 34 casks, 99 VS Code extensions
.claude/                  # Claude Code settings & commands
.config/
  nvim/                   # LazyVim
  lazygit/                # Git TUI
  ghostty/                # Terminal
  ohmyposh/               # Shell prompt
  opencode/               # OpenCode AI config
scripts/
  cargo/                  # Rust package management
  pnpm/                   # pnpm global package management
  npm/                    # npm global package management (gws, ctx7, agent-browser)
  skills/                 # Agent skill lock file, linking, validation
  githooks/               # pre-commit: skills, script refs, gitleaks
  macos/                  # System defaults & App Store
zsh/
  functions/              # Custom shell functions
  ignored/                # Local secrets (gitignored)
```

## Notes

- Zoxide can be disabled with `DISABLE_ZOXIDE=1`
- oh-my-posh is disabled in Apple Terminal
- bat cache must be rebuilt after theme changes: `bat cache --build`
- VS Code extensions are declared in the Brewfile's `vscode` block and installed
  by `brew bundle`. The old second manifest under `scripts/vscode/` was deleted
  on 28.07.2026: it had drifted two years out of date while the Brewfile block
  stayed exact, and `doctor.sh` was checking the stale one
- `.zshrc` short-circuits for Claude Code shells (`CLAUDECODE=1`) to skip interactive plugin loading
- Four JDKs are installed, not one: `openjdk@11` (required by `pdftk-java`), `openjdk@17` (a leftover nothing depends on), `openjdk@21` (pulled in by `kotlin-language-server`), and a plain `openjdk` 26 as a dependency. All three versioned ones are declared in `Brewfile` so the state shows up in a diff. This line previously claimed @21 was pinned as the only JDK, which had not been true for some time
- Slow completion-generators (uv, ngrok) are deferred until after first prompt via a precmd hook
- `uv` must stay brew-managed. A cargo-installed `uv` was purged on 28.07.2026;
  `.zshenv` puts `~/.cargo/bin` ahead of `/opt/homebrew/bin`, so a cargo copy
  silently shadows brew's. `scripts/cargo/packages.sh export` now refuses to
  write non-crates.io installs for this reason
- The commit path is guarded: `scripts/githooks/pre-commit` runs gitleaks over
  the staged diff. This repo is public and has leaked four credentials; see
  `.gitleaks.toml` for the allowlist, and keep it narrow
- `rtk`'s config lives at `~/Library/Application Support/rtk/config.toml`, which
  is stowed from `Library/Application Support/rtk/`. It is **not** `.config/rtk/`;
  a file there is read by nothing. `git` and `cargo` are in `exclude_commands`
  because rtk silently truncated `git log --name-only` from 1639 paths to 46
- When adding a new tool whose config lives in a stowed dir, gitignore its runtime state (caches, `*-cache.json`, `*.mdb`/lock DBs, `*.bak*`) **before** the first commit so it never enters the tree; `doctor.sh`'s "Repo hygiene" check fails loud if any slips through
