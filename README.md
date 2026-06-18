# cd `~`

## Table of Contents

- [cd `~`](#cd-)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Getting started](#getting-started)
  - [What is `stow`?](#what-is-stow)
    - [Directory structure before using `stow`](#directory-structure-before-using-stow)
    - [Using `stow` to mirror configuration](#using-stow-to-mirror-configuration)
    - [Resulting directory structure after stowing](#resulting-directory-structure-after-stowing)
    - [More information on `stow`](#more-information-on-stow)
  - [Tools used](#tools-used)
    - [`neovim`-related tools](#neovim-related-tools)
    - [`tmux`-related tools](#tmux-related-tools)
    - [`zsh`-related tools](#zsh-related-tools)
    - [`lazygit`-related tools](#lazygit-related-tools)
    - [AI agent tooling](#ai-agent-tooling)
  - [Keeping packages in sync](#keeping-packages-in-sync)
  - [Configuring Raycast](#configuring-raycast)
  - [Configuring editors](#configuring-editors)
    - [Managing keybindings, settings and snippets](#managing-keybindings-settings-and-snippets)
    - [Managing extensions](#managing-extensions)
  - [Configuring Brave Browser](#configuring-brave-browser)

## Prerequisites

macOS ships with `git` (via the Xcode Command Line Tools), but **not** Homebrew. The [`install.sh`](/install.sh) script bootstraps both Homebrew and `stow` for you if they're missing, so the commands below are only needed if you'd rather install them ahead of time.

```sh
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Git if you don't have it
brew install git
```

## Getting started

Now that you have `git` and `brew` installed, you can clone this repository and use `stow` to manage your dotfiles. When cloning the repository, **it is important to clone it into `$HOME/dotfiles`**. This is because the `stow` command will create symbolic links relative to the current directory, so it is important to clone the repository into the `$HOME` directory to ensure that the symbolic links are created correctly.

```sh
# Clone the repository into a specified directory
git clone https://github.com/magnusrodseth/dotfiles.git $HOME/dotfiles

# Navigate to the dotfiles directory
cd $HOME/dotfiles

# Run the install script (bash; safe to re-run, exits non-zero if any step fails)
bash install.sh

# Verify the machine matches the dotfiles afterwards
bash scripts/doctor.sh
```

`install.sh` is idempotent (safe to re-run), reports each step's real exit status, and aggregates failures instead of stopping at the first one. When it finishes, `scripts/doctor.sh` prints a read-only ✓/✗ checklist of what is and isn't set up (symlinks, Homebrew/Cargo/pnpm/VS Code packages, agent skills, fonts, CLI tools) and exits non-zero if anything's missing. The loop is: run install → run doctor → fix what's red → repeat until green.

## What is `stow`?

`stow` is a command-line tool that manages the installation of software packages by creating symbolic links. It is especially useful for managing dotfiles and configuration files in a clean, organized way.

### Directory structure before using `stow`

```sh
~/dotfiles
├── .zshrc
└── config
    └── nvim
        └── init.vim
```

### Using `stow` to mirror configuration

```sh
# Navigate to the dotfiles directory
cd ~/dotfiles

# Use stow to create symbolic links for all the files in the dotfiles directory
stow .
```

### Resulting directory structure after stowing

```sh
~
├── .zshrc -> ~/dotfiles/zshrc
└── .config
    └── nvim -> ~/dotfiles/config/nvim
        └── init.vim

```

### More information on `stow`

Refer to [this YouTube video](https://www.youtube.com/watch?v=y6XCebnB9gs) for more information.

## Tools used

- [`stow`](https://www.gnu.org/software/stow/), for managing dotfiles
- [`brew`](https://brew.sh), for installing software packages
- [`git`](https://git-scm.com), for version control
- [Fira Code Nerd Font](https://www.nerdfonts.com/font-downloads), for the font used in the terminal (installed automatically via the `font-fira-code-nerd-font` Homebrew cask in the `Brewfile`)
- [`ghostty`](https://ghostty.org/), for a fast, native terminal emulator
- [`raycast`](https://www.raycast.com/), for a Spotlight replacement with extensions, window management, etc.
- [`zed`](https://zed.dev), the primary code editor (with [`windsurf`](https://windsurf.com/), [`cursor`](https://cursor.com/), and [`vscode`](https://code.visualstudio.com/) also configured)
- [`brave`](https://brave.com/), the web browser
- [Claude Code](https://www.anthropic.com/claude-code), for AI-assisted development (skills, agents, and commands live under [`.claude`](/.claude))

### `neovim`-related tools

- [`neovim`](https://neovim.io), for text editing
- [`lazyvim`](https://www.lazyvim.org/), for an IDE experience in Neovim that is easy to set up

For more information on the Neovim setup, including plugins and keymaps, refer to the [`lazyvim` documentation](https://www.lazyvim.org/).

### `tmux`-related tools

- [`tmux`](https://github.com/tmux/tmux/wiki), for a terminal multiplexer
- [`tpm`](https://github.com/tmux-plugins/tpm), for managing tmux plugins
- [`catppuccin/tmux`](https://github.com/catppuccin/tmux), for tmux themes. Note that I am using a fork of the original repository, which can be found [in this repository](https://github.com/dreamsofcode-io/catppuccin-tmux).

For more information on the tmux-related tools, refer to [this YouTube video](https://www.youtube.com/watch?v=DzNmUNvnB04).

### `zsh`-related tools

- [`zsh`](https://www.zsh.org), for the shell
- [`zinit`](https://github.com/zdharma-continuum/zinit), for managing zsh plugins
- [`oh-my-posh`](https://ohmyposh.dev/docs/), for a minimal zsh prompt
- [`fzf`](https://github.com/junegunn/fzf), for fuzzy finding
- [`zoxide`](https://github.com/ajeetdsouza/zoxide), for fast directory switching
- [`eza`](https://github.com/eza-community/eza), for a modern, maintained replacement for ls
- [`yazi`](https://yazi-rs.github.io/), for a terminal file manager with Vim-like keybindings

For more information on the zsh-related tools, refer to [this YouTube video](https://www.youtube.com/watch?v=ud7YxC33Z3w).

### `lazygit`-related tools

- [`lazygit`](https://github.com/jesseduffield/lazygit), for a simple terminal UI for git

### AI agent tooling

A large part of this repo is now [Claude Code](https://www.anthropic.com/claude-code) configuration, all under [`.claude`](/.claude):

- **Skills** ([`.claude/skills`](/.claude/skills)) are restored from a lock file rather than committed wholesale. `scripts/skills/packages.sh install` reads [`skill-lock.json`](/scripts/skills/skill-lock.json) and reinstalls every skill on a new machine; `scripts/skills/link-dotfiles-skills.sh` symlinks the dotfiles-authored skills into `~/.claude/skills`.
- **Agents** ([`.claude/agents`](/.claude/agents)), **commands** ([`.claude/commands`](/.claude/commands)), and **rules** ([`.claude/rules`](/.claude/rules)) are committed directly.
- [`CLAUDE.md`](/CLAUDE.md) documents the repo for Claude Code and is the canonical setup runbook.

## Keeping packages in sync

Packages aren't symlinked; they're declared in lists and (re)installed from them. Each manager has an `export` (snapshot what's installed) and `install` (restore from the snapshot) command, so moving to a new machine is just a matter of running the installs.

```sh
bash scripts/cargo/packages.sh export   # or: install
bash scripts/pnpm/packages.sh export    # or: install
bash scripts/vscode/extensions.sh export # or: install
bash scripts/skills/packages.sh export  # or: install
```

Run `bash scripts/doctor.sh` at any time to see, at a glance, which packages, symlinks, fonts, and tools are present versus missing.

## Configuring Raycast

The Raycast configuration is stored in [`.config/raycast`](/.config/raycast), in the most recent `*.rayconfig` file. After installing Raycast, open Settings using `CMD + ,` > `Advanced` > `Import / Export` > `Import` > `Select File`. Select the most up-to-date file from the folder.

Note that Raycast reads its config and extensions from `~/.config/raycast`, so the [`extensions`](/.config/raycast/extensions/) located in the `dotfiles` are required to be there. **Do not delete the `extensions` directory**.

## Configuring editors

[Zed](https://zed.dev) is my primary editor these days, but [Windsurf](https://windsurf.com/), [Cursor](https://cursor.com/), and [VS Code](https://code.visualstudio.com/) are all installed and configured. (`zed -w` is the default `$EDITOR` used by git and scripts.)

### Managing keybindings, settings and snippets

On macOS, editor configuration lives under `~/Library/Application Support/<Editor>/User/`, so it's mirrored in this repo and symlinked by `stow`:

- **VS Code** is mirrored most fully: settings, keybindings, and snippets.
- **Cursor** and **Windsurf** mirror their settings (and Windsurf its keybindings).
- **Zed** tracks its [`keymap.json`](/.config/zed/keymap.json); its `settings.json` is intentionally gitignored.

Running `stow .` as detailed above symlinks all of these to the correct locations.

### Managing extensions

Extensions aren't symlinked (the `~/.vscode/extensions` directory is large). Instead, [`scripts/vscode/extensions.sh`](/scripts/vscode/extensions.sh) **exports** the installed extension list to [`vscode_extensions.txt`](/scripts/vscode/vscode_extensions.txt) and **installs** them on a new machine.

```sh
# Export extensions
bash scripts/vscode/extensions.sh export

# Install extensions
bash scripts/vscode/extensions.sh install
```

> The extension list is maintained manually: re-run `export` after installing new extensions so the list stays current. I don't install extensions often, so this isn't much of a chore.

## Configuring Brave Browser

[Brave](https://brave.com/) is the web browser, installed via the `Brewfile`. The [`browser`](/browser) directory holds the bits that aren't synced automatically: the desktop wallpaper plus exported settings for the [Dark Reader](/browser/Dark-Reader-Settings.json) and [Vimium](/browser/vimium-options.json) extensions. After installing Brave, set the wallpaper and import those extension settings.
