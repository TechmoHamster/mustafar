#!/bin/bash
# c_tailscale.sh — Phase C Tailscale bootstrap
set -euo pipefail

echo "== Mustafar Phase C: Tailscale bootstrap =="

if ! command -v tailscale >/dev/null 2>&1; then
  echo "Tailscale CLI not found. Install Tailscale and rerun."
  exit 1
fi

echo "Tailscale version: $(tailscale version | head -n1)"
echo "Bringing interface up (interactive auth may be required)..."
sudo tailscale up

echo "Current status:"
tailscale status || true

echo "Phase C complete."
