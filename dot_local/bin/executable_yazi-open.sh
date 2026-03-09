#!/bin/bash
MY_ID=12345678
FOLDER="${1:-$HOME}"

if ya emit-to "$MY_ID" tab_create "$FOLDER" 2>/dev/null; then
  # emit succeeded → instance with that ID is running
  osascript -e 'tell application "System Events" to set frontmost of process "kitty" to true'
else
  # emit failed → no instance with that ID, launch one
  kitty yazi --client-id "$MY_ID" "$FOLDER" &
fi
