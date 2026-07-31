#!/usr/bin/env bash
# where-is: resolve a project/repo/directory name to its absolute path.
#
#   where-is.sh <name>              path + git + orientation blurb
#   where-is.sh <name> --path-only  just the path
#
# Exit: 0 resolved, 1 not found, 2 ambiguous, 64 usage.
# Portable to bash 3.2 (macOS system bash): no mapfile, no assoc arrays.

set -uo pipefail

SEARCH_ROOTS_1="$HOME/dev"
SEARCH_ROOTS_2="$HOME/dotfiles"
MAX_LINES=30
MAX_BYTES=2000

query=""
path_only=0
for arg in "$@"; do
  case "$arg" in
    --path-only|-p) path_only=1 ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) printf 'unknown flag: %s\n' "$arg" >&2; exit 64 ;;
    *) [ -z "$query" ] && query="$arg" ;;
  esac
done

if [ -z "$query" ]; then
  printf 'usage: where-is.sh <name> [--path-only]\n' >&2
  exit 64
fi

nlines() { printf '%s\n' "$1" | grep -c . ; }

keep_existing_dirs() {
  while IFS= read -r d; do
    [ -n "$d" ] && [ -d "$d" ] && printf '%s\n' "$d"
  done
}

# Shallower paths first: a repo root outranks something nested inside it.
by_depth() {
  awk '{ print length($0), $0 }' | sort -n | cut -d' ' -f2-
}

# --- 1. candidates -----------------------------------------------------------

source_label="zoxide"
cands=""
if command -v zoxide >/dev/null 2>&1; then
  cands=$(zoxide query -l -- "$query" 2>/dev/null | keep_existing_dirs)
fi

if [ -z "$cands" ]; then
  source_label="filesystem"
  if command -v fd >/dev/null 2>&1; then
    cands=$(fd -t d -d 3 -a -i -F -- "$query" "$SEARCH_ROOTS_1" "$SEARCH_ROOTS_2" 2>/dev/null \
      | sed 's:/$::' | keep_existing_dirs | by_depth | head -20)
  else
    cands=$(find "$SEARCH_ROOTS_1" "$SEARCH_ROOTS_2" -maxdepth 3 -type d -iname "*${query}*" 2>/dev/null \
      | keep_existing_dirs | by_depth | head -20)
  fi
fi

if [ -z "$cands" ]; then
  printf 'NOT FOUND: no directory matching %s in zoxide or under %s, %s\n' \
    "'$query'" "$SEARCH_ROOTS_1" "$SEARCH_ROOTS_2" >&2
  exit 1
fi

# --- 2. narrow to a winner ---------------------------------------------------

pool="$cands"

if [ "$(nlines "$pool")" -gt 1 ]; then
  # An exact basename match beats a substring match.
  lc_query=$(printf '%s' "$query" | tr '[:upper:]' '[:lower:]')
  exact=$(printf '%s\n' "$pool" | while IFS= read -r d; do
    lc_base=$(basename "$d" | tr '[:upper:]' '[:lower:]')
    [ "$lc_base" = "$lc_query" ] && printf '%s\n' "$d"
  done)
  [ -n "$exact" ] && pool="$exact"
fi

if [ "$(nlines "$pool")" -gt 1 ]; then
  # A git root beats a plain directory nested inside one.
  gits=$(printf '%s\n' "$pool" | while IFS= read -r d; do
    [ -e "$d/.git" ] && printf '%s\n' "$d"
  done)
  [ -n "$gits" ] && pool="$gits"
fi

if [ "$(nlines "$pool")" -gt 1 ]; then
  printf 'AMBIGUOUS: %s candidates for %s (ranked by %s)\n' \
    "$(nlines "$pool")" "'$query'" "$source_label"
  printf '%s\n' "$pool" | head -10 | sed 's/^/  /'
  printf '\nAsk which one, or re-run with a more specific name.\n'
  exit 2
fi

winner=$(printf '%s\n' "$pool" | head -1)

# --- 3. report ---------------------------------------------------------------

printf 'PATH: %s\n' "$winner"
[ "$path_only" -eq 1 ] && exit 0

printf 'SOURCE: %s\n' "$source_label"

if [ -e "$winner/.git" ]; then
  branch=$(git -C "$winner" rev-parse --abbrev-ref HEAD 2>/dev/null)
  remote=$(git -C "$winner" remote get-url origin 2>/dev/null)
  printf 'GIT: %s' "${branch:-detached}"
  [ -n "$remote" ] && printf ' | %s' "$remote"
  printf '\n'
fi

# Ladder: AGENTS.md, else CLAUDE.md, else README.md. Only one is ever read, so a
# vault-style AGENTS.md -> CLAUDE.md symlink cannot be counted twice.
blurb=""
for f in AGENTS.md CLAUDE.md README.md; do
  if [ -f "$winner/$f" ]; then blurb="$winner/$f"; break; fi
done

if [ -n "$blurb" ]; then
  label=$(basename "$blurb")
  real=$(readlink -f "$blurb" 2>/dev/null)
  if [ -n "$real" ] && [ "$real" != "$blurb" ]; then
    label="$label -> $(basename "$real")"
  fi
  total=$(wc -l < "$blurb" | tr -d ' ')
  printf 'ORIENTATION (%s, first %s of %s lines):\n' "$label" "$MAX_LINES" "$total"
  head -"$MAX_LINES" "$blurb" | head -c "$MAX_BYTES" | sed 's/^/  /'
  printf '\n'
  exit 0
fi

printf 'ORIENTATION: no AGENTS.md, CLAUDE.md or README.md.\n'

if [ -f "$winner/package.json" ] && command -v jq >/dev/null 2>&1; then
  jq -r '"MANIFEST (package.json): \(.name // "?") \(.version // "")\n  \(.description // "(no description)")"' \
    "$winner/package.json" 2>/dev/null
elif [ -f "$winner/Cargo.toml" ]; then
  printf 'MANIFEST (Cargo.toml): %s\n' "$(grep -m1 '^name' "$winner/Cargo.toml" | cut -d'"' -f2)"
elif [ -f "$winner/pyproject.toml" ]; then
  printf 'MANIFEST (pyproject.toml): %s\n' "$(grep -m1 '^name' "$winner/pyproject.toml" | cut -d'"' -f2)"
elif [ -f "$winner/go.mod" ]; then
  printf 'MANIFEST (go.mod): %s\n' "$(grep -m1 '^module' "$winner/go.mod" | awk '{print $2}')"
fi

printf 'TOP LEVEL:\n'
ls -A "$winner" 2>/dev/null | head -25 | sed 's/^/  /'
exit 0
