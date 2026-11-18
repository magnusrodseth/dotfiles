#!/usr/bin/env bash
# PreToolUse hook for Claude Code (~/.claude/settings.json) and Codex
# (~/.codex/hooks.json). Blocks a Bash call that would publish agent
# attribution: a "Co-Authored-By: <agent>" trailer or a "Generated with
# <agent>" footer in a git commit, or in a gh PR/issue body or comment.
#
# The git commit-msg hook in ~/.config/git/hooks strips trailers from commits,
# but PR bodies never pass through git, and --no-verify skips commit-msg. This
# covers both. Both agents treat exit 2 plus a stderr reason as "deny".
# Added 18.11.2026.
set -uo pipefail

payload="$(cat)"
command="$(jq -r '.tool_input.command // empty' <<<"$payload" 2>/dev/null)"
[ -n "$command" ] || exit 0

# Only commands that publish text: git commit/merge/tag, gh pr/issue/release, gh api.
grep -qE '(^|[;&|(` ])(git[^;&|]*[[:space:]](commit|merge|tag|notes)|gh[[:space:]]+(pr|issue|release|api|gist))([[:space:]]|$)' <<<"$command" || exit 0

pattern='(Co-Authored-By:[^\n]*(Claude|Anthropic|anthropic\.com|Codex|OpenAI|openai\.com|ChatGPT|Copilot|OpenCode|opencode\.ai|Cursor|Gemini|Aider))|(Generated (with|by)[^\n]{0,8}(Claude|Codex|OpenCode|ChatGPT|Copilot))'

text="$command"
# Also read body files named on the command line (gh --body-file/-F, git -F/--file).
while IFS= read -r f; do
  f="${f%\"}"; f="${f#\"}"; f="${f%\'}"; f="${f#\'}"
  f="${f/#\~/$HOME}"
  [ -n "$f" ] && [ "$f" != "-" ] && [ -f "$f" ] && text+=$'\n'"$(cat "$f")"
done < <(grep -oE -- '(--body-file|--file|-F)[= ]+("[^"]+"|'"'"'[^'"'"']+'"'"'|[^ ;&|]+)' <<<"$command" | sed -E 's/^(--body-file|--file|-F)[= ]+//')

if grep -qiE "$pattern" <<<"$text"; then
  echo "Blocked: this would publish agent attribution (a Co-Authored-By trailer or 'Generated with' footer for an AI agent). Magnus is the sole author of commits and PRs. Remove those lines and run the command again." >&2
  exit 2
fi
exit 0
