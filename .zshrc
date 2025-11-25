#!/bin/zsh

if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in oh-my-posh
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/config.toml)"
fi

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light lukechilds/zsh-nvm
zinit light Aloxaf/fzf-tab
zinit light paulirish/git-open
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode
zinit load atuinsh/atuin


# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias vim="nvim"
alias vi="nvim"
alias bim="nvim"
alias v="nvim"
alias gitui="lazygit"
alias tf="terraform"
alias cat="bat"
alias cp='xcp'
alias ps="procs"
alias top="btm"
# alias c.="code ."
# alias c.="cursor ."
alias c.="surf ."
alias cd..="cd .."
alias tar-unzip="tar -xvf"
alias tar-zip="tar -cvf"
alias ls="eza -a"
alias speedtest="speedtest-cli"
alias l="eza --color=always --long --no-filesize --no-time -a -I .DS_Store"
alias download-mp3='yt-dlp -x --audio-format mp3 --restrict-filenames -o ~/Desktop/%\(title\)s.%\(ext\)s'
alias download-mp4='yt-dlp --format bestaudio[ext=m4a] --merge-output-format mp4 --restrict-filenames -o ~/Desktop/%\(title\)s.%\(ext\)s'
alias o="open ."
alias skim='/Applications/Skim.app/Contents/MacOS/Skim'
alias aliases="alias | sed 's/=.*$/\t -> &/'"
alias bbd="brew bundle dump --force --file=$HOME/Brewfile"
alias ngrok-default="ngrok http --url=bold-gently-weasel.ngrok-free.app"
alias clc="claude --continue"

# Source all custom functions in the zsh/functions directory
if [ -d "$HOME/zsh/functions" ]; then
    for file in "$HOME/zsh/functions"/*.sh; do
        if [ -f "$file" ]; then
            source "$file"
        fi
    done
fi

# Set the default EDITOR
export EDITOR="$(which cursor)"
export VISUAL="$EDITOR"
export LC_ALL=en_US.UTF-8

# Change the config directory
export XDG_CONFIG_HOME="$HOME/.config"

# pnpm
export PNPM_HOME="/Users/magnusrodseth/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Shell integrations
source <(fzf --zsh)
if [ -z "$DISABLE_ZOXIDE" ]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# dotnet
export PATH="$PATH:$HOME/.dotnet/tools/"

# latexmk for latex
export PATH="/Library/TeX/texbin:$PATH"

# deno
export PATH="/Users/magnusrodseth/.deno/bin:$PATH"

# bun
export PATH="/Users/magnusrodseth/.bun/bin:$PATH"

# Check if the ignored folder exists, and source all files in it
if [ -d "$HOME/dotfiles/zsh/ignored" ]; then
    for file in "$HOME/dotfiles/zsh/ignored"/*.sh; do
        if [ -f "$file" ]; then
            source "$file"
        fi
    done
fi

. "$HOME/.cargo/env"

source /Users/magnusrodseth/.config/op/plugins.sh
. /opt/homebrew/opt/asdf/libexec/asdf.sh
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
eval "$(atuin init zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/magnusrodseth/.cache/lm-studio/bin"

# pnpm
export PNPM_HOME="/Users/magnusrodseth/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# ngrok
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/magnusrodseth/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Added by Antigravity
export PATH="/Users/magnusrodseth/.antigravity/antigravity/bin:$PATH"

# Added by Windsurf
export PATH="/Users/magnusrodseth/.codeium/windsurf/bin:$PATH"
