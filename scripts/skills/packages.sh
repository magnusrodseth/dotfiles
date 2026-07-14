#!/bin/bash

# Lock file source (tracked in dotfiles)
LOCK_SOURCE="$HOME/dotfiles/scripts/skills/skill-lock.json"
# Lock file destination (where npx skills expects it)
LOCK_DEST="$HOME/.agents/.skill-lock.json"

# Function to display help
show_help() {
  echo "Usage: $0 [OPTION]"
  echo "Manage agent skills via npx skills."
  echo
  echo "Options:"
  echo "  export     Copy current skill-lock.json into dotfiles for tracking"
  echo "  install    Restore skills from tracked skill-lock.json"
  echo "  help       Display this help and exit"
}

SKILLS_DIR="$HOME/.agents/skills"
VENDOR_DIR="$HOME/dotfiles/.claude/skills"

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found. Install it first (brew install jq)."
    exit 1
  fi
}

# A skill is "vendored" when .claude/skills/<name> is a real directory rather
# than a symlink into ~/.agents/skills. Those are forks committed to the repo;
# `skills add` would overwrite them, so the lock entry is provenance only and
# must never drive an install.
is_vendored() {
  [[ -d "$VENDOR_DIR/$1" && ! -L "$VENDOR_DIR/$1" ]]
}

# Function to export current lock file to dotfiles
export_packages() {
  if [[ ! -f "$LOCK_DEST" ]]; then
    echo "No skill-lock.json found at $LOCK_DEST"
    exit 1
  fi
  require_jq

  # The live lock only knows about skills `skills add` installed, so a plain
  # copy would silently drop the entries for vendored forks. Carry those over
  # from the tracked lock so their provenance survives the round trip.
  local carried
  carried="$(jq -r '.skills | keys[]' "$LOCK_SOURCE" | while read -r skill; do
    is_vendored "$skill" && echo "$skill"
  done | jq -Rs 'split("\n") | map(select(length > 0))')"

  jq --argjson carried "$carried" --slurpfile tracked "$LOCK_SOURCE" '
    .skills = (($tracked[0].skills | with_entries(select(.key | IN($carried[])))) + .skills)
  ' "$LOCK_DEST" >"$LOCK_SOURCE.tmp" && mv "$LOCK_SOURCE.tmp" "$LOCK_SOURCE"

  echo "skill-lock.json exported to $LOCK_SOURCE ($(jq '.skills | length' "$LOCK_SOURCE") skills)"
}

# Function to restore skills from lock file
install_packages() {
  if [[ ! -f "$LOCK_SOURCE" ]]; then
    echo "No skill-lock.json found at $LOCK_SOURCE"
    echo "Run '$0 export' first to snapshot your current skills."
    exit 1
  fi
  require_jq
  mkdir -p "$SKILLS_DIR"

  # `skills experimental_install` only restores PROJECT skills from a
  # project-local skills-lock.json. It ignores the global lock entirely, so
  # driving it from here silently installed nothing. Install global skills
  # explicitly instead, one `skills add` per source repo so each is cloned once.
  local work
  work="$(mktemp)"
  local skill source skipped=0
  while IFS=$'\t' read -r skill source; do
    if [[ -e "$SKILLS_DIR/$skill" ]]; then
      skipped=$((skipped + 1))
    elif is_vendored "$skill"; then
      echo "Skipping $skill: vendored in .claude/skills"
      skipped=$((skipped + 1))
    else
      printf '%s\t%s\n' "$source" "$skill" >>"$work"
    fi
  done < <(jq -r '.skills | to_entries[] | "\(.key)\t\(.value.source)"' "$LOCK_SOURCE")

  if [[ ! -s "$work" ]]; then
    echo "All $skipped skills from the lock are already present."
  else
    local repo
    for repo in $(cut -f1 "$work" | sort -u); do
      local -a flags=()
      while IFS= read -r skill; do
        flags+=(-s "$skill")
      done < <(awk -F'\t' -v r="$repo" '$1 == r { print $2 }' "$work")
      echo "Installing $((${#flags[@]} / 2)) skill(s) from $repo"
      npx skills add "$repo" -g -y "${flags[@]}" >/dev/null 2>&1 ||
        echo "WARN: 'skills add $repo' failed"
    done
  fi
  rm -f "$work"

  # Report honestly: anything the lock promises that is still not on disk.
  local missing=0
  for skill in $(jq -r '.skills | keys[]' "$LOCK_SOURCE"); do
    if [[ ! -e "$SKILLS_DIR/$skill" ]] && ! is_vendored "$skill"; then
      echo "MISSING: $skill"
      missing=$((missing + 1))
    fi
  done
  if ((missing > 0)); then
    echo "$missing skill(s) from the lock could not be installed."
    return 1
  fi
  echo "Skills restored from lock file."

  # Mirror custom skills from dotfiles into ~/.agents/skills/ so they're
  # available to both Claude Code (.claude/skills) and other agent runtimes
  # that read from .agents/skills. Only mirrors real directories; skips
  # symlinks (those already point the other direction, into .agents/skills).
  mirror_custom_skills
}

# Function to symlink custom skills from dotfiles into ~/.agents/skills/
mirror_custom_skills() {
  local src_dir="$HOME/dotfiles/.claude/skills"
  local dest_dir="$HOME/.agents/skills"

  [[ ! -d "$src_dir" ]] && return 0
  mkdir -p "$dest_dir"

  for skill_path in "$src_dir"/*/; do
    [[ -L "${skill_path%/}" ]] && continue
    local skill_name
    skill_name="$(basename "$skill_path")"
    local target="$dest_dir/$skill_name"

    if [[ -L "$target" ]]; then
      continue
    elif [[ -e "$target" ]]; then
      echo "Skipping $skill_name: $target exists and is not a symlink"
      continue
    fi

    ln -s "${skill_path%/}" "$target"
    echo "Linked custom skill: $skill_name"
  done
}

# Ensure npx is available
if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found. Install Node.js first."
  exit 1
fi

case "$1" in
export)
  export_packages
  ;;
install)
  install_packages
  ;;
help)
  show_help
  ;;
*)
  echo "Invalid option: $1"
  show_help
  exit 1
  ;;
esac
