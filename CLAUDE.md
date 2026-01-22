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

The `install.sh` script runs in sequence:
1. Stow symlinks
2. Homebrew packages from `Brewfile`
3. Cargo packages from `scripts/cargo/cargo_packages.txt`
4. pnpm packages from `scripts/pnpm/pnpm_packages.txt`
5. Yazi plugins
6. macOS App Store apps
7. tmux plugin manager setup
8. macOS system defaults
9. bat cache build

## Key Commands

```bash
# Package management
brew bundle                              # Install Homebrew packages
./scripts/cargo/packages.sh install      # Install Cargo packages
./scripts/pnpm/packages.sh install       # Install pnpm packages

# Export current packages to lists
./scripts/cargo/packages.sh export
./scripts/pnpm/packages.sh export

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
- **Default editor**: Windsurf (`$EDITOR`)

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

**Important**: Do not delete `~/.config/raycast/extensions/` directory.

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
  alacritty/              # Terminal (themes in themes/)
  ohmyposh/               # Shell prompt
  yazi/                   # File manager
  opencode/               # OpenCode AI config
  superpowers/skills/     # Agent collaboration skills
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
