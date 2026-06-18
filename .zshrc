#!/bin/zsh
# .zshrc: interactive shell config.
# Env vars and PATH live in .zshenv (sourced earlier, for all shells).

# Skip heavy init for Claude Code shell (env is already set by .zshenv)
if [[ "$CLAUDECODE" == "1" ]]; then
  if [ -d "$HOME/dotfiles/zsh/ignored" ]; then
    for file in "$HOME/dotfiles/zsh/ignored"/*.sh; do
      [ -f "$file" ] && source "$file"
    done
  fi
  return
fi

# ──────────────────────────────────────────────────────────────────────────────
# Zinit (plugin manager)
# ──────────────────────────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Prompt (oh-my-posh). Apple Terminal doesn't support the rendering well.
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/config.toml)"
fi

# Synchronous: needed before prompt or affect first interaction
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-syntax-highlighting

# Deferred: load after first prompt to keep startup snappy
zinit ice wait'0' lucid
zinit light zsh-users/zsh-completions
zinit ice wait'0' lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
zinit ice wait'0' lucid
zinit light paulirish/git-open
zinit ice wait'0' lucid
zinit light lukechilds/zsh-nvm
zinit ice wait'1' lucid depth=1
zinit light jeffreytse/zsh-vi-mode
zinit ice wait'1' lucid
zinit load atuinsh/atuin

# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# ──────────────────────────────────────────────────────────────────────────────
# Completions (compinit). Cache for 24h to skip the slow regen.
# ──────────────────────────────────────────────────────────────────────────────
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qNmh-24) ]]; then
  compinit -C
else
  compinit
fi
zinit cdreplay -q

# Defer slow completion-generators until after first prompt
_defer_completions() {
  command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"
  command -v uvx &>/dev/null && eval "$(uvx --generate-shell-completion zsh)"
  command -v ngrok &>/dev/null && eval "$(ngrok completion 2>/dev/null)"
  add-zsh-hook -d precmd _defer_completions
  unfunction _defer_completions
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _defer_completions

# ──────────────────────────────────────────────────────────────────────────────
# Keybindings & history
# ──────────────────────────────────────────────────────────────────────────────
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ──────────────────────────────────────────────────────────────────────────────
# Aliases
# ──────────────────────────────────────────────────────────────────────────────
alias vim="nvim"
alias vi="nvim"
alias bim="nvim"
alias v="nvim"
alias gitui="lazygit"
alias cp='xcp'
alias ps="procs"
alias top="btm"
alias c.="zed ."
alias z.="zed ."
alias code="zed"
alias oc="opencode"
alias cd..="cd .."
alias tar-unzip="tar -xvf"
alias tar-zip="tar -cvf"
alias ls="eza -a"
alias speedtest="speedtest-cli"
alias l="eza --color=always --long --no-filesize --no-time -a -I .DS_Store"
alias download-mp3='yt-dlp -x --audio-format mp3 --restrict-filenames -o ~/Desktop/%\(title\)s.%\(ext\)s'
alias download-mp4='yt-dlp --format bestaudio[ext=m4a] --merge-output-format mp4 --restrict-filenames -o ~/Desktop/%\(title\)s.%\(ext\)s'
alias o="open ."
alias obs="open -a Obsidian"
alias aliases="alias | sed 's/=.*$/\t -> &/'"
alias bbd="brew bundle dump --force --file=$HOME/Brewfile"
alias ngrok-default="ngrok http --url=bold-gently-weasel.ngrok-free.app"
alias claude="claude --dangerously-skip-permissions"
alias clc="claude --continue --dangerously-skip-permissions"
alias pic="pi -c"

# Headless ship: optimized for speed
unalias ship 2>/dev/null
function ship {
  claude -p "Stage all changes with 'git add -A'. Review the diff. Create a concise conventional commit message (<type>: <description>). Commit and push to current branch. If no changes, report and exit." \
    --model claude-haiku-4-5 \
    --dangerously-skip-permissions \
    --no-session-persistence \
    --allowedTools "Bash(git *)"
}

# Sisyphus prompt harness
sis() { claude --dangerously-skip-permissions --append-system-prompt "$(cat ~/.claude/commands/sisyphus.md)"; }

# Source custom functions
if [ -d "$HOME/zsh/functions" ]; then
    for file in "$HOME/zsh/functions"/*.sh; do
        [ -f "$file" ] && source "$file"
    done
fi

# ──────────────────────────────────────────────────────────────────────────────
# Shell integrations
# ──────────────────────────────────────────────────────────────────────────────
source <(fzf --zsh)
if [ -z "$DISABLE_ZOXIDE" ]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# 1Password CLI plugins (uncomment if using op CLI)
# source "$HOME/.config/op/plugins.sh"

# Source ignored/local secrets
if [ -d "$HOME/dotfiles/zsh/ignored" ]; then
    for file in "$HOME/dotfiles/zsh/ignored"/*.sh; do
        [ -f "$file" ] && source "$file"
    done
fi

# Kiro shell integration (conditional on TERM_PROGRAM)
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Google Cloud SDK
[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && . "$HOME/google-cloud-sdk/path.zsh.inc"
[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/google-cloud-sdk/completion.zsh.inc"

# Report CWD to terminal via OSC 7 (fixes Ghostty new tab directory inheritance).
# Must stay near the end so plugins don't override the precmd hook.
_osc7_cwd() {
  printf '\e]7;file://%s%s\e\\' "$HOST" "$PWD"
}
add-zsh-hook precmd _osc7_cwd

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
