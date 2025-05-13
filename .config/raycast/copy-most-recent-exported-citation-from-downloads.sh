#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy Most Recent Exported Citation From Downloads
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📄

# Documentation:
# @raycast.description Copies the contents of the most recent `Exported Items.bib` file in the `~/Downloads` directory.
# @raycast.author magnusrodseth
# @raycast.authorURL https://raycast.com/magnusrodseth

# Find the most recent 'Exported Items.bib' file in Downloads
latest_file=$(ls -t ~/Downloads/"Exported Items.bib" 2>/dev/null | head -n 1)

if [ -f "$latest_file" ]; then
    # Copy contents to clipboard
    cat "$latest_file" | pbcopy
    echo "✅ Citation copied to clipboard!"
else
    echo "❌ No 'Exported Items.bib' file found in Downloads"
fi
