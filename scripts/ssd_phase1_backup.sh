#!/bin/zsh
# Mustafar — Phase 1: EFI Backup Helper
# Usage: ./ssd_phase1_backup.sh /dev/diskXs1
# Run `diskutil list` first to identify the correct EFI partition.
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 /dev/diskXs1"
  echo "Run 'diskutil list' first and pass the EFI partition identifier."
  exit 1
fi

EFI_DEV="$1"
OUT="$HOME/Desktop/Mustafar_EFI_Backup_$(date +%Y-%m-%d_%H%M)"
mkdir -p "$OUT"

echo "→ Mounting EFI partition $EFI_DEV..."
sudo diskutil mount "$EFI_DEV"

if [ ! -d /Volumes/EFI/EFI ]; then
  echo "✗ No /Volumes/EFI/EFI folder found. Check the mounted EFI partition."
  exit 2
fi

echo "→ Copying EFI folder..."
ditto /Volumes/EFI/EFI "$OUT/EFI"
diskutil unmount /Volumes/EFI

echo "→ Zipping..."
cd "$HOME/Desktop"
zip -r "$(basename "$OUT").zip" "$(basename "$OUT")"
echo "✓ Saved: $OUT.zip"
echo ""
echo "Copy this ZIP to an external drive or Tatooine."
