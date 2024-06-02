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
    - [`zsh`-related tools](#zsh-related-tools)
  - [Updating the color theme of Alacritty](#updating-the-color-theme-of-alacritty)

## Prerequisites

```sh
# Ensure you have Git installed
brew install git

# Ensure you have stow installed
brew install stow
```

## Getting started

> TODO: Add instructions on how to bootstrap this setup.

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

- [`neovim`](https://neovim.io), for text editing
- [`lazygit`](https://github.com/jesseduffield/lazygit), for a simple terminal UI for git
- [`alacritty`](https://github.com/alacritty/alacritty), for a fast terminal emulator

### `zsh`-related tools

- [`zsh`](https://www.zsh.org), for the shell
- [`zinit`](https://github.com/zdharma-continuum/zinit), for managing zsh plugins
- [`p10k`](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#zinit), for a minimal zsh prompt
- [`fzf`](https://github.com/junegunn/fzf), for fuzzy finding
- [`zoxide`](https://github.com/ajeetdsouza/zoxide), for fast directory switching
- [`eza`](https://github.com/eza-community/eza), for a modern, maintained replacement for ls

For more information on the zsh-related tools, refer to [this YouTube video](https://www.youtube.com/watch?v=ud7YxC33Z3w).

## Updating the color theme of Alacritty

The themes for Alacritty are downloaded from the [`alacritty-theme`](https://github.com/alacritty/alacritty-theme) repository. They are stored in the [`.config/alacritty/themes`](/.config/alacritty/themes) directory. To update the color theme of Alacritty, simply update the `import` statement in the [`.config/alacritty/alacritty.toml`](/.config/alacritty/alacritty.toml) file.

```toml
# Replace {theme} with the filename of the theme you want to use from the `alacritty-theme` repository
import = ["~/.config/alacritty/themes/{theme}.toml"]
```
