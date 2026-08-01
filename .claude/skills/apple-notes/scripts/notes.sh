#!/usr/bin/env bash
# Apple Notes CLI. Thin, quoting-safe wrapper around osascript.
#
# Every string that comes from the caller (title, body, folder, account, query)
# is written to a temp file and read back inside AppleScript as «class utf8».
# Nothing is interpolated into an AppleScript string literal, so quotes,
# newlines, backslashes and æøå all survive intact.

set -euo pipefail

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

die() { printf 'notes.sh: %s\n' "$1" >&2; exit 1; }

# lit <string> -> AppleScript expression evaluating to that string
lit() {
  local f
  f="$(mktemp "$TMP/lit.XXXXXX")"
  printf '%s' "${1-}" >"$f"
  # `read` on a zero-length file errors, so fall back to an empty literal
  if [ -s "$f" ]; then
    printf '(read POSIX file "%s" as «class utf8»)' "$f"
  else
    printf '""'
  fi
}

run() { osascript 2>&1; }

# resolve <id-or-title> -> AppleScript reference to a single note
resolve() {
  local t="$1"
  case "$t" in
    x-coredata://*) printf 'note id %s' "$(lit "$t")" ;;
    *)              printf 'first note whose name is %s' "$(lit "$t")" ;;
  esac
}

ACCOUNT=""; FOLDER=""; LIMIT=0
CMD="${1-}"; [ -n "$CMD" ] || CMD=help
shift || true

POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    --account) ACCOUNT="${2-}"; shift 2 ;;
    --folder)  FOLDER="${2-}";  shift 2 ;;
    --limit)   LIMIT="${2-}";   shift 2 ;;
    -h|--help) CMD=help; shift ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
set -- ${POSITIONAL+"${POSITIONAL[@]}"}

# AppleScript expression for the account to operate on
acct_expr() {
  if [ -n "$ACCOUNT" ]; then printf 'account %s' "$(lit "$ACCOUNT")"
  else printf 'default account'; fi
}

# AppleScript expression for the container to read notes from / write notes to
container_expr() {
  if [ -n "$FOLDER" ]; then printf 'folder %s of %s' "$(lit "$FOLDER")" "$(acct_expr)"
  else printf 'default folder of %s' "$(acct_expr)"; fi
}

case "$CMD" in

accounts)
  run <<EOF
tell application "Notes"
  set out to ""
  repeat with a in accounts
    set out to out & (name of a) & tab & (count of notes of a) & linefeed
  end repeat
  return out
end tell
EOF
  ;;

folders)
  run <<EOF
tell application "Notes"
  set out to ""
  repeat with f in folders of $(acct_expr)
    set out to out & (name of f) & tab & (count of notes of f) & linefeed
  end repeat
  return out
end tell
EOF
  ;;

# list: id <TAB> ISO-modified <TAB> name, newest first
list)
  run <<EOF
tell application "Notes"
  set out to ""
  set i to 0
  repeat with n in (notes of $(container_expr))
    set i to i + 1
    if $LIMIT > 0 and i > $LIMIT then exit repeat
    set out to out & (id of n) & tab & ((modification date of n) as «class isot» as string) & tab & (name of n) & linefeed
  end repeat
  return out
end tell
EOF
  ;;

# search: substring match on note body, case-insensitive, across every account
search)
  [ $# -ge 1 ] || die "search needs a query"
  run <<EOF
tell application "Notes"
  set out to ""
  set i to 0
  repeat with n in (every note whose body contains $(lit "$1"))
    set i to i + 1
    if $LIMIT > 0 and i > $LIMIT then exit repeat
    set out to out & (id of n) & tab & (name of n) & linefeed
  end repeat
  return out
end tell
EOF
  ;;

get)
  [ $# -ge 1 ] || die "get needs an id or title"
  run <<EOF
tell application "Notes" to return plaintext of ($(resolve "$1"))
EOF
  ;;

html)
  [ $# -ge 1 ] || die "html needs an id or title"
  run <<EOF
tell application "Notes" to return body of ($(resolve "$1"))
EOF
  ;;

# create: HTML body on stdin. Prints the new note id.
create)
  BODY="$(cat)"
  [ -n "$BODY" ] || die "create needs an HTML body on stdin"
  run <<EOF
tell application "Notes"
  set n to make new note at ($(container_expr)) with properties {body:$(lit "$BODY")}
  return id of n
end tell
EOF
  ;;

# append / replace: HTML on stdin
append)
  [ $# -ge 1 ] || die "append needs an id or title"
  BODY="$(cat)"
  run <<EOF
tell application "Notes"
  set n to ($(resolve "$1"))
  set body of n to (body of n) & $(lit "$BODY")
  return id of n
end tell
EOF
  ;;

replace)
  [ $# -ge 1 ] || die "replace needs an id or title"
  BODY="$(cat)"
  run <<EOF
tell application "Notes"
  set n to ($(resolve "$1"))
  set body of n to $(lit "$BODY")
  return id of n
end tell
EOF
  ;;

# delete: moves to Recently Deleted, recoverable for ~30 days
delete)
  [ $# -ge 1 ] || die "delete needs an id or title"
  run <<EOF
tell application "Notes"
  set n to ($(resolve "$1"))
  set nm to name of n
  delete n
  return "deleted: " & nm
end tell
EOF
  ;;

# show: open the note in the Notes UI (steals focus)
show)
  [ $# -ge 1 ] || die "show needs an id or title"
  run <<EOF
tell application "Notes"
  activate
  show ($(resolve "$1"))
end tell
EOF
  ;;

attach)
  [ $# -ge 2 ] || die "attach needs an id-or-title and a file path"
  [ -f "$2" ] || die "no such file: $2"
  ABS="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
  run <<EOF
tell application "Notes"
  set n to ($(resolve "$1"))
  set a to make new attachment at n with data (POSIX file $(lit "$ABS"))
  return "attached: " & (name of a)
end tell
EOF
  ;;

help|*)
  cat <<'USAGE'
notes.sh <command> [args] [--account NAME] [--folder NAME] [--limit N]

  accounts                    list accounts        -> name <TAB> note count
  folders                     list folders         -> name <TAB> note count
  list                        list notes, newest   -> id <TAB> ISO-modified <TAB> name
  search <query>              body substring, all accounts -> id <TAB> name
  get <id|title>              plaintext of a note
  html <id|title>             raw HTML body of a note
  create <  body.html         create note, HTML on stdin -> prints new id
  append <id|title> < f.html  append HTML to a note
  replace <id|title> < f.html replace a note's HTML
  delete <id|title>           move to Recently Deleted (recoverable)
  show <id|title>             open in the Notes UI (steals focus)
  attach <id|title> <file>    attach a file to a note

Target a note by id (x-coredata://...) or by title. Titles are NOT unique:
by-title resolves to the first match. Use ids for delete/replace.
USAGE
  ;;
esac
