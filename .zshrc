if [[ -f "/opt/homebrew/bin/brew" ]] then
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
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode

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
alias gitui="lazygit"
alias tf="terraform"
alias cat="bat"
alias cp='xcp'
alias find="fd"
alias ps="procs"
alias top="btm"
alias c="code"
alias c.="code ."
alias cd..="cd .."
alias tar-unzip="tar -xvf"
alias tar-zip="tar -cvf"
alias ls="eza -a"
alias l="eza --color=always --long --no-filesize --no-time -a -I .DS_Store"

# Executes when the current directory is changed.
function chpwd() {
  clear
  l
}

# Set the default editor
export EDITOR='/usr/local/bin/nvim'
export VISUAL="$EDITOR"
export LC_ALL=en_US.UTF-8

# pnpm
export PNPM_HOME="/Users/magnusrodseth/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Shell integrations
source <(fzf --zsh)
eval "$(zoxide init --cmd cd zsh)"
