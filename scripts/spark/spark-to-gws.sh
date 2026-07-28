#!/usr/bin/env bash
#
# spark-to-gws.sh - turn a Spark deep link into a Gmail message you can work on
# with gws.
#
# Spark is the client, gws is the powerhouse. Cmd+L in Spark copies a link like
#
#   readdle-spark://bl=QTptYWdudXMucm9kc2V0aEBnbWFpbC5jb207SUQ6TU42...
#
# which is base64 (with CRLF and padding percent-encoded) over four fields:
#
#   A    account the message lives in
#   ID   the RFC822 Message-ID header
#   gID  Gmail's own message id, in DECIMAL
#   last a unix timestamp
#
# gID is the whole trick: Gmail's API speaks hex, so int -> hex hands you the
# exact id that `gws gmail users messages get --params '{"id": ...}'` wants. No
# search, no guessing. When gID is absent (a non-Gmail account), we fall back to
# Gmail's rfc822msgid: search operator on the Message-ID, which is slower but
# works anywhere.
#
# Usage:
#   spark-to-gws.sh              # read the link from the clipboard (Cmd+L)
#   spark-to-gws.sh "<link>"     # or pass it explicitly
#   spark-to-gws.sh --id         # print only the Gmail message id, for piping

set -uo pipefail

ID_ONLY=0
LINK=""
for arg in "$@"; do
  case "$arg" in
    --id|-i) ID_ONLY=1 ;;
    -h|--help) sed -n '3,28p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) LINK="$arg" ;;
  esac
done

if [ -z "$LINK" ] && command -v pbpaste >/dev/null 2>&1; then
  LINK="$(pbpaste)"
fi
if [ -z "$LINK" ]; then
  echo "no link given and clipboard is empty" >&2
  exit 1
fi

python3 - "$LINK" "$ID_ONLY" <<'PY'
import base64, json, subprocess, sys, urllib.parse

link, id_only = sys.argv[1].strip(), sys.argv[2] == "1"

if "bl=" not in link:
    print("not a Spark deep link (no bl= payload). Use Cmd+L in Spark to copy one.",
          file=sys.stderr)
    sys.exit(1)

payload = urllib.parse.unquote(link.split("bl=", 1)[1])
payload = payload.replace("\r", "").replace("\n", "")
payload += "=" * (-len(payload) % 4)  # tolerate stripped padding
try:
    raw = base64.b64decode(payload).decode("utf-8", "replace")
except Exception as e:
    print(f"could not decode payload: {e}", file=sys.stderr)
    sys.exit(1)

fields = {}
for part in raw.split(";"):
    k, sep, v = part.partition(":")
    if sep:
        fields[k] = v

account = fields.get("A", "")
rfc822 = fields.get("ID", "")
gid = fields.get("gID", "")

msg_id = format(int(gid), "x") if gid.isdigit() else ""


def gws(args):
    try:
        r = subprocess.run(["gws"] + args, capture_output=True, text=True, timeout=30)
    except (OSError, subprocess.SubprocessError):
        return None
    t = r.stdout
    i = t.find("{")
    if i < 0:
        return None
    try:
        return json.loads(t[i:])
    except ValueError:
        return None


# Fall back to Gmail's own search when there is no gID to convert.
if not msg_id and rfc822:
    d = gws(["gmail", "users", "messages", "list", "--params",
             json.dumps({"userId": "me", "q": f"rfc822msgid:{rfc822}"}), "--format", "json"])
    if d and d.get("messages"):
        msg_id = d["messages"][0]["id"]

if not msg_id:
    print("could not resolve a Gmail message id from this link", file=sys.stderr)
    sys.exit(1)

if id_only:
    print(msg_id)
    sys.exit(0)

d = gws(["gmail", "users", "messages", "get", "--params",
         json.dumps({"userId": "me", "id": msg_id, "format": "metadata"}), "--format", "json"])

print(f"  account   {account}")
print(f"  messageId {msg_id}")

if d and "payload" in d:
    h = {x["name"].lower(): x["value"] for x in d["payload"].get("headers", [])}
    print(f"  threadId  {d.get('threadId','')}")
    for label, key in (("date", "date"), ("from", "from"), ("subject", "subject")):
        if h.get(key):
            print(f"  {label:9} {h[key][:100]}")
    print()
    print(f"  https://mail.google.com/mail/u/0/#inbox/{msg_id}")
else:
    print("  (could not fetch from Gmail; id resolved from the link alone)")

print()
print("  read:   gws gmail users messages get --params "
      f"'{{\"userId\":\"me\",\"id\":\"{msg_id}\",\"format\":\"full\"}}'")
print(f"  thread: gws gmail users threads get --params "
      f"'{{\"userId\":\"me\",\"id\":\"{d.get('threadId', '') if d else ''}\"}}'")
print(f"  reply:  gws gmail +reply --message-id {msg_id} --body '...' --draft")
PY
