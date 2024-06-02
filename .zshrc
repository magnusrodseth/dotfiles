# Path to oh-my-zsh installation
export ZSH="/Users/magnusrodseth/.oh-my-zsh"
export DEFAULT_USER="$(whoami)"

CONFIG_DIR="~/.config/lazygit"

# Plugins
plugins=(
    git 
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-z
    vi-mode
    tmux
)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# zsh scripts
source ~/zsh/aliases.sh
source ~/zsh/functions.sh
source ~/zsh/nvm.sh
source ~/zsh/bun.sh
source ~/zsh/fzf.sh
source ~/zsh/google.sh
source ~/zsh/nvim.sh
source ~/zsh/starship.sh
source ~/zsh/pnpm.sh

# Random exports
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$(brew --prefix bison)/bin:$PATH"

# bun completions
[ -s "/Users/magnusrodseth/.bun/_bun" ] && source "/Users/magnusrodseth/.bun/_bun"
