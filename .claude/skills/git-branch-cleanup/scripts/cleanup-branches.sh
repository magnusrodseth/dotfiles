#!/usr/bin/env bash
# git-branch-cleanup: classify local branches and remove the "done" ones safely.
#
# Default action: delete branches already merged into the default branch using
# `git branch -d` (git REFUSES to delete anything not fully merged, so this can
# never drop unmerged work). Squash/rebase-merged branches and branches whose
# remote was deleted are LISTED for review and only removed with --force (-D).
set -uo pipefail

DRY_RUN=0; FORCE=0; DO_FETCH=0; USE_GH=1

usage() {
  cat <<'EOF'
Usage: cleanup-branches.sh [--dry-run] [--force] [--fetch] [--no-gh]

  (default)   Delete branches merged into the default branch via `git branch -d`
              (safe; git refuses unmerged). List squash-merged / gone branches.
  --dry-run   Classify and print only; delete nothing.
  --force     Also delete PR-merged / [gone] branches with `git branch -D`.
  --fetch     Run `git fetch --prune` first (accurate [gone] detection).
  --no-gh     Skip gh PR lookups (disables squash/rebase-merge detection).

Always protected: current branch, default branch (origin/HEAD or
main/master/develop), and any branch checked out in a worktree.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    --fetch)   DO_FETCH=1 ;;
    --no-gh)   USE_GH=0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { echo "Not inside a git repository." >&2; exit 1; }

# membership test against a newline-delimited list (exact, fixed-string)
contains() { printf '%s\n' "$1" | grep -qxF -- "$2"; }

if [ "$DO_FETCH" -eq 1 ]; then
  echo "Fetching with --prune ..."
  git fetch --prune --quiet || echo "warn: fetch failed; [gone] info may be stale" >&2
fi

current=$(git branch --show-current 2>/dev/null || true)

# default branch: prefer origin/HEAD, then first existing of main/master/develop
default=""
if ref=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null); then
  default="${ref#refs/remotes/origin/}"
fi
if [ -z "$default" ]; then
  for c in main master develop; do
    if git show-ref --verify --quiet "refs/heads/$c"; then default="$c"; break; fi
  done
fi
[ -n "$default" ] || { echo "Could not determine the default branch." >&2; exit 1; }

worktree_branches=$(git worktree list --porcelain 2>/dev/null \
  | sed -n 's#^branch refs/heads/##p')

merged_branches=$(git for-each-ref --merged="$default" \
  --format='%(refname:short)' refs/heads/)

gone_branches=$(git for-each-ref --format='%(refname:short) %(upstream:track)' \
  refs/heads/ | sed -n 's/ \[gone\]$//p')

# squash/rebase merges: ask GitHub which head branches have a MERGED PR (one call)
pr_merged=""; gh_note=""
if [ "$USE_GH" -eq 1 ] && command -v gh >/dev/null 2>&1; then
  if pr_merged=$(gh pr list --state merged --limit 300 \
      --json headRefName --jq '.[].headRefName' 2>/dev/null); then :; else
    pr_merged=""; gh_note="  (gh PR lookup failed — squash-merge detection skipped)"
  fi
else
  gh_note="  (gh unavailable or --no-gh — squash-merge detection skipped)"
fi

is_protected() {
  b="$1"
  if [ "$b" = "$default" ] || [ "$b" = "$current" ]; then return 0; fi
  case "$b" in main|master|develop) return 0 ;; esac
  if contains "$worktree_branches" "$b"; then return 0; fi
  return 1
}

safe=""; done_pr=""; gone_only=""; active=""
while IFS= read -r b; do
  [ -z "$b" ] && continue
  if is_protected "$b"; then continue; fi
  if   contains "$merged_branches" "$b"; then safe="$safe$b"$'\n'
  elif contains "$pr_merged"       "$b"; then done_pr="$done_pr$b"$'\n'
  elif contains "$gone_branches"   "$b"; then gone_only="$gone_only$b"$'\n'
  else active="$active$b"$'\n'
  fi
done < <(git for-each-ref --format='%(refname:short)' refs/heads/)

print_list() {  # <title> <newline-list>
  printf '%s\n' "$1"
  if [ -z "${2//[$'\n']/}" ]; then echo "  (none)"; return; fi
  printf '%s\n' "$2" | sed '/^$/d; s/^/  - /'
}

echo "Default branch: $default   Current: ${current:-<detached>}"
echo
print_list "Merged into $default — safe to delete (git branch -d):" "$safe"
echo
print_list "Merged via squashed/rebased PR — needs -D:$gh_note" "$done_pr"
echo
print_list "Remote branch gone ([gone]) — likely merged, needs -D:" "$gone_only"
echo
print_list "Active / unmerged — KEPT:" "$active"
echo

run_delete() {  # <flag> <newline-list>
  flag="$1"; list="$2"; n=0
  [ -z "${list//[$'\n']/}" ] && return 0
  while IFS= read -r b; do
    [ -z "$b" ] && continue
    if git branch "$flag" "$b"; then n=$((n+1)); fi
  done < <(printf '%s\n' "$list")
  echo "  -> deleted $n branch(es) with 'git branch $flag'"
}

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run — nothing deleted. Re-run without --dry-run to delete the safe set."
  exit 0
fi

echo "Deleting merged branches (safe) ..."
run_delete -d "$safe"

if [ "$FORCE" -eq 1 ]; then
  echo "Force-deleting PR-merged / gone branches ..."
  run_delete -D "$done_pr"
  run_delete -D "$gone_only"
else
  if [ -n "${done_pr//[$'\n']/}${gone_only//[$'\n']/}" ]; then
    echo
    echo "PR-merged / gone branches were NOT deleted (need 'git branch -D')."
    echo "Re-run with --force to remove them, or delete individually after review."
  fi
fi
