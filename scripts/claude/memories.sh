#!/usr/bin/env bash
#
# memories.sh - export and import Claude Code's per-project auto-memory.
#
# Claude Code keeps memory in ~/.claude/projects/<key>/memory/, where <key> is
# the project's absolute path with every non-alphanumeric character replaced by
# "-". The home directory is part of that key, and it can differ between
# machines (the retired Gjensidige Mac used /Users/magnus.rodseth). A plain
# copy therefore lands under keys no project resolves to, and the memory is
# silently never loaded.
#
# export writes a zip whose top-level directories replace the home prefix with
# the literal token HOME. import maps HOME back to this machine's prefix. Import
# never overwrites: a file that already exists is skipped and reported.
#
# Projects whose key matches the exclude regex are left out. The default
# excludes employer work, because memory about it should not leave an employer's
# machine. Pass --exclude '' to export everything.
#
# The zip is not tracked in git (memory names private repos and people). Carry
# it in the personal 1Password account as the document "Claude Code memories":
#
#   bash scripts/claude/memories.sh export -o /tmp/claude-memories.zip
#   op document create /tmp/claude-memories.zip --title "Claude Code memories" \
#     --vault Private --account my.1password.eu
#
#   # on the new machine
#   op document get "Claude Code memories" --account my.1password.eu \
#     --out-file /tmp/claude-memories.zip
#   bash scripts/claude/memories.sh import /tmp/claude-memories.zip
#
# Usage:
#   memories.sh export [-o <file.zip>] [--exclude <regex>]
#   memories.sh import <file.zip> [--dry-run]
#   memories.sh list   [--exclude <regex>]

set -euo pipefail

projects="${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}"
home_key="$(printf '%s' "$HOME" | sed 's/[^A-Za-z0-9]/-/g')"
default_exclude='-dev-work(-|$)|hei-huset|gjensidige|conductor-workspaces'

usage() {
  sed -n '/^# Usage:/,/^$/p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

# Print "<key>\t<file count>" for every project with a non-empty memory dir.
selected() {
  local exclude="$1" dir key n
  for dir in "$projects"/*/memory; do
    [ -d "$dir" ] || continue
    key="$(basename "$(dirname "$dir")")"
    n="$(find "$dir" -type f | wc -l | tr -d ' ')"
    [ "$n" -gt 0 ] || continue
    if [ -n "$exclude" ] && printf '%s\n' "$key" | grep -Eq -- "$exclude"; then
      continue
    fi
    printf '%s\t%s\n' "$key" "$n"
  done
}

portable() {
  local key="$1"
  case "$key" in
    "$home_key"*) printf 'HOME%s' "${key#"$home_key"}" ;;
    *) printf '%s' "$key" ;;
  esac
}

cmd_list() {
  local exclude="$default_exclude"
  while [ $# -gt 0 ]; do
    case "$1" in
      --exclude) exclude="${2-}"; shift 2 ;;
      *) usage ;;
    esac
  done
  selected "$exclude" | while IFS=$'\t' read -r key n; do
    printf '%4s  %s\n' "$n" "$(portable "$key")"
  done
}

cmd_export() {
  local out="claude-memories-$(date +%Y-%m-%d).zip" exclude="$default_exclude"
  while [ $# -gt 0 ]; do
    case "$1" in
      -o) out="${2:?-o needs a path}"; shift 2 ;;
      --exclude) exclude="${2-}"; shift 2 ;;
      *) usage ;;
    esac
  done
  command -v zip >/dev/null || { echo "zip is not installed" >&2; exit 1; }

  stage="$(mktemp -d)"
  trap 'rm -rf "${stage:?}"' EXIT

  local count=0 files=0 key n
  while IFS=$'\t' read -r key n; do
    mkdir -p "$stage/$(portable "$key")"
    cp -Rp "$projects/$key/memory" "$stage/$(portable "$key")/memory"
    count=$((count + 1)); files=$((files + n))
  done < <(selected "$exclude")

  if [ "$count" -eq 0 ]; then
    echo "No memory to export." >&2
    exit 1
  fi

  case "$out" in /*) ;; *) out="$PWD/$out" ;; esac
  rm -f "$out"
  (umask 077; cd "$stage" && zip -qr "$out" .)
  echo "Exported $files files from $count projects to $out"
}

cmd_import() {
  local zipfile="" dry=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) dry=1; shift ;;
      -*) usage ;;
      *) zipfile="$1"; shift ;;
    esac
  done
  [ -n "$zipfile" ] && [ -f "$zipfile" ] || usage
  command -v unzip >/dev/null || { echo "unzip is not installed" >&2; exit 1; }

  stage="$(mktemp -d)"
  trap 'rm -rf "${stage:?}"' EXIT
  unzip -q "$zipfile" -d "$stage"

  local added=0 skipped=0 src rel key target
  while IFS= read -r src; do
    rel="${src#"$stage"/}"
    key="${rel%%/*}"
    case "$key" in HOME*) key="$home_key${key#HOME}" ;; esac
    target="$projects/$key/${rel#*/}"
    if [ -e "$target" ]; then
      echo "skip (exists): $target"
      skipped=$((skipped + 1))
      continue
    fi
    if [ "$dry" -eq 0 ]; then
      mkdir -p "$(dirname "$target")"
      cp -p "$src" "$target"
    fi
    added=$((added + 1))
  done < <(find "$stage" -type f -path '*/memory/*')

  local verb="Imported"
  [ "$dry" -eq 1 ] && verb="Would import"
  echo "$verb $added files into $projects ($skipped skipped because they exist)"
}

[ $# -ge 1 ] || usage
sub="$1"; shift
case "$sub" in
  export) cmd_export "$@" ;;
  import) cmd_import "$@" ;;
  list) cmd_list "$@" ;;
  *) usage ;;
esac
