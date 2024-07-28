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
  - [Updating the color theme of Alacritty](#updating-the-color-theme-of-alacritty)
  - [Configuring Raycast](#configuring-raycast)
  - [Configuring VS Code](#configuring-vs-code)
    - [Managing keybindings, settings and snippets](#managing-keybindings-settings-and-snippets)
    - [Managing extensions](#managing-extensions)
  - [Configuring Brave Browser](#configuring-brave-browser)

## Prerequisites

MacOS comes pre-installed with `git` and `brew`, but I will include instructions on how to install them for completeness.

```sh
# Ensure you have Homebrew installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Ensure you have Git installed
brew install git
```

## Getting started

Now that you have `git` and `brew` installed, you can clone this repository and use `stow` to manage your dotfiles. When cloning the repository, **it is important to clone it into `$HOME/dotfiles`**. This is because the `stow` command will create symbolic links relative to the current directory, so it is important to clone the repository into the `$HOME` directory to ensure that the symbolic links are created correctly.

```sh
# Clone the repository into a specified directory
git clone https://github.com/magnusrodseth/dotfiles.git $HOME/dotfiles

# Navigate to the dotfiles directory
cd $HOME/dotfiles

# Run the install script
sh install.sh
```

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
- [Fira Code Nerd Font](https://www.nerdfonts.com/font-downloads), for the font used in the terminal
- [`alacritty`](https://github.com/alacritty/alacritty), for a fast terminal emulator
- [`raycast`](https://www.raycast.com/), for a Spotlight replacement with extensions, window management, etc.

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

For more information on the zsh-related tools, refer to [this YouTube video](https://www.youtube.com/watch?v=ud7YxC33Z3w).

### `lazygit`-related tools

- [`lazygit`](https://github.com/jesseduffield/lazygit), for a simple terminal UI for git
- [`bunnai`](https://github.com/chhoumann/bunnai), a CLI to inject AI-generated commit messages into `lazygit`

In order to change the AI-generated commit message template, edit the [`.bunnai-template`](/.bunnai-template) file. Inspect the `lazygit` configuration in the [`.config/lazygit`](/.config/lazygit) directory to inspect how to use `bunnai` with `lazygit`.

## Updating the color theme of Alacritty

The themes for Alacritty are downloaded from the [`alacritty-theme`](https://github.com/alacritty/alacritty-theme) repository. They are stored in the [`.config/alacritty/themes`](/.config/alacritty/themes) directory. To update the color theme of Alacritty, simply update the `import` statement in the [`.config/alacritty/alacritty.toml`](/.config/alacritty/alacritty.toml) file.

```toml
# Replace {theme} with the filename of the theme you want to use from the `alacritty-theme` repository
import = ["~/.config/alacritty/themes/{theme}.toml"]
```

## Configuring Raycast

The Raycast configuration is stored in [`.config/raycast`](/.config/raycast), in the most recent `*.rayconfig` file. After installing Raycast, open Settings using `CMD + ,` > `Advanced` > `Import / Export` > `Import` > `Select File`. Select the most up-to-date file from the folder.

Note that Raycast reads its config and extensions from `~/.config/raycast`, so the [`extensions`](/.config/raycast/extensions/) located in the `dotfiles` are required to be there. **Do not delete the `extensions` directory**.

## Configuring VS Code

### Managing keybindings, settings and snippets

The relevant stuff to backup for VS Code includes the settings, keybindings, snippets, and extensions. On Mac, VS Code settings are stored in `~/Library/Application Support/Code/User/`. Hence, it is mirrored in this `dotfiles` configuration.

Simply running `stow .` as detailed above will symlink the necessary files to the correct location.

### Managing extensions

Regarding extensions, we don't want to actually link all extensions found in the `~/.vscode/extensions` directory, as this takes up a lot of space. Rather, I have written a script called [`./scripts/vscode/extensions.sh`](/scripts/vscode/extensions.sh) that serves to **export** existing extensions to the file [`vscode_extensions.txt`](/scripts/vscode/vscode_extensions.txt), and **install** them on a new machine. Use this script to manage extensions in VS Code.

```sh
# Export extensions
sh ./scripts/vscode/extensions.sh export

# Install extensions
sh ./scripts/vscode/extensions.sh install
```

> Note that the list of extensions is manually maintained by me, i.e. running the `export` option in the script must be done when new extensions are installed, and the list must be updated in the script. However, I do not install extensions often, so this is not a big issue.

## Configuring Brave Browser

Brave is the web browser used. It is installed in the [`install.sh`](/install.sh) script. When that is finished, set the wallpaper and configure relevant extension options located in the [`browser`](/browser) directory.
