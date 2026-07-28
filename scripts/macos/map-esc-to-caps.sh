#!/bin/bash
#
# Remap Caps Lock to Escape, persistently, via a hidutil LaunchAgent.
#
# This script could never work before 28.07.2026. It required
# ~/Library/LaunchAgents/com.local.KeyRemapping.plist to already exist, and that
# plist has never been in this repo, so every run exited 1 at the first check.
# It also ended with `launchctl start "$FILENAME.plist"`, passing a filename
# where launchctl expects a job label. The plist is generated here now.
#
# Key codes are USB HID usages: 0x700000039 = Caps Lock, 0x700000029 = Escape.
# Swap Src and Dst below to reverse the direction.
#
# Not called by install.sh: this changes how the keyboard behaves, so it stays
# an explicit, manual step.

set -uo pipefail

LABEL="com.local.KeyRemapping"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

mkdir -p "$HOME/Library/LaunchAgents"

cat >"$PLIST" <<'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.local.KeyRemapping</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
PLIST_EOF

echo "Wrote $PLIST"

# `load`/`unload` are deprecated; bootout/bootstrap is the modern pair. bootout
# on a job that is not loaded returns non-zero, which is expected on first run.
launchctl bootout "gui/$UID/$LABEL" 2>/dev/null && echo "Unloaded existing $LABEL"

if ! launchctl bootstrap "gui/$UID" "$PLIST" 2>/dev/null; then
  launchctl unload "$PLIST" 2>/dev/null
  launchctl load "$PLIST" || { echo "Error: could not load $PLIST" >&2; exit 1; }
fi

# Verify against the live mapping, not `launchctl list`: the latter only proves
# the job is registered, not that the remap took effect. 0x700000029 decimal is
# 30064771113, which is what hidutil prints back for the destination key.
if hidutil property --get "UserKeyMapping" 2>/dev/null | grep -q '30064771113'; then
  echo "Caps Lock is now Escape."
else
  echo "Error: the remap did not take effect." >&2
  echo "Check: hidutil property --get UserKeyMapping" >&2
  exit 1
fi
