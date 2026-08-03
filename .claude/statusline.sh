#!/usr/bin/env bash
#
# Claude Code status line: "<branch> · <n>% context left".
#
# Wired up from .claude/settings.json ("statusLine"). Claude Code pipes one
# JSON object on stdin per update (debounced at 300ms) and renders whatever
# this prints on stdout.
#
# This used to be an inline jq one-liner in settings.json. The branch is why it
# is a script now: the status line payload carries no branch field. It has
# workspace.current_dir, workspace.git_worktree and workspace.repo.{host,owner,
# name}, but the checked-out ref is not in there, so it has to come from git.
#
# Deliberately reads workspace.current_dir and passes it to git -C rather than
# relying on the process's own cwd: current_dir follows the session if the
# working directory changes mid-session, and nothing documents what cwd this
# command inherits.
#
# Invoked as `bash statusline.sh`, so it needs no exec bit (scripts here are
# committed 644).
#
# Fields used, and why each is guarded:
#   .context_window.remaining_percentage - null early in a session and again
#     after /compact until the next API call, hence // 100.
#   .workspace.current_dir - documented as always present; .cwd holds the same
#     value and is the fallback.

set -uo pipefail

input="$(cat)"

# One jq process, not two: this runs on every status line update. @tsv keeps
# the fields separate, and `dir` is read last so a path containing spaces
# survives intact.
IFS=$'\t' read -r pct dir <<EOF
$(printf '%s' "$input" | jq -r '
  [ (.context_window.remaining_percentage // 100 | floor)
  , (.workspace.current_dir // .cwd // ".")
  ] | @tsv')
EOF

branch=""
if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # symbolic-ref is empty on a detached HEAD, and both it and rev-parse fail in
  # a repo with no commits yet.
  branch="$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null)" ||
    branch="$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)" ||
    branch=""
fi

if [ -n "$branch" ]; then
  printf '%s · %s%% context left\n' "$branch" "$pct"
else
  printf '%s%% context left\n' "$pct"
fi
