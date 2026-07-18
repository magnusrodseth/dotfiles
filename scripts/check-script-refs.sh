#!/usr/bin/env bash
#
# check-script-refs.sh - fail when a tracked script references a repo script
# that git does not carry.
#
# The failure this exists for, observed here: doctor.sh shipped a call to
# scripts/skills/check-skill-integrity.sh while that script sat untracked in
# the working tree. On the authoring machine the file was right there on disk,
# so every check passed and nothing looked wrong. On a fresh clone doctor.sh
# died on "No such file or directory" and could never reach a green run - which
# breaks the whole install -> doctor -> fix -> repeat convergence loop the repo
# is built around.
#
# doctor.sh's repo-hygiene check is directional: it catches generated junk
# leaking INTO the tree, and has no notion of authored work failing to get OUT
# of it. This covers the other direction.
#
# Reads the INDEX (git ls-files, git show :<path>), not the working tree, so a
# script staged alongside the commit that references it passes. Reference and
# referent land in the same commit or neither does.
#
# Only catches references written as a repo-root-relative path, i.e. one
# starting scripts/ and ending .sh. A sibling call through "$SCRIPT_DIR/..."
# is invisible here; those resolve next to a script that is itself tracked, so
# they fail loudly at author time rather than silently on someone else's clone.
#
# The match is deliberately blind to context: a path inside a comment or an
# error string counts, because a hint telling someone to run a script that does
# not exist is its own bug. The cost is that illustrative examples in prose trip
# it, so write those with a placeholder (scripts/<name>.sh) that cannot be
# mistaken for a real path. Skipping comments instead would blind the check to
# the user-facing "run: ..." hints that are worth verifying.
#
# Read-only: reports, never mutates. Run standalone, from pre-commit, or from
# doctor.sh.
#
# Usage: check-script-refs.sh

set -uo pipefail

cd "$(git rev-parse --show-toplevel)" || exit 1

tracked="$(git ls-files)"
shell_scripts="$(printf '%s\n' "$tracked" | grep -E '\.sh$' || true)"

problems=""
while IFS= read -r src; do
  [ -n "$src" ] || continue
  # The leading boundary is load-bearing: without it, an absolute path into
  # someone else's tree ("$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh")
  # matches on its suffix and reports as a missing repo script. Require the
  # match to start a path, then strip the boundary character back off.
  refs="$(git show ":$src" 2>/dev/null \
    | grep -oE '(^|[^A-Za-z0-9_./-])scripts/[A-Za-z0-9/_.-]+\.sh' \
    | sed -E 's|^[^A-Za-z0-9_./-]||' \
    | sort -u || true)"
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    if ! printf '%s\n' "$tracked" | grep -qxF "$ref"; then
      problems="${problems}${src} -> ${ref}"$'\n'
    fi
  done <<< "$refs"
done <<< "$shell_scripts"

if [ -n "$problems" ]; then
  n="$(printf '%s' "$problems" | grep -c .)"
  echo "$n script reference(s) point at files git does not carry:" >&2
  printf '%s' "$problems" | sed 's/^/    /' >&2
  echo "Stage the referenced script(s) so they land in the same commit." >&2
  exit 1
fi

n_src="$(printf '%s\n' "$shell_scripts" | grep -c . || true)"
echo "Script refs OK ($n_src tracked script(s) checked)."
