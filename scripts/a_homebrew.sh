#!/bin/bash
# a_homebrew.sh — Phase A bootstrap for Homebrew + core packages
set -euo pipefail

BREWFILE="config/Brewfile"

echo "== Mustafar Phase A: Homebrew bootstrap =="

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install from https://brew.sh and rerun."
  exit 1
fi

if [ ! -f "$BREWFILE" ]; then
  echo "Missing $BREWFILE"
  exit 1
fi

brew update
brew bundle --file "$BREWFILE"
brew cleanup

echo "Phase A complete."
