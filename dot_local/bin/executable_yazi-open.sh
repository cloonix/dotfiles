#!/bin/bash
MY_ID=12345678
FOLDER="${1:-$HOME}"

if pgrep -x yazi >/dev/null 2>&1; then
  ya emit-to "$MY_ID" tab_create "$FOLDER"
else
  kitty yazi --client-id "$MY_ID" "$FOLDER" &
fi

osascript -e 'tell application "kitty" to activate'
