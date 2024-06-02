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
- [`zsh`](https://www.zsh.org), for the shell
- [`zinit`](https://github.com/zdharma-continuum/zinit), for managing zsh plugins
- [`neovim`](https://neovim.io), for text editing
- [`lazygit`](https://github.com/jesseduffield/lazygit), for a simple terminal UI for git
- [`alacritty`](https://github.com/alacritty/alacritty), for a fast terminal emulator
