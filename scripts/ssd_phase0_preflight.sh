#!/bin/zsh
# Mustafar — Phase 0: Preflight Inventory
# Run this BEFORE touching any hardware or making any changes.
# Save the output somewhere outside the 500GB SSD (external drive or Tatooine).
set -euo pipefail

OUT="$HOME/Desktop/Mustafar_Preflight_$(date +%Y-%m-%d_%H%M)"
mkdir -p "$OUT"

echo "→ Collecting system info..."
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
nvram -p > "$OUT/10_nvram_snapshot.txt"
ioreg -l | grep -i -e bluetooth -e airport -e broadcom -e brcm > "$OUT/11_wireless_ioreg_grep.txt" || true

echo "→ Zipping..."
cd "$HOME/Desktop"
zip -r "$(basename "$OUT").zip" "$(basename "$OUT")"
echo "✓ Saved: $OUT.zip"
echo ""
echo "Copy this ZIP to an external drive or Tatooine before opening the machine."
