#!/bin/zsh
# Mustafar — Phase 10: Post-Upgrade Validation
# Run this after the 1TB SSD install, OpenCore internal boot,
# and OCLP root patches are all confirmed working.
set -euo pipefail

OUT="$HOME/Desktop/Mustafar_PostUpgrade_$(date +%Y-%m-%d_%H%M)"
mkdir -p "$OUT"

echo "→ Collecting post-upgrade system info..."
sw_vers > "$OUT/00_macos_version.txt"
system_profiler SPHardwareDataType > "$OUT/01_hardware.txt"
system_profiler SPDisplaysDataType > "$OUT/02_graphics.txt"
system_profiler SPAirPortDataType > "$OUT/03_wifi.txt"
system_profiler SPBluetoothDataType > "$OUT/04_bluetooth.txt"
system_profiler SPUSBDataType > "$OUT/05_usb.txt"
networksetup -listallhardwareports > "$OUT/06_network_ports.txt"
diskutil list > "$OUT/07_diskutil_list.txt"
diskutil apfs list > "$OUT/08_apfs_list.txt"
pmset -g > "$OUT/09_power_settings.txt"

echo "→ Zipping..."
cd "$HOME/Desktop"
zip -r "$(basename "$OUT").zip" "$(basename "$OUT")"
echo "✓ Saved: $OUT.zip"
echo ""
echo "Compare this report against the Phase 0 preflight report."
echo "Keep the old 500GB SSD untouched until Mustafar is stable for 1-2 weeks."
