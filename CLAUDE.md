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
2. Stow symlinks (`stow --restow .`)
3. Homebrew packages from `Brewfile` (fonts included via `font-fira-code-nerd-font` cask)
4. Cargo packages from `scripts/cargo/cargo_packages.txt`
5. pnpm packages from `scripts/pnpm/pnpm_packages.txt`
6. VS Code extensions from `scripts/vscode/vscode_extensions.txt`
7. Agent skills from `scripts/skills/skill-lock.json`
8. Link dotfiles-authored skills into `~/.claude/skills/`
9. Yazi plugins
10. macOS App Store apps
11. tmux plugin manager (tpm) setup
12. macOS system defaults
13. bat cache build

After installing, run `bash scripts/doctor.sh` to verify the machine matches
the dotfiles' desired state. `doctor.sh` only reads state; it prints a ✓/✗
checklist (symlinks, Brewfile, cargo/pnpm/VS Code packages, skills, fonts, key
CLI tools) and exits non-zero if anything is missing. This is the convergence
target: run install → run doctor → fix what's red → repeat until green.

## Key Commands

```bash
# Verify machine state against the dotfiles (read-only checklist)
bash scripts/doctor.sh

# Package management
brew bundle                              # Install Homebrew packages (incl. fonts)
./scripts/cargo/packages.sh install      # Install Cargo packages
./scripts/pnpm/packages.sh install       # Install pnpm packages
./scripts/vscode/extensions.sh install   # Install VS Code extensions
./scripts/skills/packages.sh install     # Restore agent skills from lock file

# Export current packages to lists
./scripts/cargo/packages.sh export
./scripts/pnpm/packages.sh export
./scripts/skills/packages.sh export      # Snapshot skill-lock.json to dotfiles

# macOS defaults
./scripts/macos/defaults.sh
```

## Architecture

### Stow Configuration

`.stow-local-ignore` excludes from symlinking:
- `fonts/`, `vscode/`, `macos/`, `scripts/`, `browser/`
- `Brewfile`, `install.sh`
- Most of `Library/` except VS Code/Cursor User settings

### Shell (Zsh)

- Plugin manager: `zinit`
- Prompt: `oh-my-posh` (config at `.config/ohmyposh/config.toml`)
- History: `atuin` for cross-machine sync
- Key tools remapped: `vim`→`nvim`, `cat`→`bat`, `ls`→`eza`, `cd`→`zoxide`

Local secrets go in `zsh/ignored/` (auto-sourced, gitignored).

### Editor Configurations

- **Neovim**: LazyVim config in `.config/nvim/`
- **VS Code/Cursor**: Settings symlinked from `Library/Application Support/{Code,Cursor}/User/`
- **Default editor**: Windsurf (`$EDITOR` in `.zshenv`)
- Note: `.zshenv` holds env vars + PATH; `.zshrc` holds interactive shell config only.

### Claude Code Integration

Settings in `.claude/settings.json`:
- Git-only permissions (status, add, commit, push, diff, log)
- Sound hooks for tool calls
- Multiple plugins enabled (agent-orchestration, feature-dev, etc.)

Custom commands in `.claude/commands/`:
- `sisyphus.md` - Full agent workflow (context → explore → design → implement → review)
- `ship.md` - Automated commit and push

Shell aliases:
- `clc` → `claude --continue`
- `ship` → `claude "/ship"`
- `sis()` → Sisyphus agent harness

### OpenCode Configuration

Located at `.config/opencode/`:
- MCP servers: Playwright (local), Context7 (remote)
- Custom agents defined in `oh-my-opencode.json` (oracle, librarian, explore, etc.)

### Raycast

Config at `.config/raycast/`. Import via Raycast Settings → Advanced → Import/Export.

**Important**: Do not delete `~/.config/raycast/extensions/` directory. Source maps (`*.js.map`) under it are gitignored.

### AI Agent Configurations

- `.pi/` - Pi coding agent config (`agent/`, `suggester/`)
- `.config/opencode/` - OpenCode (see above)
- `.claude/` - Claude Code (settings, commands, skills, agents)

### Other top-level directories

- `.tt/` - Theme Suggester themes
- `browser/` - Browser extension configs (Dark Reader, Vimium, wallpapers)
- `images/` - Screenshots used in README
- `macos/Wallpapers/` - Desktop wallpapers (assets, not stowed)
- `scripts/macos/` - macOS setup scripts (defaults, App Store install)

## File Organization

```
.zshrc, .zshenv           # Shell configuration
.tmux.conf                # Tmux with Catppuccin theme
.gitconfig                # Git with delta pager, lazygit integration
Brewfile                  # ~310 Homebrew dependencies
.claude/                  # Claude Code settings & commands
.config/
  nvim/                   # LazyVim
  lazygit/                # Git TUI
  ghostty/                # Terminal
  ohmyposh/               # Shell prompt
  yazi/                   # File manager
  opencode/               # OpenCode AI config
scripts/
  cargo/                  # Rust package management
  pnpm/                   # Node.js package management
  macos/                  # System defaults & App Store
zsh/
  functions/              # Custom shell functions
  ignored/                # Local secrets (gitignored)
```

## Notes

- Zoxide can be disabled with `DISABLE_ZOXIDE=1`
- oh-my-posh is disabled in Apple Terminal
- bat cache must be rebuilt after theme changes: `bat cache --build`
- VS Code extensions managed separately via script (not symlinked)
- `.zshrc` short-circuits for Claude Code shells (`CLAUDECODE=1`) to skip interactive plugin loading
- Java pinned to `openjdk@21` (the only JDK in `Brewfile`); other versions removed
- Slow completion-generators (uv, ngrok) are deferred until after first prompt via a precmd hook
