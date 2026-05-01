#!/bin/bash
# d_smb.sh — Phase D SMB setup helper (manual-first)
set -euo pipefail

echo "== Mustafar Phase D: SMB setup checklist =="

echo "1) Create or verify share paths exist (example):"
echo "   sudo mkdir -p /Volumes/Mustafar-Primary/{RAW,Selects,Exports,Archive}"
echo
echo "2) Open System Settings > General > Sharing > File Sharing"
echo "   - Enable File Sharing"
echo "   - Add required folders"
echo "   - Configure per-user access"
echo
echo "3) Validate SMB reachability from another host"
echo "   smb://<mustafar-hostname-or-ip>"
echo
echo "4) Optional CLI checks"
echo "   smbutil statshares -a"
echo
echo "No destructive changes were made by this helper."
