#!/usr/bin/env bash
# pr-status.sh - report mergeability + review/CI status for GitHub PRs, from any directory.
#
# Usage:
#   pr-status.sh <ref> [<ref> ...]      one or more PRs (URL, owner/repo#N, owner/repo/N, or bare #N/N in a repo)
#   pr-status.sh --repo owner/repo      every open PR in a repo
#   pr-status.sh --mine                 your open PRs across all repos (gh search)
#   pr-status.sh --author LOGIN         someone's open PRs across all repos
#   pr-status.sh ... --comments         also print review summaries + inline comments
#
# Works without a local checkout: every call passes --repo explicitly.
set -uo pipefail

WITH_COMMENTS=0
SEARCH_AUTHOR=""
REPO_ALL=""
REFS=()

die() { echo "pr-status: $*" >&2; exit 1; }
command -v gh >/dev/null 2>&1 || die "gh CLI not found (brew install gh)"
command -v jq >/dev/null 2>&1 || die "jq not found (brew install jq)"

while [ $# -gt 0 ]; do
  case "$1" in
    --comments) WITH_COMMENTS=1 ;;
    --mine) SEARCH_AUTHOR="@me" ;;
    --author) shift; [ $# -gt 0 ] || die "--author needs a login"; SEARCH_AUTHOR="$1" ;;
    --repo) shift; [ $# -gt 0 ] || die "--repo needs owner/repo"; REPO_ALL="$1" ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) REFS+=("$1") ;;
  esac
  shift
done

# Resolve a single ref to "owner/repo<TAB>number". Returns nonzero on failure.
parse_ref() {
  local ref="$1"
  ref="${ref#https://github.com/}"; ref="${ref#http://github.com/}"
  if [[ "$ref" =~ ^([^/]+/[^/#]+)(#|/pull/|/)([0-9]+) ]]; then
    printf '%s\t%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[3]}"; return 0
  fi
  if [[ "$ref" =~ ^#?([0-9]+)$ ]]; then
    local r; r="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)" \
      || die "bare number '$ref' needs a current repo; pass owner/repo#$ref instead"
    printf '%s\t%s\n' "$r" "${BASH_REMATCH[1]}"; return 0
  fi
  echo "pr-status: unrecognized PR ref '$1' (use URL, owner/repo#N, or #N in a repo)" >&2
  return 1
}

# Collect "owner/repo<TAB>number" pairs from all input modes.
PAIRS=()
for r in "${REFS[@]:-}"; do [ -n "$r" ] || continue; p="$(parse_ref "$r")" && PAIRS+=("$p"); done
if [ -n "$REPO_ALL" ]; then
  while IFS= read -r n; do [ -n "$n" ] && PAIRS+=("$(printf '%s\t%s' "$REPO_ALL" "$n")"); done \
    < <(gh pr list --repo "$REPO_ALL" --state open --json number --jq '.[].number')
fi
if [ -n "$SEARCH_AUTHOR" ]; then
  while IFS=$'\t' read -r repo n; do [ -n "$n" ] && PAIRS+=("$(printf '%s\t%s' "$repo" "$n")"); done \
    < <(gh search prs --author "$SEARCH_AUTHOR" --state open --json repository,number \
          --jq '.[] | "\(.repository.nameWithOwner)\t\(.number)"')
fi

[ "${#PAIRS[@]}" -gt 0 ] || die "no PRs to check (give a ref, --repo, or --mine)"

FIELDS='number,title,state,isDraft,mergeable,mergeStateStatus,reviewDecision,reviews,statusCheckRollup,url'

print_one() {
  local repo="$1" num="$2"
  gh pr view "$num" --repo "$repo" --json "$FIELDS" --jq '
    def reason: {
      CLEAN:"READY to merge", BLOCKED:"BLOCKED: required approval / branch protection",
      BEHIND:"BEHIND base: needs update or rebase", DIRTY:"CONFLICTS: resolve before merge",
      DRAFT:"DRAFT: mark ready first", UNSTABLE:"UNSTABLE: non-required checks failing/pending",
      HAS_HOOKS:"READY (hooks will run on merge)", UNKNOWN:"UNKNOWN: GitHub still computing, re-check"
    }[.] // .;
    (.statusCheckRollup // []) as $c
    | [$c[] | (.conclusion // .state)] as $s
    | ([$s[]|select(.=="SUCCESS"or .=="NEUTRAL"or .=="SKIPPED")]|length) as $ok
    | ([$s[]|select(.=="FAILURE"or .=="TIMED_OUT"or .=="CANCELLED"or .=="ERROR"or .=="ACTION_REQUIRED"or .=="STARTUP_FAILURE")]|length) as $bad
    | ([$s[]|select(.=="PENDING"or .=="IN_PROGRESS"or .=="QUEUED"or .=="WAITING"or .==null)]|length) as $wait
    | "'"$repo"'#\(.number)  \(.state)\(if .isDraft then " (draft)" else "" end)  →  \(.mergeStateStatus|reason)",
      "  title:   \(.title)",
      "  review:  \(.reviewDecision // "no decision yet")\(if (.reviews|length)>0 then "  [" + ([.reviews[]|"\(.author.login):\(.state)"]|unique|join(", ")) + "]" else "" end)",
      "  checks:  \(if ($c|length)==0 then "none reported" else "\($ok)✓ \($bad)✗ \($wait)⏳" end)\(if $bad>0 or $wait>0 then "  → " + ([$c[]|select((.conclusion // .state)|IN("SUCCESS","NEUTRAL","SKIPPED")|not)|"\(.name // .context):\(.conclusion // .state)"]|join(", ")) else "" end)",
      "  merge:   mergeable=\(.mergeable)  state=\(.mergeStateStatus)",
      "  url:     \(.url)"
  ' || echo "$repo#$num  (could not fetch: check repo/number/access)"
}

print_comments() {
  local repo="$1" num="$2"
  local rev inl
  rev="$(gh api "repos/$repo/pulls/$num/reviews" \
        --jq '.[] | select((.body // "")!="") | "  [\(.state)] \(.user.login): \(.body|gsub("\r?\n";" ")|.[0:300])"' 2>/dev/null)"
  inl="$(gh api "repos/$repo/pulls/$num/comments" \
        --jq '.[] | "  \(.path):\(.line // .original_line) \(.user.login): \(.body|gsub("\r?\n";" ")|.[0:300])"' 2>/dev/null)"
  [ -n "$rev" ] && { echo "  --- review summaries ---"; echo "$rev"; }
  [ -n "$inl" ] && { echo "  --- inline comments ---"; echo "$inl"; }
  [ -z "$rev$inl" ] && echo "  (no review summaries or inline comments)"
}

for pair in "${PAIRS[@]}"; do
  IFS=$'\t' read -r repo num <<<"$pair"
  print_one "$repo" "$num"
  [ "$WITH_COMMENTS" -eq 1 ] && print_comments "$repo" "$num"
  echo
done
