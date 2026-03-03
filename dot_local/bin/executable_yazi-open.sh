#!/bin/bash
MY_ID=12345678
FOLDER="${1:-$HOME}"

if pgrep -x yazi >/dev/null 2>&1; then
  ya emit-to "$MY_ID" tab_create "$FOLDER"
  osascript -e 'tell application "System Events" to set frontmost of process "kitty" to true'
else
  kitty yazi --client-id "$MY_ID" "$FOLDER" &
fi
