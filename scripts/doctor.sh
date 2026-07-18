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
    # brew writes its "→ <name> needs to be installed or updated." lines to
    # STDERR. Discarding stderr here (as this check used to) made the count
    # always 0, so the check failed while reporting "0 dependencies missing" -
    # red with a number that disproved it, which is how you train someone to
    # stop reading red.
    out="$(brew bundle check --file="$DOTFILES/Brewfile" --verbose 2>&1)"
    missing="$(printf '%s\n' "$out" | grep -c '→' || true)"
    # "or outdated" is load-bearing: most hits are installed but behind (git,
    # zsh and stow all report here), not absent. brew bundle install does not
    # upgrade them, so name the command that does.
    fail "${missing:-some} Brewfile dependencies missing or outdated (brew bundle install; brew upgrade)"
    # Formulae from untrusted taps cannot be version-checked at all, so brew
    # lists them as needing an update whatever their real state. They inflate
    # the count above; say so rather than letting the number look exact.
    untrusted="$(printf '%s\n' "$out" \
      | grep -oE 'whether [^ ]+ is outdated' | awk '{print $2}' | sort -u || true)"
    if [ -n "$untrusted" ]; then
      n_untrusted="$(printf '%s\n' "$untrusted" | grep -c . || true)"
      warn "$n_untrusted of those are unverifiable (untrusted tap; brew trust --formula <name>)"
    fi
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
# A malformed SKILL.md or a dangling skill symlink silently drops the skill
# from Claude Code; validate-skills.sh is the loud failure for both.
if out="$(bash scripts/skills/validate-skills.sh --links 2>&1)"; then
  pass "$out"
else
  fail "skill validation (run: bash scripts/skills/validate-skills.sh --links)"
  printf '%s\n' "$out" | sed 's/^/      /'
fi
# validate-skills.sh only reads this repo. ~/.claude/skills is what Claude Code
# actually loads, and it drifts from the repo silently: `skills add` writes real
# dirs straight into it, which shadow the repo's copies and are invisible here.
# check-skill-integrity.sh reads the live tree and catches what that hides -
# skills reproducible from nowhere, dead links, and lock entries with no skill.
if out="$(bash scripts/skills/check-skill-integrity.sh 2>&1)"; then
  pass "$out"
else
  fail "skill integrity (run: bash scripts/skills/check-skill-integrity.sh)"
  printf '%s\n' "$out" | sed 's/^/      /'
fi
if [ "$(git config core.hooksPath)" = "scripts/githooks" ]; then
  pass "git pre-commit hook enabled (core.hooksPath)"
else
  fail "git hooks not enabled (run: git config core.hooksPath scripts/githooks)"
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

# --- shell init --------------------------------------------------------------

section "Shell init (.zshrc Claude Code guard)"
# `claude` injects CLAUDECODE=1, CLAUDE_CODE_CHILD_SESSION=1, session vars, plus
# .claude/settings.json env (DISABLE_ZOXIDE=1) into everything it spawns, and
# those vars can leak into real terminals (a tab or the terminal app itself
# relaunched from inside a session). Interactive shells must scrub the leak:
# DISABLE_ZOXIDE kills the cd hook, and CLAUDE_CODE_CHILD_SESSION makes a new
# `claude` skip transcript persistence (invisible to --continue/--resume).
# Non-interactive agent shells must keep skipping heavy init.
if [ -d "$HOME/.local/share/zinit" ] && command -v zoxide >/dev/null 2>&1; then
  if CLAUDECODE=1 DISABLE_ZOXIDE=1 zsh -i -c '(( $+functions[__zoxide_z] ))' >/dev/null 2>&1; then
    pass "interactive shell survives leaked Claude Code env (zoxide hooks cd)"
  else
    fail "leaked CLAUDECODE/DISABLE_ZOXIDE disables zoxide in interactive shells"
  fi
  if CLAUDECODE=1 CLAUDE_CODE_CHILD_SESSION=1 CLAUDE_CODE_SESSION_ID=dead-beef \
     zsh -i -c '[[ -z "$CLAUDECODE" && -z "$CLAUDE_CODE_CHILD_SESSION" && -z "$CLAUDE_CODE_SESSION_ID" ]]' >/dev/null 2>&1; then
    pass "interactive shell scrubs child-session vars (claude --continue/--resume see new sessions)"
  else
    fail "leaked CLAUDE_CODE_CHILD_SESSION survives; claude started here won't persist sessions"
  fi
  if CLAUDECODE=1 zsh -c 'source ~/.zshrc >/dev/null 2>&1; (( $+functions[zinit] )) && exit 1; exit 0' >/dev/null 2>&1; then
    pass "non-interactive Claude Code shells skip heavy init"
  else
    fail "non-interactive Claude Code shell ran full init (guard broken)"
  fi
else
  warn "zinit or zoxide not installed; skipping shell init checks"
fi

# --- raycast extensions ------------------------------------------------------

section "Raycast extensions (compiled command JS present)"
# The extensions' *.js/*.js.map/package.json are gitignored (regenerable build
# output that Raycast re-downloads), so git can't restore them. An interrupted
# Raycast update or a `git clean -x` can leave an extension with fewer compiled
# command .js files than it declares commands, which surfaces later as Raycast's
# "Could not find command's executable JS file". Catch that here: each command
# object in package.json carries a "mode" field, so the mode count is the
# expected .js count. Reinstall flagged extensions from the Raycast Store.
RAYEXT="$HOME/.config/raycast/extensions"
if [ -d "$RAYEXT" ]; then
  broken=0; checked=0
  for pkg in "$RAYEXT"/*/package.json; do
    [ -e "$pkg" ] || continue
    dir="$(dirname "$pkg")"
    ncmd="$(grep -oE '"mode"[[:space:]]*:' "$pkg" | wc -l | tr -d ' ')"
    [ "$ncmd" -eq 0 ] && continue   # tool-only / non-command extension
    checked=$((checked + 1))
    njs="$(find "$dir" -maxdepth 1 -name '*.js' 2>/dev/null | wc -l | tr -d ' ')"
    if [ "$njs" -lt "$ncmd" ]; then
      broken=$((broken + 1))
      title="$(grep -m1 '"title"' "$pkg" | sed -E 's/.*"title"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')"
      echo "      broken: ${title:-$(basename "$dir")} ($njs/$ncmd command .js files)"
    fi
  done
  if [ "$checked" -eq 0 ]; then
    warn "no Raycast command extensions found under $RAYEXT"
  elif [ "$broken" -eq 0 ]; then
    pass "all $checked command extensions have their compiled JS"
  else
    warn "$broken of $checked Raycast extension(s) missing compiled JS (reinstall from Raycast Store)"
  fi
else
  pass "no Raycast extensions dir (skipping)"
fi

# --- cache hygiene -----------------------------------------------------------

section "Cache hygiene (unbounded caches)"
# Some tools have no cache eviction policy at all, so their cache grows without
# limit until a disk fills. This bit them for real on 17.07.2026: the machine hit
# 97% full and ~/.cache/uv alone held 105 GB (3.4M files, every torch version ever
# installed), because uv's docs are explicit that `uv cache prune` is something you
# "run periodically" - there is no max-size setting to configure. ~/.cache/huggingface
# is the same shape: model weights are never evicted, and it had reached 112 GB of
# models untouched since early 2025.
#
# These are WARNs, not FAILs: a large cache is not a broken machine, it's a nudge to
# run the prune command before the disk gets tight. Thresholds are ~3x a healthy size,
# so a green machine stays quiet and a runaway gets caught long before 97%.
#
# `bun pm cache rm` is a full clear, not a prune - bun has no surgical equivalent of
# `uv cache prune`, so its threshold is set higher: clearing it costs a re-download of
# everything, which is a worse trade than uv's.
#
# Format: <path>:<warn-threshold-GB>:<reclaim command>
CACHES=(
  "$HOME/.cache/uv:20:uv cache prune"
  "$HOME/.cache/huggingface:30:review + rm unused models in ~/.cache/huggingface/hub"
  "$HOME/.bun/install/cache:30:bun pm cache rm  (full clear; run from a dir with a package.json)"
  "$HOME/Library/Caches/pnpm:15:pnpm store prune"
  "$HOME/.npm:15:npm cache clean --force  (does NOT cover ~/.npm/_npx - rm that separately)"
  "$HOME/Library/pnpm/store:25:pnpm store prune - but see the version-orphan note below"
)
for entry in "${CACHES[@]}"; do
  cpath="${entry%%:*}"; rest="${entry#*:}"
  limit="${rest%%:*}"; cmd="${rest#*:}"
  label="~${cpath#$HOME}"
  if [ ! -d "$cpath" ]; then
    pass "$label (absent)"
    continue
  fi
  # `du -sk` keeps this to one stat pass and avoids parsing du's human-readable
  # units; -k is POSIX and always kibibytes, so the math is unambiguous.
  kb="$(du -sk "$cpath" 2>/dev/null | awk '{print $1}')"
  if [ -z "$kb" ]; then
    warn "$label (could not measure)"
    continue
  fi
  gb=$((kb / 1024 / 1024))
  if [ "$gb" -ge "$limit" ]; then
    warn "$label is ${gb}GB (>= ${limit}GB) - reclaim with: $cmd"
  else
    pass "$label ${gb}GB (< ${limit}GB)"
  fi
done

# pnpm bumps its store version and silently abandons the old one in place. On 17.07.2026
# `~/Library/pnpm/store` held BOTH v10/v3 (active, 5.5 GB) and a top-level v3 (15 GB,
# untouched since 12.02.2025) left behind by an older pnpm. `pnpm store prune` only ever
# looks at the ACTIVE store, so it reported "Removed 0 packages" against 20 GB and no pnpm
# command will ever reclaim the orphan. The size check above cannot catch this on its own
# (a legitimately busy store is also big), so compare what pnpm says it uses against what
# is actually on disk.
if command -v pnpm >/dev/null 2>&1 && [ -d "$HOME/Library/pnpm/store" ]; then
  active="$(pnpm store path 2>/dev/null)"
  if [ -n "$active" ]; then
    # pnpm store path returns .../store/v10/v3; the version dir we care about is its parent.
    activever="$(dirname "$active")"
    orphans=""
    for d in "$HOME"/Library/pnpm/store/*; do
      [ -d "$d" ] || continue
      [ "$d" = "$activever" ] && continue
      osz="$(du -sk "$d" 2>/dev/null | awk '{print $1}')"
      [ -n "$osz" ] && [ "$osz" -gt 1048576 ] && orphans="$orphans ${d##*/}($((osz / 1024 / 1024))GB)"
    done
    if [ -n "$orphans" ]; then
      warn "abandoned pnpm store version(s):$orphans - active is ${activever##*/}; rm the others"
    else
      pass "pnpm store has no abandoned version dirs (active: ${activever##*/})"
    fi
  fi
fi

# uv predates the Brewfile entry on this machine: a stale standalone-installer copy
# in ~/.cargo/bin is what went 2 years without an upgrade. /opt/homebrew/bin precedes
# ~/.cargo/bin in PATH so brew's copy wins, but the old binary lingering is a trap for
# anything that hardcodes the path or reorders PATH.
if [ -e "$HOME/.cargo/bin/uv" ]; then
  warn "stale ~/.cargo/bin/uv shadow copy (brew owns uv now; rm ~/.cargo/bin/uv ~/.cargo/bin/uvx)"
else
  pass "no stale ~/.cargo/bin/uv"
fi

# --- repo hygiene ------------------------------------------------------------

section "Repo hygiene (no runtime/backup cruft tracked)"
# Tools drop backups (*.bak.*), caches (*-cache.json), and LMDB runtime DBs
# (*.mdb) into stowed config dirs; a later `git add -A` sweeps them in. These
# patterns only ever match generated junk, so any hit is a real leak — untrack
# it and add the path to the relevant .gitignore.
cruft="$(git ls-files | grep -E '\.bak($|\.)|\.mdb$|-cache\.json$' || true)"
if [ -z "$cruft" ]; then
  pass "no tracked .bak/.mdb/*-cache.json cruft"
else
  n="$(printf '%s\n' "$cruft" | grep -c .)"
  fail "$n tracked runtime/backup file(s) (untrack: git rm --cached <path>)"
  printf '%s\n' "$cruft" | sed 's/^/      /'
fi

# The check above is directional: it catches generated junk leaking INTO the
# tree. The two below catch the opposite failure, authored work that never made
# it out of the working directory - which is how doctor.sh itself shipped a call
# to an untracked check-skill-integrity.sh and stayed broken on every clone.
if out="$(bash scripts/check-script-refs.sh 2>&1)"; then
  pass "every referenced repo script is tracked"
else
  fail "script reference(s) point at untracked files"
  printf '%s\n' "$out" | sed 's/^/      /'
fi

# Untracked work under scripts/ and .claude/skills/ is often legitimately in
# progress, so this warns rather than fails. It is the signal that a skill or
# script exists on this machine and nowhere else - one disk failure from gone.
stray="$(git ls-files --others --exclude-standard --directory -- scripts .claude/skills || true)"
if [ -z "$stray" ]; then
  pass "no untracked scripts or skills"
else
  n="$(printf '%s\n' "$stray" | grep -c .)"
  warn "$n untracked path(s) under scripts/ or .claude/skills/ (exists only here)"
  printf '%s\n' "$stray" | sed 's/^/      /'
fi

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
