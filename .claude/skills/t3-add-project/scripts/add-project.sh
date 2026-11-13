#!/usr/bin/env bash
# Clone a GitHub repo if this machine has no clone yet, then register it as a T3 Code project.
# Usage: add-project.sh <github-url|owner/repo> [--dest <path>] [--title <title>]
set -euo pipefail

t3() { bash "$HOME/.agents/skills/t3-create-task/scripts/t3.sh" "$@"; }
die() { echo "error: $*" >&2; exit 1; }

ref="" dest="" title=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest) dest="$2"; shift 2 ;;
    --title) title="$2"; shift 2 ;;
    -h|--help) sed -n 2,3p "$0"; exit 0 ;;
    *) [[ -z "$ref" ]] || die "unexpected argument: $1"; ref="$1"; shift ;;
  esac
done
[[ -n "$ref" ]] || die "missing repo (URL or owner/repo)"

# owner/repo from https, ssh or shorthand
slug="${ref%/}"; slug="${slug%.git}"
slug="${slug#*github.com[:/]}"
slug="$(cut -d/ -f1-2 <<<"$slug")"
[[ "$slug" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || die "not a GitHub repo: $ref"
owner="${slug%/*}" repo="${slug#*/}"
lower() { tr '[:upper:]' '[:lower:]' <<<"$1"; }

remote_slug() {  # owner/repo of a checkout's origin, lowercased, or empty
  local url; url="$(git -C "$1" remote get-url origin 2>/dev/null)" || return 0
  url="${url%.git}"; url="${url#*github.com[:/]}"
  lower "$(cut -d/ -f1-2 <<<"$url")"
}

# 1. Find an existing clone: explicit --dest, else any ~/dev checkout whose origin matches
if [[ -z "$dest" ]]; then
  for d in "$HOME"/dev/*/ "$HOME"/dev/*/*/; do
    [[ -e "$d/.git" ]] || continue
    if [[ "$(remote_slug "$d")" == "$(lower "$slug")" ]]; then dest="${d%/}"; break; fi
  done
fi

cloned=no
if [[ -z "$dest" ]]; then
  case "$(lower "$owner")" in
    gjensidige) dest="$HOME/dev/work/$repo" ;;
    *)          dest="$HOME/dev/personal/$repo" ;;
  esac
fi

if [[ -e "$dest/.git" ]]; then
  [[ "$(remote_slug "$dest")" == "$(lower "$slug")" ]] \
    || die "$dest is a clone of '$(remote_slug "$dest")', not $slug. Pass --dest."
elif [[ -e "$dest" && -n "$(ls -A "$dest")" ]]; then
  die "$dest exists, is not empty and is not a git checkout. Pass --dest."
else
  mkdir -p "$(dirname "$dest")"
  gh repo clone "$slug" "$dest" -- --quiet
  cloned=yes
fi

# 2. Register in T3 unless a project already covers this path
if t3 thread list --project "$dest" --json >/dev/null 2>&1; then
  registered=already
else
  t3 project add "$dest" --title "${title:-$repo}" >/dev/null
  t3 thread list --project "$dest" --json >/dev/null 2>&1 || die "t3 project add ran, but T3 still has no project for $dest"
  registered=yes
fi

printf 'repo=%s\npath=%s\ncloned=%s\nregistered=%s\nbranch=%s\n' \
  "$slug" "$dest" "$cloned" "$registered" "$(git -C "$dest" branch --show-current)"
