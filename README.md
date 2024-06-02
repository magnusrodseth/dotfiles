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
