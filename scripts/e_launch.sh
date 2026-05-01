#!/bin/bash
# e_launch.sh — Phase E launchd installer for Mustafar jobs
set -euo pipefail

LAUNCH_DIR="$HOME/Library/LaunchAgents"

mkdir -p "$LAUNCH_DIR"

echo "== Mustafar Phase E: launchd install =="

for plist in launchd/com.mustafar.backup.plist launchd/com.mustafar.smart.plist; do
  if [ ! -f "$plist" ]; then
    echo "Missing $plist"
    exit 1
  fi

  dest="$LAUNCH_DIR/$(basename "$plist")"
  cp "$plist" "$dest"
  launchctl unload "$dest" >/dev/null 2>&1 || true
  launchctl load "$dest"
  echo "Loaded $(basename "$plist")"
done

echo "Active jobs:"
launchctl list | grep mustafar || true

echo "Phase E complete."
