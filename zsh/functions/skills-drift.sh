#!/bin/zsh

# Weekly nudge when a skill's docs fall behind the binary they document.
#
# Skills generated from a CLI (gws, spark) embed the version they were built
# from. When the binary moves ahead, the skill still loads and still reads as
# authoritative - it just quietly describes an older flag set. On 28.07.2026
# that cost a mangled email: gws-gmail documented only --to/--subject/--body,
# so an attachment meant hand-rolling MIME, while the installed gws 0.22.5 had
# --attach and --draft all along.
#
# This has to run locally. Cloud routines (/schedule) cannot see ~/.agents or
# run the installed binaries, so they cannot detect this class of drift at all.
#
# check-skill-integrity.sh --drift owns the actual comparison and stays silent
# when clean. This file only decides when to run it and where to show it.

_SKILLS_DRIFT_STAMP="${XDG_CACHE_HOME:-$HOME/.cache}/skills-drift.stamp"
_SKILLS_DRIFT_SCRIPT="$HOME/dotfiles/scripts/skills/check-skill-integrity.sh"

# Run the drift check now and always say something. Safe to run any time.
function skills-check() {
  if [[ ! -f "$_SKILLS_DRIFT_SCRIPT" ]]; then
    print -u2 "skills-check: $_SKILLS_DRIFT_SCRIPT not found"
    return 1
  fi

  local out
  out="$(bash "$_SKILLS_DRIFT_SCRIPT" --drift 2>/dev/null)"

  mkdir -p "${_SKILLS_DRIFT_STAMP:h}" 2>/dev/null
  : >| "$_SKILLS_DRIFT_STAMP" 2>/dev/null

  if [[ -n "$out" ]]; then
    print -r -- ""
    print -r -- "$out"
    print -r -- ""
  else
    print -r -- "skills: no version drift"
  fi
}

# Startup hook: at most once every 7 days, and only speaks when there IS drift.
# A clean week is completely silent, so this never becomes background noise.
function _skills_drift_autocheck() {
  [[ -o interactive ]] || return 0
  [[ -f "$_SKILLS_DRIFT_SCRIPT" ]] || return 0

  # Stamp touched within the last 7 days means we already looked recently.
  if [[ -f "$_SKILLS_DRIFT_STAMP" ]]; then
    [[ -n "$(find "$_SKILLS_DRIFT_STAMP" -mtime -7 2>/dev/null)" ]] && return 0
  fi

  local out
  out="$(bash "$_SKILLS_DRIFT_SCRIPT" --drift 2>/dev/null)"

  mkdir -p "${_SKILLS_DRIFT_STAMP:h}" 2>/dev/null
  : >| "$_SKILLS_DRIFT_STAMP" 2>/dev/null

  # Silence is the common case; only interrupt when there is something to fix.
  [[ -z "$out" ]] && return 0

  print -r -- ""
  print -r -- "$out"
  print -r -- "  (re-run any time with: skills-check)"
  print -r -- ""
}

_skills_drift_autocheck
