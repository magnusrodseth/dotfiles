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
}

ensure_stow() {
  command -v stow >/dev/null 2>&1 || brew install stow
}

run_step "Ensure Homebrew is installed" ensure_homebrew
run_step "Ensure stow is installed" ensure_stow

# Load env + PATH so tools installed below (cargo, pnpm, ya, tmux, mas, ...) are
# resolvable in this non-interactive shell. .zshenv holds PATH/env only; we
# deliberately do NOT source the interactive .zshrc here.
# shellcheck disable=SC1090
[ -f "$HOME/.zshenv" ] && source "$HOME/.zshenv"

# --- steps -------------------------------------------------------------------

stow_symlinks()       { stow --restow .; }
brew_packages()       { brew bundle install --file="$DOTFILES/Brewfile"; }
cargo_packages()      { bash scripts/cargo/packages.sh install; }
pnpm_packages()       { bash scripts/pnpm/packages.sh install; }
vscode_extensions()   { bash scripts/vscode/extensions.sh install; }
agent_skills()        { bash scripts/skills/packages.sh install; }
link_dotfiles_skills(){ bash scripts/skills/link-dotfiles-skills.sh; }
yazi_plugins()        { ya pack -i; }
app_store_apps()      { bash scripts/macos/install-app-store-apps.sh; }
tmux_plugins() {
  tmux start-server
  tmux new-session -d
  sh "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"
}
macos_defaults()      { bash scripts/macos/defaults.sh; }
bat_cache()           { bat cache --build; }

run_step "Create symlinks with stow"          stow_symlinks
run_step "Install Homebrew packages"          brew_packages
run_step "Install Cargo packages"             cargo_packages
run_step "Install pnpm packages"              pnpm_packages
run_step "Install VS Code extensions"         vscode_extensions
run_step "Install agent skills"               agent_skills
run_step "Link dotfiles skills globally"      link_dotfiles_skills
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
