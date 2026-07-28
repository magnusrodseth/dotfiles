#!/usr/bin/env bash
#
# Provision a fresh macOS machine from this dotfiles repo.
#
# Design notes (these matter for both humans and agents driving this script):
#   - Honest: every step reports its real exit status. No step prints
#     "success" unless it actually succeeded.
#   - Resilient: a failing step is recorded but does NOT abort the run, so a
#     single bad package can't block the other 13 steps. The script exits
#     non-zero at the end if anything failed, listing exactly what.
#   - Idempotent: safe to re-run. Re-running should converge toward a fully
#     set-up machine. Run `bash scripts/doctor.sh` afterwards to verify state.

set -uo pipefail

DOTFILES="$HOME/dotfiles"

if [ "$(pwd)" != "$DOTFILES" ]; then
  echo "Error: run this script from $DOTFILES" >&2
  exit 1
fi

FAILURES=()

# run_step <human-name> <command...>
# Runs a step, records (but does not abort on) failure.
run_step() {
  local name="$1"
  shift
  echo ""
  echo "==> ${name}"
  if "$@"; then
    echo "    ok: ${name}"
  else
    echo "    FAILED: ${name}" >&2
    FAILURES+=("${name}")
  fi
}

# --- bootstrap: sudo, homebrew, stow -----------------------------------------

if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs sudo for the macOS defaults step. Enter your password."
  sudo -v || { echo "Failed to obtain sudo privileges. Exiting." >&2; exit 1; }
fi

ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Put brew on PATH for the rest of THIS run, not just for future shells.
  # Without this, ensure_stow below cannot find the brew it just installed.
  # shellcheck disable=SC1090
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
}

ensure_stow() {
  command -v stow >/dev/null 2>&1 || brew install stow
}

run_step "Ensure Homebrew is installed" ensure_homebrew
run_step "Ensure stow is installed" ensure_stow

# Load env + PATH so tools installed below (cargo, pnpm, ya, tmux, mas, ...) are
# resolvable in this non-interactive shell.
#
# This deliberately does NOT source ~/.zshenv, which is what it used to do.
# .zshenv is zsh (`typeset -U path`, `path=( ... )` array); sourcing it from
# bash under `set -u` printed two syntax errors and then killed the whole run on
# `path: unbound variable`, before a single one of the 13 steps below executed.
# macOS ships bash 3.2 and nothing here installs another, so that abort hit
# every invocation on any machine where ~/.zshenv already existed.
#
# The two files must therefore be kept in sync by hand. doctor.sh asserts that
# `bash -c 'set -uo pipefail; . ~/.zshenv'` stays broken-by-design rather than
# silently becoming load-bearing again.
bootstrap_env() {
  export PNPM_HOME="$HOME/Library/pnpm"
  export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  # shellcheck disable=SC1091
  [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
  # shellcheck disable=SC1091
  [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
  PATH="$HOME/.local/bin:$PNPM_HOME:$HOME/.bun/bin:$HOME/.deno/bin:$HOME/.cargo/bin:$HOME/.dotnet/tools:$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:/Library/TeX/texbin:$PATH"
  export PATH
}
bootstrap_env

# --- steps -------------------------------------------------------------------

init_submodules()     { git submodule update --init --recursive; }
stow_symlinks()       { stow --restow .; }
brew_packages()       { brew bundle install --file="$DOTFILES/Brewfile"; }
cargo_packages() {
  # Nothing in the declared state installs Rust, so on a fresh machine this step
  # used to hit rustup's interactive installer and block forever on stdin.
  if ! command -v cargo >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path || return 1
    # shellcheck disable=SC1091
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
  fi
  bash scripts/cargo/packages.sh install
}
pnpm_packages()       { bash scripts/pnpm/packages.sh install; }
npm_packages()        { bash scripts/npm/packages.sh install; }
agent_skills()        { bash scripts/skills/packages.sh install; }
link_dotfiles_skills(){ bash scripts/skills/link-dotfiles-skills.sh; }
git_hooks()           { git config core.hooksPath scripts/githooks; }
yazi_plugins()        { ya pack -i; }
app_store_apps()      { bash scripts/macos/install-app-store-apps.sh; }
tmux_plugins() {
  # tpm needs a running server with at least one session. The previous version
  # called `tmux new-session -d` and never cleaned up, leaking one detached
  # orphan session per install run. Use a named throwaway and always kill it.
  tmux start-server || return 1
  local created=0
  if ! tmux has-session -t dotfiles-tpm-install 2>/dev/null; then
    tmux new-session -d -s dotfiles-tpm-install || return 1
    created=1
  fi
  sh "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"
  local rc=$?
  [ "$created" -eq 1 ] && tmux kill-session -t dotfiles-tpm-install 2>/dev/null
  return $rc
}
macos_defaults()      { bash scripts/macos/defaults.sh; }
bat_cache()           { bat cache --build; }

run_step "Init git submodules"                init_submodules
run_step "Create symlinks with stow"          stow_symlinks
run_step "Install Homebrew packages"          brew_packages
run_step "Install Cargo packages"             cargo_packages
run_step "Install pnpm packages"              pnpm_packages
run_step "Install npm global packages"        npm_packages
run_step "Install agent skills"               agent_skills
run_step "Link dotfiles skills globally"      link_dotfiles_skills
run_step "Enable repo git hooks"              git_hooks
run_step "Install Yazi plugins"               yazi_plugins
run_step "Install App Store apps"             app_store_apps
run_step "Install tmux (tpm) plugins"         tmux_plugins
run_step "Configure macOS defaults"           macos_defaults
run_step "Build bat cache"                    bat_cache

# --- summary -----------------------------------------------------------------

echo ""
if [ "${#FAILURES[@]}" -eq 0 ]; then
  echo "All steps completed. Run 'bash scripts/doctor.sh' to verify, then open a new shell."
  exit 0
fi

echo "Completed with ${#FAILURES[@]} failed step(s):" >&2
printf '  - %s\n' "${FAILURES[@]}" >&2
echo "" >&2
echo "Re-run this script (safe; it is idempotent) or fix the failures above," >&2
echo "then run 'bash scripts/doctor.sh' to verify." >&2
exit 1
