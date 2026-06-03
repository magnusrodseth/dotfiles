#!/usr/bin/env bash
#
# doctor.sh - verify that this machine matches the dotfiles' desired state.
#
# Prints a checklist of what is and isn't set up, and exits non-zero if
# anything is missing. This is the convergence target for `install.sh`:
# run install, run doctor, fix what's red, repeat until doctor is all green.
#
# It only READS state; it never installs or changes anything.

DOTFILES="$HOME/dotfiles"
cd "$DOTFILES" 2>/dev/null || { echo "Cannot cd to $DOTFILES" >&2; exit 1; }

# --- output helpers ----------------------------------------------------------

if [ -t 1 ]; then
  G=$'\033[32m'; R=$'\033[31m'; Y=$'\033[33m'; B=$'\033[1m'; N=$'\033[0m'
else
  G=""; R=""; Y=""; B=""; N=""
fi

FAILS=0
WARNS=0

section() { echo ""; echo "${B}$1${N}"; }
pass()    { printf '  %s✓%s %s\n' "$G" "$N" "$1"; }
fail()    { printf '  %s✗%s %s\n' "$R" "$N" "$1"; FAILS=$((FAILS + 1)); }
warn()    { printf '  %s!%s %s\n' "$Y" "$N" "$1"; WARNS=$((WARNS + 1)); }

# check_cmd <command> [label]
check_cmd() {
  local cmd="$1" label="${2:-$1}"
  if command -v "$cmd" >/dev/null 2>&1; then pass "$label"; else fail "$label (not on PATH)"; fi
}

# count non-blank, non-comment lines in a file
list_lines() { grep -vE '^\s*(#|$)' "$1" 2>/dev/null; }

# --- prerequisites -----------------------------------------------------------

section "Prerequisites"
check_cmd brew "Homebrew"
check_cmd stow "GNU stow"
check_cmd git  "git"

# --- symlinks ----------------------------------------------------------------

section "Stow symlinks (should resolve into $DOTFILES)"
check_link() {
  local target="$HOME/$1"
  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    fail "$1 (missing)"
  elif [ -L "$target" ] && [[ "$(readlink "$target")" == *"dotfiles"* ]]; then
    pass "$1"
  else
    warn "$1 (exists but is not a dotfiles symlink)"
  fi
}
for f in .zshrc .zshenv .gitconfig .tmux.conf .config/nvim .config/ghostty/config; do
  check_link "$f"
done

# --- homebrew packages -------------------------------------------------------

section "Homebrew packages (Brewfile)"
if command -v brew >/dev/null 2>&1; then
  if brew bundle check --file="$DOTFILES/Brewfile" >/dev/null 2>&1; then
    pass "all Brewfile dependencies satisfied"
  else
    missing="$(brew bundle check --file="$DOTFILES/Brewfile" --verbose 2>/dev/null | grep -c '→')"
    fail "${missing:-some} Brewfile dependencies missing (run: brew bundle install)"
  fi
else
  fail "brew not installed; cannot check Brewfile"
fi

# --- cargo packages ----------------------------------------------------------

section "Cargo packages"
if command -v cargo >/dev/null 2>&1; then
  installed="$(cargo install --list 2>/dev/null | grep -E '^[a-zA-Z0-9_-]+ ' | awk '{print $1}')"
  missing=0
  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    if grep -qx "$pkg" <<<"$installed"; then :; else echo "      missing: $pkg"; missing=$((missing + 1)); fi
  done < <(list_lines scripts/cargo/cargo_packages.txt)
  [ "$missing" -eq 0 ] && pass "all cargo packages installed" || fail "$missing cargo package(s) missing"
else
  fail "cargo not installed"
fi

# --- pnpm packages -----------------------------------------------------------

section "pnpm global packages"
if command -v pnpm >/dev/null 2>&1; then
  # `pnpm ls -g` is unreliable when global-dir is unset; inspect the global
  # node_modules directly (handles scoped names like @scope/pkg via -e).
  gdir="$(pnpm root -g 2>/dev/null)"
  if [ -d "$gdir" ]; then
    missing=0
    while IFS= read -r pkg; do
      [ -z "$pkg" ] && continue
      if [ -e "$gdir/$pkg" ]; then :; else echo "      missing: $pkg"; missing=$((missing + 1)); fi
    done < <(list_lines scripts/pnpm/pnpm_packages.txt)
    [ "$missing" -eq 0 ] && pass "all pnpm packages installed" || fail "$missing pnpm package(s) missing"
  else
    warn "pnpm global dir not found ($gdir); skipping package check"
  fi
else
  fail "pnpm not installed"
fi

# --- vscode extensions -------------------------------------------------------

section "VS Code extensions"
if command -v code >/dev/null 2>&1; then
  installed="$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')"
  total=0; missing=0
  while IFS= read -r ext; do
    [ -z "$ext" ] && continue
    total=$((total + 1))
    grep -qx "$(echo "$ext" | tr '[:upper:]' '[:lower:]')" <<<"$installed" || missing=$((missing + 1))
  done < <(list_lines scripts/vscode/vscode_extensions.txt)
  [ "$missing" -eq 0 ] && pass "all $total VS Code extensions installed" || warn "$missing of $total VS Code extensions missing"
else
  warn "'code' CLI not on PATH (skipping; install from VS Code: Shell Command)"
fi

# --- agent skills ------------------------------------------------------------

section "Agent skills"
locked="$(grep -c '"skillPath"' scripts/skills/skill-lock.json 2>/dev/null || echo 0)"
if [ -f "$HOME/.agents/.skill-lock.json" ]; then
  pass "skills restored ($locked in lock file)"
else
  fail "~/.agents/.skill-lock.json missing (run: bash scripts/skills/packages.sh install)"
fi

# --- fonts -------------------------------------------------------------------

section "Fonts"
if ls "$HOME/Library/Fonts"/FiraCodeNerdFont* >/dev/null 2>&1 \
   || ls /Library/Fonts/FiraCodeNerdFont* >/dev/null 2>&1; then
  pass "FiraCode Nerd Font installed"
else
  fail "FiraCode Nerd Font missing (run: brew install --cask font-fira-code-nerd-font)"
fi

# --- key tools on PATH -------------------------------------------------------

section "Key CLI tools"
for t in nvim eza zoxide atuin oh-my-posh yazi bat tmux delta fzf zinit; do
  case "$t" in
    zinit) [ -d "$HOME/.local/share/zinit" ] && pass "zinit" || warn "zinit (loaded by .zshrc; absent until first interactive shell)";;
    *)     check_cmd "$t";;
  esac
done

# --- summary -----------------------------------------------------------------

echo ""
if [ "$FAILS" -eq 0 ]; then
  printf '%s✓ machine matches dotfiles%s' "$G" "$N"
  [ "$WARNS" -gt 0 ] && printf ' (%d warning(s))' "$WARNS"
  echo ""
  exit 0
else
  printf '%s✗ %d check(s) failed%s' "$R" "$FAILS" "$N"
  [ "$WARNS" -gt 0 ] && printf ', %d warning(s)' "$WARNS"
  echo ""
  echo "Re-run 'bash install.sh' (idempotent) or address the items above."
  exit 1
fi
