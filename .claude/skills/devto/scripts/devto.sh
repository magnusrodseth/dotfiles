#!/usr/bin/env bash
# Dev.to (Forem) API helper. Resolves the API key from 1Password per call and
# never writes it to stdout. See ../SKILL.md.
set -euo pipefail

API="https://dev.to/api"
OP_REF="op://Private/Dev.to API Key/credential"
export OP_ACCOUNT="${OP_ACCOUNT:-my.1password.eu}"

die() { printf '%s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }
need curl; need jq; need op

key() {
  local k
  k="$(op read "$OP_REF" 2>/dev/null)" || die "could not read the API key from 1Password. If Touch ID timed out, rerun and approve promptly."
  [ -n "$k" ] || die "API key is empty at $OP_REF"
  [ "$k" != "REPLACE-ME-PASTE-KEY-HERE" ] && printf '%s' "$k" || die "API key is still the placeholder. Paste the real key into 1Password first."
}

# curl wrapper: key goes in via @- so it never appears in argv or process list
api() {
  local method="$1" path="$2" body="${3:-}"
  local hdr; hdr="$(printf 'api-key: %s' "$(key)")"
  if [ -n "$body" ]; then
    printf '%s' "$hdr" | curl -sS -X "$method" "$API$path" \
      -H @- -H 'Content-Type: application/json' --data-binary "$body" \
      -w '\n%{http_code}'
  else
    printf '%s' "$hdr" | curl -sS -X "$method" "$API$path" -H @- -w '\n%{http_code}'
  fi
}

# split the trailing status code off an api() response
split() {
  local raw="$1"
  STATUS="$(printf '%s' "$raw" | tail -n1)"
  BODY="$(printf '%s' "$raw" | sed '$d')"
}

check() {
  case "$STATUS" in
    200|201) : ;;
    401) die "401 unauthorized. The key in 1Password is wrong or revoked." ;;
    422) die "422 unprocessable. Forem said: $(printf '%s' "$BODY" | jq -r '.error // .errors // .' 2>/dev/null)" ;;
    429) die "429 rate limited. Wait and retry." ;;
    *)   die "HTTP $STATUS: $(printf '%s' "$BODY" | head -c 400)" ;;
  esac
}

strip_frontmatter() {
  awk 'NR==1 && /^---[[:space:]]*$/ {fm=1; next} fm && /^---[[:space:]]*$/ {fm=0; next} !fm' "$1"
}

# build the {"article":{...}} payload from a file plus optional flags
build_payload() {
  local file="$1"; shift
  local title="" tags="" desc="" canonical="" series="" image="" keep=0 published=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --title)             title="$2"; shift 2 ;;
      --tags)              tags="$2"; shift 2 ;;
      --description)       desc="$2"; shift 2 ;;
      --canonical)         canonical="$2"; shift 2 ;;
      --series)            series="$2"; shift 2 ;;
      --main-image)        image="$2"; shift 2 ;;
      --published)         published="$2"; shift 2 ;;
      --keep-frontmatter)  keep=1; shift ;;
      *) die "unknown flag: $1" ;;
    esac
  done

  [ -f "$file" ] || die "no such file: $file"

  local tmp; tmp="$(mktemp)"; trap 'rm -f "$tmp"' RETURN
  if [ "$keep" -eq 1 ]; then cat "$file" > "$tmp"; else strip_frontmatter "$file" > "$tmp"; fi
  [ -s "$tmp" ] || die "nothing to send: $file is empty after frontmatter stripping"

  if [ -n "$tags" ]; then
    local n; n="$(printf '%s' "$tags" | awk -F, '{print NF}')"
    [ "$n" -le 4 ] || die "Dev.to allows at most 4 tags, got $n"
  fi

  jq -n --rawfile body "$tmp" \
    --arg title "$title" --arg tags "$tags" --arg desc "$desc" \
    --arg canonical "$canonical" --arg series "$series" --arg image "$image" \
    --arg published "$published" '
    {article: ({body_markdown: $body}
      + (if $title     != "" then {title: $title}                 else {} end)
      + (if $tags      != "" then {tags: $tags}                   else {} end)
      + (if $desc      != "" then {description: $desc}            else {} end)
      + (if $canonical != "" then {canonical_url: $canonical}     else {} end)
      + (if $series    != "" then {series: $series}               else {} end)
      + (if $image     != "" then {main_image: $image}            else {} end)
      + (if $published != "" then {published: ($published=="true")} else {} end))}'
}

report() {
  printf '%s' "$BODY" | jq -r '
    "id:        \(.id)",
    "title:     \(.title)",
    "published: \(.published)",
    "tags:      \((.tag_list // []) | join(", "))",
    "url:       \(.url // "n/a")",
    "edit:      https://dev.to/\(.user.username)/\(.slug)/edit"'
}

cmd="${1:-}"; [ -n "$cmd" ] || die "usage: devto.sh {whoami|list|get|draft|update|publish|unpublish}"
shift || true

case "$cmd" in
  whoami)
    split "$(api GET /users/me)"; check
    printf '%s' "$BODY" | jq -r '"authenticated as \(.username) (id \(.id))"'
    ;;

  list)
    case "${1:-all}" in
      published)   p=/articles/me/published ;;
      unpublished) p=/articles/me/unpublished ;;
      all|"")      p=/articles/me/all ;;
      *) die "list takes: published | unpublished | all" ;;
    esac
    split "$(api GET "$p?per_page=100")"; check
    printf '%s' "$BODY" | jq -r 'if length==0 then "(none)" else
      (.[] | "\(.id)\t\(if .published then "live " else "draft" end)\t\(.title)") end'
    ;;

  get)
    [ -n "${1:-}" ] || die "usage: devto.sh get <id>"
    split "$(api GET "/articles/$1")"; check
    printf '%s\n' "$BODY" | jq .
    ;;

  draft)
    [ -n "${1:-}" ] || die "usage: devto.sh draft <file.md> [flags]"
    f="$1"; shift
    split "$(api POST /articles "$(build_payload "$f" --published false "$@")")"; check
    echo "Draft created (not public)."
    report
    ;;

  update)
    [ -n "${2:-}" ] || die "usage: devto.sh update <id> <file.md> [flags]"
    id="$1"; f="$2"; shift 2
    split "$(api PUT "/articles/$id" "$(build_payload "$f" "$@")")"; check
    echo "Updated."
    report
    ;;

  publish)
    [ -n "${1:-}" ] || die "usage: devto.sh publish <id>"
    split "$(api PUT "/articles/$1" '{"article":{"published":true}}')"; check
    echo "PUBLISHED. This is now public and will be crawled within minutes."
    report
    ;;

  unpublish)
    [ -n "${1:-}" ] || die "usage: devto.sh unpublish <id>"
    split "$(api PUT "/articles/$1/unpublish")"; check
    echo "Unpublished. The article is hidden, but anything already crawled or cached stays out there."
    ;;

  *) die "unknown command: $cmd" ;;
esac
