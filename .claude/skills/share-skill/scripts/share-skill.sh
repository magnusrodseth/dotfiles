#!/usr/bin/env bash
# Package a Claude Code skill into a shareable zip inside a fresh temp folder,
# then open that folder in Finder (macOS). The zip's top-level folder is the
# skill name, so it unzips to <skill-name>/SKILL.md. Symlinks are dereferenced
# so recipients get real files; OS junk and caches are excluded.
set -euo pipefail

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
  echo "usage: share-skill.sh <skill-name-or-path>" >&2
  exit 2
fi

# Normalize: strip a leading slash the user might include (e.g. "/humanize").
name="${1#/}"

# Resolve the skill directory: a direct path first, then known skill locations.
skill_dir=""
if [ -f "$name/SKILL.md" ]; then
  skill_dir="$name"
else
  config_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  for base in "./.claude/skills" "$config_dir/skills" "$HOME/.claude/skills"; do
    if [ -f "$base/$name/SKILL.md" ]; then
      skill_dir="$base/$name"
      break
    fi
  done
fi

if [ -z "$skill_dir" ]; then
  echo "error: no skill named '$name' with a SKILL.md found in ./.claude/skills, \$CLAUDE_CONFIG_DIR/skills, or ~/.claude/skills" >&2
  exit 1
fi

# Resolve symlinks to the physical directory (authored skills are often symlinked).
real_dir="$(cd "$skill_dir" && pwd -P)"
skill_name="$(basename "$real_dir")"

# Stage a clean, dereferenced copy in a readable, date-stamped folder under /tmp.
stamp="$(date +%Y-%m-%d_%H%M%S)"
tmp_root="/tmp/shared-skills/${skill_name}_${stamp}"
stage="$tmp_root/$skill_name"
rm -rf "$stage"
mkdir -p "$stage"
cp -RL "$real_dir/." "$stage/"

# Strip OS junk, VCS metadata, caches, and build artifacts from the staged copy.
find "$stage" \( \
  -name '.DS_Store' -o \
  -name 'Thumbs.db' -o \
  -name '*.bak' -o \
  -name '*.log' -o \
  -name '*-cache*' -o \
  -name '.git' -o \
  -name 'node_modules' -o \
  -name '__pycache__' \
  \) -exec rm -rf {} + 2>/dev/null || true

# Build the zip inside the temp folder, then drop the staging copy.
zip_path="$tmp_root/$skill_name.zip"
( cd "$tmp_root" && zip -rq "$skill_name.zip" "$skill_name" )
rm -rf "$stage"

# Reveal the zip in Finder, selected inside its dated folder (macOS). Safe no-op elsewhere.
if command -v open >/dev/null 2>&1; then
  open -R "$zip_path" 2>/dev/null || true
fi

echo "Packaged '$skill_name'"
echo "Zip:    $zip_path"
echo "Folder: $tmp_root"
